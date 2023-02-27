#! /bin/awk 
# 简单的拼写检测程序，搭配用户可定义的异常列表、
# 内置字典是由标准的 UNIX 拼写字典列表构成
# 不过可以在命令行上覆盖改值
#
# 语法：
# 	awk [-v Dictionaries="sysdict1 sysdict2 ..."] -f spell.awk -- \
#		[=suffixfile1 =suffixfile2 ...] [+dict1 +dict2 ...]
#		[-strip] [-verbose] [files(s)]	
# Example:
# 	awk -f spell.awk -- -strip  -verbose \=../data/english.sfx +../data/my.dict ../data/u1.passwd

BEGIN 	{ initialize() }   	# 初始化 
	{ spell_check_line() }	# 处理
END	{ report_exceptions() }	# 报告

function initialize(){
	# 程序初始化工作

	NonWordChars="[^" \
		"'" \
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ" \
		"abcdefghijklmnopqrstuvwxyz" \
		    "\241\242\243\244\245\246\247\250\251\252\253\254\255\256\257" \
		"\260\261\262\263\264\265\266\267\270\271\272\273\274\275\276\277" \
		"\300\301\302\303\304\305\306\307\310\311\312\313\314\315\316\317" \
		"\320\321\322\323\324\325\326\327\330\331\332\333\334\335\336\337" \
		"\340\341\342\343\344\345\346\347\350\351\352\353\354\355\356\357" \
		"\360\361\362\363\364\365\366\367\370\371\372\373\374\375\376\377" \
	"]"

	get_dictionaries()
	scan_options()
	load_dictionaries()
	load_suffixes()
	order_suffixes()	
}

function get_dictionaries(	files,key){
	# 系统默认的字典列表
	
	if ((Dictionaries == "" ) && ("DICTIONARIES" in ENVIRON))
		Dictionaries = ENVIRON["DICTIONARIES"]	
	if (Dictionaries == "") { 
		# 使用默认字典
		DictionaryFiles["/usr/dict/words"]++
		DictionaryFiles["/usr/local/share/dict/words.knuth"]++
		DictionaryFiles["/usr/share/dict/words"]++
		DictionaryFiles["/usr/share/dict/web2a"]++
	}else{
		split(Dictionaries, files)
		for (key in files)
			DictionaryFiles[files[key]]++
	}	
}

function scan_options( 		k){
	# 处理命令行

	for (k =1; k<ARGC; k++){
		if (ARGV[k] == "-strip"){
			ARGV[k] = ""
			Strip=1
		}else if(ARGV[k] == "-verbose"){
			ARGV[k] = ""
			Verbose=1
		}else if(ARGV[k] ~ /^=/){ # 后缀文件
			NSuffixFiles++
			SuffixFiles[substr(ARGV[k],2)]++
			ARGV[k] = ""
		}else if (ARGV[k] ~ /^[+]/) { # 私人字典
			DictionaryFiles[substr(ARGV[k],2)]++
			ARGV[k] = ""
		}
	}

	# 删除结尾的空参数（针对 nawk）
	while((ARGC > 0) && (ARGV[ARGC-1] == ""))
		ARGC--
}

function load_dictionaries(	file, word){
	# 从字典中读取单词列表

	for (file in DictionaryFiles){
		while ((getline word < file) > 0)
			Dictionary[tolower(word)]++
		close(file)
	}
}

function load_suffixes(		file, k, line, n , parts){
	# 加载后缀替换列表

	if (NSuffixFiles > 0) {	# 自文件中载入后缀正则表达式
		for (file in SuffixFiles){
			while ((getline line < file) > 0){
				sub(" *#.*$","",line) # 截去注释
				sub("^[ \t]+$", "", line) # 截去开头空白
				sub("[ \t]+$","", line) # 截去结尾空白
				if (line == "")
					continue
				n = split(line, parts)
				Suffixes[parts[1]]++
				Replacement[parts[1]] = parts[2]
				for (k=3; k<=n; k++)
					Replacement[parts[1]] = Replacement[parts[1]] " " parts[k]
			}
			close(file)
		}
	}else{
		# 载入英文后缀正则表达式的默认表格
		split("'$ 's$ ed$ edly$ es$ ing$ ingly$ ly$ s$", parts)
		for (k in parts){
			Suffixes[parts[k]] = 1
			Replacement[parts[k]] = ""
		}
	}
}

function order_suffixes( 	i, j, key){
	# 以渐减的长度排列后缀

	NOrderedSuffix = 0
	for (key in Suffixes)
		OrderedSuffix[++NOrderedSuffix] = key
	
	for (i = 1; i< NOrderedSuffix;  i++)
		for (j = i+1; j< NOrderedSuffix; j ++)
			if (length(OrderedSuffix[i]) < length(OrderedSuffix[j]))
				swap(OrderedSuffix, i, j)
}

function swap(a, i, j, temp){
	temp = a[i]
	a[i] = a[j]
	a[j] = temp
}

function spell_check_line( 	k, word){
	# 对行进行处理
	gsub(NonWordChars, " ") 	# 移除非单词字符
	for(k =1; k<= NF; k ++){
		word = $k
		sub("^'+", "", word) 	# 移除开头的 '
		sub("'+$", "", word) 	# 移除结尾的 '
		if (word != "")
			spell_check_word(word)
	}
}

function spell_check_word(word, 	key, lc_word, location, w, wordlist){
	# 对单词进行拼写校验
	
	lc_word = tolower(word)
	if (lc_word in Dictionary){	# 拼写正确
		return
	} else {
		if (Strip){
			strip_suffixes(lc_word, wordlist)
			for (w in wordlist)
				if (w in Dictionary)
					return
		}
		location = Verbose ? (FILENAME ":" FNR ":") : ""
		if (lc_word in Exception)
			Exception[lc_word] = Exception[lc_word] "\n" location word
		else
			Exception[lc_word] = location word
	}
}

function strip_suffixes(word, wordlist, 	ending, k, n, regexp){
	# 对单词进行后缀处理
	
	split("",wordlist)
	for (k =1; k<= NOrderedSuffix; k ++){
		regexp = OrderedSuffix[k]
		if (match(word, regexp)){
			word = substr(word, 1, RSTART  -1)
			if (Replacement[regexp] == "")
				wordlist[word] = 1
			else {
				split(Replacement[regexp], ending)
				for (n in ending){
					if (ending[n] == "\"\"")
						ending[n] = ""
					wordlist[word ending[n]] = 1
				}
			}
			break
		}
	}
}


function report_exceptions(	key, sortpipe){
	# 报告异常单词

	sortpipe= Verbose ? "sort -f -t: -u -k1,1 -k2n,2 -k3" : "sort -f -u -k1"
	for (key in Exception)
		print Exception[key] | sortpipe
	close(sortpipe)
}