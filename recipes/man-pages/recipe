program="man-pages"
version="$VER_man_pages"
release="1"
arch="i686"

tarname=${program}-${version}.tar.xz

description="
The Man-pages package contains over 2,200 man pages. 
     
man pages
Describe C programming language functions, important device files, and \
significant configuration files 
"


build() {

unpack "${tardir}/$tarname"

cd "$srcdir"

make install DESTDIR=$destdir

}
