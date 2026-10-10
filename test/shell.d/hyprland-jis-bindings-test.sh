#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

# Load the JIS bindings on a jp layout and fire one of them in a fake window,
# printing what it hands to Hyprland. TEST_FCITX5_CONFIG is the fcitx5 config,
# or unset for none.
fire() {
  local keys="$1" class="$2" tags="${3-}"
  local home="$test_dir/home"

  rm -rf "$home"
  mkdir -p "$home/.config/fcitx5"
  if [[ -v TEST_FCITX5_CONFIG ]]; then
    printf '%s\n' "$TEST_FCITX5_CONFIG" >"$home/.config/fcitx5/config"
  fi

  if [[ ${TEST_KEYBOARD_ONLY:-false} == "true" ]]; then
    printf '[Groups/0/Items/0]\nName=keyboard-us\n' > "$home/.config/fcitx5/profile"
  else
    printf '[Groups/0/Items/0]\nName=keyboard-us\n[Groups/0/Items/1]\nName=mozc\n' > "$home/.config/fcitx5/profile"
  fi

  HOME="$home" XDG_CONFIG_HOME="$home/.config" OMARCHY_PATH="$ROOT" \
    TEST_KEYS="$keys" TEST_CLASS="$class" TEST_TAGS="$tags" TEST_LAYOUT="${TEST_LAYOUT:-jp}" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local real_open = io.open
io.open = function(path, mode)
  if path == "/etc/vconsole.conf" then
    local file = io.tmpfile()
    file:write("XKBLAYOUT=" .. os.getenv("TEST_LAYOUT") .. "\n")
    file:seek("set")
    return file
  end

  return real_open(path, mode)
end

local binds = {}
o = {
  bind = function(keys, description, dispatcher, options)
    binds[keys] = { dispatcher = dispatcher, options = options or {} }
  end,
}

local window = { class = os.getenv("TEST_CLASS"), tags = {} }
for tag in os.getenv("TEST_TAGS"):gmatch("[^,]+") do
  table.insert(window.tags, tag)
end

hl = {
  dsp = {
    send_key_state = function(key)
      return ("send %s %s %s"):format(key.mods, key.key, key.state)
    end,
  },
  dispatch = function(action) print(action) end,
  timer = function(callback) callback() end,
  get_active_window = function() return window end,
  exec_cmd = function(command) print("exec " .. command) end,
}

o.shell_succeeds = function(command) print("exec " .. command) end

require("default.hypr.bindings.input-method")
require("default.hypr.bindings.jis")

local bind = binds[os.getenv("TEST_KEYS")]
if bind.options.non_consuming then
  print("non_consuming")
end
if type(bind.dispatcher) == "string" then
  print("exec " .. bind.dispatcher)
else
  bind.dispatcher()
end
LUA
}

assert_fires() {
  local description="$1" expected="$2"
  shift 2
  local actual

  actual=$(fire "$@")
  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

zoom="CTRL + SHIFT + semicolon"
assert_fires "the JIS + key zooms in with Ctrl + keypad plus" \
  $'send CTRL KP_Add down\nsend CTRL KP_Add up' "$zoom" "chromium"
assert_fires "the JIS + key zooms in windows without a class" \
  $'send CTRL KP_Add down\nsend CTRL KP_Add up' "$zoom" ""
assert_fires "the JIS + key zooms Obsidian in with Ctrl + ^" \
  $'send CTRL asciicircum down\nsend CTRL asciicircum up' "$zoom" "obsidian"
assert_fires "the JIS + key zooms the Obsidian Flatpak in with Ctrl + ^" \
  $'send CTRL asciicircum down\nsend CTRL asciicircum up' "$zoom" "md.obsidian.Obsidian"

# The prefix bind has to pass Ctrl + Space on, or tmux and Herdr never see it.
# Fcitx never toggles on it (configure --defaults removes it from its keys), so
# a terminal can always return to direct input first.
prefix="CTRL + SPACE"
direct=$'non_consuming\nexec timeout 0.3 fcitx5-remote --check -c'
assert_fires "the terminal prefix switches to direct input" "$direct" "$prefix" "com.mitchellh.ghostty" "terminal*"
assert_fires "the prefix leaves input alone outside terminals" "non_consuming" "$prefix" "chromium" "browser"
for layout in us kr; do
  TEST_LAYOUT="$layout" assert_fires "the terminal prefix works with $layout keyboards too" "$direct" "$prefix" "foot" "terminal"
done
TEST_KEYBOARD_ONLY=true assert_fires "keyboard-only profiles use the same prefix bind" "$direct" "$prefix" "foot" "terminal"

assert_fires "Super + I cycles configured input independently of custom Fcitx keys" \
  "exec omarchy-input-method cycle" "SUPER + I" "chromium"
assert_fires "Super + Shift + I cycles configured input back" \
  "exec omarchy-input-method cycle back" "SUPER + SHIFT + I" "chromium"
TEST_KEYBOARD_ONLY=true assert_fires "Super + I cycles keyboard layouts without an input engine" \
  "exec omarchy-input-method cycle" "SUPER + I" "foot" "terminal"
