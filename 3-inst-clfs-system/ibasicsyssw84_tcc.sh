# Instalador de tcc
# 64 bit on 64 bit machine, MULTILIB.

#tcc-0.9.27.tar.bz2

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

./configure \
--prefix=/usr \
--libdir=/lib64 \
--enable-cross
registro_error $MSG_CONF

#De esta forma se compila para 64 bit un conjunto de tcc para distintas
#arqitecturas. Pir ejemplo el /usr/bin/i386-tcc que es un cc para generar
#binarios de 32 bit. Este será necesario para generar un tcc que corra
#en 32 bit (y genere binarios de 32 bit)

#Esta será la receta para generar el tcc de la maquina host
#./configure \
#--prefix=/usr \
#--cpu=i386

#Texto1="CC=gcc"
#Texto2="CC=i386-tcc"
#sed -i 's/'"$Texto1"'/'"$Texto2"'/' config.mak
#Así le decimos qué cc hay que usar.
#Es la compilación cruzada más sencilla que he visto en mi vida!!!!

make
registro_error $MSG_MAKE

#make test 2>&1 | tee $FILE_CHECKS

make install 
registro_error $MSG_INST

######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA
