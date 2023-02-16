md5 "/bin/[
/bin/bash
/bin/cat
/bin/chmod
/bin/cp
/bin/csh
/bin/dash
/bin/date
/bin/dd
/bin/df
/bin/echo
/bin/ed
/bin/expr
/bin/hostname
/bin/kill
/bin/ksh
/bin/launchctl
/bin/link
/bin/ln
/bin/ls
/bin/mkdir
/bin/mv
/bin/pax
/bin/ps
/bin/pwd
/bin/rm
/bin/rmdir
/bin/sh
/bin/sleep
/bin/stty
/bin/sync
/bin/tcsh
/bin/test
/bin/unlink
/bin/wait4path
/bin/zsh" /dev/null  2> /dev/null |
	awk '{
		count[$4]++
		if (count[$4] == 1) fist[$4] = $0
		if (count[$4] == 2) print fist[$4]
		if (count[$4] > 1) print $0
	}' |
		sort |
			awk '{
				if (last != $1) print ""
				last = $1
				print
			}'
