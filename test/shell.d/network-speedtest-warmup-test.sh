#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
require_compositor "network speed test warm-up"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/bin"
for component in Commons Ui services; do
  ln -s "$ROOT/shell/$component" "$stage/$component"
done
ln -s "$ROOT/shell/plugins/panels/speedtest" "$stage/speedtest"
cp "$SHELL_TEST_DIR/fixtures/network-speedtest-warmup/shell.qml" "$stage/shell.qml"
cat >"$stage/bin/omarchy-network-speedtest" <<'SH'
#!/bin/bash
sleep 5.5
while true; do
  echo 42
  sleep 1
done
SH
chmod +x "$stage/bin/omarchy-network-speedtest"

output=$(PATH="$stage/bin:$PATH" timeout 16 quickshell -p "$stage" --no-color 2>&1) || fail "network speed test warm-up exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "the speed test measures from the first sample, not from launch" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Unable to assign|Binding loop' <<<"$output"; then
  fail "network speed test warm-up has no QML errors" "$output"
fi
pass "the speed test measures from the first sample, not from launch"
