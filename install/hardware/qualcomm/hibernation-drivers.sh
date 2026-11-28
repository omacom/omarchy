#!/bin/bash

# Run by omarchy-qualcomm-hibernate.service on the Snapdragon X1 laptops: "pre"
# before the hibernation (user processes still run, so PipeWire can let go of the
# sound card), "post" when the unit stops after the resume.
#
# A hibernation image is restored after a power cycle. The audio and compute
# DSPs and the Wi-Fi chip are off then, but their drivers would come back
# believing they still run. So before hibernating, device PM goes synchronous
# (asynchronous PM stalls the restore) and the Wi-Fi and DSP drivers are
# unloaded. "pre" notes what the sound chain had bound. After the resume the
# drivers are loaded again, which boots both DSPs afresh, and what the sound
# chain had is bound again where it didn't come back by itself.

state=${OMARCHY_QUALCOMM_HIBERNATE_STATE:-/run/omarchy-qualcomm-hibernate}
pm_async=${OMARCHY_QUALCOMM_PM_ASYNC:-/sys/power/pm_async}
sys=${OMARCHY_QUALCOMM_SYS_ROOT:-/sys}
asound=${OMARCHY_QUALCOMM_ASOUND_ROOT:-/proc/asound}
watchdog=${OMARCHY_QUALCOMM_WATCHDOG:-/dev/watchdog0}
tick=${OMARCHY_QUALCOMM_HIBERNATE_TICK:-1}
drivers=$sys/bus/platform/drivers
modules=$sys/module

# The drivers of the LPASS codec macros, which need the clocks the audio DSP
# provides.
macro_drivers=(rx_macro tx_macro va_macro wsa_macro)

log() {
  echo "omarchy-qualcomm-hibernate: $*"
}

# The devices a platform driver has bound, one per line.
bound_devices() {
  local entry

  for entry in "$drivers/$1"/*; do
    [[ -L $entry && ${entry##*/} != "module" ]] && echo "${entry##*/}"
  done
}

bound() {
  [[ -e $drivers/$1/$2 ]]
}

# SoundWire devices with a driver, which on these laptops are the speaker amps.
speakers() {
  local device count=0

  for device in "$sys"/bus/soundwire/devices/sdw:*; do
    [[ -e $device/driver ]] && ((count++))
  done
  echo "$count"
}

card_up() {
  local id

  for id in "$asound"/card*/id; do
    [[ -f $id && $(<"$id") == "$1" ]] && return 0
  done
  return 1
}

# The Wi-Fi driver's modules, those using it first, where it is Qualcomm's
# ath11k or ath12k. Another maker's card is left alone.
wifi_modules() {
  local interface module holder

  for interface in "$sys"/class/net/*; do
    [[ -d $interface/wireless ]] || continue
    module=$(readlink -f "$interface/device/driver/module")
    module=${module##*/}
    [[ $module == ath1[12]k* ]] || continue
    for holder in "$modules/$module"/holders/*; do
      [[ -e $holder ]] && echo "${holder##*/}"
    done
    echo "$module"
    return
  done
}

# Keep the hardware watchdog fed while the drivers come back, so a hang there
# resets the laptop instead of leaving it frozen.
watchdog_on() {
  [[ -c $watchdog ]] || return 0
  : >"$state.wd"
  (
    exec 3>"$watchdog" || exit 0
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
  local i count wanted driver device id

  log "loading qcom_q6v5_pas"
  timeout 60 modprobe qcom_q6v5_pas || log "loading qcom_q6v5_pas failed"

  wanted=$(wc -l <"$state/macros")
  for ((i = 0; i < 60; i++)); do
    count=0
    while read -r driver device; do
      bound "$driver" "$device" && ((count++))
    done <"$state/macros"
    ((count == wanted)) && break
    sleep "$tick"
  done
  log "LPASS macros bound: $count of $wanted"

  # The SoundWire controllers are not always probed again by themselves.
  sleep $((2 * tick))
  while read -r device; do
    if ! bound qcom-soundwire "$device"; then
      log "binding $device"
      echo "$device" >"$drivers/qcom-soundwire/bind" 2>/dev/null
    fi
  done <"$state/soundwire"

  wanted=$(<"$state/speakers")
  for ((i = 0; i < 30; i++)); do
    count=$(speakers)
    ((count >= wanted)) && break
    sleep "$tick"
  done
  log "speakers bound: $count of $wanted"

  # The card's own rebind after its components return can use stale DAI
  # names, so bind it afresh.
  sleep $((2 * tick))
  while read -r driver device id; do
    if ! card_up "$id"; then
      log "binding the sound card $id again"
      echo "$device" >"$drivers/$driver/unbind" 2>/dev/null
      sleep "$tick"
      echo "$device" >"$drivers/$driver/bind" 2>/dev/null
      for ((i = 0; i < 10; i++)); do
        card_up "$id" && break
        sleep "$tick"
      done
    fi
    if card_up "$id"; then
      log "sound card $id is back"
    else
      log "sound card $id did not come back"
    fi
  done <"$state/cards"
}

# Bring back what "pre" took away: after the resume, after a hibernation that
# failed, or when "pre" itself could not unload a driver.
restore() {
  local -a wifi

  [[ -s $state/pm_async ]] && cat "$state/pm_async" >"$pm_async"
  watchdog_on
  if [[ -e $state/dsps && ! -d $modules/qcom_q6v5_pas ]]; then
    restore_dsps
  fi
  if [[ -s $state/wifi ]]; then
    mapfile -t wifi <"$state/wifi"
    # Loading the modules that use the core loads the core too
    if ((${#wifi[@]} > 1)); then
      unset 'wifi[-1]'
    fi
    for module in "${wifi[@]}"; do
      if [[ ! -d $modules/$module ]]; then
        log "loading $module"
        timeout 30 modprobe "$module" || log "loading $module failed"
      fi
    done
  fi
  watchdog_off
  rm -rf -- "$state"
}

# A driver still loaded across the power cycle loses the session, so a failed
# unload stops the hibernation: the unit fails, and with it the sleep service
# that requires it.
unload_failed() {
  log "unloading $1 failed, not hibernating"
  restore
  exit 1
}

# What the audio DSP's restart has to bring back, noted before it stops.
note_sound_chain() {
  local driver device card

  for driver in "${macro_drivers[@]}"; do
    bound_devices "$driver" | while read -r device; do
      echo "$driver $device"
    done
  done >"$state/macros"
  bound_devices qcom-soundwire >"$state/soundwire"
  speakers >"$state/speakers"
  for card in "$sys"/class/sound/card*; do
    [[ -f $card/id && -e $card/device/driver ]] || continue
    driver=$(readlink -f "$card/device/driver")
    device=$(readlink -f "$card/device")
    # Only a card on the platform bus, which is the laptop's own
    [[ ${driver%/*} == "$(readlink -f "$drivers")" ]] && echo "${driver##*/} ${device##*/} $(<"$card/id")"
  done >"$state/cards"
}

case ${1:-} in
  pre)
    rm -rf -- "$state"
    mkdir -p -- "$state"
    cat "$pm_async" >"$state/pm_async"
    echo 0 >"$pm_async"
    mapfile -t wifi < <(wifi_modules)
    if ((${#wifi[@]})); then
      printf '%s\n' "${wifi[@]}" >"$state/wifi"
      timeout 30 modprobe -r "${wifi[@]}" || unload_failed "${wifi[0]}"
    fi
    if [[ -d $modules/qcom_q6v5_pas ]]; then
      note_sound_chain
      : >"$state/dsps"
      timeout 60 modprobe -r qcom_q6v5_pas || unload_failed qcom_q6v5_pas
    fi
    log "ready to hibernate"
    ;;
  post)
    if [[ -d $state ]]; then
      restore
      log "drivers restored"
    fi
    ;;
  *)
    echo "usage: $0 pre|post" >&2
    exit 2
    ;;
esac
