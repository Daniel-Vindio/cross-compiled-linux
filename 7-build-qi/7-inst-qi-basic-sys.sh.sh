#!/bin/bash

echo -e "
############################################################\n\
#$0\n\
############################################################\n"

proc_root=$(ls -id / | cut -d " " -f1)
[ $proc_root == "2" ] && echo "Debe hacerse en chroot / must be chroot" \
&& exit 1

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

function registro_error () {
#Función para registrar errores y resultados en la bitaćora
if [ $? -ne 0 ]
then
	MOMENTO=$(date)
	echo $MSG_ERR
	echo "$MOMENTO $nombre <$1> -> ERROR" >> $FILE_QILOG
#	exit 1
else
	MOMENTO=$(date)
	echo "$MOMENTO $nombre <$1> -> Conforme" >> $FILE_QILOG
fi
}

cd /home

paquetes="acl-2.2.53-i686+1.tlz \
attr-2.4.48-i686+1.tlz \
autoconf-2.69-i686+1.tlz \
automake-1.15.1-i686+1.tlz \
bash-4.4.18-i686+1.tlz \
bc-1.07.1-i686+1.tlz \
binutils-2.30-i686+1.tlz \
bison-3.0.4-i686+1.tlz \
bzip2-1.0.6-i686+1.tlz \
check-0.12.0-i686+1.tlz \
coreutils-8.30-i686+1.tlz \
diffutils-3.6-i686+1.tlz \
e2fsprogs-1.43.9-i686+1.tlz \
eudev-3.2.5-i686+1.tlz \
expat-2.2.5-i686+1.tlz \
file-5.32-i686+1.tlz \
findutils-4.6.0-i686+1.tlz \
flex-2.6.4-i686+1.tlz \
gawk-4.2.0-i686+1.tlz \
gdbm-1.15-i686+1.tlz \
gettext-0.19.8.1-i686+1.tlz \
glibc-2.27-i686+1.tlz \
gmp-6.1.2-i686+1.tlz \
gperf-3.1-i686+1.tlz \
gpm-1.20.7-i686+1.tlz \
grep-3.1-i686+1.tlz \
groff-1.22.3-i686+1.tlz \
grub-2.02-i686+1.tlz \
gzip-1.9-i686+1.tlz \
iana-etc-2.30-i686+1.tlz \
inetutils-1.9.4-i686+1.tlz \
intltool-0.51.0-i686+1.tlz \
iproute2-4.15.0-i686+1.tlz \
kbd-2.0.4-i686+1.tlz \
kmod-25-i686+1.tlz \
less-530-i686+1.tlz \
libcap-2.25-i686+1.tlz \
libelf-0.170-i686+1.tlz \
libffi-3.2.1-i686+1.tlz \
libpipeline-1.5.0-i686+1.tlz \
libtool-2.4.6-i686+1.tlz \
linux-4.17-i686+1.tlz \
m4-1.4.18-i686+1.tlz \
make-4.2.1-i686+1.tlz \
man-db-2.8.1-i686+1.tlz \
man-pages-4.15-i686+1.tlz \
mpc-1.1.0-i686+1.tlz \
mpfr-4.0.1-i686+1.tlz \
ncurses-6.1-i686+1.tlz \
openssl-1.1.0g-i686+1.tlz \
patch-2.7.6-i686+1.tlz \
procps-ng-3.3.12-i686+1.tlz \
psmisc-23.1-i686+1.tlz \
readline-7.0-i686+1.tlz \
sed-4.4-i686+1.tlz \
shadow-4.6-i686+1.tlz \
sysklogd-1.5.1-i686+1.tlz \
sysvinit-2.88dsf-i686+1.tlz \
tar-1.30-i686+1.tlz \
tcc-0.9.27-i686+1.tlz \
texinfo-6.5-i686+1.tlz \
tzdata-2018d-i686+1.tlz \
util-linux-2.31.1-i686+1.tlz \
xz-5.2.3-i686+1.tlz \
zlib-1.2.11-i686+1.tlz"

FILE_QILOG="/home/qi-build.log"

for i in $paquetes; do
	echo -e "\nqi -b $i" >> $FILE_QILOG
	qi -d $i
	registro_error $i
done

for i in $paquetes; do
	echo -e "\nqi -b $i" >> $FILE_QILOG
	qi -i $i
	registro_error $i
done
