# Instalador de gcc Segunda Pasada (MUSL)

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

echo -e "\nInstalacion de $nombre_dir Pasada 2 (MUSL x-comp)" >> $FILE_BITACORA

patch -Np1 -i ../gcc-$1.patch
registro_error "patch -Np1 -i ../"

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

cd $DIR_FUENTES/$nombre_dir/libstdc++-v3/config/os
mv -v gnu-linux gnu-linux.old
ln -svf generic gnu-linux
registro_error "ln -svf generic gnu-linux"
cd $DIR_FUENTES/$nombre_dir


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
--target=${CLFS_TARGET} \
--host=${CLFS_HOST} \
--with-sysroot=${CLFS} \
--with-local-prefix=/tools \
--with-native-system-header-dir=/tools/include \
--with-mpc=/cross-tools \
--with-mpfr=/cross-tools \
--with-gmp=/cross-tools \
--disable-nls \
--disable-static \
--enable-languages=c,c++ \
--with-system-zlib \
--disable-multilib \
--disable-libsanitizer
registro_error $MSG_CONF

#--disable-libsanitizer
#Parece que no causa problemas
#El oficial también lo desactiva

#Opciones para analizar errores. Ya no hacen falta
#--disable-libmpx \
#--disable-libgomp \
#--disable-libstdcxx

###-opcion propuesta en la wiki oficial
##../configure \
##--prefix=/cross-tools \
##--build=${CLFS_HOST} \
##--target=${CLFS_TARGET} \
##--host=${CLFS_HOST} \
##--with-sysroot=${CLFS} \
##--with-mpc=/cross-tools \
##--with-mpfr=/cross-tools \
##--with-gmp=/cross-tools \
##--enable-languages=c,c++ \
##--disable-libmudflap \
##--disable-libsanitizer \
##--disable-nls \
##--disable-multilib \
##--with-multilib-list=
##registro_error $MSG_CONF

#make AS_FOR_TARGET="${CLFS_TARGET}-as" LD_FOR_TARGET="${CLFS_TARGET}-ld"
registro_error $MSG_MAKE

#make check 2>&1 | tee $FILE_CHECKS

#make install
registro_error $MSG_INST

######------------------------------------------------------------------

cd ../..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA





