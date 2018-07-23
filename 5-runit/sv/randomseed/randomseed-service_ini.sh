#!/bin/bash -e

echo "Empieza el servicio randomseed"


if [ -f /var/tmp/random-seed ]; then
    /bin/cat /var/tmp/random-seed >/dev/urandom
fi
      
/bin/dd if=/dev/urandom of=/var/tmp/random-seed count=1

#Con esto evitamos que de por terminado el script.
kill -stop $$

