#! /bin/sh -
# 单选

echo choice your name:

PS3="name?"  # 设置提示字符串，默认 #?
select name in 张三 李四 王五
do
	if [ -n "$name" ]
	then
		echo your name: $name
		break
	else
		echo 'invalid.'
	fi
done


