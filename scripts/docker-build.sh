#!/usr/bin/env -S bash -euET -o pipefail -O inherit_errexit

ARCH=$(uname -m)
if [[ $ARCH = "x86_64" ]]; then
  TARGETARCH='amd64'
elif [[ $ARCH = "aarch64" ]]; then
  TARGETARCH='arm64'
else
  echo "Unsupported architecture: $ARCH"
  exit 1;
fi

DOCKER_BUILDKIT=${DOCKER_BUILDKIT-}

AVAHI_UTILS=false
CHIP_ENVIRONMENT=false
OTBR=false
OT_COMMISSIONER=false
OT_NRF528XX_ENVIRONMENT=false
NRFCONNECT_CHIP=false
NRFUTIL=false

ORG=${ORG:-}
if [[ -n $ORG ]]; then ORG="$ORG/"; fi
DOCKER_BUILD=${DOCKER_BUILD:-docker build}
VERSION=${VERSION:-latest}

while [ $# -gt 0 ] ; do
  case $1 in
    --avahi-utils) AVAHI_UTILS=true ;;
    --chip-environment) CHIP_ENVIRONMENT=true ;;
    --otbr) OTBR=true ;;
    --ot-commissioner) OT_COMMISSIONER=true ;;
    --ot-nrf528xx-environment) OT_NRF528XX_ENVIRONMENT=true ;;
    --nrfconnect-chip) NRFCONNECT_CHIP=true ;;
    --nrfutil) NRFUTIL=true ;;
    --all) AVAHI_UTILS=true; CHIP_ENVIRONMENT=true; OTBR=true; OT_COMMISSIONER=true; OT_NRF528XX_ENVIRONMENT=true; NRFCONNECT_CHIP=true; NRFUTIL=true ;;
  esac
  shift
done

declare -A HASHES=(
  ['third_party/ot-nrf528xx/openthread/etc/docker/environment/Dockerfile']='14ca28d53cfbbf8c99d33fd31d3c7511'
  ['third_party/nrfconnect-chip-docker/nrfconnect-toolchain/Dockerfile']='0dceb02b0e528798bc54209547baefb5'
  ['third_party/nrfconnect-chip-docker/nrfconnect-chip/Dockerfile']='4878612ae4cebb9d69deabe46cc234d9'
)

declare -A HASH_CHECKS=(
  ['third_party/ot-nrf528xx/openthread/etc/docker/environment/Dockerfile']=$OT_NRF528XX_ENVIRONMENT
  ['third_party/nrfconnect-chip-docker/nrfconnect-toolchain/Dockerfile']=$NRFCONNECT_CHIP
  ['third_party/nrfconnect-chip-docker/nrfconnect-chip/Dockerfile']=$NRFCONNECT_CHIP
)

check_hash () {
  # shellcheck disable=SC2207
  MD5=($(md5sum "$1"))
  if [[ -v "HASHES[$1]" && -v "HASH_CHECKS[$1]" && ${HASH_CHECKS[$1]} && ${MD5[0]} != "${HASHES[$1]}" ]]; then
    echo -e "HASH_ERROR: $1\n"
    echo "Unable to patch file, hash mismatch."
    echo -e "Manually validate the patch and update the hash to proceed.\n"
    echo "FILE:     ${MD5[1]}"
    echo "COMPUTED: ${MD5[0]}"
    echo "EXPECTED: ${HASHES[$1]}"
    exit 1;
  fi
}

(
  cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  cd ..

  if [[ $AVAHI_UTILS = true ]]; then
    (set -x && $DOCKER_BUILD -t "${ORG}avahi-utils:$VERSION" etc/docker/avahi/avahi-utils)
  fi

  if [[ $OTBR = true ]]; then
    (cd third_party/ot-br-posix \
       && set -x && $DOCKER_BUILD --build-arg INFRA_IF_NAME=eth1 -t "${ORG}otbr:$VERSION" -f etc/docker/Dockerfile .)
  fi

  if [[ $OT_COMMISSIONER = true ]]; then
    (cd third_party/ot-commissioner && set -x && $DOCKER_BUILD \
     -t "${ORG}ot-commissioner:$VERSION" -f ../../etc/docker/openthread/ot-commissioner/Dockerfile .)
  fi

  if [[ $OT_NRF528XX_ENVIRONMENT = true ]]; then
    (cd third_party/ot-nrf528xx/openthread && git reset --hard)
    check_hash 'third_party/ot-nrf528xx/openthread/etc/docker/environment/Dockerfile'

    # shellcheck disable=SC1003
    sed -i \
      -e '21,$d' \
      -e '/python3 -m pip install -U cmake/i \    && python3 -m pip install --upgrade pip \\' \
      third_party/ot-nrf528xx/openthread/etc/docker/environment/Dockerfile

    (cd third_party/ot-nrf528xx/openthread \
      && set -x && $DOCKER_BUILD -t "${ORG}ot-nrf528xx-environment:$VERSION" -f etc/docker/environment/Dockerfile .)
  fi

  if [[ $CHIP_ENVIRONMENT = true ]]; then
    (set -x && $DOCKER_BUILD -t "${ORG}chip-environment:$VERSION" etc/docker/connectedhomeip/environment)
  fi

  if [[ $NRFCONNECT_CHIP = true ]]; then
    (cd third_party/nrfconnect-chip-docker && git reset --hard)
    check_hash 'third_party/nrfconnect-chip-docker/nrfconnect-toolchain/Dockerfile'
    check_hash 'third_party/nrfconnect-chip-docker/nrfconnect-chip/Dockerfile'

    # shellcheck disable=SC2016
    sed -i \
      -e '44,52d' \
      -e 's/\${TOOLCHAIN_URL}/https:\/\/developer.arm.com\/-\/media\/Files\/downloads\/gnu-rm\/9-2020q2\/gcc-arm-none-eabi-9-2020-q2-update-$(uname -m)-linux.tar.bz2/' \
      -e 's/\(libpython3-dev\) \\/\1 make \\/' \
      -e 's/gcc-arm-none-eabi-9-2019-q4-major/gcc-arm-none-eabi-9-2020-q2-update/' \
      third_party/nrfconnect-chip-docker/nrfconnect-toolchain/Dockerfile

    (cd third_party/nrfconnect-chip-docker/nrfconnect-toolchain \
     && set -x && $DOCKER_BUILD -t "${ORG}nrfconnect-toolchain:$VERSION" .)

    [[ -z "$DOCKER_BUILDKIT" ]] && FLAGS="--build-arg TARGETARCH=$TARGETARCH" || FLAGS=''

    # shellcheck disable=SC2016
    sed -i \
      -e '/^ARG NCS_REVISION/i \ARG TARGETARCH' \
      -e 's/amd64/${TARGETARCH}/' \
      -e 's/g++-multilib //' \
      third_party/nrfconnect-chip-docker/nrfconnect-chip/Dockerfile

    # shellcheck disable=SC2086
    (cd third_party/nrfconnect-chip-docker/nrfconnect-chip \
     && set -x && $DOCKER_BUILD $FLAGS \
      --build-arg "BASE=${ORG}nrfconnect-toolchain:$VERSION" -t "${ORG}nrfconnect-chip:$VERSION" .)
  fi

  if [[ $NRFUTIL = true ]]; then
    (set -x && $DOCKER_BUILD -t "${ORG}nrfutil:$VERSION" etc/docker/nordicsemi/nrfutil)
  fi
)