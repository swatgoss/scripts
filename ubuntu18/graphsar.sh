#!/bin/bash
#env_parallel

SCANDIR="$1"
MACHINES=$(find "$SCANDIR" -mindepth 1 -type d)
DONNEES="CPU RAM BLK"

#	case $2 in
#		CPU) 
#			head -n1 $TRUC > $TRUC-AVG$OPTION.csv; grep ';-1' $TRUC | sed 's/,/./g' >> $TRUC-AVG$OPTION.csv;;
#		RAM)
#			sed 's/,/./g' ${TRUC%-CPU}-RAM > ${TRUC%-CPU}-AVGRAM.csv;;
#		BLK)
#			;;
#		*)
#			;;
#	esac

func_splitdata()
{
	[ ! -f $1/global-AVG$2.csv ] || echo "$1/global-AVG$2.csv deja extrait" && exit
	echo -e run "$(printf '%5d' $3 )" : extraction $2 dans $1
	SARFILES=$(find $1 -name "sadf*$2")
	#aggregation des donnees en CSV
	sed -e '2,$s/#.*$//' -e '/^$/d' $SARFILES > $1/global-AVG$2.csv

}
export -f func_splitdata

func_splitcpu()
{
	GLOBFILE=$(find $1 -name "global-AVGCPU.csv")
	for CPUN in $(tail -n +2 $GLOBFILE | awk -v FS=";" '{print $4}' | sort -n | uniq | tail -n +2)
	do
		head -n1 $GLOBFILE > $1/global-CPU$CPUN.csv
		NCPU="^$CPUN$" awk -F ";" '$4 ~ ENVIRON["NCPU"]' $GLOBFILE | sed 's/,/./g' >> $1/global-CPU$CPUN.csv
	done
	((CPUN++))
	echo "$GLOBFILE extraction de $CPUN CPU"
}
export -f func_splitcpu

parallel func_splitdata {1} {2} {\#} ::: "${MACHINES[@]}" ::: $DONNEES

parallel func_splitcpu ::: "${MACHINES[@]}"
