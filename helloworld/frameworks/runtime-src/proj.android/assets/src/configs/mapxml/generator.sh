#!/usr/bin/env bash


work=`pwd`
basePath=${work%/*}
writePath=${basePath}"/map/"

srcPath=${basePath}"/mapxml/"
initFile=$writePath"init.lua"
files=`ls ${srcPath}*.xml`

for file in $files
do
	baseName=${file%.*}
	baseName=${baseName##*/}
	writeFile=${writePath}${baseName}".lua"
	srcFile=${srcPath}${baseName}".xml"
	if [[ -f ${writeFile} ]]
	then
		newer=`find $srcFile -newer $writeFile`
		if [[ $newer == $srcFile ]]
		then
			./out $file $writePath
		fi
	else
		./out $file $writePath
	fi
	
#	pattern='require("configs.map.'${baseName}'")'
#	loaded=`sed -n '/'$pattern'/p' $initFile`
#	if [[ ${#loaded} -eq 0 ]]
#	then
#		echo $pattern >> $initFile
#	fi

done

echo "generate done!"


