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

save_lib="ld-2.27.so libc-2.27.so libpthread-2.27.so libthread_db-1.0.so"
cd /lib
for LIB in $save_lib; do
	objcopy --only-keep-debug $LIB $LIB.dbg
	strip --strip-unneeded $LIB
	objcopy --add-gnu-debuglink=$LIB.dbg $LIB
done

save_usrlib="libquadmath.so.0.0.0 libstdc++.so.6.0.24
libmpx.so.2.0.1 libmpxwrappers.so.2.0.1 libitm.so.1.0.0
libcilkrts.so.5.0.0 libatomic.so.1.2.0"
cd /usr/lib

for LIB in $save_usrlib; do
	objcopy --only-keep-debug $LIB $LIB.dbg
	strip --strip-unneeded $LIB
	objcopy --add-gnu-debuglink=$LIB.dbg $LIB
done

unset LIB save_lib save_usrlib
