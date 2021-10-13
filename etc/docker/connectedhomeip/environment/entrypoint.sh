#!/bin/sh

service dbus start 1> /dev/null

service avahi-daemon start 1> /dev/null

bluetoothd &

exec "$@"

# TODO net <= network; can use host?
# TODO matter-bridge ip table
# TODO device doesn't need double?
