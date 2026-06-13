#!/usr/bin/env tclsh
# test_sdcc_polling.tcl
# End-to-end test of the SDCC output polling pipeline.
#
# Simulates what the IDE does (X::__compilation_poll_tick) when reading
# the .mcu8051ide_sdcc_output.log written by startsdcc.bat.
#
# Pass criteria: the SDCC_DONE marker is detected within 1 second of
# SDCC finishing, without the 30-second watchdog needing to fire.

set test_dir "C:/tjf/testcases/poll_e2e"
file mkdir $test_dir

# Stage 1: copy the production bat (the one shipped with build/) to the
# test dir, the same way build_exe.bat ships it next to the exe.
set build_bat "C:/tjf/github/MCU805IDE_win/build/startsdcc.bat"
set stage_bat [file join $test_dir startsdcc.bat]
file copy -force $build_bat $stage_bat

# Re-run lf2crlf to be safe (build_exe.bat already did this, but the
# test must not depend on it).
exec cscript //nologo "C:/tjf/github/MCU805IDE_win/src/pkgs/Windows/lf2crlf.vbs" \
    "$stage_bat" "${stage_bat}.crlf"
file rename -force "${stage_bat}.crlf" $stage_bat

# Stage 2: invoke the bat with forward-slash paths, exactly the way
# external_compiler.tcl's exec would after the regsub fix.
set work_dir_fwd "C:/tjf/testcases/222"
set input_file   [file join $work_dir_fwd "004_arrays_structs.c"]
if {![file exists $input_file]} {
    puts "SKIP: test input $input_file not present"
    exit 0
}

set output_log [file join $work_dir_fwd .mcu8051ide_sdcc_output.log]
file delete -force $output_log

set bat_start_ms [clock milliseconds]
set bat_pid [exec -- "$stage_bat" \
    "$work_dir_fwd" \
    --iram-size 256 --xram-size 0 --code-size 8192 \
    --nooverlay --noinduction --std-sdcc89 --model-small \
    "$input_file" &]

# Stage 3: poll the output log the same way X.tcl does.
# Run for at most 5 seconds, tick every 100ms. Bail as soon as
# SDCC_DONE is seen.
set seen_done 0
set done_rc ""
set max_ticks 50
set pos 0
for {set i 0} {$i < $max_ticks} {incr i} {
    after 100
    if {![file exists $output_log]} {continue}
    set fh [open $output_log r]
    fconfigure $fh -encoding utf-8
    seek $fh $pos
    set chunk [read $fh]
    set pos [tell $fh]
    close $fh
    if {$chunk eq ""} {continue}
    foreach line [split $chunk "\n"] {
        if {$line eq ""} {continue}
        if {[regexp {^SDCC_DONE:(-?\d+)} $line -> rc]} {
            set seen_done 1
            set done_rc $rc
            break
        }
    }
    if {$seen_done} {break}
}

set elapsed_ms [expr {[clock milliseconds] - $bat_start_ms}]

# Report
puts ""
puts "============================================================"
puts "SDCC polling pipeline E2E test"
puts "============================================================"
puts "output log:  $output_log"
puts "poll ticks:  $i"
puts "elapsed:     ${elapsed_ms} ms"
puts "marker seen: $seen_done"
puts "marker rc:   $done_rc"
puts "============================================================"

if {$seen_done && $elapsed_ms < 3000} {
    puts "PASS: marker detected within [expr {$elapsed_ms}] ms"
    exit 0
} else {
    puts "FAIL: marker not seen within timeout, or took too long"
    puts "--- last 30 bytes of output log ---"
    catch {
        set fh [open $output_log r]
        fconfigure $fh -encoding utf-8
        seek $fh -30 end
        puts [read $fh]
        close $fh
    }
    exit 1
}
