#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# The overlay decision is what Omarchy controls. mpv, the GL probe, and Hyprland
# are stubbed, so this checks the command that would be launched. It does not
# open a camera and it does not exercise an M3 Max.
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

stub="$tmp/bin"
mkdir -p "$stub"
runtime="$tmp/runtime"
signature="webcam-overlay-test"
marker="$runtime/hypr/$signature/omarchy-software-rendering"
mkdir -p "${marker%/*}"

args="$tmp/mpv-args"
pids="$tmp/mpv-pids"
probe="$tmp/probe"
ready="$tmp/overlay-ready"
seen="$tmp/mpv-seen"
log="$tmp/overlay.log"
resize="$tmp/resize"
elapsed="$tmp/elapsed"
stderr="$tmp/stderr"
region="$tmp/region"
modefile="$tmp/mpv-mode"
statusfile="$tmp/gpu-status"
functions="$tmp/functions"

awk '
  /^(webcam_overlay_gpu_unsupported|webcam_overlay_mapped|webcam_overlay_running|launch_webcam_overlay|wait_for_webcam_overlay|start_webcam_overlay|cleanup_webcam)\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-capture-screenrecording" >"$functions"

cat >"$stub/mpv" <<'SH'
#!/bin/bash
printf '%s\n' "$$" >>"$OMARCHY_TEST_MPV_PIDS"
printf '%s\n' "$*" >>"$OMARCHY_TEST_MPV_ARGS"
mode=$(cat "$OMARCHY_TEST_MPV_MODE")
case $mode in
abort)
  exit 134
  ;;
abort-once)
  if [[ ! -e $OMARCHY_TEST_MPV_SEEN ]]; then
    : >"$OMARCHY_TEST_MPV_SEEN"
    exit 134
  fi
  : >"$OMARCHY_TEST_OVERLAY_READY"
  sleep 30
  ;;
hang)
  sleep 30
  ;;
*)
  : >"$OMARCHY_TEST_OVERLAY_READY"
  sleep 30
  ;;
esac
SH

cat >"$stub/omarchy-hw-software-rendering" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_GPU_PROBE"
exit "$(cat "$OMARCHY_TEST_GPU_STATUS")"
SH

cat >"$stub/hyprctl" <<'SH'
#!/bin/bash
[[ $1 == clients ]] || exit 0
if [[ -e $OMARCHY_TEST_OVERLAY_READY ]]; then
  printf '%s\n' '[{"title":"WebcamOverlay"}]'
else
  printf '%s\n' '[]'
fi
SH

cat >"$stub/v4l2-ctl" <<'SH'
#!/bin/bash
printf '%s\n' "Size: Discrete 1280x720" "Size: Discrete 1920x1080"
SH

cat >"$stub/omarchy-capture-webcam-resize" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_RESIZE"
SH

cat >"$stub/pkill" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$stub"/*

gpu_args="av://v4l2:/dev/video1 --profile=low-latency --untimed --no-cache --demuxer-lavf-o=video_size=1280x720,framerate=30 --vf=lavfi=[crop=ih*8/9:ih] --title=WebcamOverlay --wayland-app-id=WebcamOverlay-medium --no-border --no-audio --no-osc --osd-level=0 --really-quiet"
software_args="$gpu_args --vo=gpu --gpu-api=opengl --gpu-context=wayland --gpu-sw=yes --demuxer-lavf-probe-info=auto --demuxer-lavf-analyzeduration=0 --video-latency-hacks=no"

cleanup_mpv() {
  [[ -s $pids ]] || return 0
  local pid
  while read -r pid; do
    kill "$pid" 2>/dev/null || true
  done <"$pids"
}
trap 'cleanup_mpv; rm -rf "$tmp"' EXIT

run_overlay() {
  local mode=$1 status=$2 target=${3:-region:800x600+1+2}
  cleanup_mpv
  rm -f "$args" "$pids" "$probe" "$ready" "$seen" "$log" "$resize" "$elapsed" "$stderr" "$region"
  printf '%s\n' "$mode" >"$modefile"
  printf '%s\n' "$status" >"$statusfile"

  FUNCTIONS="$functions" \
    TARGET="$target" \
    ELAPSED="$elapsed" \
    LOG_FILE="$log" \
    REGION_FILE="$region" \
    WEBCAM_DEVICE=/dev/video1 \
    WEBCAM_SIZE=medium \
    XDG_RUNTIME_DIR="$runtime" \
    HYPRLAND_INSTANCE_SIGNATURE="$signature" \
    OMARCHY_TEST_MPV_ARGS="$args" \
    OMARCHY_TEST_MPV_PIDS="$pids" \
    OMARCHY_TEST_MPV_MODE="$modefile" \
    OMARCHY_TEST_MPV_SEEN="$seen" \
    OMARCHY_TEST_GPU_PROBE="$probe" \
    OMARCHY_TEST_GPU_STATUS="$statusfile" \
    OMARCHY_TEST_OVERLAY_READY="$ready" \
    OMARCHY_TEST_RESIZE="$resize" \
    PATH="$stub:$PATH" \
    timeout 20 bash -c '
      source "$FUNCTIONS"
      start=${EPOCHREALTIME}
      start_webcam_overlay "$TARGET"
      awk -v s="$start" -v e="$EPOCHREALTIME" "BEGIN { printf \"%.3f\\n\", e - s }" >"$ELAPSED"
    ' 2>"$stderr"
  [[ ! -s $stderr ]] || fail "webcam overlay startup prints nothing (mpv $mode, probe $status)" "$(cat "$stderr")"
}

lines() {
  [[ -e $1 ]] || {
    echo 0
    return
  }
  wc -l <"$1" | tr -d ' '
}

rm -f "$marker"
run_overlay map 1
[[ $(cat "$args") == "$gpu_args" ]] || fail "a GPU overlay keeps mpv's default renderer" "$(cat "$args")"
[[ $(lines "$args") == 1 && $(lines "$probe") == 1 ]] || fail "a GPU overlay is launched once" "$(cat "$args")"
[[ ! -e $log ]] || fail "a GPU overlay logs no software fallback" "$(cat "$log")"
[[ $(cat "$region") == "800x600+1+2" ]] || fail "a region recording still anchors the overlay" "$(cat "$region" 2>/dev/null)"
[[ $(cat "$resize") == medium ]] || fail "the overlay is still resized" "$(cat "$resize" 2>/dev/null)"
pass "a GPU overlay keeps mpv's default renderer"

run_overlay map 2 "monitor:eDP-1"
[[ $(cat "$args") == "$gpu_args" ]] || fail "an unreadable GL renderer still tries the GPU overlay" "$(cat "$args")"
[[ $(lines "$args") == 1 ]] || fail "an unreadable GL renderer does not also launch software rendering" "$(cat "$args")"
[[ ! -e $region ]] || fail "a monitor recording writes no region file" "$(cat "$region")"
pass "an unreadable GL renderer still tries the GPU overlay"

run_overlay hang 1
[[ $(cat "$args") == "$gpu_args" ]] || fail "a live GPU overlay is not replaced while its window is still mapping" "$(cat "$args")"
[[ $(lines "$args") == 1 ]] || fail "a live GPU overlay is launched once" "$(cat "$args")"
awk -v e="$(cat "$elapsed")" 'BEGIN { exit !(e >= 2.0) }' ||
  fail "a live GPU overlay is given the map wait before any fallback" "$(cat "$elapsed")"
pass "a live GPU overlay is not replaced while its window is still mapping"

run_overlay map 0
[[ $(cat "$args") == "$software_args" ]] || fail "a software rasterizer opens the overlay with Wayland software rendering" "$(cat "$args")"
[[ $(lines "$args") == 1 && $(lines "$probe") == 1 ]] || fail "a software rasterizer launches one overlay" "$(cat "$args")"
grep -Fqx 'webcam overlay: Wayland software rendering (no GPU acceleration)' "$log" ||
  fail "a software rasterizer records why the GPU renderer was skipped" "$(cat "$log" 2>/dev/null)"
! grep -F 'retrying' "$log" || fail "a software rasterizer does not start a GPU overlay first" "$(cat "$log")"
pass "a software rasterizer opens the overlay with Wayland software rendering"

printf '%s\n' 'llvmpipe (LLVM 21.1.0, 128 bits)' >"$marker"
run_overlay map 1
[[ $(cat "$args") == "$software_args" ]] || fail "a session already rendering on the CPU uses Wayland software rendering" "$(cat "$args")"
[[ ! -e $probe ]] || fail "a session already rendering on the CPU does not probe Mesa again" "$(cat "$probe")"
grep -Fqx 'webcam overlay: Wayland software rendering (no GPU acceleration)' "$log" ||
  fail "a CPU-rendered session records the software overlay" "$(cat "$log" 2>/dev/null)"
pass "a session already rendering on the CPU uses Wayland software rendering"
rm -f "$marker"

run_overlay abort-once 1
[[ $(lines "$args") == 2 ]] || fail "a GPU overlay that exits is tried again with software rendering" "$(cat "$args")"
[[ $(sed -n '1p' "$args") == "$gpu_args" ]] || fail "the first attempt is the GPU renderer" "$(sed -n '1p' "$args")"
[[ $(sed -n '2p' "$args") == "$software_args" ]] || fail "the retry is the Wayland software renderer" "$(sed -n '2p' "$args")"
grep -Fqx 'webcam overlay: GPU renderer exited before the window mapped; retrying with Wayland software rendering' "$log" ||
  fail "the GPU exit is logged before the software retry" "$(cat "$log" 2>/dev/null)"
awk -v e="$(cat "$elapsed")" 'BEGIN { exit !(e < 2.0) }' ||
  fail "a GPU overlay that has already exited is replaced without waiting out the map timeout" "$(cat "$elapsed")"
[[ $(cat "$resize") == medium ]] || fail "the software retry still resizes the overlay" "$(cat "$resize" 2>/dev/null)"
pass "a GPU overlay that exits before mapping is retried with Wayland software rendering"

run_overlay abort 0
[[ $(cat "$args") == "$software_args" ]] || fail "a software rasterizer whose overlay exits is not launched again" "$(cat "$args")"
[[ $(lines "$args") == 1 ]] || fail "a failed software overlay is launched once" "$(cat "$args")"
grep -Fqx 'webcam overlay: software renderer exited before the window mapped' "$log" ||
  fail "a failed software overlay is logged" "$(cat "$log" 2>/dev/null)"
[[ $(cat "$resize") == medium ]] || fail "a failed software overlay still reaches resize" "$(cat "$resize" 2>/dev/null)"
pass "a failed software overlay is not launched again"

cleanup_mpv
