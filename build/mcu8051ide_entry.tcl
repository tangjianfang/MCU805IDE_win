# MCU8051IDE freewrap entry script
# Sets up environment for Windows and sources the real main.tcl
# This file is stored in the source tree and copied to build/ during packaging.
#
# IMPORTANT: Do NOT use file normalize on VFS paths — it resolves to the
# original build-machine directory, which doesn't exist on other computers.
# Instead, use $argv0 (the exe's actual location) to determine ROOT_DIRNAME.

# Determine the root directory from the exe's actual location on this machine.
# In freewrap, $argv0 is the real filesystem path to the running exe.
# The VFS root maps to the directory containing the exe.
set ::ROOT_DIRNAME [file dirname $argv0]

# Normalize using the exe path (this is a real filesystem path, not VFS)
set ::ROOT_DIRNAME [file normalize $::ROOT_DIRNAME]

# Mark that this entry script has run, so main.tcl knows not to
# override our path values with AIPCS placeholders or argv0 logic.
set ::MCU8051IDE_FREWRAP_ENTRY 1

# Set library directory path (where all .tcl source files live)
set ::LIB_DIRNAME [file join $::ROOT_DIRNAME lib]

# For MS Windows: this is the same as LIB_DIRNAME
set ::LIB_DIRNAME_SPECIFIC_FOR_MS_WINDOWS $::LIB_DIRNAME

# Set installation directory (same as ROOT for a freewrap package)
set ::INSTALLATION_DIR $::ROOT_DIRNAME

# Set auto_path for Tcl packages
set ::AUTO_PATH_FOR_MS_WINDOWS [list \
    libraries/bwidget \
    libraries/md5 \
    libraries/tdom \
    libraries/itcl \
    libraries/tclx8.4 \
    libraries/img_png \
]

foreach dir $::AUTO_PATH_FOR_MS_WINDOWS {
    lappend ::auto_path [file join $::ROOT_DIRNAME $dir]
}

# Set library environment variables so DLLs can find their .tcl counterparts
set ::env(ITCL_LIBRARY) [file join $::ROOT_DIRNAME libraries itcl]
set ::env(TCLX_LIBRARY) [file join $::ROOT_DIRNAME libraries tclx8.4]

# Source main.tcl with error tracing - write to log file for diagnosis
# Use USERPROFILE for the log file (writable on any Windows machine)
set log_file [file join $::env(USERPROFILE) .mcu8051ide_startup_log.txt]
if {[catch {source [file join $::LIB_DIRNAME main.tcl]} err]} {
    if {[catch {open $log_file w} fout]} {
        # Can't write to USERPROFILE either — fall back to temp dir
        set log_file [file join [file dirname $argv0] startup_log.txt]
        catch {set fout [open $log_file w]}
    }
    if {[info exists fout]} {
        puts $fout "ERROR sourcing main.tcl: $err"
        puts $fout "ErrorInfo:\n$::errorInfo"

        # Safely read diagnostic variables (they may not exist if main.tcl failed early)
        proc safe_var {name} {
            if {[info exists $name]} {
                return "[set $name]"
            } else {
                return "(undefined)"
            }
        }

        puts $fout "\nEnvironment at error point:"
        puts $fout "  argv0: $argv0"
        puts $fout "  ROOT_DIRNAME: [safe_var ::ROOT_DIRNAME]"
        puts $fout "  LIB_DIRNAME: [safe_var ::LIB_DIRNAME]"
        puts $fout "  MICROSOFT_WINDOWS: [safe_var ::MICROSOFT_WINDOWS]"
        puts $fout "  font_size_factor: [safe_var ::font_size_factor]"
        puts $fout "  Tcl version: [info patchlevel]"
        puts $fout "  auto_path: $::auto_path"
        puts $fout "  Itcl loaded: [catch {package present Itcl}]"
        close $fout
    }
    error $err
}