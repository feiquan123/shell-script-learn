#!/bin/bash
# 从标准输入读取文本流，在输出出现频率最高的前 n(默认：25) 个单词列表
# 附上出现评率的计数，按计数由大到小排列
# 输出到标准输出
#
# 语法
# 	wf.sh [n]

tr -cs A-Za-z\' '\n' |
	tr A-Z a-z |
		sort |
			uniq -c|
				sort -k1,1nr -k2 |
					sed ${1:-25}q