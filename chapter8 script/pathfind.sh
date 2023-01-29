#!/bin/bash -

# 在查找路径下寻找一个或多个原始文件或文件模式
# 查找路径有一个指定的环境变量所定义。
#
# 标准输出产生的结果，通常是在查找路径下找到的每个文件之第一个实体的完整路径，
# 或是 ”filename: not found“ 的标准错误输出。
#
# 如果所有文件都找到，则退出码为0，
# 否则，即为找不到的文件个数 - 非零值
# （shell 的退出码限制为 125）
#
#
# 语法：
# 	pathfind [--all] [--?] [--help] [--version] envvar pattern(s)
#
# 选项 --all 指的是寻找路径下的所有目录，
# 而不是找到第一个就停止

IFS=' '

OLDPATH="$PATH"
PATH=/bin:/usr/bin
export PATH

usage(){
	echo "Usage: $PROGRAM [--all] [--?] [--help] [--version] envvar pattern(s)"
}

usage_and_exit(){
	usage
	exit $1
}

error(){
	echo "$@" 1>&2
	usage_and_exit 1
}

warning(){
	echo "$@" 1>&2
	EXITCODE=`expr $EXITCODE + 1`
}

version(){
	echo "$PROGRAM version $VERSION"
}

all=no
envvar=
EXITCODE=0
PROGRAM=`basename $0`
VERSION=1.0

while test $# -gt 0 ; do
	case $1 in 
	--all | --al | --a | -all | -al | -a )
		all=yes
		;;
	--help | --hel | --he | --h | '--?' | -help | -hel | -he | -h | '-?' )
		usage_and_exit 0
		;;
	--version | --versio | --versi | --vers | --ver | --ve | --v | \
	-version | -versio | -versi | -vers | -ver | -ve | -v )
		version
		exit 0
		;;
	-*)
		error "Unrecognized option: $1 "
		;;
	*)
		break
		;;
	esac
	shift
done

# 默认之后的一个参数为 环境变量名
envvar="$1"
# 如果还有其他参数，则偏移
test $# -gt 0 && shift
# 如果环境变量名为 PATH，则使用 OLDPATH 
test "x$envvar" = "xPATH" && envvar=OLDPATH
# 获取环境变量对应的路径
dirpath=`eval echo '${'"$envvar"'}' 2>/dev/null | tr : ' ' `

# 错误检测
if test -z "$envvar"; then 
	error Enviroment variable missing or empty
elif test "x$dirpath" = "x$envvar" ; then
	error "Broken sh on this platform; cannot expand $envvar"
elif test -z "$dirpath"; then
	error Empty directory search path
elif test $# -eq 0; then
	exit 0
fi

for pattern in "$@"; do 
	result=""
	for dir in ${dirpath}; do
		for file in $dir/$pattern; do
			if test -f $file; then 
				result=$file
				echo $result
				test "$all" = "no" && break 2
			fi
		done
	done
	test -z "$result" && warning "$pattern: not found"
done

# 限制退出状态，一般是 UNIX 实现上的限制【0-125】
test $EXITCODE -gt 125 && EXITCODE=125

exit $EXITCODE