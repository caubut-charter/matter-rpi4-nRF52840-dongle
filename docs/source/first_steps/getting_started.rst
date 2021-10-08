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

Project Requirements
--------------------

This guide covers multiple recommended configurations.  The **RPi + Linux Desktop** configuration features the fastest build and execution times.  If a Linux Desktop is not available, the **RPi Only** or **RPi + SSD** configurations may be used with the latter having slightly faster build times over using just an SD card in the RPi.

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
     - 64Gb+ microSD card ("SD card" in this guide, 64Gb EVO+ Class 10 used)
     - microSD card reader
     - Ethernet cable

   .. group-tab:: RPi + SSD

     - Desktop PC
     - `Raspberry Pi`_ 4B ("RPi" in this guide)
     - 3x `nRF52840 Dongle`_
     - External 5V AC RPi adapter (CanaKit 3.5A USB-C Used)
     - microSD card ("SD card" in this guide, just to hold bootloader, 32Gb EVO+ Class 10 used)
     - microSD card reader
     - Ethernet cable
     - powered USB 3.0 hub (Sabrent 5V/2.5A 4-port USB 3.0 hub used)
     - external USB 3.0 SSD (Samsung T7 500GB SSD used)

     .. note::

        See `Best Working SSD / Storage Adapters for Raspberry Pi 4 / 400`_ and `Raspberry Pi 4 Bootloader USB Mass Storage Boot Guide`_ for recommended external storage options.

.. note::

   The Linux Desktop/Desktop PC and RPi must be connected to the same LAN.

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

            # clone the repository
            git clone https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle.git
            cd matter-rpi4-nRF52840-dongle

            # setup third-party dependencies
            ./scripts/setup

      .. group-tab:: Update

         .. warning::

            Changes to the current branch will be reset.  If desired, stash or save in another branch or they will be lost.

         ::

            # fetch changes from the upstream repository
            git fetch
            # reset any changes
            git reset --hard
            # update local main to origin main
            git checkout -B main origin/main
            # update third-party dependencies
            ./scripts/setup

#. Optionally, update third-party dependencies.  Third-party dependencies are defined in :code:`.third_party` and are fixed to specific commits (like git submodules) last tested with this guide.  Due to the frequent activity in each third-party repository, the setup script can also be used to update a third-party dependency to the latest version, the latest version of a specific branch, or a specific commit.  Below are some examples.

   ::

      # update all third-party dependencies to their latest version
      ./scripts/setup -u

      # update all third-party dependencies to match .third_party,
      # except switch to the latest commit in the stable 'test_event_6' branch
      # of the connectedhomeip project
      MATTER_BRANCH=test_event_6 scripts/setup

      # update all third-party dependencies to their latest version,
      # except switch to the latest commit in the stable 'test_event_6' branch
      # of the connectedhomeip project
      MATTER_BRANCH=test_event_6 scripts/setup -u

      # update all third-party dependencies to match .third_party,
      # except switch to a specific commit of the connectedhomeip project
      MATTER_COMMIT=<hash> scripts/setup

#. Build the :code:`openthread/otbr` image.

   .. note::

      There is a preexisting image on Docker Hub for the RPi, but it will not work for this guide due to the use of a :code:`macvlan` network on :code:`eth1`.  Docker always places the :code:`bridge` network on :code:`eth0` if the container is restarted.

   ::

      (cd third_party/ot-br-posix \
       && docker build --build-arg INFRA_IF_NAME=eth1 -t openthread/otbr:latest -f etc/docker/Dockerfile .)

#. Build the required docker images.

   ::

      ./scripts/docker-build \
       --matter/environment \
       --openthread/otbr

#. Optionally, remove any build layers to recover disk space.

   .. warning::

      This will remove any build layers and untagged images not attached to a container on the entire system, even for other users or projects.

   ::

      docker image prune

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
      export LAN_IF=$(arp -a | grep $(avahi-resolve -4 --name matter-demo.local | awk '{print $2}') | awk 'NF>1{print $NF}')
      echo $LAN_IF

#. Create a docker network attached to the host's broadcast domain.

   .. note::

      The :code:`169.254.0.0/16` IPv4 link-local space won't be used for network traffic, but an IPv4 address is required by the docker network driver and every container connected directly to the host's broadcast domain needs a unique IPv4 address as it is used in MAC address generation.

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

            # clone the repository
            git clone https://github.com/caubut-charter/matter-rpi4-nRF52840-dongle.git
            cd matter-rpi4-nRF52840-dongle

            # setup third-party dependencies
            ./scripts/setup

      .. group-tab:: Update

         .. warning::

            Changes to the current branch will be reset.  If desired, stash or save in another branch or they will be lost.

         ::

            # fetch changes from the upstream repository
            git fetch
            # reset any changes
            git reset --hard
            # update local main to origin main
            git checkout -B main origin/main
            # update third-party dependencies
            ./scripts/setup

#. Optionally, update third-party dependencies.  Third-party dependencies are defined in :code:`.third_party` and are fixed to specific commits (like git submodules) last tested with this guide.  Due to the frequent activity in each third-party repository, the setup script can also be used to update a third-party dependency to the latest version, the latest version of a specific branch, or a specific commit.  Below are some examples.

   ::

      # update all third-party dependencies to their latest version
      ./scripts/setup -u

      # update all third-party dependencies to match .third_party,
      # except switch to the latest commit in the stable 'test_event_6' branch
      # of the connectedhomeip project
      MATTER_BRANCH=test_event_6 scripts/setup

      # update all third-party dependencies to their latest version,
      # except switch to the latest commit in the stable 'test_event_6' branch
      # of the connectedhomeip project
      MATTER_BRANCH=test_event_6 scripts/setup -u

      # update all third-party dependencies to match .third_party,
      # except switch to a specific commit of the connectedhomeip project
      MATTER_COMMIT=<hash> scripts/setup

Preparing the Build System
--------------------------

.. note::

   For an **RPi + Linux Desktop** configuration, the "build system" will be the Linux Desktop.  For an **RPi Only** or **RPi + SSD** configuration, the "build system" will be the RPi.

#. Build the required docker images.

   ::

      ./scripts/docker-build \
       --avahi/avahi-utils \
       --openthread/environment \
       --openthread/ot-commissioner \
       --nordicsemi/nrfconnect-chip \
       --nordicsemi/nrfutil

#. Optionally, remove any build layers to recover disk space.

   .. warning::

      This will remove any build layers and untagged images not attached to a container on the entire system, even for other users or projects.

   ::

      docker image prune

   ::

      $ du -h --max-depth=1 third_party
      192M    third_party/ot-nrf528xx
      786M    third_party/ot-commissioner
      960K    third_party/nrfconnect-chip-docker
      4.9G    third_party/connectedhomeip
      237M    third_party/ot-br-posix
      6.1G    third_party


+---------------------------+-----------------------------------------------+--------------------------------------------------------------------+
| :code:`bootstrap`         | :code:`build`                                 | Artifact                                                           |
+===========================+===============================================+====================================================================+
| :code:`--ot-br-posix`     | :code:`--otbr-image`                          | OpenThread Border Router container image                           |
+---------------------------+-----------------------------------------------+--------------------------------------------------------------------+
| :code:`--ot-nrf528xx`     | :code:`--ot-nrf528xx-environment-image`       | OpenThread RCP firmware build environment container image          |
|                           |                                               +--------------------------------------------------------------------+
|                           | :code:`--nrf52840-dongle-ot-rcp`              | OpenThread RCP firmware                                            |
+---------------------------+-----------------------------------------------+--------------------------------------------------------------------+
| :code:`--ot-commissioner` | :code:`--ot-commissioner-image`               | OpenThread commissioner container image                            |
+---------------------------+-----------------------------------------------+--------------------------------------------------------------------+
| :code:`--chip`            | :code:`--nrfconnect-toolchain-image`          | Base container image for :code:`nrfconnect-chip-environment-image` |
|                           |                                               +--------------------------------------------------------------------+
| :code:`--nrfconnect-chip` | :code:`--nrfconnect-chip-environment-image`   | nRF52840 dongle-Matter build environment container image           |
|                           |                                               +--------------------------------------------------------------------+
|                           | :code:`--nrf52840-dongle-thread-lighting-app` | nRF52840 dongle Thread light firmware                              |
+---------------------------+-----------------------------------------------+--------------------------------------------------------------------+
| :code:`--chip`            | :code:`--chip-environment-image`              | General Matter build and runtime environment                      |
|                           |                                               +--------------------------------------------------------------------+
|                           | :code:`--chip-device-ctrl`                    | Python Matter controller                                           |
+---------------------------+-----------------------------------------------+--------------------------------------------------------------------+
|                           | :code:`--avahi-utils-image`                   | DNS-SD utilities                                                   |
+---------------------------+-----------------------------------------------+--------------------------------------------------------------------+
|                           | :code:`--nrfutil-image`                       | nRF52840 dongle flashing utility container image                   |
+---------------------------+-----------------------------------------------+--------------------------------------------------------------------+


References
----------

- `How to Boot Raspberry Pi 4 / 400 From a USB SSD or Flash Drive`_
