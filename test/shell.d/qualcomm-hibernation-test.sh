#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The Snapdragon X1 hibernation helper on a made-up sysfs like the Yoga Slim 7x's:
# what "pre" unloads and notes of the sound chain, and what "post" brings back.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
sys=$tmp/sys
helper=$ROOT/install/hardware/qualcomm/hibernation-drivers.sh

bind_device() {
  mkdir -p "$sys/devices/platform/$2" "$sys/bus/platform/drivers/$1"
  : >"$sys/bus/platform/drivers/$1/bind"
  : >"$sys/bus/platform/drivers/$1/unbind"
  ln -sfn "$sys/devices/platform/$2" "$sys/bus/platform/drivers/$1/$2"
  ln -sfn "$sys/bus/platform/drivers/$1" "$sys/devices/platform/$2/driver"
}

macros=("rx_macro 6ac0000.codec" "tx_macro 6ae0000.codec" "va_macro 6d44000.codec" "wsa_macro 6aa0000.codec" "wsa_macro 6b00000.codec")

# ath12k Wi-Fi (or another maker's), both DSPs, five LPASS macros, two
# SoundWire controllers with four speaker amps, and the sound card.
laptop() {
  local wifi_module=${1:-ath12k} macro speaker
  rm -rf "$sys" "$tmp/asound" "$tmp/state" "$tmp/calls"
  mkdir -p "$sys/module/$wifi_module/holders" "$sys/module/qcom_q6v5_pas" "$sys/class/net/wlan0/wireless" \
    "$sys/devices/pci/wifi" "$sys/bus/pci/drivers/wifi" "$sys/class/sound/card0" "$tmp/asound/card0"
  if [[ $wifi_module == ath12k ]]; then
    mkdir -p "$sys/module/ath12k_wifi7"
    ln -s "$sys/module/ath12k_wifi7" "$sys/module/ath12k/holders/ath12k_wifi7"
  fi
  ln -s "$sys/module/$wifi_module" "$sys/bus/pci/drivers/wifi/module"
  ln -s "$sys/bus/pci/drivers/wifi" "$sys/devices/pci/wifi/driver"
  ln -s "$sys/devices/pci/wifi" "$sys/class/net/wlan0/device"
  for macro in "${macros[@]}"; do
    bind_device $macro
  done
  bind_device qcom-soundwire 6ab0000.soundwire
  bind_device qcom-soundwire 6b10000.soundwire
  bind_device snd-x1e80100 sound
  echo X1E80100LENOVOY >"$sys/class/sound/card0/id"
  ln -s "$sys/devices/platform/sound" "$sys/class/sound/card0/device"
  echo X1E80100LENOVOY >"$tmp/asound/card0/id"
  for speaker in 1:0:0217:0204:00:0 1:0:0217:0204:00:1 4:0:0217:0204:00:0 4:0:0217:0204:00:1; do
    mkdir -p "$sys/bus/soundwire/devices/sdw:$speaker"
    ln -s "$sys/bus/platform/drivers/qcom-soundwire" "$sys/bus/soundwire/devices/sdw:$speaker/driver"
  done
  echo 1 >"$tmp/pm_async"
}

# Unloading the DSP driver takes the sound chain with it. Loading it brings the
# macros and one SoundWire controller back by themselves, and not the other.
mkdir -p "$tmp/bin"
cat >"$tmp/bin/modprobe" <<'SH'
#!/bin/bash
echo "modprobe $*" >>"$TMP/calls"
if [[ $1 == -r ]]; then
  shift
  [[ " $* " == *" ${FAIL_UNLOAD:-none} "* ]] && exit 1
  for module in "$@"; do rm -rf "$SYS/module/$module"; done
  if [[ " $* " == *" qcom_q6v5_pas "* ]]; then
    rm -f "$SYS"/bus/platform/drivers/*_macro/*.codec "$SYS"/bus/platform/drivers/qcom-soundwire/*.soundwire \
      "$SYS"/bus/platform/drivers/snd-x1e80100/sound "$SYS"/bus/soundwire/devices/sdw:*/driver
    rm -rf "$TMP/asound/card0"
  fi
  exit 0
fi
mkdir -p "$SYS/module/$1"
if [[ $1 == qcom_q6v5_pas ]]; then
  for macro in rx_macro/6ac0000 tx_macro/6ae0000 va_macro/6d44000 wsa_macro/6aa0000 wsa_macro/6b00000; do
    ln -sfn "$SYS/devices/platform/${macro#*/}.codec" "$SYS/bus/platform/drivers/$macro.codec"
  done
  ln -sfn "$SYS/devices/platform/6ab0000.soundwire" "$SYS/bus/platform/drivers/qcom-soundwire/6ab0000.soundwire"
fi
SH
chmod +x "$tmp/bin/modprobe"

helper() {
  PATH="$tmp/bin:$PATH" TMP=$tmp SYS=$sys OMARCHY_QUALCOMM_SYS_ROOT=$sys OMARCHY_QUALCOMM_ASOUND_ROOT=$tmp/asound \
    OMARCHY_QUALCOMM_PM_ASYNC=$tmp/pm_async OMARCHY_QUALCOMM_HIBERNATE_STATE=$tmp/state \
    OMARCHY_QUALCOMM_WATCHDOG=$tmp/no-watchdog OMARCHY_QUALCOMM_HIBERNATE_TICK=0 \
    bash "$helper" "$@" >"$tmp/out" 2>&1
}

laptop
helper pre || fail "pre on a laptop like the Yoga" "$(<"$tmp/out")"
[[ $(<"$tmp/calls") == $'modprobe -r ath12k_wifi7 ath12k\nmodprobe -r qcom_q6v5_pas' ]] ||
  fail "pre unloads the Wi-Fi and DSP drivers" "$(<"$tmp/calls")"
[[ $(<"$tmp/pm_async") == 0 && $(wc -l <"$tmp/state/macros") == 5 && $(<"$tmp/state/speakers") == 4 &&
  $(<"$tmp/state/cards") == "snd-x1e80100 sound X1E80100LENOVOY" ]] ||
  fail "pre notes the sound chain" "$(cat "$tmp/state/macros" "$tmp/state/cards")"
: >"$tmp/calls"
helper post || fail "post on a laptop like the Yoga" "$(<"$tmp/out")"
[[ $(<"$tmp/calls") == $'modprobe qcom_q6v5_pas\nmodprobe ath12k_wifi7' ]] ||
  fail "post loads the DSP and Wi-Fi drivers again" "$(<"$tmp/calls")"
[[ $(<"$sys/bus/platform/drivers/qcom-soundwire/bind") == 6b10000.soundwire ]] ||
  fail "post binds the SoundWire controller that didn't come back, and only it" "$(<"$tmp/out")"
[[ $(<"$sys/bus/platform/drivers/snd-x1e80100/bind") == sound ]] ||
  fail "post binds the missing sound card again" "$(<"$tmp/out")"
[[ $(<"$tmp/pm_async") == 1 && ! -e $tmp/state ]] || fail "post puts device PM back and forgets the state" "$(<"$tmp/out")"
pass "the helper stops and brings back what a Yoga-like laptop has"

# A DSP driver that won't unload stops the hibernation, and Wi-Fi comes back.
laptop
FAIL_UNLOAD=qcom_q6v5_pas helper pre && fail "a failed unload still hibernates" "$(<"$tmp/out")"
[[ $(tail -1 "$tmp/calls") == "modprobe ath12k_wifi7" && $(<"$tmp/pm_async") == 1 && ! -e $tmp/state ]] ||
  fail "a failed unload brings back what was stopped" "$(<"$tmp/calls")"
pass "a driver that won't unload stops the hibernation"

# Another maker's Wi-Fi card is left alone.
laptop mt7925e
helper pre || fail "pre with another maker's Wi-Fi" "$(<"$tmp/out")"
[[ $(<"$tmp/calls") == "modprobe -r qcom_q6v5_pas" ]] || fail "pre unloads another maker's Wi-Fi" "$(<"$tmp/calls")"
pass "another maker's Wi-Fi is left alone"
