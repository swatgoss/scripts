(for NUM in `seq 2 "$(awk 'NR == 2{print NF}' /proc/net/netstat)"`; do awk -vNUM=$NUM 'NR <= 2{print $1 "\t" $NUM}' /proc/net/netstat; done) | grep -P -B1 '(TcpExt:.[1-9]+)(?!.*:.0*)'
