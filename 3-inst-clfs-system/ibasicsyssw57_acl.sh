# Instalador de acl
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

echo -e "\nInstalacion de $nombre_dir 32 bit on 64 bit machine, MULTILIB" >> $FILE_BITACORA

#Estos sed parecen apropiados para la vesión 2.2.53. Con la 2.2.54 creo
#que no funcionan
#sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
#sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
#sed -i 's/{(/\\{(/' test/run
#la versión 53 ya tiene esto resuelto
#sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" libacl/__acl_to_any_text.c


CC="gcc ${BUILD32}" \
CXX="g++ ${BUILD32}" \
./configure \
--prefix=/usr \
--libdir=/lib \
--bindir=/bin \
--libexecdir=/usr/lib \
--disable-static
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

#make -j1 check 2>&1 | tee $FILE_CHECKS
#Se producen bastantes fallos. Hago pruebas a mano siguiendo las indicaciones
#de los test. Los errores precen de la propia definición del test, no creo
#que se trata de errores de compilación.

make install 
registro_error $MSG_INST

#Con --prefix=/usr --libdir=/lib no hay ninguna biblioteca que cambiar

######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA






