#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "output playback lifecycle (quickshell unavailable)"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/config" "$tmp/runtime"
chmod 700 "$tmp/runtime"
cp "$ROOT/test/shell.d/fixtures/audio-output/shell.qml" "$tmp/config/"
cp "$ROOT/shell/plugins/panels/audio/OutputTest.qml" "$tmp/config/"
cat >"$tmp/bin/pw-play" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" >"$OUTPUT_TEST_ARGS"
printf '%s\n' "$$" >>"$OUTPUT_TEST_PIDS"
if [[ $2 == "failure" ]]; then
  exit 1
fi
if [[ $2 == "complete" ]]; then
  exit 0
fi
exec sleep 60
STUB
chmod +x "$tmp/bin/pw-play"

# Offscreen QML and a fake player exercise Process lifecycle without playing
# sound or connecting to the user's desktop/audio session.
PATH="$tmp/bin:$PATH" OUTPUT_TEST_ARGS="$tmp/args" OUTPUT_TEST_PIDS="$tmp/pids" \
  XDG_RUNTIME_DIR="$tmp/runtime" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= \
  QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software \
  timeout 20 quickshell -p "$tmp/config" --no-color >"$tmp/log" 2>&1 || {
    cat "$tmp/log" >&2
    fail "output playback QML lifecycle runs"
  }
if ! rg -q 'OUTPUT_TEST_PASS' "$tmp/log" || rg -q 'OUTPUT_TEST_FAIL|ReferenceError|TypeError|Unable to assign' "$tmp/log"; then
  cat "$tmp/log" >&2
  fail "output playback QML lifecycle"
fi
while read -r pid; do
  if kill -0 "$pid" 2>/dev/null; then
    fail "output playback leaves no process after stopping or destruction"
  fi
done <"$tmp/pids"
pass "output playback starts only on request and stops on dismissal, output changes, failure, and timeout"

mapfile -t args <"$tmp/args"
[[ ${args[0]} == "--target" && ${args[1]} == "test-sink" ]] || fail "playback targets the selected output"
[[ ${args[2]} == "--volume" && ${args[3]} == "0.5" ]] || fail "test sound uses a modest stream volume"
[[ ${args[4]} == "--properties" && ${args[5]} == *"node.dont-fallback=true node.dont-reconnect=true" ]] || fail "playback cannot fall back to another output"
[[ ${args[6]} == "/usr/share/sounds/alsa/Front_Center.wav" ]] || fail "output test uses the installed short sample"
pass "output test targets the selected device without fallback and plays the short sample"
