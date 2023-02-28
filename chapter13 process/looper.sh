#! /bin/sh -

echo "PID: $$"
trap 'echo Ignoring HUP ...' HUP
trap 'echo Child terminated ... ' CHLD
trap 'echo This is an EXIT trap' EXIT
# trap 'echo This is a DEBUG trap' DEBUG
trap 'echo This is a ERR trap' ERR
trap 'echo Terminating on USR1 ... ; exit 1' USR1

echo Try command substitution: $(ls no-such-file)  # 命令替换失败不捕捉
echo Try a standalone command:
ls no-such-file

while true
do
	sleep 2
	date > /dev/null
done