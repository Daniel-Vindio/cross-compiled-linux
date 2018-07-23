#!/bin/bash -e

#Con esto carga los parámetros de configuración de la red
. /etc/sysconfig/ifconfig.enp1s8

echo "Desactivación del servicio de red (network) en eth0 - ${IFACE}"

ip route del default via ${GATEWAY} dev ${IFACE}
echo "Borrat GATEWAY: ip route del default via ${GATEWAY} dev ${IFACE}"

ip link set ${IFACE} down
echo "Apaga el LINK: ip link set ${IFACE} down"

ip addr del $IP/$PREFIX broadcast $BROADCAST dev ${IFACE}
echo "Borra BROADCAST: ip addr del $IP/$PREFIX broadcast $BROADCAST dev ${IFACE}"
