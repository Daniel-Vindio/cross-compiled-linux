#!/bin/bash -e

#-----------------------------------------------------------------------
#Installation of the cross-tool required before building the temporary
#system
#Variables in variables-inst-cross-tools-multilib are required
#-----------------------------------------------------------------------

echo -e "
############################################################\n\
#$0\n\
############################################################\n"

./imultilib1_file.sh 		$VER_file 	gz
./imultilib2_linux.sh 		$VER_linux 	xz
./imultilib3_m4.sh 			$VER_m4 	xz
./imultilib4_ncurses.sh 	$VER_ncurses gz
./imultilib5_pkg-config-lite.sh $VER_pkg gz
./imultilib6_gmp.sh 		$VER_gmp 	xz
./imultilib7_mpfr.sh 		$VER_mpfr 	xz
./imultilib8_mpc.sh 		$VER_mpc 	gz
##No needed anymore. I keep them as a curiosity.
##./imultilib9_isl.sh 		$VER_isl 	gz
##./imultilib10_cloog.sh 		$VER_cloog 	gz

##Via GLIBC
####./imultilib11_binutils.sh 	$VER_binutils gz
####./imultilib12_gcc.sh		$VER_gcc	gz
####./imultilib13_glibc.sh 		$VER_glibc	xz
####./imultilib14_glibc.sh 		$VER_glibc	xz
####./imultilib15_gcc.sh		$VER_gcc	gz

##Via MUSL
./imusl44_binutils.sh 	$VER_binutils gz
./imusl45_gcc.sh		$VER_gcc	gz
./imusl46_musl.sh		$VER_musl	gz
./imusl47_gcc.sh		$VER_gcc	gz


echo -e "
############################################################\n\
#$0\n\
############################################################\n"
echo -e "
#############################\n\
#  terminado con exito      #\n\
#  successfully finised     #\n\
#############################\n"




