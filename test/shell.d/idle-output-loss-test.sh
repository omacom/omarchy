#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""

cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

require_compositor "idle output loss test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping idle output loss test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
wakes="$TMPDIR/wakes.log"
config_dir="$TMPDIR/idle-output-loss"
mkdir -p "$config_dir" "$TMPDIR/home" "$TMPDIR/stubs"
cp "$SHELL_TEST_DIR/fixtures/idle-output-loss/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

# Stub the boundary: the idle service's wake command only records that it ran.
cat >"$TMPDIR/stubs/omarchy-system-wake" <<STUB
#!/bin/bash
echo wake >> "$wakes"
STUB
chmod +x "$TMPDIR/stubs/omarchy-system-wake"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
OMARCHY_WAKE_LOG="$wakes" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
PATH="$TMPDIR/stubs:$ROOT/bin:$PATH" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..120}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,220p' "$log" >&2
    fail "idle output loss quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "idle output loss test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  jq . "$result" >&2
  sed -n '1,220p' "$log" >&2
  fail "idle service keeps the cycle through output loss and still cancels on real activity"
fi

# The wake stub runs asynchronously; each scenario marks its own section.
expected=$'S no-outputs-close\nS fallback-only-close\nS stale-list-monitorremoved\nS fallback-removed-close\nwake\nS real-dismissal\nwake\nS real-activity\nwake'
if [[ $(cat "$wakes") != "$expected" ]]; then
  printf 'Wake log:\n' >&2
  cat "$wakes" >&2
  sed -n '1,120p' "$log" >&2
  fail "wake runs only for real dismissal and activity, never for output loss"
fi

pass "idle service keeps the cycle through output loss and still cancels on real activity"
