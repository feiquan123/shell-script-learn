#! /bin/sh
grep "$@"
case $(whoami) in
	root)
		echo 危险操作指令
		;;
esac