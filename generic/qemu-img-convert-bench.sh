#bench and log many combination of image files
parallel -j 1 --delay 1 /usr/bin/time -o {3/.}-format={2}-cache={1}.log -a qemu-img convert -t {1} {3} -O {2} {3/.}.{2} \>\> {3/.}-format={2}-cache={1}.log ::: unsafe none writeback writethrough ::: raw vdi vmdk vpc ::: first.qcow second.qcow third.vmdk

#convert to raw multiple disk images, increase -j parameter for increased parallelism but beware of storage saturation from the potentiel huge amount of data written
parallel -j 2 --delay 1 /usr/bin/time -o {3/.}-format={2}-cache={1}.log -a qemu-img convert -t {1} {3} -O {2} {3/.}.{2} \>\> {3/.}-format={2}-cache={1}.log ::: writeback ::: raw ::: first.qcow second.qcow third.vmdk
