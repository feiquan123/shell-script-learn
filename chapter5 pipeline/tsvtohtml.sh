#!/bin/bash
# 将 tsv 文件转化为 html
#
# 用法：
#	./tsvtohtml.sh <passwd-to-directory.out >passwd-to-directory.html 

cat <<EOF
<!DOCTYPE HTML PUBLIC "-/ /IETF/ /DTD HTML/ /EN//3.0">
<html>
	<head>
		<title>Office directory</title>
	</head>
	<body>
		<table>
EOF

sed -e 's=&=\&amp;=g' \
    -e 's=<=\&lt;=g' \
    -e 's=>=\&lgt;=g' \
    -e 's=\t=</td><td>=g' \
    -e 's=^.*$=			<tr><td>&</td></tr>='

cat <<EOF
		</table>
	</body>
</html>
EOF