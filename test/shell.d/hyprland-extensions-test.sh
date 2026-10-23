#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Load Omarchy's Hyprland defaults the way hyprland.lua does, logging each bind
# and unbind in order, then the user's bindings.lua after them.
load_config() {
  local home="$1"
  local config_home="${2:-$home/.config}"

  HOME="$home" XDG_CONFIG_HOME="$config_home" XDG_STATE_HOME="$home/.local/state" OMARCHY_PATH="$ROOT" lua 2>&1 <<'LUA'
package.path = os.getenv("XDG_CONFIG_HOME") .. "/?.lua;" .. os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local function proxy()
  return setmetatable({}, {
    __index = function(self, key)
      local value = proxy()
      rawset(self, key, value)
      return value
    end,
    __call = function()
      return {}
    end,
  })
end

hl = setmetatable({
  dsp = proxy(),
  bind = function(keys, dispatcher, opts)
    print("bind\t" .. keys .. "\t" .. ((opts or {}).description or ""))
  end,
  unbind = function(keys)
    print("unbind\t" .. keys)
  end,
  notification = {
    create = function(notification)
      print("notify\t" .. notification.icon .. "\t" .. notification.text)
    end,
  },
  get_config = function() return nil end,
  get_active_window = function() return nil end,
}, {
  __index = function()
    return function()
      return {}
    end
  end,
})

require("default.hypr.omarchy")
require("default.hypr.require_optional").module("hypr.bindings")
LUA
}

line_of() {
  grep -nxF "$2" <<<"$1" | head -n 1 | cut -d: -f1
}

# Without an extensions folder, the defaults load as before.
bare_home="$tmpdir/bare-home"
mkdir -p "$bare_home"
bare_output=$(load_config "$bare_home") || fail "defaults load without an extensions folder" "$bare_output"
grep -q $'^bind\tSUPER + W\t' <<<"$bare_output" || fail "defaults load without an extensions folder" "$bare_output"
if grep -q 'Hyprland extension' <<<"$bare_output"; then
  fail "a missing extensions folder is not an error" "$bare_output"
fi
pass "defaults load without an extensions folder"

home="$tmpdir/home"
extensions="$home/.config/hypr/extensions"
addon="$tmpdir/addon"
mkdir -p "$extensions" "$addon"

cat >"$extensions/b-rebind.lua" <<'LUA'
o.rebind("SUPER + W", "Extension close", "true")
LUA
cat >"$extensions/a-first.lua" <<'LUA'
o.bind("SUPER + F12", "Extension first", "true")
LUA
cat >"$extensions/c-broken.lua" <<'LUA'
error("boom")
LUA
cat >"$addon/linked.lua" <<'LUA'
o.bind("SUPER + F11", "Extension linked", "true")
LUA
ln -s "$addon/linked.lua" "$extensions/d-linked.lua"
ln -s "$addon/removed.lua" "$extensions/e-dangling.lua"
echo 'o.bind("SUPER + F10", "Not Lua", "true")' >"$extensions/notes.txt"
mkdir -p "$extensions/nested"
echo 'o.bind("SUPER + F9", "Nested", "true")' >"$extensions/nested/deep.lua"
cat >"$home/.config/hypr/bindings.lua" <<'LUA'
o.rebind("SUPER + W", "User close", "true")
LUA

output=$(load_config "$home") || fail "a config with extensions loads" "$output"

first=$(line_of "$output" $'bind\tSUPER + F12\tExtension first')
rebind=$(line_of "$output" $'bind\tSUPER + W\tExtension close')
linked=$(line_of "$output" $'bind\tSUPER + F11\tExtension linked')
[[ -n $first && -n $rebind && -n $linked ]] || fail "extensions load, symlinked ones included" "$output"
(( first < rebind && rebind < linked )) || fail "extensions load in name order" "$output"
pass "extensions load in name order, symlinked ones included"

default_close=$(line_of "$output" $'bind\tSUPER + W\tClose window')
[[ -n $default_close ]] || fail "the default SUPER + W binding is still bound first" "$output"
(( default_close < rebind )) || fail "extensions load after Omarchy's default bindings" "$output"
pass "extensions load after Omarchy's default bindings, so they can rebind them"

user_close=$(line_of "$output" $'bind\tSUPER + W\tUser close')
[[ -n $user_close ]] && (( rebind < user_close )) || fail "the user's bindings load after extensions" "$output"
pass "the user's bindings still override extensions"

grep -q $'^notify\terror\tCould not load Hyprland extension .*c-broken.lua: .*boom' <<<"$output" ||
  fail "a broken extension is reported" "$output"
pass "a broken extension is shown as an error and the rest still load"

if grep -Eq 'Not Lua|Nested' <<<"$output"; then
  fail "only top-level *.lua files load as extensions" "$output"
fi
if grep -q 'e-dangling' <<<"$output"; then
  fail "a dangling symlink is skipped silently" "$output"
fi
pass "only top-level *.lua files load, and a dangling symlink is skipped"

# The folder follows XDG_CONFIG_HOME, like the rest of the user config.
xdg_home="$tmpdir/xdg-home"
xdg_config="$tmpdir/xdg-config"
mkdir -p "$xdg_home" "$xdg_config/hypr/extensions"
echo 'o.bind("SUPER + F8", "XDG extension", "true")' >"$xdg_config/hypr/extensions/xdg.lua"
xdg_output=$(load_config "$xdg_home" "$xdg_config") || fail "extensions load from XDG_CONFIG_HOME" "$xdg_output"
grep -qxF $'bind\tSUPER + F8\tXDG extension' <<<"$xdg_output" || fail "extensions load from XDG_CONFIG_HOME" "$xdg_output"
pass "extensions follow XDG_CONFIG_HOME"

# Turning off Omarchy's default bindings doesn't turn off extensions.
grep -q 'require("default.hypr.extensions")' "$ROOT/default/hypr/omarchy.lua" ||
  fail "omarchy.lua loads extensions"
if awk '/omarchy_default_bindings ~= false/,/^end$/' "$ROOT/default/hypr/omarchy.lua" | grep -q 'extensions'; then
  fail "extensions load outside the default bindings switch"
fi
pass "extensions load even with Omarchy's default bindings off"
