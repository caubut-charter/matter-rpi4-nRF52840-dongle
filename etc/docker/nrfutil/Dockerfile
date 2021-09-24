FROM ubuntu:21.04

RUN set -x \
    && apt-get update && apt-get upgrade -y \
    && apt-get install --no-install-recommends -y ca-certificates git build-essential cmake ninja-build libudev-dev libusb-1.0-0 swig python3 python3-pip libpython3-dev \
    && python3 -m pip install --upgrade pip \
    # clone Nordic's version of vcpkg
    && git clone https://github.com/NordicPlayground/vcpkg.git \
    && (cd vcpkg \
    # bootstrap known working version
    && git checkout 30e529d \
    && ./bootstrap-vcpkg.sh -useSystemBinaries \
    # generate ARM64 Linux target
    && cp ./triplets/x64-linux.cmake ./triplets/$(uname -m)-linux.cmake \
    && sed -i "1s/.*/set(VCPKG_TARGET_ARCHITECTURE $(uname -m))/" ./triplets/$(uname -m)-linux.cmake \
    && echo 'set(VCPKG_BUILD_TYPE release)' >> ./triplets/$(uname -m)-linux.cmake \
    # install nrf-ble-driver
    && VCPKG_DEFAULT_TRIPLET=$(uname -m)-linux ./vcpkg install nrf-ble-driver) \
    # clone nrf-ble-driver-py
    && git clone https://github.com/NordicSemiconductor/pc-ble-driver-py \
    && (cd pc-ble-driver-py \
    # checkout known working version
    && git checkout v0.14.2 \
    && sed -i '/^ninja/d' requirements-dev.txt \
    && python3 -m pip install --ignore-installed -r requirements-dev.txt \
    # build nrf-ble-driver-py
    && CMAKE_PREFIX_PATH=$PWD/../vcpkg/installed/$(uname -m)-linux/share/nrf-ble-driver python3 setup.py bdist_wheel --build-type Release \
    # install nrf-ble-driver-py
    && python3 -m pip install dist/*) \
    # install known working version of nrfutil
    && python3 -m pip install -U nrfutil==6.1.0 \
    # clean up
    && rm -rf /vcpkg \
    && rm -rf /pc-ble-driver-py \
    && apt-get -y remove ca-certificates git build-essential cmake ninja-build libudev-dev swig python3-pip libpython3-dev \
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* ~/.cache/*

WORKDIR /root

ENTRYPOINT ["/usr/local/bin/nrfutil"]
