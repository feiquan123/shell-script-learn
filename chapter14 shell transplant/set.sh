{
	set +o  		# 选项设置
	(shopt -p) 2>/dev/null 	#特定的选项， subShell 会使用 ksh 默认
	set			# 变量于值
	export -p     		#  被导出的变量
	readonly -p  		# 只读变量
	trap 			# 捕捉设置
	
	typeset -f 		# 函数定义（非 POSIX）		
} > /tmp/Shell.state