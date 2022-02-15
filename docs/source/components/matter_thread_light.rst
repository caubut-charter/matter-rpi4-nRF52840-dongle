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

#. Select an nRF52840 dongle for OTBR, note its MAC address, and plug it into an open USB port on the RPi.

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

   .. tabs::

      .. tab:: Built

         ::

            docker run -it --rm \
             -v $PWD/build/Release:/root \
             --device $(readlink -f $LIGHT_TTY) \
             caubutcharter/nrfutil:latest dfu usb-serial -pkg nrf52840-dongle-thread-lighting-app.zip -p $(readlink -f $LIGHT_TTY)

      .. tab:: Downloaded

         ::

            # latest
            docker run -it --rm \
             -v $PWD/build/Release:/root \
             --device $(readlink -f $LIGHT_TTY) \
             caubutcharter/nrfutil:latest dfu usb-serial -pkg nrf52840-dongle-thread-lighting-app-LATEST.zip -p $(readlink -f $LIGHT_TTY)

            # test event
            docker run -it --rm \
             -v $PWD/build/Release:/root \
             --device $(readlink -f $LIGHT_TTY) \
             caubutcharter/nrfutil:latest dfu usb-serial -pkg nrf52840-dongle-thread-lighting-app-TEST_EVENT_7.zip -p $(readlink -f $LIGHT_TTY)

Commissioning the Device
------------------------

#. Capture the current Active Operational Dataset and Extended PAN ID from the OTBR service.

   ::

      sudo ot-ctl dataset active -x
      sudo ot-ctl dataset extpanid

#. Start the :code:`chip-device-ctrl` Matter controller.

   ::

      cd third_party/connectedhomeip
      source out/python_env/bin/activate
      sudo out/python_env/bin/chip-device-ctrl --bluetooth-adapter=hci0

#. Reseat the dongle.  BLE advertisements are only enabled for 15 minutes after boot.  The LED should show a *Short Flash On (50 ms on/950 ms off)*.

   .. note::

      If the dongle was previously commissioned, even unsuccessfully, the settings may still exist on the dongle even after flashing.  This can be observed by the light pattern not matching the above statement.  To clear the settings, hold the :code:`SW1` button (different from the button used to flash the dongle) until the following sequence of LED patterns completes (about 6 seconds):

      - :code:`LD1` and :code:`LD2` will start blinking in unison
      - both LEDs will stop blinking

#. Discovery the Matter Thread Light over BLE.

   ::

      ble-scan

#. Using the output above, connect to the Matter Thread Light over BLE.  The pin code should be hard coded to :code:`20202021`.  The LED should show a *Rapid Even Flashing (100 ms on/100 ms off)*.  See :ref:`BLE Connection Failures` for troubleshooting if the connection fails.

   ::

      # example: connect -ble 3840 20202021 123456
      connect -ble <discriminator> <pin_code> <temp_id>

#. Inject the previously obtained Active Operational Dataset as hex-encoded value using ZCL Network Commissioning cluster.

   ::

      # example: zcl NetworkCommissioning AddOrUpdateThreadNetwork 123456 0 0 operationalDataset=hex:0e080000000000010000000300000f35060004001fffe0020811111111222222220708fdc0ab06bb38fa61051000112233445566778899aabbccddeeff030b6d61747465722d64656d6f0102123404104260acc85ec98f24df213dd31e58e7e00c0402a0fff8 breadcrumb=0
      zcl NetworkCommissioning AddOrUpdateThreadNetwork 123456 0 0 operationalDataset=hex:<active_operational_dataset> breadcrumb=0

#. Enable the Thread interface on the device by executing the following command with :code:`networkID` equal to the Extended PAN ID of the Thread network.  The LED should show a *Short Flash Off (950ms on/50ms off)*.

   ::

      # example: zcl NetworkCommissioning ConnectNetwork 123456 0 0 networkID=hex:1111111122222222 breadcrumb=0
      zcl NetworkCommissioning ConnectNetwork 123456 0 0 networkID=hex:<extended_pan_id> breadcrumb=0

#. Close the BLE connection.

   ::

      close-ble

#. Discover IPv6 address of the Matter Thread Light.

   ::

      resolve 123456

#. Control the light.

   ::

      zcl OnOff On 123456 1 0
      zcl OnOff Off 123456 1 0
      zcl OnOff Toggle 123456 1 0
      zcl LevelControl MoveToLevel 123456 1 0 level=10 transitionTime=0 optionMask=0 optionOverride=0

#. Exit :code:`chip-device-ctrl`.

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
