# gen_wrap_list.tcl - Generate list_of_files_to_wrap.txt by scanning build dir
# Usage: tclsh gen_wrap_list.tcl <build_dir>
# This script scans the build directory for all files that should be wrapped
# into the freewrap VFS, and writes their relative paths to the wrap list.
# Compatible with freewrap TCLSH (which lacks file relativename).

if {$argc < 1} {
    puts "Usage: tclsh gen_wrap_list.tcl <build_dir>"
    exit 1
}

set build_dir [lindex $argv 0]
if {![file exists $build_dir]} {
    puts "ERROR: Build directory not found: $build_dir"
    exit 1
}

# Convert to normalized path for consistent prefix stripping
set build_dir [file normalize $build_dir]
# Ensure trailing separator for prefix matching
set base_prefix "${build_dir}/"

# Files to EXCLUDE from the wrap list (build artifacts, not runtime data)
set exclude_patterns [list \
    "list_of_files_to_wrap.txt" \
    "mcu8051ide.exe" \
    "mcu8051ide.ico" \
    "external_command.exe" \
    "startup_log.txt" \
    "mcu8051ide-*.exe" \
    "mcu8051ide-*.zip" \
    "*.iss" \
    "ext_cmd_entry.tcl" \
]

# Directories to skip entirely (build-only, not needed in VFS)
set exclude_dirs [list \
    "doc" \
]

# Extensions to skip (build artifacts)
set exclude_exts [list \
    ".log" \
    ".bak" \
]

# Compute relative path by stripping the base directory prefix
proc make_relative {abspath base_prefix} {
    # Strip the base directory prefix to get relative path
    set rel [string range $abspath [string length $base_prefix] end]
    # Normalize: replace backslashes with forward slashes for consistency
    set rel [string map {\\ /} $rel]
    return $rel
}

proc should_exclude {relpath} {
    global exclude_patterns exclude_dirs exclude_exts

    # Check exclude patterns (match against just the filename or full path)
    set filename [file tail $relpath]
    foreach pat $exclude_patterns {
        if {[string match $pat $filename] || [string match $pat $relpath]} {
            return 1
        }
    }

    # Check exclude directories (first component of relative path)
    set parts [split $relpath "/"]
    set first_dir [lindex $parts 0]
    foreach d $exclude_dirs {
        if {$first_dir eq $d} {
            return 1
        }
    }

    # Check exclude extensions
    set ext [file extension $relpath]
    foreach e $exclude_exts {
        if {$ext eq $e} {
            return 1
        }
    }

    return 0
}

proc scan_dir {dir base_prefix} {
    set result [list]
    foreach f [glob -nocomplain -directory $dir *] {
        set relpath [make_relative $f $base_prefix]

        if {[file isdirectory $f]} {
            # Recurse into subdirectory
            set sub_result [scan_dir $f $base_prefix]
            set result [concat $result $sub_result]
        } else {
            # Check if file should be included
            if {![should_exclude $relpath]} {
                lappend result $relpath
            }
        }
    }
    return $result
}

puts "Scanning build directory: $build_dir"

set files [scan_dir $build_dir $base_prefix]

# Sort for reproducible output
set files [lsort $files]

# Write to wrap list file
set outfile [file join $build_dir list_of_files_to_wrap.txt]
set fout [open $outfile w]
foreach f $files {
    puts $fout $f
}
close $fout

puts "Generated wrap list with [llength $files] files"
puts "Output: $outfile"