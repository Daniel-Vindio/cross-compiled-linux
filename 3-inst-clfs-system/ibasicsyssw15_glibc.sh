# Instalador de glibc 64 Bit
#10.8.1. Installation of Glibc

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

LINKER=$(readelf -l /tools/bin/bash | sed -n 's@.*interpret.*/tools\(.*\)]$@\1@p')
sed -i "s|libs -o|libs -L/usr/lib64 -Wl,-dynamic-linker=${LINKER} -o|" \
  scripts/test-installation.pl
unset LINKER
registro_error "Sed test-installation.pl 1"

# scripts/test-installation.pl has been modified to skip nss_test2
# line 125 add && $name ne "nss_test2". Then tar the modified directory to
# create a new and modified glibc-2.27.tar.xz

sed -i 's/\\$$(pwd)/`pwd`/' timezone/Makefile
registro_error "timezone"

if [ -d "build" ] ; then
	rm -rv "build"
fi

mkdir build
registro_error "mkdir build"
cd build

echo "slibdir=/lib64" >> configparms
registro_error "slibdir=/lib64 >> configparms"

CC="gcc ${BUILD64}" \
CXX="g++ ${BUILD64}" \
../configure \
--prefix=/usr \
--disable-profile \
--enable-kernel=4.10 \
--libexecdir=/usr/lib64/glibc \
--libdir=/usr/lib64 \
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

#make -k check 2>&1 | tee $FILE_CHECKS; grep Error $FILE_CHECKS

make install
registro_error $MSG_INST

rm -v /usr/include/rpcsvc/*.x
registro_error "rm -v /usr/include/rpcsvc/*.x"

cp -v ../nscd/nscd.conf /etc/nscd.conf
registro_error "cp -v ../nscd/nscd.conf /etc/nscd.conf"

mkdir -pv /var/cache/nscd
registro_error "mkdir -pv /var/cache/nscd"


######-----------10.8.2. Internationalization 
mkdir -pv /usr/lib/locale
registro_error "mkdir -pv /usr/lib/locale"

localedef -i es_ES -f ISO-8859-1 es_ES
registro_error "localedef -i es_ES -f ISO-8859-1 es_ES"

localedef -i es_ES@euro -f ISO-8859-15 es_ES@euro
registro_error "localedef -i es_ES@euro -f ISO-8859-15 es_ES@euro"

localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i ja_JP -f EUC-JP ja_JP


##10.8.3. Configuring Glibc 
cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF
registro_error "/etc/nsswitch.conf"


tar -xf ../../tzdata-2018d.tar.xz
registro_error "tar -xf ../../tzdata-2018d.tar.xz"

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
registro_error "mkdir -pv $ZONEINFO/{posix,right}"

cd tzdata-2018d

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew \
          systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done
registro_error "for tz in etcetera"


cp -v zone.tab iso3166.tab $ZONEINFO
registro_error "cp -v zone.tab iso3166.tab $ZONEINFO"

zic -d $ZONEINFO -p America/New_York
registro_error "zic -d $ZONEINFO -p America/New_York"

unset ZONEINFO

cp -v /usr/share/zoneinfo/Europe/Madrid /etc/localtime
registro_error "cp -v /usr/share/zoneinfo/Europe/Madrid /etc/localtime"


#10.8.4. Configuring The Dynamic Loader 

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf

/usr/local/lib
/usr/local/lib64
/opt/lib
/opt/lib64

# End /etc/ld.so.conf
EOF
registro_error "/etc/ld.so.conf"


######------------------------------------------------------------------

cd ../../..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA
