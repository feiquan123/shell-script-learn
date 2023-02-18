#! /bin/sh

# 移除临时文件
rm -f merge1 unique[123] dupusers dupuids unique-ids old-new-list

# 合并密码文件
sort ../data/u1.passwd ../data/u2.passwd > merge1

# 将合并文件分割为 ：
#	具有相同 username 和 uid 的用户放进 unique1. 未重复的用户 username 也放入此文件
#	具有相同 username 不同 uid 的文件放入 dupusernames
#	拒用相同 uid 不同 username 的文件放入 dupuids
awk -f splitout.awk merge1

# 建立唯一的 uid 编号
awk -F: '{print $3}' merge1 | sort -n -u > unique-ids

# 用户 - 旧 uid - 新 uid 的建立
rm -f old-new-list
old_ifs=$IFS
IFS=:

# username 相同 uid 不同时，选择后置的记录的作为最终的结果
while read user passwd uid gid fullname homedir Shell
do 
	if read user2 passwd2 uid2 gid2 fullname2 homedir2 Shell2
	then
		if [ $user = $user2 ]
		then
			printf "%s\t%s\t%s\n" $user $uid $uid2 >>old-new-list
			echo "$user:$passwd:$uid2:$gid:$fullname:$homedir:$Shell"
		else
			echo $0: out of sync: $user and $user2 >&2
			exit 1
		fi
	else
		echo $0: no duplicate for $user >&2
		exit 1
	fi
done < dupusers > unique2
IFS=$old_ifs

count=$(wc -l  < dupuids) # 计算重复的 id 数目

# 重置输入参数为新的唯一 uid
set -- $(./newuids.sh -c $count unique-ids | tr '\n' ' ')
IFS=:

# uid 相同 username 不同的记录，重新插入各自唯一的 uid 
while read user passwd uid gid fullname homedir Shell
do
	newuid=$1
	shift

	echo "$user:$passwd:$newuid:$gid:$fullname:$homedir:$Shell"
	printf "%s\t%s\t%s\n" $user $uid $newuid >> old-new-list
done < dupuids > unique3
IFS=$old_ifs

sort -k 3 -t : -n unique[123] > final.passwd

while read user old new
do
	echo "find / -user $user -print0 | xargs -0 chown $new"
done < old-new-list > chown-files

chmod +x chown-files

rm -f merge1 unique[123] dupusers dupuids unique-ids old-new-list