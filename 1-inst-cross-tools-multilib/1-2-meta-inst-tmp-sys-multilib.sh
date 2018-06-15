#!/bin/bash -e

echo -e "
############################################################\n\
#$0\n\
############################################################\n"

./imultilib16_gmp.sh 		$VER_gmp 		xz
./imultilib17_mpfr.sh 		$VER_mpfr 		xz
./imultilib18_mpc.sh 		$VER_mpc 		gz
#./imultilib19_isl.sh 		$VER_isl 		gz
#./imultilib20_cloog.sh 		$VER_cloog 		gz
./imultilib21_zlib.sh		$VER_zlib		xz
./imultilib22_binutils.sh	$VER_binutils 	gz
./imultilib23_gcc.sh		$VER_gcc		gz
./imultilib24_ncurses.sh 	$VER_ncurses 	gz
./imultilib25_bash.sh 		$VER_bash		gz
./imultilib26_bzip2.sh 		$VER_bzip2 		gz
./imultilib27_check.sh 		$VER_check 		gz
./imultilib28_coreutils.sh 	$VER_coreutils	xz
./imultilib29_diffutils.sh 	$VER_diffutils 	xz
./imultilib30_file.sh 		$VER_file 		gz
./imultilib31_findutils.sh	$VER_findutils	gz
./imultilib32_gawk.sh 		$VER_gawk 		xz
./imultilib33_gettext.sh 	$VER_gettext 	xz
./imultilib34_grep.sh 		$VER_grep 		xz
./imultilib35_gzip.sh 		$VER_gzip	 	xz
./imultilib36_make.sh 		$VER_make 		gz
./imultilib37_patch.sh 		$VER_patch 		xz
./imultilib38_sed.sh 		$VER_sed 		xz
./imultilib39_tar.sh 		$VER_tar 		xz
##./imultilib40_texinfo.sh 	$VER_texinfo 	xz	#Impossible to install now
./imultilib41_util-linux.sh	$VER_util_linux xz
##./imultilib42_vim.sh 		$VER_vim 		bz2	#Impossible to install now
./imultilib43_xz.sh 		$VER_xz 		xz


echo -e "
############################################################\n\
#$0\n\
############################################################\n"
echo -e "
#############################\n\
#  terminado con exito      #\n\
#  successfully finised     #\n\
#############################\n"
