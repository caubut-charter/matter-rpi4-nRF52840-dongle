FROM ubuntu:18.04 AS builder

COPY . /ot-commissioner

RUN set -x \
    && apt-get update && apt-get upgrade -y \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get --no-install-recommends install -fy \
        git \
        python3 \
        python3-pip \
        sudo \
    && (cd ot-commissioner \
    && ./script/bootstrap.sh \
    && mkdir build \
    && (cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/app/ot-commissioner -GNinja .. \
    && ninja -j1 \
    && mkdir -p /app/ot-commissioner \
    && ninja install))

FROM ubuntu:18.04

RUN set -x \
    && apt-get update && apt-get upgrade -y \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get install --no-install-recommends -fy libreadline7 \
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* ~/.cache/*

COPY --from=builder /app/ot-commissioner/ /usr/local/

ENTRYPOINT ["/usr/local/bin/commissioner-cli"]
