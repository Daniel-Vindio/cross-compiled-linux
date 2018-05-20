# Instalador de Texinfo

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

echo -e "\nInstalacion de $nombre_dir " >> $FILE_BITACORA


./configure \
--prefix=/tools
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

make install
registro_error $MSG_INST

######------------------------------------------------------------------

cd ..
rm -rf $nombre_dir && echo "Borrado el directorio $nombre_dir"


#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA






########################################################################
########Historico del error con las bibilotecas de terminal ############

#Este es el aviso que da cuando no ve claro lo de la bibliotecas de terminal...
#configure: WARNING: Could not find a terminal library among tinfo ncurses curses termlib termcap terminfo
#configure: WARNING: The programs from `info' directory will not be built.
#configure: Continuing with main configure (x86_64-unknown-linux-gnu).
#checking for tgetent in -ltinfo... no
#checking for tgetent in -lncurses... yes
#checking for library with termcap variables... 
#checking ncurses/termcap.h usability... no
#checking ncurses/termcap.h presence... no
#checking for ncurses/termcap.h... no


#--build=${CLFS_HOST} \ Quitando esto no de problemas (de momento)
#If you specify --host, but not --build, when configure performs the first 
#compiler test it tries to run an executable produced by the compiler. 
#If the execution fails, it enters cross-compilation mode. This is fragile. 
#Moreover, by the time the compiler test is performed, it may be too late 
#to modify the build-system type: other tests may have already been 
#performed. 
#Therefore, whenever you specify --host, be sure to specify --build too
#Lo que sucede en este caso al no poner buil, es que no falla la prueba
#de compilación (ya que la arquitectura de build y host es la misma) y
#usan el mismo interpreter (aunque está en distinto sitio)
#https://www.gnu.org/software/autoconf/manual/autoconf-2.69/html_node/Hosts-and-Cross_002dCompilation.html
#Confirmado. EN el config.log generado solo son --host, la prueba
#de cross compiling da negativo.
#Conclusión: solo con --host no falla porque no cross compila.
#LDFLAGS="L/tools/lib64 -lncurses" con esto se lia el interpreter
#LIBS=-lncurses \
## painful separate build for cross-compiling.
#SUBDIRS =
#if TOOLS_ONLY
#  # Build native tools only.
#  SUBDIRS += gnulib/lib install-info tp util info <--- este info hay que añadirlo al makefile.am
#if HAVE_TERMLIBS
#    SUBDIRS += info
#else
#sed -i '/rpl_$/d' lib/config.h
#gl_cv_func_getopt_gnu=yes
#/mnt/clfs/sources/texinfo-6.4/tools/info/Makefile
#Hay que cambiar en la linea  2499,1-8 ¿?
#$(top_builddir)/$(native_tools)/info/makedoc 
#por
#/mnt/clfs/sources/texinfo-6.5/info/makedoc
#Posible solución
#https://lists.gnu.org/archive/html/help-texinfo/2014-12/msg00006.html
#When cross-compiling, this program should be build for the "build"
#architecture, not the "host". There are a few possible solutions,
#outlined at http://lists.gnu.org/archive/html/automake/2014-01/msg00006.html.
#At the moment I think using AX_CC_FOR_BUILD from Autoconf Archive
#would be the best.


