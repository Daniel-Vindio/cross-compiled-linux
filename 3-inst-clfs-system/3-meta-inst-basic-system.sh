#!/tools/bin/bash -e

echo -e "
############################################################\n\
#$0\n\
############################################################\n"

cd /home

. 0-var-chroot-rc
. versiones.sh

./2-4-creacion-directorios.sh
./2-5-creacion-config-files.sh


control_flujo () {
	echo "Continue? To exit press N"
	read CS
	if [ "$CS" == "N" ]
		then
			echo "exit"
			exit
	fi
}

# Cross-Compiled Linux From Scratch
# Version 3.0.0-SYSVINIT-x86_64-Multilib
# V. Building the CLFS System
# 9. Constructing Testsuite Tools 
./ibasicsyssw1_tcl.sh 		$VER_tcl 	gz
./ibasicsyssw2_expect.sh 	$VER_expect gz
./ibasicsyssw3_dejagnu.sh 	$VER_dejagnu gz

# Perl is required by texinfo (and its dependents), and also it is needed
# for graft and qi (package management)
./ibasicsyssw4_perl.sh 		$VER_perl 	gz


# Texinfo is a very problematic source to cross-compile, impossible.
# I bring it here, to chroot, but it requires Perl. Luckily, Perl has
# been very kind to chroot compilation without problems.
./ibasicsyssw5_texinfo.sh 	$VER_texinfo xz


# Bison and m4 are needed for building Glibc (2.16)
# I've tried to cross compile them, but I have had problems with
# intl in Glibc. Bison and m4 don't work...m4 subprocess... file not found
# So I think its better to build them now, in chroot, but with /tools, and
# later install them again, but with the rest of the system.
# m4 requires texinfo, that's why it is build before.
./ibasicsyssw6_m4.sh 		$VER_m4 	xz
./ibasicsyssw7_bison.sh 	$VER_bison 	xz


# Programs for package management: Graft and Qi
./ibasicsyssw8_lzip.sh 		$VER_lzip 	gz
./ibasicsyssw9_unzip.sh 	$VER_unzip 	gz
./ibasicsyssw10_graft.sh 	$VER_graft 	gz
./ibasicsyssw11_qi.sh 		$VER_qi


# And now, the rest of the basic system in chroot.
# Important: The tar package of glibc has been created from the development
# source (git cloned). Also the file scripts/test-installation.pl must be
# modified to skip xxxx test
./ibasicsyssw12_linux.sh 		$VER_linux 		xz
./ibasicsyssw13_man-pages.sh 	$VER_man_pages 	xz
./ibasicsyssw14_glibc.sh 		$VER_glibc 		xz	#32 bit
./ibasicsyssw15_glibc.sh 		$VER_glibc 		xz	#64 bit


# 10.9. Adjusting the Toolchain and TESTS
./ibasicsyssw16_adjust.sh

#Optional. Do not run if GLIBC has already been installed with 15.
#10.8.2. Internationalization
#10.8.3. Configuring Glibc excep time zone
#10.8.4. Configuring The Dynamic Loader 
#ibasicsyssw17_locales.sh

#control_flujo

# From now on, we have kind of tasks to be performed on the building 
# machine:
#	* 32 bit libraries. 
#		- Making and install on the build machine.
#		- Cross making and packaging for the host machine.
#	* 32 bit application (binaries). 
#		- Cross making and packaging for the host machine.
#		- Making and installing on the build machine? We'll see.
#	* 64 bit libraries.
#		- Making and install on the build machine.
#	* 64 bit application (binaries). 
#		- Making and installing on the build machine

# Prepared for 64 bit
./ibasicsyssw18_m4.sh 	$VER_m4 	xz

########## in progress / en proceso ################

#GMP 32 (cross compiled) and 64 (native) Bit Libraries 
./ibasicsyssw19_gmp.sh	$VER_gmp	xz
./ibasicsyssw20_gmp.sh	$VER_gmp	xz

./ibasicsyssw21_mpfr.sh $VER_mpfr xz
./ibasicsyssw22_mpfr.sh $VER_mpfr xz

./ibasicsyssw23_mpc.sh $VER_mpc gz
./ibasicsyssw24_mpc.sh $VER_mpc gz

#./ibasicsyssw25_isl.sh $VER_isl gz
#./ibasicsyssw26_isl.sh $VER_isl gz

#./ibasicsyssw27_cloog.sh $VER_cloog gz
#./ibasicsyssw28_cloog.sh $VER_cloog gz

./ibasicsyssw29_zlib.sh $VER_zlib xz
./ibasicsyssw30_zlib.sh $VER_zlib xz

./ibasicsyssw31_flex.sh $VER_flex gz
./ibasicsyssw32_flex.sh $VER_flex gz

./ibasicsyssw33_bison.sh $VER_bison xz
./ibasicsyssw34_bison.sh $VER_bison xz

##./ibasicsyssw35_binutils.sh $VER_binutils gz	Solo para qi
./ibasicsyssw36_binutils.sh $VER_binutils gz

##./ibasicsyssw37_gcc.sh $VER_gcc gz Solo para qi TO-DO
./ibasicsyssw38_gcc.sh $VER_gcc gz 
./ibasicsyssw39_gcctest.sh
./ibasicsyssw40_wrapper.sh

##Hasta aquí es
##V. Building the CLFS System
##10. Installing Basic System Software
##10.28 gcc
##A partir de aquí se seguirá la estructura de LFS 8.2
##III. Building the LFS System
##6. Installing Basic System Software
##(ya estará hecho Adjusting the Toolchain) seguir con 6.11 en adelante

#control_flujo
./ibasicsyssw41_file.sh $VER_file gz
./ibasicsyssw42_file.sh $VER_file gz

##Siguiente según LFS, readline, sin embargo, por una cuestión de dependencias
##parece adecuado seguir con el orden de CLFS hasta Ncurses.

#No hay Sed para 32 bit sobre 64. Dejo el espacio para mantener las numeraciones
#impares para 32 bit.
#ibasicsyssw43_sed
./ibasicsyssw44_sed.sh $VER_sed xz

#ibasicsyssw45_pkg-config-lite
./ibasicsyssw46_pkg-config-lite.sh $VER_pkg gz

./ibasicsyssw47_ncurses.sh $VER_ncurses gz
./ibasicsyssw48_ncurses.sh $VER_ncurses gz

./ibasicsyssw49_readline.sh $VER_readline gz
./ibasicsyssw50_readline.sh $VER_readline gz

#ibasicsyssw51_bc
./ibasicsyssw52_bc.sh $VER_bc gz

#Al instalar el paquete en la host, le faltan las librerías de Flex.
#Construir paquete flex. La build ya tiene las librerías de 32 y 64
#por eso no dio problemas para construir bc en la build.

./ibasicsyssw53_bzip2.sh $VER_bzip2 gz
./ibasicsyssw54_bzip2.sh $VER_bzip2 gz
#Se genera también paquete qi

#6.24. Attr-2.4.47
#En CLFS no se instala. Pero voy a instalarlo, a que serán necesarias
#las librerías.
./ibasicsyssw55_attr.sh $VER_attr gz
./ibasicsyssw56_attr.sh $VER_attr gz

#6.25. Acl-2.2.52
#Ídem anterior
./ibasicsyssw57_acl.sh $VER_acl gz
./ibasicsyssw58_acl.sh $VER_acl gz

#6.26. Libcap-2.25
#Ídem anterior
./ibasicsyssw59_libcap.sh $VER_libcap xz
./ibasicsyssw60_libcap.sh $VER_libcap xz

#No se instala Shadow en 64 bit. Solo son porgramas, no contiene bibliotecas
#Por otro lado, el croos-compiler no está pensado para ser un OS 
#independiente. No necesita shadow.

#10.80. Psmisc-
./ibasicsyssw61_psmisc.sh $VER_psmisc xz

#10.42. Iana-Etc-2.30
./ibasicsyssw62_iana.sh $VER_iana bz2

#10.65. Grep-
./ibasicsyssw63_grep.sh $VER_grep xz

#Ahora toca bash  para 32 bit. ¿Hace falta en 64 bit de tools/bin/bash
#a un basr en /bin ?. Creo que se coplicaría hasta la ejecución de 
#este mismo programa. Lo pospongo.

#10.43. Libtool-
./ibasicsyssw64_libtool.sh $VER_libtool xz
./ibasicsyssw65_libtool.sh $VER_libtool xz

#10.48. GDBM-
./ibasicsyssw66_gdbm.sh $VER_gdbm gz
./ibasicsyssw67_gdbm.sh $VER_gdbm gz

#6.37. Gperf
#No está en CLFS. No genera bibliotecas --> Lo instalo solo en 64 bit
./ibasicsyssw68_gperf.sh $VER_gperf gz

#6.38. Expat-
#No está en CLFS. Genera bibliotecas --> Lo instalo en 32 y 64 bit
./ibasicsyssw69_expat.sh $VER_expat bz2
./ibasicsyssw70_expat.sh $VER_expat bz2


#6.39. Inetutils
#No está en CLFS. No genera bibliotecas --> Lo instalo solo en 64 bit
./ibasicsyssw71_inetutils.sh $VER_inetutils xz

#6.41. XML::Parser
#No está en CLFS. Genera module de perl?  --> Lo instalo en 32? y 64 bit ??
#La duda es si el sistema en la build machine para compilar otros paquetes
#de 32 bit va a nacesitar esa module como 32 bit.
#
#Problema. 
#10.50. Perl-5.20.0 32 Bit Libraries
#10.51. Perl-5.20.0 64 Bit
#No quería reinstalar Perl, pero me temo que algo habrá que hacer...No. No se instala
#De momento tengo un Perl instaldo en tools desde el principio que funciona
#bien. Por cierto, se compiló como 32 bit (pero funciona en 64).

#instalaré XML::Parser en:
# perldoc -l File::Basename
#/tools/lib/perl5/5.26.1/File/Basename.pm
#el prefix es /tools

./ibasicsyssw72_xml-parser.sh $VER_xmlparser gz


#6.42. Intltool-
#Solo hay programas. No hay librerías.Solo instalo version 64 bit
./ibasicsyssw73_intltool.sh $VER_intltool gz

#6.43. Autoconf-
#Solo hay programas. No hay librerías.Solo instalo version 64 bit
./ibasicsyssw74_autoconf.sh $VER_autoconf xz

#6.44. Automake-
./ibasicsyssw75_automake.sh $VER_automake xz

#10.75. XZ Utils- 32 Bit Libraries
./ibasicsyssw76_xz.sh $VER_xz xz
./ibasicsyssw77_xz.sh $VER_xz xz

#10.77. Kmod-
./ibasicsyssw78_kmod.sh $VER_kmod xz
./ibasicsyssw79_kmod.sh $VER_kmod xz

#10.63. Gettext-
./ibasicsyssw80_gettext.sh $VER_gettext xz
./ibasicsyssw81_gettext.sh $VER_gettext xz

#6.48. Libelf-
./ibasicsyssw82_libelf.sh $VER_libelf bz2
./ibasicsyssw83_libelf.sh $VER_libelf bz2

#Tiny CC Compiler
./ibasicsyssw84_tcc.sh $VER_tcc bz2

#6.49. Libffi
#Solo son librerias y headers. No hay programas.
./ibasicsyssw85_libffi.sh $VER_libffi gz
./ibasicsyssw86_libffi.sh $VER_libffi gz

#6.50. OpenSSL
./ibasicsyssw87_openssl.sh $VER_openssl gz
./ibasicsyssw88_openssl.sh $VER_openssl gz


#6.51. Python-3
##./ibasicsyssw89_Python.sh $VER_Python xz
./ibasicsyssw90_Python.sh $VER_Python xz

#6.52. Ninja-
./ibasicsyssw91_ninja.sh $VER_ninja gz

#6.53. Meson
./ibasicsyssw92_meson.sh $VER_meson gz
#Pasa como en Python. No hay opción a multilib.

#6.54. Procps-ng-
./ibasicsyssw93_procps-ng.sh $VER_procps xz
./ibasicsyssw94_procps-ng.sh $VER_procps xz


#Se adelanta la instalación de Util-linux. Esto es debido a que la versión
#en 32 bit de E2fsprogs requiere libuuid, que solo está en /tools/64.
#Aunque se ajusten los paths, LIBS, etc para que encuentre la librería
#el porblema persiste. O bien no enuentra libuuid en /tools/lib (lógicamente
#ya ue no esté instalado ahí) o si cambiamos a /tools/lib64, lo encentra
#pero portesta por ser una versión incompatible.
#Voy a probar a instalar ya en el definitibo /lib util-linux, previsto
#para más adelante.

#De hecho ese es el orden previsto en CLFS. Efectivamente. Así funciona.

#6.73. Util-linux- /  10.35. Util-linux- 32 bit / 10.36. 64 Bit
./ibasicsyssw95_util-linux.sh $VER_util_linux xz
./ibasicsyssw96_util-linux.sh $VER_util_linux xz

#6.55. E2fsprogs- CLF 10.39
./ibasicsyssw97_e2fsprogs.sh $VER_e2fsprogs gz
./ibasicsyssw98_e2fsprogs.sh $VER_e2fsprogs gz

#6.56. Coreutils-
./ibasicsyssw99_coreutils.sh $VER_coreutils xz

#6.59. Gawk-
./ibasicsyssw103_gawk.sh $VER_gawk xz
./ibasicsyssw104_gawk.sh $VER_gawk xz


#6.57. Check-
#Primero es necesaro que esté gaw, ya que si no, check coge el 
#/tools/gawk
./ibasicsyssw100_check.sh $VER_check gz
./ibasicsyssw101_check.sh $VER_check gz

#6.58. Diffutils-
#Solo tiene programas. No tiene librerías. Se instala solo 64 bit
./ibasicsyssw102_diffutils.sh $VER_diffutils xz

#6.59. Gawk-
./ibasicsyssw103_gawk.sh $VER_gawk xz
./ibasicsyssw104_gawk.sh $VER_gawk xz


#6.60. Findutils-
#Solo tiene programas. No tiene librerías. Se instala solo 64 bit
./ibasicsyssw105_findutils.sh $VER_findutils gz

#6.61. Groff-
#Solo tiene programas. No tiene librerías. Se instala solo 64 bit
./ibasicsyssw106_groff.sh $VER_groff gz

#6.62. GRUB-
#Solo tiene programas. No tiene librerías. Se instala solo 64 bit
./ibasicsyssw107_grub.sh $VER_grub xz


#6.63. Less
#Solo tiene programas. No tiene librerías. Se instala solo 64 bit
./ibasicsyssw108_less.sh $VER_less gz

#6.64. Gzip
#Solo tiene programas. No tiene librerías. Se instala solo 64 bit
./ibasicsyssw109_gzip.sh $VER_gzip xz

#6.65. IPRoute2-
./ibasicsyssw110_iproute2.sh $VER_iproute2 xz

#10.70. Kbd-
./ibasicsyssw112_kbd.sh $VER_kbd xz

#6.67. Libpipeline
./ibasicsyssw113_libpipeline.sh $VER_libpipeline gz
./ibasicsyssw114_libpipeline.sh $VER_libpipeline gz

#6.68. Make-
./ibasicsyssw115_make.sh $VER_make gz

#6.69. Patch
./ibasicsyssw116_patch.sh $VER_patch xz

#6.70. Sysklogd-
./ibasicsyssw117_sysklogd.sh $VER_sysklogd gz

#6.71. Sysvinit-
./ibasicsyssw118_sysvinit.sh $VER_sysvinit bz2

#6.72. Eudev-
./ibasicsyssw119_eudev.sh $VER_eudev gz
./ibasicsyssw120_eudev.sh $VER_eudev gz

#6.74. Man-DB-
./ibasicsyssw121_man-db.sh $VER_man_db xz
./ibasicsyssw122_man-db.sh $VER_man_db xz

#6.75. Tar-1
./ibasicsyssw123_tar.sh $VER_tar xz

#6.76. Texinfo-
./ibasicsyssw124_texinfo.sh $VER_texinfo xz
./ibasicsyssw125_texinfo.sh $VER_texinfo xz

echo -e "
#############################\n\
#  terminado con exito      #\n\
#  successfully finised     #\n\
#############################\n"

