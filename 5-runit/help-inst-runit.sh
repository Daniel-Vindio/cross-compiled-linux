# Help to install runit with qi

#runit

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

control_flujo () {
	echo "Continue? To exit press N"
	read CS
	if [ "$CS" == "N" ]
		then
			echo "exit"
			exit
	fi
}

if [ $(id -u) -ne 0 ]
	then 
		echo -e "Ur not root bro"
		echo -e "Tines que ser root, tío"
	exit 1
fi

#---------------------------------------

qi -dp runit-$VER_runit-i686+1.tlz
qi -i runit-$VER_runit-i686+1.tlz

commands="chpst runit runit-init runsv runsvchdir runsvdir sv svlogd utmpset"

for i in $commands; do
	ln -svf /usr/pkg/runit-$VER_runit-i686+1/package/admin/runit/command/$i /command/$i
done

for i in $commands; do
	ln -svf /command/$i /usr/local/bin/$i
done

servicios="dbusdaemon getty-1 getty-3 iptables klogd localnet network.eth0 \
randomseed ratonpad syslogd"

for i in $servicios; do
	ln -svf /etc/sv/$i /service/
done


cp -v /usr/pkg/runit-$VER_runit-i686+1/package/admin/runit/command/runit* /sbin/
ln -svf runit-init /sbin/init

#Registro de tiempos de ejecución
T_FINAL=$(date +"%T")
echo "$(date) $nombre <$MSG_TIME> $T_COMIENZO $T_FINAL" >> $FILE_BITACORA






