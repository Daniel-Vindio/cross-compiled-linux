#!/tools/bin/bash -e

echo -e "
############################################################\n\
#$0\n\
############################################################\n"

control_flujo () {
	echo "Continue? To exit press N"
	read CS
	if [ "$CS" == "N" ]
		then
			echo "exit"
			exit
	fi
}

cd /home

. 0-var-chroot-musl-rc
. versiones.sh

./2-4-creacion-directorios.sh
./2-5-creacion-config-files.sh


########## LINUX, MUSL, BINUTILS GCC ET AL. ############################
# ----Testsuite Tools built in /tools ----------------------------------
./ibasicsyssw1_tcl.sh		$VER_tcl 	gz
./ibasicsyssw2_expect.sh 	$VER_expect gz
./ibasicsyssw3_dejagnu.sh 	$VER_dejagnu gz
./ibasicsyssw4_perl.sh 		$VER_perl 	gz
./ibasicsyssw5_texinfo.sh 	$VER_texinfo xz
./ibasicsyssw6_m4.sh 		$VER_m4 	xz
./ibasicsyssw7_bison.sh 	$VER_bison 	xz
#-----Programas de apoyo -----------------------------------------------
./ibasicsyssw13_man-pages.sh 	$VER_man_pages 	xz
./ibasicsyssw30_zlib.sh 		$VER_zlib xz
./ibasicsyssw42_file.sh 		$VER_file gz
./ibasicsyssw50_readline.sh 	$VER_readline gz
./ibasicsyssw18_m4.sh 			$VER_m4 	xz
./ibasicsyssw52_bc.sh 			$VER_bc gz
./ibasicsyssw130_help2man.sh 	$VER_help2man xz
./ibasicsyssw134_flex.sh 		$VER_flex	gz
#-----Kernel Headers ---------------------------------------------------
./ibasicsyssw12_linux.sh 		$VER_linux 	xz
#-----Libc MUSL --------------------------------------------------------
./ibasicsyssw14_musl.sh 		$VER_musl	gz
#-----Adjusting the Toolchain and TESTS --------------------------------
./ibasicsyssw16_adjust.sh
#-----BINUTILS ---------------------------------------------------------
export VER_binutils="2.31.1.dev010119"
./ibasicsyssw36_binutils.sh 	$VER_binutils gz
#-----GCC y programas de apoyo -----------------------------------------
./ibasicsyssw19_gmp.sh			$VER_gmp	xz
./ibasicsyssw22_mpfr.sh 		$VER_mpfr 	xz
./ibasicsyssw24_mpc.sh 			$VER_mpc 	gz
./ibasicsyssw38_gcc.sh 			$VER_gcc 	gz
./ibasicsyssw39_gcctest.sh

#******************* Resumen *******************************************
# Desde los instaladores 1, 2 y de la parte 3 hasta aquí mismo son el 
# compilador cruzado (Bisonte) propiamente dicho.
# A partir de aquí se genera el Sistema Mínimo - Básico con ls toolchain
# formada por LINUX, MUSL, BINUTILS GCC ET AL.

#******************* Asuntos Pedientes *********************************
#Analizar quién es y qué hace exactamete este nuevo gcc
#10.8.2. Internationalization / #10.8.3. Configuring Glibc excep time zone
#10.8.4. Configuring The Dynamic Loader 
#ibasicsyssw17_locales.sh
#----Problema, no hay programa localedef ya que es parte de Glib
#----y estamos instalando MUSL

########## GRAFT y Qi ##################################################
# Programs for package management: Graft and Qi
#Se instalan en /tools ¿Tiene sentido? Ahora no
#./ibasicsyssw8_lzip.sh 		$VER_lzip 	gz
#./ibasicsyssw9_unzip.sh 	$VER_unzip 	gz
#./ibasicsyssw10_graft.sh 	$VER_graft 	gz
#./ibasicsyssw11_qi.sh 		$VER_qi

########## SISTEMA #####################################################
./ibasicsyssw53_bzip2.sh 			$VER_bzip2 		gz
./ibasicsyssw46_pkg-config-lite.sh 	$VER_pkg 		gz
./ibasicsyssw48_ncurses.sh 			$VER_ncurses 	gz
./ibasicsyssw55_attr.sh 			$VER_attr 		gz
./ibasicsyssw58_acl.sh 				$VER_acl 		gz
./ibasicsyssw59_libcap.sh 			$VER_libcap 	xz
./ibasicsyssw44_sed.sh 				$VER_sed 		xz
./ibasicsyssw61_psmisc.sh 			$VER_psmisc 	xz
./ibasicsyssw62_iana.sh 			$VER_iana 		bz2
./ibasicsyssw33_bison.sh 			$VER_bison 		xz
./ibasicsyssw63_grep.sh 			$VER_grep 		xz
./ibasicsyssw126_bash.sh 			$VER_bash 		gz
./ibasicsyssw64_libtool.sh 			$VER_libtool 	xz
./ibasicsyssw66_gdbm.sh 			$VER_gdbm 		gz
./ibasicsyssw68_gperf.sh 			$VER_gperf 		gz
./ibasicsyssw69_expat.sh 			$VER_expat 		bz2
./ibasicsyssw71_inetutils.sh 		$VER_inetutils 	xz
./ibasicsyssw135_perl.sh 			$VER_perl 		gz
./ibasicsyssw72_xml-parser.sh 		$VER_xmlparser 	gz
./ibasicsyssw73_intltool.sh 		$VER_intltool 	gz
./ibasicsyssw74_autoconf.sh 		$VER_autoconf 	xz
./ibasicsyssw75_automake.sh 		$VER_automake 	xz
./ibasicsyssw76_xz.sh 				$VER_xz		 	xz
./ibasicsyssw79_kmod.sh 			$VER_kmod	 	xz
./ibasicsyssw80_gettext.sh 			$VER_gettext 	xz
./ibasicsyssw136_libuargp.sh 		$VER_libuargp 	xz
./ibasicsyssw82_libelf.sh 			$VER_libelf 	bz2
./ibasicsyssw86_libffi.sh 			$VER_libffi 	gz
#./ibasicsyssw87_openssl.sh 			$VER_openssl 	gz
./ibasicsyssw89_Python.sh 			$VER_Python 	xz
./ibasicsyssw91_ninja.sh 			$VER_ninja 		gz
./ibasicsyssw92_meson.sh 			$VER_meson 		gz
./ibasicsyssw93_procps-ng.sh 		$VER_procps 	xz
./ibasicsyssw97_e2fsprogs.sh 		$VER_e2fsprogs 	gz
./ibasicsyssw99_coreutils.sh 		$VER_coreutils 	xz
./ibasicsyssw100_check.sh 			$VER_check 		gz
./ibasicsyssw102_diffutils.sh 		$VER_diffutils 	xz
./ibasicsyssw103_gawk.sh 			$VER_gawk 		xz
./ibasicsyssw105_findutils.sh 		$VER_findutils 	gz
./ibasicsyssw106_groff.sh 			$VER_groff 		gz
./ibasicsyssw107_grub.sh 			$VER_grub 		xz
./ibasicsyssw108_less.sh 			$VER_less 		gz
./ibasicsyssw109_gzip.sh 			$VER_gzip 		xz
./ibasicsyssw110_iproute2.sh 		$VER_iproute2 	xz
./ibasicsyssw112_kbd.sh 			$VER_kbd 		xz
./ibasicsyssw114_libpipeline.sh 	$VER_libpipeline gz
./ibasicsyssw115_make.sh 			$VER_make 		bz2
./ibasicsyssw116_patch.sh 			$VER_patch 		xz
./ibasicsyssw117_sysklogd.sh 		$VER_sysklogd 	gz
./ibasicsyssw120_eudev.sh 			$VER_eudev 		gz
./ibasicsyssw96_util-linux.sh 		$VER_util_linux xz
./ibasicsyssw121_man-db.sh 			$VER_man_db 	xz
./ibasicsyssw123_tar.sh 			$VER_tar 		xz
./ibasicsyssw125_texinfo.sh 		$VER_texinfo 	xz
./ibasicsyssw126_vim.sh 			$VER_vim 		bz2
./ibasicsyssw131_shadow.sh 			$VER_shadow 	xz

#Para MUSL
./ibasicsyssw137_libressl.sh 		$VER_libressl 	gz

#-----Adicionales ------------------------------------------------------
./ibasicsyssw128_gpm.sh $VER_gpm bz2


########## 4 CONFIG FILES ##############################################
./4-inst-config-files.sh

########## 5 RUNIT #####################################################
./5-inst-runit.sh

########## 6 KERNEL ####################################################
./ibasicsyssw12k_linux.sh 		$VER_linux 	xz


########## ROOT PASWORD ################################################
clear
echo -e "============================================================\n"
echo "Aviso:"
echo "PON la contraseña para root"
echo ""
echo -e "============================================================\n"
passwd root

########## AVISOS ######################################################
echo -e "\n============================================================"
echo "Aviso"
echo "REVISAR achivos de configuración cargados por 4 CONFIG FILES"
echo ""
echo -e "============================================================\n"


echo -e "
#############################################################\n\
#Aplicación en progreso. Faltan más aplicaciones que instalar\n\
#############################################################\n"





