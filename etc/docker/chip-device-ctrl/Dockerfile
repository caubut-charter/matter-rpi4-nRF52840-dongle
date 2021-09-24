FROM ubuntu:21.04 AS builder

ARG CHIP_HASH=master

WORKDIR /connectedhomeip

RUN set -x \
    && apt-get update && apt-get upgrade -y \
    && apt-get --no-install-recommends install -y git gcc g++ python pkg-config libssl-dev libdbus-1-dev libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev python3-pip unzip libgirepository1.0-dev libcairo2-dev bluez \
    && git clone https://github.com/project-chip/connectedhomeip.git . \
    && git checkout $CHIP_HASH \
    && scripts/build_python.sh -m platform

FROM ubuntu:20.10

RUN set -x \
    && apt-get update && apt-get upgrade -y \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get --no-install-recommends install -y python3 libssl1.1 libglib2.0 libavahi-client3 python3-venv bluez bluetooth usbutils \
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* ~/.cache/*

COPY --from=builder /connectedhomeip/out/python_env /connectedhomeip/out/python_env

WORKDIR /connectedhomeip

COPY ./entrypoint.sh /

RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
