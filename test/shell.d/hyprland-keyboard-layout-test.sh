#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua
require_command xkbcli

resolved_input_for() {
  local module="$1"
  OMARCHY_PATH="$ROOT" OMARCHY_MODULE="$module" OMARCHY_VCONSOLE="${2-}" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local vconsole = os.getenv("OMARCHY_VCONSOLE")
local real_open = io.open

io.open = function(path, mode)
  if path:match("/omarchy/keyboard%-layouts$") then
    local selected = os.getenv("TEST_KEYBOARD_SELECTION")
    if not selected then return nil end
    local file = io.tmpfile()
    file:write(selected)
    file:seek("set")
    return file
  end

  if path == "/etc/omarchy/input-method" then
    local preference = os.getenv("TEST_INPUT_PREFERENCE")
    if not preference then return nil end
    local file = io.tmpfile()
    file:write(preference)
    file:seek("set")
    return file
  end

  if path ~= "/etc/vconsole.conf" then
    return real_open(path, mode)
  end

  -- An unset OMARCHY_VCONSOLE reaches Lua as "", never nil, so the cases that
  -- ask for a missing /etc/vconsole.conf need the empty string to fail the open.
  if not vconsole or vconsole == "" then
    return nil
  end

  local file = io.tmpfile()
  file:write(vconsole)
  file:seek("set")
  return file
end

hl = {
  config = function(config)
    local input = config.input
    print(("[%s] [%s] [%s]"):format(input.kb_layout, input.kb_variant, input.kb_options))
  end,
}

o = { window = function() end }

require(os.getenv("OMARCHY_MODULE"))
LUA
}

resolved_input() {
  resolved_input_for "default.hypr.input" "${1-}"
}

# The greeter compositor resolves the layout from its own entrypoint.
resolved_greeter_input() {
  resolved_input_for "default.sddm.hyprland" "${1-}"
}

assert_resolved_input() {
  local resolver="$1"
  local description="$2"
  local expected="$3"
  local actual

  if (( $# > 3 )); then
    actual=$("$resolver" "$4")
  else
    actual=$("$resolver")
  fi

  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

assert_input() {
  assert_resolved_input resolved_input "$@"
}

assert_greeter_input() {
  assert_resolved_input resolved_greeter_input "$@"
}

base_options="omarchy:shift_caps_compose"
toggle_options="$base_options,grp:alts_toggle"

assert_input "missing vconsole.conf falls back to us" "[us] [] [$base_options]"

assert_input "us layout passes through" "[us] [intl] [$base_options]" 'XKBLAYOUT=us
XKBVARIANT=intl
'

assert_input "latin layouts are left alone" "[de] [nodeadkeys] [$base_options]" 'XKBLAYOUT=de
XKBVARIANT=nodeadkeys
'

assert_input "non-latin layout gains us in front" "[us,ara] [,] [$toggle_options]" 'XKBLAYOUT=ara
'

assert_input "prepended us keeps variants aligned" "[us,ru] [,phonetic] [$toggle_options]" 'XKBLAYOUT=ru
XKBVARIANT=phonetic
'
assert_input "non-latin layout in front moves a trailing us to the front" "[us,il] [,] [$toggle_options]" 'XKBLAYOUT=il,us
'
assert_input "a trailing us is not duplicated, so the toggle has one stop per layout" "[us,ru] [,] [$toggle_options]" 'XKBLAYOUT=ru,us
'
assert_input "moving us keeps every layout paired with its variant" "[us,ru] [intl,phonetic] [$toggle_options]" 'XKBLAYOUT=ru,us
XKBVARIANT=phonetic,intl
'
assert_input "a third layout keeps its place and variant" "[us,ua,de] [,,nodeadkeys] [$toggle_options]" 'XKBLAYOUT=ua,us,de
XKBVARIANT=,,nodeadkeys
'
assert_input "a us variant that can't type latin still gets a plain us in front" "[us,ru,us] [,,rus] [$toggle_options]" 'XKBLAYOUT=ru,us
XKBVARIANT=,rus
'

caps=$(xkbcli compile-keymap --include "$ROOT/etc/xkb" --include-defaults --layout us,ru --options omarchy:shift_caps_compose | grep -A5 'key <CAPS>')
[[ $caps == *"Caps_Lock,"*"Multi_key ]"* && $caps == *"LockMods(modifiers=Lock),"*"NoAction() ]"* ]] ||
  fail "Shift + Caps Lock composes without toggling Caps Lock" "$caps"
pass "Shift + Caps Lock composes without toggling Caps Lock"

# The greeter takes no compose or capslock options: they're session comfort
# settings with nothing to do with typing a password.
assert_greeter_input "greeter falls back to us without vconsole.conf" "[us] [] []"

assert_greeter_input "greeter follows the system layout" "[fr] [] []" 'XKBLAYOUT=fr
'

assert_greeter_input "greeter keeps a latin layout in front" "[us,ru] [,phonetic] [grp:alts_toggle]" 'XKBLAYOUT=ru
XKBVARIANT=phonetic
'

assert_greeter_input "greeter moves a trailing us and its variant to the front" "[us,ru] [intl,phonetic] [grp:alts_toggle]" 'XKBLAYOUT=ru,us
XKBVARIANT=phonetic,intl
'

assert_greeter_input "greeter keeps later layouts and variants aligned" "[us,ua,de] [,,nodeadkeys] [grp:alts_toggle]" 'XKBLAYOUT=ua,us,de
XKBVARIANT=,,nodeadkeys
'

assert_greeter_input "greeter keeps a plain us in front of a cherokee us" "[us,ru,us] [,,chr] [grp:alts_toggle]" 'XKBLAYOUT=ru,us
XKBVARIANT=,chr
'

hooks_conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
input_lua="$ROOT/default/hypr/input.lua"

hooks_layouts=$(awk -F')' '/\) ;;$/ { gsub(/[[:space:]|]+/, "\n", $1); print $1 }' "$hooks_conf" | grep '^[a-z]\+$' | sort)
lua_layouts=$(sed -n '/^local non_latin_layouts =/,+1p' "$input_lua" | grep -o '"[^"]*"' | tr -d '"' | tr ' ' '\n' | grep '^[a-z]\+$' | sort)

[[ -n $hooks_layouts ]] || fail "non-latin layout list is readable from omarchy_hooks.conf"

[[ $hooks_layouts == "$lua_layouts" ]] ||
  fail "non-latin layout lists stay in sync" "$(diff <(echo "$hooks_layouts") <(echo "$lua_layouts"))"
pass "non-latin layout lists stay in sync with the initramfs hook"

sddm_lua="$ROOT/default/sddm/hyprland.lua"
sddm_layouts=$(sed -n '/^local non_latin_layouts =/,+1p' "$sddm_lua" | grep -o '"[^"]*"' | tr -d '"' | tr ' ' '\n' | grep '^[a-z]\+$' | sort)

[[ $hooks_layouts == "$sddm_layouts" ]] ||
  fail "greeter non-latin layout list stays in sync" "$(diff <(echo "$hooks_layouts") <(echo "$sddm_layouts"))"
pass "greeter non-latin layout list stays in sync with the initramfs hook"

TEST_INPUT_PREFERENCE=$'INPUT_METHOD=hangul\n XKB_LAYOUT="kr" # desktop only\n' assert_input "Korean selection overrides its installer US layout" "[kr] [] [$base_options]" $'XKBLAYOUT=us\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=hangul\nXKB_LAYOUT=kr:kr104\n' assert_input "Korean Right Alt selection maps 한/영 and 한자 to Right Alt and Right Ctrl" "[kr] [kr104] [$base_options]" $'XKBLAYOUT=us\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=none\nXKB_LAYOUT=la\n' assert_input "Lao selection gets Lao behind US on the desktop" "[us,la] [,] [$toggle_options]" $'XKBLAYOUT=us\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=none\nXKB_LAYOUT=xx\n' assert_input "an unknown desktop override is ignored" "[us] [] [$base_options]" $'XKBLAYOUT=us\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=hangul\nXKB_LAYOUT=kr\n' assert_input "a later US variant overrides the Korean preference" "[us] [intl] [$base_options]" $'XKBLAYOUT=us\nXKBVARIANT=intl\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=hangul\nXKB_LAYOUT=kr\n' assert_input "a later layout overrides the Korean preference" "[de] [nodeadkeys] [$base_options]" $'XKBLAYOUT=de\nXKBVARIANT=nodeadkeys\n'

TEST_KEYBOARD_SELECTION=$'XKBLAYOUT=us,fr\nXKBVARIANT=intl,\n' assert_input "menu selections replace installer desktop defaults" "[us,fr] [intl,] [$base_options]" $'XKBLAYOUT=jp\n'
TEST_KEYBOARD_SELECTION=$'XKBLAYOUT=us,fr\nXKBVARIANT=intl,\n' assert_greeter_input "menu selections leave the greeter keyboard unchanged" "[jp] [] []" $'XKBLAYOUT=jp\n'

TEST_KEYBOARD_SELECTION=$'XKBLAYOUT=us,ru\nXKBVARIANT=,phonetic\n' assert_input "saved non-Latin selections retain the layout shortcut" "[us,ru] [,phonetic] [$toggle_options]" $'XKBLAYOUT=us\n'
