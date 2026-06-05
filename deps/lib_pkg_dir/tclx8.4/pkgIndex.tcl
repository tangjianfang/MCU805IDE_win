# -*- tcl -*-
# TclX package index - version 8.4
# NOTE: This pkgIndex requires tclx84.dll (compiled C extension)
# The DLL must be compiled from tclx source with MinGW/MSVC + Tcl headers
# Until the DLL is available, the C core of TclX will not load
# However, the pure-Tcl library files can still be sourced individually

if {![package vsatisfies [package provide Tcl] 8.6-]} {return}

# TODO: Compile tclx84.dll from source (tclx8.4.tar.bz2)
#       using: MinGW gcc with Tcl 8.6 development headers
package ifneeded Tclx 8.4 [list load [file join $dir tclx84.dll]]