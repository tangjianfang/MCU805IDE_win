# -*- tcl -*-
# itcl package index - version 4.2.4
# NOTE: This pkgIndex requires itcl424.dll (compiled C extension)
# The DLL must be compiled from itcl source with MinGW/MSVC + Tcl headers
# Until the DLL is available, itcl package will not load

if {![package vsatisfies [package provide Tcl] 8.6-]} {return}

# TODO: Compile itcl424.dll from source (itcl-itcl-4-2-4.tar.gz)
#       using: MinGW gcc with Tcl 8.6 development headers
package ifneeded itcl 4.2.4 [list load [file join $dir itcl424.dll] Itcl]
package ifneeded Itcl 4.2.4 [list package require -exact itcl 4.2.4]