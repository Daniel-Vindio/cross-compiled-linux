#!/bin/bash -e

echo -e "
############################################################\n\
#$0\n\
############################################################\n"

control_flujo () {
	echo "Continue? To exit press N"
	read CS
	if [ "$CS" == "N" ]
		then
			echo "exit"
			exit
	fi
}

if [ $(id -u) -ne 0 ]; then 
	echo -e "Ur not root bro"
	echo -e "Tines que ser root, tío"
	exit 1
fi

#8.2. Preparing Virtual Kernel File Systems
echo "8.2. Preparing Virtual Kernel File Systems"
if [ ! -d "${CLFS}/dev" ]; then
	mkdir -pv ${CLFS}/{dev,proc,sys,run}
fi
#control_flujo

# Creating Initial Device Nodes
if [ ! -c "${CLFS}/dev/console" ]; then
	mknod -m 600 ${CLFS}/dev/console c 5 1
	echo "Creado ${CLFS}/dev/console "
fi

if [ ! -c "${CLFS}/dev/null" ]; then
	mknod -m 666 ${CLFS}/dev/null c 1 3
	echo "Creado ${CLFS}/dev/null"
fi

