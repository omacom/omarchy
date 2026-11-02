#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

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

export PATH="$stub_bin:$ROOT/bin:$PATH"
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
for i in "$@"; do
  [[ -n ${take_next:-} ]] && { : >"$i"; break; }
  [[ $i == "-o" ]] && take_next=1
done
sleep 5
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

pkill -f "$stub_bin/gpu-screen-recorder" 2>/dev/null || true

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

pkill -f "$stub_bin/gpu-screen-recorder" 2>/dev/null || true

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
printf '%s\n' "$@" >"$OMARCHY_TEST_WF_ARGS"
echo "$$" >"$OMARCHY_TEST_WF_PID"
for i in "$@"; do
  [[ -n ${take_next:-} ]] && { : >"$i"; break; }
  [[ $i == "-f" ]] && take_next=1
done
sleep 5
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

pkill -f "$stub_bin/wf-recorder" 2>/dev/null || true

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

# The bar indicator only stays honest if the refresh happens after the recorder
# is actually gone -- refreshing while it is still alive (the force-kill path)
# or not refreshing at all (a redundant --stop-recording) leaves it stuck
# 'active', dead-ending every later click on it.
export OMARCHY_TEST_SEQUENCE="$tmp_dir/sequence"
export OMARCHY_TEST_RECORDER_RUNNING="$tmp_dir/recorder-running"
export OMARCHY_TEST_KILL_SENT="$tmp_dir/kill-sent"
export OMARCHY_TEST_EXIT_DELAY="$tmp_dir/exit-delay"
export OMARCHY_TEST_GSR_HELD="$tmp_dir/gsr-held"
export OMARCHY_TEST_INDICATOR_STATE="$tmp_dir/indicator-state"
sequence_file=$OMARCHY_TEST_SEQUENCE

# A recorder that ignores SIGINT unless OMARCHY_TEST_GRACEFUL is set, and after
# SIGKILL stays visible while held or for OMARCHY_TEST_EXIT_DELAY more probes.
cat >"$stub_bin/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
case "$*" in
*"--signal INT")
  printf 'signal INT\n' >>"$OMARCHY_TEST_SEQUENCE"
  [[ ${OMARCHY_TEST_GRACEFUL:-false} == "true" ]] && rm -f "$OMARCHY_TEST_RECORDER_RUNNING"
  exit 0
  ;;
*"--signal KILL")
  printf 'signal KILL\n' >>"$OMARCHY_TEST_SEQUENCE"
  touch "$OMARCHY_TEST_KILL_SENT"
  exit 0
  ;;
esac
[[ -f $OMARCHY_TEST_RECORDER_RUNNING ]] || exit 1
[[ -f $OMARCHY_TEST_KILL_SENT && ! -f $OMARCHY_TEST_GSR_HELD ]] || exit 0
remaining=$(cat "$OMARCHY_TEST_EXIT_DELAY" 2>/dev/null || echo 0)
if ((remaining > 0)); then
  echo "$((remaining - 1))" >"$OMARCHY_TEST_EXIT_DELAY"
  printf 'recorder still exiting\n' >>"$OMARCHY_TEST_SEQUENCE"
  exit 0
fi
rm -f "$OMARCHY_TEST_RECORDER_RUNNING"
exit 1
SH

# The bar asks --status on refresh; record what it would see at that moment.
cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf 'omarchy-shell %s\n' "$*" >>"$OMARCHY_TEST_SEQUENCE"
if [[ -f $OMARCHY_TEST_RECORDER_RUNNING ]]; then
  echo recording >"$OMARCHY_TEST_INDICATOR_STATE"
else
  echo idle >"$OMARCHY_TEST_INDICATOR_STATE"
fi
SH

cat >"$stub_bin/sleep" <<'SH'
#!/bin/bash
[[ $1 == "1" ]] && /usr/bin/sleep 0.01
exit 0
SH

chmod +x "$stub_bin"/omarchy-capture-screenrecording-process "$stub_bin"/omarchy-shell "$stub_bin"/sleep

stop_runtime="$tmp_dir/stop-runtime"
mkdir -p "$stop_runtime"
stop_recording() {
  XDG_RUNTIME_DIR="$stop_runtime" OMARCHY_SCREENRECORD_DIR="$recording_dir" \
    timeout 3 "$ROOT/bin/omarchy-capture-screenrecording" --stop-recording >/dev/null 2>&1
}

# A recorder still alive when the grace period ends gets SIGKILLed; the
# indicator must read idle even when exiting takes several probes after it.
touch "$OMARCHY_TEST_RECORDER_RUNNING"
rm -f "$OMARCHY_TEST_KILL_SENT" "$OMARCHY_TEST_NOTIFICATION_ARGS"
echo 3 >"$OMARCHY_TEST_EXIT_DELAY"
: >"$sequence_file"
stop_recording || true

kill_line=$(grep -n '^signal KILL' "$sequence_file" | head -1 | cut -d: -f1 || true)
refresh_line=$(grep -n 'omarchy.indicators refresh' "$sequence_file" | head -1 | cut -d: -f1 || true)
[[ -n $kill_line && -n $refresh_line ]] && ((refresh_line > kill_line)) ||
  fail "indicator refresh runs after the force-kill, not before it" "$(cat "$sequence_file")"
pass "indicator refresh runs after the force-kill, not before it"

[[ $(cat "$OMARCHY_TEST_INDICATOR_STATE") == "idle" ]] ||
  fail "a delayed SIGKILL exit is idle at indicator refresh" "$(cat "$sequence_file")"
pass "a delayed SIGKILL exit is idle at indicator refresh"

grep -F 'force-killed' "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "a force-killed recording posts the error notification" "$(cat "$OMARCHY_TEST_NOTIFICATION_ARGS")"
pass "a force-killed recording posts the error notification"

# If the recorder remains visible beyond the bounded foreground wait, stopping
# still returns and posts the error, then refreshes when the recorder disappears.
touch "$OMARCHY_TEST_RECORDER_RUNNING" "$OMARCHY_TEST_GSR_HELD"
rm -f "$OMARCHY_TEST_KILL_SENT" "$OMARCHY_TEST_INDICATOR_STATE" "$OMARCHY_TEST_NOTIFICATION_ARGS"
echo 0 >"$OMARCHY_TEST_EXIT_DELAY"
: >"$sequence_file"

if ! stop_recording; then
  rm -f "$OMARCHY_TEST_GSR_HELD"
  fail "a recorder held after SIGKILL does not block stopping"
fi
[[ ! -f $OMARCHY_TEST_INDICATOR_STATE ]] ||
  fail "a recorder still present is not prematurely refreshed"
grep -F 'force-killed' "$OMARCHY_TEST_NOTIFICATION_ARGS" >/dev/null ||
  fail "a recorder held after SIGKILL posts the error notification"
pass "a recorder held after SIGKILL returns without a premature refresh"

# Stopping again while it is still stuck must not start a second watcher.
if ! stop_recording; then
  rm -f "$OMARCHY_TEST_GSR_HELD"
  fail "a second stop while the recorder is stuck does not block stopping"
fi

# Count by the watch lock: an earlier stop's preview cleanup shares the command line.
count_watchers() {
  local pid count=0
  for pid in $(/usr/bin/pgrep -f "$ROOT/bin/omarchy-capture-screenrecording --stop-recording"); do
    [[ $(readlink "/proc/$pid/fd/9" 2>/dev/null) == "$stop_runtime/omarchy-screenrecord-watch.lock" ]] && ((++count))
  done
  echo "$count"
}

for attempt in {1..100}; do
  (($(count_watchers) == 1)) && break
  /usr/bin/sleep 0.01
done
watchers=$(count_watchers)
if ((watchers != 1)); then
  rm -f "$OMARCHY_TEST_GSR_HELD"
  fail "repeated stops while the recorder is stuck leave one watcher" "watchers: $watchers"
fi
pass "repeated stops while the recorder is stuck leave one watcher"

rm -f "$OMARCHY_TEST_GSR_HELD"
for attempt in {1..100}; do
  [[ $(cat "$OMARCHY_TEST_INDICATOR_STATE" 2>/dev/null) == "idle" ]] && break
  /usr/bin/sleep 0.01
done
[[ $(cat "$OMARCHY_TEST_INDICATOR_STATE" 2>/dev/null) == "idle" ]] ||
  fail "a recorder that outlasts the foreground wait eventually refreshes idle" "$(cat "$sequence_file")"
pass "a recorder that outlasts the foreground wait eventually refreshes idle"

# Clicking the indicator while it shows a stale 'active' state runs
# --stop-recording; refreshing there lets the dead button recover by itself.
rm -f "$OMARCHY_TEST_RECORDER_RUNNING"
: >"$sequence_file"
if stop_recording; then
  fail "a redundant --stop-recording exits nonzero"
fi
pass "a redundant --stop-recording exits nonzero"

grep -F 'omarchy.indicators refresh' "$sequence_file" >/dev/null ||
  fail "a redundant --stop-recording resyncs the indicator" "$(cat "$sequence_file")"
pass "a redundant --stop-recording resyncs the indicator"

# A graceful stop must clear the indicator before post-processing, which can
# take seconds per recorded minute; only finalize_recording runs ffprobe.
recording_file="$recording_dir/screenrecording-graceful.mp4"
: >"$recording_file"
echo "$recording_file" >"$stop_runtime/omarchy-screenrecord-filename"

cat >"$stub_bin/ffprobe" <<'SH'
#!/bin/bash
printf 'ffprobe %s\n' "$*" >>"$OMARCHY_TEST_SEQUENCE"
exit 1
SH

cat >"$stub_bin/ffmpeg" <<'SH'
#!/bin/bash
printf 'ffmpeg %s\n' "$*" >>"$OMARCHY_TEST_SEQUENCE"
exit 1
SH

chmod +x "$stub_bin"/ffprobe "$stub_bin"/ffmpeg

touch "$OMARCHY_TEST_RECORDER_RUNNING"
rm -f "$OMARCHY_TEST_KILL_SENT"
: >"$sequence_file"
OMARCHY_TEST_GRACEFUL=true stop_recording || true

refresh_line=$(grep -n 'omarchy.indicators refresh' "$sequence_file" | head -1 | cut -d: -f1 || true)
finalize_line=$(grep -n '^ffprobe ' "$sequence_file" | head -1 | cut -d: -f1 || true)
[[ -n $refresh_line && -n $finalize_line ]] && ((refresh_line < finalize_line)) ||
  fail "a graceful stop refreshes the indicator before post-processing" "$(cat "$sequence_file")"
! grep -q '^signal KILL' "$sequence_file" ||
  fail "a recorder that stops on INT is not killed" "$(cat "$sequence_file")"
pass "a graceful stop refreshes the indicator before post-processing"

# A recorder this script did not start leaves no recording to finalize; its stop
# still clears the indicator.
touch "$OMARCHY_TEST_RECORDER_RUNNING"
: >"$sequence_file"
OMARCHY_TEST_GRACEFUL=true stop_recording || true
grep -F 'omarchy.indicators refresh' "$sequence_file" >/dev/null ||
  fail "a stop with no recording to finalize refreshes the indicator" "$(cat "$sequence_file")"
pass "a stop with no recording to finalize refreshes the indicator"
