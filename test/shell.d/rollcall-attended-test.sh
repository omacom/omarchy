#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Every wait gives up after a second and nothing pauses, so a person who does
# nothing costs a second, not a minute.
export OMARCHY_ROLLCALL_TIMEOUT=1 OMARCHY_ROLLCALL_PAUSE=0

# PipeWire as files: sinks.json, sources.json, cards.json and the defaults.
# Setting a volume or a mute rewrites the file, as the real server would.
cat >"$stub_bin/pactl" <<'SH'
#!/bin/bash
pa=$STUB/pa
[[ -e $pa/down ]] && exit 1
case $1 in
  info) exit 0 ;;
  get-default-sink) cat "$pa/default-sink" ;;
  get-default-source) cat "$pa/default-source" ;;
  -f) cat "$pa/$4.json" 2>/dev/null || echo '[]' ;;
  set-*)
    echo "pactl $*" >>"$STUB/calls"
    file=$pa/sinks.json
    [[ $1 == *source* ]] && file=$pa/sources.json
    if [[ $1 == *mute ]]; then
      jq --arg name "$2" --argjson mute "$([[ $3 == 1 ]] && echo true || echo false)" 'map(if .name == $name then .mute = $mute else . end)' "$file"
    else
      jq --arg name "$2" --argjson values "$(printf '%s\n' "${@:3}" | jq -s .)" \
        'map(if .name == $name then .volume |= (keys_unsorted as $k | reduce range(0; $k | length) as $i (.; .[$k[$i]].value = $values[$i])) else . end)' "$file"
    fi >"$file.tmp" && mv "$file.tmp" "$file"
    ;;
esac
SH

cat >"$stub_bin/omarchy-audio-output-sink" <<'SH'
#!/bin/bash
cat "$STUB/pa/physical" 2>/dev/null || cat "$STUB/pa/default-sink"
SH

# Only what the command asks of ffmpeg: a tone, loudness, a camera frame and its range.
cat >"$stub_bin/ffmpeg" <<'SH'
#!/bin/bash
args=" $* "
out=${!#}
if [[ $args == *" lavfi "* ]]; then
  echo tone >"$out"
elif [[ $args == *astats* ]]; then
  printf '[Parsed_astats_0 @ 0x1] Peak level dB: %s\n[Parsed_astats_0 @ 0x1] RMS level dB: %s\n[Parsed_astats_0 @ 0x1] RMS peak dB: %s\n' \
    ${ASTATS:--12.4 -31.0 -17.2} >&2
elif [[ $args == *list_formats* && -n ${IR_NODE:-} && $args == *"/$IR_NODE "* ]]; then
  echo "[video4linux2,v4l2 @ 0x1] Raw       :        gray :     8-bit Greyscale : 640x360" >&2
elif [[ $args == *list_formats* ]]; then
  echo "[video4linux2,v4l2 @ 0x1] ${CAMERA_FORMAT:-Raw       :     yuyv422 :           YUYV 4:2:2 : 640x480 1280x720}" >&2
elif [[ $args == *signalstats* ]]; then
  printf 'lavfi.signalstats.YMIN=16\nlavfi.signalstats.YMAX=%s\n' "${YMAX:-235}" >&2
elif [[ $args == *" v4l2 "* ]]; then
  echo "ffmpeg $*" >>"$STUB/calls"
  if [[ -n ${CAMERA_BUSY:-} ]]; then
    echo "[video4linux2,v4l2 @ 0x1] /dev/video0: Device or resource busy" >&2
    exit 1
  fi
  echo jpeg >"$out"
fi
SH

cat >"$stub_bin/ffprobe" <<'SH'
#!/bin/bash
echo 1280x720
SH

cat >"$stub_bin/pw-play" <<'SH'
#!/bin/bash
echo "pw-play $*" >>"$STUB/calls"
SH

cat >"$stub_bin/pw-record" <<'SH'
#!/bin/bash
echo "pw-record $*" >>"$STUB/calls"
echo wav >"${!#}"
SH

# Writes the value into the fake sysfs, as the real one does through logind.
cat >"$stub_bin/brightnessctl" <<'SH'
#!/bin/bash
echo "brightnessctl $*" >>"$STUB/calls"
device="" value=""
while (( $# )); do
  case $1 in
    -d) device=$2; shift ;;
    set) value=$2; shift ;;
  esac
  shift
done
for dir in "$OMARCHY_ROLLCALL_ROOT/sys/class/backlight/$device" "$OMARCHY_ROLLCALL_ROOT/sys/class/leds/$device"; do
  [[ -d $dir && -n $value ]] && echo "$value" >"$dir/brightness"
done
exit 0
SH

cat >"$stub_bin/rfkill" <<'SH'
#!/bin/bash
echo "rfkill $*" >>"$STUB/calls"
if [[ $1 == "unblock" || $1 == "block" ]]; then
  for switch in "$OMARCHY_ROLLCALL_ROOT"/sys/class/rfkill/rfkill*; do
    [[ $(<"$switch/type") == "$2" ]] && { [[ $1 == "block" ]] && echo 1 || echo 0; } >"$switch/soft"
  done
fi
exit 0
SH

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
case "$*" in
  "devices -j") cat "$STUB/hypr/devices.json" ;;
  "monitors -j") cat "$STUB/hypr/monitors.json" ;;
  "clients -j") cat "$STUB/hypr/clients.json" ;;
  *) exit 1 ;;
esac
SH

# MPRIS players are files named for their bus name, holding their status.
cat >"$stub_bin/busctl" <<'SH'
#!/bin/bash
case "$*" in
  *ListNames*) jq -nc --arg names "$(ls "$STUB/players" 2>/dev/null)" '{type: "as", data: [($names | split("\n") | map(select(. != "")))]}' ;;
  *PlaybackStatus*) echo "s \"$(cat "$STUB/players/$3")\"" ;;
  *HandleLidSwitchExternalPower*) echo "s \"${LID_AC_ACTION:-suspend}\"" ;;
  *HandleLidSwitch*) echo "s \"${LID_ACTION:-suspend}\"" ;;
  *) exit 1 ;;
esac
SH

cat >"$stub_bin/bluetoothctl" <<'SH'
#!/bin/bash
case $1 in
  devices) cat "$STUB/bt/connected" 2>/dev/null ;;
  info) printf '\tName: Test\n\tIcon: %s\n' "$(cat "$STUB/bt/icon")" ;;
esac
SH

cat >"$stub_bin/pw-dump" <<'SH'
#!/bin/bash
printf '%s' "${PW_DUMP:-[]}"
SH

# A suspend counts as the kernel would count it.
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
stats=$OMARCHY_ROLLCALL_ROOT/sys/power/suspend_stats
case "$*" in
  "is-active --quiet bluetooth.service") exit 0 ;;
  suspend)
    echo "systemctl suspend" >>"$STUB/calls"
    if [[ -n ${SUSPEND_FAILS:-} ]]; then
      echo $(( $(<"$stats/fail") + 1 )) >"$stats/fail"
      echo suspend_noirq >"$stats/last_failed_step"
      echo -5 >"$stats/last_failed_errno"
      echo "${SUSPEND_DEV:-}" >"$stats/last_failed_dev"
    elif [[ -n ${SUSPEND_CALLED_OFF:-} ]]; then
      # A key pressed on the way down: the kernel counts a failure with -16.
      echo $(( $(<"$stats/fail") + 1 )) >"$stats/fail"
      echo -16 >"$stats/last_failed_errno"
      if [[ $SUSPEND_CALLED_OFF == "then-sleeps" ]]; then
        (sleep 0.3; echo $(( $(<"$stats/success") + 1 )) >"$stats/success") >/dev/null 2>&1 &
      fi
    else
      echo $(( $(<"$stats/success") + 1 )) >"$stats/success"
      [[ -z ${HW_SLEEP:-} ]] || echo "$HW_SLEEP" >"$stats/last_hw_sleep"
    fi
    ;;
esac
SH

# The automated report before a suspend, then after it.
cat >"$stub_bin/omarchy-rollcall" <<'SH'
#!/bin/bash
count=$(( $(cat "$STUB/rollcall-count" 2>/dev/null || echo 0) + 1 ))
echo "$count" >"$STUB/rollcall-count"
if (( count == 1 )); then
  cat "$STUB/rollcall-before.json"
else
  cat "$STUB/rollcall-after.json"
fi
SH

cat >"$stub_bin/fprintd-list" <<'SH'
#!/bin/bash
cat "$STUB/fprint-list"
SH
cat >"$stub_bin/fprintd-verify" <<'SH'
#!/bin/bash
cat "$STUB/fprint-verify"
SH

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
echo "gum $*" >>"$STUB/calls"
[[ -n ${GUM_ANSWER:-} ]] || exit 1
echo "$GUM_ANSWER"
SH

cat >"$stub_bin/omarchy-hw-vm" <<'SH'
#!/bin/bash
[[ -n ${VM:-} ]]
SH
chmod +x "$stub_bin"/*

new_root() {
  fake=$(mktemp -d "$test_tmp/root.XXXXXX")
  mkdir -p "$fake/sys/class/net" "$fake/sys/class/rfkill" "$fake/sys/class/bluetooth" "$fake/sys/class/drm" \
    "$fake/sys/class/input" "$fake/sys/class/power_supply" "$fake/sys/class/dmi/id" "$fake/sys/class/leds" \
    "$fake/sys/class/backlight" "$fake/sys/class/video4linux" "$fake/sys/bus/usb/devices" "$fake/sys/power/suspend_stats" \
    "$fake/proc" "$fake/run/udev/data" "$fake/dev" "$fake/home" "$fake/state" \
    "$fake/stub/pa" "$fake/stub/hypr" "$fake/stub/bt" "$fake/stub/players"
  printf '3\n' >"$fake/sys/class/dmi/id/chassis_type"
  printf 'freeze mem disk\n' >"$fake/sys/power/state"
  printf 's2idle [deep]\n' >"$fake/sys/power/mem_sleep"
  printf '0\n' >"$fake/sys/power/suspend_stats/success"
  printf '0\n' >"$fake/sys/power/suspend_stats/fail"
  touch "$fake/stub/calls"
  desktop_audio
  echo '{"keyboards": [{"name": "at-keyboard", "main": true, "capsLock": false}], "mice": [], "touch": [], "tablets": []}' >"$fake/stub/hypr/devices.json"
  echo '[{"id": 0, "name": "HDMI-A-1", "width": 2560, "height": 1440, "refreshRate": 59.95}]' >"$fake/stub/hypr/monitors.json"
  echo '[{"mapped": true, "hidden": false, "monitor": 0}]' >"$fake/stub/hypr/clients.json"
  mkdir -p "$fake/sys/class/drm/card0-HDMI-A-1" "$fake/sys/class/drm/card0-DP-1"
  printf 'connected\n' >"$fake/sys/class/drm/card0-HDMI-A-1/status"
  printf 'disconnected\n' >"$fake/sys/class/drm/card0-DP-1/status"
  mkdir -p "$fake/sys/bus/usb/devices/usb1"
  printf '480\n' >"$fake/sys/bus/usb/devices/usb1/speed"
  mkdir -p "$fake/sys/class/bluetooth/hci0"
  mkdir -p "$fake/sys/class/leds/input3::capslock"
  printf '0\n' >"$fake/sys/class/leds/input3::capslock/brightness"
}

# A desktop's audio: a graphics card's HDMI sink and an analog card with an empty headphone jack.
desktop_audio() {
  cat >"$fake/stub/pa/sinks.json" <<'JSON'
[{"name": "alsa_output.pci-0000_01_00.1.hdmi-stereo", "active_port": "hdmi-output-0", "mute": false,
  "volume": {"front-left": {"value": 40000}, "front-right": {"value": 40000}},
  "ports": [{"name": "hdmi-output-0", "type": "HDMI", "availability": "available"}],
  "properties": {"device.bus": "pci", "alsa.driver_name": "snd_hda_intel"}}]
JSON
  echo '[{"name": "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor", "mute": false, "volume": {"mono": {"value": 65536}}, "ports": [], "properties": {"device.class": "monitor"}}]' >"$fake/stub/pa/sources.json"
  cat >"$fake/stub/pa/cards.json" <<'JSON'
[{"name": "alsa_card.pci-0000_01_00.1", "ports": {"hdmi-output-0": {"type": "HDMI", "availability": "available"}}, "properties": {"device.bus": "pci"}},
 {"name": "alsa_card.pci-0000_01_00.6", "ports": {"analog-output-headphones": {"type": "Headphones", "availability": "not available"}}, "properties": {"device.bus": "pci"}}]
JSON
  echo alsa_output.pci-0000_01_00.1.hdmi-stereo >"$fake/stub/pa/default-sink"
  echo alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor >"$fake/stub/pa/default-source"
}

# A laptop's audio: speakers and a headphone jack on one sink, a built-in microphone.
laptop_audio() {
  cat >"$fake/stub/pa/sinks.json" <<'JSON'
[{"name": "alsa_output.pci-0000_00_1f.3.analog-stereo", "active_port": "analog-output-speaker", "mute": false,
  "volume": {"front-left": {"value": 30000}, "front-right": {"value": 30000}},
  "ports": [{"name": "analog-output-speaker", "type": "Speaker", "availability": "availability unknown"},
            {"name": "analog-output-headphones", "type": "Headphones", "availability": "not available"}],
  "properties": {"device.bus": "pci", "alsa.driver_name": "snd_hda_intel"}},
 {"name": "alsa_output.pci-0000_00_1f.3.hdmi-stereo", "active_port": "hdmi-output-0", "mute": false,
  "volume": {"front-left": {"value": 50000}, "front-right": {"value": 50000}},
  "ports": [{"name": "hdmi-output-0", "type": "HDMI", "availability": "available"}],
  "properties": {"device.bus": "pci", "alsa.driver_name": "snd_hda_intel"}}]
JSON
  cat >"$fake/stub/pa/sources.json" <<'JSON'
[{"name": "alsa_input.pci-0000_00_1f.3.analog-stereo", "active_port": "analog-input-internal-mic", "mute": false,
  "volume": {"front-left": {"value": 40000}, "front-right": {"value": 40000}},
  "ports": [{"name": "analog-input-internal-mic", "type": "Mic", "availability": "availability unknown"}],
  "properties": {"device.bus": "pci", "alsa.driver_name": "snd_hda_intel"}}]
JSON
  cat >"$fake/stub/pa/cards.json" <<'JSON'
[{"name": "alsa_card.pci-0000_00_1f.3", "properties": {"device.bus": "pci"},
  "ports": {"analog-output-speaker": {"type": "Speaker", "availability": "availability unknown"},
            "analog-output-headphones": {"type": "Headphones", "availability": "not available"},
            "analog-input-internal-mic": {"type": "Mic", "availability": "availability unknown"}}}]
JSON
  echo alsa_output.pci-0000_00_1f.3.analog-stereo >"$fake/stub/pa/default-sink"
  echo alsa_input.pci-0000_00_1f.3.analog-stereo >"$fake/stub/pa/default-source"
}

make_laptop() {
  mkdir -p "$fake/proc/acpi/button/lid/LID0"
  printf 'state:      open\n' >"$fake/proc/acpi/button/lid/LID0/state"
  printf '10\n' >"$fake/sys/class/dmi/id/chassis_type"
  mkdir -p "$fake/sys/class/backlight/intel_backlight"
  printf '100\n' >"$fake/sys/class/backlight/intel_backlight/max_brightness"
  printf '50\n' >"$fake/sys/class/backlight/intel_backlight/brightness"
  mkdir -p "$fake/sys/class/power_supply/BAT0" "$fake/sys/class/power_supply/AC"
  printf 'Battery\n' >"$fake/sys/class/power_supply/BAT0/type"
  printf '1\n' >"$fake/sys/class/power_supply/BAT0/present"
  printf 'Charging\n' >"$fake/sys/class/power_supply/BAT0/status"
  printf 'Mains\n' >"$fake/sys/class/power_supply/AC/type"
  printf '1\n' >"$fake/sys/class/power_supply/AC/online"
  radio 0 wlan phy0
  radio 1 bluetooth hci0
  mkdir -p "$fake/sys/class/leds/platform::kbd_backlight"
  printf '3\n' >"$fake/sys/class/leds/platform::kbd_backlight/max_brightness"
  printf '1\n' >"$fake/sys/class/leds/platform::kbd_backlight/brightness"
  mkdir -p "$fake/sys/class/drm/card1-eDP-1"
  printf 'connected\n' >"$fake/sys/class/drm/card1-eDP-1/status"
  printf 'disconnected\n' >"$fake/sys/class/drm/card0-HDMI-A-1/status"
  echo '[{"id": 0, "name": "eDP-1", "width": 2880, "height": 1800, "refreshRate": 120.0}]' >"$fake/stub/hypr/monitors.json"
  laptop_audio
}

radio() {
  mkdir -p "$fake/sys/class/rfkill/rfkill$1"
  printf '%s\n' "$2" >"$fake/sys/class/rfkill/rfkill$1/type"
  printf '%s\n' "$3" >"$fake/sys/class/rfkill/rfkill$1/name"
  printf '0\n' >"$fake/sys/class/rfkill/rfkill$1/soft"
  printf '0\n' >"$fake/sys/class/rfkill/rfkill$1/hard"
}

attended() {
  STUB=$fake/stub OMARCHY_ROLLCALL_ROOT=$fake OMARCHY_ROLLCALL_STATE=$fake/state HOME=$fake/home \
    PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-rollcall-test" "$@"
}

# In the background as the command itself, so a signal reaches it and not a wrapper.
attended_bg() {
  (
    export STUB=$fake/stub OMARCHY_ROLLCALL_ROOT=$fake OMARCHY_ROLLCALL_STATE=$fake/state HOME=$fake/home PATH="$stub_bin:$ROOT/bin:$PATH"
    exec "$ROOT/bin/omarchy-rollcall-test" "$@" --no-ask >"$test_tmp/out" 2>/dev/null
  ) &
  pid=$!
}

# Waits for the running test to print a prompt.
await_prompt() {
  for _ in $(seq 50); do
    grep -q "::prompt:: $1 " "$test_tmp/out" 2>/dev/null && return
    sleep 0.1
  done
  fail "the prompt $1 never came"
}

# Runs a test as the panel does, while a person acts on each prompt by the
# function named in $person, and prints what the panel would read.
drive() {
  local line key
  attended "$@" --no-ask 2>/dev/null | while IFS= read -r line; do
    printf '%s\n' "$line"
    if [[ $line == "::prompt:: "* ]]; then
      key=${line#::prompt:: }
      "$person" "${key%% *}"
    fi
  done
  return "${PIPESTATUS[0]}"
}

# Sets $out and $status from one driven run.
run() {
  status=0
  out=$(drive "$@") || status=$?
}

nobody() {
  :
}
person=nobody

detail() {
  grep -v '^::' <<<"$out" | tail -n 1
}

stored() {
  jq -r "$2" "$fake/state/attended/$1.json"
}

expect() {
  local description=$1 expected=$2 actual=$3
  [[ $actual == $expected ]] || fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

set_json() {
  jq "$2" "$1" >"$1.tmp" && mv "$1.tmp" "$1"
}

sink_volume() {
  set_json "$fake/stub/pa/sinks.json" "map(if .name == \"alsa_output.pci-0000_00_1f.3.analog-stereo\" then .volume[].value = $1 else . end)"
}

sink_mute() {
  set_json "$fake/stub/pa/sinks.json" "map(if .name == \"alsa_output.pci-0000_00_1f.3.analog-stereo\" then .mute = $1 else . end)"
}

# Listing
new_root
expect "the list names every test in walkthrough order" \
  "speakers microphone headphones camera volume-keys mic-mute-key brightness-keys keyboard-backlight-key wireless-key media-keys caps-lock-light external-display usb-port bluetooth-device suspend lid charger fingerprint keyboard touchpad touchscreen" \
  "$(attended --list --json | jq -r 'map(.id) | join(" ")')"
expect "every entry has the contract's fields and nothing has a result yet" "true" \
  "$(attended --list --json | jq 'all(.[]; (keys == ["applicable", "detail", "id", "kind", "needs", "reason", "result", "title"]) and .result == null and .detail == "")')"
expect "needs uses the fixed vocabulary" "true" \
  "$(attended --list --json | jq 'all(.[]; .needs | IN("", "headphones", "usb-device", "external-display", "bluetooth-device", "charger", "enrolled-finger"))')"
expect "kinds are verify, interact or panel, and keyboard, touchpad and touchscreen are the panel's" "keyboard touchpad touchscreen" \
  "$(attended --list --json | jq -r 'if all(.[]; .kind | IN("verify", "interact", "panel")) then map(select(.kind == "panel") | .id) | join(" ") else "bad kind" end')"

desktop=$(attended --list --json | jq -c 'map({key: .id, value: (if .applicable then "yes" else .reason end)}) | from_entries')
expect "a desktop has no built-in speakers" "no built-in speakers" "$(jq -r .speakers <<<"$desktop")"
expect "a desktop skips the built-in microphone" "not a laptop" "$(jq -r .microphone <<<"$desktop")"
expect "a desktop's headphone jack applies" "yes" "$(jq -r .headphones <<<"$desktop")"
expect "brightness keys are a laptop's" "not a laptop" "$(jq -r '."brightness-keys"' <<<"$desktop")"
expect "a desktop has no charger to pull" "no battery" "$(jq -r .charger <<<"$desktop")"
expect "a desktop has no lid" "not a laptop" "$(jq -r .lid <<<"$desktop")"
expect "a desktop with a free output can take an external display" "yes" "$(jq -r '."external-display"' <<<"$desktop")"
expect "a desktop can suspend" "yes" "$(jq -r .suspend <<<"$desktop")"
expect "a desktop without a microphone has no microphone mute to test" "no microphone" "$(jq -r '."mic-mute-key"' <<<"$desktop")"
expect "the keyboard always applies" "yes" "$(jq -r .keyboard <<<"$desktop")"
expect "a desktop has no touchpad" "no touchpad" "$(jq -r .touchpad <<<"$desktop")"

make_laptop
laptop=$(attended --list --json | jq -c 'map({key: .id, value: (if .applicable then "yes" else .reason end)}) | from_entries')
expect "a laptop gets every laptop test" "yes yes yes yes yes yes yes yes yes" \
  "$(jq -r '[.speakers, .microphone, .headphones, ."brightness-keys", ."keyboard-backlight-key", ."wireless-key", .charger, .lid, .touchpad] | join(" ")' <<<"$laptop")"
expect "a laptop always has a camera to test" "yes" "$(jq -r .camera <<<"$laptop")"
expect "a laptop with no external display connected can take one" "yes" "$(jq -r '."external-display"' <<<"$laptop")"

touch "$fake/stub/pa/down"
expect "audio tests do not apply when PipeWire cannot be reached" "PipeWire is not reachable from this session" \
  "$(attended --list --json | jq -r 'map(select(.id == "speakers" or .id == "volume-keys") | .reason) | unique | join(",")')"
rm "$fake/stub/pa/down"
mkdir -p "$fake/etc/systemd/sleep.conf.d"
touch "$fake/etc/systemd/sleep.conf.d/omarchy-sleep-disabled.conf"
expect "suspend and the lid do not apply when Omarchy turned sleep off" "sleep is turned off on this machine" \
  "$(attended --list --json | jq -r 'map(select(.id == "suspend" or .id == "lid") | .reason) | unique | join(",")')"
rm -r "$fake/etc"
expect "suspend does not apply in a virtual machine" "virtual machine" "$(VM=1 attended --list --json | jq -r '.[] | select(.id == "suspend") | .reason')"

# The store, and the protocol the panel reads
new_root
make_laptop
run speakers
expect "a verify test ends waiting on a person" "4" "$status"
expect "speakers asks for a comfortable level, then plays left and right" \
  "::prompt:: speakers.volume|::prompt:: speakers.left|::progress:: 0.5|::prompt:: speakers.right|::progress:: 1" \
  "$(grep '^::' <<<"$out" | grep -v verify | cut -d' ' -f1-2 | paste -sd'|' -)"
expect "the question is the last line, after the detail" "::verify:: speakers.question Did you hear*" "$(tail -n 1 <<<"$out")"
expect "the detail names the speakers, the level and the driver" "played left, then right, on the built-in speakers at 45% (snd_hda_intel)" "$(detail)"
expect "the tones go to the speakers" "2" "$(grep -c 'pw-play --target alsa_output.pci-0000_00_1f.3.analog-stereo .*/\(left\|right\).wav' "$fake/stub/calls")"
expect "the volume is never touched" "0" "$(grep -c 'set-sink-volume' "$fake/stub/calls" || true)"
expect "the pending file holds the detail and the question" "speakers.question played left, then right, on the built-in speakers at 45% (snd_hda_intel)" \
  "$(jq -r '"\(.key) \(.detail)"' "$fake/state/attended/speakers.pending.json")"
expect "the list shows it pending" "pending" "$(attended --list --json | jq -r '.[] | select(.id == "speakers") | .result')"

attended speakers --record pass
expect "a pass after a pending question keeps the measured detail" "pass played left, then right, on the built-in speakers at 45% (snd_hda_intel)" \
  "$(stored speakers '"\(.result) \(.detail)"')"
expect "recording clears the pending question" "no" "$([[ -e $fake/state/attended/speakers.pending.json ]] && echo yes || echo no)"
expect "a result carries when it finished" "number" "$(stored speakers '.finished | type')"
expect "the store holds only finished results, written whole" "speakers.json" "$(ls -A "$fake/state/attended")"

run speakers
attended speakers --record skip
expect "a skipped question records a skip" "skip not answered" "$(stored speakers '"\(.result) \(.detail)"')"
attended keyboard --record pass --detail "every key on 6 rows"
expect "a panel measurement is recorded with its own detail" "pass every key on 6 rows" "$(stored keyboard '"\(.result) \(.detail)"')"
expect "the list carries a stored result's detail" "pass every key on 6 rows" "$(attended --list --json | jq -r '.[] | select(.id == "keyboard") | "\(.result) \(.detail)"')"
status=0
attended keyboard --record maybe >/dev/null 2>&1 || status=$?
expect "an unknown answer is a usage error" "2" "$status"
status=0
attended --record pass >/dev/null 2>&1 || status=$?
expect "an answer with no test is a usage error" "2" "$status"
attended --reset
expect "reset forgets every result" "null null" "$(attended --list --json | jq -r 'map(select(.id == "speakers" or .id == "keyboard") | .result // "null") | join(" ")')"

run keyboard
expect "a panel test run from here says to use the walkthrough and records nothing" "77 only the walkthrough can observe this*" "$status $(detail)"
expect "a panel test run records nothing" "no" "$([[ -e $fake/state/attended/keyboard.json ]] && echo yes || echo no)"
new_root
run lid
expect "a test that does not apply exits as a skip and records nothing" "77 not applicable: not a laptop no" \
  "$status $(detail) $([[ -e $fake/state/attended/lid.json ]] && echo yes || echo no)"

# Where the sound goes
new_root
make_laptop
echo alsa_output.pci-0000_00_1f.3.hdmi-stereo >"$fake/stub/pa/default-sink"
run speakers
expect "speakers are skipped when audio goes to HDMI, and the skip is recorded" "77 audio is going to HDMI or DisplayPort, not the built-in speakers skip" \
  "$status $(detail) $(stored speakers .result)"
expect "nothing played to HDMI" "0" "$(grep -c pw-play "$fake/stub/calls" || true)"
echo alsa_output.pci-0000_00_1f.3.analog-stereo >"$fake/stub/pa/default-sink"
set_json "$fake/stub/pa/sinks.json" 'map(if .name | endswith("analog-stereo") then .active_port = "analog-output-headphones" else . end)'
run speakers
expect "speakers are skipped when headphones have the output" "audio is going to headphones, not the built-in speakers" "$(detail)"

new_root
make_laptop
echo omarchy_speaker_tuning >"$fake/stub/pa/default-sink"
echo alsa_output.pci-0000_00_1f.3.analog-stereo >"$fake/stub/pa/physical"
run speakers
expect "tuned speakers play through the tuning and are judged by the sink it feeds" "4 played left, then right, on the built-in speakers at 45% (snd_hda_intel), through omarchy speaker tuning" \
  "$status $(detail)"
expect "the tones go to the tuning" "2" "$(grep -c 'pw-play --target omarchy_speaker_tuning' "$fake/stub/calls")"

# Terminal mode asks itself, with no protocol lines
new_root
make_laptop
if command -v script >/dev/null; then
  terminal() {
    status=0
    out=$(STUB=$fake/stub OMARCHY_ROLLCALL_ROOT=$fake OMARCHY_ROLLCALL_STATE=$fake/state HOME=$fake/home PATH="$stub_bin:$ROOT/bin:$PATH" \
      script -qec "$ROOT/bin/omarchy-rollcall-test $*" /dev/null 2>/dev/null | tr -d '\r') || status=$?
  }
  GUM_ANSWER=Yes terminal speakers
  expect "a yes in a terminal passes" "0 pass" "$status $(stored speakers .result)"
  expect "a terminal sees plain prompts and no protocol" "no" "$(grep -q '^::' <<<"$out" && echo yes || echo no)"
  expect "a terminal is told the steps first" "Set a comfortable volume, then listen*" "$(head -n 1 <<<"$out")"
  expect "a terminal sees the prompt sentences" "Listen: a tone from the left speaker." "$(grep 'left speaker\.$' <<<"$out")"
  GUM_ANSWER=No terminal speakers
  expect "a no in a terminal fails" "1 fail" "$status $(stored speakers .result)"
  GUM_ANSWER="" terminal speakers
  expect "escape in a terminal skips" "77 skip not answered" "$status $(stored speakers '"\(.result) \(.detail)"')"
  GUM_ANSWER=Yes terminal speakers --no-ask
  expect "--no-ask in a terminal leaves the question to the panel" "4 ::verify:: speakers.question*" "$status $(tail -n 1 <<<"$out")"
  terminal keyboard
  expect "a panel test in a terminal says to use the walkthrough" "77 only the walkthrough can observe this*" "$status $out"
else
  skip "terminal mode needs script(1)"
fi

# Volume keys: observed in PipeWire, put back exactly
new_root
make_laptop
volume_person() {
  case $1 in
    volume-keys.up) sink_volume 33277 ;;
    volume-keys.down) sink_volume 29000 ;;
    volume-keys.mute) sink_mute true ;;
    volume-keys.unmute) sink_mute false ;;
  esac
}
person=volume_person run volume-keys
expect "volume keys pass when each press reaches the output" "0 Volume Up, Volume Down and Mute each changed the output; volume and mute put back" "$status $(detail)"
expect "the volume is put back exactly" "30000 30000 false" \
  "$(jq -r '.[0] | "\(.volume["front-left"].value) \(.volume["front-right"].value) \(.mute)"' "$fake/stub/pa/sinks.json")"
expect "only what changed is put back" "pactl set-sink-volume alsa_output.pci-0000_00_1f.3.analog-stereo 30000 30000" "$(grep pactl "$fake/stub/calls")"

sink_volume 65536
person=volume_person run volume-keys
expect "at full volume, Volume Down is asked for first" "::prompt:: volume-keys.down" "$(grep -m 1 '^::prompt::' <<<"$out" | cut -d' ' -f1-2)"

new_root
make_laptop
run volume-keys
expect "a key that changes nothing fails once the wait is up" "1 Volume Up changed nothing within 1 s" "$status $(detail)"

new_root
make_laptop
up_only() {
  [[ $1 == "volume-keys.up" ]] && sink_volume 40000
  return 0
}
OMARCHY_ROLLCALL_TIMEOUT=10
attended_bg volume-keys
await_prompt volume-keys.up
up_only volume-keys.up
await_prompt volume-keys.down
kill -TERM "$pid"
status=0
wait "$pid" || status=$?
expect "a volume test stopped mid-way puts the volume back" "143 30000" "$status $(jq -r '.[0].volume["front-left"].value' "$fake/stub/pa/sinks.json")"
expect "a stopped test records nothing" "no" "$([[ -e $fake/state/attended/volume-keys.json ]] && echo yes || echo no)"

# Microphone mute key
new_root
make_laptop
mic_person() {
  local mute=true
  [[ $1 == "mic-mute-key.again" ]] && mute=false
  set_json "$fake/stub/pa/sources.json" "map(.mute = $mute)"
}
person=mic_person run mic-mute-key
expect "the microphone mute key passes when the source follows it" "0 the key muted and unmuted the microphone; mute put back" "$status $(detail)"

# Brightness keys: sysfs, put back exactly
new_root
make_laptop
brightness() {
  printf '%s\n' "$1" >"$fake/sys/class/backlight/intel_backlight/brightness"
}
brightness_person() {
  case $1 in
    brightness-keys.down) brightness 25 ;;
    brightness-keys.up) brightness 60 ;;
  esac
}
person=brightness_person run brightness-keys
expect "brightness keys measure both steps, then ask whether the screen dimmed" "4 intel_backlight went 50 → 25 → 60 of 100; brightness put back" "$status $(detail)"
expect "brightness is put back before the question" "50 brightnessctl -q -d intel_backlight set 50" \
  "$(cat "$fake/sys/class/backlight/intel_backlight/brightness") $(grep brightnessctl "$fake/stub/calls")"

brightness 3
person=brightness_person run brightness-keys
expect "near the bottom, Brightness Up is asked for first" "::prompt:: brightness-keys.up" "$(grep -m 1 '^::prompt::' <<<"$out" | cut -d' ' -f1-2)"

new_root
make_laptop
attended_bg brightness-keys
await_prompt brightness-keys.down
brightness 20
await_prompt brightness-keys.up
kill -TERM "$pid"
status=0
wait "$pid" || status=$?
expect "a brightness test stopped mid-way puts the brightness back" "143 50" "$status $(cat "$fake/sys/class/backlight/intel_backlight/brightness")"
OMARCHY_ROLLCALL_TIMEOUT=1

# Keyboard backlight
new_root
make_laptop
person=kbd_person
kbd_person() {
  printf '2\n' >"$fake/sys/class/leds/platform::kbd_backlight/brightness"
}
run keyboard-backlight-key
expect "the keyboard backlight key passes on a change, and the level is put back" "0 platform::kbd_backlight went from 1 to 2 of 3; brightness put back 1" \
  "$status $(detail) $(cat "$fake/sys/class/leds/platform::kbd_backlight/brightness")"
person=nobody

# Wireless key: rfkill, and radios turned back on when stopped
new_root
make_laptop
radios() {
  printf '%s\n' "$1" >"$fake/sys/class/rfkill/rfkill0/soft"
  printf '%s\n' "$1" >"$fake/sys/class/rfkill/rfkill1/soft"
}
wireless_person() {
  case $1 in
    wireless-key.press) radios 1 ;;
    wireless-key.again) radios 0 ;;
  esac
}
person=wireless_person run wireless-key
expect "the wireless key passes when it turns the radios off and on" "0 the key turned the radios off and on again (bluetooth,wlan)" "$status $(detail)"
off_only() {
  [[ $1 == "wireless-key.press" ]] && radios 1
  return 0
}
person=off_only run wireless-key
expect "radios the key left off are turned back on" "1 0 0" \
  "$status $(cat "$fake/sys/class/rfkill/rfkill0/soft") $(cat "$fake/sys/class/rfkill/rfkill1/soft")"
expect "only the radio types it blocked are unblocked" "rfkill unblock bluetooth|rfkill unblock wlan" "$(grep rfkill "$fake/stub/calls" | paste -sd'|' -)"
renamed_person() {
  case $1 in
    wireless-key.press) radios 1 ;;
    # The card loses power and comes back under a new name.
    wireless-key.again)
      rm -r "$fake/sys/class/rfkill/rfkill0"
      radio 2 wlan phy1
      printf '0\n' >"$fake/sys/class/rfkill/rfkill1/soft"
      ;;
  esac
}
radios 0
person=renamed_person run wireless-key
expect "a radio that comes back under a new name counts as back" "0 the key turned the radios off and on again (bluetooth,wlan)" "$status $(detail)"
# Starting in airplane mode, the first press alone turns every radio on; the
# second press still has to be seen.
rm -rf "$fake/sys/class/rfkill/rfkill2"
radio 0 wlan phy0
radios 1
airplane_once() {
  [[ $1 == "wireless-key.press" ]] && radios 0
  return 0
}
person=airplane_once run wireless-key
expect "from airplane mode, a second press that never comes fails" "1 no radio changed back within 1 s of the second press" "$status $(detail)"
airplane_twice() {
  case $1 in
    wireless-key.press) radios 0 ;;
    wireless-key.again) radios 1 ;;
  esac
}
# Bluetooth comes back a moment after Wi-Fi; it must not stand in for the
# second press.
late_bluetooth() {
  case $1 in
    wireless-key.press)
      printf '0\n' >"$fake/sys/class/rfkill/rfkill0/soft"
      (sleep 1.5; printf '0\n' >"$fake/sys/class/rfkill/rfkill1/soft"; : >"$fake/stub/late-done") >/dev/null 2>&1 &
      ;;
  esac
  return 0
}
radios 1
rm -f "$fake/stub/late-done"
OMARCHY_ROLLCALL_TIMEOUT=3 person=late_bluetooth run wireless-key
expect "a radio that comes up late after the first press is not the second press" "1 no radio changed back within 3 s of the second press" "$status $(detail)"
for _ in $(seq 1 50); do [[ -e $fake/stub/late-done ]] && break; sleep 0.1; done
radios 1
person=airplane_twice run wireless-key
expect "from airplane mode, both presses seen pass" "0 the key turned the radios on and off again (bluetooth,wlan)" "$status $(detail)"

# A card whose power the key cuts vanishes instead of showing as blocked.
vanishing_person() {
  case $1 in
    wireless-key.press) rm -r "$fake/sys/class/rfkill/rfkill0" ;;
    wireless-key.again) radio 0 wlan phy0 ;;
  esac
}
radios 0
person=vanishing_person run wireless-key
expect "a radio that vanishes when the key cuts it and comes back passes" "0 the key turned the radios off and on again (bluetooth,wlan)" "$status $(detail)"

# Bluetooth was off: the key brings every radio back on, and the test turns
# Bluetooth off again.
rm -rf "$fake/sys/class/rfkill/rfkill2"
radio 0 wlan phy0
radios 0
printf '1\n' >"$fake/sys/class/rfkill/rfkill1/soft"
: >"$fake/stub/calls"
person=wireless_person run wireless-key
expect "a radio that was off at the start does not have to come back off" "0 the key turned the radios off and on again (bluetooth,wlan)" "$status $(detail)"
expect "a radio that was off at the start is turned off again" "1 rfkill block bluetooth" \
  "$(cat "$fake/sys/class/rfkill/rfkill1/soft") $(grep rfkill "$fake/stub/calls" | paste -sd'|' -)"

# Media keys, through MPRIS
new_root
media_person() {
  case $1 in
    media-keys.start) echo Playing >"$fake/stub/players/org.mpris.MediaPlayer2.chromium.instance42" ;;
    media-keys.pause) echo Paused >"$fake/stub/players/org.mpris.MediaPlayer2.chromium.instance42" ;;
    media-keys.resume) echo Playing >"$fake/stub/players/org.mpris.MediaPlayer2.chromium.instance42" ;;
  esac
}
person=media_person run media-keys
expect "media keys ask someone to play something, watch it pause and resume, then ask" "4 Play/Pause paused and resumed chromium" "$status $(detail)"
expect "the start prompt comes first" "::prompt:: media-keys.start" "$(grep -m 1 '^::prompt::' <<<"$out" | cut -d' ' -f1-2)"
run media-keys
expect "a player that does not pause fails" "1 Play/Pause did not pause chromium within 1 s" "$status $(detail)"

# Caps Lock, through Hyprland
new_root
caps_person() {
  local state=true
  [[ $1 == "caps-lock-light.again" ]] && state=false
  set_json "$fake/stub/hypr/devices.json" ".keyboards[0].capsLock = $state"
  [[ $state == "true" ]] && printf '1\n' >"$fake/sys/class/leds/input3::capslock/brightness" || printf '0\n' >"$fake/sys/class/leds/input3::capslock/brightness"
}
person=caps_person run caps-lock-light
expect "Caps Lock is watched on and off, then the light is asked about" "4 Caps Lock turned on and off" "$status $(detail)"
expect "the question lets a keyboard with no light skip" "*Skip if the keyboard has no such light." "$(tail -n 1 <<<"$out")"

# External display: in Hyprland, then every window back
new_root
make_laptop
display_person() {
  case $1 in
    external-display.plug)
      printf 'connected\n' >"$fake/sys/class/drm/card0-HDMI-A-1/status"
      set_json "$fake/stub/hypr/monitors.json" '. + [{"id": 1, "name": "HDMI-A-1", "width": 3840, "height": 2160, "refreshRate": 59.997}]'
      ;;
    external-display.check-unplug)
      printf 'disconnected\n' >"$fake/sys/class/drm/card0-HDMI-A-1/status"
      set_json "$fake/stub/hypr/monitors.json" 'map(select(.name != "HDMI-A-1"))'
      ;;
  esac
}
person=display_person run external-display
expect "an external display is named by connector kind and mode, and asked about" "4 HDMI, 3840x2160 at 60 Hz; every window came back when it was unplugged" "$status $(detail)"
echo '[{"mapped": true, "hidden": false, "monitor": 0}, {"mapped": true, "hidden": false, "monitor": 1}]' >"$fake/stub/hypr/clients.json"
person=display_person run external-display
expect "a window left on the unplugged display fails" "1 a window stayed on the unplugged display (HDMI, 3840x2160 at 60 Hz)" "$status $(detail)"

# USB ports: speed and capability, accumulated per port
new_root
mkdir -p "$fake/sys/bus/usb/devices/usb2/2-0:1.0/usb2-port1" "$fake/sys/bus/usb/devices/usb1/1-0:1.0/usb1-port1" "$fake/sys/bus/usb/devices/usb1/1-0:1.0/usb1-port2"
printf '10000\n' >"$fake/sys/bus/usb/devices/usb2/speed"
ln -s "$fake/sys/bus/usb/devices/usb2/2-0:1.0/usb2-port1" "$fake/sys/bus/usb/devices/usb1/1-0:1.0/usb1-port1/peer"
ln -s "$fake/sys/bus/usb/devices/usb1/1-0:1.0/usb1-port1" "$fake/sys/bus/usb/devices/usb2/2-0:1.0/usb2-port1/peer"
usb_device() {
  local dir=$fake/sys/bus/usb/devices/$1
  mkdir -p "$dir"
  printf '%s\n' "$2" >"$dir/speed"
  printf ' %s\n' "$3" >"$dir/version"
  ln -s "$4" "$dir/port"
}
usb_person() {
  usb_device "$@"
}
person=usb_fast
usb_fast() {
  usb_device 2-1 5000 3.20 "$fake/sys/bus/usb/devices/usb2/2-0:1.0/usb2-port1"
}
run usb-port
expect "a USB 3 device in a fast port reports both speeds, named by the port's USB 2 side" \
  "0 port 1-1: USB 3 device at 5000 Mb/s, port up to 10000 Mb/s; ports tried: 1-1 5000/10000 Mb/s" "$status $(detail)"
rm -r "$fake/sys/bus/usb/devices/2-1"
usb_slow() {
  usb_device 1-1 480 3.20 "$fake/sys/bus/usb/devices/usb1/1-0:1.0/usb1-port1"
}
person=usb_slow run usb-port
expect "a USB 3 device stuck at USB 2 speed in a fast port fails" \
  "1 port 1-1: a USB 3 device came up at 480 Mb/s in a port that does 10000 Mb/s*; ports tried: 1-1 480/10000 Mb/s" "$status $(detail)"
usb_second() {
  usb_device 1-2 12 1.10 "$fake/sys/bus/usb/devices/usb1/1-0:1.0/usb1-port2"
}
person=usb_second run usb-port
expect "another port's pass still carries the earlier slow port" \
  "1 port 1-2: USB 1 device at 12 Mb/s, port up to 480 Mb/s; ports tried: 1-1 480/10000 Mb/s, 1-2 12/480 Mb/s; slow earlier: 1-1" "$status $(detail)"
person=nobody run usb-port
expect "no device plugged in fails once the wait is up" "1 no USB device appeared within 1 s" "$status $(detail)"
person=nobody

# Charger
new_root
make_laptop
charger_person() {
  if [[ $1 == "charger.unplug" ]]; then
    printf '0\n' >"$fake/sys/class/power_supply/AC/online"
    printf 'Discharging\n' >"$fake/sys/class/power_supply/BAT0/status"
  else
    printf '1\n' >"$fake/sys/class/power_supply/AC/online"
    printf 'Charging\n' >"$fake/sys/class/power_supply/BAT0/status"
  fi
}
person=charger_person run charger
expect "the charger passes when AC and the battery both follow it" "0 the charger went offline and online, and the battery went discharging, then charging" "$status $(detail)"
stuck_battery() {
  [[ $1 == "charger.unplug" ]] && printf '0\n' >"$fake/sys/class/power_supply/AC/online"
  return 0
}
printf '1\n' >"$fake/sys/class/power_supply/AC/online"
person=stuck_battery run charger
expect "a battery that keeps saying charging on battery fails" "1 the charger went offline, but the battery reports charging" "$status $(detail)"

# Bluetooth: a device the person connected, and a tone when it is audio
new_root
bluetooth_person() {
  echo "Device AA:BB:CC:DD:EE:FF Headphones" >"$fake/stub/bt/connected"
  set_json "$fake/stub/pa/sinks.json" '. + [{"name": "bluez_output.AA_BB_CC_DD_EE_FF.1", "volume": {}, "mute": false, "ports": [], "properties": {"api.bluez5.address": "AA:BB:CC:DD:EE:FF", "api.bluez5.codec": "aac"}}]'
}
echo audio-headphones >"$fake/stub/bt/icon"
person=bluetooth_person run bluetooth-device
expect "a Bluetooth audio device takes a tone, and the detail names no address" "4 audio-headphones connected and took a tone over AAC" "$status $(detail)"
expect "the tone goes to the Bluetooth sink" "1" "$(grep -c 'pw-play --target bluez_output.AA_BB_CC_DD_EE_FF.1' "$fake/stub/calls")"
echo input-mouse >"$fake/stub/bt/icon"
desktop_audio
person=nobody run bluetooth-device
expect "a connected device that is not audio passes on being connected" "0 input-mouse connected" "$status $(detail)"
echo audio-headset >"$fake/stub/bt/icon"
person=nobody run bluetooth-device
expect "a connected headset with no audio output fails" "1 audio-headset connected, but no audio output for it appeared" "$status $(detail)"
echo audio-card >"$fake/stub/bt/icon"
person=nobody run bluetooth-device
expect "a connected speaker with no audio output fails" "1 audio-card connected, but no audio output for it appeared" "$status $(detail)"
echo audio-input-microphone >"$fake/stub/bt/icon"
person=nobody run bluetooth-device
expect "a connected microphone has no output to offer and passes on being connected" "0 audio-input-microphone connected" "$status $(detail)"
radio 1 bluetooth hci0
printf '1\n' >"$fake/sys/class/rfkill/rfkill1/soft"
run bluetooth-device
expect "Bluetooth turned off is a skip" "77 Bluetooth is turned off" "$status $(detail)"

# Suspend: the kernel's counters, then every check that passed before
new_root
echo '{"checks": [{"id": "wifi", "result": "pass", "detail": "connected (iwlwifi)"}, {"id": "bluetooth", "result": "skip", "detail": "turned off"}]}' >"$fake/stub/rollcall-before.json"
cp "$fake/stub/rollcall-before.json" "$fake/stub/rollcall-after.json"
run suspend
expect "a counted suspend with every check still passing passes" "0 slept and woke (deep); every check that passed before still passes" "$status $(detail)"
expect "suspend counts down before it sleeps" "::prompt:: suspend.countdown|::progress:: 0.2" "$(grep '^::' <<<"$out" | head -n 2 | cut -d' ' -f1-2 | paste -sd'|' -)"
rm "$fake/stub/rollcall-count"
echo '{"checks": [{"id": "wifi", "result": "fail", "detail": "NetworkManager reports the adapter unavailable (iwlwifi)"}, {"id": "bluetooth", "result": "fail", "detail": "x"}]}' >"$fake/stub/rollcall-after.json"
run suspend
expect "a check that passed before and fails after waking is named" \
  "1 slept and woke (deep), but these checks passed before and do not now: wifi (fail: NetworkManager reports the adapter unavailable (iwlwifi))" "$status $(detail)"
rm "$fake/stub/rollcall-count"
echo '{"checks": [{"id": "wifi", "result": "skip", "detail": "NetworkManager is not running"}, {"id": "bluetooth", "result": "skip", "detail": "turned off"}]}' >"$fake/stub/rollcall-after.json"
run suspend
expect "a check that passed before and only skips after waking is lost too" \
  "1 slept and woke (deep), but these checks passed before and do not now: wifi (skip: NetworkManager is not running)" "$status $(detail)"
rm "$fake/stub/rollcall-count"
echo '{"checks": [{"id": "wifi", "result": "pass", "detail": "connected (iwlwifi)"}, {"id": "network", "result": "pass", "detail": "online (wifi)"}, {"id": "time", "result": "pass", "detail": "synchronised"}]}' >"$fake/stub/rollcall-before.json"
echo '{"checks": [{"id": "wifi", "result": "pass", "detail": "on, not connected (iwlwifi)"}, {"id": "network", "result": "skip", "detail": "offline"}, {"id": "time", "result": "skip", "detail": "not synchronised while offline"}]}' >"$fake/stub/rollcall-after.json"
run suspend
expect "being offline after waking is where the person is, not a lost check" "0 slept and woke (deep); every check that passed before still passes" "$status $(detail)"
rm "$fake/stub/rollcall-count"
echo '{"checks": [{"id": "wifi", "result": "pass", "detail": "on, not connected (iwlwifi)"}, {"id": "network", "result": "skip", "detail": "NetworkManager is not running"}, {"id": "time", "result": "skip", "detail": "timedated did not answer"}]}' >"$fake/stub/rollcall-after.json"
run suspend
expect "a network or clock whose service died on waking is lost" \
  "1 slept and woke (deep), but these checks passed before and do not now: network (skip: NetworkManager is not running), time (skip: timedated did not answer)" "$status $(detail)"
echo '{"checks": [{"id": "wifi", "result": "pass", "detail": "connected (iwlwifi)"}, {"id": "bluetooth", "result": "skip", "detail": "turned off"}]}' >"$fake/stub/rollcall-before.json"
rm "$fake/stub/rollcall-count"
echo '{"checks": []}' >"$fake/stub/rollcall-after.json"
run suspend
expect "a report that cannot be run after waking fails" "1 slept and woke (deep), but the automated checks could not be run afterwards" "$status $(detail)"
rm "$fake/stub/rollcall-count"
echo '{"checks": [{"id": "wifi", "result": "fail", "detail": "NetworkManager reports the adapter unavailable (iwlwifi)"}, {"id": "bluetooth", "result": "fail", "detail": "x"}]}' >"$fake/stub/rollcall-after.json"
SUSPEND_FAILS=1 run suspend
expect "a failed suspend names the step" "1 suspend failed at suspend_noirq" "$status $(detail)"
SUSPEND_FAILS=1 SUSPEND_DEV=usb3-0000:00:14.0 run suspend
expect "a plain failed device is named" "1 suspend failed at suspend_noirq (usb3-0000:00:14.0)" "$status $(detail)"
SUSPEND_FAILS=1 SUSPEND_DEV=nvme-Samsung_SSD_990_S7KGNU0X123456 run suspend
expect "a device name that can carry a serial is left out" "1 suspend failed at suspend_noirq" "$status $(detail)"
rm -f "$fake/stub/rollcall-count"
cp "$fake/stub/rollcall-before.json" "$fake/stub/rollcall-after.json"
SUSPEND_CALLED_OFF=then-sleeps run suspend
expect "a suspend a wake event called off is not a failure when the next one sleeps" "0 slept and woke (deep); every check that passed before still passes" "$status $(detail)"
SUSPEND_CALLED_OFF=always run suspend
expect "only called-off suspends fail saying so" \
  "1 every suspend was called off by a wake event on the way down; keep hands off the keyboard and mouse until it sleeps" "$status $(detail)"
printf '[s2idle] deep\n' >"$fake/sys/power/mem_sleep"
HW_SLEEP=0 run suspend
expect "s2idle that never reached hardware sleep fails" "1 the machine slept but never reached hardware low-power sleep (s2idle)" "$status $(detail)"

# Lid
new_root
make_laptop
lid_person() {
  printf 'state:      closed\n' >"$fake/proc/acpi/button/lid/LID0/state"
  echo $(( $(<"$fake/sys/power/suspend_stats/success") + 1 )) >"$fake/sys/power/suspend_stats/success"
  printf 'state:      open\n' >"$fake/proc/acpi/button/lid/LID0/state"
}
person=lid_person run lid
expect "closing the lid passes on a counted suspend" "0 closing the lid slept the machine and opening it woke it (deep)" "$status $(detail)"
person=nobody run lid
expect "a lid never closed fails once the wait is up" "1 the lid was not closed within 1 s" "$status $(detail)"
LID_ACTION=ignore run lid
expect "a lid set to do nothing is a skip" "77 closing the lid is set not to sleep" "$status $(detail)"
unplug_then_lid() {
  case $1 in
    lid.unplug) printf '0\n' >"$fake/sys/class/power_supply/AC/online" ;;
    lid.close) lid_person ;;
  esac
}
person=unplug_then_lid LID_AC_ACTION=ignore run lid
expect "on the charger, where the lid does not sleep, the person unplugs first" \
  "0 closing the lid slept the machine and opening it woke it (deep)|::prompt:: lid.unplug" "$status $(detail)|$(grep -m1 '^::prompt::' <<<"$out" | cut -d' ' -f1-2)"
printf '1\n' >"$fake/sys/class/power_supply/AC/online"
person=nobody LID_AC_ACTION=ignore run lid
expect "a charger left in where the lid does not sleep is a skip" "77 the charger stayed in, and on the charger closing the lid does not sleep" "$status $(detail)"

# Fingerprint
new_root
mkdir -p "$fake/sys/bus/usb/devices/3-4"
printf '27c6\n' >"$fake/sys/bus/usb/devices/3-4/idVendor"
echo "User has no fingers enrolled for Goodix MOC Fingerprint Sensor." >"$fake/stub/fprint-list"
run fingerprint
expect "no enrolled finger is a skip" "77 no finger enrolled" "$status $(detail)"
printf 'Fingerprints for user:\n - #0: right-index-finger\n' >"$fake/stub/fprint-list"
echo "Verify result: verify-match (done)" >"$fake/stub/fprint-verify"
run fingerprint
expect "a matched finger passes" "0 the reader matched an enrolled finger (1 enrolled)" "$status $(detail)"
echo "Verify result: verify-no-match (done)" >"$fake/stub/fprint-verify"
run fingerprint
expect "an unmatched finger fails" "1 the reader did not match an enrolled finger" "$status $(detail)"

# Camera: one frame under the state directory
new_root
make_laptop
mkdir -p "$fake/sys/devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.0/video4linux/video0"
ln -s "$fake/sys/devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.0/video4linux/video0" "$fake/sys/class/video4linux/video0"
ln -s "$fake/sys/devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.0" "$fake/sys/class/video4linux/video0/device"
ln -s /sys/bus/usb/drivers/uvcvideo "$fake/sys/devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.0/driver"
printf '81:0\n' >"$fake/sys/class/video4linux/video0/dev"
printf 'E:ID_V4L_CAPABILITIES=:capture:\n' >"$fake/run/udev/data/c81:0"
touch "$fake/dev/video0"
run camera
expect "the camera shows its frame and asks" "4 took a 1280x720 frame (uvcvideo)" "$status $(detail)"
expect "the frame is under the state directory" "::image:: $fake/state/files/camera.jpg" "$(grep '^::image::' <<<"$out")"
YMAX=20 run camera
expect "a flat frame says why it might be" "took a 1280x720 frame (uvcvideo), nearly flat: a closed shutter or a dark room?" "$(detail)"
CAMERA_BUSY=1 run camera
expect "a camera another app holds is a skip" "77 the camera is in use by another application" "$status $(detail)"
CAMERA_FORMAT="Raw       :        gray :     8-bit Greyscale : 640x360" run camera
expect "an infrared camera is not judged as a picture" "77 the only camera found is an infrared one" "$status $(detail)"
mkdir -p "$fake/sys/devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.2/video4linux/video2"
ln -s "$fake/sys/devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.2/video4linux/video2" "$fake/sys/class/video4linux/video2"
ln -s "$fake/sys/devices/pci0000:00/0000:00:14.0/usb3/3-6/3-6:1.2" "$fake/sys/class/video4linux/video2/device"
printf '81:2\n' >"$fake/sys/class/video4linux/video2/dev"
printf 'E:ID_V4L_CAPABILITIES=:capture:\n' >"$fake/run/udev/data/c81:2"
touch "$fake/dev/video2"
: >"$fake/stub/calls"
IR_NODE=video0 run camera
expect "an infrared camera listed first gives way to the visible one" "4 1" "$status $(grep -c -- "-i $fake/dev/video2 " "$fake/stub/calls")"
rm "$fake/sys/class/video4linux/video0" "$fake/sys/class/video4linux/video2"
mkdir -p "$fake/sys/bus/pci/drivers/intel-ipu6/0000:00:05.0"
run camera
expect "a sensor behind an image processor with no relay fails" "1 the camera sits behind an image processor and no relay or libcamera makes it available to apps" "$status $(detail)"
mkdir -p "$fake/home/.config/omarchy" "$fake/sys/devices/virtual/video4linux/video50"
echo 'CARD_LABEL="Front Camera"' >"$fake/home/.config/omarchy/camera-relay.env"
echo "Front Camera" >"$fake/sys/devices/virtual/video4linux/video50/name"
touch "$fake/dev/video50"
run camera
expect "Omarchy's relay is the camera apps use" "4 took a 1280x720 frame (Omarchy's camera relay)" "$status $(detail)"
rm "$fake/home/.config/omarchy/camera-relay.env"
echo "Virtual Camera" >"$fake/sys/devices/virtual/video4linux/video50/name"
printf '81:50\n' >"$fake/sys/devices/virtual/video4linux/video50/dev"
printf 'E:ID_V4L_CAPABILITIES=:capture:\n' >"$fake/run/udev/data/c81:50"
run camera
expect "another relay's capture node is the camera apps use" "4 took a 1280x720 frame (Omarchy's camera relay)" "$status $(detail)"
rm -r "$fake/sys/devices/virtual/video4linux/video50"
mkdir -p "$fake/sys/devices/pci0000:00/0000:00:05.0/video4linux/video3"
ln -s "$fake/sys/devices/pci0000:00/0000:00:05.0/video4linux/video3" "$fake/sys/class/video4linux/video3"
ln -s "$fake/sys/devices/pci0000:00/0000:00:05.0" "$fake/sys/class/video4linux/video3/device"
ln -s /sys/bus/pci/drivers/intel-ipu6 "$fake/sys/devices/pci0000:00/0000:00:05.0/driver"
printf '81:3\n' >"$fake/sys/class/video4linux/video3/dev"
printf 'E:ID_V4L_CAPABILITIES=:capture:\n' >"$fake/run/udev/data/c81:3"
touch "$fake/dev/video3"
run camera
expect "the image processor's own capture nodes are never tried" "1 the camera sits behind an image processor and no relay or libcamera makes it available to apps" "$status $(detail)"
PW_DUMP='[{"info": {"props": {"media.class": "Video/Source", "api.libcamera.path": "/base/soc/cci/camera"}}}]' run camera
expect "a camera only libcamera reaches is not judged here" "77 the camera reaches apps through PipeWire and libcamera; open a camera app to check its picture" "$status $(detail)"

# Microphone: a recording that is speech, silence or steady noise
new_root
make_laptop
run microphone
expect "speech from the built-in microphone is played back and asked about" "4 recorded speech from the built-in microphone, peak -12 dB, 14 dB above its average (snd_hda_intel)" "$status $(detail)"
expect "it records from the built-in microphone" "1" "$(grep -c 'pw-record --target alsa_input.pci-0000_00_1f.3.analog-stereo' "$fake/stub/calls")"
ASTATS="-inf -inf -inf" run microphone
expect "silence fails" "1 the built-in microphone recorded silence, peak -inf dB (snd_hda_intel)" "$status $(detail)"
ASTATS="-30.0 -33.0 -32.5" run microphone
expect "steady noise with no speech in it fails" "1 the built-in microphone recorded a steady level with no speech in it, peak -30 dB (snd_hda_intel)" "$status $(detail)"
set_json "$fake/stub/pa/sources.json" 'map(.mute = true)'
run microphone
expect "a muted microphone is a skip" "77 the microphone is muted" "$status $(detail)"

# Headphones: the jack sensed, and the speakers giving way
new_root
make_laptop
headphones_person() {
  [[ $1 == "headphones.plug" ]] || return 0
  set_json "$fake/stub/pa/cards.json" '.[0].ports["analog-output-headphones"].availability = "available"'
  set_json "$fake/stub/pa/sinks.json" 'map(if .name | endswith("analog-stereo") then .active_port = "analog-output-headphones" else . end)'
}
person=headphones_person run headphones
expect "headphones pass the jack and the route, then ask about the tones" "4 the jack sensed the plug and audio moved from the speakers to the headphones (snd_hda_intel)" "$status $(detail)"
jack_only() {
  [[ $1 == "headphones.plug" ]] && set_json "$fake/stub/pa/cards.json" '.[0].ports["analog-output-headphones"].availability = "not available" | .[0].ports["analog-output-headphones"].availability = "available"'
  return 0
}
laptop_audio
person=jack_only run headphones
expect "a jack that senses the plug while audio stays on the speakers fails" "1 the jack reports headphones, but audio stayed on the speakers" "$status $(detail)"
laptop_audio
person=nobody run headphones
expect "nothing plugged in fails once the wait is up" "1 the jack reported nothing within 1 s of asking to plug headphones in" "$status $(detail)"
