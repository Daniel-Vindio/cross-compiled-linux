program="gmp"
version="6.0.0"
release="1"
arch="i686"

tarname=${program}-${version}.tar.xz

description="


GMP is a free library for arbitrary precision arithmetic, operating on 
signed integers, rational numbers, and floating-point numbers. There is 
no practical limit to the precision except the ones implied by the 
available memory in the machine GMP runs on. GMP has a rich set of 
functions, and the functions have a regular interface.

The main target applications for GMP are cryptography applications and 
research, Internet security applications, algebra systems, computational
algebra research, etc. 
---
"

build() {

. /home/0-variables-build-flags

unpack "${tardir}/$tarname"
cd "$srcdir"

echo -e "\nInstalacion de $srcdir 32 Bit"

# It avoids optimization (not possible in cross compiling)
mv -v config{fsf,}.guess
mv -v config{fsf,}.sub

CC="gcc -isystem /usr/include ${BUILD32}" \
CXX="g++ -isystem /usr/include ${BUILD32}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib ${BUILD32}" \
ABI=32 \
./configure \
--prefix=/usr \
--disable-static \
--enable-cxx \
--docdir=/usr/share/doc/gmp-$version

make

make html

make install DESTDIR=${destdir}

make install-html DESTDIR=${destdir}

}











