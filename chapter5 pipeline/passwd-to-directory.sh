#!/bin/bash
# 过滤 /etc/passwd 生成办公室名录
# 
# 语法：
#	passwd-to-directory.sh < ./data/passwd-to-directory.pwd > passwd-to-directory.out

# 限制临时文件访问权限
umask 077

# 临时文件
PERSON=/tmp/pd.key.person.$$
OFFICE=/tmp/pd.key.office.$$
TELEPHONE=/tmp/pd.key.telephone.$$
USER=/tmp/pd.key.user.$$
MERGE_1=/tmp/pd.key.merge_1.$$

# 信号捕获
trap "exit 1"  HUP INT PIPE QUIT TERM
trap "rm -f $PERSON $OFFICE $TELEPHONE $USER $MERGE_1" EXIT

# 用户信息
awk -F: '{print $1 ":" $5}' > $USER

# 获取用户名 key:username
sed -e 's=/.*==' \
    -e 's=\([^:]*\):\(.*\) \([^ ]*\)=\1:\3, \2=' <$USER | sort >$PERSON

# 获取办公室信息 key:office
sed -e 's=\([^:]*\):[^/]*/\([^/]*\)/.*$=\1:\2=' <$USER | sort >$OFFICE

# 获取手机号 key:telephone
sed -e 's=\([^:]*\):[^/]*/[^/]*/\([^/]*\)=\1:\2=' <$USER | sort >$TELEPHONE

# 合并 & 排序
join -t: $PERSON $OFFICE > $MERGE_1
join -t: $MERGE_1 $TELEPHONE |
	cut -d: -f 2- |
		sort -t: -k1,1 -k2,2 -k3,3 |
			awk -F: '{ printf("%-39s\t%s\t%s\n", $1, $2, $3) }'