#! /bin/sh -

trap "echo EXIT" EXIT

# (( 算术运算 ))
while (( x < 42))
do
	((x++))
done
echo $x

echo "-----------------------"
for ((i=0; i< 10; i++))
do
	echo $i
done

echo "-----------------------"
for name in foo stuff -
do
	case $name in 
		( foo | bar )  echo foo: $name ;;
		( stuff | junk ) echo stuff: $name ;;
		( * ) echo invalid: $name ;;
	esac
done

echo "-----------------------"
echo 'A\tB'
echo $'A\tB' # 转义

echo "-----------------------"
read id name path <<< "1001 alice /home/alice"
echo id=$id name=$name path=$path

echo "-----------------------"
x=1
if (( (x < 3) || (x > 10) ))
then
	echo "true"
else 
	echo "false"
fi