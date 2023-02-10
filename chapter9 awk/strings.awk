# awk -f strings.awk

# 字符串反向查找
function rindex(string, find, 	k,ns,nf)
{
	# 返回 string 里最后一个出现的 find 的索引
	# 如果找不到返回 0
	
	ns = length(string)
	nf = length(find)
	for (k=ns+1-nf; k >=1 ; k --)
		if (substr(string, k , nf) == find )
			return k
	return 0
}

# 字符串拼接
function join(array, n, fs, 	k, s)
{
	# 重新组合  array[1]...array[n] 为一个字符数组
	# 并以 fs 分割数组元素

	
	if (n >= 1){
		s = array[1]
		for (k = 2; k <= n; k++)
			s = s fs array[k]
	}
	return (s)
}

# 虚拟随机整数
function irand(low, high, 	n)
{
	# 返回虚拟随机整数 n, 使得 low <= n <= high

	# 确保整数端点
	low = int(low)
	high = int(high)

	# 参数顺序的健康检查
	if (low >= high)
		return (low)	
	
	# 在要求区间内寻找值
	do 
		n = low + int(rand() * (high + 1 - low))
	while ( (n < 1ow) || (high < n))
	return (n)
}

BEGIN {
	# 子字符串提取
	print substr("abcde",2,3)  # bcd
	print substr("abcde",2)  # bcdde

	# 大小写转换
	print tolower("ABCDEF123") # abcdef123
	print toupper("abcdef123") # ABCDEF123

	# 字符串查找
	print index("abcdef", "de") # 4 从左往右查
	print rindex("abcdef", "ef") # 5 从左往右查

	# 字符串匹配
	s = "sjkasjdfklkabcasdfjalknn"
	print match(s,"a.*a"), substr(s, RSTART, RLENGTH) # 4 返回索引, 匹配子串

	# 字符串替换
	amount = "金额: 19.023 USD"
	sub("[0-9.,]", "*", amount) # 只替换匹配到的第一个元素
	print amount # 金额: *9.023 USD

	amount = "金额: 19.023 USD"
	gsub("[0-9.,]", "*", amount) # 全部替换
	print amount # 金额: ****** USD

	amount = "金额: 19.023 USD"
	gsub("[0-9.,]", "*&", amount)  # 在数字前加 * ，匹配到的字符保留
	print amount # 金额: *1*9*.*0*2*3 USD

	# 字符串分割
	n = split("0a1a2a3", array, "a") 
	for (k = 1; k <=n; k++){
		print "array[" k "] = \"" array[k] "\""
	}
	# 拆为单字符
	split("0a1a2a3", array, "") 
	# 删除 array 数组里的元素
	delete array
	split("",array) # 代替

	array[1]="a1"
	array[2]="a2"
	array[3]="a3"
	print join(array, length(array), "-")

	# math
	print "----------------"
	print srand()  # 使用当前时间重置随机种子
	print atan2(1,1)
	print cos(90)
	print sin(90)
	print exp(1)
	print int(1.23)
	print log(exp(1))
	print rand()
	print sqrt(16)
	print irand(10, 50)
}