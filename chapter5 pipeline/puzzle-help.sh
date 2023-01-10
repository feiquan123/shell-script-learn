#!/bin/bash
# 通过单词列表，进行 grep 模式匹配
# word lists
#
# 用法
# 	./puzzle-help.sh egrep-pattern [word-list-files]
#
# 案例
# 	./puzzle-help.sh '^b.....[ab]...$' | fmt
#	./puzzle-help.sh '[^aoeiuy]{6}'

FILES="
	/usr/dict/words
	/usr/share/dict/words
	/usr/share/lib/dict/words
	/usr/local/share/dict/words.biology
	/usr/local/share/dict/words.chemistry
	/usr/local/share/dict/words.general
	/usr/local/share/dict/words.knuth
	/usr/local/share/dict/words.latin
	/usr/local/share/dict/words.manpages
	/usr/local/share/dict/words.mathematics
	/usr/local/share/dict/words.physics
	/usr/local/share/dict/words.roget
	/usr/local/share/dict/words.sciences
	/usr/local/share/dict/words.UNIX
	/usr/local/share/dict/words.webster
"

pattern="$1"

grep -E -h -i "$pattern" $FILES 2>/dev/null | sort -u -f