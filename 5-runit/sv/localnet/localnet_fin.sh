#!/bin/bash -e

echo "Termina el servicio localnet"

ip link set lo down
ip addr del 127.0.0.1/8 label lo dev lo
