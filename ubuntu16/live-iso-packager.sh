#!/bin/bash
FILESYSTEM=ubuntu-custom
CUSTOMFS=ubuntu-fs
ORIGINISO=ubuntu-iso

chmod +w ${FILESYSTEM}/casper/filesystem.manifest
sudo chroot ${CUSTOMFS} /bin/bash -x << \EOF | sudo tee ${FILESYSTEM}/casper/filesystem.manifest | wc -l
dpkg-query -W --showformat='${Package} ${Version}\n'
EOF
echo " packages in new manifest"

#ADD DETECTION+VERBIAGE
sudo rm ${FILESYSTEM}/casper/filesystem.squashfs

#ADD PRODUCTION COMPRESSION OR SPEEDY TEST SCRIPT OPTION
#sudo mksquashfs ${CUSTOMFS} ${FILESYSTEM}/casper/filesystem.squashfs -comp lzo -b 65536 -e ${CUSTOMFS}/boot
sudo mksquashfs ${CUSTOMFS} ${FILESYSTEM}/casper/filesystem.squashfs -noI -noD -noF -noX -b 1M

#FILESYSTEM SIZE DETECTION, SIMPLIFY SUDO INVOCATIONS
sudo bash -c "printf $(sudo du -sx --block-size=1 ${CUSTOMFS} | cut -f1) | sudo tee ${FILESYSTEM}/casper/filesystem.size"
echo " blocks detected for filesystem size"

#UPDATE MD5 LIST
#sudo rm ${FILESYSTEM}/md5sum.txt
find ${FILESYSTEM} -type f -print0 | sudo xargs -0 md5sum | grep -v ${FILESYSTEM}/isolinux/boot.cat | sudo tee ${FILESYSTEM}/md5sum.txt

sudo mkisofs -D -r -V ${FILESYSTEM} -cache-inodes -J -l -b ${FILESYSTEM}/isolinux/isolinux.bin -c ${FILESYSTEM}/isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ubuntu-16.04.1-perso.iso ${FILESYSTEM}/
