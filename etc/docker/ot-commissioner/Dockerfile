FROM openthread/environment:latest AS builder

ARG DEBIAN_FRONTEND noninteractive
ARG TZ America/Denver
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN set -x \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && git clone https://github.com/openthread/ot-commissioner \
    && (cd ot-commissioner \
    && ./script/bootstrap.sh \
    && mkdir build \
    && (cd build \
    && cmake -DCMAKE_INSTALL_PREFIX=/app/ot-commissioner -GNinja .. \
    && ninja -j1 \
    && mkdir -p /app/ot-commissioner \
    && ninja install))

FROM ubuntu:18.04

ARG DEBIAN_FRONTEND noninteractive
ARG TZ America/Denver
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN set -x \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && apt-get update && apt-get upgrade -y \
    && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && apt-get install --no-install-recommends -fy libreadline7 \
    && apt-get -y clean && apt-get -y autoremove \
    && rm -rf /tmp/* /var/lib/apt/lists/* ~/.cache/*

COPY --from=builder /app/ot-commissioner/ /usr/local/

ENTRYPOINT ["/usr/local/bin/commissioner-cli"]
