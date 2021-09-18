.. _Building and testing the OPTIGA™ Trust M for the Connected Home IP Software: https://github.com/Infineon/connected-home-optiga-trust#12---run-te1-tests
.. _Unable to establish ble connection between devices: https://github.com/project-chip/connectedhomeip/issues/6347#issuecomment-840618307

Bluetooth Troubleshooting
=========================

This document is for issues with Bluetooth using :code:`chip-device-ctrl`.

.. _Docker Container HCI Issues:

Docker Container HCI Issues
---------------------------

For the following errors, the docker container is unable to control the RPi's Bluetooth Host Controller Interface (HCI).

::

   Traceback (most recent call last):
     ...
   dbus.exceptions.DBusException: org.freedesktop.DBus.Error.NameHasNoOwner: Could not get owner of name 'org.bluez': no such name

   During handling of the above exception, another exception occurred:

   Traceback (most recent call last):
     ...
   dbus.exceptions.DBusException: org.freedesktop.DBus.Error.Spawn.ChildExited: Launch helper exited with unknown return code 1
   Failed to initialize BLE, if you don't have BLE, run chip-device-ctrl with --no-ble
   org.freedesktop.DBus.Error.Spawn.ChildExited: Launch helper exited with unknown return code 1
   Failed to bringup CHIPDeviceController CLI
   Exception ignored in: <function BluezManager.__del__ at 0x7f87cdc430>
   Traceback (most recent call last):
     File "/app/third_party/connectedhomeip/out/python_env/lib/python3.8/site-packages/chip/ChipBluezMgr.py", line 818, in __del__
       self.disconnect()
   AttributeError: 'BluezManager' object has no attribute 'disconnect'
   python: ../avahi-common/dbus-watch-glue.c:70: connection_data_ref: Assertion `d->ref >= 1' failed.
   [1631898604.446415][34:34] CHIP:DL: Inet Layer shutdown
   Aborted (core dumped)

In the container, the Bluetooth service is most likely not running.

::

   container$ ps aux | grep bluetoothd

Make sure Bluetooth management is disabled on the RPi under :ref:`Preparing the RPi`.  A reboot is required after making this change.  The Bluetooth service should not be running on the host OS after the reboot.

::

   rpi$ ps aux | grep bluetoothd

If this issue occurred after these steps have been taken, stop the container, restart the HCI from the host OS, and recreate the :code:`chip-device-ctrl` container.

::

   # make sure the interface is present
   rpi$ sudo hciconfig hci0
   # restart the interface
   rpi$ sudo hciconfig hci0 reset

Bluetooth management should now be running in the container.

::

   container$ ps aux | grep bluetoothd

If issues persist, check that the HCI is present in the container and run :code:`bluetoothd` in debug mode to look for additional errors.

::

   container$ hciconfig hci0
   container$ bluetoothd -d -n

.. _BLE Connection Failures:

BLE Connection Failures
-----------------------

To make sure BLE connections work outside of :code:`chip-device-ctrl`, try :code:`bluetoothctl` from inside the container.

::

   container$ bluetoothctl
   [bluetooth]# scan on
   ...
   [NEW] Device <mac_address> MatterLight
   ...
   [bluetooth]# scan off
   [bluetooth]# connect <mac_address>
   Connection successful
   ...
   [MatterLight]# disconnect
   [bluetooth]# exit

Additional Steps
""""""""""""""""

If issues still persist, try stopping the container, disabling WiFi and/or setting the HCI to BLE only, and recreating the :code:`chip-device-ctrl` container.

::

   # disable WiFi
   rpi$ sudo rfkill block wifi
   # set HCI to BLE only
   rpi$ sudo btmgmt -i hci0 power off;sudo btmgmt -i hci0 bredr off;sudo btmgmt -i hci0 power on

References
----------

- `Building and testing the OPTIGA™ Trust M for the Connected Home IP Software`_
- `Unable to establish ble connection between devices`_
