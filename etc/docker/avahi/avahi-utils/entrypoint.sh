#!/bin/sh

service dbus start 1> /dev/null

rm /run/avahi-daemon/pid
service avahi-daemon start 1> /dev/null
service avahi-daemon status

sleep 2

exec "$@"
