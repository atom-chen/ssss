#!/usr/bin/env bash


file=$1
cdir=`pwd`
dir=${cdir%/*}"/map/"

if [[ ! -d $dir ]]
then
	mkdir $dir
fi

output=${dir}${file%.xml}"_move.xml"

if [[ -f $output ]]
then
	exit
fi

move=`sed -n 's/<Movable>\(.*\)<\/Movable>/\1/p' $file`

move=${move//|/ }
move=${move//$'\r'}

#echo $move
#IFS="|"
function sortGrid
{
	if [[ $# -le 1 ]]
	then
		echo $1
		return
	fi
	
	first=$1
	first=${first#* }
	first=${first% *}
	fx=${first%%,*}
	fy=${first##*,}	
	local low=
	local high=
	for grid in $@
	do
		grid=${grid#* }
		grid=${grid% *}
		x=${grid%%,*}
		y=${grid##*,}
		if [[ $x -lt $fx || ($x -eq $fx && $y -lt $fy) ]]
		then
			low=${low}" "${grid}
		fi
		if [[ $x -gt $fx || ($x -eq $fx && $y -gt $fy) ]]
		then 
			high=${high}" "${grid}
		fi
	done
#	echo $low
#	echo $high
	low=`sortGrid $low`
	high=`sortGrid $high`

	echo ${low}" "${first}" "${high}

}


result=`sortGrid $move`

list=()

function merge1
{
	for grid in $result
	do
		y=${grid##*,}
		x=${grid%%,*}
		len=${#list[@]}
		
		if [[ $len -eq 0 ]]
		then
			list+=($x","$y","$y)
			continue
		fi
		
		idx=$((len-1))
		p=${list[$idx]}	
		px=${p%%,*}
		tmp=${p#*,}
		py1=${tmp%,*}
		py2=${tmp#*,}
		if [[ $px -eq $x ]]
		then
			if [[ $((py2+1)) -eq $y ]]
			then
				list[$idx]=$x","$py1","$y
			else
				list+=($x","$y","$y)
			fi

		else
			list+=($x","$y","$y)
		fi

	done
}

merge1

map=`sed -n 's/<Map \(.*\)>/\1/p' $file`

map=${map//$'\r'}

mapWidth=2048
mapHeight=1536
gridWidth=${map#*gridWidth=}
gridWidth=${gridWidth%% *}
gridWidth=${gridWidth//'"'}

gridHeight=${map#*gridHeight=}
gridHeight=${gridHeight%% *}
gridHeight=${gridHeight//'"'}

width=${map#*width=}
width=${width%% *}
width=${width//'"'}

height=${map#*height=}
height=${height%% *}
height=${height//'"'}

xOffset=${map#*xOffset=}
xOffset=${xOffset%% *}
xOffset=${xOffset//'"'}

yOffset=${map#*yOffset=}
yOffset=${yOffset%% *}
yOffset=${yOffset//'"'}

ident=${map#*ident=}
ident=${ident%% *}
ident=${ident//'"'}

total=$width
if [[ $width -lt $height ]]
then
	total=$height
fi

totalW=$((gridWidth * total))
totalH=$((gridHeight * total))
startX=$xOffset
halfH=$((totalH / 2))
startY=$((mapHeight - yOffset - halfH))

halfGridW=$((gridWidth / 2))
halfGridH=$((gridHeight / 2))


function exportMoveGrid
{
	local txt='<?xml version="1.0" encoding="utf-8"?>'
	txt=$txt"\n"
	txt=$txt'<Movable>'	
	for grid in ${list[@]}
	do
		x=${grid%%,*}
		tmp=${grid#*,}
		y1=${tmp%%,*}
		y2=${tmp##*,}
		
		ox=$((x * halfGridW))
		ox1=$((y1 * halfGridW))
		ox2=$((y2 * halfGridW))	
	
		oy1=$((y1 * halfGridH))
		oy=$((x * halfGridH))
		oy2=$((y2 * halfGridH))
		
		px1=$((startX+ox1+ox))
		py1=$((startY+oy-oy1))
		
		px2=$((px1 + halfGridW))
		py2=$((py1 + halfGridH))

		px3=$((px2 + ox2 - ox1))
		py3=$((py2 - oy2 + oy1))

		px4=$((px3 - halfGridW))
		py4=$((py3 - halfGridH))
		
		txt=$txt$px1","$py1"|"$px2","$py2"|"$px3","$py3"|"$px4","$py4";"

	done
	txt=$txt'</Movable>'

	echo $txt > $output
}

exportMoveGrid

builds=`sed -n 's/<Gate \(.*\)>\(.*\)<\/Gate>/\1 |\2;/p' $file`
builds=${builds//$'\r'}

generals=`sed -n 's/<Robber \(.*\)>\(.*\)<\/Robber>/\1 |\2;/p' $file`
generals=${generals//$'\r'}

function getValue
{
	v=${1#*$2"="}
	v=${v%% *}
	v=${v//'"'}
	echo $v
}

function exportLuaMap
{
	oldIFS=$IFS
	IFS=';'
	
	local txt="cc.exports.mapConfig"$ident" = {"
	mapPic=${map#*background=}
	mapPic=${mapPic%% *}
	mapPic=${mapPic#*/}
	mapPic=${mapPic%.png*}
	txt=$txt"id="$ident",mapPic=\""$mapPic"\",buildings={"
	for build in $builds
	do
		id=`getValue $build 'id'`
		buildId=`getValue $build 'buildID'`
		level=`getValue $build 'level'`
		num=`getValue $build 'Num'`
		ox=`getValue $build 'ox'`
		oy=`getValue $build 'oy'`
		
		owner=`getValue $build 'type'`
		grid=${build#*|}
		x=${grid%%,*}
		y=${grid##*,}
		px=$((startX + x * halfGridW + halfGridW + y * halfGridW))
		py=$((startY + x * halfGridH - y * halfGridH))
		px=`echo "$px + $ox" | bc`
		py=`echo "$py - $oy" | bc`
		txt=$txt"{id="$id",buildId="$buildId",pos={x="$px",y="$py"},owner="$owner",oriNum="$num",level="$level"},"
		
	done

	txt=$txt"},"

	txt=$txt"generals={"
	
	for general in $generals
	do
		generalId=`getValue $general 'generalID'`
		id=`getValue $general 'ident'`
		level=`getValue $general 'level'`
		ox=`getValue $general 'ox'`
		oy=`getValue $general 'oy'`
		owner=`getValue $general 'type'`
		grid=${general#*|}
		x=${grid%%,*}
		y=${grid##*,}
		px=$((startX + x * halfGridW + halfGridW + y * halfGridW))
		py=$((startY + x * halfGridH - y * halfGridH))
		txt=$txt"{id="$id",owner="$owner",generalId="$generalId",pos={x="$px",y="$py"},level="$level"},"
	done

	txt=$txt"},"
	
	txt=$txt"}"
	
	echo $txt > $dir${file%.xml}".lua"

	IFS=$oldIFS

}


exportLuaMap

sh load.sh $file



