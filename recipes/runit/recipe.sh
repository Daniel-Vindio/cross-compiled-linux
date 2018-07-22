program="runit"
version="$VER_runit"
release="1"
arch="i686"

#tarname=${program}-${version}.tar.gz
tarname=${program}-${version}.tar

description="
runit is a cross-platform Unix init scheme with service supervision, 
a replacement for sysvinit, and other init schemes. 
---
"


build() {

#mkdir: created directory '/usr/src/qi/build/package-runit'
#Este es el DESTDIR

cd ${destdir}
echo -e "1 estoy en $PWD----------------\n"

mkdir -v -p ${destdir}/package
chmod -v 1755 ${destdir}/package
cd ${destdir}/package
echo -e "2 estoy en $PWD----------------\n"

gunzip ${tardir}/$tarname
tar -xpf ${tardir}/$tarname
#rm runit-2.1.2.tar

cd admin/${program}-${version}
echo -e "2 estoy en $PWD-- y debería estar en admin/runit-2.1.2 \n"

echo 'gcc -m32' >src/conf-cc
echo 'gcc -m32 -s' >src/conf-ld

package/install

mkdir -v -p ${destdir}/etc/runit

cp -p /home/runit/[123] ${destdir}/etc/runit/
cp -p /home/runit/ctrlaltdel ${destdir}/etc/runit/

******Hay que seguir con las carpetas del sv.
Ver si hay que copiar las carpetas supervise.


}
