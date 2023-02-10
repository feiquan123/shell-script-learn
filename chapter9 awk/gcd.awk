# echo 25770 30972 | awk -f gcd.awk

function gcd(x,y,	r)
{
	# 返回 x,y 的最大公约数
	x=int(x)
	y=int(y)
	# print x,y
	r=x%y
	return (r == 0)? y : gcd(y,r)
}

{ g=gcd($1,$2); print "gcd(" $1 ", " $2") = ", g}