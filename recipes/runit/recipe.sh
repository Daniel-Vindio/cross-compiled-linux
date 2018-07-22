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

#Replacing sysvinit
mkdir -v -p ${destdir}/etc/runit

#Step 1: The three stages
#Copio los mios, no los de muestra,aportados por el programa.
cp -p /home/runit/[123] ${destdir}/etc/runit/
cp -p /home/runit/ctrlaltdel ${destdir}/etc/runit/


mkdir -v -p ${destdir}/etc/sv/
cp -pvR /home/runit/sv/getty-1 ${destdir}/etc/sv/getty-1


#Step 2: The runit programs
mkdir -v -p ${destdir}/sbin
cp -vp /package/admin/runit/command/runit* ${destdir}/sbin/

#Step 3: The getties
mkdir -v -p ${destdir}/service
ln -vs ${destdir}/etc/sv/getty-5 ${destdir}/service/


hasta aquí fuciona.
Ver qué pasa con la instalación de los ejecutables de rnunit en /command
hace falta poner de acuerdo a el PATH de /etc/runit/2 para que encuentre
runsvdir



}
