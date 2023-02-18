#! /bin/sh -
# 打印一个或多个未使用的 uid
# 
# 语法：
# 	newuids.sh [-c N] list-of-ids-file
# 	-c N 	显示 N 个未使用的 uid

count=1		# 预定要显示的 uid 个数

# 解析参数，令 sh 发出诊断
# 必要时离开程序
while getopts "c:" opt
do
	case $opt in
	c) count=$OPTARG ;;
	esac
done

shift $(($OPTIND - 1))

IDFILE="$1"

# 注意 -v count 需要带上引号
awk -v count="$count" '
	BEGIN {
		# getline 读取文件中的数据赋值到 id 变量中
		for (i = 1; getline id > 0; i++)
			uidlist[i] = id
		
		totalids = i

		for (i = 2; i <= totalids; i++){
			if (uidlist[i-1] != uidlist[i]){
				for (j = uidlist[i-1] + 1; j < uidlist[i]; j++ ) {
					print j
					if ( --count == 0){
						exit
					}
				}
			}
		}
	}
' $IDFILE