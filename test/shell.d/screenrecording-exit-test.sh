#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

tmp=$(mktemp -d)
cleanup() {
  if [[ -s $tmp/pid ]]; then kill "$(<"$tmp/pid")" 2>/dev/null || true; fi
  rm -rf "$tmp"
}
trap cleanup EXIT
mkdir -p "$tmp/bin" "$tmp/runtime" "$tmp/videos"
mkfifo "$tmp/release"
export TEST_STATE="$tmp" XDG_RUNTIME_DIR="$tmp/runtime" OMARCHY_SCREENRECORD_DIR="$tmp/videos"
export PATH="$tmp/bin:$ROOT/bin:$PATH"

cat >"$tmp/bin/gpu-screen-recorder" <<'SH'
#!/bin/bash
echo $$ >"$TEST_STATE/pid"
while (( $# )); do
  if [[ ${0##*/} == "gpu-screen-recorder" && $1 == "-o" || ${0##*/} == "wf-recorder" && $1 == "-f" ]]; then touch "$2"; break; fi
  shift
done
read -r _ <"$TEST_STATE/release"
exit "${TEST_EXIT_CODE:-0}"
SH
cat >"$tmp/bin/omarchy-capture-screenrecording-process" <<'SH'
#!/bin/bash
[[ -s $TEST_STATE/pid ]] && kill -0 "$(<"$TEST_STATE/pid")" 2>/dev/null
SH
cat >"$tmp/bin/omarchy-shell" <<'SH'
#!/bin/bash
[[ $* == "-q omarchy.indicators refresh" ]] || exit 1
echo refresh >>"$TEST_STATE/refreshes"
SH
cat >"$tmp/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "$TEST_BACKEND" ]]
SH
cat >"$tmp/bin/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
echo Test-1
SH
cp "$tmp/bin/gpu-screen-recorder" "$tmp/bin/wf-recorder"
chmod +x "$tmp/bin/"*

for backend in gpu-screen-recorder wf-recorder; do
  export TEST_BACKEND=$backend
  for code in 0 1; do
    rm -f "$tmp/pid" "$tmp/refreshes" "$tmp/runtime/omarchy-screenrecord-pid"
    TEST_EXIT_CODE=$code "$ROOT/bin/omarchy-capture-screenrecording" --fullscreen --resolution=1280x720
    [[ -s $tmp/refreshes ]] || fail "starting a recording refreshes its indicator"
    before=$(wc -l <"$tmp/refreshes")
    echo exit >"$tmp/release"
    for _ in {1..100}; do
      [[ $(wc -l <"$tmp/refreshes") -gt $before ]] && break
      sleep 0.02
    done
    [[ $(wc -l <"$tmp/refreshes") -gt $before ]] || fail "$backend exit $code refreshes the indicator without a stop command"
    pass "$backend exit $code refreshes the indicator without a stop command"
  done
done
