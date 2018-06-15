# Instalador de glibc 32 Bit
#10.7. Glibc-2.19 <--- esa era la antigua 32 Bit Libraries
#Se tiene en centa 6.2 de LFS-8.2 
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
echo -e "\nInstalacion de $nombre_dir 32 Bit" >> $FILE_BITACORA

#ln -sfv /tools/lib/gcc /usr/lib --->llevar a un script en CLFS no tiene sentido. Ver si tiene sentido en LFS
#ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3 --->llevar a un script
#rm -f /usr/include/limits.h --->llevar a un script
#GCC_INCDIR=/usr/lib/gcc/i686-pc-linux-gnu/$1/include ¿Hará falta?


#symlink for LSB compliance
ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3
registro_error "ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3"

#rm -f /usr/include/limits.h
#registro_error "rm -f /usr/include/limits.h"

if [ -f /usr/include/limits.h ] ; then
	rm -f /usr/include/limits.h
	registro_error "rm -f /usr/include/limits.h"
fi


if [ -d "build" ] ; then
	rm -rv "build"
fi

mkdir build
registro_error "mkdir build"
cd build

CC="gcc ${BUILD32}" \
CXX="g++ ${BUILD32}" \
../configure \
--prefix=/usr \
--disable-werror \
--enable-kernel=4.10 \
--enable-stack-protector=strong \
--libexecdir=/usr/lib/glibc \
--host=${CLFS_TARGET32}
libc_cv_slibdir=/lib
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

#sed -i '/cross-compiling/s@ifeq@ifneq@g' ../localedata/Makefile
#make -k check 2>&1 | tee $FILE_CHECKS; grep Error $FILE_CHECKS

#touch /etc/ld.so.conf
#registro_error "touch /etc/ld.so.conf"

sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
registro_error "sed '/test-installation/s"

make install
registro_error "make install"

#rm -v /usr/include/rpcsvc/*.x
#registro_error "rm -v /usr/include/rpcsvc/*.x"

##llevar a un script
##cp -v ../nscd/nscd.conf /etc/nscd.conf
##mkdir -pv /var/cache/nscd

##llevar a un script los locales y la configuración

######------------------------------------------------------------------

cd ../..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"

#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA
