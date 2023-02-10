# echo 2 2 | awk -f ackermann.awk
# echo 3 3 | awk -f ackermann.awk
# echo 3 4 | awk -f ackermann.awk
# echo 4 4 | awk -f ackermann.awk

function ack(a, b)
{
	N++ 	# 计算递归深度
	if (a == 0)
		return (b + 1)
	else if (b == 0 )
		return (ack(a -1, 1))
	else
		return (ack(a - 1, ack(a, b - 1)))
}

{ N=0; print "ack(" $1 ", " $2 ") = ", ack($1, $2), "[" N " calls]"}