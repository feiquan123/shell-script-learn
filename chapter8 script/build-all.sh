#! /bin/bash -
#
# 以并行处理的方式，在一台或多台构建主机上，建立一个或多个包
#
# 语法：
# 	build-all	[ --? ]
# 			[ --all "..." ]
#			[ --cd "..." ]
#			[ --check "..." ]
#			[ --configure "..." ]
#			[ --environment "..." ]
#			[ --help ]
#			[ --logdirectory dir ]
#			[ --on "[user@]host[:dir][,envfile] ..." ]
#			[ --source "dir..." ]
#			[ --userhosts "file(s)" ]
#			[ --version ]
#			package(s)
#
# 可选用的初始文件：
# 	$HOME/.build/directories	list of source directories
# 	$HOME/.build/userhosts		list of [user@]host[:dir][,envfile]

IFS='
	 '

# 权限校验，不能以 root 用户身份运行
test "`id -u`" -eq 0 && \
	error "For security reasons, this program must NOT be run by root"

# 查找路径限制，并用 export 使其成为全局性，以使所有子进程都可以使用它
PATH=/usr/local/bin:/bin:/usr/bin
export PATH

# 设置访问权限掩码
UMASK=002
umask $UMASK

usage(){
	cat <<EOF
Usage:
	$PROGRAM 	[ --? ]
			[ --all "..." ]
			[ --cd "..." ]
			[ --check "..." ]
			[ --configure "..." ]
			[ --environment "..." ]
			[ --help ]
			[ --logdirectory dir ]
			[ --on "[user@]host[:dir][,envfile] ..." ]
			[ --source "dir..." ]
			[ --userhosts "file(s)" ]
			[ --version ]
			package(s)
EOF
}

usage_and_exit(){
	usage
	exit $1
}

version(){
	echo "$PROGRAM version $VERSION"
}

error(){
	echo "$@" 1>&2
	usage_and_exit 1
}

warning(){
	echo "$@" 1>&2
	EXITCODE=`expr $EXITCODE + 1`
}

find_file(){
	# 测试包存档文件的可读性 & 是否存在，再将其参数记录到两个全局变量中
	# Usage: 
	# 	find_file file program-and-args
	# Return 0 (success) if found, 1 (failure) if not found

	if test -r "$1"
	then
		PAR="$2"	# 用来提取的程序与参数
		PARFile="$1"	# 要提取来源的实际文件
		return 0
	else
		return 1
	fi
}

find_package(){
	# 遍历源目录查找包
	# Usage: find_package package-x.y.z
	base=`echo "$1" | sed -e 's/[-_][.]*[0-9].*$//' -e`
	PAR=
	PARFILE=
	for srcdir in $SRCDIRS
	do
		test "$srcdir" = "." && srcdir="`pwd`"

		for subdir in "$base" ""
		do
			# NB: update package setting in build_one() if this list changes
			find_file $srcdir/$subdir/$1.tar.gz	"tar xfz"	&& return
			find_file $srcdir/$subdir/$1.tar.Z	"tar xfz"	&& return
			find_file $srcdir/$subdir/$1.tar	"tar xf"	&& return
			find_file $srcdir/$subdir/$1.tar.bz2	"tar xfj"	&& return
			find_file $srcdir/$subdir/$1.tgz	"tar xfz"	&& return
			find_file $srcdir/$subdir/$1.zip	"unzip -q"	&& return
			find_file $srcdir/$subdir/$1.jar	"jar xf"	&& return
		done
	done
}


set_userhosts(){
	# Usage: set_userhosts file(s)
	for u in "$@"
	do
		if test -r "$u"
		then
			ALTUSERHOSTS="$ALTUSERHOSTS $u"
		elif test -r "$BUILDHOME/$u"
		then
			ALTUSERHOSTS="$ALTUSERHOSTS $BUILDHOME/$u"
		else
			error "File not found: $u"
		fi
	done
}

build_one(){
	# Usage:
	#	build_one (user@)host[:build-directory][,envfile]

	arg="`eval echo $1`"				# 展开环境变量
	userhost="`echo $arg | sed -e 's/:.*$//'`"	# 删除冒号与冒号后的任何东西

	user="`echo $userhost | sed -e 's/@.*$//'`"	# 取出用户名
	test "$user" = "$userhost" && user=$USER	# 如果为空，则使用 $USER

	host="`echo $userhost | sed -e 's/^[^@]*@//'`"	# 取出主机名

	envfile="`echo $arg | sed -e 's/^[^,]*,//'`"	# 环境变量文件名称
	test "$envfile" = "$arg" && envfile=/dev/null

	builddir="`echo $arg | sed -e 's/^.*://'` -e 's/,.*//'" # 构建目录
	test "$builddir" = "$arg" && builddir=/tmp

	parbase=`basename $PARFILE`
	package=`echo $parbase | \
		sed 	-e 's/[.]jar$//' \
			-e 's/[.]tar[.]bz2$//' \
			-e 's/[.]tar[.]gz$//' \
			-e 's/[.]tar[.]Z$//' \
			-e 's/[.]tar$//' \
			-e 's/[.]tgz$//' \
			-e 's/[.]zip$//'`
	
	# 将存档复制到远程主机
	echo $SSH $SSHFLAGS $userhost "test -f $PARFILE"
	if $SSH $SSHFLAGS $userhost "test -f $PARFILE"
	then
		parbaselocal=$PARFILE
	else
		parbaselocal=$parbase
		echo $scp $PARFILE $userhost:$builddir
		$scp $PARFILE $userhost:$builddir
	fi

	# 确定日志文件名
	sleep 1 			# 为了确保唯一的日志文件名
	now="`date $DATEFLAGS`"
	logfile="$package.$host.$now.log"
	
	nice $SSH $SSHFLAGS $userhost "
		echo '====================================' ;
		# 加载构建初始化脚本
		test -f $BUILDBEGIN && . $BUILDBEGIN || \
			test -f $BUILDBEGIN && source $BUILDBEGIN || \
				true;
		
		# 打印
		echo 'Package: 			$package' ;
		echo 'Archive:			$PARFile' ;
		echo 'Date:			$now' ;
		echo 'Local user:		$USER' ;
		echo 'Local host:		`hostname`' ;
		echo 'Local log directory:	$LOGDIR' ;
		echo 'Local log file:		$logfile' ;
		echo 'Remote user:		$user' ;
		echo 'Remote host:		$host' ;
		echo 'Remote directory:		$builddir' ;

		printf 'Remote date:		' ;
		date $DATEFLAGS ;
		printf 'Remote uname:		' ;
		uname -a || true ;
		printf 'Remote gcc version:	' ;
		gcc --version | head -n 1 || echo ;
		printf 'Remote g++ version:	' ;
		g++ --version | head -n 1 || echo ;

		echo 'Configure environment:	`$STRIPCOMMENTS $envfile | $JOINLINES`' ;
		echo 'Extra environment:	$EXTRAENVIRONMENT' ;
		echo 'Configure directory:	$CONFIGUREDIR' ;
		echo 'Configure flags:		$CONFIGUREFLAGS' ;
		echo 'Make all targets:		$ALLTARGETS' ;
		echo 'Make check targets:	$CheckTARGETS' ;
		echo 'Disk free report for $builddir/$package:';
		df $builddir | $INDENT ;
		echo 'Environment:' ;
		env | env LC_ALL=C sort | $INDENT ;

		echo '====================================' ;
		# 设置掩码
		umask $UMASK;
		
		# 切换到工作目录
		cd $builddir || exit 1 ;

		# 移除之前的安装目录
		/bin/rm -rf $builddir/$package ;
		
		# 解压缩
		$PAR $parbaselocal ;

		# 解压完后删除源文件
		test "$parbase" = "$parbaselocal" && /bin/rm -f $parbase ;

		# 切换到包目录
		cd $package/$CONFIGUREDIR || exit 1 ;
		
		# 如果提供了 configure 则使用它开始构建
		test -f configure && \
			chmod a+x configure && \
				env `$STRIPCOMMENTS $envfile | $JOINLINES` \
					$EXTRAENVIRONMENT \
						nice time ./configure $CONFIGUREFLAGS ;
		
		# 开始构建
		nice time make $ALLTARGETS && nice time make $CHECKTARGETS ;

		echo '====================================' ;
		echo 'Disk free report for $builddir/$package:' ;
		df $builddir | $INDENT ;

		printf 'Remote date:		' ;
		date $DATEFLAGS ;

		cd ;
		test -f $BUILDEND && .$BUILDEND || \
			test -f $BUILDEND && source $BUILDEND || \
				true ;
		
		echo '====================================' ;
	" < /dev/null > "$LOGDIR/$logfile" 2>&1 &
	
}

ALLTARGETS=							# 程序或 make target 构建用
altlogdir=							# 日志文件的另一个位置
altsrcdirs=							# 来源文件的另一个位置
ALTUSERHOSTS=							# 列出额外主机的文件
CHECKTARGETS=check						# 执行包测试的 make target 名称
CONFIGUREDIR=							# 配置脚本的子目录
CONFIGUREFLAGS=							# 配置程序的特殊标志
LOGDIR=								# 本地目录，以保留日志文件
userhosts=							# 在命令行上指定的额外构建主机
BUILDHOME=$HOME/.build						# build-all 的初始化文件所在目录
BUILDBEGIN=./.build/begin 					# 构建开始时，在远程主机上的的登录 shell 内执行
BUILDEND=./.build/end 						# 构建结束时，在远程主机上的的登录 shell 内执行
EXITCODE=0							# 最终退出码
EXTRAENVIRONMENT=						# 任何额外的环境变量都会传入
PROGRAM=`basename $0`						# 程序名称
VERSION=1.0							# 程序版本号
DATEFLAGS="+%Y.%m.%d.%H.%M.%S" 					# 日志文件名中的时间格式
SCP=scp								# 远程文件传输
SHH=shh								# 远程登录
SSHFLAGS=${SSHFLAGS--x}						# ssh 会建立个别加密通道(channel), 不需要此功能默认关闭
STRIPCOMMENTS="sed -e 's/#.*$//'"					# 移除 shell 注释
INDENT="awk '{ print \"\t\t\t\" \$0 }'" 			# 将数据流过滤为内缩状
JOINLINES="tr '\n' '\040'" 					# 将换行字符替换为空格
defaultdirectories=$BUILDHOME/directories			# 初始 directories 文件定义
defaultuserhosts=$BUILDHOME/userhosts				# 初始 userhosts 文件定义
SRCDIRS="`$STRIPCOMMENTS $defaultdirectories 2>/dev/null`"	# 初始化设置来源模板的列表

# 当用户定制文件不存在时，使用默认值填充
test -z "$SRCDIRS" && \
	SRCDIRS="
		.
		/usr/local/src
		/usr/local/gnu/src
		$HOME/src
		$HOME/gnu/src
		/tmp
		/usr/tmp
		/var/tmp
	"

while test $# -gt 0
do 
	case $1 in 
	--all | --al | --a | -all | -al | -a )
		shift
		ALLTARGETS="$1"
		;;

	--cd | -cd )
		shift
		CONFIGUREDIR="$1"
		;;

	--check | --chec | --che | --ch | -check | -chec | -che | -ch )
		shift
		CHECKTARGETS="$1"
		;;

	--configure | --configur | --configu | --config | --confi | --conf | --con | --co |\
	-configure | -configur | -configu | -config | -confi | -conf | -con | -co )
		shift
		CONFIGUREFLAGS="$1"
		;;

	--environment | --environmen | --environme | --environm | --environ | --enviro | --envir | \
	--envi | --env | --en | --e | \
	-environment | -environmen | -environme | -environm | -environ | -enviro | -envir | \
	-envi | -env | -en | -e )
		shift
		EXTRAENVIRONMENT="$1"
		;;

	--help | --hel | --he | --h | '--?' | -help | -hel | -he | -h | '-?' )
		usage_and_exit 0
		;;

	--logdirectory | --logdirector | --logdirecto | --logdirect | --logdirec | --logdire |\
	--logdir | --logdi | --logd | --log | --lo | --l |\
	-logdirectory | -logdirector | -logdirecto | -logdirect | -logdirec | -logdire |\
	-logdir | -logdi | -logd | -log | -lo | -l )
		shift
		altlogdir="$1"
		;;

	--on | --o | -on | -o)
		shift
		userhosts="$userhosts $1"
		;;

	--source | --sourc | --sour | --sou | --so | --s |\
	-source | -sourc | -sour | -sou | -so | -s )
		shift
		altsrcdirs="$altsrcdirs $1"
		;;
	
	--userhosts | --userhost | --userhos | --userho | --userh | --user | --use | --us | --u |\
	-userhosts | -userhost | -userhos | -userho | -userh | -user | -use | -us | -u )
		shift
		set_userhosts $1
		;;

	--version | --versio | --versi | --vers | --ver | --ve | --v |\
	-version | -versio | -versi | -vers | -ver | -ve | -v )
		version
		exit 0
		;;

	-*)
		error "unrecognized option:$1 "
		;;

	*)
		break
		;;
	esac
	shift
done

# 邮件客户端程序
for MAIL in 	/bin/mailx /usr/bin/mailx /usr/sbin/mailx /usr/ucb/mailx \
		/bin/mail /usr/bin/mail
do
	test -x $MAIL && break
done

test -x $MAIL || error "Cannot find mail client"

# 用户自定义的额外来源优先
SRCDIRS="$altsrcdirs $SRCDIRS"

# 设置 userhosts 的值
if test -n "$userhosts"
then
	# 当用户指定了 userhosts 时，将 ALTUSERHOSTS 合并进去
	test -n "$ALTUSERHOSTS" &&
		userhosts="$userhosts `$STRIPCOMMENTS $ALTUSERHOSTS 2>/dev/null`"
else
	# 当用户未指定 userhosts 时，如果指定了 ALTUSERHOSTS 则使用 ALTUSERHOSTS ； 否则将其设置为默认文件
	test -z "$ALTUSERHOSTS" && ALTUSERHOSTS="$defaultuserhosts"
	userhosts="`$STRIPCOMMENTS $ALTUSERHOSTS 2>/dev/null`"
fi

test -z "$userhosts" && usage_and_exit 1

# 处理包
for p in "$@"
do
	find_package "$p"  # 结果在全局变量：PARFILE

	if test -z "$PARFILE"
	then
		warning "Cannot find package file $p"
		continue
	fi

	# 日志目录
	LOGDIR="$altlogdir"
	if test -z "$LOGDIR" -o ! -d "$LOGDIR" -o ! -w "$LOGDIR" 			# 判断日志变量是否为空 或 是否存在此目录 或 此目录是否有写入权限
	then
		for LOGDIR in 	"`dirname $PARFILE`/logs/$p" $BUILDHOME/logs/$p \	# 尝试在包存档目录、$BUILDHOME、临时目录下建立 logs 文件夹
				/usr/tmp /var/tmp /tmp
		do
			test -d "$LOGDIR" || mkdir -p "$LOGDIR" 2>/dev/null		# 目录不存在则建立目录
			test -d "$LOGDIR" -a -w "$LOGDIR" && break 			# 目录存在 & 有写入权限则返回
		done
	fi

	# 进度通知
	msg="Check build logs for $p in `hostname`: $LOGDIR"
	echo "$msg"
	echo "$msg" | $MAIL -s "$msg" $USER 2>/dev/null

	for u in $userhosts
	do
		build_one $u
	done
done

test $EXITCODE -gt 125 && EXITCODE=125
exit $EXITCODE
