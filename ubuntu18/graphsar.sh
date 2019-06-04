#!/bin/bash
#env_parallel

SCANDIR="$1"
MACHINES=$(find "$SCANDIR" -mindepth 1 -type d)
DONNEES="CPU RAM BLK"

func_splitdata()
{
	if [ -f $1/global-AVG$2.csv ]; then
		{
			echo "$1/global-AVG$2.csv deja extrait"
			exit
		}
	else
	echo -e run "$(printf '%5d' $3 )" : extraction $2 dans $1
	SARFILES=$(find $1 -name "sadf*$2")
	#aggregation des donnees en CSV
	sed -e '2,$s/#.*$//' -e '/^$/d' $SARFILES > $1/global-AVG$2.csv
	fi
}
export -f func_splitdata

func_splitcpu()
{
	if [ -f $1/global-CPU-1.csv ]; then
		{
			echo "$1/global-CPU-1.csv deja extrait"
			exit
		}
	else
	GLOBFILE=$(find $1 -name "global-AVGCPU.csv")
	for CPUN in $(tail -n +2 $GLOBFILE | awk -v FS=";" '{print $4}' | sort -n | uniq )
	do
		head -n1 $GLOBFILE > $1/global-CPU$CPUN.csv
		NCPU="^$CPUN$" awk -F ";" '$4 ~ ENVIRON["NCPU"]' $GLOBFILE | sed 's/,/./g' >> $1/global-CPU$CPUN.csv
	done
	((CPUN++))
	echo "$GLOBFILE extraction de $CPUN CPU"
	fi
}
export -f func_splitcpu

func_splitblk()
{
	if [ -f $1/global-BLKsda.csv -o -f $1global-BLKvda.csv ]; then
		{
			echo "$1/global-BLK?da.csv deja extrait"
			exit
		}
	else
	GLOBFILE=$(find $1 -name "global-AVGBLK.csv")
	for BLKN in $(tail -n +2 $GLOBFILE | awk -v FS=";" '{print $4}' | sort -n | uniq )
	do
		head -n1 $GLOBFILE > $1/global-BLK$BLKN.csv
		NBLK="^$BLKN$" awk -F ";" '$4 ~ ENVIRON["NBLK"]' $GLOBFILE | sed 's/,/./g' >> $1/global-BLK$BLKN.csv
	done
	((CPUN++))
	echo "$GLOBFILE extraction de $BLKN Blockdevice"
	fi
}
export -f func_splitblk

func_splitgeneric()
{
	MESSAGE="extraction des donnees $2 pour $1"
	if [  -f $1/global-$2*.csv ]; then
		{
			echo $MESSAGE "donnees deja extraites, abandon"
			exit
		}
	fi
	echo $MESSAGE
	awk -v FOLDER="$1/" -v TYPE="$2" -F ';' ' NR==1{header=$0; next}; !seen[$1]++ {f=FOLDER"global-"TYPE$4".csv"; print header > f}; {f=FOLDER"global-"TYPE$4".csv"; gsub(/,/, "."); print >> f; close(f)} ' $1/global-AVG$2.csv
		
}
export -f func_splitgeneric

parallel func_splitdata {1} {2} {\#} ::: "${MACHINES[@]}" ::: $DONNEES

#parallel func_splitcpu ::: "${MACHINES[@]}"

#parallel func_splitblk ::: "${MACHINES[@]}"

parallel -j8 func_splitgeneric {1} {2} ::: "${MACHINES[@]}" ::: CPU BLK
