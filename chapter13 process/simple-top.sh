#! /bin/sh -
# 持续执行 ps 命令
# 每次显示之间，只作短时间的暂停
#
# 语法
# 	simple-top

IFS='
 	'

PATH=/usr/ucb:/usr/bin:/bin
export PATH

HEADFLAGS="-n 20"
PSFLAGS=aux
SLEEPFLAGS=5
SORTFLAGS='-k3nr -k1,1 -k2n'

HEADER="`ps $PSFLAGS | head -n 1`"

while true
do
	clear
	uptime
	echo "$HEADER"
	ps $PSFLAGS |
		sed -e 1d |
			sort $SORTFLAGS |
				head $HEADFLAGS
	sleep $SLEEPFLAGS
done