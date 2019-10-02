#requires parallel, cvt, gtf and awk
parallel {1} 1680 1050 {2} \| grep -i modeline \| sed \'s/^\ *Modeline/#xrandr --newmode /\' \| awk -vOUTPUT={3} \' \{print \$0\; print \"#xrandr --addmode \" OUTPUT \" \" \$3 \}\' ::: gtf cvt ::: 50 59 60 ::: VGA-1
