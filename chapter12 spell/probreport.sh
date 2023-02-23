#! /bin/bash -
# Usage:
#	probreport filename

test -z $1 && {
	echo "input filename" 
	exit 1
}

cat "$1" |	# 删除格式化命令
	tr A-Z a-z | 	# 大写转小写
		tr -c a-z '\n' |  # 将非 a-z 字符替换为换行符
			sort |	
				uniq |
					comm -13 /usr/share/dict/words  - 		# 报告不在字典里的词