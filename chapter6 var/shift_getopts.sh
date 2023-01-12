#!/bin/bash
# 用法
#	shift_getopts.sh  -v -l  -q  -f /tmp/go.txt  file1 file2

# 将标志变量设置为空值
file= verbose= quiet= long=

while getopts :f:vql opt; do
	case $opt in
		f)	file=$OPTARG
			;;
		v)	verbose=true
			quiet=
			;;
		q)	quiet=true
			verbose=
			;;
		l)	long=true
			;;
		'?')	echo "$0: invalid option -$POTARG" >&2
			echo "Usage: $0 [-f file] [-vql] [files ....]" >&2
			exit 1
			;;
	esac
done

shift $((OPTIND - 1))

echo file=$file verbose=$verbose quiet=$quiet long=$long args=[$@]