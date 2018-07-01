# Instalador de libelf
# 32 bit on 64 bit machine, MULTILIB.

#elfutils-0.170.tar.xz
nombre="elfutils"
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

echo -e "\nInstalacion de libelf $nombre_dir 32 bit on 64 bit machine, MULTILIB" >> $FILE_BITACORA

CC="gcc ${BUILD32}" \
CXX="g++ ${BUILD32}" \
./configure \
--prefix=/usr \
--libdir=/lib
registro_error $MSG_CONF

Texto1="CFLAGS = -D_FORTIFY_SOURCE=2 -g -O2"
Texto2="CFLAGS = -D_FORTIFY_SOURCE=2 -g -O2 -Wno-error=packed-not-aligned"
sed -i 's/'"$Texto1"'/'"$Texto2"'/' backends/Makefile
registro_error "sed"

make
registro_error $MSG_MAKE

make check 2>&1 | tee $FILE_CHECKS

make -C libelf install 
registro_error $MSG_INST

install -vm644 config/libelf.pc /usr/lib/pkgconfig
registro_error "install -vm644"
######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA


#error
#In file included from m68k_corenote.c:72:
#linux-core-note.c:116:1: error: alignment 2 of 'struct m68k_prstatus' is less than 4 [-Werror=packed-not-aligned]
# ;
# ^
#linux-core-note.c:110:5: error: '({anonymous})' offset 70 in 'struct m68k_prstatus' isn't aligned to 4 [-Werror=packed-not-aligned]
#     ;
#     ^
#  CC       bpf_regs.o
#  CC       i386_init.os
#cc1: all warnings being treated as errors
#make[2]: *** [Makefile:750: m68k_corenote.o] Error 1
#make[2]: *** Waiting for unfinished jobs....

#/elfutils-0.170/backends/Makefile
#linea 292 CFLAGS = -D_FORTIFY_SOURCE=2 -g -O2-Wno-error=packed-not-aligned



