#!/usr/bin/env bash

files=`ls *.xml`

for f in $files
do
	echo "generating $f"
	sh make.sh $f
done

echo "done"





