.. _Raspberry Pi: https://www.raspberrypi.org/products/
.. _ARM64 Raspberry Pi OS Lite: https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-05-28/
.. _nRF52840 Dongle: https://www.nordicsemi.com/Products/Development-hardware/nRF52840-Dongle/GetStarted
.. _docker: https://docs.docker.com/engine/install/ubuntu/
.. _Raspberry Pi Imager: https://www.raspberrypi.org/software/
.. _Configuring OpenThread Radio Co-processor on nRF52840 Dongle: https://github.com/project-chip/connectedhomeip/blob/master/docs/guides/openthread_rcp_nrf_dongle.md
.. _Build OpenThread: https://openthread.io/guides/build
.. _nRF Util: https://www.nordicsemi.com/Products/Development-tools/nrf-util
.. _CHIP nRF Connect Lighting Example Application: https://github.com/project-chip/connectedhomeip/tree/master/examples/lighting-app/nrfconnect#setting-up-the-environment

Getting Started
===============

Project Requirements
--------------------

- Desktop PC
- `Raspberry Pi`_ 4B ("RPi" in this guide)
- 3x `nRF52840 Dongle`_
- External 5V AC RPi adapter (3.5A Used)
- 32Gb+ microSD card ("SD card" in this guide)
- microSD card reader
- Ethernet cable

.. warning::

   The RPi must use an external AC adapter of the proper voltage.  Do not power from a USB hub or a computer's USB port.

Preparing the RPi Boot Medium
-----------------------------

#. On the Linux Desktop/Desktop PC, download and extract the `ARM64 Raspberry Pi OS Lite`_ image.

   .. note::

      The 64-bit version is *required* for the **RPi Only** or **RPi + SSD** configurations to run the OpenThread build toolchain.

   .. tabs::

      .. group-tab:: Linux

         ::

            cd ~/Downloads
            unzip YYYY-MM-DD-raspios-buster-arm64-lite.zip

      .. group-tab:: macOS

         Double click the :code:`.zip` archive to extract the :code:`.img` in the same folder.


      .. group-tab:: Windows

         Double click the :code:`.zip` archive.  Drag the :code:`.img` file to a desired location.

#. Download, install, and run `Raspberry Pi Imager`_.

   .. tabs::

      .. group-tab:: Linux

         ::

            # this will probably fail due to missing dependencies, that's okay
            sudo dpkg -i imager_<X.Y.Z>_amd64.deb

            # this fixes it
            sudo apt-get install -f

            # refresh binaries known to the shell
            hash -r

            # launch the app
            rpi-imager

      .. group-tab:: macOS

            Install to **Applications** from the downloaded :code:`.dmg` file and run the app.

      .. group-tab:: Windows

            Run the downloaded :code:`.exe` installer and run the app.

#. Install the OS onto the RPi's boot medium.

   .. tabs::

      .. group-tab:: RPi + Linux Desktop

         #. Click **Choose OS** > **Use custom**  and select the :code:`YYYY-MM-DD-raspios-buster-arm64-lite.img`.

         #. Plug the microSD card reader and SD card into the Linux Desktop.

         #. Click **Choose Storage** and select the SD card.

         #. Click **Write**.

      .. group-tab:: RPi Only

         #. Click **Choose OS** > **Use custom**  and select the :code:`YYYY-MM-DD-raspios-buster-arm64-lite.img`.

         #. Plug the microSD card reader and SD card into the Desktop PC.

         #. Click **Choose Storage** and select the SD card.

         #. Click **Write**.

      .. group-tab:: RPi + SSD

         #. Click **Choose OS** > **Misc utility images** > **Bootloader** > **USB Boot**.

         #. Plug the microSD card reader and SD card into the Desktop PC.

         #. Click **Choose Storage** and select the SD card.

         #. Click **Write**.

         #. Safely eject the SD card and plug it into the RPi.

         #. Click **Choose OS** > **Use custom**  and select the :code:`YYYY-MM-DD-raspios-buster-arm64-lite.img`.

         #. Plug the external USB 3.0 SSD into the Desktop PC.

         #. Click **Choose Storage** and select the external USB 3.0 SSD.

         #. Click **Write**.

#. Enable SSH on boot.  A FAT32 :code:`boot` partition should have mounted once the OS has been installed.  If it did not, check the system's documentation for mounting the partition.  Reseat the boot medium if all else fails.  Add an empty file called :code:`ssh` into the root of the partition.

   .. tabs::

      .. group-tab:: Linux

         Clicking on the volume in any modern File Manager will typically mount the partition.

         ::

            touch /media/$USER/boot/ssh

      .. group-tab:: macOS

         The volume can be mounted using :code:`Disk Utility`.

         ::

            touch /Volumes/boot/ssh

      .. group-tab:: Windows

         From Windows Explorer, navigate to the mounted partition, right-click in the folder, and select **New** > **Text Document**.  Name the file :code:`ssh` without any file extension.

#. Optionally, change the RPi's hostname ("matter-demo" in this guide) to avoid naming conflicts with other RPis on the LAN.  An EXT4 :code:`rootfs` partition should have mounted once the OS has been installed.  If it did not, check the system's documentation for mounting the partition.  For systems that cannot mount writeable EXT4 partitions, this step can be performed later directly on the RPi.  The hostname will be used to connect to the RPi (e.g. :code:`matter-demo.local`).

   .. tabs::

      .. group-tab:: Linux

         ::

            # verify the existing hostname (default is "raspberrypi")
            cat /media/$USER/rootfs/etc/hostname

            # overwrite the hostname and verify
            echo matter-demo | sudo tee /media/$USER/rootfs/etc/hostname
            cat /media/$USER/rootfs/etc/hostname

#. Safely eject the RPi's boot medium and remove it from the Linux Desktop/Desktop PC.

#. For the **RPi + SSD** configuration, update the bootloader for USB boot.  The SD card should already be plugged into the RPi.  Power the RPi to update the bootloader from the SD card.  The green activity light will blink a steady pattern once the update has been completed.  If an HDMI monitor is attached to the RPi, the screen will go green once the update is complete. Allow 10 seconds or more for the update to complete.  Do not remove the SD card until the update is complete.  Power off the RPi and remove the SD card.

#. Plug the boot medium into the RPi, connect the RPi to the LAN via Ethernet, and power it on.

   .. warning::

      If the boot medium is an external USB 3.0 SSD, make sure to plug it in through the powered USB 3.0 hub to a USB 3.0 (blue) port on the RPi.  This ensures the nRF52840 dongles have enough power and the USB SSD has maximum throughput.  Briefly disconnect the hub from the RPi when first powering it on to ensure it doesn't use the hub for power.  Restore the hub's connection to the RPi a couple seconds after powering the RPi so it can boot off the external USB 3.0 SSD.  **Software initiated reboots do not have this requirement.**

#. Once booted, SSH into the RPi from the Linux Desktop/Desktop PC.  If the hostname was changed, the RPi can be reached via :code:`<hostname>.local`, otherwise, it should be reachable via :code:`raspberrypi.local`.  If multiple RPis are on the LAN, check the LAN's router for the correct IP address.

   ::

      # default password is "raspberry"
      ssh pi@matter-demo.local

.. _Preparing the RPi:

Preparing the RPi
-----------------

#. Optionally, if not already done, change the RPi's hostname ("matter-demo" in this guide) to avoid naming conflicts with other RPis on the LAN.

   ::

      # verify the existing hostname (default is "raspberrypi")
      cat /etc/hostname

      # overwrite the hostname and verify
      echo matter-demo | sudo tee /etc/hostname
      cat /etc/hostname

#. Update the system.

   ::

      sudo apt-get update && sudo apt-get upgrade -y

#. Reboot the RPi and reconnect to it.

   ::

      sudo reboot
      ssh pi@matter-demo.local

#. Install docker.

   ::

      curl -sSL https://get.docker.com | sh
      sudo usermod -aG docker $USER

#. Log out and log back in so that group memberships are re-evaluated.

   ::

      exit
      ssh pi@matter-demo.local

#. Install additional packages.

   ::

      sudo apt-get install -y \
       avahi-utils \
       build-essential \
       git \
       libbz2-dev \
       libcairo2-dev \
       libexpat-dev \
       libffi-dev \
       libgdbm-compat-dev \
       libgdbm-dev \
       libgirepository1.0-dev \
       libglib2 \
       liblzma-dev \
       libncurses-dev \
       libreadline-dev \
       libsqlite3-dev \
       libssl-dev \
       uuid-dev
      sudo apt autoremove

#. Build and install Matter compatible version of python.

   ::

      wget -c https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tar.xz -O - | tar -xJ
      cd Python-3.9.7

      ./configure --enable-optimizations --enable-shared --with-system-expat
      make -j4
      sudo make install
      sudo ldconfig -v
      sudo pip3 install --upgrade pip

      cd ..
      sudo rm -rf Python-3.9.7*

#. Clone or update this project's repository.

   .. tabs::

      .. group-tab:: Clone

         ::

            # clone the repository
            git clone https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle.git
            cd matter-rpi4-nRF52840-dongle

      .. group-tab:: Update

         .. warning::

            Changes to the current branch will be reset.  If desired, stash or save in another branch or they will be lost.

         ::

            # fetch changes from the upstream repository
            git fetch
            # reset any changes
            # update local main to origin main
            git checkout -B main origin/main

#. Download dependencies.

   ::

      # CHIP latest
      script/bootstrap -f --all

      # CHIP test event
      script/bootstrap -f --chip test_event_6 --all

#. Build/download artifacts and install.

   .. tabs::

      .. tab:: Build

         ::

            DOCKER_IMAGE_PREFIX=caubutcharter script/setup --clean --all

      .. tab:: Download

         .. note::

            OpenThread Border Router and :code:`chip-device-ctrl` still need to be built locally.

         ::

            export BASE_URL=https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle/releases/download/nightly
            docker pull caubutcharter/ot-commissioner:latest
            docker pull caubutcharter/nrfutil:latest
            script/setup --clean --otbr --chip-device-ctrl
            wget -c $BASE_URL/nrf52840-dongle-ot-rcp.zip -P build/Release

            # CHIP latest
            wget -c $BASE_URL/nrf52840-dongle-thread-lighting-app-LATEST.zip -P build/Release

            # CHIP test event
            wget -c $BASE_URL/nrf52840-dongle-thread-lighting-app-TEST_EVENT_6.zip -P build/Release

#. Optionally, remove remove old container images and build layers to recover disk space.

   .. warning::

      This will remove any untagged container images and build layers not attached to a container on the entire system, even for other users or projects.

   ::

      docker image prune

References
----------

- `Configuring OpenThread Radio Co-processor on nRF52840 Dongle`_
- `Build OpenThread`_
- `nRF Util`_
- `CHIP nRF Connect Lighting Example Application`_
