# wc ../data/passwd-to-directory.pwd
awk '{ C+=length($0) + 1; W +=NF} END {print NR, W, C}' ../data/passwd-to-directory.pwd

# cat ../data/passwd-to-directory.pwd
awk 1 ../data/passwd-to-directory.pwd

# num, log(num)
seq 1 10 | awk '{print $1, log($1)}' 

# 打印 50% 行左右的随机样本
awk 'rand()<0.5' ../data/passwd-to-directory.pwd

# 统计某列的和、平均值
seq 1 10 | awk -v COLUMN=1 '{ sum+=$COLUMN } END {print sum, sum/NR}'

# 描述，..., 金额
seq 1 10 | awk '{print NR, rand()}' | \
awk  '{sum += $NF; print $0, sum}'

# 查找文件内文本方式
egrep 'jones|toto' ../data/passwd-to-directory.pwd
awk '/jones|toto/' ../data/passwd-to-directory.pwd
awk '/jones|toto/ {print FILENAME ":" FNR ":\t" $0}'  ../data/passwd-to-directory.pwd

# 多文件查找指定行 2~5 行
sed -s -n -e '2,5p' -s ../data/passwd-to-directory.pwd ../data/score.tsv | egrep 'jones|toto'
awk '(2<=FNR)&& (FNR<=5) && /jones|toto/ {print FILENAME ":" FNR ":\t" $0}' ../data/passwd-to-directory.pwd ../data/score.tsv

# tsv to csv
sed 's/\t/,/g' ../data/score.tsv
awk 'BEGIN { FS="\t"; OFS=","} { $1=$1; print}' ../data/score.tsv

# 移除重复行
sort ../data/score.tsv | uniq
awk 'LAST!=$0 {print $0} {LAST=$0}' ../data/score.tsv 

# 移除 \r\n 中的 \r
sed -e 's/\r$//' ../data/score.tsv 
awk 'BEGIN {RS="\r\n"} {print}' ../data/score.tsv 

# \n 替换为 \n\n
sed -e 's/$/\n/' ../data/score.tsv
awk 'BEGIN {ORS="\n\n"} {print}' ../data/score.tsv
awk 'BEGIN {ORS="\n\n"} 1' ../data/score.tsv
awk '{print $0 "\n"}' ../data/score.tsv
awk '{print; print ""}' ../data/score.tsv

# \n\n 替换为 \n
sed -e 's/$/\n/' ../data/score.tsv | awk 'BEGIN {RS="\n*\n"} {print}' 

# 寻找超过 20 字符的行
egrep -n '^.{73,}' ../data/passwd-to-directory.pwd
awk 'length($0) > 72 {print FILENAME ":" NR ":\t" $0}' ../data/passwd-to-directory.pwd