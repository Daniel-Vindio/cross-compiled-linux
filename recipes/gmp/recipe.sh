program="gmp"
version="$VER_gmp"
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

. /home/0-var-chroot-rc

unpack "${tardir}/$tarname"
cd "$srcdir"

echo -e "\n Creación paquete Qi $program para 32 bit" >> $FILE_BITACORA

# It avoids optimization (not possible in cross compiling)
mv -v config{fsf,}.guess
mv -v config{fsf,}.sub

#Estaba así de antes. No sé si es que con el isystem no funcionaba..
#Pruebo de nuevo como lo porpone CLFS
#CC="gcc ${BUILD32}" \
#CXX="g++ ${BUILD32}" \
#Parece que le sienta mal g++ -isystem /usr/include
#Pero solo en g++. Si se deja en cc no pasa nada.

#si pong g++ -isystem /tools/include ${BUILD32} no hay porblema
#algo pasa a 
#checking whether g++ -isystem /usr/include -m32 accepts -g... yes
#checking C++ compiler g++ -isystem /usr/include -m32  -m32 -O2 -pedantic -fomit-frame-pointer -mtune=corei7 -march=corei7... no, std iostream
#checking C++ compiler g++ -isystem /usr/include -m32  -g -O2... no, std iostream
#configure: error: C++ compiler not available, see config.log for details

#según config.log
#/usr/include/c++/8.1.0/cstdlib:75:15: fatal error: stdlib.h: No such file or directory
#Pero sí que está en /tools/include y en /usr/include
#voy a porbar a quitarle al configure el test
#configure:10199: g++ -isystem /usr/include -m32  -g -O2 conftest.cc >&5
#no funciona.
#Solución. 
#O uso -isystem /tools/include en g++ haré esto
#O quito -isystem /usr/include en g++
#O reinstalo stdlib.h

CC="gcc -isystem /usr/include ${BUILD32}" \
CXX="g++ -isystem /tools/include ${BUILD32}" \
LDFLAGS="-Wl,-rpath-link,/usr/lib:/lib ${BUILD32}" \
ABI=32 \
./configure \
--prefix=/usr \
--disable-static \
--enable-cxx \
--docdir=/usr/share/doc/gmp-$VER_gmp
registro_error $MSG_CONF

make
registro_error $MSG_MAKE

make html
registro_error "make html"

make -k check 2>&1 | tee $FILE_CHECKS

awk '/# PASS:/{total+=$3} ; END{print total}' $FILE_CHECKS

make install DESTDIR=${destdir}
registro_error $MSG_INST

make install-html DESTDIR=${destdir}
registro_error "make install-html DESTDIR=${destdir}"

}











