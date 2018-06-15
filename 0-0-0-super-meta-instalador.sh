#!/bin/bash -e

#Full automation.
#This script is only to face a complete updating of the system, from zero.
#For example, when a new version of gcc, glibc or even the kernel. 


#Abrir consola GUI y ser root
#Open Gui console and be root.

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

echo "======================================================="
echo "Did you exec env -i HOME=\$HOME TERM=\$TERM /bin/bash ?"
echo "If you did, type SI to continue"
echo "If not, press any key to exit"
echo "======================================================="
read CS
if [ "$CS" != "SI" ]
	then
		echo "exit"
		exit
fi

#====== STAGE 1 ========================================================
. 0-var-general-rc
. $dirversiones/versiones.sh


# Cross-Compiled Linux From Scratch
# Version 3.0.0-SYSVINIT-x86_64-Multilib
# III. Make the Cross-Compile Tools
# 5. Constructing Cross-Compile Tools
cd $srcinst1
./1-1-meta-inst-cross-tools-multilib.sh


# IV. Building the Basic Tools
# 6. Constructing a Temporary System
. $srcdir/0-var-inst-tmp-sys-multilib-rc 
./1-2-meta-inst-tmp-sys-multilib.sh


cd $srcinst2
./2-1-creacion-file-system.sh
./2-2-empiece-mount-filesys.sh

#Ahora hay que llevarse cosas al chroot.
#Some stuff (files of variables and instalators mainly) has to be copied
#within the chroot environment.

mkdir -v $croothome
chmod -v 777 $croothome

mkdir -v $chrootqipkgs
chmod -v 777 $chrootqipkgs

cp -v $srcdir/0-var-chroot-rc $croothome
cp -v $srcinst2/2-4-creacion-directorios.sh $croothome
cp -v $srcinst2/2-5-creacion-config-files.sh $croothome
cp -v $srcinst3/* $croothome
cp -v $dirversiones/versiones.sh $croothome

touch $croothome/reg_instal.log
touch $croothome/test.log

#====== STAGE 2 ========================================================
./2-3-1-empiece-chroot.sh


#Este tendrá que cargar un meta instaldor a la vez que el chroot
#Carga /home/0-super-meta-instalador-clfs-system.sh

#/home*/0-super-meta-instalador-clfs-system.sh is a very important script.
#See /home**/clfs/cross-compilador/2-inst-clfs-system

#* Home of the chroot envirnment
#** Home of the building system. 
