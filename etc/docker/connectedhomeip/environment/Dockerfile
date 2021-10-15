FROM ubuntu:21.04

RUN set -x \
    && apt-get update && apt-get upgrade -y \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get --no-install-recommends install -y git gcc g++ python pkg-config libssl-dev libdbus-1-dev libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev python3-pip unzip libgirepository1.0-dev libcairo2-dev bluez bluetooth usbutils avahi-utils

COPY ./entrypoint.sh /

RUN chmod a+x /entrypoint.sh

RUN mkdir /var/chip

WORKDIR /var/chip

ENTRYPOINT ["/bin/bash"]
