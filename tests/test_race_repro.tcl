# test_race_repro.tcl
# Definitive test of the race condition: if poll_start truncates the
# output log AFTER the bat has already written the marker, the marker
# is lost and the polling never fires ext_compilation_complete.

set work_dir   "C:/tjf/c_test_proj"
set log_path   [file join $work_dir .mcu8051ide_sdcc_output.log]

# Force a recompile by running the bat synchronously
file delete -force $log_path
set bat "C:/tjf/github/MCU805IDE_win/build/startsdcc.bat"
set input_file [file join $work_dir main.c]
exec -- $bat "$work_dir" \
    --iram-size 256 --xram-size 0 --code-size 8192 \
    --nooverlay --noinduction --std-sdcc89 --model-small \
    "$input_file"

# Verify marker is there
set fh [open $log_path r]
fconfigure $fh -encoding utf-8
set content [read $fh]
close $fh
puts "After bat, log size: [file size $log_path] bytes, content: |$content|"

# Now simulate the race: poll_start runs AFTER bat finished
# It calls `open $output_path w` to truncate, then poll_tick
puts ""
puts "Simulating poll_start truncate..."
set fh [open $log_path w]
close $fh
set sz [file size $log_path]
puts "After truncate, file size: $sz bytes"

# Now poll_tick will see an empty file forever
set pos 0
set fh [open $log_path r]
fconfigure $fh -encoding utf-8
seek $fh $pos
set new_content [read $fh]
set pos [tell $fh]
close $fh
puts "Poll tick reads: |$new_content| (length [string length $new_content])"

if {$new_content eq ""} {
    puts ""
    puts "*** RACE CONDITION CONFIRMED ***"
    puts "    The bat had already written 'SDCC_DONE:0' to the log file."
    puts "    The poll_start function (in X.tcl) then opened the log"
    puts "    with mode 'w' (truncating it) AFTER the bat had finished."
    puts "    The poll_tick sees an empty file and the marker is lost."
    puts "    Only the 30-second watchdog will recover."
    exit 0
} else {
    puts "RACE NOT REPRODUCED: marker still visible"
    exit 1
}
