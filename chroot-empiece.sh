#!/bin/bash

#Chapter 8. If You Are Going to Chroot 

#Este pequeño script es para recordar y automatizar el arranque del
#chroot. Se supone que ya se ha instalado todo el sw básico y se han
#creado todos los archivos del filesystem y los symlinks necesarios.

#=== This script is useful to enter the chroot for manteinance, ongoing
#developments etc.

#This little script is to remember and automate the start of the
#chroot. It is assumed that all the basic sw has already been installed and
#created all the files in the filesystem and the necessary symlinks


#Abrir consola GUI y ser root
#Open Gui console and be root.

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

. 0-var-general-rc
cd ${srcinst2}
#Aquí es donde están los empieces
#This is the path to the "starting" scripts
echo "Ya estoy en ${srcinst2}"

#Se monta el file system
#Mounting file system
.2-2-empiece-mount-filesys.sh
echo "Montado el file system"

#Se entra en chroot
#Entering chroot
./2-3-2-empiece-chroot.sh
