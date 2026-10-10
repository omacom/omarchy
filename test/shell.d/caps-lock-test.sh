#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin" "$work/state"
cat >"$work/bin/hyprctl" <<'STUB'
#!/bin/bash
[[ $* == reload ]] || exit 1
exit "${RELOAD_EXIT:-0}"
STUB
chmod +x "$work/bin/hyprctl"
export PATH="$work/bin:$PATH" XDG_STATE_HOME="$work/state" OMARCHY_PATH="$ROOT"

apply() {
  INPUT_OPTIONS="$1" EXPECTED_OPTIONS="$2" lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local result = os.getenv("INPUT_OPTIONS")
hl = {
  get_config = function(name)
    assert(name == "input.kb_options")
    return result
  end,
  config = function(value) result = value.input.kb_options end,
}
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/caps-lock.lua")
assert(result == os.getenv("EXPECTED_OPTIONS"), result)
LUA
}

original='compose:caps,shift:both_capslock_cancel,grp:alts_toggle,lv3:ralt_switch'
apply "$original" "$original"
pass "no preference leaves the configured behaviour untouched"

"$ROOT/bin/omarchy-setup-caps-lock" normal
apply "$original" 'grp:alts_toggle,lv3:ralt_switch,caps:capslock'
apply 'ctrl:nocaps,compose:rctrl,grp:caps_toggle' 'compose:rctrl,caps:capslock'
apply 'caps:escape,grp:alt_shift_toggle' 'grp:alt_shift_toggle,caps:capslock'
apply '' 'caps:capslock'
pass "normal Caps Lock removes conflicting remaps but preserves AltGr and other Compose keys"

apply "$original" 'grp:alts_toggle,lv3:ralt_switch,caps:capslock'
pass "a fresh config load reapplies the saved preference"

"$ROOT/bin/omarchy-setup-caps-lock" compose
apply "$original" 'grp:alts_toggle,lv3:ralt_switch,compose:caps'
pass "Compose mode preserves layout switching without assigning Lock to Shift"

if "$ROOT/bin/omarchy-setup-caps-lock" invalid 2>/dev/null; then
  fail "invalid arguments are rejected"
fi
[[ $(cat "$work/state/omarchy/caps-lock") == compose ]] || fail "invalid arguments leave the preference intact"
pass "invalid arguments do not mutate state"

"$ROOT/bin/omarchy-setup-caps-lock" reset
apply "$original" "$original"
"$ROOT/bin/omarchy-setup-caps-lock" reset
pass "reset restores configuration and is idempotent"

printf '%s\n' 'unknown' >"$work/state/omarchy/caps-lock"
apply "$original" "$original"
pass "invalid stored data is ignored"

if RELOAD_EXIT=1 "$ROOT/bin/omarchy-setup-caps-lock" normal; then
  fail "reload failure is reported"
fi
[[ $(cat "$work/state/omarchy/caps-lock") == normal ]] || fail "preference remains available for next login"
pass "reload failure is reported while retaining the preference for next login"
