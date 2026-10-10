#!/bin/bash

set -euo pipefail

remoteproc_root=${OMARCHY_YOGA_REMOTEPROC_ROOT:-/sys/class/remoteproc}
attempts=${OMARCHY_YOGA_REMOTEPROC_ATTEMPTS:-30}
sleep_seconds=${OMARCHY_YOGA_REMOTEPROC_SLEEP:-1}

adsp_started=0
cdsp_started=0
shopt -s nullglob

# Either DSP can appear late or fail its first start, so both are tried until
# both are up or the attempts run out.
for ((attempt = 1; attempt <= attempts; attempt++)); do
  for state_file in "$remoteproc_root"/remoteproc*/state; do
    remoteproc=${state_file%/state}
    [[ -r $remoteproc/firmware && -r $state_file ]] || continue

    firmware=$(tr -d '\0\n' <"$remoteproc/firmware")
    case "$firmware" in
      *qcadsp*) kind=ADSP started=$adsp_started ;;
      *qccdsp*) kind=CDSP started=$cdsp_started ;;
      *) continue ;;
    esac
    ((started)) && continue

    if [[ $(<$state_file) == running ]]; then
      echo "Yoga Slim 7x: $kind is already running"
    elif [[ -w $state_file ]] && printf 'start\n' >"$state_file"; then
      echo "Yoga Slim 7x: started $kind"
    else
      echo "Yoga Slim 7x: could not start $kind ($firmware)" >&2
      continue
    fi

    if [[ $kind == ADSP ]]; then
      adsp_started=1
    else
      cdsp_started=1
    fi
  done

  ((adsp_started && cdsp_started)) && exit 0
  sleep "$sleep_seconds"
done

# The audio DSP decides the result: battery, audio and USB-C hang off it.
if ((adsp_started)); then
  echo "Yoga Slim 7x: compute DSP did not appear or could not be started" >&2
  exit 0
fi

echo "Yoga Slim 7x: audio DSP did not appear or could not be started" >&2
exit 1
