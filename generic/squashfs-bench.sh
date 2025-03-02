#creates a sqfs archive for each combination of parameters given and logs compression metadata+time spent
#xz, zstd, gzip compressors are readable by 7-Zip on Windows, especially usefull with raw full disk images since 7-Zip also reads partitions and partition contents

#sudo apt install time squashfs-tools parallel

#for gzip and zstd compression, or benchmark. gzip have 1-9 compression levels, zstd have 1-22 compression levels
parallel -j 1 --delay 2 /usr/bin/time -o {4/.}-{1}-{2}k-Xcomp{3}.log -a mksquashfs {4} {4/.}-{1}-{2}k-Xcomp{3}.sqfs -comp {1} -Xcompression-level {3} -b {2}k -noappend \>\> {4/.}-{1}-{2}k-Xcomp{3}.log ::: gzip zstd ::: 128 512 1024 ::: 1 6 9 ::: first-directory file.img

#for xz compression, strength is controlled by dictionnary size, up to 100% of available memory
parallel -j 1 --delay 2 /usr/bin/time -o {4/.}-{1}-{2}k-Xdict{3}.log -a mksquashfs {4} {4/.}-{1}-{2}k-Xdict{3}.sqfs -comp {1} -Xdict-size {3}% -b {2}k -noappend \>\> {4/.}-{1}-{2}k-Xdict{3}.log ::: xz ::: 64 256 1024 ::: 25 50 75 100 ::: first-directory file.img
