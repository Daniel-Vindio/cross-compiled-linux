#!/bin/bash -e

#Scipt para activación y control con runit del servicio de red (network)
echo "Activación del servicio de red (network) en wlan0 - wlp0s29f7u6"

#Con esto carga los parámetros de configuración de la red
. /etc/sysconfig/ifconfig.wlp0s29f7u6

#Estos son los parámetros
#ONBOOT=yes
#IFACE=wlp0s29f7u6
#SERVICE=wpa

# Additional arguments to wpa_supplicant
#WPA_ARGS=
#Eso era antes, ahora tiene.
#WPA_ARGS="-C/run/wpa_supplicant

#WPA_SERVICE=ipv4-static
#IP=192.168.1.183
#GATEWAY=192.168.1.1
#PREFIX=24
#BROADCAST=192.168.1.255

#The difference with eth0 is in the applied /lib/service/ in this case
#is wpa

#From /lib/service/wpa the following you can get the following commands

CFGFILE=/etc/sysconfig/wpa_supplicant-wlp0s29f7u6.conf
PIDFILE=/run/wpa_supplicant/wlp0s29f7u6.pid
CONTROL_IFACE=/run/wpa_supplicant/wlp0s29f7u6

#Es necesario poner esto antes, ya que wpa_supplicant hace que no sigan
#ejecutandose los comandos del script que vengan detras. De echo no hace 
#falata kill stop.

#Esto es lo que hace WPA_SERVICE=ipv4-static en resumidas cuentas 
if [ "$(ip addr show ${IFACE} 2>/dev/null | grep ${IP}/)" = "" ]; then
		echo "Adding IPv4 address $IP/$PREFIX to the ${IFACE} interface..."
		ip addr add $IP/$PREFIX broadcast $BROADCAST dev ${IFACE}
	else
		echo "Cannot add IPv4 address ${IP} to ${IFACE}.  Already present."
fi

link_status=`ip link show ${IFACE}`

if ! echo "${link_status}" | grep -q UP; then
#Este control no puede funcionar, ya que UP aparece varias veces
#como mensaje de ip link show... lo dejaré...    
	ip link set ${IFACE} up
	echo "Setting ${IFACE} up"  
else
	echo "ya estaba UP"
fi

#MTU. NO aplica se deja el por defecto 1500

   if ip route | grep -q default; then
      echo "Gateway already setup; skipping."
   else
      echo "Setting up default gateway..."
      ip route add default via ${GATEWAY} dev ${IFACE}
	fi


if [ -e ${PIDFILE} ]; then
	ps $(cat ${PIDFILE}) | grep wpa_supplicant >/dev/null
    if [ "$?" = "0" ]; then
		echo "wpa_supplicant already running on $IFACE."
    else
		rm ${PIDFILE}
		echo "se borra ${PIDFILE}"
	fi
fi

if [ ! -e ${CFGFILE} ]; then
	echo "No puede ser que no exista el configuration file ${CFGFILE}"
fi

## Only specify -C on command line if it is not in CFGFILE
#      if ! grep -q ctrl_interface ${CFGFILE}; then 
#         WPA_ARGS="-C/run/wpa_supplicant ${WPA_ARGS}"
#      fi
#En este sistema que estoy diseñando se definirá esto en el archivo
#de configuración directamente. En LFS original WPA_ARGS= está vacío
#en el mío se dará WPA_ARGS="-C/run/wpa_supplicant"

echo "Starting wpa_supplicant on the $IFACE interface..."
mkdir -vp /run/wpa_supplicant

#OJO la opción -B cd wpa_supplicant lo manda al background, y no podría
#ser controlado. Hay que quitar la B. 
#La -d para debugging deja abierto el porceso y no continuan ejecutándose
#comandos. No se puede dejar puesta. Usar solo para depuración.

exec /sbin/wpa_supplicant -q -Dnl80211,wext -P${PIDFILE} \
-c${CFGFILE} -i${IFACE} ${WPA_ARGS}


#Este exec en /sbin/wpa_supplicant es fundamental para que sv pueda parar a
#/sbin/wpa_supplicant. Si no se pone exec, al hacer sv stop, el
#/sbin/wpa_supplicant se resucita fuera de runit, y no para.

if [ "$?" != "0" ]; then
	echo "Error en /sbin/wpa_supplicant"
	#exit 1 #Si hubiera error el controlador o bash -e lo rearmarían
fi

#Elimino un bloque que controla que exista y sea ejecutable
#WPA_SERVICE=ipv4-static. Es que tienen que estar y correctamente

#Al final del todo del script
#Creo que wpa_supplicant para el proceso, así que no hace falta kill
#kill -stop $$
#Este kill hace que no se salga y el supervisor provoque su reactivación

