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

  HOME="$home" XDG_CONFIG_HOME="$home/.config" OMARCHY_PATH="$ROOT" \
    TEST_KEYS="$keys" TEST_CLASS="$class" TEST_TAGS="$tags" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local real_open = io.open
io.open = function(path, mode)
  if path == "/etc/vconsole.conf" then
    local file = io.tmpfile()
    file:write("XKBLAYOUT=jp\n")
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

require("default.hypr.bindings.jis")

local bind = binds[os.getenv("TEST_KEYS")]
if bind.options.non_consuming then
  print("non_consuming")
end
bind.dispatcher()
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
prefix="CTRL + SPACE"
freed=$'[Hotkey/TriggerKeys]\n0=Zenkaku_Hankaku\n\n[Hotkey/ActivateKeys]\n0=Henkan'
TEST_FCITX5_CONFIG=$freed assert_fires "the terminal prefix switches to direct input once Ctrl + Space no longer toggles" \
  $'non_consuming\nexec fcitx5-remote -c' "$prefix" "com.mitchellh.ghostty" "terminal*"
TEST_FCITX5_CONFIG=$freed assert_fires "the prefix leaves input alone outside terminals" \
  "non_consuming" "$prefix" "chromium" "browser"

# While fcitx5 still toggles on Ctrl + Space, switching to direct input would
# undo the toggle it just made.
assert_fires "the prefix leaves input alone without an fcitx5 config" \
  "non_consuming" "$prefix" "com.mitchellh.ghostty" "terminal*"
TEST_FCITX5_CONFIG=$'[Behavior]\nShareInputState=No' assert_fires "the prefix leaves input alone with the default trigger keys" \
  "non_consuming" "$prefix" "com.mitchellh.ghostty" "terminal*"
TEST_FCITX5_CONFIG=$'[Hotkey/TriggerKeys]\n0=Zenkaku_Hankaku\n1=Control+space' assert_fires "the prefix leaves input alone while Ctrl + Space is a trigger key" \
  "non_consuming" "$prefix" "com.mitchellh.ghostty" "terminal*"
