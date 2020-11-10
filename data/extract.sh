#!/bin/sh

cat total-pop.txt |
	tr -d ' ' |
	sed 's/Bothsexescombined;//' |
	awk -F ';' '{$1=$3="";print}' |
	awk '{print "pop" $1 " : D.Dict Int Int"} {print "pop" $1 " = \n    D.fromList"} {printf "        ["; for(i=2;i<=22;i++)printf ", (%s, %s) ",i+1998,$i*1000;printf "]\n"}' |
	sed 's/\[,/[/g' >> ../app/src/Gen/Population.elm
