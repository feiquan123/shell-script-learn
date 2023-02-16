#! /bin/sh -
# 根据它们的 MD5 校验和，
# 显示在某种程度上内容几乎一致的文件名
#
# 语法：
#	show-identical-files files

IFS='
	 '

PATH=/usr/local/bin:/usr/bin:/bin:/sbin/
export PATH

md5 "$@" /dev/null  2> /dev/null |
	awk '{
		count[$4]++
		if (count[$4] == 1) fist[$4] = $0
		if (count[$4] == 2) print fist[$4]
		if (count[$4] > 1) print $0
	}' |
		sort -k4 |
			awk '{
				if (last != $4) print ""
				last = $4
				print
			}'