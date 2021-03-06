program="mpfr"
version="$VER_mpfr"
release="1"
arch="i686"

tarname=${program}-${version}.tar.xz

description="


The MPFR library is a C library for multiple-precision floating-point 
computations with correct rounding. MPFR has continuously been supported 
by the INRIA and the current main authors come from the Caramba and 
AriC project-teams at Loria (Nancy, France) and LIP (Lyon, France) 
respectively; see more on the credit page. MPFR is based on the GMP 
multiple-precision library.

The main goal of MPFR is to provide a library for multiple-precision 
floating-point computation which is both efficient and has a 
well-defined semantics. It copies the good ideas from the ANSI/IEEE-754 
standard for double-precision floating-point arithmetic 
(53-bit significand).
---
"

build() {

. /home/0-var-chroot-rc

unpack "${tardir}/$tarname"
cd "$srcdir"

echo -e "\n Creación paquete Qi $program para 32 bit" >> $FILE_BITACORA

CC="gcc -isystem /usr/include ${BUILD32}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib ${BUILD32}" \
./configure \
--prefix=/usr \
--host=${CLFS_TARGET32} \
--disable-static \
--enable-thread-safe \
--docdir=/usr/share/doc/mpfr-$version

make

make html

make -k check 2>&1 | tee $FILE_CHECKS

make install DESTDIR=${destdir}

make install-html DESTDIR=${destdir}

}











