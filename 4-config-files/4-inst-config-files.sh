#!/bin/bash -e

if [ $(id -u) -ne 0 ]; then 
	echo -e "Ur not root bro"
	echo -e "Tines que ser root, tío"
	exit 1
fi

srcdir=${PWD}
#destndir1="/mnt/clfs/etc/sysconfig"
#destndir2="/mnt/clfs/etc"

if [ ! -d "$destndir1" ]; then
	mkdir -vp $destndir1
fi

configfiles1="clock console createfiles ifconfig.enp1s8 \
ifconfig.wlp0s29f7u6 modules mouse rc.site udev_retry \
wpa_supplicant-wlp0s29f7u6.conf"

for i in ${configfiles1}; do
	install -v -m0644 ${i} -t ${destndir1}
done


configfiles2="hostname resolv.conf inputrc profile shells"

for i in ${configfiles2}; do
	install -v -m0644 ${i} -t ${destndir2}
done

if [ ! -f "/etc/hosts" ]; then
	echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
	echo "created /etc/hosts ..."
fi


install -v -m0644 fstab -t /etc

if [ ! -d "/etc/modprobe.d" ]; then
	mkdir -vp /etc/modprobe.d
fi
install -v -m755 usb.conf -t /etc/modprobe.d

if [ ! -d "/boot/grub" ]; then
	mkdir -vp /boot/grub
fi
install -v -m0644 grub.cfg -t /boot/grub




