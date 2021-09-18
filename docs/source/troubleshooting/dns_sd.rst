DNS-SD Troubleshooting
======================

The :code:`avahi-utils` image allows checking of DNS-SD results from what docker containers will see on the :code:`matter-bridge` network.  This is useful from the RPi as DNS-SD records will leak from the :code:`docker0` interface with incorrect addresses if commands are run from the host.  The following examples assume the OTBR service is running and configured.


Scanning Services
-----------------

   .. warning:: The chosen IPv4 address must be unique from other docker containers on the host's broadcast domain to ensure a unique MAC address is generated.

   .. note::

      This command continually scans.  Hit :code:`CTRL-C` to exit.

   ::

      docker run -it --rm  --privileged \
       --network matter-bridge --ip 169.254.200.0 \
       --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
       avahi/avahi-utils:latest avahi-browse -lr _meshcop._udp

Resolving IPv6 Hostnames
------------------------

   .. warning:: The chosen IPv4 address must be unique from other docker containers on the host's broadcast domain to ensure a unique MAC address is generated.

   ::

      docker run -it --rm  --privileged \
       --network matter-bridge --ip 169.254.200.0 \
       --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
       avahi/avahi-utils:latest avahi-resolve -6 --name otbr.local

Resolving IPv4 Hostnames
------------------------

   .. warning:: The chosen IPv4 address must be unique from other docker containers on the host's broadcast domain to ensure a unique MAC address is generated.

   .. note::

      This guide uses IPv6 exclusively for the Matter network, so this query should timeout.

   ::

      docker run -it --rm  --privileged \
       --network matter-bridge --ip 169.254.200.0 \
       --sysctl "net.ipv6.conf.all.disable_ipv6=0" \
       avahi/avahi-utils:latest avahi-resolve -4 --name otbr.local
