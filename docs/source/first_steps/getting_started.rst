.. _Raspberry Pi: https://www.raspberrypi.org/products/
.. _Best Working SSD / Storage Adapters for Raspberry Pi 4 / 400: https://jamesachambers.com/best-ssd-storage-adapters-for-raspberry-pi-4-400/
.. _Raspberry Pi 4 Bootloader USB Mass Storage Boot Guide: https://jamesachambers.com/new-raspberry-pi-4-bootloader-usb-network-boot-guide/
.. _ARM64 Raspberry Pi OS Lite: https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2021-05-28/
.. _nRF52840 Dongle: https://www.nordicsemi.com/Products/Development-hardware/nRF52840-Dongle/GetStarted
.. _docker: https://docs.docker.com/engine/install/ubuntu/
.. _Raspberry Pi Imager: https://www.raspberrypi.org/software/
.. _How to Boot Raspberry Pi 4 / 400 From a USB SSD or Flash Drive: https://www.tomshardware.com/how-to/boot-raspberry-pi-4-usb

Getting Started
===============

Project Components
------------------

- :doc:`../components/otbr`
- :doc:`../components/matter_thread_light` (WIP)
- Matter Ethernet Light (TODO)
- Matter LAN Controller (TODO)
- Matter Cloud Controller (TODO)

Project Requirements
--------------------

This guide covers multiple configurations for building and running the demo.  The **RPi + Linux Desktop** configuration features the fastest build and execution times.  If a Linux Desktop is not available, the **RPi Only** or **RPi + SSD** configurations may be used with the latter having slightly faster build times over using just an SD card in the RPi.

.. tabs::

   .. group-tab:: RPi + Linux Desktop

     - x64 Ubuntu Linux Desktop ("Linux Desktop" in this guide)
     - `Raspberry Pi`_ 4B ("RPi" in this guide)
     - 3x `nRF52840 Dongle`_
     - External 5V AC RPi adapter (CanaKit 3.5A USB-C Used)
     - 32gb+ microSD card ("SD card" in this guide, 32Gb EVO+ Class 10 used)
     - microSD card reader
     - Ethernet cable

   .. group-tab:: RPi Only

     - Desktop PC
     - `Raspberry Pi`_ 4B ("RPi" in this guide, RPi 4B used)
     - 3x `nRF52840 Dongle`_
     - External 5V AC RPi adapter (CanaKit 3.5A USB-C Used)
     - 32Gb+ microSD card ("SD card" in this guide, 32Gb EVO+ Class 10 used)
     - microSD card reader
     - Ethernet cable

   .. group-tab:: RPi + SSD

     - Desktop PC
     - `Raspberry Pi`_ 4B ("RPi" in this guide)
     - 3x `nRF52840 Dongle`_
     - External 5V AC RPi adapter (CanaKit 3.5A USB-C Used)
     - microSD card ("SD card" in this guide, 32Gb EVO+ Class 10 used)
     - 32Gb+ microSD card reader
     - Ethernet cable
     - powered USB 3.0 hub (Sabrent 5V/2.5A 4-port USB 3.0 hub used)
     - external USB SSD (Samsung T7 500GB SSD used)

     .. note::

        See `Best Working SSD / Storage Adapters for Raspberry Pi 4 / 400`_ and `Raspberry Pi 4 Bootloader USB Mass Storage Boot Guide`_ for recommended external storage options.

.. note::

   The Linux Desktop/Desktop PC and RPi will must be connected to the same LAN.

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
            sudo dpkg -i /path/to/imager_<X.Y.Z>_amd64.deb

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

         #. Plug the external USB SSD into the Desktop PC.

         #. Click **Choose Storage** and select the external USB SSD.

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

      If the boot medium is an external USB SSD, make sure to plug it in through the powered USB 3.0 hub to a USB 3.0 (blue) port on the RPi.  This ensures the nRF52840 dongles have enough power and the USB SSD has maximum throughput.  Briefly disconnect the hub from the RPi when first powering it on to ensure it doesn't use the hub for power.  Restore the hub's connection to the RPi a couple seconds after powering the RPi so it can boot off the external USB SSD.  **Software initiated reboots do not have this requirement.**

#. Once booted, SSH into the RPi from the Linux Desktop/Desktop PC.  If the hostname was change, the RPi can be reached via :code:`<hostname>.local`, otherwise, it should be reachable via :code:`raspberrypi.local`.  If multiple RPis are on the LAN, check the LAN's router for the correct IP address.

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

#. Set the RPi to the desired timezone.

   ::

      sudo timedatectl set-timezone America/Denver

#. Update the system.

   ::

      apt-get update && sudo apt-get upgrade -y


#. Disable Bluetooth management.

   ::

      sudo systemctl mask bluetooth

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

#. Create a docker network attached to the host's broadcast domain.

   .. note::

      The :code:`169.254.0.0/16` IPv4 link-local space won't be used for network traffic, but an IPv4 address is required by the docker network driver and every container connected directly to the host's broadcast domain needs a unique IPv4 address as it is used in MAC address generation.

   ::

      docker network create -d macvlan \
       --subnet=169.254.0.0/16 \
       -o parent=eth0 matter-bridge

#. Install git.

   ::

      sudo apt-get install -y git

#. Clone or update this project's repository.

   .. tabs::

      .. group-tab:: Clone

         ::

            git clone --recursive -j4 https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle.git
            cd matter-rpi4-nRF52840-dongle

      .. group-tab:: Update

         .. warning::

            Make sure any changes to main are saved in another branch or they will be lost.

         ::

            # change branch to main
            git checkout main
            # make local main the same as remote main (for the commit we are on locally)
            git reset --hard origin/main
            # do the same for every submodule (reverts any patches, build artifacts, etc.)
            git submodule foreach --recursive git reset --hard
            # update local main to match upstream's main (updates submodule git refs but not the files)
            git pull
            # update submodules for all the updated git refs
            git submodule update --init --recursive

#. Build the :code:`otbr` image.

   .. note::

      There is a preexisting image on Docker Hub for the RPi, but it will not work for this guide due to the use of a :code:`macvlan` network on :code:`eth1`.  Docker always places the :code:`bridge` network on :code:`eth0` if the container is restarted.

   ::

      (cd third_party/ot-br-posix \
       && docker build --build-arg INFRA_IF_NAME=eth1 -t openthread/otbr:latest -f etc/docker/Dockerfile .)

#. Build the :code:`chip-device-ctrl` image.

   ::

      docker build -t matter/chip-device-ctrl:latest etc/docker/chip-device-ctrl

Preparing the Linux Desktop
---------------------------

.. note::

   This section is for **RPi + Linux Desktop** configurations only.

#. Install `docker`_ if not present on the system.

   ::

      # check if installed
      docker --version

#. Add the current user to the :code:`docker` group.

   ::

      # check if in the docker group
      id -nG $USER | grep docker

      # add user to group if necessary
      sudo usermod -aG docker $USER

#. Log out and log back in so that group memberships are re-evaluated.

#. Capture the LAN interface.

   ::

      ping -c 1 matter-demo.local
      export LAN_IF=$(arp -a | grep matter-demo | awk 'NF>1{print $NF}')
      echo $LAN_IF

#. Create a docker network attached to the host's broadcast domain.

   .. note::

      The :code:`169.254.0.0/16` IPv4 link-local space won't be used for network traffic, but an IPv4 address is required by the docker network driver and every container connected directly to the host's broadcoast domain needs a unique IPv4 address as it is used in MAC address generation.

   ::

      docker network create -d macvlan \
       --subnet=169.254.0.0/16 \
       -o parent=$LAN_IF matter-bridge

#. Install git.

   ::

      sudo apt-get install -y git

#. Clone or update this project's repository.

   .. tabs::

      .. group-tab:: Clone

         ::

            git clone --recursive -j8 https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle.git
            cd matter-rpi4-nRF52840-dongle

      .. group-tab:: Update

         .. warning::

            Make sure any changes to main are saved in another branch or they will be lost.

         ::

            # change branch to main
            git checkout main
            # make local main the same as remote main (for the commit we are on locally)
            git reset --hard origin/main
            # do the same for every submodule (reverts any patches, build artifacts, etc.)
            git submodule foreach --recursive git reset --hard
            # update local main to match upstream's main (updates submodule git refs but not the files)
            git pull
            # update submodules for all the updated git refs
            git submodule update --init --recursive


Preparing the Build System
--------------------------

.. note::

   For an **RPi + Linux Desktop** configuration, the "build system" will be the Linux Desktop.  For an **RPi Only** or **RPi + SSD** configuration, the "build system" will be the RPi.

#. Pull or build the :code:`openthread/environment` image.

   .. tabs::

      .. group-tab:: RPi + Linux Desktop

         ::

            docker pull openthread/environment:latest

      .. group-tab:: RPi Only / RPi + SSD

         .. note::

            This patch updates :code:`pip` so the binary wheel of :code:`cmake` can be pulled on some architectures (i.e. ARM64).  The dependencies to build from source are not present on the base image nor are they installed as part of the :code:`Dockerfile`.

         ::

            # Dockerfile patch
            sed -i '/python3 -m pip install -U cmake/i \    && python3 -m pip install --upgrade pip \\' \
             third_party/connectedhomeip/third_party/openthread/repo/etc/docker/environment/Dockerfile

            # **NEW 9/15/2021 Dockerfile patch**
            # developer.arm.com updated their certificate and the intermediate certifcate
            # is missing from the ca-certificates package
            sed -i \
            -e '/cd openthread/i \    && apt-get install -y wget \\' \
            -e '/cd openthread/i \    && wget https:\/\/secure.globalsign.com\/cacert\/gsrsaovsslca2018.crt -P \/tmp \\' \
            -e '/cd openthread/i \    && openssl x509 -inform der -in \/tmp\/gsrsaovsslca2018.crt -out \/tmp\/gsrsaovsslca2018.pem \\' \
            -e '/cd openthread/i \    && mv /tmp/gsrsaovsslca2018.pem "\/etc\/ssl\/certs\/$(openssl x509 -noout -subject_hash -in \/tmp\/gsrsaovsslca2018.pem).0" \\' \
             third_party/connectedhomeip/third_party/openthread/repo/etc/docker/environment/Dockerfile

            # build the image
            (cd third_party/connectedhomeip/third_party/openthread/repo \
             && docker build -t openthread/environment:latest -f etc/docker/environment/Dockerfile .)

#. Build the :code:`nrfutil` image.

   ::

      docker build -t nordicsemi/nrfutil:latest etc/docker/nrfutil

#. Build the :code:`avahi-utils` image.

   ::

      docker build -t avahi/avahi-utils:latest etc/docker/avahi-utils

#. Build the :code:`ot-commissioner` image.

   ::

      docker build --build-arg TZ=$(cat /etc/timezone) -t openthread/ot-commissioner:latest /etc/docker/ot-commissioner

#. Pull or build the :code:`nrfconnect-chip` image.

   .. tabs::

      .. group-tab:: RPi + Linux Desktop

         ::

            docker pull nordicsemi/nrfconnect-chip:latest

      .. group-tab:: RPi Only / RPi + SSD

         ::

            # nrfconnect-toolchain Dockerfile patch
            sed -i \
             -e '/NRF_TOOLS_URL/d' \
             -e '/JLink/d' \
             -e '/nRF-Command-Line-Tools/d' \
             -e 's/\(libpython3-dev\) \\/\1 make \\/' \
             third_party/nrfconnect-chip-docker/nrfconnect-toolchain/Dockerfile

            # build the nrfconnect-toolchain image
            DOCKER_BUILD_ARGS='--build-arg TOOLCHAIN_URL=https://armkeil.blob.core.windows.net/developer/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-aarch64-linux.tar.bz2' \
             third_party/nrfconnect-chip-docker/nrfconnect-toolchain/build.sh --org nordicsemi

            # nrfconnect-chip Dockerfile patch
            sed -i \
             -e 's/amd64/arm64/' \
             -e 's/g++-multilib //' \
             third_party/nrfconnect-chip-docker/nrfconnect-chip/Dockerfile

            # build the nrfconnect-chip image
            third_party/nrfconnect-chip-docker/nrfconnect-chip/build.sh --org nordicsemi

References
----------

- `How to Boot Raspberry Pi 4 / 400 From a USB SSD or Flash Drive`_