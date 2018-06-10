# Instalador de readline
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

sed -i '/MV.*old/d' Makefile.in
registro_error "sed -i '/MV.*old/d' Makefile.in"

sed -i '/{OLDSUFF}/c:' support/shlib-install
registro_error "sed -i '/{OLDSUFF}/c:' support/shlib-install"

CC="gcc ${BUILD32}" \
CXX="g++ ${BUILD32}" \
./configure \
--prefix=/usr \
--libdir=/lib \
--disable-static \
--docdir=/usr/share/doc/readline-$1
registro_error $MSG_CONF

#make SHLIB_LIBS=-lncurses. Est es en la vesrión clfs antigua. Ahora
#parece que se us ncursesw y en versión 6.

#make SHLIB_LIBS="-L/tools/lib -lncursesw"
#Aquí está el meollo. ¿Dónde etá ncursesw? LFS dice que en tools
#Siguiendo CLFS, ya estaría instalada. Siguiendo LFS, todavía no, así que
#estaría en tools, pero en 64 --- Hace falta instalar primero ncurses multilib

#Conclusión.
#Una vez instalada ncurses en la build machine, al conclusión es que
#-lncursesw está en /lib (ojo para trabajos de 32 bit, sino está en /lib64.

make SHLIB_LIBS="-L/lib -lncursesw"
registro_error $MSG_MAKE

##no tiene make check 2>&1 | tee $FILE_CHECKS

#make SHLIB_LIBS="-L/tools/lib -lncurses" install
#En el libro pone -lncurses ¿? si estamos hablando siempre de -lncursesw...
#pongo -lncursesw a ver qué pasa.
make SHLIB_LIBS=-lncursesw htmldir=/usr/share/doc/readline-$1 install
registro_error $MSG_INST


#--disable-static --> no hace falta moverlas, simplemente no están
#mv -v /lib/lib{readline,history}.a /usr/lib

#Parece que es más apropiado que estén en/lib, que en /usr/lib
#mv -v /usr/lib/lib{readline,history}.so.* /lib
#registro_error "mv -v /lib/lib{readline,history}.a /usr/lib"
#PERO:
#mv: cannot stat '/usr/lib/libreadline.so.*': No such file or directory
#mv: cannot stat '/usr/lib/libhistory.so.*': No such file or directory
#Ya estaban en /lib !!


#En CLFS: ln -svf ../../lib/$(readlink /lib/libreadline.so) /usr/lib/libreadline.so
#ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
#registro_error "ln -svf ../../lib/"
#resultado:
#'/usr/lib/libreadline.so' -> '../../lib/'
#ldconfig: Cannot mmap file /usr/lib/libreadline.so.
#Lógico, el readlin está vacío, porque no había /usr/lib
#Conclusión. eliminar también en ln -svf ..


#En CLFS: ln -svf ../../lib/$(readlink /lib/libhistory.so) /usr/lib/libhistory.so
#ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
#registro_error "ln -svf ../../lib/"

#resultado:
#/usr/lib/libhistory.so' -> '../../lib/'
#ldconfig dice
#ldconfig: Cannot mmap file /usr/lib/libhistory.so.
#Lógico, el readlin está vacío, porque no había /usr/lib
#Conclusión. eliminar también en ln -svf ...

##Vigilar esto bien para el paquete qi

##En CLFS: rm -v /lib/lib{readline,history}.so

install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-$1

######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA






