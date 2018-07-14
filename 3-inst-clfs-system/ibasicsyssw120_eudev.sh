# Instalador de eudev
# 64 bit on 64 bit machine, MULTILIB.

#eudev-3.2.5.tar.gz

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

sed -r -i 's|/usr(/bin/test)|\1|' test/udev-test.pl
registro_error "sed"

cat > config.cache << "EOF"
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
#BLKID_CFLAGS="-I/tools/include"
EOF

CC="gcc ${BUILD64}" \
CXX="g++ ${BUILD64}" \
PKG_CONFIG_PATH=${PKG_CONFIG_PATH64} \
./configure \
--prefix=/usr \
--bindir=/sbin \
--sbindir=/sbin \
--libdir=/usr/lib64 \
--sysconfdir=/etc \
--libexecdir=/lib64 \
--with-rootprefix= \
--with-rootlibdir=/lib64 \
--enable-manpages \
--disable-static \
--config-cache
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

make install
registro_error $MSG_INST

mkdir -pv /lib64/udev/rules.d
registro_error "mkdir1"

mkdir -pv /etc/udev/rules.d
registro_error "mkdir2"

tar -xvf ../udev-lfs-20171102.tar.bz2
registro_error "tar"

make -f udev-lfs-20171102/Makefile.lfs install
registro_error "make"

udevadm hwdb --update
registro_error "udevadm hwdb --update"

make check 2>&1 | tee $FILE_CHECKS

######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA



