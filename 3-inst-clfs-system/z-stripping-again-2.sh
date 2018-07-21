#!/bin/bash

echo -e "
############################################################\n\
#$0\n\
############################################################\n"

#6.79. Stripping Again


#You must be root.
if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

# Solo puede ser desde chroot
proc_root=$(ls -id / | cut -d " " -f1)
[ $proc_root == "2" ] && echo "Debe hacerse en chroot / must be chroot" \
&& exit 1

/tools/bin/find /usr/lib -type f -name \*.a -exec /tools/bin/strip --strip-debug {} ';'
/tools/bin/find /lib /usr/lib -type f \( -name \*.so* -a ! -name \*dbg \) -exec /tools/bin/strip --strip-unneeded {} ';'
/tools/bin/find /{bin,sbin} /usr/{bin,sbin,libexec} -type f -exec /tools/bin/strip --strip-all {} ';'
