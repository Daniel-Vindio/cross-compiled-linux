# Instalador de gcc Primera PAsada

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
	echo ""
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

echo -e "\nInstalacion de $nombre_dir STATIC + No Threads " >> $FILE_BITACORA


########################
#no hace falta parche de specs. Lo hace todo el siguiente bucle
#######################

for file in \
 $(find gcc/config -name linux64.h -o -name linux.h -o -name sysv4.h)
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
  registro_error "creado $file.orig"
done


touch /tools/include/limits.h
registro_error "touch /tools/include/limits.h"

if [ -d "build" ] ; then
	rm -rv "build"
fi

mkdir -v build
registro_error "mkdir -v build"
cd build

AR=ar LDFLAGS="-Wl,-rpath,/cross-tools/lib" \
../configure \
--prefix=/cross-tools \
--build=${CLFS_HOST} \
--host=${CLFS_HOST} \
--target=${CLFS_TARGET} \
--with-sysroot=${CLFS} \
--with-local-prefix=/tools \
--with-native-system-header-dir=/tools/include \
--with-mpfr=/cross-tools \
--with-gmp=/cross-tools \
--with-cloog=/cross-tools \
--with-mpc=/cross-tools \
--with-isl=/cross-tools \
--without-headers \
--with-newlib \
--disable-nls \
--disable-shared \
--enable-languages=c,c++ \
--disable-decimal-float \
--disable-libgomp \
--disable-libmudflap \
--disable-libssp \
--disable-libatomic \
--disable-libitm \
--disable-libsanitizer \
--disable-libquadmath \
--disable-threads \
--disable-target-zlib \
--with-system-zlib \
--enable-checking=release
registro_error $MSG_CONF

# --disable-multilib \

make all-gcc all-target-libgcc
registro_error $MSG_MAKE

#make check 2>&1 | tee $FILE_CHECKS

make install-gcc install-target-libgcc
registro_error $MSG_INST

######------------------------------------------------------------------

cd ../..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA



#tar -xf ../mpfr-$3.tar.xz
#mv -v mpfr-$3 mpfr
#registro_error "mpfr-$3"
#
#tar -xf ../gmp-$4.tar.xz
#mv -v gmp-$4 gmp
#registro_error "gmp-$4"
#
#tar -xf ../mpc-$5.tar.gz
#mv -v mpc-$5 mpc
#registro_error "mpc-$5"
#
#tar -xf ../isl-$6.tar.gz
#mv -v isl-$6 isl
#registro_error "isl-$6"





