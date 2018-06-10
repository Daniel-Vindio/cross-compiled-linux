program="m4"
version="$VER_m4"
release="1"
arch="i686"

tarname=${program}-${version}.tar.xz

description="

GNU M4 is an implementation of the traditional Unix macro processor. 
It is mostly SVR4 compatible although it has some extensions 
(for example, handling more than 9 positional parameters to macros). 
GNU M4 also has built-in functions for including files, running shell 
commands, doing arithmetic, etc.  
---
"

build() {

unpack "${tardir}/$tarname"
cd "$srcdir"

echo -e "\n Creación paquete Qi para 32 bit" >> $FILE_BITACORA

CC="gcc ${BUILD32}" \
./configure \
--prefix=/usr
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

make check 2>&1 | tee $FILE_CHECKS

make install DESTDIR=${destdir}
registro_error $MSG_INST

}











