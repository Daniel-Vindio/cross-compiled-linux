program="attr"
version="$VER_attr"
release="1"
arch="i686"

tarname=${program}-${version}.tar.gz

description="

Commands for Manipulating Filesystem Extended Attributes
---
"

build() {

. /home/0-var-chroot-rc

unpack "${tardir}/$tarname"
cd "$srcdir"

echo -e "\n Creación paquete Qi $program para 32 bit" >> $FILE_BITACORA

sed -i 's:{(:\\{(:' test/run
registro_error "sed"

CC="gcc ${BUILD32}" \
CXX="g++ ${BUILD32}" \
./configure \
--prefix=/usr \
--libdir=/lib \
--bindir=/bin \
--disable-static

make

make -j1 check 2>&1 | tee $FILE_CHECKS

make DESTDIR=${destdir} install
}











