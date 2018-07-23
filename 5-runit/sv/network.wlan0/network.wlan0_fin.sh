#!/bin/bash -e

#Con esto carga los parámetros de configuración de la red
. /etc/sysconfig/ifconfig.wlp0s29f7u6

CFGFILE=/etc/sysconfig/wpa_supplicant-wlp0s29f7u6.conf
PIDFILE=/run/wpa_supplicant/wlp0s29f7u6.pid
CONTROL_IFACE=/run/wpa_supplicant/wlp0s29f7u6

echo "Desactivación del servicio de red (network) en wlan0 - ${IFACE}"

ip route del default via ${GATEWAY} dev ${IFACE}
echo "Borrat GATEWAY: ip route del default via ${GATEWAY} dev ${IFACE}"

ip link set ${IFACE} down
echo "Apaga el LINK: ip link set ${IFACE} down"

ip addr del $IP/$PREFIX broadcast $BROADCAST dev ${IFACE}
echo "Borra BROADCAST: ip addr del $IP/$PREFIX broadcast $BROADCAST dev ${IFACE}"

rm -rv $CONTROL_IFACE

#Pendiente del kill el porcese que se queda huerfano después de parar
#el servcio
