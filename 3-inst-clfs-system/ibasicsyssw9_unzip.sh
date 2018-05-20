# Instalador de unzip
#Hace falta para Qi

nombre="unzip"
nombre_comp=${nombre}$1.tar.$2
nombre_dir=${nombre}$1

echo $nombre
echo $nombre_comp
echo $nombre_dir

#unzip60.tar.gz

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

echo -e "\nInstalacion de $nombre_dir " >> $FILE_BITACORA
#Necesita que se le aporte la fuente de bzip2. Hay que colocarla en ese
#directorio que trae a tal efecto
tar -xf $DIR_FUENTES/bzip2-1.0.6.tar.gz -C $DIR_FUENTES/unzip60/bzip2

#No basta con poner las fuentes, es necesario compilar la librería libz2.a
#Esto se hace dentro de las fuentes que acabamos de poner
cd $DIR_FUENTES/unzip60/bzip2/bzip2-1.0.6

#Parece que traen cosas precompiladas. Hay que eliminar todo y partir de cero
make distclean

#To make it more complicated, the normal build is not valid due some error
#that is very well explined in the make file. As a consecuence a patch is
#needen to produce BZ_NO_STDIO compiling.
cp -v Makefile{,.orig}
patch -N -i $DIR_FUENTES/ibasicsyssw9_unzip_bzip2-1.0.6.patch
registro_error "parche fuentes bzip2"

#The patch fixes something like
#+	$(CC) $(CFLAGS) -DBZ_NO_STDIO -c blocksort.c
#It is done un 7 sources used to build libz2.a

#Only the library libz2.a is needed.
make libbz2.a

#And now configuring, that is also special.
cd ../../unix
./configure gcc "" /sources/unzip60/bzip2/bzip2-1.0.6
registro_error $MSG_CONF

#The generic_gcc option is recommended. The makefile default is cc, but
#in our chroot there is no cc --> gcc. They recommend not tu patch the 
#Makefile, but to use generic_gcc
cd ..
make -f unix/Makefile generic_gcc

registro_error $MSG_MAKE

#There is a problem with the make install. (I don't have time to fix it
#but is easy to install only the programs, without the manuals)
cp unzip funzip unzipsfx /tools/bin
registro_error $MSG_INST

######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA






