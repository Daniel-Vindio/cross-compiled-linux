#/bin/bash -e

# Variante asociada a 0-0-meta-empiece-chroot.sh
# Para uso normal. Se utiliza como acceso habitual al chroot,
#Además, este se empleará cuando se hay terminado de contruir el sistema
#básico de sofware, y ya no sea necesario utilizará /tools.
# LFS 6.80. Cleaning Up


#In addition, this will be used when you have finished building the basic 
#software system, and it is no longer necessary to use / tools. 
#LFS 6.80. Cleaning Up

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

#CLFS=/mnt/clfs #You don't need to define it here again
#export CLFS

/usr/sbin/chroot "${CLFS}" /usr/bin/env -i \
HOME=/root \
TERM="${TERM}" \
PS1="\[\e[1;31m\]chr-\u [ \[\e[0m\]\w\[\e[1;31m\] ]# \[\e[0m\]" \
PATH=/bin:/usr/bin:/sbin:/usr/sbin \
/bin/bash --login
