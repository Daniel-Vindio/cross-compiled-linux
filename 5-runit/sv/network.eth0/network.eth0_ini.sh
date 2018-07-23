#!/bin/bash -e

#Scipt para activación y control con runit del servicio de red (network)
echo "Activación del servicio de red (network) en eth0 - enp1s8"

#El S20network de lsf llamaría a /sbin/ifup ${interface}. Yo solo 
#consideraré el eth0 - enp1s8. Y luego haré otro para la wifi.


#               Veamos que hace /sbin/ifup


#Hace falta que exista el archivo de configuración. No puede no existir.
#En LFS podría no existir. Exit 1 y ya está, pero aqué el supervisor estaría
#intentándolo contínuamente (sin sentido).


#Con esto carga los parámetros de configuración de la red
. /etc/sysconfig/ifconfig.enp1s8

#De la línea 84 a la 104 son comprobaciones del archivo de configuración.
#Son condicionales con exit si el archivo no cumple. NO puede ser este el
#caso. Tiene que cumplir, si no no funciona. Esto tiene sentido, ya que
#yo diseño el sistema, y no es necesaria tanta previsión de posibles
#archivos que no cumplan... soy yo quien los define para el SO de los
#ordenadores.

#Estos son los parámetros
#ONBOOT=yes
#IFACE=enp1s8
#SERVICE=ipv4-static
#IP=192.168.1.182
#GATEWAY=192.168.1.1
#PREFIX=24
#BROADCAST=192.168.1.255

#     En 108 llama a
#     IFCONFIG=${file} /lib/services/ipv4-static enp1s8 up
#     Veamos qué hace.

#De la linea 18 a la 44 comprueba nuevamente la existencia de los parámetros
#de configuración y genera $args

if [ "$(ip addr show ${IFACE} 2>/dev/null | grep ${IP}/)" = "" ]; then
		echo "Adding IPv4 address $IP/$PREFIX to the ${IFACE} interface..."
		ip addr add $IP/$PREFIX broadcast $BROADCAST dev ${IFACE}
	else
		echo "Cannot add IPv4 address ${IP} to ${IFACE}.  Already present."
fi

#seguimos con ifup
#114 UP () es una función

#	link_status=`ip link show ${IFACE}`
#
#    if ! echo "${link_status}" | grep -q UP; then
		ip link set ${IFACE} up
		echo "Setting ${IFACE} up"  
#	else
#		echo "ya estaba UP"
#	fi
#El resultado de ese grep puede ser siempre UP; Hay muchos UP or DOWN
#en el mensaje de IP link

#MTU. NO aplica se deja el por defecto 1500

   if ip route | grep -q default; then
      echo "Gateway already setup; skipping."
   else
      echo "Setting up default gateway..."
      ip route add default via ${GATEWAY} dev ${IFACE}
	fi

#Al final del todo del script
kill -stop $$
#Este kill hace que no se salga y el supervisor provoque su reactivación

