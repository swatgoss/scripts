# https://github.com/louwrentius/fio-plot testé sur OpenMEdiaVault 7 / Debian 12

apt install zlib1g-dev libjpeg-dev python3-pip python3-venv

python3 -m venv /Data/fio-plot/

pip3 install fio-plot

source /Data/fio-plot/bin/activate

bench-fio --target /Data/SSD/ --type directory --size=1G --iodepth 1 2 4 8 16 32 64 --numjobs 1 2 4 8 16 32 64 --mode read --output /Data/SSD

#fio-plot ...
