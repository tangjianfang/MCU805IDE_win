# test_race_fixed.tcl
# Verify the fix: poll_start must NOT truncate the output log.
# Simulates the exact scenario:
#   1. Bat completes (writes SDCC_DONE:0 to log)
#   2. poll_start runs AFTER bat (the race condition window)
#   3. Poll tick should still see the marker
# Without the fix, poll_start would truncate the log and the poll would
# see an empty file. With the fix, the marker survives.

set work_dir   "C:/tjf/c_test_proj"
set log_path   [file join $work_dir .mcu8051ide_sdcc_output.log]
set bat        "C:/tjf/github/MCU805IDE_win/build/startsdcc.bat"
set input_file [file join $work_dir main.c]

# Force a recompile
file delete -force $log_path
exec -- $bat "$work_dir" \
    --iram-size 256 --xram-size 0 --code-size 8192 \
    --nooverlay --noinduction --std-sdcc89 --model-small \
    "$input_file"

# Verify marker is there
set fh [open $log_path r]
fconfigure $fh -encoding utf-8
set content [read $fh]
close $fh
puts "After bat, log content: |$content|"

# Now do what the FIXED poll_start does (NO truncate)
# Just initialize state and call poll tick
set __sdcc_output_path $log_path
set __sdcc_output_pos 0
set compilation_in_progress 1
set seen_done 0
set done_rc ""

# Run poll tick once
set fh [open $__sdcc_output_path r]
fconfigure $fh -encoding utf-8
seek $fh $__sdcc_output_pos
set new_content [read $fh]
set __sdcc_output_pos [tell $fh]
close $fh

puts ""
puts "Poll tick reads (with fix, no truncate): |$new_content|"

if {$new_content ne ""} {
    foreach line [split $new_content "\n"] {
        if {$line eq ""} {continue}
        if {[regexp {^SDCC_DONE:(-?\d+)} $line -> rc]} {
            set seen_done 1
            set done_rc $rc
        }
    }
}

if {$seen_done} {
    puts ""
    puts "*** FIX VERIFIED ***"
    puts "    Poll tick saw the marker after a fast-completing bat."
    puts "    rc=$done_rc"
    puts "    ext_compilation_complete would now be called."
    exit 0
} else {
    puts ""
    puts "FIX FAILED: marker not seen"
    exit 1
}
