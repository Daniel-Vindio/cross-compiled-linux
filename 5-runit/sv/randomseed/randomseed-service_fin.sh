#!/bin/bash -e

echo "termina el servicio randomseed"

/bin/dd if=/dev/urandom of=/var/tmp/random-seed count=1

