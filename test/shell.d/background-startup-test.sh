#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "background startup test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/services" "$stage/bin" "$stage/home/.local/state/omarchy/current"
printf 'P6\n1 1\n255\n\377\000\377' >"$stage/still.ppm"
ln -s "$stage/still.ppm" "$stage/home/.local/state/omarchy/current/background"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$ROOT/shell/services/BackgroundIntro.qml" "$stage/services/"
cp "$SHELL_TEST_DIR/fixtures/background-startup/shell.qml" "$stage/shell.qml"
cat >"$stage/bin/omarchy-theme-bg-boot-intro" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stage/bin/omarchy-theme-bg-boot-intro"
cat >"$stage/bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "eval" ]]; then
  printf '%s\n' "$*" >>"$STARTUP_CURSOR_LOG"
else
  /usr/bin/hyprctl "$@"
fi
SH
chmod +x "$stage/bin/hyprctl"
: >"$stage/cursor.log"
output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" STARTUP_CURSOR_LOG="$stage/cursor.log" timeout 6 quickshell -p "$stage" --no-color 2>&1) || fail "background startup fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "the wallpaper restores before background plugin loading" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "background startup fixture has no QML errors" "$output"
fi
pass "fresh startup hides the desktop until both the background and bar are ready"
pass "the startup cursor stays hidden until the desktop begins fading in"
