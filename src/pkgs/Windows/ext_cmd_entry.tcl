# ext_cmd_entry.tcl - Entry script for external_command.exe
# Wraps batch file execution for the IDE's external tool integration.
# Executes the command passed as arguments.

if {$argc > 0} {
    set cmd [lindex $argv 0]
    for {set i 1} {$i < $argc} {incr i} {
        append cmd " [lindex $argv $i]"
    }
    catch {exec $cmd} result
    puts $result
}