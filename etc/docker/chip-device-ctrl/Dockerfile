FROM ubuntu:20.10

RUN set -x \
    && apt-get update && apt-get upgrade -y \
    && apt-get --no-install-recommends install -y git gcc g++ python pkg-config libssl-dev libdbus-1-dev libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev python3-pip unzip libgirepository1.0-dev libcairo2-dev bluez bluetooth usbutils \
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* ~/.cache/*

COPY ./entrypoint.sh /

RUN chmod a+x /entrypoint.sh

WORKDIR /app/third_party/connectedhomeip

ENTRYPOINT ["/entrypoint.sh"]
