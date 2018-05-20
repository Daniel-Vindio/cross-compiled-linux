# 10.8.2. Internationalization, locales y archivos de configuración GLIBC

T_COMIENZO=$(date +"%T")	#para calcular el tiempo de instalación

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


if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

#---------------INSTALACIÓN DE ARCHVOS DE CONFGURACION------------------
echo -e "\nInstalacion 10.8.2. Internationalization GLIBC" >> $FILE_BITACORA


#10.8.2. Internationalization 

mkdir -pv /usr/lib/locale
registro_error "mkdir -pv /usr/lib/locale"

localedef -i es_ES -f ISO-8859-1 es_ES
registro_error "localedef -i es_ES -f ISO-8859-1 es_ES"

localedef -i es_ES@euro -f ISO-8859-15 es_ES@euro
registro_error "localedef -i es_ES@euro -f ISO-8859-15 es_ES@euro"

localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i ja_JP -f EUC-JP ja_JP


##10.8.3. Configuring Glibc 
cat > /etc/nsswitch.conf << "EOF"
 Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF
registro_error "/etc/nsswitch.conf"

#En este script no está time zone


#10.8.4. Configuring The Dynamic Loader 

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf

/usr/local/lib
/usr/local/lib64
/opt/lib
/opt/lib64

# End /etc/ld.so.conf
EOF
registro_error "/etc/ld.so.conf"


######------------------------------------------------------------------

#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA
