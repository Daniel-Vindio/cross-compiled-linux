#!/bin/bash -e

echo "Empieza el servicio localnet"

#------------ACTIVACIoN LOOPBACK (S08 EN LFS)---------------------------
#nota: /etc/sysconfig/network no se ha definido en LFS
[ -r /etc/sysconfig/network ] && . /etc/sysconfig/network
[ -r /etc/hostname ] && HOSTNAME=`cat /etc/hostname`

echo "Activacion del interfaz «loopback»"
ip addr add 127.0.0.1/8 label lo dev lo
ip link set lo up

echo "Asignacion del «hostname»: ${HOSTNAME}"
hostname ${HOSTNAME}

kill -stop $$
