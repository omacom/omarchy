#!/bin/bash
# End-to-end client test under a headless sway (wlroots), when available.
# Usage: wayland-test.sh CLIENT_BINARY
# Starts its own sway with WLR_BACKENDS=headless and a private
# XDG_RUNTIME_DIR inside a retained ${TMPDIR:-/var/tmp} directory; never
# touches the user's session. Skips when sway or python3 is missing.
set -euo pipefail
client=$1
command -v sway >/dev/null && command -v python3 >/dev/null || {
  printf 'continuity wayland test: SKIP (sway or python3 unavailable)\n'
  exit 0
}
work=$(mktemp -d "${TMPDIR:-/var/tmp}/omarchy-continuity-wayland-test.XXXXXX")
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# A copy drops sway's file capabilities, which a rootless container refuses.
cp "$(command -v sway)" "$work/sway"
sway_pid=
start_sway() { # NAME OUTPUTS CONFIG
  local name=$1 outputs=$2 config=$3
  stop_sway
  export XDG_RUNTIME_DIR=$work/$name-xdg
  mkdir -m 0700 "$XDG_RUNTIME_DIR"
  printf '%s\n' "$config" >"$work/$name-sway.conf"
  WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1 WLR_HEADLESS_OUTPUTS=$outputs \
    "$work/sway" -c "$work/$name-sway.conf" >"$work/$name-sway.log" 2>&1 &
  sway_pid=$!
  for _ in $(seq 1 200); do
    [[ -S $XDG_RUNTIME_DIR/wayland-1 ]] && break
    sleep 0.05
  done
  [[ -S $XDG_RUNTIME_DIR/wayland-1 ]] || fail "$name: sway did not start: $(cat "$work/$name-sway.log")"
  export WAYLAND_DISPLAY=wayland-1
  sleep 0.3
}
stop_sway() {
  [[ -n $sway_pid ]] || return 0
  kill "$sway_pid" 2>/dev/null || true
  wait "$sway_pid" 2>/dev/null || true
  sway_pid=
}
trap stop_sway EXIT

frame() { # PATH WIDTH HEIGHT
  python3 -I - "$@" <<'EOF'
import struct, sys, time
path, w, h = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
now = time.clock_gettime_ns(time.CLOCK_BOOTTIME)
header = b"OMBFRAW1" + struct.pack("<IIII", w, h, w * 4, 0x34325258) + struct.pack("<QQQ", w * h * 4, now, 0)
row = bytes((x * 7) & 0xff for x in range(w * 4))
with open(path, "wb") as f:
    f.write(header)
    for _ in range(h):
        f.write(row)
EOF
}

run_client() { # NAME ARGS...
  local name=$1
  shift
  "$client" "$@" 2>"$work/$name.log" || fail "$name: non-zero exit"
}

expect() { # NAME REGEX
  grep -Eq -- "$2" "$work/$1.log" || fail "$1: expected /$2/ in: $(cat "$work/$1.log")"
}

# One 1280x800 output at scale 2: single-output fast path, viewporter.
start_sway single 1 'output HEADLESS-1 mode 1280x800 scale 2'
frame "$work/single.raw" 1280 800
sha_before=$(sha256sum "$work/single.raw")
run_client single --file "$work/single.raw" --max-ms 300 --fade-ms 0 \
  --ready-file "$work/single.ready" --pid-file "$work/single.pid"
expect single 'first-frame .*output=HEADLESS-1 size=1280x800 logical=640x400 latency_ms=[0-9]+'
expect single 'timing .*file=[0-9.]+ connect=[0-9.]+ buffer=[0-9.]+ registry=[0-9.]+ outputs=- surface=[0-9.]+ configure=[0-9.]+ commit=[0-9.]+ frame=[0-9.]+ presented=[0-9.]+ copy=sendfile'
expect single 'exit .*reason=max-ms shown_ms=[0-9]+'
grep -q '^first_frame_ns=[0-9]' "$work/single.ready" || fail "single: ready file"
[[ ! -e $work/single.pid ]] || fail "single: pid file left behind"
[[ $(sha256sum "$work/single.raw") == "$sha_before" ]] || fail "single: raw file changed"
[[ $(grep -c ' timing ' "$work/single.log") == 1 ]] || fail "single: timing logged more than once"

# SIGUSR1 fades with the ARGB buffer fallback (lazy read-only frame map).
"$client" --file "$work/single.raw" --max-ms 5000 --fade-ms 100 --no-alpha-modifier \
  --ready-file "$work/fade.ready" 2>"$work/fade.log" &
pid=$!
for _ in $(seq 1 200); do [[ -s $work/fade.ready ]] && break; sleep 0.02; done
kill -USR1 "$pid"
wait "$pid" || fail "fade: non-zero exit"
expect fade 'fade boottime=[0-9.]+ reason=sigusr1 mechanism=argb-premultiplied fade_ms=100'
expect fade 'exit .*reason=(faded|fade-timeout)'

# SIGTERM as early as the signals are blocked (the "start" line) leaves at
# once, without a fade, whatever startup phase it lands in.
"$client" --file "$work/single.raw" --max-ms 5000 2>"$work/term.log" &
pid=$!
for _ in $(seq 1 500); do grep -q ' start ' "$work/term.log" && break; sleep 0.002; done
kill -TERM "$pid"
wait "$pid" || fail "term: non-zero exit"
expect term 'exit .*reason=sigterm'
grep -q ' fade ' "$work/term.log" && fail "term: faded"

# Frame size not matching the only output's mode.
frame "$work/mismatch.raw" 1024 768
run_client mismatch --file "$work/mismatch.raw" --max-ms 2000
expect mismatch 'exit .*reason=no-matching-output'
grep -q 'first-frame' "$work/mismatch.log" && fail "mismatch: showed a frame"

# Two outputs: the extra output roundtrip picks the matching one.
start_sway dual 2 'output HEADLESS-1 mode 1024x768
output HEADLESS-2 mode 1280x800 scale 2'
run_client dual --file "$work/single.raw" --max-ms 300 --fade-ms 0
expect dual 'first-frame .*output=HEADLESS-2 size=1280x800'
expect dual 'timing .* outputs=[0-9.]+ '
stop_sway

printf 'continuity wayland test: PASS (fixtures retained in %s)\n' "$work"
