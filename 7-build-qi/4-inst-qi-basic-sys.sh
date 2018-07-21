#!/bin/bash

echo -e "
############################################################\n\
#$0\n\
############################################################\n"

proc_root=$(ls -id / | cut -d " " -f1)
[ $proc_root == "2" ] && echo "Debe hacerse en chroot / must be chroot" \
&& exit 1

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

function registro_error () {
#Función para registrar errores y resultados en la bitaćora
if [ $? -ne 0 ]
then
	MOMENTO=$(date)
	echo $MSG_ERR
	echo "$MOMENTO $nombre <$1> -> ERROR" >> $FILE_QILOG
#	exit 1
else
	MOMENTO=$(date)
	echo "$MOMENTO $nombre <$1> -> Conforme" >> $FILE_QILOG
fi
}

FILE_QILOG="/home/qi-build.log"
RECIPEPATH="/usr/src/qi/recipes"

cd /home
. 0-var-chroot-rc
. versiones.sh

pqt=$(ls -l $RECIPEPATH | awk '{print $9}')

for i in $pqt; do
	echo -e "\nqi -b $i" >> $FILE_BITACORA
	qi -b $i
	registro_error $i
done
