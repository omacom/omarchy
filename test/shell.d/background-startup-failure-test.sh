#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
require_compositor "failed background startup"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/bin" "$stage/home/.local/state/omarchy/current"
ln -s "$stage/deleted.png" "$stage/home/.local/state/omarchy/current/background"
for component in Commons Ui services; do
  ln -s "$ROOT/shell/$component" "$stage/$component"
done
ln -s "$ROOT/shell/plugins/background" "$stage/background"
cp "$SHELL_TEST_DIR/fixtures/background-startup-failure/shell.qml" "$stage/shell.qml"
cat >"$stage/bin/omarchy-theme-bg-boot-intro" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stage/bin/omarchy-theme-bg-boot-intro"

output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" timeout 13 quickshell -p "$stage" --no-color 2>&1) || fail "failed background startup exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "a missing wallpaper reveals the desktop within the startup deadline" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Unable to assign|Binding loop' <<<"$output"; then
  fail "failed background startup has no QML errors" "$output"
fi
pass "a missing wallpaper reveals the desktop within the startup deadline"
