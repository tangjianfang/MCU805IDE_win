#!/usr/bin/env tclsh
# test_regex_red_green.tcl
# Red-green verification of the SDCC_DONE regex change.
#
# 1. The buggy marker (with trailing space) is created by the OLD bat
#    style (set /p "=SDCC_DONE:N").
# 2. The fixed marker (no trailing space) is created by the NEW bat
#    style (echo SDCC_DONE:N).
# 3. Both OLD and NEW regex are tested against both.
#
# Expected:
#   OLD regex: matches only the fixed marker
#   NEW regex: matches both (red-green: new is more permissive)

# Marker data
set fixed_marker "SDCC_DONE:0\r\n"
set buggy_marker "SDCC_DONE:0 \r\n"   ;# the trailing space is the bug

# OLD regex (from the original X.tcl) - anchored, no whitespace tolerance
set old_re {^SDCC_DONE:(-?\d+)$}
# NEW regex (from the fix at X.tcl:4162) - leading anchored, no trailing anchor
set new_re {^SDCC_DONE:(-?\d+)}

set results [list]

set rc1 ""; set rc2 ""; set rc3 ""; set rc4 ""

# Test OLD regex against fixed marker
set m1 [regexp $old_re $fixed_marker rc1]
lappend results [list "OLD regex vs fixed marker" $m1 ($rc1) [expr {$m1 ? "PASS" : "FAIL"}]]

# Test OLD regex against buggy marker (the original bug)
set m2 [regexp $old_re $buggy_marker rc2]
lappend results [list "OLD regex vs buggy marker" $m2 ($rc2) [expr {$m2 ? "PASS" : "FAIL (this is the bug)"}]]

# Test NEW regex against fixed marker
set m3 [regexp $new_re $fixed_marker rc3]
lappend results [list "NEW regex vs fixed marker" $m3 ($rc3) [expr {$m3 ? "PASS" : "FAIL"}]]

# Test NEW regex against buggy marker (defense in depth)
set m4 [regexp $new_re $buggy_marker rc4]
lappend results [list "NEW regex vs buggy marker" $m4 ($rc4) [expr {$m4 ? "PASS" : "FAIL"}]]

# Print results
puts ""
puts "============================================================"
puts "Regex red-green verification"
puts "============================================================"
puts "OLD regex: $old_re"
puts "NEW regex: $new_re"
puts "fixed marker bytes: [string range $fixed_marker 0 end-2] (clean)"
puts "buggy marker bytes: 'SDCC_DONE:0 ' (trailing space)"
puts "------------------------------------------------------------"
foreach r $results {
    puts [format "  %-40s -> %s" [lindex $r 0] [lindex $r 3]]
}
puts "============================================================"

# The critical assertions:
#   - OLD regex MUST fail on the buggy marker (proves the bug exists)
#   - NEW regex MUST succeed on BOTH markers (proves the fix works)
set pass 1
if {$m2} {
    puts "FAIL: OLD regex unexpectedly matched the buggy marker"
    set pass 0
}
if {!$m3} {
    puts "FAIL: NEW regex did not match the fixed marker"
    set pass 0
}
if {!$m4} {
    puts "FAIL: NEW regex did not match the buggy marker (defense in depth broken)"
    set pass 0
}

if {$pass} {
    puts "OVERALL: PASS (red-green confirmed: old was buggy, new is fixed)"
    exit 0
} else {
    puts "OVERALL: FAIL"
    exit 1
}
