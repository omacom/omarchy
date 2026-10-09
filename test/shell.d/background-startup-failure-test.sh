#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
require_compositor "failed background startup"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/bin" "$stage/home/.local/state/omarchy/current"
printf 'not an image\n' >"$stage/broken.png"
ln -s "$stage/broken.png" "$stage/home/.local/state/omarchy/current/background"
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

# Past the fixture's own 12 s backstop, so its failure message is what reports a hang.
output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" timeout 14 quickshell -p "$stage" --no-color 2>&1) || fail "failed background startup exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "an unreadable wallpaper reveals the desktop within the startup deadline" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Unable to assign|Binding loop' <<<"$output"; then
  fail "failed background startup has no QML errors" "$output"
fi
pass "an unreadable wallpaper reveals the desktop within the startup deadline"
