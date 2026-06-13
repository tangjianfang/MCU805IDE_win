# test_hook.tcl - Optional test automation hook
# Activated only when env var MCU8051IDE_AUTOCOMPILE_FILE is set.
# Has zero effect for normal users.

if {[info exists ::env(MCU8051IDE_AUTOCOMPILE_FILE)]
	&& $::env(MCU8051IDE_AUTOCOMPILE_FILE) ne ""} {
	set ::AUTOCOMPILE_FILE $::env(MCU8051IDE_AUTOCOMPILE_FILE)
	set ::AUTOCOMPILE_RESULT [file join $::env(TEMP) mcu8051ide_autocompile_result.txt]
	set ::AUTOCOMPILE_START_MS [clock milliseconds]

	proc ::__autocompile_log {msg} {
		set fh [open $::AUTOCOMPILE_RESULT a]
		puts $fh "[clock format [clock seconds] -format {%H:%M:%S}] $msg"
		close $fh
	}

	proc ::__autocompile_tick {} {
		::__autocompile_log "tick: actualProject='${::X::actualProject}' APPLICATION_LOADED=$::APPLICATION_LOADED"
		if {![info exists ::APPLICATION_LOADED] || !$::APPLICATION_LOADED} {
			after 200 [list ::__autocompile_tick]
			return
		}
		if {${::X::actualProject} eq ""} {
			after 200 [list ::__autocompile_tick]
			return
		}

		# Verify the editor has a file open and report state
		::__autocompile_log "STATE: project_menu_locked=$::X::project_menu_locked"
		::__autocompile_log "STATE: compilation_in_progress=$::X::compilation_in_progress"
		::__autocompile_log "STATE: main_file=[${::X::actualProject} cget -P_option_main_file]"

		# Send F11 (the standard compile hotkey) to the toplevel.
		# event_generate is the closest to a real key press we can do
		# from inside the same Tk process without SendKeys.
		::__autocompile_log "SENDING F11 at [clock format [clock seconds] -format {%H:%M:%S}]"
		event generate . <Key> -keysym F11
		update

		# Capture every line that the poll forwards to the message panel,
		# so we can verify the \r / control-char stripping works.
		set ::__autocompile_lines_log [file join $::env(TEMP) mcu8051ide_autocompile_lines.txt]
		set ::__autocompile_capture [list]
		# Rename compilation_message so we can wrap it. We can't easily
		# intercept messages_text_append (it's a Snit method), but
		# compilation_message is a plain X:: proc and is called from the
		# poll tick before messages_text_append - so logging the argument
		# here is a faithful picture of what the user sees.
		rename ::X::compilation_message ::X::compilation_message__orig
		proc ::X::compilation_message {args} {
			lappend ::__autocompile_capture [lindex $args 0]
			return [::X::compilation_message__orig {*}$args]
		}

		# Poll the result via monitor
		after 500 [list ::__autocompile_monitor]
	}

	proc ::__autocompile_monitor {} {
		set elapsed [expr {[clock milliseconds] - $::AUTOCOMPILE_START_MS}]
		::__autocompile_log "MONITOR elapsed=${elapsed}ms in_progress=$::X::compilation_in_progress"
		if {${::X::compilation_in_progress}} {
			# still running
			if {$elapsed > 60000} {
				::__autocompile_log "TIMEOUT: in_progress=1 after 60s"
				after 500 {exit 2}
				return
			}
			after 500 [list ::__autocompile_monitor]
			return
		}
		# Done
		# Dump every line that the poll forwarded to compilation_message
		# so we can verify \r / control-char stripping works.
		if {[info exists ::__autocompile_capture]} {
			set fh [open $::__autocompile_lines_log w]
			puts $fh "=== captured [llength $::__autocompile_capture] lines ==="
			set n 0
			foreach line $::__autocompile_capture {
				incr n
				# Show repr of each line so \r and other control chars are visible
				puts $fh "[format %03d $n] |$line|"
			}
			close $fh
			::__autocompile_log "CAPTURED_LINES: [llength $::__autocompile_capture] lines -> $::__autocompile_lines_log"
		}
		::__autocompile_log "DONE: elapsed=${elapsed}ms in_progress=0"
		# Check if SDCC log got the marker
		set log_path [file join [file dirname ${::AUTOCOMPILE_FILE}] .mcu8051ide_sdcc_output.log]
		if {[file exists $log_path]} {
			set sz [file size $log_path]
			::__autocompile_log "SDCC_LOG: path=|${log_path}| size=${sz}"
			set fh [open $log_path r]
			set content [read $fh]
			close $fh
			if {[regexp {^SDCC_DONE:(-?\d+)} $content -> bat_rc]} {
				::__autocompile_log "SDCC_LOG: has_done=1 rc=${bat_rc}"
			} else {
				::__autocompile_log "SDCC_LOG: has_done=0 (no SDCC_DONE marker)"
			}
			set last5 [lrange [split $content "\n"] end-4 end]
			::__autocompile_log "SDCC_LOG_LAST5: [join $last5 { | }]"
		} else {
			::__autocompile_log "SDCC_LOG: file does not exist at |${log_path}|"
		}
		after 500 {exit 0}
	}

	# Initialize log file
	set fh [open $::AUTOCOMPILE_RESULT w]
	puts $fh "INIT: [clock format [clock seconds] -format {%Y/%m/%d %H:%M:%S}]"
	puts $fh "AUTOCOMPILE_FILE: ${::AUTOCOMPILE_FILE}"
	close $fh

	# Start after 1.5s to let project load
	after 1500 [list ::__autocompile_tick]
}
