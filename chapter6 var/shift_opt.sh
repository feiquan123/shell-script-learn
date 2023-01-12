#!/bin/bash
# 用法:
# 	shift_opt.sh  -v -l  -q  -f /tmp/go.txt  file1 file2

# 将标志变量设置为空值
file= verbose= quiet= long=

while [ $# -gt 0 ]; do
	case $1 in
		-f) 	file=$2
			shift
			;;
		-v)	verbose=true
			quiet=
			;;
		-q)	quiet=true
			verbose=
			;;
		-l)	long=true
			;;
		--)	shift	# 以 -- 结束
			break
			;;
		-*)	echo $0: $1: unrecognized option >&2
			;;
		*)	break
			;;
	esac

	shift		
done

echo file=$file verbose=$verbose quiet=$quiet long=$long args=[$@]