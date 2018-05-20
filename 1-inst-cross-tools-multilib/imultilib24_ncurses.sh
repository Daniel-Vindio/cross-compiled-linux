# Instalador de ncurses

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

#http://www.linuxfromscratch.org/lfs/view/development/chapter06/ncurses.html
#Ver esta forma de instalar

echo -e "\nInstalacion de $nombre_dir " >> $FILE_BITACORA

./configure \
--prefix=/tools \
--build=${CLFS_HOST} \
--host=${CLFS_TARGET} \
--libdir=/tools/lib64 \
--with-build-cc=gcc \
--with-shared \
--without-debug \
--without-ada \
--enable-widec \
--enable-overwrite
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

make install
registro_error $MSG_INST

#No hacen ni bien ni mal a texinfo.
for lib in ncurses form panel menu ; do
    rm -vf                    /tools/lib64/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /tools/lib64/lib${lib}.so
    ln -sfv ${lib}w.pc        /tools/lib64/pkgconfig/${lib}.pc
done

rm -vf                     /tools/lib64/libcursesw.so
echo "INPUT(-lncursesw)" > /tools/lib64/libcursesw.so
ln -sfv libncurses.so      /tools/lib64/libcurses.so


######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA




#--enable-widec
#El original no lo lleva. Voy a porbarlo a ver si arregla el porblema
#de texinfo (no lo arregla)
#for lib in ncurses form panel menu ; do
#    rm -vf                    /tools/lib64/lib${lib}.so
#    echo "INPUT(-l${lib}w)" > /tools/lib64/lib${lib}.so
#    ln -sfv ${lib}w.pc        /tools/lib64/pkgconfig/${lib}.pc
#done
#
#rm -vf                     /tools/lib64/libcursesw.so
#echo "INPUT(-lncursesw)" > /tools/lib64/libcursesw.so
#ln -sfv libncurses.so      /tools/lib64/libcurses.so



