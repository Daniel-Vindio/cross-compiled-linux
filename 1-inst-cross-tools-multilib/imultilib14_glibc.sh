# Instalador de glibc 64 Bit 

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

echo -e "\nInstalacion de $nombre_dir 64 Bit" >> $FILE_BITACORA

cp -v timezone/Makefile{,.orig}
sed 's/\\$$(pwd)/`pwd`/' timezone/Makefile.orig > timezone/Makefile
registro_error "timezone"

if [ -d "build" ] ; then
	rm -rv "build"
fi

mkdir build
registro_error "mkdir build"
cd build

echo "libc_cv_ssp=no" > config.cache
registro_error "config.cache"

echo "slibdir=/tools/lib64" >> configparms
registro_error "slibdir=/tools/lib64"

BUILD_CC="gcc" \
CC="${CLFS_TARGET}-gcc ${BUILD64}" \
AR="${CLFS_TARGET}-ar" \
RANLIB="${CLFS_TARGET}-ranlib" \
../configure \
--prefix=/tools \
--host=${CLFS_TARGET} \
--build=${CLFS_HOST} \
--libdir=/tools/lib64 \
--disable-profile \
--enable-kernel=4.10 \
--with-binutils=/cross-tools/bin \
--with-headers=/tools/include \
--enable-obsolete-rpc \
--cache-file=config.cache
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

#make check 2>&1 | tee $FILE_CHECKS

make install
registro_error $MSG_INST

######------------------------------------------------------------------

cd ../..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA





