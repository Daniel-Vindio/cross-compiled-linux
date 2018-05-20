#!/bin/bash -e

echo -e "
############################################################\n\
#$?\n\
############################################################\n"

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

if [ ! -d "${CLFS}/dev" ]; then
	echo "Revise el sistema !!!!"
	echo "${CLFS}/dev proc, sys y run deberían existir "
	echo "Check the system !!!!"
	echo "${CLFS}/dev proc, sys and run should alreay exist "
fi

#8.2. Mounting Virtual Kernel File Systems 
#Solo montaje, la creación está en el archivo 2_1
#Only mounting, cration of the file systmen is in file 2_1
mount -v -o bind /dev ${CLFS}/dev

mount -vt devpts -o gid=5,mode=620 devpts ${CLFS}/dev/pts
mount -vt proc proc ${CLFS}/proc
mount -vt tmpfs tmpfs ${CLFS}/run
mount -vt sysfs sysfs ${CLFS}/sys

if [ -h ${CLFS}/dev/shm ]; then
  mkdir -pv ${CLFS}/$(readlink ${CLFS}/dev/shm)
fi

