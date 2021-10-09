.. _Matter: https://buildwithmatter.com/
.. _nRF52840 Dongles: https://www.nordicsemi.com/Products/Development-hardware/nRF52840-Dongle/GetStarted
.. _Raspberry Pi 4B: https://www.raspberrypi.org/products/
.. _container images: https://hub.docker.com/u/caubutcharter
.. _build artifacts: https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/releases/tag/nightly

Introduction
============

This project is an introductory step-by-step walk-through for building, commissioning, and testing your first Matter_ components.  It is meant as a bootstrap guide for anyone interested in Matter that wants to quickly setup a runnable example.  `nRF52840 Dongles`_ are used as low-cost radios and microcontrollers.  A `Raspberry Pi 4B`_ is used for building artifacts and running services.  Theoretically, an x64 Linux Desktop can be used for any step, and in some cases it is desirable (e.g. building firmware), but it is not tested as frequently.  *Every* stage is containerized to prevent dependency issues on the host.

Instructions are included to build everything from scratch.  Some of the build steps are executed via scripts in this repository which perform some minimal patching so everything builds on the Raspberry Pi or to reduce the container image sizes.  CI/CD pipelines are setup on this project to generate nightly builds of the `container images`_ and various `build artifacts`_ as an alternative option to building everything from scratch.

Major Components
----------------

+----------------------------------+----------------------------------------------------------------------------------------+
| Component                        | Description                                                                            |
+==================================+========================================================================================+
| Border Router                    | A Thread border router bridges a home Ethernet/WiFi network with a Thread network.     |
|                                  | OpenThread Border Router (OTBR) will be used.  OTBR will run in a docker               |
|                                  | container but requires a radio that speaks Thread. The Thread Radio Co-Processor       |
|                                  | is the Thread radio that can be used for this purpose.  An nRF52840 dongle will        |
|                                  | be flashed and provisioned for this guide.                                             |
+----------------------------------+----------------------------------------------------------------------------------------+
| Matter Commissioner/Controller   | For this guide, it is a docker application that can push WiFi or Thread credentials to |
|                                  | a Matter accessory via the RPi's built-in Bluetooth radio (commissioner).  Once        |
|                                  | commissioned, it can send commands, such as on/off (controller).                       |
+----------------------------------+----------------------------------------------------------------------------------------+
| Matter Thread Accessory (WIP)    | A Matter accessory that connects to the local network via Thread.  An nRF52840         |
|                                  | dongle with the lighting example will be used.                                         |
+----------------------------------+----------------------------------------------------------------------------------------+
| Matter Ethernet Accessory (TODO) | A Matter accessory that connects via Ethernet or WiFi.  The lighting example will be   |
|                                  | used in a docker container.  An nRF52840 dongle will be used for this accessory's      |
|                                  | BLE radio so it can be commissioned.                                                   |
+----------------------------------+----------------------------------------------------------------------------------------+

Physically, these components may resemble the following diagram.

.. image:: ../_static/physical_diagram.png
   :align: center

Minor Components
----------------

+---------------------------+-------------+
| Component                 | Description |
+===========================+=============+
| OpenThread Commissioner   |             |
+---------------------------+-------------+
| DNS-SD Client             |             |
+---------------------------+-------------+
| nRF52840 Flashing Utility |             |
+---------------------------+-------------+

In order for service discovery to work, containers need to be attached to the same Local Area Network.  This project does this by attaching containers to the host's network.  Below is an example architecture diagram that allows containers to run on different hosts by using this method.  Should a test environment derived from the steps in this project outgrow a single host, it should still work the same when split over several hosts.

   .. image:: ../_static/logical_diagram.png
      :align: center


- :doc:`../components/otbr`
- :doc:`../components/matter_thread_light` (WIP)
- Matter WiFi/Ethernet Light (TODO)
