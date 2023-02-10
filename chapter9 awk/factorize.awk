# 计算整数的因式分解，一行列出一个
# 语法：
# 	awk -f factorize.awk
# 	seq 2 100 | awk -f factorize.awk
{
	n = int($1)
	m = n = (n >= 2) ? n : 2
	factors=""
	for (k =2; (m > 1) && (k^2 <= n); )
	{
		if (int(m % k) != 0)
		{
			k ++
			continue
		}
		m /= k
		factors = (factors == "") ? ("" k) : (factors  " * " k)
	}
	if ((1 < m ) && (m < n))
		factors = factors " * " m
	print n, (factors == "") ? "is prime" : ("= " factors)
}