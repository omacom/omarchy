#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua
require_command xkbcli

resolved_input_for() {
  local module="$1"
  OMARCHY_PATH="$ROOT" OMARCHY_MODULE="$module" OMARCHY_VCONSOLE="${2-}" lua - <<'LUA'
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
  get_config = function() end,
  on = function() end,
}

o = { window = function() end }

require(os.getenv("OMARCHY_MODULE"))
LUA
}

resolved_input() {
  resolved_input_for "default.hypr.input" "${1-}"
}

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# The greeter compositor takes the layouts default/splash/greeter exports from
# default/splash/layouts, with the greeter's own export reading a fixture.
greeter_vconsole=$test_tmp/vconsole.conf
sed -n '/^while IFS=/,/^done/p' "$ROOT/default/splash/greeter" |
  sed -e "s|/etc/vconsole.conf|$greeter_vconsole|" -e "s|/usr/share/omarchy|$ROOT|" >"$test_tmp/greeter-layouts.sh"
grep -qF "$ROOT/default/splash/layouts $greeter_vconsole" "$test_tmp/greeter-layouts.sh" ||
  fail "the greeter's layouts are read from the fixture" "$(cat "$test_tmp/greeter-layouts.sh")"

resolved_greeter_input() (
  printf '%s' "${1-}" >"$greeter_vconsole"
  . "$test_tmp/greeter-layouts.sh"
  resolved_input_for "default.splash.greeter"
)

assert_resolved_input() {
  local resolver="$1"
  local description="$2"
  local expected="$3"
  local actual

  if (( $# > 3 )); then
    actual=$("$resolver" "$4") || fail "$description" "$actual"
  else
    actual=$("$resolver") || fail "$description" "$actual"
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
# settings with nothing to do with typing a password. Nor a layout shortcut:
# the screen's keyboard switches (default/splash/layouts orders the layouts,
# test/shell.d/boot-splash-layouts-test.sh).
assert_greeter_input "greeter starts a non-Latin layout in US, without a layout shortcut" "[us,ru] [,phonetic] []" 'XKBLAYOUT=ru
XKBVARIANT=phonetic
XKBOPTIONS=grp:alts_toggle
'

hooks_conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
input_lua="$ROOT/default/hypr/input.lua"

hooks_layouts=$(awk -F')' '/\) ;;$/ { gsub(/[[:space:]|]+/, "\n", $1); print $1 }' "$hooks_conf" | grep '^[a-z]\+$' | sort)
lua_layouts=$(sed -n '/^local non_latin_layouts =/,+1p' "$input_lua" | grep -o '"[^"]*"' | tr -d '"' | tr ' ' '\n' | grep '^[a-z]\+$' | sort)

[[ -n $hooks_layouts ]] || fail "non-latin layout list is readable from omarchy_hooks.conf"

[[ $hooks_layouts == "$lua_layouts" ]] ||
  fail "non-latin layout lists stay in sync" "$(diff <(echo "$hooks_layouts") <(echo "$lua_layouts"))"
pass "non-latin layout lists stay in sync with the initramfs hook"

kmscon_sh="$ROOT/install/provisioning/kmscon.sh"
kmscon_layouts=$(sed -n '/^omarchy_keymap_xkb() {/,/^}/p' "$kmscon_sh" | awk -F')' '/ \| ua\)$/ { gsub(/[[:space:]|]+/, "\n", $1); print $1 }' | grep '^[a-z]\+$' | sort)

[[ $hooks_layouts == "$kmscon_layouts" ]] ||
  fail "kmscon non-latin layout list stays in sync" "$(diff <(echo "$hooks_layouts") <(echo "$kmscon_layouts"))"
pass "kmscon non-latin layout list stays in sync with the initramfs hook"

TEST_INPUT_PREFERENCE=$'INPUT_METHOD=hangul\n XKB_LAYOUT="kr" # desktop only\n' assert_input "Korean selection overrides its installer US layout" "[kr] [] [$base_options]" $'XKBLAYOUT=us\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=hangul\nXKB_LAYOUT=kr:kr104\n' assert_input "Korean Right Alt selection maps 한/영 and 한자 to Right Alt and Right Ctrl" "[kr] [kr104] [$base_options]" $'XKBLAYOUT=us\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=none\nXKB_LAYOUT=la\n' assert_input "Lao selection gets Lao behind US on the desktop" "[us,la] [,] [$toggle_options]" $'XKBLAYOUT=us\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=none\nXKB_LAYOUT=xx\n' assert_input "an unknown desktop override is ignored" "[us] [] [$base_options]" $'XKBLAYOUT=us\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=hangul\nXKB_LAYOUT=kr\n' assert_input "a later US variant overrides the Korean preference" "[us] [intl] [$base_options]" $'XKBLAYOUT=us\nXKBVARIANT=intl\n'
TEST_INPUT_PREFERENCE=$'INPUT_METHOD=hangul\nXKB_LAYOUT=kr\n' assert_input "a later layout overrides the Korean preference" "[de] [nodeadkeys] [$base_options]" $'XKBLAYOUT=de\nXKBVARIANT=nodeadkeys\n'

TEST_KEYBOARD_SELECTION=$'XKBLAYOUT=us,fr\nXKBVARIANT=intl,\n' assert_input "menu selections replace installer desktop defaults" "[us,fr] [intl,] [$base_options]" $'XKBLAYOUT=jp\n'

TEST_KEYBOARD_SELECTION=$'XKBLAYOUT=us,ru\nXKBVARIANT=,phonetic\n' assert_input "saved non-Latin selections retain the layout shortcut" "[us,ru] [,phonetic] [$toggle_options]" $'XKBLAYOUT=us\n'

altgr_calls=$(OMARCHY_PATH="$ROOT" lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local real_open = io.open
io.open = function(path, mode)
  if path:match("/omarchy/keyboard%-layouts$") then
    local f = io.tmpfile(); f:write("XKBLAYOUT=de,de\nXKBVARIANT=nodeadkeys,nodeadkeys\n"); f:seek("set"); return f
  elseif path:match("/fcitx5/profile$") then
    local f = io.tmpfile(); f:write("[Groups/0/Items/0]\nName=keyboard-de-nodeadkeys\n"); f:seek("set"); return f
  end
  return real_open(path, mode)
end
local seen_cmd
io.popen = function(cmd)
  seen_cmd = cmd
  return { read = function() return "key <RALT> { [ ISO_Level3_Shift ] };" end, close = function() end }
end
local keyboard = require("default.hypr.keyboard")
assert(keyboard.altgr(), "AltGr layout is detected")
local _, count = seen_cmd:gsub("xkbcli compile%-keymap", "")
print(count)
LUA
)
[[ $altgr_calls == "1" ]] || fail "keyboard.altgr deduplicates identical layouts across Hyprland and Fcitx" "got $altgr_calls calls"
pass "keyboard.altgr deduplicates identical layouts across Hyprland and Fcitx"
