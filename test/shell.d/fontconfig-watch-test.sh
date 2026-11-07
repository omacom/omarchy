#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "fontconfig first-creation watcher"
require_command quickshell
require_command fc-match
require_command fc-list

test_dir=$(mktemp -d)
qs_pid=""
cleanup() {
  if [[ -n $qs_pid ]]; then
    kill "$qs_pid" 2>/dev/null || true
    wait "$qs_pid" 2>/dev/null || true
  fi
  rm -rf "$test_dir"
}
trap cleanup EXIT
mkdir -p "$test_dir/home" "$test_dir/shell"
cp "$SHELL_TEST_DIR/fixtures/fontconfig-watch/shell.qml" "$test_dir/shell/shell.qml"
ln -s "$ROOT/shell/Commons" "$test_dir/shell/Commons"
log="$test_dir/log"
HOME="$test_dir/home" XDG_CONFIG_HOME="$test_dir/home/.config" \
XDG_CACHE_HOME="$test_dir/home/.cache" OMARCHY_PATH="$ROOT" \
  quickshell -p "$test_dir/shell" --no-color >"$log" 2>&1 &
qs_pid=$!

wait_family() {
  for ((i=0; i<100; i++)); do
    if grep -Fq "FONT_RESOLVED:$1" "$log"; then return; fi
    sleep 0.1
  done
  fail "font watcher did not resolve $1" "$(cat "$log")"
}
wait_family ""
initial=$(sed -n 's/.*FONT_RESOLVED://p' "$log" | tail -1)
selected=$(fc-list -f '%{family[0]}\n' | sort -u | awk -v initial="$initial" 'length && $0 != initial && !found { print; found = 1 }')
[[ -n $selected ]] || fail "a second installed font is needed for the watcher test"
sleep 1
font_dir="$test_dir/home/.config/fontconfig/conf.d"
mkdir -p "$font_dir"
python3 - "$font_dir/50-omarchy-monospace.conf" "$selected" <<'PY'
from pathlib import Path
from xml.sax.saxutils import escape
import sys
Path(sys.argv[1]).write_text('<fontconfig><match target="pattern"><test name="family" qual="any"><string>monospace</string></test><edit name="family" mode="prepend_first" binding="strong"><string>' + escape(sys.argv[2]) + '</string></edit></match></fontconfig>')
PY
wait_family "$selected"
pass "the running Style singleton resolves first drop-in creation with initially missing parents"
