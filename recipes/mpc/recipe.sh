program="mpc"
version="$VER_mpc"
release="1"
arch="i686"

tarname=${program}-${version}.tar.gz

description="

GNU MPC is a C library for the arithmetic of complex numbers with 
arbitrarily high precision and correct rounding of the result. It 
extends the principles of the IEEE-754 standard for fixed precision 
real floating point numbers to complex numbers, providing well-defined 
semantics for every operation. At the same time, speed of operation at 
high precision is a major design goal. 
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
--disable-static \
--docdir=/usr/share/doc/mpc-$version \
--host=${CLFS_TARGET32}

make

make html

make check 2>&1 | tee $FILE_CHECKS

make install DESTDIR=${destdir}

make install-html DESTDIR=${destdir}

}











