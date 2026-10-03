#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

clipboard="$ROOT/default/hypr/bindings/clipboard.lua"

grep -F 'active_window_wants_app_copy' "$clipboard" >/dev/null ||
  fail "universal copy detects Codex-style app clipboard handlers"
grep -F 'haystack:find("codex"' "$clipboard" >/dev/null ||
  fail "universal copy matches Codex in the focused window class or title"
grep -F 'if active_window_wants_app_copy() then' "$clipboard" >/dev/null ||
  fail "universal copy prefers Ctrl+C when Codex is focused"
grep -F 'o.bind("SUPER + C", "Universal copy", universal_clipboard_shortcut("CTRL", "C", "CTRL", "Insert"))' \
  "$clipboard" >/dev/null ||
  fail "Super+C still uses Ctrl+C outside terminals and Ctrl+Insert in terminals"
pass "universal copy sends Ctrl+C for Codex instead of the terminal clipboard chord"
