#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Bare Ctrl does not wake omarchy-screensaver via read -n1; scoped Control_L/R
# press binds must SIGHUP the screensaver while it is open (issue #10583).
# release=true on bare modifiers does not dispatch on Hyprland 0.56.2, so the
# binds use press + non_consuming instead.

utilities="$ROOT/default/hypr/bindings/utilities.lua"
screensaver="$ROOT/bin/omarchy-screensaver"

[[ -f $utilities ]] || fail "utilities bindings exist"
[[ -f $screensaver ]] || fail "screensaver helper exists"

# Screensaver only wakes on tty bytes or signals — document the gap.
grep -F 'read -n1' "$screensaver" >/dev/null ||
  fail "screensaver still uses read -n1 for tty wake"
grep -E 'trap exit_screensaver .*SIGHUP' "$screensaver" >/dev/null ||
  fail "screensaver traps SIGHUP for non-tty dismiss"
pass "screensaver traps SIGHUP for non-tty dismiss"

# Scoped binds: only while screensaver windows are open.
for needle in \
  'hl.on("window.open"' \
  'hl.on("window.close"' \
  'hl.on("window.destroy"' \
  'org.omarchy.screensaver' \
  'Control_L' \
  'Control_R' \
  'non_consuming = true' \
  "pkill -HUP -f '[o]rg.omarchy.screensaver'" \
  '#10583'; do
  grep -F "$needle" "$utilities" >/dev/null ||
    fail "utilities screensaver wake includes $needle"
done
pass "utilities binds Control_L/R press (non_consuming) to SIGHUP while screensaver is open"

# Must not rely on bare-modifier release binds (dead on Hyprland 0.56.2).
# Strip comments so the explanatory note about release=true cannot match.
code_only=$(grep -vE '^[[:space:]]*--' "$utilities" || true)
if grep -E 'Control_[LR].*release\s*=\s*true|release\s*=\s*true.*Control_[LR]' <<<"$code_only" >/dev/null; then
  fail "utilities must not use release=true on bare Control binds" "$code_only"
fi
pass "utilities does not use release=true on bare Control screensaver binds"

# Must not reintroduce global mouse wake (removed in v3.3.0 for BT mice).
if grep -E 'mouse:27[2-4]|mouse_move' <<<"$code_only" >/dev/null; then
  fail "utilities must not add global mouse screensaver wake" "$code_only"
fi
pass "utilities does not reintroduce global mouse screensaver wake"

# Counter discipline: bind only when the first screensaver opens, unbind at zero.
grep -F 'if screensaver_windows ~= 1 then' "$utilities" >/dev/null ||
  fail "screensaver wake binds only on the first open window"
grep -F 'if screensaver_windows ~= 0 then' "$utilities" >/dev/null ||
  fail "screensaver wake unbinds only when the last window is gone"
pass "screensaver wake bind lifetime tracks open screensaver windows"
