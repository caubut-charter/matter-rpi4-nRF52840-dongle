#!/usr/bin/env bash

git submodule foreach --recursive git reset --hard

(cd third_party/connectedhomeip \
 && git checkout master && git pull && git submodule update --init --recursive)

(cd third_party/ot-nrf528xx \
 && git checkout main && git pull && git submodule update --init --recursive)

(cd third_party/ot-br-posix \
 && git checkout main && git pull && git submodule update --init --recursive)

(cd third_party/nrfconnect-chip-docker \
 && git checkout master && git pull && git submodule update --init --recursive)
