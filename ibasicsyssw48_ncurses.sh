# Instalador de ncurses
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

echo -e "\nInstalacion de $nombre_dir 64 bit" >> $FILE_BITACORA

sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
registro_error "sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in"

CC="gcc ${BUILD64}" \
CXX="g++ ${BUILD64}" \
./configure \
--prefix=/usr \
--libdir=/lib64 \
--with-shared \
--without-debug \
--enable-widec \
--enable-pc-files \
--without-normal \
--with-default-terminfo-dir=/usr/share/terminfo
registro_error $MSG_CONF

make
registro_error "make"

make install
registro_error "make install"

mv -v /usr/bin/ncursesw6-config{,-64}
registro_error "mv -v /usr/bin/ncursesw5-config{,-64}"

ln -svf multiarch_wrapper /usr/bin/ncursesw6-config
registro_error "ln -svf multiarch_wrapper"

#mv -v /usr/lib64/libncursesw.so.6* /lib64
#registro_error "mv -v /usr/lib64/libncursesw.so.6* /lib64"
#Resultado:
#ldconfig: Cannot mmap file /usr/lib64/libncursesw.so
#Como consecuencia, el symlink no apunta a ningún sitio. Lo elimino de la
#instalación y quito esta instrucción
#ln -sfv ../../lib64/$(readlink /usr/lib64/libncursesw.so) /usr/lib64/libncursesw.so
#registro_error "ln -sfv ../../lib64"

for lib in ncurses form panel menu ; do
	rm -vf /usr/lib64/lib${lib}.so
	registro_error "rm -vf /usr/lib64/lib${lib}.so"
	echo "INPUT(-l${lib}w)" > /usr/lib64/lib${lib}.so
	registro_error "echo INPUT...lib${lib}" 
	ln -sfv ${lib}w.pc /usr/lib64/pkgconfig/${lib}.pc
	registro_error "ln -sfv ${lib}w.pc /usr/lib64/pkgconfig/${lib}.pc"
done

rm -vf /usr/lib64/libcursesw.so
registro_error "rm -vf /usr/lib64/libcursesw.so"

echo "INPUT(-lncursesw)" > /usr/lib64/libcursesw.so
registro_error "echo INPUT(-lncursesw) > /usr/lib64/libcursesw.so"

ln -sfv libncurses.so /usr/lib64/libcurses.so
registro_error "ln -sfv libncurses.so /usr/lib64/libcurses.so"

mkdir -v /usr/share/doc/ncurses-$1
cp -v -R doc/* /usr/share/doc/ncurses-$1
registro_error "cp -v -R doc/*"

make distclean
registro_error "make distclean"

./configure \
--prefix=/usr \
--with-shared \
--without-normal \
--without-debug \
--without-cxx-binding \
--with-abi-version=5
registro_error $MSG_CONF

make sources libs
registro_error "make sources libs"

cp -av lib/lib*.so.5* /usr/lib64
registro_error "cp -av lib64/lib*.so.5* /usr/lib64"

######------------------------------------------------------------------

cd ..
#rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA



###==================== nota sobre los TEST
#./configure \
#--prefix=/usr \
#--with-ncursesw

#Parece que solo curses no funciona.
