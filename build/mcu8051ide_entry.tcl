# MCU8051IDE freewrap entry script
# Sets up environment for Windows and sources the real main.tcl

# Determine the root directory (VFS root where files were extracted)
set script_dir [file dirname [info script]]
set ::ROOT_DIRNAME [file normalize $script_dir]

# If the script is inside lib/ (shouldn't be, but just in case), go up
if {[file exists [file join $script_dir lib main.tcl]]} {
    set ::ROOT_DIRNAME [file normalize $script_dir]
} elseif {[file exists [file join $script_dir main.tcl]]} {
    set ::ROOT_DIRNAME [file normalize [file join $script_dir ..]]
}

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
set log_file [file join $::ROOT_DIRNAME startup_log.txt]
if {[catch {source [file join $::LIB_DIRNAME main.tcl]} err]} {
    set fout [open $log_file w]
    puts $fout "ERROR sourcing main.tcl: $err"
    puts $fout "ErrorInfo:\n$::errorInfo"
    puts $fout "\nEnvironment at error point:"
    puts $fout "  ROOT_DIRNAME: $::ROOT_DIRNAME"
    puts $fout "  LIB_DIRNAME: $::LIB_DIRNAME"
    puts $fout "  MICROSOFT_WINDOWS: $::MICROSOFT_WINDOWS"
    puts $fout "  font_size_factor: $::font_size_factor"
    puts $fout "  DEFAULT_FIXED_FONT: $::DEFAULT_FIXED_FONT"
    puts $fout "  class cmd available: [info commands class]"
    puts $fout "  itcl::class available: [info commands ::itcl::class]"
    puts $fout "  Editor::fontSize: [catch {set Editor::fontSize} e2] -> $e2"
    puts $fout "  Editor namespace vars: [info vars Editor::*]"
    puts $fout "  Itcl loaded: [package present Itcl]"
    close $fout
    error $err
}