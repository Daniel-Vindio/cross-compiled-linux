#!/bin/bash -e

echo "Empieza el servicio dbusdaemon"

exec 2>&1

if [ ! -d /var/run/dbus ]; then
  mkdir -p /var/run/dbus
  chown messagebus /var/run/dbus
  chgrp messagebus /var/run/dbus
fi
/usr/bin/dbus-uuidgen --ensure
dbus-daemon --nofork --system
#--config-file=/etc/dbus-1/system.conf
#--nopidfile 


#kill -stop $$
