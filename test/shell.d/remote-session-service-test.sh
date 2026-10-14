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
  if [[ -n $TMPDIR && -f $TMPDIR/stub.pid ]]; then
    kill "$(<"$TMPDIR/stub.pid")" 2>/dev/null || true
  fi
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

require_compositor "remote session service test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping remote session service test"
  exit 0
fi

require_command jq
require_command grim

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/remote-session"
mkdir -p "$config_dir" "$TMPDIR/home" "$TMPDIR/bin"
cp "$SHELL_TEST_DIR/fixtures/remote-session/shell.qml" "$config_dir/shell.qml"

# A stand-in for the real server: the probe matches it by process name, so it
# must stay a script called gliff-server rather than exec into sleep, and it
# takes its sleep down with it when killed. Its ssh peer comes from the
# environment the fixture launches it with. It cannot capture the screen, so
# the fixture uses grim for the screencast event.
cat >"$TMPDIR/bin/gliff-server" <<'SH'
#!/bin/bash
sleep 30 &
trap 'kill $!' TERM EXIT
wait $!
SH

chmod +x "$TMPDIR/bin/gliff-server"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
OMARCHY_QML_TEST_STUB_PID="$TMPDIR/stub.pid" \
OMARCHY_QML_TEST_FRAME="$TMPDIR/frame.png" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..150}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,160p' "$log" >&2
    fail "remote session quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,160p' "$log" >&2
  fail "remote session service test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  jq . "$result" >&2
  sed -n '1,160p' "$log" >&2
  fail "remote session service tracks a gliff-server session"
fi
pass "remote session service tracks a gliff-server session"

[[ -s $TMPDIR/frame.png ]] || fail "the fixture raised screencast events through grim"
pass "the fixture raised screencast events through grim"

