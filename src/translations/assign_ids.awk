#! /usr/bin/gawk -f

function get_trans_str(source_string) {
	if(match(source_string, /mcset \$l/)) {
		trans_str_org=substr(source_string, RSTART+9)
		sub(/[ \t]*\\$/, "", trans_str_org)
		return trans_str_org
	} else {
		return ""
	}
}

BEGIN {
	while(getline line < "template.txt") {
		if(match(line, /namespace[ \t]+eval/)) {
			ns=line
			sub(/^[ \t]*namespace[ \t]+eval[ \t]+/,"",ns)
			sub(/[ \t]*\{$/,"",ns)
			continue
		}
		if(!match(line, /^[ \t]*##ID\:[0-9][0-9][0-9][0-9][0-9][0-9]##[ \t]*$/)) {
			continue
		}

		sub(/^[ \t]+/,"",line)
		sub(/[ \t]+$/,"",line)
		id=line

		getline line < "template.txt"
		trc=get_trans_str(line)
		if(trc == "") {
			exit(1)
		}

		template_arr[ns,trc]=id
	}
	close("template.txt")
}

/namespace[ \t]+eval/ {
	ns=$0
	sub(/^[ \t]*namespace[ \t]+eval[ \t]+/,"",ns)
	sub(/[ \t]*\{$/,"",ns)
}

/^[ \t]*mcset \$l/ {
	xxx=get_trans_str($0)
	print(template_arr[ns,xxx])
}

{
	print($0)
}
