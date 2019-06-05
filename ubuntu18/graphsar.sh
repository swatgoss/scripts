#!/bin/bash
#env_parallel

SCANDIR="$1"
MACHINES=$(find "$SCANDIR" -mindepth 1 -type d)
DONNEES="CPU RAM BLK"

func_splitmois()
{
	echo extraction du mois $2 pour $1
	export MOIS="2019-""$2"'.*'
	echo $MOIS
	awk -v FS=";" 'NR==1; $3 ~ ENVIRON["MOIS"]' $1/global-CPU-1.csv > $1/mois$2-CPU-1.csv
	awk -v FS=";" 'NR==1; $3 ~ ENVIRON["MOIS"]' $1/global-ALLRAM.csv > $1/mois$2-ALLRAM.csv
	awk -v FS=";" 'NR==1; $3 ~ ENVIRON["MOIS"]' $1/global-BLK?da.csv > $1/mois$2-SYSBLK.csv
}
export -f func_splitmois

func_splitdata()
{
	if [ -f $1/global-ALL$2.csv ]; then
		{
			echo "$1/global-ALL$2.csv deja extrait"
			exit
		}
	else
	#echo -e run "$(printf '%5d' $3 )" : extraction $2 dans $1
	SARFILES=$(find $1 -name "sadf*$2")
	#aggregation des donnees en CSV
	sed -e '2,$s/#.*$//' -e '/^$/d' $SARFILES > $1/global-ALL$2.csv
	fi
}
export -f func_splitdata

func_splitcpu()
{
	if [ -f $1/global-CPU-1.csv ]; then
		{
			echo "$1/global-CPU-1.csv deja extrait"
			return
		}
	else
		{
		GLOBFILE=$(find $1 -name "global-ALLCPU.csv")
		for CPUN in $(tail -n +2 $GLOBFILE | awk -v FS=";" '{print $4}' | sort -n | uniq )
		do
			HEADER="$(head -n1 $GLOBFILE)"
			NCPU="^$CPUN$" awk -F ";" '$4 ~ ENVIRON["NCPU"]' $GLOBFILE | sed 's/,/./g' > $1/global-CPU$CPUN.csv
			sort -t';' -k3 -o $1/global-CPU$CPUN.csv $1/global-CPU$CPUN.csv
			#echo "adding CPU header " $HEADER
			sed -i "1i $HEADER" $1/global-CPU$CPUN.csv
		done
		((CPUN++))
		echo "$GLOBFILE extraction de $CPUN CPU"
		}
	fi
}
export -f func_splitcpu

func_splitblk()
{
	echo "starting BLK extraction of $1"
	if [ -f $1/global-BLKsda.csv -o -f $1global-BLKvda.csv ]; then
		{
			echo "$1/global-BLK?da.csv deja extrait"
			return
		}
	else
	{
		GLOBFILE=$(find $1 -name "global-ALLBLK.csv")
		for BLKN in $(tail -n +2 $GLOBFILE | awk -v FS=";" '{print $4}' | sort -n | uniq )
		do
			HEADER="$(head -n1 $GLOBFILE)"
			NBLK="^$BLKN$" awk -F ";" '$4 ~ ENVIRON["NBLK"]' $GLOBFILE | sed 's/,/./g' > $1/global-BLK$BLKN.csv
			sort -t';' -k3 -o $1/global-BLK$BLKN.csv $1/global-BLK$BLKN.csv
			#echo $1 $NBLK " adding BLK header " $HEADER
			sed -i "1i $HEADER" $1/global-BLK$BLKN.csv
		done
		#echo "$GLOBFILE extraction de $BLKN Blockdevice"
	}
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

func_metasplitter()
{
echo -e run "$(printf '%5d' $3 )" : extraction $2 dans $1
func_splitdata "$1" "$2" "$3"
echo "extraction CPU de $1"
func_splitcpu "$1"
echo "extraction BLK de $1"
func_splitblk "$1" 
}
export -f func_metasplitter

func_genveusz()
{
INPUT="$1""/mois""$2"
OUTPUT=${INPUT%.csv}.pdf

veusz --listen <<EOF > $INPUT.log
AddImportPath(u'C:\\Users\\Swatgoss\\Documents\\sars_dpar_vb1')
ImportFileCSV(u'$INPUT-CPU-1.csv', dateformat=u'YYYY-MM-DD hh:mm:ss UTC', delimiter=u';', linked=True, dsprefix=u'CPU')
ImportFileCSV(u'$INPUT-ALLRAM.csv', dateformat=u'YYYY-MM-DD hh:mm:ss UTC', delimiter=u';', linked=True, dsprefix=u'RAM')
DatasetPlugin(u'MovingAverage', {u'ds_in': u'CPU%user', u'ds_out': u'CPUmoyenne%user', u'weighterrors': True, u'width': 120})
DatasetPlugin(u'Add Datasets', {u'ds_in': ('RAMkbmemfree', 'RAMkbmemused'), u'ds_out': u'RAMkbTOTAL'})
DatasetPlugin(u'Add Datasets', {u'ds_in': ('RAMkbcached', 'RAMkbbuffers'), u'ds_out': u'RAMkblibres'})
DatasetPlugin(u'Multiply', {u'ds_in': u'RAMkbTOTAL', u'ds_out': u'RAMkbplafond', u'factor': 0.895})
DatasetPlugin(u'Subtract Datasets', {u'ds_in1': u'RAMkbmemused', u'ds_in2': u'RAMkblibres', u'ds_out': u'RAMkbreels'})
DatasetPlugin(u'Subtract Datasets', {u'ds_in1': u'RAMkbmemfree', u'ds_in2': u'RAMkblibres', u'ds_out': u'RAMkbrestants'})
DatasetPlugin(u'Subtract Datasets', {u'ds_in1': u'RAMkbplafond', u'ds_in2': u'RAMkbreels', u'ds_out': u'RAMkbresteutile'})
DatasetPlugin(u'Subtract Datasets', {u'ds_in1': u'RAMkbmemused', u'ds_in2': u'RAMkbbuffers', u'ds_out': u'RAMkbused-buffer'})
DatasetPlugin(u'Subtract Datasets', {u'ds_in1': u'RAMkbplafond', u'ds_in2': u'RAMkbreels', u'ds_out': u'RAMresteutile'})
Set('colorTheme', u'default-latest')
Set('StyleSheet/axis-function/autoRange', u'next-tick')
Add('page', name=u'page1', autoadd=False)
To(u'page1')
Set('width', u'60cm')
Set('height', u'21cm')
Add('graph', name=u'graph1', autoadd=False)
To(u'graph1')
Set('rightMargin', u'30.2cm')
Set('topMargin', u'1.2cm')
Add('axis', name=u'x', autoadd=False)
To(u'x')
Set('autoRange', u'+1%')
Set('mode', u'datetime')
Set('direction', u'horizontal')
Set('otherPosition', 0.0)
Set('Label/rotate', u'0')
Set('TickLabels/size', u'8pt')
Set('TickLabels/rotate', u'45')
Set('MajorTicks/hide', False)
Set('MajorTicks/length', u'5pt')
Set('MajorTicks/number', 24)
Set('GridLines/hide', False)
To('..')
Add('axis', name=u'y', autoadd=False)
To(u'y')
Set('min', 0.0)
Set('max', 109.0)
Set('log', False)
Set('direction', u'vertical')
Set('TickLabels/format', u'%VE%')
Set('MajorTicks/style', u'solid')
Set('MajorTicks/number', 9)
Set('MinorTicks/width', u'0.5pt')
Set('MinorTicks/number', 10)
Set('GridLines/width', u'0pt')
Set('GridLines/hide', False)
Set('MinorGridLines/width', u'0pt')
Set('MinorGridLines/hide', False)
To('..')
Add('xy', name=u'xy1', autoadd=False)
To(u'xy1')
Set('marker', u'circle')
Set('markerSize', u'1pt')
Set('color', u'darkblue')
Set('thinfactor', 40)
Set('xData', u'CPUtimestamp')
Set('yData', u'CPUmoyenne%user')
Set('hide', True)
To('..')
Add('bar', name=u'bar1', autoadd=False)
To(u'bar1')
Set('lengths', ('CPU%user', 'CPU%system', 'CPU%nice', 'CPU%steal', 'CPU%iowait', 'CPU%idle'))
Set('posn', u'CPUtimestamp')
Set('mode', u'stacked-area')
Set('keys', ('%user', '%system', '%nice', '%steal', '%iowait', '%idle'))
Set('BarFill/fills', [('solid', '#0044fe', False), ('solid', '#ff0000', False), ('solid', '#fff900d2', False), ('solid', '#ff00e0', False), ('solid', '#686868b9', False), ('backward 4', '#00f100b2', False)])
Set('BarLine/lines', [('solid', '0.05pt', 'black', True)])
To('..')
Add('key', name=u'key1', autoadd=False)
To(u'key1')
Set('horzPosn', u'centre')
Set('vertPosn', u'top')
Set('keyLength', u'1cm')
Set('marginSize', 0.2)
Set('columns', 6)
Set('symbolswap', False)
To('..')
To('..')
Add('label', name=u'machine1', autoadd=False)
To(u'machine1')
Set('label', u'CPU DATA :')
Set('hide', False)
Set('xPos', [0.4])
Set('yPos', [0.95])
To('..')
Add('label', name=u'hostnameCPU', autoadd=False)
To(u'hostnameCPU')
Set('label', u'CPU# hostname')
Set('xPos', [0.45])
Set('yPos', [0.95])
To('..')
Add('label', name=u'machine2', autoadd=False)
To(u'machine2')
Set('label', u'RAM DATA :')
Set('hide', False)
Set('xPos', [0.55])
Set('yPos', [0.95])
To('..')
Add('label', name=u'hostnameRAM', autoadd=False)
To(u'hostnameRAM')
Set('label', u'RAM# hostname')
Set('xPos', [0.6])
Set('yPos', [0.95])
To('..')
Add('label', name=u'enregistrement1', autoadd=False)
To(u'enregistrement1')
Set('label', u'Premier enregistrement de la periode representee :')
Set('xPos', [0.028])
Set('yPos', [0.95])
To('..')
Add('label', name=u'timestamp', autoadd=False)
To(u'timestamp')
Set('label', u'CPUtimestamp')
Set('xPos', [0.2])
Set('yPos', [0.95])
To('..')
Add('graph', name=u'graph2', autoadd=False)
To(u'graph2')
Set('leftMargin', u'31.7cm')
Set('topMargin', u'1.2cm')
Add('axis', name=u'x', autoadd=False)
To(u'x')
Set('autoRange', u'+1%')
Set('mode', u'datetime')
Set('direction', u'horizontal')
Set('otherPosition', 0.001)
Set('Label/rotate', u'0')
Set('TickLabels/size', u'8pt')
Set('TickLabels/rotate', u'45')
Set('MajorTicks/hide', False)
Set('MajorTicks/length', u'5pt')
Set('MajorTicks/number', 24)
Set('GridLines/hide', False)
To('..')
Add('axis', name=u'y', autoadd=False)
To(u'y')
Set('min', 0.0)
Set('max', u'Auto')
Set('autoRange', u'+12%')
Set('reflect', False)
Set('outerticks', True)
Set('datascale', 1000.0)
Set('direction', u'vertical')
Set('Line/width', u'1pt')
Set('TickLabels/format', u'%VE')
Set('MajorTicks/number', 17)
Set('MinorTicks/width', u'1pt')
Set('MinorTicks/length', u'3pt')
Set('MinorTicks/number', 4)
Set('GridLines/hide', False)
Set('MinorGridLines/hide', True)
To('..')
Add('xy', name=u'commit', autoadd=False)
To(u'commit')
Set('marker', u'none')
Set('xData', u'RAMtimestamp')
Set('yData', u'RAMkbcommit')
Set('hide', True)
Set('key', u'kbcommit')
Set('PlotLine/color', u'blue')
Set('PlotLine/width', u'0pt')
To('..')
Add('xy', name=u'RAMutile', autoadd=False)
To(u'RAMutile')
Set('marker', u'none')
Set('color', u'darkmagenta')
Set('xData', u'RAMtimestamp')
Set('yData', u'RAMresteutile')
Set('key', u'reste RAM utile')
Set('PlotLine/color', u'magenta')
Set('PlotLine/width', u'0pt')
To('..')
Add('xy', name=u'plafond', autoadd=False)
To(u'plafond')
Set('marker', u'none')
Set('xData', u'RAMtimestamp')
Set('yData', u'RAMkbplafond')
Set('key', u'plafond 90% RAM')
Set('PlotLine/color', u'red')
Set('PlotLine/width', u'2pt')
Set('PlotLine/style', u'dotted')
To('..')
Add('bar', name=u'bar1', autoadd=False)
To(u'bar1')
Set('lengths', ('RAMkbreels', 'RAMkbcached', 'RAMkbbuffers', 'RAMkbmemfree'))
Set('posn', u'RAMtimestamp')
Set('mode', u'stacked-area')
Set('keys', ('Mémoire USER', 'RAM cache', 'RAM buffer', 'RAM inutilisée'))
Set('hide', False)
Set('BarFill/fills', [('solid', '#2a80d5', False), ('backward 4', '#56b235', False, 0, '0.5pt', 'solid', '5pt', '#56b235', 70, False), ('backward 4', '#f2510d', False, 0, '0.5pt', 'solid', '5pt', '#f2510d', 80, False), ('backward 4', '#fefe00', False, 0, '0.5pt', 'solid', '5pt', '#fefe00', 90, False)])
Set('BarLine/lines', [('solid', '0.1pt', '#0000007f', True)])
To('..')
Add('axis', name=u'pourcentage', autoadd=False)
To(u'pourcentage')
Set('label', u'')
Set('min', 0.0)
Set('max', 100.0)
Set('direction', u'vertical')
Set('otherPosition', 1.0)
To('..')
Add('key', name=u'key1', autoadd=False)
To(u'key1')
Set('horzPosn', u'centre')
Set('vertPosn', u'top')
Set('keyLength', u'1cm')
Set('marginSize', 0.2)
Set('columns', 3)
Set('symbolswap', False)
To('..')
To('..')
To('..')
Export("$OUTPUT")
Quit()
EOF
}
export -f func_genveusz

parallel func_metasplitter {1} {2} {\#} ::: "${MACHINES[@]}" ::: $DONNEES

#parallel func_splitdata {1} {2} {\#} ::: "${MACHINES[@]}" ::: $DONNEES

#parallel func_splitcpu ::: "${MACHINES[@]}"

#parallel func_splitblk ::: "${MACHINES[@]}"

parallel func_splitmois {1} {2} ::: "${MACHINES[@]}" ::: {04..06}

#parallel -j8 func_splitgeneric {1} {2} ::: "${MACHINES[@]}" ::: CPU BLK
