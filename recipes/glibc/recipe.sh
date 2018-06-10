program="glibc"
version="$VER_glibc"
release="1"
arch="i686"

tarname=${program}-${version}.tar.xz

description="
The GNU C Library project provides the core libraries for the GNU 
system and GNU/Linux systems, as well as many other systems that use 
Linux as the kernel. These libraries provide critical APIs including 
ISO C11, POSIX.1-2008, BSD, OS-specific APIs and more. These APIs 
include such foundational facilities as open, read, write, malloc, 
printf, getaddrinfo, dlopen, pthread_create, crypt, login, exit and more. 
---
"

build() {

function registro_error () {
#Función para registrar errores y resultados en la bitaćora
if [ $? -ne 0 ]
then
	MOMENTO=$(date)
	echo $MSG_ERR
	echo "$MOMENTO $nombre <$1> -> ERROR" >> $FILE_BITACORA
	exit 1
else
	MOMENTO=$(date)
	echo "$MOMENTO $nombre <$1> -> Conforme" >> $FILE_BITACORA
fi
}

unpack "${tardir}/$tarname"
cd "$srcdir"

echo -e "\nInstalacion de $srcdir 32 Bit" >> $FILE_BITACORA

patch -Np1 -i ${tardir}/glibc-2.27-fhs-1.patch
registro_error "patch -Np1 -i ../glibc-2.27-fhs-1.patch"

ln -sfv /tools/lib/gcc /usr/lib
registro_error "ln -sfv /tools/lib/gcc /usr/lib"

#GCC_INCDIR=/usr/lib/gcc/${CLFS_TARGET32}/${VER_gcc}/include
#Desgraciadamente, este no existe. lo quito del CC=

ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3
registro_error "ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3"

rm -f /usr/include/limits.h
registro_error "rm -f /usr/include/limits.h"

if [ -d "build" ] ; then
	rm -rv "build"
fi

mkdir build
cd build

CC="gcc ${BUILD32} -isystem /usr/include" \
CXX="g++ ${BUILD32}" \
../configure \
--prefix=/usr \
--host=${CLFS_TARGET32} \
--enable-kernel=4.10 \
--enable-stack-protector=strong \
--disable-werror \
libc_cv_slibdir=/lib
registro_error $MSG_CONF

#--libexecdir=/usr/lib/glibc \
#unset GCC_INCDIR

make
registro_error $MSG_MAKE

#sed -i '/cross-compiling/s@ifeq@ifneq@g' ../localedata/Makefile
#make check 2>&1 | tee $FILE_CHECKS; grep Error $FILE_CHECKS

touch ${destdir}/etc/ld.so.conf

sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install DESTDIR=${destdir}
registro_error $MSG_INST

#rm -v ${destdir}/usr/include/rpcsvc/*.x
#No existe
#registro_error "rm -v ${destdir}/usr/include/rpcsvc/*.x"

cp -v ../nscd/nscd.conf ${destdir}/etc/nscd.conf
registro_error "cp -v ../nscd/nscd.conf ${destdir}/etc/nscd.conf"

#Lo llevo a 3-1
#mkdir -pv ${destdir}/var/cache/nscd
#registro_error "mkdir -pv ${destdir}/var/cache/nscd"

unlink /usr/lib/gcc
unlink /lib/ld-lsb.so.3

}











