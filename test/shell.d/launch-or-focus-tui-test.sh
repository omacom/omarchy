#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-launch-or-focus" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >"$OMARCHY_TEST_FOCUS_PATTERN"
SH
chmod +x "$mock_bin"/*

pattern_log="$test_tmp/pattern"

focus_pattern() {
  PATH="$mock_bin:$PATH" OMARCHY_TEST_FOCUS_PATTERN="$pattern_log" \
    bash "$ROOT/bin/omarchy-launch-or-focus-tui" "$@"
  cat "$pattern_log"
}

[[ $(focus_pattern btop) == "org.omarchy.btop" ]] || fail "single-word TUI focuses its own app id"
[[ $(focus_pattern "zsh -c 'fastfetch; read -k 1'") == "org.omarchy.zsh" ]] || fail "TUI command string focuses the app id launch-tui derives from its first word"
[[ $(focus_pattern /usr/bin/btop) == "org.omarchy.btop" ]] || fail "TUI path focuses the app id of its basename"
[[ $(focus_pattern "'btop' --help") == "org.omarchy.btop" ]] || fail "single-quoted first word focuses the unquoted app id"
[[ $(focus_pattern '"btop" --help') == "org.omarchy.btop" ]] || fail "double-quoted first word focuses the unquoted app id"
[[ $(focus_pattern --app-id=org.omarchy.about omarchy-launch-about --render) == "org.omarchy.about" ]] || fail "explicit app id is used as the focus pattern"

pass "launch-or-focus-tui focuses the app id launch-tui sets"
