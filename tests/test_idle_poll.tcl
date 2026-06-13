#!/usr/bin/env tclsh
# test_idle_poll.tcl
# Simulates X::__compilation_poll_tick exactly as it runs in the IDE.
# Watches the real production .mcu8051ide_sdcc_output.log and reports
# the exact elapsed time until the marker is detected.
#
# This is the most direct possible test of the fix: it uses the same
# regex, the same file handle configuration, and the same read-until-pos
# logic as X.tcl.

set work_dir   "C:/tjf/testcases/222"
set input_file [file join $work_dir "004_arrays_structs.c"]
set build_bat  "C:/tjf/github/MCU805IDE_win/build/startsdcc.bat"
set log_path   [file join $work_dir .mcu8051ide_sdcc_output.log]

# Verify prerequisites
if {![file exists $build_bat]}  { puts "FAIL: $build_bat not found"; exit 1 }
if {![file exists $input_file]} { puts "FAIL: $input_file not found"; exit 1 }

# Truncate the log so we start clean
file delete -force $log_path

puts "============================================================"
puts "Idle IDE polling simulation"
puts "============================================================"
puts "bat:    $build_bat"
puts "input:  $input_file"
puts "log:    $log_path"
puts ""

# Stage 1: invoke the bat in the exact way external_compiler.tcl does,
# with forward-slash paths (the post-regsub form).
set work_dir_fwd  "C:/tjf/testcases/222"
set input_file_fwd $input_file
set iram 256
set xram 0
set code 8192
set sdcc_opts [list --nooverlay --noinduction --std-sdcc89 --model-small]

set t0 [clock milliseconds]
set pid [exec -- "$build_bat" \
    "$work_dir_fwd" \
    --iram-size $iram --xram-size $xram --code-size $code \
    {*}$sdcc_opts \
    "$input_file_fwd" &]

# Stage 2: simulate X::__compilation_poll_tick (verbatim from X.tcl)
set compilation_in_progress 1
set __sdcc_output_path $log_path
set __sdcc_output_pos 0
set ticks 0
set seen_done 0
set done_rc ""
set max_ticks 100    ;# 100 * 100ms = 10 seconds, plenty for SDCC

while {$ticks < $max_ticks && $compilation_in_progress && !$seen_done} {
    after 100
    incr ticks
    if {![file exists $__sdcc_output_path]} {continue}
    if {[catch {
        set fh [open $__sdcc_output_path r]
        fconfigure $fh -encoding utf-8
        seek $fh $__sdcc_output_pos
        set new_content [read $fh]
        set __sdcc_output_pos [tell $fh]
        close $fh
    } err]} {
        puts "  poll error: $err"
        continue
    }
    if {$new_content eq ""} {continue}
    foreach line [split $new_content "\n"] {
        if {$line eq ""} {continue}
        if {[regexp {^SDCC_DONE:(-?\d+)} $line -> rc]} {
            set seen_done 1
            set done_rc $rc
            set compilation_in_progress 0
            break
        }
    }
}

set elapsed_ms [expr {[clock milliseconds] - $t0}]

# Stage 3: wait for bat to fully exit and report
catch {wait $pid}

puts ""
puts "============================================================"
puts "RESULT"
puts "============================================================"
puts "poll ticks used: $ticks (1 tick = 100 ms)"
puts "elapsed:         ${elapsed_ms} ms"
puts "marker seen:     $seen_done"
puts "marker rc:       $done_rc"
puts "compilation_in_progress reset: [expr {$compilation_in_progress ? "NO (still stuck)" : "YES"}]"
puts "============================================================"

# Pass criteria:
#   1. marker was seen
#   2. rc = 0 (SDCC succeeded)
#   3. elapsed < 5 seconds (much faster than the 30s watchdog)
#   4. compilation_in_progress was correctly reset
if {$seen_done && $done_rc eq "0" && $elapsed_ms < 5000 && !$compilation_in_progress} {
    puts ""
    puts "PASS: full pipeline works end-to-end in ${elapsed_ms} ms"
    puts "      (no 30s watchdog fire, no manual recovery needed)"
    exit 0
} else {
    puts ""
    puts "FAIL: see criteria above"
    exit 1
}
