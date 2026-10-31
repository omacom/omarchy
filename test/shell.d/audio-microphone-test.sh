#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "microphone capture lifecycle (quickshell unavailable)"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/config" "$tmp/runtime"
chmod 700 "$tmp/runtime"
cp "$ROOT/test/shell.d/fixtures/audio/shell.qml" "$tmp/config/"
cp "$ROOT/shell/plugins/panels/audio/MicrophoneTest.qml" "$tmp/config/"
cat >"$tmp/bin/pw-record" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" >"$MICROPHONE_TEST_ARGS"
printf '%s\n' "$$" >>"$MICROPHONE_TEST_PIDS"
if [[ $2 == "failure" ]]; then
  exit 1
fi
exec sleep 60
STUB
chmod +x "$tmp/bin/pw-record"

# Offscreen QML and a fake recorder exercise Process lifecycle without opening
# the user's microphone or connecting to their desktop/audio session.
PATH="$tmp/bin:$PATH" MICROPHONE_TEST_ARGS="$tmp/args" MICROPHONE_TEST_PIDS="$tmp/pids" \
  XDG_RUNTIME_DIR="$tmp/runtime" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= \
  QT_STYLE_OVERRIDE= QT_QUICK_BACKEND=software \
  timeout 40 quickshell -p "$tmp/config" --no-color >"$tmp/log" 2>&1 || {
    cat "$tmp/log" >&2
    fail "microphone capture QML lifecycle runs"
  }
if ! rg -q 'MICROPHONE_TEST_PASS' "$tmp/log" || rg -q 'MICROPHONE_TEST_FAIL|ReferenceError|TypeError|Unable to assign' "$tmp/log"; then
  cat "$tmp/log" >&2
  fail "microphone capture QML lifecycle"
fi
while read -r pid; do
  if kill -0 "$pid" 2>/dev/null; then
    fail "microphone capture leaves no process after stopping or destruction"
  fi
done <"$tmp/pids"
pass "microphone capture starts only on request and stops on dismissal, source changes, failure, and timeout"

mapfile -t args <"$tmp/args"
[[ ${args[0]} == "--target" && ${args[1]} == "test-source" ]] || fail "capture targets the selected microphone"
[[ ${args[4]} == "--properties" && ${args[5]} == "node.dont-fallback=true node.dont-reconnect=true" ]] || fail "capture cannot fall back to another microphone"
[[ ${args[6]} == "--raw" && ${args[7]} == "/dev/null" ]] || fail "microphone test discards captured audio"
pass "microphone test targets the selected device and discards audio without fallback"
