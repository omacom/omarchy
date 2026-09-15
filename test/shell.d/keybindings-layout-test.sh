#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command xkbcli
require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin" "$tmpdir/home"
# Direct compiler/parser checks must be as isolated as the menu subprocesses.
export HOME="$tmpdir/home" XDG_CONFIG_HOME="$tmpdir/home/.config"
unset XKB_CONFIG_ROOT XKB_CONFIG_EXTRA_PATH XKB_DEFAULT_RULES XKB_DEFAULT_MODEL
unset XKB_DEFAULT_LAYOUT XKB_DEFAULT_VARIANT XKB_DEFAULT_OPTIONS
cat >"$tmpdir/bin/hyprctl" <<'STUB'
#!/bin/bash
case "$*" in
  '-j devices') cat "$FIXTURES/devices.json"; [[ ! -e $FIXTURES/device-failure ]] ;;
  binds)
    code=21
    [[ ! -e $FIXTURES/code ]] || read -r code <"$FIXTURES/code"
    printf 'bind\n\tmodmask: 65\n\tkey: code:%s\n\tkeycode: %s\n\tdescription: Physical key\n\tdispatcher: exec\n\targ: true\n' "$code" "$code" ;;
  *) exit 1 ;;
esac
STUB
chmod +x "$tmpdir/bin/hyprctl"

keyboard() {
  jq -n --arg layout "$1" --argjson index "$2" '{keyboards: [{main: true, rules: "evdev", model: "pc105", layout: $layout, variant: "", options: "", active_layout_index: $index}]}' >"$tmpdir/devices.json"
}

render() {
  env -i PATH="$tmpdir/bin:$ROOT/bin:$PATH" HOME="$tmpdir/home" \
    XDG_CACHE_HOME="$tmpdir/cache" OMARCHY_PATH="$ROOT" FIXTURES="$tmpdir" \
    bash "$ROOT/bin/omarchy-menu-keybindings" --print
}

keyboard be 0
rendered=$(render)
[[ $rendered == *'SUPER SHIFT + MINUS '* ]] || fail "physical key uses the active layout base symbol" "$rendered"
pass "physical key uses the active layout base symbol"

keyboard us,be 1
rendered=$(render)
[[ $rendered == *'SUPER SHIFT + MINUS '* ]] || fail "second layout group uses its base symbol" "$rendered"
keyboard us,be 0
rendered=$(render)
[[ $rendered == *'SUPER SHIFT + EQUAL '* ]] || fail "switching group invalidates cached labels" "$rendered"
pass "layout groups resolve independently and invalidate cached labels"

# Load functions without the menu entry point to check the record boundary.
source <(awk '/^if \[\[ \$1 ==/ { exit } { print }' "$ROOT/bin/omarchy-menu-keybindings")
KEYBINDINGS_GROUP=1
KEYBINDINGS_KEYMAP=$(xkbcli compile-keymap --layout be --options '')
record='SUPER,equal,Literal code:21,exec,printf code:21,mouse:272'
[[ $(parse_keycodes <<<"$record") == "$record" ]] || fail "symbol bindings and dispatch payloads are untouched"
record='SUPER,code:21,Literal code:21,exec,printf code:21,mouse:272'
[[ $(parse_keycodes <<<"$record") == 'SUPER,MINUS,Literal code:21,exec,printf code:21,mouse:272' ]] || fail "only the physical key field is translated"
pass "only physical key labels change, never symbol bindings or dispatch payloads"

rewrite_devices() {
  jq "$1" "$tmpdir/devices.json" >"$tmpdir/next.json"
  mv "$tmpdir/next.json" "$tmpdir/devices.json"
}

expect_key() {
  local rendered
  rendered=$(render)
  [[ $rendered == *"SUPER SHIFT + $1 "* ]] || fail "$2" "$rendered"
  pass "$2"
}

# Synthetic device metadata includes a real group name and unset R/M values.
keyboard be,us 0
rewrite_devices '.keyboards[0] += {rules:"", model:"", active_keymap:"Belgian"}'
expect_key MINUS "matching active keymap names ignore XKB type level names with empty rules/model"
rewrite_devices '.keyboards[0] += {active_layout_index:1, active_keymap:"English (US)"}'
expect_key EQUAL "matching active keymap names select the second group"

keyboard de 0
expect_key DEAD_ACUTE "German base symbol is not its shifted level"
keyboard fr 0
expect_key EQUAL "French layout resolves independently"
keyboard us 0
rewrite_devices '.keyboards[0].variant = "dvorak"'
expect_key BRACKETRIGHT "variant changes invalidate cached labels"
keyboard us,us 1
rewrite_devices '.keyboards[0].variant = ",dvorak"'
expect_key BRACKETRIGHT "empty positional variants and repeated layouts retain group order"

keyboard be 0
rewrite_devices '.keyboards = [{main:false, layout:"us", active_layout_index:0}] + .keyboards'
expect_key MINUS "main keyboard wins over the first device"
rewrite_devices '.keyboards |= reverse'
expect_key MINUS "device enumeration order does not change the selected map"
rewrite_devices '.keyboards[0].main = false | .keyboards[1].main = true'
expect_key EQUAL "main keyboard changes invalidate cached labels"
rewrite_devices '.keyboards[].main = false'
expect_key code:21 "ambiguous devices do not silently choose US"
keyboard be 0
rewrite_devices 'del(.keyboards[0].main, .keyboards[0].active_layout_index)'
expect_key MINUS "a sole single-layout keyboard needs no index or main flag"

for index in -1 2 0.5 '"unknown"' null false; do
  keyboard us,be "$index"
  expect_key code:21 "invalid or missing multi-layout index $index stays physical"
done
keyboard us 0
rewrite_devices '.keyboards[0].active_layout_index = false'
expect_key code:21 "a malformed single-layout index must not be coerced to zero"

printf '{broken json\n' >"$tmpdir/devices.json"
expect_key code:21 "malformed device JSON stays physical"
printf '{"keyboards":[]}\n' >"$tmpdir/devices.json"
expect_key code:21 "no keyboard stays physical"
keyboard nonexistent_layout 0
expect_key code:21 "compilation failure stays physical without US fallback"
keyboard be 0
expect_key MINUS "a successful retry replaces unresolved labels"

KEYBINDINGS_KEYMAP=''
for code in 21 9999; do
  record="SUPER,code:$code,Action,exec,true"
  [[ $(parse_keycodes <<<"$record") == "$record" ]] || fail "unknown keycodes stay visible"
done
[[ $(parse_keycodes <<<'SUPER,mouse:272,Action,exec,true') == 'SUPER,LEFT MOUSE BUTTON,Action,exec,true' ]] || fail "mouse labels survive unavailable keymaps"
pass "unknown keycodes and mouse bindings survive unavailable keymaps"

keyboard us 0
rewrite_devices '.keyboards[0].active_keymap = "Unreconstructable custom map"'
expect_key code:21 "a reported keymap name that disagrees with RMLVO stays physical"

keyboard us 0
touch "$tmpdir/device-failure"
expect_key code:21 "failed device queries cannot reuse a successful response or cache"
rm "$tmpdir/device-failure"

printf '9\n' >"$tmpdir/code"
keyboard us 0
expect_key ESCAPE "default options resolve the escape key"
rewrite_devices '.keyboards[0].options = "caps:swapescape"'
expect_key CAPS_LOCK "keyboard options affect labels and invalidate the cache"
rm "$tmpdir/code"

# Exercise the compiler failure boundary and cache invalidation independently
# of device metadata. Only synthetic keymaps/argument logs enter these fixtures.
real_xkbcli=$(type -P xkbcli)
printf '%s\n' "$real_xkbcli" >"$tmpdir/real-xkbcli"
cat >"$tmpdir/bin/xkbcli" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" >"$FIXTURES/compiler-args"
if [[ -e $FIXTURES/compiled-map ]]; then
  cat "$FIXTURES/compiled-map"
else
  read -r compiler <"$FIXTURES/real-xkbcli"
  "$compiler" "$@"
fi
[[ ! -e $FIXTURES/compiler-failure ]]
STUB
chmod +x "$tmpdir/bin/xkbcli"
keyboard us 0
rewrite_devices '.keyboards[0].model = "pc104" | .keyboards[0].options = "caps:swapescape"'
expect_key EQUAL "non-default models compile successfully"
expected_args=$'compile-keymap\n--rules\nevdev\n--model\npc104\n--layout\nus\n--variant\n\n--options\ncaps:swapescape'
[[ $(<"$tmpdir/compiler-args") == "$expected_args" ]] || fail "all RMLVO values are passed as separate literal arguments"
pass "all RMLVO values are passed as separate literal arguments"

"$real_xkbcli" compile-keymap --layout be --options '' >"$tmpdir/compiled-map"
expect_key MINUS "changed compiled map invalidates cache even with unchanged device metadata"
touch "$tmpdir/compiler-failure"
expect_key code:21 "partial compiler output on failure must not become a label"
rm "$tmpdir/compiler-failure"
expect_key MINUS "compiler recovery cannot reuse failed results"
: >"$tmpdir/compiled-map"
expect_key code:21 "empty compiler output stays physical"
rm "$tmpdir/compiled-map" "$tmpdir/bin/xkbcli"

# Both generations of xkbcli syntax, shared groups, key-local wrapping and
# unrepresentable multi-symbol levels are checked without a live compositor.
KEYBINDINGS_KEYMAP='xkb_keycodes "test" {
  <AE12> = 21;
};
xkb_symbols "test" {
  key <AE12> {
    symbols[Group1] = [ equal, plus ],
    symbols[Group2] = [ minus, underscore ]
  };
};'
for pair in 1:EQUAL 2:MINUS 3:EQUAL; do
  KEYBINDINGS_GROUP=${pair%:*}
  [[ $(parse_keycodes <<<'SHIFT,code:21,Action,exec,true') == "SHIFT,${pair#*:},Action,exec,true" ]] || fail "explicit groups and per-key wrapping resolve base symbols"
done
pass "explicit groups and per-key wrapping resolve base symbols"
base_keymap=$KEYBINDINGS_KEYMAP
KEYBINDINGS_GROUP=3
KEYBINDINGS_KEYMAP=${base_keymap/'key <AE12> {'/'key <AE12> { groupsClamp;'}
[[ $(parse_keycodes <<<'SHIFT,code:21,Action,exec,true') == 'SHIFT,MINUS,Action,exec,true' ]] || fail "key-local group clamping is honored"
KEYBINDINGS_GROUP=4
KEYBINDINGS_KEYMAP=${base_keymap/'key <AE12> {'/'key <AE12> { groupsRedirect=Group1;'}
[[ $(parse_keycodes <<<'SHIFT,code:21,Action,exec,true') == 'SHIFT,EQUAL,Action,exec,true' ]] || fail "key-local group redirection is honored"
KEYBINDINGS_GROUP=1
KEYBINDINGS_KEYMAP=${base_keymap/equal/NoSymbol}
[[ $(parse_keycodes <<<'SHIFT,code:21,Action,exec,true') == 'SHIFT,code:21,Action,exec,true' ]] || fail "NoSymbol is not displayed as a key label"
pass "group clamping, redirection and NoSymbol are handled"
KEYBINDINGS_GROUP=1
KEYBINDINGS_KEYMAP='xkb_keycodes "test" {
  <AE12> = 21;
};
xkb_symbols "test" {
  key <AE12> { [ { a, b }, c ] };
};'
[[ $(parse_keycodes <<<'SHIFT,code:21,Action,exec,true') == 'SHIFT,code:21,Action,exec,true' ]] || fail "unsupported multi-symbol levels stay physical"
pass "unsupported multi-symbol levels stay physical"

KEYBINDINGS_KEYMAP=$(xkbcli compile-keymap --layout us --options '')
[[ $(parse_keycodes <<<'SUPER,code:122,Action,exec,true') == 'SUPER,XF86AUDIOLOWERVOLUME,Action,exec,true' ]] || fail "XKB key names with punctuation resolve media keys"
pass "XKB key names with punctuation resolve media keys"
