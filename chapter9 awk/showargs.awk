# awk -v One=1 -v Tow=2  -f showargs.awk  Three=3 file1 Four=4 flie2  file3
BEGIN {
	# args
	print "ARGC=",ARGC
	for (k =0; k< ARGC; k++) {
		print "ARGV[" k "] = [" ARGV[k] "]"
	}	

	# env
	print "ENV_HOME=", ENVIRON["HOME"]
	print "ENV_USER=", ENVIRON["USER"]
}