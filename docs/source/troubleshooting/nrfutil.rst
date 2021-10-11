nrfutil Troubleshooting
=======================

LIBUSB_ERROR_NO_DEVICE
----------------------

.. note::

     This issue should be unlikely to occur anymore.  Earlier documentation mapped all devices to :code:`ttyACM0` which conflicted with the OTBR service running in privileged mode.

The following error may occur if multiple nRF52840 Dongles are connected to the USB bus when attempting to flash.  Remove all but the one that is being flashed and try again.  If errors still persist, reboot the build system.

::

   usb1.USBErrorNoDevice: LIBUSB_ERROR_NO_DEVICE

If the build system is the RPi, the OTBR service will need to be rebuilt and reconfigured.  Stop the container which automatically removes it and re-run :ref:`Setting Up OTBR` and :ref:`Verifying OTBR`.

::

   docker container stop otbr

If the Thread network cannot be formed after rebuilding and reconfiguring the service, stop the container again and start from :ref:`Flashing the RCP`.  Remove all other dongles from the RPi except the RCP.
