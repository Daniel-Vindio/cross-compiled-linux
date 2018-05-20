#!/bin/bash

echo -e "
############################################################\n\
#$?\n\
############################################################\n"

#"Desempiece" Para finalizar la sesión y desmontar el systema
#"Unstart" To end the session and umount the file system.

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

. 0-var-general-rc

umount ${CLFS}/dev/pts

if [ -h ${CLFS}/dev/shm ]; then
  link=$(readlink ${CLFS}/dev/shm)
  umount -v ${CLFS}/$link
  unset link
else
  umount -v ${CLFS}/dev/shm
fi

umount ${CLFS}/dev
umount ${CLFS}/proc
umount ${CLFS}/sys
umount ${CLFS}/run
