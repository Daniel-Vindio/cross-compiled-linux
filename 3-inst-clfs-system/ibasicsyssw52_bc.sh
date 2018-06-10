# Instalador de bc
# 64 bit on 64 bit machine, MULTILIB.

nombre=$(echo $0 | cut -d "." -f2 | cut -d "_" -f2)
nombre_comp=$nombre-$1.tar.$2
nombre_dir=$nombre-$1

T_COMIENZO=$(date +"%T")	#para calcular el tiempo de instalación

function registro_error () {
#Función para registrar errores y resultados en la bitaćora
if [ $? -ne 0 ]
then
	MOMENTO=$(date)
	echo $MSG_ERR
	echo "$MOMENTO $nombre <$1> -> ERROR" >> $FILE_BITACORA
	exit 1
else
	MOMENTO=$(date)
	echo "$MOMENTO $nombre <$1> -> Conforme" >> $FILE_BITACORA
fi
}


# $# es el nº de argumentos. Aquí se comprueba la sintaxis de la 
# aplicación
if [ $# != 2 ]
then
	echo "uso ./nombre vesion compresion"
	echo "nombre = nombre del programa"
	echo "version = x.y.z"
	echo "compresión = gz / xz etc"
	exit 1
fi

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

cd $DIR_FUENTES

if [ -e $nombre_comp ]
then
	echo "Comienza la descompresión ..."
else
	echo "no existe el archivo, o no tiene el formato .tar"
	echo "se abandona la instalación"
	exit 1
fi

case $2 in
	gz)
	tar -zxf $nombre_comp || (echo "error descompresión"; exit 1);;

	bz2)
	tar -jxf $nombre_comp || (echo "error descompresión"; exit 1);;

	xz)
	tar -xf $nombre_comp || (echo "error descompresión"; exit 1);;
	
	tgz)
	tar -xvzf $nombre_comp || (echo "error descompresión"; exit 1);;

	*)
	echo "uso ./$nombre x.y.z (gz/bz2/zx)"
	exit 1;;
esac	
echo "... fin de la descompresión"

cd $nombre_dir

#----------------------CONFIGURE - MAKE - MAKE INSTALL------------------

echo -e "\nInstalacion de $nombre_dir 64 bit on 64 bit machine, MULTILIB" >> $FILE_BITACORA

cat > bc/fix-libmath_h << "EOF"
#! /bin/bash
sed -e '1 s/^/{"/' 		\
	-e 's/$/",/' 		\
	-e '2,$ s/^/"/' 	\
	-e '$ d' 			\
	-i libmath.h

sed -e '$ s/$/0}/' \
	-i libmath.h
EOF
registro_error "cat > bc/fix-libmath_h"


#Creo que no hace falta ya que en la build machine ya están las curses en
#/lib
#ln -sv /tools/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
#ln -sfv libncurses.so.6 /usr/lib/libncurses.so

sed -i -e '/flex/s/as_fn_error/: ;; # &/' configure
registro_error "sed de configure"

CC="gcc ${BUILD64}" \
./configure \
--prefix=/usr \
--with-readline \
--mandir=/usr/share/man \
--infodir=/usr/share/info
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

echo "quit" | ./bc/bc -l Test/checklib.b | tee $FILE_CHECKS

make install
registro_error $MSG_INST

######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA






