#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Stubs a recorder and a sysfs tree. Nothing here opens a GPU or records a screen.
tmp=$(mktemp -d)
stub="$tmp/bin"
pci="$tmp/pci"
dri="$tmp/dri"
runtime="$tmp/runtime"
recordings="$tmp/recordings"
notice="$tmp/notice"
mkdir -p "$stub"

trap 'pkill -f "$stub/gpu-screen-recorder" 2>/dev/null || true; rm -rf "$tmp"' EXIT

cat >"$stub/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_NOTIFICATION_ARGS"
SH

cat >"$stub/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
printf 'eDP-1\n'
SH

cat >"$stub/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$stub/omarchy-shell" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub/gpu-screen-recorder" <<'SH'
#!/bin/bash
case ${OMARCHY_TEST_GSR_MODE:-ok} in
fail)
  echo 'gsr error: gsr_get_supported_video_codecs_vaapi: vaInitialize failed' >&2
  ;;
exit)
  echo 'gsr error: gsr_get_supported_video_codecs_vaapi: vaInitialize failed' >&2
  exit 1
  ;;
cancel)
  echo 'gsr error: gsr_get_supported_video_codecs_vaapi: vaInitialize failed' >&2
  touch "$XDG_RUNTIME_DIR/omarchy-screenrecord-cancel"
  sleep 30
  exit 0
  ;;
esac

for arg in "$@"; do
  [[ -n ${take_next:-} ]] && { : >"$arg"; break; }
  [[ $arg == "-o" ]] && take_next=1
done
sleep 30
SH

chmod +x "$stub"/*

export PATH="$stub:$ROOT/bin:/usr/bin:/bin"
export XDG_RUNTIME_DIR="$runtime"
export OMARCHY_PCI_DEVICES_PATH="$pci"
export OMARCHY_DRI_DRIVERS_PATH="$dri"
export OMARCHY_SCREENRECORD_DIR="$recordings"
export OMARCHY_TEST_NOTIFICATION_ARGS="$notice"

add_gpu() {
  local slot=$1 vendor=$2 class=$3
  mkdir -p "$pci/$slot"
  printf '%s\n' "$vendor" >"$pci/$slot/vendor"
  printf '%s\n' "$class" >"$pci/$slot/class"
}

reset_case() {
  pkill -f "$stub/gpu-screen-recorder" 2>/dev/null || true
  rm -rf "$pci" "$dri" "$runtime" "$recordings" "$notice"
  mkdir -p "$pci" "$dri" "$runtime" "$recordings"
}

record() {
  OMARCHY_TEST_GSR_MODE=$1 "$ROOT/bin/omarchy-capture-screenrecording" --fullscreen --resolution=0x0 >/dev/null 2>&1 || true
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
