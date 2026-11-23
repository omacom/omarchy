#!/bin/bash

# Run by yoga-slim7x-hibernate.service on the Lenovo Yoga Slim 7x: "pre" before
# the hibernation (user processes still run, so PipeWire can let go of the
# sound card), "post" when the unit stops after the resume.
#
# A hibernation image is restored after a power cycle. The audio and compute
# DSPs and the Wi-Fi chip are off then, but their drivers would come back
# believing they still run. So before hibernating, device PM goes synchronous
# (asynchronous PM stalls the restore) and the Wi-Fi and DSP drivers are
# unloaded. After the resume they are loaded again, which boots both DSPs
# afresh, and the sound card is bound again once the audio chain is back.

state=${OMARCHY_YOGA_HIBERNATE_STATE:-/run/yoga-slim7x-hibernate}
pm_async=${OMARCHY_YOGA_PM_ASYNC:-/sys/power/pm_async}
platform=${OMARCHY_YOGA_PLATFORM_ROOT:-/sys/bus/platform}

log() {
  echo "yoga-slim7x-hibernate: $*"
}

bound() {
  [[ -e $platform/devices/$1/driver ]]
}

card_up() {
  grep -q '\[X1E80100' /proc/asound/cards 2>/dev/null
}

# Keep the hardware watchdog fed while the drivers come back, so a hang there
# resets the laptop instead of leaving it frozen.
watchdog_on() {
  [[ -c /dev/watchdog0 ]] || return 0
  : >"$state.wd"
  (
    exec 3>/dev/watchdog0 || exit 0
    while [[ -e $state.wd ]]; do
      printf '.' >&3
      sleep 2
    done
    printf 'V' >&3
  ) &
}

watchdog_off() {
  rm -f -- "$state.wd"
  wait 2>/dev/null
}

restore_dsps() {
  local i count dev

  log "loading qcom_q6v5_pas"
  timeout 60 modprobe qcom_q6v5_pas || log "loading qcom_q6v5_pas failed"

  # The LPASS macros need the clocks the audio DSP provides.
  for ((i = 0; i < 60; i++)); do
    count=0
    for dev in 6aa0000.codec 6ac0000.codec 6ae0000.codec 6b00000.codec 6d44000.codec; do
      bound "$dev" && ((count++))
    done
    ((count == 5)) && break
    sleep 1
  done
  log "LPASS macros bound: $count of 5"

  # The SoundWire controllers are not always probed again by themselves.
  sleep 2
  for dev in 6ab0000.soundwire 6b10000.soundwire; do
    if ! bound "$dev"; then
      log "binding $dev"
      echo "$dev" >"$platform/drivers/qcom-soundwire/bind" 2>/dev/null
    fi
  done

  for ((i = 0; i < 30; i++)); do
    count=0
    for dev in /sys/bus/soundwire/devices/sdw:*; do
      [[ -e $dev/driver ]] && ((count++))
    done
    ((count >= 4)) && break
    sleep 1
  done
  log "speakers bound: $count"

  # The card's own rebind after its components return can use stale DAI
  # names, so bind it afresh.
  sleep 2
  if ! card_up; then
    log "binding the sound card again"
    echo sound >"$platform/drivers/snd-x1e80100/unbind" 2>/dev/null
    sleep 1
    echo sound >"$platform/drivers/snd-x1e80100/bind" 2>/dev/null
    for ((i = 0; i < 10; i++)); do
      card_up && break
      sleep 1
    done
  fi
  if card_up; then
    log "sound card is back"
  else
    log "sound card did not come back"
  fi
}

case ${1:-} in
  pre)
    rm -rf -- "$state"
    mkdir -p -- "$state"
    cat "$pm_async" >"$state/pm_async"
    echo 0 >"$pm_async"
    if [[ -d /sys/module/ath12k_wifi7 ]] && timeout 30 modprobe -r ath12k_wifi7 ath12k; then
      : >"$state/wifi"
    fi
    if [[ -d /sys/module/qcom_q6v5_pas ]] && timeout 60 modprobe -r qcom_q6v5_pas; then
      : >"$state/dsps"
    fi
    log "ready to hibernate"
    ;;
  post)
    if [[ -d $state ]]; then
      [[ -s $state/pm_async ]] && cat "$state/pm_async" >"$pm_async"
      watchdog_on
      [[ -e $state/dsps ]] && restore_dsps
      if [[ -e $state/wifi ]]; then
        log "loading ath12k_wifi7"
        timeout 30 modprobe ath12k_wifi7 || log "loading ath12k_wifi7 failed"
      fi
      watchdog_off
      rm -rf -- "$state"
      log "drivers restored"
    fi
    ;;
  *)
    echo "usage: $0 pre|post" >&2
    exit 2
    ;;
esac
