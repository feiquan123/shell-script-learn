#! /bin/sh -
# 寻找所有的文件及目录
# 在目录树下，将最近修改过的加以组化
# 并于最上层的 FILES.* 与 DIRECTORIES.* 内置列表
# 
# 语法：
# 	filesdirectories.sh directory

IFS='
	 '

PATH=/usr/local/bin:/bin:/usr/bin  # 需要 GNU find 的 -fprint 选项
export PATH

if [ $# -ne 1 ]
then
	echo "Usage: $0 directory" >&2
	exit 1
fi

umask 077 #确保文件的私密性
TMP=${TMPDIR:-/tmp}

TMPFILES="
	$TMP/DIRECTORIES.all.$$ $TMP/DIRECTORIES.all.$$.tmp
	$TMP/DIRECTORIES.last01.$$ $TMP/DIRECTORIES.last01.$$.tmp
	$TMP/DIRECTORIES.last02.$$ $TMP/DIRECTORIES.last02.$$.tmp
	$TMP/DIRECTORIES.last07.$$ $TMP/DIRECTORIES.last07.$$.tmp
	$TMP/DIRECTORIES.last14.$$ $TMP/DIRECTORIES.last14.$$.tmp
	$TMP/DIRECTORIES.last31.$$ $TMP/DIRECTORIES.last31.$$.tmp
	$TMP/FILES.all.$$ $TMP/FILES.all.$$.tmp
	$TMP/FILES.last01.$$ $TMP/FILES.last01.$$.tmp
	$TMP/FILES.last02.$$ $TMP/FILES.last02.$$.tmp
	$TMP/FILES.last07.$$ $TMP/FILES.last07.$$.tmp
	$TMP/FILES.last14.$$ $TMP/FILES.last14.$$.tmp
	$TMP/FILES.last31.$$ $TMP/FILES.last31.$$.tmp
"

WD=$1  # 存储参数目录名称,供稍后使用
cd $WD || exit 1

# 退出时，移除临时文件
trap 'exit 1'		HUP INT PIPE QUIT TERM
trap 'rm -f $TMPFILES' 	EXIT

find . \
	   -name DIRECTORIES.all -true \
	-o -name 'DIRECTORIES.last[0-9][0-9]' -true \
	-o -name FILES.all -true \
	-o -name 'FILES.last[0-9][0-9]' -true \
	-o -type f 			-fprint $TMP/FILES.all.$$ \
	-a 		-mtime -31 	-fprint $TMP/FILES.last31.$$ \
	-a 		-mtime -14 	-fprint $TMP/FILES.last14.$$ \
	-a 		-mtime -7  	-fprint $TMP/FILES.last07.$$ \
	-a 		-mtime -2 	-fprint $TMP/FILES.last02.$$ \
	-a 		-mtime -1	-fprint $TMP/FILES.last01.$$ \
	-o -type d 			-fprint $TMP/DIRECTORIES.all.$$ \
	-a 		-mtime -31 	-fprint $TMP/DIRECTORIES.last31.$$ \
	-a 		-mtime -14 	-fprint $TMP/DIRECTORIES.last14.$$ \
	-a 		-mtime -7 	-fprint $TMP/DIRECTORIES.last07.$$ \
	-a 		-mtime -2 	-fprint $TMP/DIRECTORIES.last02.$$ \
	-a 		-mtime -1 	-fprint $TMP/DIRECTORIES.last01.$$ 

for i in FILES.all FILES.last31 FILES.last14 FILES.last07 FILES.last02 FILES.last01 \
	DIRECTORIES.all DIRECTORIES.last31 DIRECTORIES.last14 DIRECTORIES.last07 DIRECTORIES.last02 DIRECTORIES.last01
do
	sed -e "s=^[.]/=$WD/=" -e "s=^[.]$=$WD=" $TMP/$i.$$ |
	LC_ALL=C sort > $TMP/$i.$$.tmp

	# 检查内容是否有变更，如果发生变更则进行替换
	cmp -s $TMP/$i.$$.tmp $i || mv $TMP/$i.$$.tmp $i
done