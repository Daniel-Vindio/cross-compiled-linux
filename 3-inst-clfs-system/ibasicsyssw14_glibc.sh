# Instalador de glibc 32 Bit
#10.7. Glibc-2.19 <--- esa era la antigua 32 Bit Libraries

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

LINKER=$(readelf -l /tools/bin/bash | sed -n 's@.*interpret.*/tools\(.*\)]$@\1@p')
sed -i "s|libs -o|libs -L/usr/lib -Wl,-dynamic-linker=${LINKER} -o|" \
  scripts/test-installation.pl
unset LINKER

# scripts/test-installation.pl has been modified to skip nss_test2
# line 125 add && $name ne "nss_test2". Then tar the modified directory to
# create a new and modified glibc-2.27.tar.xz

cp -v timezone/Makefile{,.orig}
sed 's/\\$$(pwd)/`pwd`/' timezone/Makefile.orig > timezone/Makefile
registro_error "timezone"

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
--disable-profile \
--enable-kernel=4.10 \
--libexecdir=/usr/lib/glibc \
--host=${CLFS_TARGET32} \
--enable-obsolete-rpc
registro_error $MSG_CONF

#--enable-obsolete-nsl
# Causes a making error (not during the testes before installing, but
# during making) --> I decided not to build obsolete nsl.
# BUG. scripts/test-installation.pl doesn't detect that obsolete nls are
# not enabled, and try to test installation of all the -lnss_* and fails
# I hack line 125 to avoid testing, fixing test-installation.pl in the 
# tarball source.

make
registro_error $MSG_MAKE

sed -i '/cross-compiling/s@ifeq@ifneq@g' ../localedata/Makefile
#make -k check 2>&1 | tee $FILE_CHECKS; grep Error $FILE_CHECKS

touch /etc/ld.so.conf
registro_error "touch /etc/ld.so.conf"

make install
registro_error "make install"

rm -v /usr/include/rpcsvc/*.x
registro_error "rm -v /usr/include/rpcsvc/*.x"

######------------------------------------------------------------------

cd ../..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"

#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA


# List of library names according to the book
#ld
#libBrokenLocale
#libSegFault
#libanl
#libc
#libc_nonshared
#libcidn
#libcrypt
#libdl
#libg
#libieee *** It dosnt exist in Glibc 2-27
#libm
#libmcheck
#libmemusage
#libnsl
#libnss_compat
#libnss_dns
#libnss_files
#libnss_hesiod
#libnss_nis
#libnss_nisplus
#libpcprofile
#libpthread
#libpthread_nonshared
#libresolv
#librpcsvc
#librt
#libthread_db
#libutil

#Según soversion.mk
#ld
#libc
#libnss_nis
#libBrokenLocale
#libpthread
#libthread_db
#libnss_nisplus
#libcrypt
#libdl
#libgcc_s
#libcidn
#libnss_test1
#libnsl
#libutil
#libnss_ldap
#libnss_test2
#libnss_dns
#libnss_compat
#libmvec
#libresolv
#libnss_db
#libm
#libnss_files
#librt
#libnss_hesiod
#libanl

