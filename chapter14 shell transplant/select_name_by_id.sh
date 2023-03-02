#! /bin/sh -
# 单选
# 通过 name 选择 id

PS3="name?" 
TMOUT=2 # 超时哈酒为 2s 

ids=(1001 1002 1003)
select name in 张三 李四 王五
do
	if [ -n "$name" ]
	then
		id=${ids[REPLY - 1]}
		echo your name: $name
		echo your id: $id
		break
	else
		echo "invalid."
	fi
done

echo done