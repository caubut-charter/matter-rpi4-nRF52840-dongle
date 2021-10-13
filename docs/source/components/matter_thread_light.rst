.. _Zephyr Project Documentation\: nRF52840 Dongle: https://docs.zephyrproject.org/latest/boards/arm/nrf52840dongle_nrf52840/doc/index.html#programming-and-debugging
.. _Accessing Bluetooth dongle from inside Docker?: https://stackoverflow.com/questions/28868393/accessing-bluetooth-dongle-from-inside-docker
.. _Bluetooth socket can't be opened inside container: https://github.com/moby/moby/issues/16208#issuecomment-161770118
.. _Working with Python CHIP Controller: https://github.com/project-chip/connectedhomeip/blob/master/docs/guides/python_chip_controller_building.md
.. _Using CLI in nRF Connect examples: https://github.com/project-chip/connectedhomeip/blob/master/docs/guides/nrfconnect_examples_cli.md
.. _External Thread Commissioning: https://openthread.io/guides/border-router/external-commissioning?comm=ot-commissionn
.. _CHIP ESP32 Lock Example: https://github.com/project-chip/connectedhomeip/tree/master/examples/lock-app/esp32

Matter Thread Light
===================

This section covers flashing a Matter Thread light accessory on an nRF52840 dongle and commissioning it onto the OTBR Thread network.

Flashing the Accessory
----------------------

#. Select an nRF52840 dongle for OTBR, note its MAC address, and plug it into an open USB port on the build system.

   .. image:: ../_static/nRF52840_dongle_mac.png
      :align: center

#. Press the reset button on the dongle to put it into DFU mode.  A red LED on the dongle will start blinking.  The reset button is on the far side of the board from the USB connector.  Note that the button does not face up. It will have to push it from the outside in, towards the USB connector.

   .. image:: ../_static/nRF52840_dongle_press_reset.svg
      :align: center

   Source: https://docs.zephyrproject.org/latest/boards/arm/nrf52840dongle_nrf52840/doc/index.html#programming-and-debugging

#. Capture the absolute path to the static symlink of this dongle by matching the MAC address (all caps no delimiters) with the following command.

   ::

      # example: export LIGHT_TTY=$(find /dev/serial/by-id -type l | grep C794EB8363FA)
      export LIGHT_TTY=$(find /dev/serial/by-id -type l | grep <mac>)
      echo $LIGHT_TTY

#. Flash the nRF52840 firmware package onto the dongle.

   ::

      # latest
      docker run -it --rm \
       -v $PWD/build/Release:/root \
       --device $(readlink -f $LIGHT_TTY):$(readlink -f $LIGHT_TTY) \
       caubutcharter/nrfutil:latest dfu usb-serial -pkg nrf52840-dongle-thread-lighting-app-LATEST.zip -p $(readlink -f $LIGHT_TTY)

      # test event
      docker run -it --rm \
       -v $PWD/build/Release:/root \
       --device $(readlink -f $LIGHT_TTY):$(readlink -f $LIGHT_TTY) \
       caubutcharter/nrfutil:latest dfu usb-serial -pkg nrf52840-dongle-thread-lighting-app-TEST_EVENT_6.zip -p $(readlink -f $LIGHT_TTY)

Commissioning the Device
------------------------

.. warning::

   This section is a work in progress.

#. From the RPi, capture the current Active Operational Dataset and Extended PAN ID from the OTBR service.

   ::

      docker exec -it otbr sh -c "sudo ot-ctl dataset active -x"
      sudo docker exec -it otbr sh -c "sudo ot-ctl dataset extpanid"

#. Run the :code:`chip-device-ctrl` container.

   ::

      docker run -it --rm --net=host --privileged \
       -v "$PWD"/third_party/connectedhomeip:/var/chip \
       -v "$PWD"/build/Release/chip-device-ctrl:/var/chip/out \
       caubutcharter/chip-environment:latest /bin/bash

#. In the container, make sure the Bluetooth service is running.  If it is not, see :ref:`Container HCI Issues`.

   ::

      ps aux | grep bluetoothd

#. Run :code:`chip-device-ctrl`.

   ::

      source out/python_env/bin/activate
      out/python_env/bin/chip-device-ctrl --bluetooth-adapter=hci0

#. Reseat the dongle.  BLE advertisements are only enabled for 15 minutes after boot.  The LED should show a *Short Flash On (50 ms on/950 ms off)*.

   .. note::

      If the dongle was previously commissioned, even unsuccessfully, the settings may still exist on the dongle even after flashing.  This can be observed by the light pattern not matching the above statement.  To clear the settings, hold the :code:`SW1` button (different from the button used to flash the dongle) until the following sequence of LED patterns completes (about 6 seconds):

      - :code:`LD1` and :code:`LD2` will start blinking in unison
      - both LEDs will stop blinking

#. Discovery the Matter Thread Light over BLE.

   ::

      ble-scan

#. Using the output above, connect to the Matter Thread Light over BLE.  The pin code should be hard coded to :code:`20202021`.  The LED should show a *Rapid Even Flashing (100 ms on/100 ms off)*.  See :ref:`BLE Connection Failures` for troubleshooting if the connection fails.

   .. warning::

      This step is currently failing.  Watching https://github.com/project-chip/connectedhomeip/issues/9948 to see if it resolves.

   ::

      # example: connect -ble 3840 20202021 123456
      connect -ble <discriminator> <pin_code> <temp_id>


#. Inject the previously obtained Active Operational Dataset as hex-encoded value using ZCL Network Commissioning cluster.

   ::

      # example: zcl NetworkCommissioning AddThreadNetwork 123456 0 0 operationalDataset=hex:0e080000000000010000000300000f35060004001fffe0020811111111222222220708fdc0ab06bb38fa61051000112233445566778899aabbccddeeff030b6d61747465722d64656d6f0102123404104260acc85ec98f24df213dd31e58e7e00c0402a0fff8 breadcrumb=0 timeoutMs=3000
      zcl NetworkCommissioning AddThreadNetwork 123456 0 0 operationalDataset=hex:<active_operational_dataset> breadcrumb=0 timeoutMs=3000

#. Enable the Thread interface on the device by executing the following command with :code:`networkID` equal to Extended PAN ID of the Thread network.  The LED should show a *Short Flash Off (950ms on/50ms off)*.

   ::

      # example: zcl NetworkCommissioning EnableNetwork 123456 0 0 networkID=hex:1111111122222222 breadcrumb=0 timeoutMs=3000
      zcl NetworkCommissioning EnableNetwork 123456 0 0 networkID=hex:<extended_pan_id> breadcrumb=0 timeoutMs=3000

#. Close the BLE connection.

   ::

      close-ble

#. Discover IPv6 address of the Matter Thread Light.

   .. note::

      This section is a WIP.

   ::

      resolve 5544332211 1234

   Getting :code:`CHIP Error 0x000000AC: Internal error`.  Possible issue with Fabric ID.  Also getting an error about the temp ID format during BLE connection.  Device LED does have a "Short Flash Off".

   Device is possibly seen over DNS-SD.

   ::

      $ docker run -it --rm \
       --network matter-bridge --ip 169.254.200.0 \
       --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
       caubutcharter/avahi-utils:latest avahi-browse --all | grep matter
      +   eth0 IPv6 0A3DC266752DF2DB                              _matterc._udp        local
      +   eth0 IPv6 C8E944D0D1FA50DC-00000000000004D2             _matter._tcp         local
      +   eth0 IPv6 DCBC16980E4F73F3                              _matterc._udp        local

     $ docker run -it --rm \
      --network matter-bridge --ip 169.254.200.0 \
      --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
      caubutcharter/avahi-utils:latest avahi-browse -lr _matter._tcp.
     Avahi mDNS/DNS-SD Daemon is running
     +   eth0 IPv6 C8E944D0D1FA50DC-00000000000004D2             _matter._tcp         local
     =   eth0 IPv6 C8E944D0D1FA50DC-00000000000004D2             _matter._tcp         local
        hostname = [5AB0CD5DEE054C38.local]
        address = [fd11:22::a085:a340:fc5e:c74b]
        port = [5540]
        txt = ["T=0" "CRA=300" "CRI=5000"]

   This extended error is showing when exiting the tool.

   ::

      [1631993184.884151][588:596] CHIP:DIS: mDNS error: ../../src/platform/Linux/MdnsImpl.cpp:397: CHIP Error 0x000000AC: Internal error

   https://github.com/project-chip/connectedhomeip/issues/9264

#. Exit :code:`chip-device-ctrl`.

   ::

      exit

#. Exit the :code:`chip-device-ctrl` container which will stop and automatically remove it.

   ::

      exit

References
----------

- `Zephyr Project Documentation: nRF52840 Dongle`_
- `Accessing Bluetooth dongle from inside Docker?`_
- `Bluetooth socket can't be opened inside container`_
- `Working with Python CHIP Controller`_
- `Using CLI in nRF Connect examples`_
- `External Thread Commissioning`_
- `CHIP ESP32 Lock Example`_
