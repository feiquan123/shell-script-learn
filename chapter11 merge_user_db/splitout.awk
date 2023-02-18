#! /bin/awk -f
# $1      $2   $3  $4  $5        $6      $7
# user:passwd:uid:gid:long name:homedir:Shell

BEGIN { FS=":" }

# name[]  --- 以 username 为索引
# uid[]   --- 以 uid 为索引

# 如果出现重复，决定其配置
{
	if ($1 in name) {
		if ($3 in uid)
			; # 名称与uid 一致，无需处理任何事
		else{
			# 名称相同，uid 不同
			print name[$1] > "dupusers"
			print $0 > "dupusers"
			delete name[$1]

			# 删除名称相同，uid 不同的已存项目
			remove_uid_by_name($1)
		}
	} else if ($3 in uid){
		# 名称不同，uid 相同
		print uid[$3] > "dupuids"
		print $0 > "dupuids"
		delete uid[$3]

		# 删除 名称不同，uid 相同 的项目
		remove_name_by_uid($3)
	} else{
		# 名称，uid 都不同的项目， 第一次处理
		name[$1] = uid[$3] = $0
	}
}

END {
	for (i in name)
		print name[i] > "unique1"
	
	close("unique1")
	close("dupusers")
	close("dupuids")
}

function remove_uid_by_name(n, 	i,f){
	for (i in uid){
		split(uid[i], f, ":")
		if (f[1] == n){
			delete uid[i]
			break
		}
	}
}

function remove_name_by_uid(id,	i,f){
	for (i in name){
		split(name[i], f, ":")
		if (f[$3] == id){
			delete name[i]
			break
		}
	}
}