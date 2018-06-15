program="linux"
version="$VER_linux"
release="1"
arch="i686"

tarname=${program}-${version}.tar.xz

description="
Kernel headers
     
---
"


build() {

unpack "${tardir}/$tarname"

cd "$srcdir"

make mrproper

make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete

mkdir -vp ${destdir}/usr/include/
cp -rv dest/include/* ${destdir}/usr/include/


}
