#!/bin/bash

service dbus start 1> /dev/null
bluetoothd &

exec "$@"
