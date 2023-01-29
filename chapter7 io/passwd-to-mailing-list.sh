#!/bin/bash

# 产生使用特定 Shell 的所有用户邮寄列表
#
# 语法:
# 	passwd-to-mailing-list < /etc/passwd
# 	ypcat passwd | passwd-to-mailing-list
# 	niscat passwd.org_dir | passwd-to-mailing-list

rm -rf /tmp/*.mailing-list

while IFS=: read user passwd uid gid name home Shell; do
	Shell=${Shell:-/bin/sh} # 空的 Shell, 默认为 /bin/sh
	file="/tmp/$(echo $Shell | sed -e 's;^/;;' -e 's;/;-;g').mailing-list"
	echo $user, >> $file
done