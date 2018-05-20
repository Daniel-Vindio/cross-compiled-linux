#!/tools/bin/bash -e
#OJO esto es porque en chroot bash no está en /bin todavía
#We need bash in tools, because in chroot bash has not been created yet.

#This script is used only once, when creating the file system directories
#Este script se usa solo una vez, al crear los directorios del sistema
# de archivos

control_flujo () {
	echo "Continue? To exit press N"
	read CS
	if [ "$CS" == "N" ]
		then
			echo "exit"
			exit
	fi
}

if [ $(id -u) -ne 0 ]; then 
	echo -e "Ur not root bro"
	echo -e "Tines que ser root, tío"
	exit 1
fi


#8.5. Creating Directories 
#Los directorios se crean desde chroot
# Directories are created from chroot

proc_root=$(ls -id / | cut -d " " -f1)
[ $proc_root == "2" ] && echo "Debe hacerse en chroot / must be chroot" \
&& exit 1

#mkdir -pv /{bin,boot,dev,{etc/,}opt,home,lib{,64},mnt}
mkdir -pv /{bin,boot,dev,{etc/,}opt,lib{,64},mnt}
mkdir -pv /{proc,media/{floppy,cdrom},run/{,shm},sbin,srv,sys}
mkdir -pv /var/{lock,log,mail,spool}
mkdir -pv /var/{opt,cache,lib{,64}/{misc,locate},local}
#control_flujo

install -dv /root -m 0750
install -dv {/var,}/tmp -m 1777
#control_flujo

ln -sv ../run /var/run
#control_flujo

mkdir -pv /usr/{,local/}{bin,include,lib{,64},sbin,src}
mkdir -pv /usr/{,local/}share/{doc,info,locale,man}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}share/man/man{1..8}
#control_flujo

install -dv /usr/lib/locale
#control_flujo

ln -sv ../lib/locale /usr/lib64
#control_flujo

#8.6. Creating Essential Files and Symlinks 
ln -sv /tools/bin/{bash,cat,echo,grep,pwd,stty} /bin
#control_flujo

ln -sv /tools/bin/file /usr/bin
#control_flujo

ln -sv /tools/lib/libgcc_s.so{,.1} /usr/lib
#control_flujo

ln -sv /tools/lib64/libgcc_s.so{,.1} /usr/lib64
#control_flujo

ln -sv /tools/lib/libstd* /usr/lib
#control_flujo

ln -sv /tools/lib64/libstd* /usr/lib64
#control_flujo

ln -sv bash /bin/sh
#control_flujo
