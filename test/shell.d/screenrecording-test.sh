#!/bin/bash

set -euo pipefail

# No session variables, credentials, or developer command lookup reach fixtures.
if [[ ${1:-} != "--isolated" ]]; then
  exec /usr/bin/env -i PATH=/usr/bin:/bin LC_ALL=C /bin/bash "$0" --isolated
fi

source "$(dirname "$0")/base-test.sh"

tmp_dir=$(mktemp -d)
stub_bin="$tmp_dir/bin"
tool_bin="$tmp_dir/tools"
mkdir -p "$stub_bin" "$tool_bin" "$tmp_dir/home" "$tmp_dir/tmp"
export HOME="$tmp_dir/home" TMPDIR="$tmp_dir/tmp"
export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache" XDG_STATE_HOME="$HOME/.local/state"
export OMARCHY_TEST_SANDBOX="$tmp_dir" OMARCHY_TEST_PID_LOG="$tmp_dir/fixture-pids"

stop_fixture_recorders() {
  local pid state
  [[ -f $OMARCHY_TEST_PID_LOG ]] || return 0
  while read -r pid; do
    if [[ $pid =~ ^[0-9]+$ ]] && grep -qzxF "OMARCHY_TEST_SANDBOX=$tmp_dir" "/proc/$pid/environ" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      for _ in {1..100}; do
        [[ -r /proc/$pid/stat ]] || break
        state=$(<"/proc/$pid/stat")
        [[ ${state##*) } != "Z "* ]] || break
        sleep 0.01
      done
      wait "$pid" 2>/dev/null || true
    fi
  done <"$OMARCHY_TEST_PID_LOG"
  : >"$OMARCHY_TEST_PID_LOG"
}
cleanup() {
  stop_fixture_recorders
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

# Only these harmless tools and checkout helpers are discoverable. In
# particular an installed recorder can never become an accidental fallback.
for tool in awk bash cat chmod cmp date diff dirname env flock grep jq ln ls mkdir mkfifo mktemp mv python3 readlink rm rmdir sed sleep stat tac tail touch wc; do
  ln -s "$(command -v "$tool")" "$tool_bin/$tool"
done
for tool in omarchy-capture-webcam-list omarchy-hw-webcam omarchy-capture-screenrecording-with-webcam omarchy-capture-webcam-resize omarchy-i18n omarchy-cmd-present; do
  ln -s "$ROOT/bin/$tool" "$tool_bin/$tool"
done
# A failed or cancelled start may clean its webcam; there is no live overlay.
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/pkill"
chmod +x "$stub_bin/pkill"

cat >"$stub_bin/v4l2-ctl" <<'SH'
#!/bin/bash

[[ -n ${OMARCHY_TEST_V4L2_LOG:-} ]] && printf '%s\n' "$*" >>"$OMARCHY_TEST_V4L2_LOG"
[[ ${OMARCHY_TEST_NO_WEBCAM:-false} == "true" ]] && exit 0

case "$1" in
--list-devices)
  printf '%s\n' "ipu6 (PCI:0000:00:05.0):"
  printf '\t%s\n' "/dev/video0"
  printf '\t%s\n' "/dev/video1"

  if [[ ${OMARCHY_TEST_RAW_WEBCAM:-false} != "true" ]]; then
    printf '\n%s\n' "Built-in Webcam: Integrated Camera"
    printf '\t%s\n' "/dev/video42"
    printf '\t%s\n' "/dev/video43"
    printf '\n%s\n' "USB Capture Card: External Camera"
    printf '\t%s\n' "/dev/video2"
  fi

  if [[ ${OMARCHY_TEST_DUAL_NODE_WEBCAM:-false} == "true" ]]; then
    printf '\n%s\n' "Dual Node Camera: ISP Wrapper"
    printf '\t%s\n' "/dev/video7"
    printf '\t%s\n' "/dev/video8"
    printf '\n%s\n' "Metadata Only: Sensor"
    printf '\t%s\n' "/dev/video9"
  fi
  ;;
--device)
  case "$2" in
  /dev/video0) device_capability="Video Output" ;;
  /dev/video1) device_capability="Metadata Capture" ;;
  /dev/video7 | /dev/video9) device_capability="Video Output" ;;
  *) device_capability="Video Capture" ;;
  esac

  printf '%s\n' \
    "Driver Info:" \
    $'\tCapabilities     : 0x84a00001' \
    $'\t\tVideo Capture' \
    $'\tDevice Caps      : 0x04200001' \
    $'\t\t'"$device_capability"
  ;;
esac
SH

cat >"$stub_bin/omarchy-menu-select" <<'SH'
#!/bin/bash

printf '%s\n' "$@" >"$OMARCHY_TEST_MENU_ARGS"
printf '%s\n' "$3"
SH

cat >"$stub_bin/omarchy-capture-screenrecording" <<'SH'
#!/bin/bash

printf '%s\n' "$@" >"$OMARCHY_TEST_RECORDER_ARGS"
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash

printf '%s\n' "$@" >"$OMARCHY_TEST_NOTIFICATION_ARGS"
SH

chmod +x "$stub_bin"/*

export PATH="$stub_bin:$tool_bin"
# The resize helper anchors to a region file here, so keep it out of the real one
export XDG_RUNTIME_DIR="$tmp_dir"
export OMARCHY_TEST_MENU_ARGS="$tmp_dir/menu-args"
export OMARCHY_TEST_RECORDER_ARGS="$tmp_dir/recorder-args"
export OMARCHY_TEST_NOTIFICATION_ARGS="$tmp_dir/notification-args"

mapfile -t capture_devices < <(omarchy-capture-webcam-list)
expected_capture_devices=(
  "/dev/video42  Built-in Webcam: Integrated Camera"
  "/dev/video2  USB Capture Card: External Camera"
)

if [[ ${capture_devices[*]} != "${expected_capture_devices[*]}" ]]; then
  fail "webcam detection filters output-only devices and collapses each capture group" \
    "expected: ${expected_capture_devices[*]}\nactual:   ${capture_devices[*]}"
fi
pass "webcam detection filters output-only devices and collapses each capture group"

dual_node=$(OMARCHY_TEST_DUAL_NODE_WEBCAM=true omarchy-capture-webcam-list) ||
  fail "webcam listing exits zero when the trailing device is filtered"
pass "webcam listing exits zero when the trailing device is filtered"

expected_dual_node="/dev/video42  Built-in Webcam: Integrated Camera
/dev/video2  USB Capture Card: External Camera
/dev/video8  Dual Node Camera: ISP Wrapper"
[[ $dual_node == "$expected_dual_node" ]] ||
  fail "webcam detection falls through to a later capture-capable node in a group" "$dual_node"
pass "webcam detection falls through to a later capture-capable node in a group"

# A video node udev recorded nothing for sends the guard to v4l2-ctl, which is
# what the stubbed answers below exercise.
fallback_v4l="$tmp_dir/v4l-fallback"
mkdir -p "$fallback_v4l/video0" "$tmp_dir/udev-empty"
echo 81:0 >"$fallback_v4l/video0/dev"
export OMARCHY_V4L_CLASS_PATH="$fallback_v4l"
export OMARCHY_UDEV_DATA_PATH="$tmp_dir/udev-empty"

if "$ROOT/bin/omarchy-hw-webcam"; then
  pass "webcam hardware detection succeeds when a capture device is available"
else
  fail "webcam hardware detection succeeds when a capture device is available"
fi

if OMARCHY_TEST_RAW_WEBCAM=true "$ROOT/bin/omarchy-hw-webcam"; then
  fail "webcam hardware detection rejects output-only video devices"
else
  pass "webcam hardware detection rejects output-only video devices"
fi

if OMARCHY_TEST_NO_WEBCAM=true "$ROOT/bin/omarchy-hw-webcam"; then
  fail "webcam hardware detection fails when no video device is available"
else
  pass "webcam hardware detection fails when no video device is available"
fi

# With udev's record available the guard answers from it and opens no device.
udev_v4l="$tmp_dir/v4l-udev"
udev_data="$tmp_dir/udev-data"
udev_dev="$tmp_dir/dev"
mkdir -p "$udev_v4l/video0/device" "$udev_v4l/video1/device" "$udev_data" "$udev_dev"
touch "$udev_dev/video0" "$udev_dev/video1"
export OMARCHY_DEV_PATH="$udev_dev"
echo 81:0 >"$udev_v4l/video0/dev"
echo 81:1 >"$udev_v4l/video1/dev"
printf '%s\n' 'E:ID_V4L_VERSION=2' 'E:ID_V4L_CAPABILITIES=:' >"$udev_data/c81:0"
printf '%s\n' 'E:ID_V4L_CAPABILITIES=:capture:' >"$udev_data/c81:1"
v4l2_log="$tmp_dir/v4l2-log"

OMARCHY_TEST_V4L2_LOG="$v4l2_log" OMARCHY_V4L_CLASS_PATH="$udev_v4l" OMARCHY_UDEV_DATA_PATH="$udev_data" \
  "$ROOT/bin/omarchy-hw-webcam" ||
  fail "webcam hardware detection reads a capture node from udev"
[[ ! -s $v4l2_log ]] ||
  fail "webcam hardware detection opens no video device when udev answers" "$(cat "$v4l2_log")"
pass "webcam hardware detection reads udev's record without opening a device"

# A node udev has no record for, sorted before a recorded capture node, must not
# send the guard to the devices: the recorded answer is enough.
mixed_v4l="$tmp_dir/v4l-mixed"
mixed_data="$tmp_dir/udev-mixed"
mkdir -p "$mixed_v4l/video0/device" "$mixed_v4l/video1/device" "$mixed_data"
echo 81:0 >"$mixed_v4l/video0/dev"
echo 81:1 >"$mixed_v4l/video1/dev"
printf '%s\n' 'E:ID_V4L_CAPABILITIES=:capture:' >"$mixed_data/c81:1"
OMARCHY_TEST_V4L2_LOG="$v4l2_log" OMARCHY_V4L_CLASS_PATH="$mixed_v4l" OMARCHY_UDEV_DATA_PATH="$mixed_data" \
  "$ROOT/bin/omarchy-hw-webcam" ||
  fail "webcam hardware detection finds a recorded capture node after an unrecorded one"
[[ ! -s $v4l2_log ]] ||
  fail "webcam hardware detection opens no device when a later node's record answers" "$(cat "$v4l2_log")"
pass "webcam hardware detection answers from a later node's record before asking any device"

# A recorded capture node this user cannot open is not one the picker would list.
rm "$udev_dev/video1"
if OMARCHY_TEST_RAW_WEBCAM=true OMARCHY_TEST_V4L2_LOG="$v4l2_log" OMARCHY_V4L_CLASS_PATH="$udev_v4l" OMARCHY_UDEV_DATA_PATH="$udev_data" \
  "$ROOT/bin/omarchy-hw-webcam"; then
  fail "webcam hardware detection rejects a recorded capture node the user cannot open"
fi
[[ -s $v4l2_log ]] ||
  fail "webcam hardware detection asks the devices when the recorded capture node cannot be opened"
pass "webcam hardware detection rejects a recorded capture node the user cannot open"
: >"$v4l2_log"
touch "$udev_dev/video1"

# v4l2loopback with exclusive_caps=1 switches between output and capture with its
# producer, after udev recorded either, so neither record is taken as the answer.
printf '%s\n' 'E:ID_V4L_CAPABILITIES=:video_output:' >"$udev_data/c81:1"
OMARCHY_TEST_V4L2_LOG="$v4l2_log" OMARCHY_V4L_CLASS_PATH="$udev_v4l" OMARCHY_UDEV_DATA_PATH="$udev_data" \
  "$ROOT/bin/omarchy-hw-webcam" ||
  fail "webcam hardware detection asks a node udev recorded as output-only, which can capture by now"
[[ -s $v4l2_log ]] ||
  fail "webcam hardware detection asks the devices when udev records no capture node"
pass "webcam hardware detection asks a node udev recorded as output-only, which can capture by now"
: >"$v4l2_log"

if OMARCHY_TEST_RAW_WEBCAM=true OMARCHY_TEST_V4L2_LOG="$v4l2_log" OMARCHY_V4L_CLASS_PATH="$udev_v4l" OMARCHY_UDEV_DATA_PATH="$udev_data" \
  "$ROOT/bin/omarchy-hw-webcam"; then
  fail "webcam hardware detection rejects nodes that are output-only both in udev and live"
fi
pass "webcam hardware detection rejects nodes that are output-only both in udev and live"
: >"$v4l2_log"

virtual_v4l="$tmp_dir/v4l-virtual"
mkdir -p "$virtual_v4l/video0"
echo 81:1 >"$virtual_v4l/video0/dev"
printf '%s\n' 'E:ID_V4L_CAPABILITIES=:capture:' >"$udev_data/c81:1"
if OMARCHY_TEST_RAW_WEBCAM=true OMARCHY_TEST_V4L2_LOG="$v4l2_log" OMARCHY_V4L_CLASS_PATH="$virtual_v4l" OMARCHY_UDEV_DATA_PATH="$udev_data" \
  "$ROOT/bin/omarchy-hw-webcam"; then
  fail "webcam hardware detection asks a virtual camera udev recorded as capture, which may have stopped"
fi
[[ -s $v4l2_log ]] ||
  fail "webcam hardware detection asks the devices for a node with no parent device"
pass "webcam hardware detection asks a virtual camera udev recorded as capture, which may have stopped"
: >"$v4l2_log"

if OMARCHY_TEST_V4L2_LOG="$v4l2_log" OMARCHY_V4L_CLASS_PATH="$tmp_dir/no-v4l" "$ROOT/bin/omarchy-hw-webcam"; then
  fail "webcam hardware detection fails without any video node"
fi
[[ ! -s $v4l2_log ]] ||
  fail "webcam hardware detection runs nothing without any video node" "$(cat "$v4l2_log")"
pass "webcam hardware detection fails without any video node"

if OMARCHY_TEST_RAW_WEBCAM=true "$ROOT/bin/omarchy-capture-screenrecording-with-webcam"; then
  fail "screenrecording webcam picker rejects output-only video devices"
fi
grep -Fx 'No webcam devices found' "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null || \
  fail "screenrecording webcam picker reports no capture-capable device"
pass "screenrecording webcam picker rejects output-only video devices"

"$ROOT/bin/omarchy-capture-screenrecording-with-webcam"

expected_menu_args="$tmp_dir/expected-menu-args"
printf '%s\n' \
  "Select Webcam" \
  "/dev/video42  Built-in Webcam: Integrated Camera" \
  "/dev/video2  USB Capture Card: External Camera" \
  "--" \
  "--width" \
  "520" \
  "--maxheight" \
  "520" >"$expected_menu_args"

if ! cmp -s "$OMARCHY_TEST_MENU_ARGS" "$expected_menu_args"; then
  fail "screenrecording webcam picker passes each webcam as a menu option" "$(diff -u "$expected_menu_args" "$OMARCHY_TEST_MENU_ARGS")"
fi
pass "screenrecording webcam picker passes each webcam as a menu option"

expected_recorder_args="$tmp_dir/expected-recorder-args"
printf '%s\n' \
  "--with-desktop-audio" \
  "--with-microphone-audio" \
  "--with-webcam" \
  "--webcam-device=/dev/video2" >"$expected_recorder_args"

if ! cmp -s "$OMARCHY_TEST_RECORDER_ARGS" "$expected_recorder_args"; then
  fail "screenrecording webcam picker starts recording with selected device" "$(diff -u "$expected_recorder_args" "$OMARCHY_TEST_RECORDER_ARGS")"
fi
pass "screenrecording webcam picker starts recording with selected device"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

case $1 in
clients)
  printf '[{"address":"0xabc","title":"%s","size":[%s,%s],"monitor":2}]\n' \
    "${OMARCHY_TEST_CLIENT_TITLE:-WebcamOverlay}" \
    "${OMARCHY_TEST_CLIENT_WIDTH:-178}" \
    "${OMARCHY_TEST_CLIENT_HEIGHT:-200}"
  ;;
monitors)
  printf '[{"id":2,"x":1280,"y":-100,"width":%s,"height":%s,"scale":%s}]\n' \
    "${OMARCHY_TEST_MONITOR_WIDTH:-2560}" \
    "${OMARCHY_TEST_MONITOR_HEIGHT:-1600}" \
    "${OMARCHY_TEST_MONITOR_SCALE:-2}"
  ;;
dispatch)
  printf '%s\n' "$*" >>"$OMARCHY_TEST_HYPRCTL_ARGS"
  ;;
esac
SH
chmod +x "$stub_bin/hyprctl"

export OMARCHY_TEST_HYPRCTL_ARGS="$tmp_dir/hyprctl-args"

"$ROOT/bin/omarchy-capture-webcam-resize" smaller

expected_hyprctl_args="$tmp_dir/expected-hyprctl-args"
printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 128, y = 144 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 2392, y = 516 })' >"$expected_hyprctl_args"

if ! cmp -s "$OMARCHY_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "webcam resize preserves its aspect ratio and corner anchor" "$(diff -u "$expected_hyprctl_args" "$OMARCHY_TEST_HYPRCTL_ARGS")"
fi
pass "webcam resize preserves its aspect ratio and corner anchor"

: >"$OMARCHY_TEST_HYPRCTL_ARGS"
OMARCHY_TEST_MONITOR_WIDTH=1920 \
  OMARCHY_TEST_MONITOR_HEIGHT=1080 \
  OMARCHY_TEST_MONITOR_SCALE=1 \
  OMARCHY_TEST_CLIENT_WIDTH=128 \
  OMARCHY_TEST_CLIENT_HEIGHT=144 \
  "$ROOT/bin/omarchy-capture-webcam-resize" reset

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 240, y = 270 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 2920, y = 670 })' >"$expected_hyprctl_args"

if ! cmp -s "$OMARCHY_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "webcam default size adapts to monitor resolution" "$(diff -u "$expected_hyprctl_args" "$OMARCHY_TEST_HYPRCTL_ARGS")"
fi
pass "webcam default size adapts to monitor resolution"

: >"$OMARCHY_TEST_HYPRCTL_ARGS"
OMARCHY_TEST_CLIENT_TITLE="Other Window" "$ROOT/bin/omarchy-capture-webcam-resize" larger

if [[ -s $OMARCHY_TEST_HYPRCTL_ARGS ]]; then
  fail "webcam resize ignores other windows" "$(cat "$OMARCHY_TEST_HYPRCTL_ARGS")"
fi
pass "webcam resize ignores other windows"

region_file="$XDG_RUNTIME_DIR/omarchy-screenrecord-region"

: >"$OMARCHY_TEST_HYPRCTL_ARGS"
echo "800x600+100+100" >"$region_file"
"$ROOT/bin/omarchy-capture-webcam-resize" reset

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 133, y = 150 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 727, y = 510 })' >"$expected_hyprctl_args"

if ! cmp -s "$OMARCHY_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "webcam anchors to the recorded region" "$(diff -u "$expected_hyprctl_args" "$OMARCHY_TEST_HYPRCTL_ARGS")"
fi
pass "webcam anchors to the recorded region"

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 178, y = 200 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 2342, y = 460 })' >"$expected_hyprctl_args"

for region in "not-a-region" ""; do
  : >"$OMARCHY_TEST_HYPRCTL_ARGS"
  printf '%s' "$region" >"$region_file"
  "$ROOT/bin/omarchy-capture-webcam-resize" reset

  if ! cmp -s "$OMARCHY_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
    fail "webcam falls back to the monitor for an unusable region" "$(diff -u "$expected_hyprctl_args" "$OMARCHY_TEST_HYPRCTL_ARGS")"
  fi
done
pass "webcam falls back to the monitor for an unusable region"

# A region too narrow for presets scaled from its height shrinks the whole
# ladder, so the three sizes stay distinct and each one fits inside the margins
: >"$OMARCHY_TEST_HYPRCTL_ARGS"
echo "200x1200+0+0" >"$region_file"
for size in small medium large; do
  "$ROOT/bin/omarchy-capture-webcam-resize" "$size"
done

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 64, y = 72 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 96, y = 1088 })' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 89, y = 100 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 71, y = 1060 })' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 120, y = 135 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 40, y = 1025 })' >"$expected_hyprctl_args"

if ! cmp -s "$OMARCHY_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "webcam sizes stay distinct and inside a narrow region" "$(diff -u "$expected_hyprctl_args" "$OMARCHY_TEST_HYPRCTL_ARGS")"
fi
pass "webcam sizes stay distinct and inside a narrow region"

rm -f "$region_file"

# The stop path reads the recording state file back and uses its contents as a
# path -- ffmpeg writes beside it, `mv` replaces it, `rm -f` deletes its
# preview -- so it has to live in the per-user runtime directory rather than
# under a name in world-writable /tmp that another account can create first.
recording_dir="$tmp_dir/recordings"
mkdir -p "$recording_dir"

# Nothing is recording yet, whatever else runs on the machine.
cat >"$stub_bin/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$stub_bin/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
printf 'DP-1\n'
SH

cat >"$stub_bin/gpu-screen-recorder" <<'SH'
#!/bin/bash
echo "$$" >>"$OMARCHY_TEST_PID_LOG"
for i in "$@"; do
  [[ -n ${take_next:-} ]] && { : >"$i"; break; }
  [[ $i == "-o" ]] && take_next=1
done
exec sleep 30
SH

cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$stub_bin"/omarchy-capture-screenrecording-process "$stub_bin"/omarchy-hyprland-monitor-focused \
  "$stub_bin"/gpu-screen-recorder "$stub_bin"/omarchy-shell

# Compare that name across the run rather than demanding it be absent: the
# whole point of the finding is that anyone can own it already, and a leftover
# from a pre-fix recording would red-light the fixed script.
tmp_state="/tmp/omarchy-screenrecord-filename"
tmp_state_before=$(stat -c '%y %s' "$tmp_state" 2>/dev/null || true)

OMARCHY_SCREENRECORD_DIR="$recording_dir" \
  "$ROOT/bin/omarchy-capture-screenrecording" --fullscreen >/dev/null 2>&1

stop_fixture_recorders

[[ $(stat -c '%y %s' "$tmp_state" 2>/dev/null) == "$tmp_state_before" ]] ||
  fail "screen recording keeps no state under a fixed /tmp name"
pass "screen recording keeps no state under a fixed /tmp name"

[[ -s $XDG_RUNTIME_DIR/omarchy-screenrecord-filename ]] ||
  fail "the recording state file lives in the per-user runtime directory" \
    "$(ls -a "$XDG_RUNTIME_DIR")"
pass "the recording state file lives in the per-user runtime directory"

[[ $(<"$XDG_RUNTIME_DIR/omarchy-screenrecord-filename") == "$recording_dir"/* ]] ||
  fail "the recording state file names the recording that was started" \
    "$(<"$XDG_RUNTIME_DIR/omarchy-screenrecord-filename")"
pass "the recording state file names the recording that was started"

# The :-/tmp fallback would reopen the hole this PR closes. A recording
# started without a session runtime dir has to land under the state directory.
state_home="$tmp_dir/state-home"
mkdir -p "$state_home/omarchy" "$tmp_dir/home-fallback"
chmod 755 "$state_home/omarchy"
tmp_state_before=$(stat -c '%y %s' "$tmp_state" 2>/dev/null || true)

env -u XDG_RUNTIME_DIR \
  HOME="$tmp_dir/home-fallback" \
  XDG_STATE_HOME="$state_home" \
  OMARCHY_SCREENRECORD_DIR="$recording_dir" \
  "$ROOT/bin/omarchy-capture-screenrecording" --fullscreen >/dev/null 2>&1

stop_fixture_recorders

[[ $(stat -c '%y %s' "$tmp_state" 2>/dev/null) == "$tmp_state_before" ]] ||
  fail "without a runtime dir, screen recording still keeps no state under a fixed /tmp name"
pass "without a runtime dir, screen recording still keeps no state under a fixed /tmp name"

fallback_file="$state_home/omarchy/omarchy-screenrecord-filename"
[[ -s $fallback_file ]] ||
  fail "without a runtime dir the recording state file lives in the state directory" \
    "$(ls -la "$state_home/omarchy" 2>/dev/null || true)"
pass "without a runtime dir the recording state file lives in the state directory"

[[ $(<"$fallback_file") == "$recording_dir"/* ]] ||
  fail "the fallback state file names the recording that was started" \
    "$(<"$fallback_file")"
pass "the fallback state file names the recording that was started"

# The overlay resizer reads the region file the recorder writes, so the two
# have to resolve the same fallback as well as the same runtime dir.
: >"$OMARCHY_TEST_HYPRCTL_ARGS"
echo "800x600+100+100" >"$state_home/omarchy/omarchy-screenrecord-region"
env -u XDG_RUNTIME_DIR \
  HOME="$tmp_dir/home-fallback" \
  XDG_STATE_HOME="$state_home" \
  "$ROOT/bin/omarchy-capture-webcam-resize" reset

printf '%s\n' \
  'dispatch hl.dsp.window.resize({ window = "address:0xabc", x = 133, y = 150 })' \
  'dispatch hl.dsp.window.move({ window = "address:0xabc", x = 727, y = 510 })' >"$expected_hyprctl_args"

if ! cmp -s "$OMARCHY_TEST_HYPRCTL_ARGS" "$expected_hyprctl_args"; then
  fail "without a runtime dir the webcam anchors to the recorded region" "$(diff -u "$expected_hyprctl_args" "$OMARCHY_TEST_HYPRCTL_ARGS")"
fi
pass "without a runtime dir the webcam anchors to the recorded region"

mode=$(stat -c '%a' "$state_home/omarchy" 2>/dev/null || stat -f '%Lp' "$state_home/omarchy")
[[ $mode == "700" ]] || fail "fallback directory is private even when it already existed" "mode: $mode"
pass "fallback directory is private even when it already existed"

# gpu-screen-recorder aborts before recording on a GPU it does not know, such
# as Apple Silicon's. wf-recorder takes over when it is installed, on the same
# monitor, and its pid is the one stop and status act on.
cat >"$stub_bin/gpu-screen-recorder" <<'SH'
#!/bin/bash
echo "gsr error: unknown gpu vendor" >&2
exit 1
SH

cat >"$stub_bin/wf-recorder" <<'SH'
#!/bin/bash
echo "$$" >>"$OMARCHY_TEST_PID_LOG"
printf '%s\n' "$@" >"$OMARCHY_TEST_WF_ARGS"
echo "$$" >"$OMARCHY_TEST_WF_PID"
for i in "$@"; do
  [[ -n ${take_next:-} ]] && { : >"$i"; break; }
  [[ $i == "-f" ]] && take_next=1
done
exec sleep 30
SH
chmod +x "$stub_bin/gpu-screen-recorder" "$stub_bin/wf-recorder"

# Fresh directories: a recording named for the same second must not exist yet.
wf_runtime="$tmp_dir/wf-runtime"
wf_recordings="$tmp_dir/wf-recordings"
mkdir -p "$wf_runtime" "$wf_recordings"
wf_args="$tmp_dir/wf-args"
wf_pid="$tmp_dir/wf-pid"
XDG_RUNTIME_DIR="$wf_runtime" OMARCHY_TEST_WF_ARGS="$wf_args" OMARCHY_TEST_WF_PID="$wf_pid" \
  OMARCHY_SCREENRECORD_DIR="$wf_recordings" \
  "$ROOT/bin/omarchy-capture-screenrecording" --fullscreen >/dev/null 2>&1

stop_fixture_recorders

[[ -s $wf_args ]] || fail "wf-recorder records when gpu-screen-recorder cannot start"
grep -Fxq -- '-o' "$wf_args" && grep -Fxq DP-1 "$wf_args" && grep -Fxq 48000 "$wf_args" ||
  fail "wf-recorder records the focused monitor at 48 kHz" "$(<"$wf_args")"
[[ $(<"$wf_runtime/omarchy-screenrecord-pid") == "$(<"$wf_pid")" ]] ||
  fail "the recorder pid is the wf-recorder that is recording" "$(ls -a "$wf_runtime")"
[[ $(<"$wf_runtime/omarchy-screenrecord-filename") == "$wf_recordings"/* ]] ||
  fail "the wf-recorder recording is the one recorded as started"
pass "wf-recorder records when gpu-screen-recorder cannot start"

# Without wf-recorder, a recorder that cannot start leaves nothing behind.
rm "$stub_bin/wf-recorder"
none_runtime="$tmp_dir/none-runtime"
none_recordings="$tmp_dir/none-recordings"
mkdir -p "$none_runtime" "$none_recordings"
echo 424242 >"$none_runtime/omarchy-screenrecord-pid"
XDG_RUNTIME_DIR="$none_runtime" OMARCHY_SCREENRECORD_DIR="$none_recordings" \
  "$ROOT/bin/omarchy-capture-screenrecording" --fullscreen >/dev/null 2>&1 || true
[[ ! -e $none_runtime/omarchy-screenrecord-pid && ! -e $none_runtime/omarchy-screenrecord-filename ]] ||
  fail "a recorder that cannot start records no state, and clears a stale pid" "$(ls -a "$none_runtime")"
pass "a recorder that cannot start records no state, and clears a stale pid"

# Another recorder runs in both cases below: the helper answers for any
# selection but a pid, and a stop by name ends it.
helper_calls="$tmp_dir/helper-calls"
recording_flag="$tmp_dir/recording"
cat >"$stub_bin/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_HELPER_CALLS"
if [[ $1 == "--pid" ]]; then
  [[ $2 == "${OMARCHY_TEST_LIVE_PID:-}" ]]
  exit
fi
if [[ $* == *"--signal INT" ]]; then
  rm -f "$OMARCHY_TEST_RECORDING"
  exit 0
fi
[[ -e $OMARCHY_TEST_RECORDING ]]
SH
chmod +x "$stub_bin/omarchy-capture-screenrecording-process"

# A saved pid that is no longer a recorder is a recording that ended without a
# stop: nothing of ours records, so stop has nothing to do and signals no other
# recorder the user runs.
stale_runtime="$tmp_dir/stale-runtime"
mkdir -p "$stale_runtime"
echo 424242 >"$stale_runtime/omarchy-screenrecord-pid"
touch "$recording_flag"
: >"$helper_calls"
if XDG_RUNTIME_DIR="$stale_runtime" OMARCHY_TEST_HELPER_CALLS="$helper_calls" OMARCHY_TEST_RECORDING="$recording_flag" \
  OMARCHY_SCREENRECORD_DIR="$recording_dir" \
  "$ROOT/bin/omarchy-capture-screenrecording" --stop-recording >/dev/null 2>&1; then
  fail "stop finds no recording of ours behind a stale pid" "$(<"$helper_calls")"
fi
! grep -q -- '--signal' "$helper_calls" ||
  fail "stop signals nothing when the saved pid is stale" "$(<"$helper_calls")"
[[ -e $recording_flag ]] || fail "the other recorder keeps recording"
pass "a stale saved pid leaves every other recorder alone"

# Without a saved pid (a recording started before the pid was saved), status
# and stop select every recorder the user runs, as the bar and the menu do.
legacy_runtime="$tmp_dir/legacy-runtime"
mkdir -p "$legacy_runtime"
touch "$recording_flag"
: >"$helper_calls"
rm -f "$OMARCHY_TEST_NOTIFICATION_ARGS"
XDG_RUNTIME_DIR="$legacy_runtime" OMARCHY_TEST_HELPER_CALLS="$helper_calls" OMARCHY_TEST_RECORDING="$recording_flag" \
  OMARCHY_SCREENRECORD_DIR="$recording_dir" \
  "$ROOT/bin/omarchy-capture-screenrecording" --stop-recording >/dev/null 2>&1 ||
  fail "stop finds a recording started before the pid was saved" "$(<"$helper_calls")"
grep -Fxq -- '--signal INT' "$helper_calls" ||
  fail "stop signals the user's recorders when no pid was saved" "$(<"$helper_calls")"
! grep -Fq -- '--signal KILL' "$helper_calls" ||
  fail "a recorder that stops on INT is not killed" "$(<"$helper_calls")"
[[ ! -e $OMARCHY_TEST_NOTIFICATION_ARGS ]] ||
  fail "stop announces no saved recording when none was recorded as started" "$(<"$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "without a saved pid, status and stop select the user's recorders"

# The bar indicator and the menu's Stop row ask --status, so they show a stop
# exactly when the toggle has a recording of ours to end. It needs no
# recordings directory, never notifies and never signals.
status() {
  XDG_RUNTIME_DIR="$1" OMARCHY_TEST_HELPER_CALLS="$helper_calls" OMARCHY_TEST_RECORDING="$recording_flag" \
    OMARCHY_TEST_LIVE_PID="${2:-}" OMARCHY_SCREENRECORD_DIR="$tmp_dir/no-such-recordings" \
    "$ROOT/bin/omarchy-capture-screenrecording" --status >/dev/null 2>&1
}
touch "$recording_flag"
: >"$helper_calls"
rm -f "$OMARCHY_TEST_NOTIFICATION_ARGS"
echo 424242 >"$stale_runtime/omarchy-screenrecord-pid"
if status "$stale_runtime"; then fail "--status reports nothing of ours behind a stale pid"; fi
status "$legacy_runtime" || fail "--status reports a recording started before the pid was saved"
status "$stale_runtime" 424242 || fail "--status reports the recorder its saved pid names"
rm -f "$recording_flag"
if status "$legacy_runtime"; then fail "--status reports nothing when no recorder runs"; fi
! grep -q -- '--signal' "$helper_calls" || fail "--status signals nothing" "$(<"$helper_calls")"
[[ ! -e $OMARCHY_TEST_NOTIFICATION_ARGS ]] || fail "--status never notifies, even without a recordings directory" "$(<"$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "--status answers what stop would act on, without a recordings directory, notifications or signals"

# A recording that ended without a stop leaves its audio loopbacks and sink
# loaded. Status and stop unload them, newest first, once the saved recorder is
# gone; while it records, or before it saves its pid, the mix stays.
cat >"$stub_bin/pactl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_AUDIO_CALLS"
SH
chmod +x "$stub_bin/pactl"

audio_runtime="$tmp_dir/audio-runtime"
audio_calls="$tmp_dir/audio-calls"
audio_modules="$audio_runtime/omarchy-screenrecord-pa-modules"
mkdir -p "$audio_runtime"
echo 123 >"$audio_runtime/omarchy-screenrecord-pid"
rm -f "$recording_flag"

recorder() {
  XDG_RUNTIME_DIR="$audio_runtime" OMARCHY_TEST_HELPER_CALLS="$helper_calls" OMARCHY_TEST_RECORDING="$recording_flag" \
    OMARCHY_TEST_LIVE_PID="${2:-}" OMARCHY_TEST_AUDIO_CALLS="$audio_calls" OMARCHY_SCREENRECORD_DIR="$recording_dir" \
    "$ROOT/bin/omarchy-capture-screenrecording" "$1" >/dev/null 2>&1
}

for action in --status --stop-recording; do
  printf '10\n11\n12\n' >"$audio_modules"
  : >"$helper_calls"
  : >"$audio_calls"
  status=0
  recorder "$action" || status=$?
  (( status == 1 )) || fail "$action reports no recorder after it exits" "$status"
  [[ $(<"$audio_calls") == $'unload-module 12\nunload-module 11\nunload-module 10' ]] ||
    fail "$action releases the exited recorder's audio loopbacks before its sink" "$(<"$audio_calls")"
  [[ ! -e $audio_modules ]] || fail "$action removes the stale audio module list"
  ! grep -q -- '--signal' "$helper_calls" || fail "$action signals no other recorder"
  pass "$action releases audio capture after the saved recorder exits"
done

printf '10\n11\n12\n' >"$audio_modules"
: >"$audio_calls"
recorder --status 123 || fail "status recognizes the active recorder"
[[ ! -s $audio_calls && -e $audio_modules ]] || fail "status leaves an active recording's audio modules loaded"
pass "status preserves the active recorder's audio capture"

rm "$audio_runtime/omarchy-screenrecord-pid"
: >"$audio_calls"
status=0
recorder --status || status=$?
(( status == 1 )) || fail "status reports inactive before the recorder starts"
[[ ! -s $audio_calls && -e $audio_modules ]] || fail "status preserves the audio mix created before the recorder starts"
pass "status leaves the starting recorder's audio mix alone"

# VAAPI startup diagnostics use the same command, notification, and owned
# recorder fixtures as the backend tests above. Sysfs and drivers are scratch.
pci="$tmp_dir/pci"
dri="$tmp_dir/dri"
runtime="$tmp_dir/vaapi-runtime"
recordings="$tmp_dir/vaapi-recordings"
notice="$tmp_dir/vaapi-notice"
export XDG_RUNTIME_DIR="$runtime" OMARCHY_PCI_DEVICES_PATH="$pci"
export OMARCHY_DRI_DRIVERS_PATH="$dri" OMARCHY_SCREENRECORD_DIR="$recordings"
export OMARCHY_TEST_NOTIFICATION_ARGS="$notice"
cat >"$stub_bin/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$stub_bin/gpu-screen-recorder" <<'SH'
#!/bin/bash
echo "$$" >>"$OMARCHY_TEST_PID_LOG"
exec python3 - "$@" <<'PYTHON'
import os, pathlib, signal, sys, time
mode = os.environ.get("OMARCHY_TEST_GSR_MODE", "ok")
runtime = pathlib.Path(os.environ["XDG_RUNTIME_DIR"])
filename = pathlib.Path(sys.argv[sys.argv.index("-o") + 1])
signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
if mode == "split":
    os.write(2, b"vaInit")
    time.sleep(0.3)
    os.write(2, b"ialize failed\n")
if mode not in ("ok", "late", "split"):
    os.write(2, b"gsr error: vaInitialize failed\n")
if mode == "exit":
    sys.exit(7)
if mode == "cancel":
    (runtime / "omarchy-screenrecord-cancel").touch()
elif mode == "flood":
    written = 0
    while not (runtime / "ready").exists():
        written += os.write(2, b"x" * 4096)
        if written >= 131072:
            (runtime / "noisy").touch()
        time.sleep(0.001)
    filename.touch()
elif mode != "stall":
    filename.touch()
if mode == "late":
    while not (runtime / "continue").exists():
        time.sleep(0.01)
    os.write(2, b"vaInitialize failed\n" + b"x" * 1048576)
    (runtime / "drained").touch()
while True:
    time.sleep(0.1)
PYTHON
SH
chmod +x "$stub_bin/omarchy-capture-screenrecording-process" "$stub_bin/gpu-screen-recorder"
add_gpu() {
  local slot=$1 vendor=$2 class=$3
  mkdir -p "$pci/$slot"
  printf '%s\n' "$vendor" >"$pci/$slot/vendor"
  printf '%s\n' "$class" >"$pci/$slot/class"
}

reset_case() {
  stop_fixture_recorders
  rm -rf "$pci" "$dri" "$runtime" "$recordings" "$notice"
  mkdir -p "$pci" "$dri" "$runtime" "$recordings"
}

record() {
  OMARCHY_TEST_GSR_MODE=$1 "$ROOT/bin/omarchy-capture-screenrecording" --fullscreen --resolution=0x0 >"$tmp_dir/recorder-output" 2>&1 || true
  [[ ! -e $runtime/omarchy-screenrecord-gsr.err ]] || fail "startup removes its temporary stderr file"
  [[ -z $(compgen -G "$runtime/omarchy-screenrecord-stderr.*") ]] || fail "startup removes its stderr FIFO"
}

started() {
  [[ -s $runtime/omarchy-screenrecord-pid && -s $runtime/omarchy-screenrecord-filename ]]
}

# Haswell-shaped iGPU (the name lspci gives it is not what this check reads)
# plus a NVIDIA 3D controller and a NVIDIA audio function that must not count.
reset_case
add_gpu 00 0x8086 0x030000
add_gpu 01 0x10de 0x030200
add_gpu 02 0x10de 0x040300
touch "$dri/nvidia_drv_video.so"
record fail
started || fail "a VAAPI init failure still starts the recording on the CPU fallback"
grep -F 'VAAPI failed to initialize' "$notice" >/dev/null || fail "VAAPI init failure is reported" "$(cat "$notice" 2>/dev/null || true)"
grep -F 'intel-media-driver' "$notice" >/dev/null || fail "a hybrid with no Intel driver names intel-media-driver" "$(cat "$notice")"
grep -F 'libva-intel-driver' "$notice" >/dev/null || fail "a hybrid with no Intel driver names libva-intel-driver" "$(cat "$notice")"
if grep -F 'libva-nvidia-driver' "$notice" >/dev/null; then
  fail "a hybrid does not ask for the NVIDIA driver that is already installed" "$(cat "$notice")"
fi
if grep -F 'libva-mesa-driver' "$notice" >/dev/null; then
  fail "a hybrid does not ask for an AMD driver" "$(cat "$notice")"
fi
pass "hybrid Intel+NVIDIA with no Intel VAAPI driver reports that driver and still starts"

reset_case
add_gpu 00 0x8086 0x030000
add_gpu 01 0x10de 0x030200
touch "$dri/nvidia_drv_video.so"
record ok
started || fail "a clean recorder start is recorded as started"
[[ ! -e $notice ]] || fail "a clean recorder start does not mention VAAPI" "$(cat "$notice")"
pass "a recorder that does not fail VAAPI init stays quiet even when the Intel driver is absent"

reset_case
add_gpu 00 0x8086 0x030000
add_gpu 01 0x10de 0x030200
touch "$dri/iHD_drv_video.so" "$dri/nvidia_drv_video.so"
record fail
started || fail "VAAPI init failure with drivers installed still starts"
grep -F 'even though a VAAPI driver' "$notice" >/dev/null || fail "an installed driver that will not initialize says so" "$(cat "$notice" 2>/dev/null || true)"
if grep -F 'intel-media-driver' "$notice" >/dev/null; then
  fail "an installed Intel driver is not listed as missing" "$(cat "$notice")"
fi
pass "VAAPI init failure with the detected drivers installed points at the debug log"

reset_case
add_gpu 00 0x8086 0x030000
add_gpu 01 0x10de 0x030200
touch "$dri/nvidia_drv_video.so"
record exit
if started; then
  fail "a recorder that exits before writing a file is not recorded as started"
fi
grep -F 'libva-intel-driver' "$notice" >/dev/null || fail "a recorder that exits on VAAPI init still names the missing Intel driver" "$(cat "$notice" 2>/dev/null || true)"
pass "a recorder that exits on VAAPI init still reports the missing Intel driver"

reset_case
add_gpu 00 0x1002 0x030000
add_gpu 01 0x1002 0x040300
record fail
grep -F 'libva-mesa-driver' "$notice" >/dev/null || fail "AMD with no Mesa VAAPI driver names libva-mesa-driver" "$(cat "$notice" 2>/dev/null || true)"
grep -F 'mesa-vdpau' "$notice" >/dev/null || fail "AMD with no Mesa VAAPI driver names mesa-vdpau" "$(cat "$notice")"
if grep -F 'intel-media-driver' "$notice" >/dev/null; then
  fail "an AMD machine is not told to install an Intel driver" "$(cat "$notice")"
fi
pass "AMD with no Mesa VAAPI driver reports that driver"

reset_case
add_gpu 00 0x10de 0x030000
record fail
grep -F 'libva-nvidia-driver' "$notice" >/dev/null || fail "NVIDIA with no VAAPI driver names libva-nvidia-driver" "$(cat "$notice" 2>/dev/null || true)"
if grep -F 'intel-media-driver' "$notice" >/dev/null; then
  fail "a NVIDIA machine is not told to install an Intel driver" "$(cat "$notice")"
fi
pass "NVIDIA with no VAAPI driver reports libva-nvidia-driver"

reset_case
add_gpu 00 0x8086 0x0c0330
record fail
grep -F 'Install the driver for your GPU' "$notice" >/dev/null || fail "no display GPU falls back to the generic driver hint" "$(cat "$notice" 2>/dev/null || true)"
if grep -F 'until the missing driver is installed' "$notice" >/dev/null; then
  fail "a non-display Intel device is not treated as an iGPU" "$(cat "$notice")"
fi
pass "a machine with no display GPU gets the generic VAAPI hint"

reset_case
add_gpu 00 0x8086 0x030000
add_gpu 01 0x10de 0x030200
touch "$dri/nvidia_drv_video.so"
printf '%s\n' 'old gsr error: vaInitialize failed' >"$runtime/omarchy-screenrecord.log"
OMARCHY_SCREENRECORD_DEBUG=true record ok
[[ ! -e $notice ]] || fail "an older debug log line does not report the next recording" "$(cat "$notice")"
pass "an older vaInitialize line in the debug log does not report the next recording"

reset_case
add_gpu 00 0x8086 0x030000
add_gpu 01 0x10de 0x030200
touch "$dri/nvidia_drv_video.so"
OMARCHY_SCREENRECORD_DEBUG=true record fail
grep -F 'vaInitialize failed' "$runtime/omarchy-screenrecord.log" >/dev/null ||
  fail "debug mode still keeps the recorder stderr" "$(cat "$runtime/omarchy-screenrecord.log" 2>/dev/null || true)"
grep -F 'libva-intel-driver' "$notice" >/dev/null || fail "debug mode still reports the missing Intel driver" "$(cat "$notice" 2>/dev/null || true)"
pass "debug mode keeps the recorder stderr and still reports the missing driver"

reset_case
add_gpu 00 0x8086 0x030000
add_gpu 01 0x10de 0x030200
touch "$dri/nvidia_drv_video.so"
record cancel
[[ ! -e $notice ]] || fail "a cancelled start does not report VAAPI" "$(cat "$notice")"
if started; then
  fail "a cancelled start is not recorded as started"
fi
pass "a cancelled start stays quiet about VAAPI"

# A stalled/portal start may be arbitrarily noisy. Its diagnostics must stay
# bounded before readiness, then disappear without closing stderr on the GPU.
wait_for_file() {
  for _ in {1..250}; do
    [[ ! -e $1 ]] || return 0
    sleep 0.02
  done
  fail "fixture writes $1" "$(cat "$tmp_dir/recorder-output")"
}
reset_case
OMARCHY_TEST_GSR_MODE=flood "$ROOT/bin/omarchy-capture-screenrecording" --fullscreen --resolution=0x0 >"$tmp_dir/recorder-output" 2>&1 &
starter=$!
wait_for_file "$runtime/noisy"
bytes=0
[[ ! -f $runtime/omarchy-screenrecord-gsr.err ]] || bytes=$(stat -c %s "$runtime/omarchy-screenrecord-gsr.err")
(( bytes <= 65536 )) || fail "noisy startup diagnostics use bounded storage" "$bytes bytes"
touch "$runtime/ready"
wait "$starter"
started || fail "noisy startup reaches readiness"
[[ ! -e $runtime/omarchy-screenrecord-gsr.err ]] || fail "ready startup removes its diagnostics"
[[ -z $(compgen -G "$runtime/omarchy-screenrecord-stderr.*") ]] || fail "ready startup removes its FIFO"
pass "noisy startup uses bounded storage and cleans it at readiness"

reset_case
record late
pid=$(<"$runtime/omarchy-screenrecord-pid")
[[ $pid == "$(tail -n 1 "$OMARCHY_TEST_PID_LOG")" ]] || fail "saved pid is the recorder, not its stderr drainer"
touch "$runtime/continue"
wait_for_file "$runtime/drained"
kill -0 "$pid" || fail "detached recorder survives later stderr without SIGPIPE"
[[ ! -e $notice && ! -e $runtime/omarchy-screenrecord-gsr.err ]] || fail "later stderr is discarded without a warning or log"
pass "detached recorder keeps its own pid and later stderr is drained without SIGPIPE"

# Run the actual startup body with a synthetic clock, not a native locale.
# Unsetting EPOCHREALTIME makes it assignable in this disposable Bash process.
sed '/^mkdir -p "\$RUNTIME_DIR" || exit 1$/,$d' "$ROOT/bin/omarchy-capture-screenrecording" >"$tmp_dir/clock-recorder"
cat >>"$tmp_dir/clock-recorder" <<'SH'
unset EPOCHREALTIME
EPOCHREALTIME="1794080000${OMARCHY_TEST_CLOCK_SEPARATOR}900000"
clock_checks=0
start_cancelled() {
  if [[ -v started_at && $recorder_ended == "false" ]]; then
    clock_checks=$((clock_checks + 1))
    if (( clock_checks == 1 )); then
      EPOCHREALTIME="1794080001${OMARCHY_TEST_CLOCK_SEPARATOR}100000"
    else
      EPOCHREALTIME="1794080020${OMARCHY_TEST_CLOCK_SEPARATOR}100000"
    fi
    # Safely end a broken timeout rather than leaving its recorder running.
    (( clock_checks <= 2 )) || touch "$CANCEL_FILE"
  fi
  [[ -e $CANCEL_FILE ]]
}
start_screenrecording
# Both conversions must agree: wait at 0.2 seconds, time out at 19.2 seconds.
(( clock_checks == 2 )) && [[ ! -e $CANCEL_FILE ]]
SH
for separator in '.' ',' '٫'; do
  for mode in stall flood; do
    reset_case
    OMARCHY_TEST_CLOCK_SEPARATOR="$separator" OMARCHY_TEST_GSR_MODE="$mode" \
      bash "$tmp_dir/clock-recorder" --fullscreen --resolution=0x0 >"$tmp_dir/recorder-output" 2>&1 ||
      fail "startup times out across '$separator' clock separators with $mode stderr" "$(cat "$tmp_dir/recorder-output")"
    ! started || fail "a recorder that never becomes ready records no state"
    [[ ! -e $runtime/omarchy-screenrecord-gsr.err && -z $(compgen -G "$runtime/omarchy-screenrecord-stderr.*") ]] ||
      fail "timed-out startup removes its diagnostics"
    pass "startup waits within budget and times out across '$separator' clock separators with $mode stderr"
  done
done

reset_case
add_gpu 00 0x8086 0x030000
record split
grep -F 'intel-media-driver' "$notice" >/dev/null || fail "VAAPI marker survives short stderr chunks across read timeouts"
pass "VAAPI detection handles short chunks split across read timeouts"

# Stop must still select the actual backend PID. This helper only signals a
# process carrying this fixture's unique environment marker, never a session.
cat >"$stub_bin/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
[[ ${1:-} == "--pid" && $2 =~ ^[0-9]+$ ]] || exit 1
grep -qzxF "OMARCHY_TEST_SANDBOX=$OMARCHY_TEST_SANDBOX" "/proc/$2/environ" 2>/dev/null || exit 1
state=$(<"/proc/$2/stat")
[[ ${state##*) } != "Z "* ]] || exit 1
if [[ ${3:-} == "--signal" ]]; then
  printf '%s\n' "$*" >>"$OMARCHY_TEST_SANDBOX/stop-signals"
  kill "-$4" "$2"
fi
SH
reset_case
record late
pid=$(<"$runtime/omarchy-screenrecord-pid")
drain_pipe=$(readlink "/proc/$pid/fd/2")
"$ROOT/bin/omarchy-capture-screenrecording" --status || fail "status selects the actual detached recorder"
touch "$runtime/continue"
wait_for_file "$runtime/drained"
# A recording removed outside Omarchy needs no preview or finalization.
rm "$(<"$runtime/omarchy-screenrecord-filename")"
"$ROOT/bin/omarchy-capture-screenrecording" --stop-recording >"$tmp_dir/stop-output" 2>&1 || fail "stop signals the actual recorder"
grep -Fxq -- "--pid $pid --signal INT" "$tmp_dir/stop-signals" || fail "stop sends INT to the backend PID"
[[ ! -e $runtime/omarchy-screenrecord-pid && ! -e $runtime/omarchy-screenrecord-gsr.err ]] || fail "stop removes recorder state and retains no diagnostics"
for _ in {1..100}; do
  drainers=0
  for proc in /proc/[0-9]*; do
    grep -qzxF "OMARCHY_TEST_SANDBOX=$tmp_dir" "$proc/environ" 2>/dev/null || continue
    for fd in "$proc"/fd/*; do
      [[ $(readlink "$fd" 2>/dev/null) != "$drain_pipe" ]] || drainers=$((drainers + 1))
    done
  done
  (( drainers > 0 )) || break
  sleep 0.01
done
(( drainers == 0 )) || fail "stderr drainer exits at recorder EOF"
pass "status and stop own the backend PID, and its stderr drainer exits at EOF"

# A failed external discard reader must not close the pipe on a live recorder.
cat >"$stub_bin/cat" <<'SH'
#!/bin/bash
if [[ ${OMARCHY_TEST_DRAIN_FAIL:-false} == "true" ]] && (( $# == 0 )); then
  touch "$OMARCHY_TEST_SANDBOX/drainer-failed"
  exit 73
fi
exec /usr/bin/cat "$@"
SH
chmod +x "$stub_bin/cat"
reset_case
OMARCHY_TEST_DRAIN_FAIL=true record late
touch "$runtime/continue"
wait_for_file "$runtime/drained"
[[ -e $tmp_dir/drainer-failed ]] || fail "discard-reader failure was exercised"
kill -0 "$(<"$runtime/omarchy-screenrecord-pid")" || fail "builtin discard reader keeps recorder alive after cat fails"
pass "discard-reader failure falls back without giving the recorder SIGPIPE"
