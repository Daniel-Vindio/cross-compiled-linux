# Instalador de gcc
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

echo -e "\nInstalacion de $nombre_dir 64 bit on 64 bit machine, MULTILIB." >> $FILE_BITACORA

if [ -d "build" ] ; then
	rm -rv "build"
fi

mkdir build
registro_error "mkdir build"
cd build

SED=sed CC="gcc -isystem /usr/include ${BUILD64}" \
CXX="g++ -isystem /usr/include ${BUILD64}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib64:/lib64:/usr/lib:/lib" \
../configure \
--prefix=/usr \
--libdir=/usr/lib64 \
--libexecdir=/usr/lib64 \
--enable-languages=c,c++ \
--disable-bootstrap \
--with-system-zlib
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

#ulimit -s 32768
#make -k check 2>&1 | tee $FILE_CHECKS
#../contrib/test_summary >> $FILE_CHECKS

make install
registro_error $MSG_INST

##Seems to be an obsolete requirement.
##cp -v ../gcc-4.8.3/include/libiberty.h /usr/include
##cp -v ../include/libiberty.h /usr/include
##registro_error "cp -v ../include/libiberty.h /usr/include"

ln -sv ../usr/bin/cpp /lib64
registro_error "ln -sv /usr/bin/cpp /lib64"

ln -sv gcc /usr/bin/cc
registro_error "ln -sv gcc /usr/bin/cc"

install -v -dm755 /usr/lib64/bfd-plugins
registro_error "install -v -dm755 /usr/lib/bfd-plugins"

ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/$1/liblto_plugin.so /usr/lib64/bfd-plugins/
registro_error "ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/$1/"

mkdir -pv /usr/share/gdb/auto-load/usr/lib64
registro_error "mkdir -pv /usr/share/gdb/auto-load/usr/lib"

mv -v /usr/lib64/*gdb.py /usr/share/gdb/auto-load/usr/lib64
registro_error "mv -v /usr/lib/*gdb.py /usr/share/gdb/----"

######------------------------------------------------------------------

cd ../..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA

