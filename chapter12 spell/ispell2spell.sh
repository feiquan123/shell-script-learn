#! /bin/sh

# UNIX 的 spell 把 '+file' 的第一个参数看作是
# 提供私有拼写列表
#
# Usage:
# 	ispell2spell.sh +dictfile checkfile

mydict=
case $1 in 
	+?*)	mydict=${1#+}
		mydict="-p $mydict"  # -p 指定备用个人词典
		shift
		;;
esac

cat "$@" | ispell -l $mydict | sort -u