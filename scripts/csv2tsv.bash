#!/usr/bin/env bash

while [ $# -ne 0 ] ; do
	echo $1

	awk '
BEGIN { 
	OFS="\t";
#	FPAT = "(\"([^\"]|\"\")*\")|([^,\"]*)" #	legit csv
	FPAT = "(\"([^\"]|\"\")*\")|([^,\"]*)|(\"[^,]*\")" 
#	(\"[^,]*\") is for my malformed csv
#	([^,\"]*) will match Windows ^Ms so matches end of line giving extra field
#			remove them with cat test.csv | tr -d "\r" > test2.csv 
#	I suspect the extra field will break bulk insert
}

#	Some of these data files contain a Byte Order Marker, or BOM,
#	Linux ignores these, but Cygwin on Windows does not.
#	If they are not removed, the first line will have an
#	additional preceding field, which in our case does not
#	really affect anything as told BULK INSERT to ignore row 1.
#	Nevertheless, we need our malformed tsv files to
#	be properly malformed!

( NR==1 ){sub(/^\xef\xbb\xbf/,"")}

{
	gsub("\r","");# remove windows
	for(i=1;i<=NF;i++){
		if( ($i ~ /^"/) && ($i ~ /"$/) ){
			f=substr($i,2,length($i)-2)
		}else{
			f=$i; 
		};
		gsub(/""/,"\"",f);
		printf f;
		if( i != NF) printf OFS;
	}; 
	printf "\n";
}' "$1" > "$1".tsv

	shift
done
