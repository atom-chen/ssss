#!/usr/bin/env bash


wd=`pwd`
writePath=${wd%/*}"/xmlToLua/"
files=`ls ${wd}/*.xml`

for file in $files
do
	base=${file##*/}
	base=${base%.*}
	wfile=${writePath}${base}".lua"
	if [[ -f ${wfile} ]]
	then
		newer=`find $file -newer $wfile`
		if [[ $newer == $file ]]
		then
			./out $file $writePath
		fi
	else
		./out $file $writePath
	fi

done

echo "done"
