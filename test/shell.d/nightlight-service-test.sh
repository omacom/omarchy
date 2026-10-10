#!/bin/bash

# Runs the real nightlight Service.qml under Quickshell against stubbed
# hyprctl and omarchy-nightlight-config, and checks the orderings that used to
# race: quick double toggles, warmth previews around a save, and toggles made
# while a save restarts hyprsunset.

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

require_compositor "nightlight service test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping nightlight service test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/nightlight-service"
control="$TMPDIR/control"
mkdir -p "$config_dir" "$control" "$TMPDIR/home" "$TMPDIR/bin"
cp "$SHELL_TEST_DIR/fixtures/nightlight-service/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

printf '6500\n' >"$control/state"
: >"$control/log"

# hyprctl: "get" reads the screen, "set N" changes it. apply-delay slows a set
# down so a save can be asked for while it is still running.
cat >"$TMPDIR/bin/hyprctl" <<'SH'
#!/bin/bash
[[ ${1:-} == "hyprsunset" && ${2:-} == "temperature" ]] || exit 1
if [[ -n ${3:-} ]]; then
  delay=$(cat "$NIGHTLIGHT_TEST_DIR/apply-delay" 2>/dev/null || echo 0)
  sleep "$delay"
  printf '%s\n' "$3" >"$NIGHTLIGHT_TEST_DIR/state"
  printf 'set %s\n' "$3" >>"$NIGHTLIGHT_TEST_DIR/log"
else
  printf 'get\n' >>"$NIGHTLIGHT_TEST_DIR/log"
  sleep "$(cat "$NIGHTLIGHT_TEST_DIR/get-delay" 2>/dev/null || echo 0)"
  cat "$NIGHTLIGHT_TEST_DIR/state"
fi
SH

cat >"$TMPDIR/bin/pgrep" <<'SH'
#!/bin/bash
exit 0
SH

# The save command: logs when it starts and ends, takes save-delay seconds,
# and exits with save-exit.
cat >"$TMPDIR/bin/omarchy-nightlight-config" <<'SH'
#!/bin/bash
[[ ${1:-} == "set" ]] || exit 0
shift
printf 'save-start %s\n' "$*" >>"$NIGHTLIGHT_TEST_DIR/log"
sleep "$(cat "$NIGHTLIGHT_TEST_DIR/save-delay" 2>/dev/null || echo 0)"
code=$(cat "$NIGHTLIGHT_TEST_DIR/save-exit" 2>/dev/null || echo 0)
printf 'save-end %s\n' "$code" >>"$NIGHTLIGHT_TEST_DIR/log"
(( code == 0 )) || echo "Could not write hyprsunset.conf" >&2
exit "$code"
SH

chmod +x "$TMPDIR/bin/"*

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
NIGHTLIGHT_TEST_DIR="$control" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
PATH="$TMPDIR/bin:$PATH" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..200}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,160p' "$log" >&2
    fail "nightlight service quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,160p' "$log" >&2
  fail "nightlight service test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  jq . "$result" >&2
  sed -n '1,160p' "$log" >&2
  fail "nightlight service orders toggles, previews, and saves"
fi

pass "nightlight service orders toggles, previews, and saves"
