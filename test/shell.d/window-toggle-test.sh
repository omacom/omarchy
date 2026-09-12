#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# Fake hyprctl: logs dispatches; lua-layer first arg fails so the fallback runs.
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf 'hyprctl:%s\n' "$*" >>"$OMARCHY_TEST_HYPR_LOG"
[[ $1 == "dispatch" && $2 == hl.dsp* ]] && exit 1
exit 0
SH
chmod +x "$mock_bin/hyprctl"

export PATH="$mock_bin:$PATH"
export OMARCHY_TEST_HYPR_LOG="$test_tmp/hypr-log"
toggle="$ROOT/bin/omarchy-hyprland-window-toggle"

: >"$OMARCHY_TEST_HYPR_LOG"
"$toggle" float
grep -Fq 'hyprctl:dispatch togglefloating' "$OMARCHY_TEST_HYPR_LOG" ||
  fail "window toggle floats via fallback dispatcher" "$(cat "$OMARCHY_TEST_HYPR_LOG")"
pass "window toggle floats via fallback dispatcher"

: >"$OMARCHY_TEST_HYPR_LOG"
"$toggle" fullscreen
grep -Fq 'hyprctl:dispatch fullscreen 0' "$OMARCHY_TEST_HYPR_LOG" ||
  fail "window toggle fullscreen dispatches" "$(cat "$OMARCHY_TEST_HYPR_LOG")"
pass "window toggle fullscreen dispatches"

: >"$OMARCHY_TEST_HYPR_LOG"
"$toggle" maximized
grep -Fq 'hyprctl:dispatch fullscreenstate 0 2' "$OMARCHY_TEST_HYPR_LOG" ||
  fail "window toggle maximized dispatches" "$(cat "$OMARCHY_TEST_HYPR_LOG")"
pass "window toggle maximized dispatches"

"$toggle" bogus >/dev/null 2>&1 &&
  fail "window toggle exits non-zero on unknown target"
pass "window toggle exits non-zero on unknown target"

"$toggle" --help >/dev/null 2>&1 || fail "window toggle --help succeeds"
pass "window toggle --help succeeds"

grep -Fq '"trigger.window.float"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "window float row exists in the default menu"
pass "window float row exists in the default menu"
