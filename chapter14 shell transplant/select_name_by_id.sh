#! /bin/sh -
# 单选
# 通过 name 选择 id

PS3="name?" 
TMOUT=2 # 超时哈酒为 2s 
select name in 张三 李四 王五
do
	case $REPLY in
	1) id="1001" ;;
	2) id="1002" ;;
	3) id="1003" ;;
	*) echo "invalid." ;;
	esac

	if [ -n "$name" ]
	then
		echo your name: $name
		echo your id: $id
		break
	fi
done

echo done