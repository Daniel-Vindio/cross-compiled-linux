#/bin/bash -e

#8.3. Entering the Chroot Environment
echo -e "
############################################################\n\
#$0\n\
############################################################\n"

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

/usr/sbin/chroot "${CLFS}" /tools/bin/env -i \
HOME=/root \
TERM="${TERM}" \
PS1="\[\e[1;31m\]chr-\u [ \[\e[0m\]\w\[\e[1;31m\] ]# \[\e[0m\]" \
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
/tools/bin/bash -c /home/3-meta-inst-basic-system.sh

#En la versión original de ./2- (ahora ./2-0-) el empiece te lleva
#a una terminal de chroot. Pero la versión ./2-1- es para automatizar
#el porceso y ejecutar un empiece especial, que carga el programa de
#instalación /home/0-super-meta-instalador-clfs-system.sh
#/tools/bin/bash --login +h
