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

require_compositor "bar drag test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping bar drag test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/bar-drag"
mkdir -p "$config_dir" "$TMPDIR/home" "$TMPDIR/bin"
cp "$SHELL_TEST_DIR/fixtures/bar-drag/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"
# The bar syncs the compositor's blur to its background as it starts.
printf '#!/bin/bash\nexit 0\n' >"$TMPDIR/bin/omarchy-bar"
chmod +x "$TMPDIR/bin/omarchy-bar"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..100}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,160p' "$log" >&2
    fail "bar drag quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,160p' "$log" >&2
  fail "bar drag test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  printf 'bar drag result:\n' >&2
  jq . "$result" >&2
  printf 'bar drag log:\n' >&2
  sed -n '1,160p' "$log" >&2
  fail "dragged widgets land where dropped, as the instances dragged"
fi

pass "dragged widgets land where dropped, as the instances dragged"
