#!/bin/bash -e

# Cabeza borradora = literal translation of eraserhead
# Script to delete all the file system.
# It is needed to help to re-install the whole system, for example,
# when updating the system to the new package versions.

control_flujo () {
	echo "ARE YOU POSITIVE? To exit press N"
	read CS
	if [ "$CS" == "N" ]
		then
			echo "exit"
			exit
	fi
}

control_flujo2 () {
	echo "I don't know what 'positive' means. To exit press N"
	echo "It means you're sure. To exit press N"
	read CS
	if [ "$CS" == "N" ]
		then
			echo "exit"
			exit
	fi
}

control_flujo3 () {
	echo "Yes, I'm sure that's Ellis Brittle. To exit press N"
	echo "Directories will be deleted. To exit press N"
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


. 0-var-general-rc


echo -e "\nBORRADO TOTAL DEL SISTEMA DE ARCHIVOS"
echo -e "ERASING THE FILE SYSTEM COMPLETELY\n"
control_flujo
control_flujo2
control_flujo3

cd ${CLFS}
echo -e "\n---> Borrado de carpetas en ${CLFS}"
ls
control_flujo
rm -rf bin etc lib media opt root sbin srv tmp usr boot dev home lib64 mnt proc run sys var qipkgs



cd ${CLFS}/cross-tools
echo -e "\n---> Borrado de carpetas en $PWD"
ls
control_flujo
rm -rf bin include lib libexec share x86_64-unknown-linux-gnu


cd ${CLFS}/tools
echo -e "\n---> Borrado de carpetas en $PWD"
ls
control_flujo
rm -fr bin include lib64 man share x86_64-unknown-linux-gnu etc lib  libexec sbin var






















