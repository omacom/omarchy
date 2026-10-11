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

require_command python3

# The bar is built per monitor, so a widget's own IPC handler exists once per
# screen. Every one of them has to defer to the copy that owns the target.
ungated=$(ROOT="$ROOT" python3 <<'PY'
import os
import re
from pathlib import Path

root = Path(os.environ["ROOT"])
gated = 0
for path in sorted((root / "shell/plugins").glob("**/*.qml")):
  text = path.read_text()
  if not re.search(r"^(Panel|BarWidget) \{", text, re.M):
    continue
  for block in re.findall(r"^  ShellIpc \{\n(.*?)^  \}", text, re.M | re.S):
    if re.search(r"^    enabled: .*root\.ipcOwner$", block, re.M):
      gated += 1
    else:
      print(path.relative_to(root))
if gated == 0:
  print("no gated handler found")
PY
)
[[ -z $ungated ]] || fail "every bar widget's IPC handler is gated on ipcOwner" "ungated: $ungated"
pass "every bar widget's IPC handler is gated on ipcOwner"

require_compositor "bar IPC owner test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping bar IPC owner test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
config_dir="$TMPDIR/bar-ipc-owner"
mkdir -p "$config_dir" "$TMPDIR/home"
cp "$SHELL_TEST_DIR/fixtures/bar-ipc-owner/"*.qml "$config_dir/"
ln -s "$ROOT/shell/Ui" "$config_dir/Ui"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
  quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,120p' "$log" >&2
    fail "bar IPC owner quickshell exited before writing result"
  fi
  sleep 0.1
done

[[ -s $result ]] || {
  sed -n '1,120p' "$log" >&2
  fail "bar IPC owner test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  jq . "$result" >&2
  sed -n '1,120p' "$log" >&2
  fail "per-monitor copies register an IPC target once"
fi
pass "per-monitor copies register an IPC target once"

# The copies left after the handover answer through Quickshell itself.
reply=$(quickshell -p "$config_dir" ipc call test.widget ping 2>&1 || true)
[[ $reply == "pong" ]] || fail "the remaining widget copy answers its IPC target" "got: $reply"
targets=$(quickshell -p "$config_dir" ipc show 2>&1 || true)
grep -q '^target test.panel$' <<<"$targets" || fail "the remaining panel copy holds its IPC target" "got: $targets"
pass "the remaining copies answer their IPC targets"

if grep -q 'will not be used' "$log"; then
  grep 'will not be used' "$log" >&2
  fail "no duplicate IPC registration is logged"
fi
pass "no duplicate IPC registration is logged"
