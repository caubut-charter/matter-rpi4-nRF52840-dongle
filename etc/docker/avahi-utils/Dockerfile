FROM ubuntu:20.10

RUN set -x \
    && apt-get update && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y net-tools iproute2 avahi-utils \
    && service dbus start \
    && service avahi-daemon start \
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* ~/.cache/*

COPY ./entrypoint.sh /

RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
