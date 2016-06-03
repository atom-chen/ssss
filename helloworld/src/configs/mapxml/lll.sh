#!/usr/bin/env bash


files=`ls *.xml`


for file in $files
do

	txt=`cat $file`
	txt=${txt//$'\r'}
	echo "generateing..."
	echo $file
	echo $txt > $file

done
