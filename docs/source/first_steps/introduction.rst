.. _Matter: https://buildwithmatter.com/
.. _nRF52840 Dongles: https://www.nordicsemi.com/Products/Development-hardware/nRF52840-Dongle/GetStarted

.. _Raspberry Pi 4B: https://www.raspberrypi.org/products/

Introduction
============

The purpose of this project is to provide a guided walk-through for building, commissioning, and testing Matter_ accessories.  `nRF52840 Dongles`_ are used as low-cost radios and microcontrollers.  A `Raspberry Pi 4B`_ is used for providing services.  Building and flashing firmware images can be done on a Linux Desktop or directly on the Raspberry Pi.  *Every* stage is Dockerized to prevent dependency issues on the host.

Project Components
------------------

- :doc:`../components/otbr`
- :doc:`../components/matter_thread_light` (WIP)
- Matter WiFi/Ethernet Light (TODO)
- Matter LAN Controller (TODO)
- Matter Cloud Controller (TODO)
