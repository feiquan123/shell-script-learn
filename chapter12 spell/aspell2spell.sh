#! /bin/sh

# UNIX 的 spell 把 '+file' 的第一个参数看作是
# 提供私有拼写列表
#
# Usage:
# 	aspell2spell.sh +dictfile checkfile

mydict=
case $1 in 
	+?*)	mydict=${1#+}
		# -v 显示除了匹配特定模式的行以外的所有行
		# -f StringFile：指定包含字符串的文件
		mydict="fgrep -v -f $mydict" 
		shift
		;;
esac

cat "$@" | aspell -l --mode=none | sort -u | eval $mydict