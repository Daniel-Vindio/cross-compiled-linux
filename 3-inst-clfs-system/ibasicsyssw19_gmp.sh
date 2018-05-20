# Instalador de gmp
# 32 bit on 64 bit machine, MULTILIB.

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

echo -e "\nInstalacion de $nombre_dir 32 bit on a 64 bit machine" >> $FILE_BITACORA

# It avoids optimization (not possible in cross compiling)
mv -v config{fsf,}.guess
registro_error "mv -v config{fsf,}.guess"

mv -v config{fsf,}.sub
registro_error "mv -v config{fsf,}.sub"

CC="gcc -isystem /usr/include ${BUILD32}" \
CXX="g++ -isystem /usr/include ${BUILD32}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib ${BUILD32}" \
ABI=32 \
./configure \
--prefix=/usr \
--disable-static \
--enable-cxx 
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

#Add to configure:
#--docdir=/usr/share/doc/gmp-$1
#make html
#registro_error "make html"

make install
registro_error $MSG_INST

#make install-html
#registro_error "make install-html"

#make check 2>&1 | tee $FILE_CHECKS
#awk '/# PASS:/{total+=$3} ; END{print total}' $FILE_CHECKS
# 190 tests must PASS

# It is important in order to keep both libraries, 32 and 64 bit, by 
# means of a stub header in the place of the original gmp.h (See 64 bit
# installer)
mv -v /usr/include/gmp{,-32}.h
registro_error "mv -v /usr/include/gmp{,-32}.h"

######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA


#---Comments
#First installation
#./configure \
#--prefix=/tools


