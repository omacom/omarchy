#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "popup card anchor loss test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping popup card anchor loss test"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

cp "$SHELL_TEST_DIR/fixtures/popup-card-anchor-loss/shell.qml" "$test_tmp/shell.qml"
ln -s "$ROOT/shell/Ui" "$test_tmp/Ui"
ln -s "$ROOT/shell/Commons" "$test_tmp/Commons"

output=$(OMARCHY_PATH="$ROOT" timeout 15 quickshell -p "$test_tmp" --no-color 2>&1) || {
  printf '%s\n' "$output" >&2
  fail "popup card anchor loss fixture exits cleanly"
}

if grep -q "RESULT skip" <<<"$output"; then
  skip "$(sed -n 's/.*RESULT skip //p' <<<"$output")"
  exit 0
fi

if ! grep -q "RESULT pass" <<<"$output"; then
  printf '%s\n' "$output" >&2
  fail "a closing popup card stays hidden when its anchor leaves the window"
fi

pass "a closing popup card stays hidden when its anchor leaves the window"
