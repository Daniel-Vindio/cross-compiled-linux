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

./ibasicsyssw25_isl.sh $VER_isl gz
./ibasicsyssw26_isl.sh $VER_isl gz

./ibasicsyssw27_cloog.sh $VER_cloog gz
./ibasicsyssw28_cloog.sh $VER_cloog gz

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
#control_flujo


echo -e "
#############################\n\
#  terminado con exito      #\n\
#  successfully finised     #\n\
#############################\n"

