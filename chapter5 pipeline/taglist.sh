#!/bin/bash
# 读取命令行上给的的 HTML/SGML/XML 文件
# 找出包含像 <tag>word</tag> 这样的标记，在输出到标准输出
# 该标准输出将以制表符(tab)分割字段，依次为
# 计数	单词	标签	文件名
# 按照单词于标签由小到达排序
#
# 语法：
# 	taglist.sh xml-file

cat "$1" |
	sed -e "s#\(<[^ ]*\) [^<>]*#\1#g" -e 's#\(<[^/]\)#\n\1#g' |
		tr ' (){}[]' '\n\n\n\n\n\n\n' |
			egrep '>[^<>]+</' |
				awk -F'[<>]' -v FILE="$1" '{ printf("%-31s\t%-15s\t%s\n", $3, $2, FILE) }' |
					sort |
						uniq -c |
							sort -k2,2 -k3,3 |
								awk '{
									print ($2 == Last)? ($0 " <----") : $0
									Last = $2
								}'