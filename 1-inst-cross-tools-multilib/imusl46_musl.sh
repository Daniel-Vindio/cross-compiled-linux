# Instalador de MUSL

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

echo -e "\nInstalacion de $nombre_dir (MUSL x-comp)" >> $FILE_BITACORA

###Pendiente de analizar y desarrollar
#CC="${CLFS_TARGET}-gcc ${BUILD32}" \
#./configure \
#CROSS_COMPILE=${CLFS_TARGET}- \
#--prefix=/tools \
#--disable-static \
#--target=${CLFS_TARGET32}

CC="${CLFS_TARGET}-gcc ${BUILD64}" \
CROSS_COMPILE=${CLFS_TARGET}- \
./configure \
--prefix=/tools \
--build=${CLFS_HOST} \
--target=${CLFS_TARGET} \
--disable-gcc-wrapper
registro_error $MSG_CONF

#--disable-static No tarda anto como para quitarla
#--syslibdir=/tools/lib64 Esto no funciona siempre va a /lib

###-opcion propuesta en la wiki oficial
#CC="${CLFS_TARGET}-gcc" \
#CROSS_COMPILE=${CLFS_TARGET}- \
#./configure \
#--prefix=/tools \
#--enable-debug \
#--enable-optimize
#registro_error $MSG_CONF

make
registro_error $MSG_MAKE

make install
registro_error $MSG_INST


ln -fv /tools/lib/libc.so /tools/lib/ld-musl-x86_64.so.1
registro_error $MSG_INST "ln -fv /tools/lib/libc.so ---"

#ln -fv /tools/lib/libc.so /tools/lib/ld-musl-i386.so.1
#registro_error $MSG_INST "ln -fv /tools/lib/libc.so ---"



######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA






