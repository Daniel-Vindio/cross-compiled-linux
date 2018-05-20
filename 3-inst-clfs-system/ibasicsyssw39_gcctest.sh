# Tests for GCC


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

function registro_error2 () {
#Función para registrar errores y resultados en la bitaćora
if [ -z "$1" ]
then
	MOMENTO=$(date)
	echo $MSG_ERR
	echo "$MOMENTO Toolchain <$1> -> ERROR" >> $FILE_BITACORA
	exit 1
else
	MOMENTO=$(date)
	echo "$MOMENTO <$1> -> Conforme" >> $FILE_BITACORA
fi
}


if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi


#----------------------CONFIGURE - MAKE - MAKE INSTALL------------------
echo -e "\nGCC Tests" >> $FILE_BITACORA

echo 'main(){}' > dummy.c
gcc ${BUILD32} dummy.c
readelf -l a.out | grep ': /lib' > /tmp/dum_test
resultado=$(cat /tmp/dum_test)
echo $resultado
registro_error2 "$resultado"

#to test also if cc --> gcc
echo 'main(){}' > dummy.c
cc ${BUILD64} dummy.c
readelf -l a.out | grep ': /lib' > /tmp/dum_test
resultado=$(cat /tmp/dum_test)
echo $resultado
registro_error2 "$resultado"

echo 'int main(){}' > dummy.c
gcc ${BUILD32} dummy.c -v -Wl,--verbose &> /tmp/dum_test

grep -o '/usr/lib.*/crt[1in].*succeeded' /tmp/dum_test
grep -B4 '^ /tools/include' /tmp/dum_test
grep -B4 '^ /usr/include' /tmp/dum_test
grep 'SEARCH.*/lib' /tmp/dum_test |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " /tmp/dum_test
grep found /tmp/dum_test
rm -v dummy.c a.out /tmp/dum_test


echo 'int main(){}' > dummy.c
gcc ${BUILD64} dummy.c -v -Wl,--verbose &> /tmp/dum_test

grep -o '/usr/lib.*/crt[1in].*succeeded' /tmp/dum_test
grep -B4 '^ /tools/include' /tmp/dum_test
grep -B4 '^ /usr/include' /tmp/dum_test
grep 'SEARCH.*/lib' /tmp/dum_test |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " /tmp/dum_test
grep found /tmp/dum_test


rm -v dummy.c a.out /tmp/dum_test

cat > dummy.c << "EOF"
#include <stdio.h>

int main (void){
	printf("¡Hola majetes!\n");
	return 0;
}
EOF
echo "----"
gcc ${BUILD64} dummy.c -v -Wl,--verbose &> /tmp/dum_test

grep -o '/usr/lib.*/crt[1in].*succeeded' /tmp/dum_test
grep -B4 '^ /tools/include' /tmp/dum_test
grep -B4 '^ /usr/include' /tmp/dum_test
grep 'SEARCH.*/lib' /tmp/dum_test |sed 's|; |\n|g'
grep "/lib.*/libc.so.6 " /tmp/dum_test
grep found /tmp/dum_test
echo "----"
./a.out
rm -v dummy.c a.out /tmp/dum_test


