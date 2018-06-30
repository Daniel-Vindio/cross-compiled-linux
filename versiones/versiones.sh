# Este script sirve para almacenar todas las variables de versión, las 
# cuales son compartidas por varios instaladores. De esta froma se 
# centraliza su control, lo que facilita la actualización continua de 
# las versiones.

# This script is used to store all the version variables, which are 
# shared by several installers. This control is centralized in order to 
# make easier the continuous updating of the versions.


# Important warning regarding the correct assigment of the version
# values to the variables.
echo -e "
Remember: Do not try ./versiones.sh, 'export' won't work!.  
Use instead, source versiones.sh"

if [ "$0" != "$BASH_SOURCE" ]
then
	echo -e "\nOk, vale. It seems you've used '. versiones.sh'"
else
	echo -e "
=======================================================
 I told you. With ./versiones.sh, 'export' won't work!.  
 Use instead source '. versiones.sh'	EXIT.			   
======================================================="
	exit
fi
	


paquetes="PRUEBA binutils bash bison bzip2 check cloog coreutils dejagnu \
diffutils expect file findutils gawk gcc gettext glibc gmp graft grep \
gzip isl linux lzip m4 make man_pages mpc mpfr ncurses patch perl pkg \
qi sed tar tcl texinfo unzip util_linux vim xz zlib flex readline bc \
attr acl libcap shadow psmisc iana libtool gdbm gperf expat inetutils \
xmlparser intltool autoconf automake kmod"

VER_PRUEBA="prueba_ok"
VER_binutils="2.30"
VER_file="5.32"
#VER_gcc="7.3.0"
VER_gcc="8.1.0"
VER_glibc="2.27"
#VER_gmp="6.0.0"		#gmp+mpc+mpfr 6.0.0+1.0.2+3.1.2 funciona
VER_gmp="6.1.2"
VER_linux="4.16"
VER_m4="1.4.18"
#VER_mpc="1.0.2"
VER_mpc="1.1.0"
#VER_mpfr="3.1.2"
VER_mpfr="4.0.1"
VER_ncurses="6.1"
VER_cloog="0.18.4"
VER_isl="0.18"
VER_pkg="0.28-1"		#pkg-config-lite. En instalador bien
VER_bash="4.4.18"
VER_bzip2="1.0.6"
VER_coreutils="8.29"
VER_check="0.12.0"
VER_diffutils="3.6"
VER_findutils="4.6.0"
VER_gawk="4.2.0"
VER_gettext="0.19.8.1"
VER_grep="3.1"
VER_gzip="1.9"
VER_make="4.2.1"
VER_patch="2.7.6"
VER_sed="4.4"
VER_tar="1.30"
VER_util_linux="2.31.1"	#util-linux En instalador bien
VER_vim="8.0"
VER_xz="5.2.3"
VER_zlib="1.2.11"
VER_tcl="8.6.8"
VER_expect="5.45.4"		#expect5.45.4 Si guion
VER_dejagnu="1.6.1"
VER_perl="5.26.1"
VER_texinfo="6.5"
VER_bison="3.0.4"
VER_lzip="1.20"
VER_unzip="60" 			#unzip60 sin guion
VER_graft="2.16"
VER_qi="1.0-rc24"
VER_man_pages="4.15" 	#man-pages En instalador bien
VER_flex="2.6.4"
VER_readline="7.0"
VER_bc="1.07.1"
VER_attr="2.4.48"
VER_acl="2.2.53"
VER_libcap="2.25"
VER_shadow="4.6"
VER_psmisc="23.1"
VER_iana="2.30"			#iana-etc en el instalador
VER_libtool="2.4.6"
VER_gdbm="1.15"
VER_gperf="3.1"
VER_expat="2.2.5"
VER_inetutils="1.9.4"
VER_xmlparser="2.44"
VER_intltool="0.51.0"
VER_autoconf="2.69"
VER_automake="1.15.1"
VER_kmod="25"


for i in $paquetes; do
	export VER_$i
done

echo -e "\nTest = $VER_PRUEBA. Should be 'prueba_ok'"

#https://stackoverflow.com/questions/2683279/how-to-detect-if-a-script-is-being-sourced
# if "$0" == "$BASH_SOURCE" then the file has been sourced, othewise 
# it was excuted with ./
# $_ could've been used instead $BASH_SOURCE... I don't it see clear.
