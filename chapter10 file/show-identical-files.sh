#! /bin/sh -
# 根据它们的 MD5 校验和，
# 显示在某种程度上内容几乎一致的文件名
#
# 语法：
#	show-identical-files files

IFS='
	 '

PATH=/usr/local/bin:/usr/bin:/bin
export PATH

md5sum "$@" /dev/null  2> /dev/null |
	awk '{
		count[$1]++
		if (count[$1] == 1) fist[$1] = $0
		if (count[$1] == 2) print fist[$1]
		if (count[$1] > 1) print $0
	}' |
		sort |
			awk '{
				if (last != $1) print ""
				last = $1
				print
			}'