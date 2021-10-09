.. _Radio Co-Processor: https://openthread.io/platforms#radio-co-processor-rcp
.. _OpenThread Border Router: https://openthread.io/guides/border-router
.. _nRF Util: https://www.nordicsemi.com/Products/Development-tools/nrf-util
.. _Configuring OpenThread Radio Co-processor on nRF52840 Dongle: https://github.com/project-chip/connectedhomeip/blob/master/docs/guides/openthread_rcp_nrf_dongle.md
.. _Build OpenThread: https://openthread.io/guides/build
.. _Run OTBR Docker: https://openthread.io/guides/border-router/docker/run
.. _Thread CLI Documentation: https://github.com/openthread/openthread/blob/main/src/cli/README.md
.. _ot-commissioner CLI Documentation: https://github.com/openthread/ot-commissioner/tree/main/src/app/cli

OpenThread Border Router
========================

This section covers building a Thread `Radio Co-Processor`_ (RPC) and setting up an `OpenThread Border Router`_ (OTBR) on an RPi.

.. _Flashing the RCP:

Flashing the RCP
----------------

#. Select an nRF52840 dongle for OTBR, note its MAC address, and plug it into an open USB port on the build system.

   .. image:: ../_static/nRF52840_dongle_mac.png
      :align: center

#. Press the reset button on the dongle to put it into DFU mode.  A red LED on the dongle will start blinking.  The reset button is on the far side of the board from the USB connector.  Note that the button does not face up. It will have to push it from the outside in, towards the USB connector.

   .. image:: ../_static/nRF52840_dongle_press_reset.svg
      :align: center

   Source: https://docs.zephyrproject.org/latest/boards/arm/nrf52840dongle_nrf52840/doc/index.html#programming-and-debugging

#. Capture the absolute path to the static symlink of this dongle by matching the MAC address (all caps no delimiters) with the following command.

   ::

      # example: export RCP_TTY=$(find /dev/serial/by-id -type l | grep F415E25657B9)
      export RCP_TTY=$(find /dev/serial/by-id -type l | grep <mac>)
      echo $RCP_TTY

#. Flash the RCP firmware package onto the dongle.

   ::

      docker run -it --rm \
       -v $PWD/build/ot-nrf528xx/bin:/root \
       --device $(readlink -f $RCP_TTY):$(readlink -f $RCP_TTY) \
       nordicsemi/nrfutil:latest dfu usb-serial -pkg ot-rcp.zip -p $(readlink -f $RCP_TTY)

.. _Setting Up OTBR:

Setting Up OTBR
---------------

#. If the build system is not the RPi, move the RPC to an open USB port on the RPi where the following commands will be executed.

#. Capture the absolute path to the static symlink of this dongle by matching the MAC address (all caps no delimiters) with the following command.

   .. warning::

      This step is required even if the build system is the RPi as the device name may have changed since flashing.

   ::

      # example: export RCP_TTY=$(find /dev/serial/by-id -type l | grep F415E25657B9)
      export RCP_TTY=$(find /dev/serial/by-id -type l | grep <mac>)
      echo $RCP_TTY

#. Run the OTBR service.

   .. warning::

      This OTBR service container will automatically be removed if stopped.  This was a design decision as the dongle's :code:`ttyACM` index is not guaranteed in certain situations (e.g. host restart).

   ::

      docker create --rm --name otbr --hostname otbr -p 8080:80 --privileged \
       --sysctl "net.ipv6.conf.eth1.disable_ipv6=0 net.ipv6.conf.eth1.forwarding=1" \
       openthread/otbr:latest --radio-url spinel+hdlc+uart://$(readlink -f $RCP_TTY)
      docker network connect matter-bridge --ip 169.254.100.0 otbr
      docker start otbr
      docker exec -it otbr ip address del 169.254.100.0/16 dev eth1

#. Navigate to http://matter-demo.local:8080/ from any device on the LAN and click on **Form** on the side menu to setup a Thread network.

#. Adjust the settings and click the **Form** button to create the Thread network.

   .. note::

      It is recommend to leave the default **Channel** and **On-Mesh** Prefix values.

   The following settings are used in this guide.

   +-----------------+----------------------------------+
   | Parameter       | Value                            |
   +=================+==================================+
   | Network Name    | matter-demo                      |
   +-----------------+----------------------------------+
   | PAN ID          | 0x1234                           |
   +-----------------+----------------------------------+
   | Network Key     | 00112233445566778899aabbccddeeff |
   +-----------------+----------------------------------+
   | Extended PAN ID | 1111111122222222                 |
   +-----------------+----------------------------------+
   | Passphrase      | 123456                           |
   +-----------------+----------------------------------+
   | Channel         | default                          |
   +-----------------+----------------------------------+
   | On-Mesh Prefix  | default                          |
   +-----------------+----------------------------------+
   | Default Route   | On                               |
   +-----------------+----------------------------------+

#. Additional details about the created OTBR can be viewed by clicking on **Status** on the side menu.


#. On the RPi, capture the generated PSKc key for the Thread network.\

   ::

      docker exec -it otbr ot-ctl pskc

.. _Verifying OTBR:

Verifying OTBR
--------------

#. On the build system, verify the mesh commissioning protocol (MeshCoP) advertisement from OTBR.  Capture the **address** and **port** to test the commissioning process.

   .. warning:: The chosen IPv4 address must be unique from other docker containers on the host's broadcast domain to ensure a unique MAC address is generated.

   .. note::

      This command continually scans.  Hit :code:`CTRL-C` to exit.

   ::

      docker run -it --rm \
       --network matter-bridge --ip 169.254.200.0 \
       --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
       avahi/avahi-utils:latest avahi-browse -lr _meshcop._udp

#. Run the ot-commissioner.

   .. warning:: The chosen IPv4 address must be unique from other docker containers on the host's broadcast domain to ensure a unique MAC address is generated.

   ::

       docker run -it --rm \
        --network=matter-bridge --ip 169.254.100.10 \
        --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
        openthread/ot-commissioner:latest

#. Set the PSKc key to the one captured while setting up OTBR.

   ::

      config set pskc <PSKc>

#. Start the commissioning process and verify there are no errors.

   ::

      # link-local IPv6 address (starts with fe80)
      start <address>%eth0 <port>

#. Stop the commissioning process to end the test.

   ::

      stop

#. Exit the process which will stop the container and automatically remove it.

   ::

      exit

References
----------

- `Configuring OpenThread Radio Co-processor on nRF52840 Dongle`_
- `Build OpenThread`_
- `Run OTBR Docker`_
- `Thread CLI Documentation`_
- `ot-commissioner CLI Documentation`_
