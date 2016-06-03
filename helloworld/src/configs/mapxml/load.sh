#!/usr/bin/env bash

file=$1
cdir=`pwd`
dir=${cdir%/*}"/map/"

pattern='require("configs.map.'${file//.xml}'")'

initFile=$dir'init.lua'

loaded=`sed -n '/'$pattern'/p' $initFile`

if [[ ${#loaded} -eq 0 ]]
then
	echo $pattern >> $initFile
	echo "write init.lua done"
fi


