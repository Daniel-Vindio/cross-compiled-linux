# Instalador de bzip
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

echo -e "\nInstalacion de $nombre_dir 64 bit on 64 bit machine, MULTILIB" >> $FILE_BITACORA

sed -i -e 's:ln -s -f $(PREFIX)/bin/:ln -s :' Makefile
registro_error "sed Makefile"

sed -i 's@X)/man@X)/share/man@g' ./Makefile
registro_error "sed Makefile 2"

sed -i 's@/lib\(/\| \|$\)@/lib64\1@g' Makefile
registro_error "sed Makefile 3"

make -f Makefile-libbz2_so CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"
registro_error "make -f Makefile-libbz2_so"

make clean
registro_error "make clean"

make CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}"
registro_error "make"

#make CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" check 2>&1 | tee $FILE_CHECKS

make CC="gcc ${BUILD64}" CXX="g++ ${BUILD64}" PREFIX=/usr install
registro_error "Make install"

cp -v bzip2-shared /bin/bzip2
registro_error "cp 1"

cp -av libbz2.so* /lib64
registro_error "cp 2"

ln -sv ../../lib64/libbz2.so.1.0 /usr/lib64/libbz2.so
registro_error "ln 1"

rm -v /usr/bin/{bunzip2,bzcat,bzip2}
registro_error "rm 1"

ln -sv bzip2 /bin/bunzip2
registro_error "ln 2"

ln -sv bzip2 /bin/bzcat
registro_error "ln 3"



######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA






