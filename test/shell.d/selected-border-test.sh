#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping selected border runtime tests"
  exit 0
fi

fixture_dir=$(mktemp -d)
trap 'rm -rf "$fixture_dir"' EXIT
mkdir -p "$fixture_dir/home"
export XDG_CONFIG_HOME="$fixture_dir/home/.config"
export XDG_DATA_HOME="$fixture_dir/home/.local/share"
export XDG_STATE_HOME="$fixture_dir/home/.local/state"
export XDG_CACHE_HOME="$fixture_dir/home/.cache"
ln -s "$ROOT/shell/Ui" "$fixture_dir/Ui"
ln -s "$ROOT/shell/Commons" "$fixture_dir/Commons"
cp "$SHELL_TEST_DIR/fixtures/selected-border/shell.qml" "$fixture_dir/shell.qml"
ulimit -c 0 2>/dev/null || true

output=$(HOME="$fixture_dir/home" OMARCHY_PATH="$ROOT" QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software timeout 15 quickshell -p "$fixture_dir" --no-color 2>&1) ||
  fail "selected border runtime fixture exits cleanly" "$output"

if [[ $output == *"RESULT fail"* ]] || [[ $output != *"RESULT pass hover precedence"* ]]; then
  fail "selected controls preserve normal borders and dedicated selected styling" "$output"
fi

pass "selected controls preserve normal, borderless, gradient and per-side styling; cursor keeps hover precedence"
