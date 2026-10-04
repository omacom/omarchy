#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "nightlight resume runtime test"
require_command quickshell

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

cp "$SHELL_TEST_DIR/fixtures/nightlight-resume/shell.qml" "$test_tmp/shell.qml"
mkdir "$test_tmp/Nightlight"
cp "$ROOT/shell/plugins/services/nightlight/NightlightModel.js" "$test_tmp/Nightlight/"
# Keep the real QML timers and scheduling code, replacing only the wall clock.
sed 's/Date.now()/root.shell.now/g' "$ROOT/shell/plugins/services/nightlight/Service.qml" >"$test_tmp/Nightlight/Service.qml"

output=$(timeout 15 quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "nightlight resume fixture exits cleanly"
}

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "sunset mode restores the correct temperature after sleep"
fi

pass "sunset mode restores the correct temperature after sleep"
