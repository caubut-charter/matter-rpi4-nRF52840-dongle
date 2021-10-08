#!/usr/bin/env -S bash -euET -o pipefail -O inherit_errexit

declare -A DOT_THIRD_PARTY
REPOS=()
declare -A URL
declare -A BRANCH
declare -A COMMIT

UPDATE=false
ONLY=''

while [ $# -gt 0 ] ; do
  case $1 in
    -u | --update) UPDATE=true ;;
    -o | --only) ONLY=$2 ;;
  esac
  shift
done

(
  cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  cd ..
  while IFS="=" read -r KEY VALUE; do
    if [[ $KEY == '' || $VALUE = '' || $KEY =~ ^[[:space:]]*#.*$ ]]; then
      continue
    fi
    DOT_THIRD_PARTY[$KEY]=$VALUE
  done < ".third_party"
  for KEY in "${!DOT_THIRD_PARTY[@]}"; do
    REPOS+=("${KEY%_*}")
    declare -n ARRAY=${KEY##*_}
    declare -n VALUE=$KEY
    # shellcheck disable=SC2034
    ARRAY[${KEY%_*}]=${VALUE:-${DOT_THIRD_PARTY[$KEY]}}
    unset -n ARRAY
  done
  # shellcheck disable=SC2207
  REPOS=($(printf "%s\n" "${REPOS[@]}" | sort -u))
  TMP_THIRD_PARTY=$(mktemp)
  (set -x && mkdir -p third_party)
  for REPO in "${REPOS[@]}"; do
    echo "${REPO}_URL=${URL[$REPO]}" >> "$TMP_THIRD_PARTY"
    echo "${REPO}_BRANCH=${BRANCH[$REPO]}" >> "$TMP_THIRD_PARTY"
    if [[ ! $REPO =~ $ONLY ]]; then
      echo "+skipping $REPO"
      echo "${REPO}_COMMIT=${COMMIT[$REPO]}" >> "$TMP_THIRD_PARTY"
    else
      (
        cd third_party
          (
            DIR=$(TMP=${URL[$REPO]##*/};echo "${TMP%.*}")
            if [[ ! -d $PATH ]]; then (set -x && mkdir -p "$DIR"); fi
            cd "$DIR"
            if [[ $(git rev-parse --git-dir 2> /dev/null) != '.git' ]]; then
              (set -x && git clone -j8 "${URL[$REPO]}" .)
            fi
            (set -x && git fetch)
            (set -x && git reset --hard && git clean -fd)
            (set -x && git submodule foreach --recursive git reset --hard && git submodule foreach --recursive git clean -fd)
            if [[ $UPDATE = true || -z ${COMMIT[$REPO]} ]]; then
              (set -x && git checkout -B "${BRANCH[$REPO]}" "origin/${BRANCH[$REPO]}")
            else
              (set -x && git checkout "${COMMIT[$REPO]}")
            fi
            (set -x && git submodule update --init --recursive)
            echo "${REPO}_COMMIT=$(git rev-parse --short HEAD)" >> "$TMP_THIRD_PARTY"
          )
      )
    fi
    if [[ ${REPOS[-1]} != "$REPO" ]]; then
      echo '' >> "$TMP_THIRD_PARTY"
    fi
  done
  set -x
  cat "$TMP_THIRD_PARTY" > .third_party
  rm "$TMP_THIRD_PARTY"
)