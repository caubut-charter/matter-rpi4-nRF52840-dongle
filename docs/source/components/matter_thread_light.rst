.. _CHIP nRF Connect Lighting Example Application: https://github.com/project-chip/connectedhomeip/tree/master/examples/lighting-app/nrfconnect#setting-up-the-environment
.. _Zephyr Project Documentation\: nRF52840 Dongle: https://docs.zephyrproject.org/latest/boards/arm/nrf52840dongle_nrf52840/doc/index.html#programming-and-debugging
.. _Accessing Bluetooth dongle from inside Docker?: https://stackoverflow.com/questions/28868393/accessing-bluetooth-dongle-from-inside-docker
.. _Bluetooth socket can't be opened inside container: https://github.com/moby/moby/issues/16208#issuecomment-161770118
.. _Working with Python CHIP Controller: https://github.com/project-chip/connectedhomeip/blob/master/docs/guides/python_chip_controller_building.md
.. _Using CLI in nRF Connect examples: https://github.com/project-chip/connectedhomeip/blob/master/docs/guides/nrfconnect_examples_cli.md
.. _External Thread Commissioning: https://openthread.io/guides/border-router/external-commissioning?comm=ot-commissionn

Matter Thread Light
===================

Building the Device Image
-------------------------

#. From the build system, run the nRF Connect Matter build environment.

   .. note::

      Building will occur in the :code:`build/lighting-app/nrfconnect` directory.  Remove this directory first if a fresh build is desired.

      ::

         sudo rm -rf build/lighting-app/nrfconnect

   .. note::

      The nRF Connect SDK is cached in the :code:`build/nrf-sdk` directory so it can be reused for other projects.  Remove this directory first if a fresh build is desired.

      ::

         sudo rm -rf build/nrf-sdk

   ::

      docker run -it --rm \
       -v $PWD/build/nrf-sdk:/var/ncs \
       -v $PWD/third_party/connectedhomeip:/var/chip \
       -v $PWD/build/lighting-app/nrfconnect:/var/chip/examples/lighting-app/nrfconnect/build \
       nordicsemi/nrfconnect-chip:latest

#. Install nRF Connect and Matter dependencies.

   ::

       # bootstrap if build/nrf-sdk is empty
       setup

       # update an existing build/nrf-sdk
       python3 scripts/setup/nrfconnect/update_ncs.py --update

#. Build the lighting example for the nRF52840 dongle which creates a :code:`.hex` format image at :code:`build/zephyr/zephyr.hex`.

   ::

       cd examples/lighting-app/nrfconnect
       west build -b nrf52840dongle_nrf52840

#. Exit the container which will stop and automatically remove it.

   ::

      exit

Flashing the Device
-------------------

#. From the build system, generate the nRF52840 dongle firmware package.

   ::

      docker run --rm \
       -v $PWD/build/lighting-app/nrfconnect/zephyr:/root \
       nordicsemi/nrfutil:latest pkg generate --hw-version 52 --sd-req=0x00 \
       --application zephyr.hex --application-version 1 matter-thread-light.zip

#. Select an nRF52840 dongle for OTBR, note its MAC address, and plug it into an open USB port on the build system.

   .. note::

      If the dongle was already plugged in, reseat the device.  Flashing sometimes stalls at 0% if not reseated.

   .. image:: ../_static/nRF52840_dongle_mac.png
      :align: center

#. Press the reset button on the dongle to put it into DFU mode.  A red LED on the dongle will start blinking.  The push button is on the far side of the board from the USB connector.  Note that the button does not face up. It will have to push it from the outside in, towards the USB connector.

   .. image:: ../_static/nRF52840_dongle_press_reset.svg
      :align: center

   Source: https://infocenter.nordicsemi.com/index.jsp?topic=%2Fug_nrf52840_dongle%2FUG%2Fnrf52840_Dongle%2Fhw_button_led.html

#. Capture the absolute path to the static symlink of this dongle by matching the MAC address (all caps no delimiters) with the following command.

   ::

      # example: export LIGHT_TTY=$(find /dev/serial/by-id -type l | grep C794EB8363FA)
      export LIGHT_TTY=$(find /dev/serial/by-id -type l | grep <mac>)
      echo $LIGHT_TTY

#. Flash the nRF52840 firmware package onto the dongle.

   ::

      docker run -it --rm \
       -v $PWD/build/lighting-app/nrfconnect/zephyr:/root \
       --device $(readlink -f $LIGHT_TTY):$(readlink -f $LIGHT_TTY) \
       nordicsemi/nrfutil:latest dfu usb-serial -pkg matter-thread-light.zip -p $(readlink -f $LIGHT_TTY)

Commissioning the Device
------------------------

.. warning::

   This section is a work in progress.

.. tabs::

   .. tab:: chip-device-ctrl

      .. note::

         Building will occur in the :code:`build/chip-device-ctrl` directory.  Remove this directory first if a fresh build is desired.

         ::

            sudo rm -rf build/chip-device-ctrl

      #. From the RPi, run the :code:`chip-device-ctrl` build environment.

         ::

            docker run -it --rm --net=host --privileged \
             -v $PWD:/app \
             -v $PWD/build/chip-device-ctrl:/app/third_party/connectedhomeip/out \
             matter/chip-device-ctrl:latest /bin/bash

      #. In the container, make sure the Bluetooth service is running.  If it is not, see :ref:`Docker Container HCI Issues`.

         ::

            ps aux | grep bluetoothd

      #. Build and install :code:`chip-device-ctrl`.

         .. note::

            This step can be skipped if there was an existing build in the :code:`build/chip-device-ctrl` directory.

         ::

            scripts/build_python.sh -m platform

      #. Run :code:`chip-device-ctrl`.

         ::

            source out/python_env/bin/activate
            out/python_env/bin/chip-device-ctrl --bluetooth-adapter=hci0

      #. Reseat the dongle.  BLE advertisements are only enabled for 15 minutes after powering the dongle.

      #. Discovery the Matter Thread Light over BLE.

         ::

            ble-scan

      #. Using the output above, connect to the Matter Thread Light over BLE.  The pin code should be hard coded to :code:`20202021`.  See :ref:`BLE Connection Failures` for troubleshooting if the connection fails.

         ::

            # example: connect -ble 3840 20202021 1234
            connect -ble <steup> discriminator> <pin_code> <temp_id>

      #. Commission the Matter Thread Light over BLE.

         TODO

      #. Exit :code:`chip-device-ctrl`.

         ::

            exit

      #. Exit the :code:`chip-device-ctrl` build environment which will stop the container and automatically remove it.

         ::

            exit

   .. tab:: ot-commissioner

      TODO

References
----------

- `CHIP nRF Connect Lighting Example Application`_
- `Zephyr Project Documentation: nRF52840 Dongle`_
- `Accessing Bluetooth dongle from inside Docker?`_
- `Bluetooth socket can't be opened inside container`_
- `Working with Python CHIP Controller`_
- `Using CLI in nRF Connect examples`_
- `External Thread Commissioning`_
