#!/bin/bash

set -euo pipefail

remoteproc_root=${OMARCHY_ZENBOOK_REMOTEPROC_ROOT:-/sys/class/remoteproc}
attempts=${OMARCHY_ZENBOOK_REMOTEPROC_ATTEMPTS:-30}
sleep_seconds=${OMARCHY_ZENBOOK_REMOTEPROC_SLEEP:-1}

for ((attempt = 1; attempt <= attempts; attempt++)); do
  adsp_started=0
  cdsp_started=0
  shopt -s nullglob

  for state_file in "$remoteproc_root"/remoteproc*/state; do
    remoteproc=${state_file%/state}
    [[ -r $remoteproc/firmware && -r $state_file ]] || continue

    firmware=$(tr -d '\0\n' <"$remoteproc/firmware")
    case "$firmware" in
      *adsp*) kind=ADSP ;;
      *cdsp*) kind=CDSP ;;
      *) continue ;;
    esac

    if [[ $(<$state_file) == running ]]; then
      echo "Zenbook A16: $kind is already running"
      if [[ $kind == ADSP ]]; then
        adsp_started=1
      else
        cdsp_started=1
      fi
    elif [[ -w $state_file ]] && printf 'start\n' >"$state_file"; then
      echo "Zenbook A16: started $kind"
      if [[ $kind == ADSP ]]; then
        adsp_started=1
      else
        cdsp_started=1
      fi
    else
      echo "Zenbook A16: could not start $kind ($firmware)" >&2
    fi
  done

  ((adsp_started && cdsp_started)) && exit 0
  sleep "$sleep_seconds"
done

echo "Zenbook A16: ADSP/CDSP did not both appear and start successfully" >&2
exit 1
