#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

for newer_options in false true; do
  OMARCHY_NEWER_OPTIONS="$newer_options" lua - <<'LUA' || fail "look and feel loads before and after a Hyprland upgrade"
local supported = os.getenv("OMARCHY_NEWER_OPTIONS") == "true"
local newer = { ["misc.bell_sound"] = "default", ["misc.startup_hold_layer"] = "", ["cursor.hide_at_startup"] = false }
local set = {}
hl = {
  get_config = function(key)
    assert(newer[key] ~= nil, key)
    if supported then return newer[key] end
    return nil, "unknown config key '" .. key .. "'"
  end,
  config = function(config)
    for section, options in pairs(config) do
      for option, value in pairs(options) do
        local key = section .. "." .. option
        assert(supported or newer[key] == nil, "unknown config key '" .. key .. "'")
        set[key] = value
      end
    end
  end,
  curve = function() end,
  animation = function() end,
}
dofile(os.getenv("ROOT") .. "/default/hypr/looknfeel.lua")
assert(set["misc.bell_sound"] == (supported and "none" or nil))
assert(set["misc.startup_hold_layer"] == (supported and "overlay:omarchy-background" or nil))
assert(set["cursor.hide_at_startup"] == (supported or nil))
LUA
done
pass "look and feel mutes bells, holds the splash's frame and hides the startup cursor only when the running compositor supports them"

run_application_bindings() {
  local home="$1"
  local prelude="${2:-}"

  OMARCHY_REGION_FILE="${OMARCHY_REGION_FILE:-$tmpdir/no-region}" HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_STATE_HOME="$home/.local/state" OMARCHY_PATH="$ROOT" OMARCHY_BINDING_PRELUDE="$prelude" lua - <<'LUA'
package.path = os.getenv("HOME") .. "/.config/?.lua;" .. os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local prelude = os.getenv("OMARCHY_BINDING_PRELUDE") or ""
if prelude ~= "" then
  assert(load(prelude))()
end

hl = {
  dsp = {
    exec_cmd = function(command)
      return { kind = "exec", arg = command }
    end,
  },
  bind = function(keys, dispatcher, opts)
    opts = opts or {}
    if opts.description then
      print(keys .. "\t" .. opts.description)
    end
  end,
}

require("default.hypr.helpers")
require("default.hypr.bindings.applications")
LUA
}

run_omarchy_bindings() {
  local home="$1"
  local prelude="${2:-}"

  OMARCHY_REGION_FILE="${OMARCHY_REGION_FILE:-$tmpdir/no-region}" HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_STATE_HOME="$home/.local/state" OMARCHY_PATH="$ROOT" OMARCHY_BINDING_PRELUDE="$prelude" lua - <<'LUA'
package.path = os.getenv("HOME") .. "/.config/?.lua;" .. os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

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

local prelude = os.getenv("OMARCHY_BINDING_PRELUDE") or ""
if prelude ~= "" then
  assert(load(prelude))()
end

hl = setmetatable({
  dsp = proxy(),
  bind = function(keys, dispatcher, opts)
    opts = opts or {}
    if opts.description then
      print(keys .. "\t" .. opts.description)
    end
  end,
  config = function() end,
  env = function() end,
  monitor = function() end,
  window_rule = function() end,
  workspace_rule = function() end,
  layer_rule = function() end,
  gesture = function() end,
  animation = function() end,
  curve = function() end,
  exec_cmd = function() end,
  dispatch = function() end,
  on = function() end,
  timer = function() end,
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
LUA
}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

fresh_home="$tmpdir/fresh-home"
mkdir -p "$fresh_home"
fresh_output=$(run_application_bindings "$fresh_home")
grep -Fq $'SUPER + RETURN	Terminal' <<<"$fresh_output" || fail "default application bindings include essentials"
grep -Fq $'SUPER + SHIFT + A	ChatGPT' <<<"$fresh_output" || fail "default application bindings include preinstalled web apps"
grep -Fq $'SUPER + SHIFT + Q	Calculator' <<<"$fresh_output" || fail "default application bindings include the preinstalled calculator"
grep -Fq $'XF86Calculator	Calculator' <<<"$fresh_output" || fail "default application bindings include the calculator hardware key"
pass "default application bindings load from package defaults"

removed_home="$tmpdir/removed-home"
mkdir -p "$removed_home/.local/state/omarchy"
touch "$removed_home/.local/state/omarchy/preinstalls-removed"
removed_output=$(run_omarchy_bindings "$removed_home")
grep -Fq $'SUPER + RETURN	Terminal' <<<"$removed_output" || fail "preinstall removal keeps essential bindings"
if grep -Fq $'SUPER + SHIFT + A	ChatGPT' <<<"$removed_output"; then
  fail "preinstall removal skips preinstalled web app bindings"
fi
if grep -Fq $'	Calculator' <<<"$removed_output"; then
  fail "preinstall removal skips calculator bindings"
fi
pass "preinstall removal flag skips optional application bindings"

variable_home="$tmpdir/variable-home"
mkdir -p "$variable_home"
variable_output=$(run_omarchy_bindings "$variable_home" 'omarchy_preinstalled_bindings = false')
grep -Fq $'SUPER + RETURN	Terminal' <<<"$variable_output" || fail "preinstalled binding variable keeps essential bindings"
if grep -Fq $'SUPER + SHIFT + A	ChatGPT' <<<"$variable_output"; then
  fail "preinstalled binding variable skips optional application bindings"
fi
if grep -Fq $'	Calculator' <<<"$variable_output"; then
  fail "preinstalled binding variable skips calculator bindings"
fi
pass "preinstalled binding variable skips optional application bindings"

echo cn >"$tmpdir/region-cn"
region_output=$(OMARCHY_REGION_FILE="$tmpdir/region-cn" run_application_bindings "$fresh_home")
grep -Fq $'SUPER + SHIFT + Q	Calculator' <<<"$region_output" || fail "a region keeps the hotkeys that aren't web apps"
grep -Fq $'SUPER + SHIFT + Y	Bilibili' <<<"$region_output" || fail "China binds its own web apps"
for binding in $'SUPER + SHIFT + A	ChatGPT' $'SUPER + SHIFT + E	Email' $'SUPER + SHIFT + Y	YouTube' $'SUPER + SHIFT + M	Music' $'SUPER + SHIFT + G	Signal'; do
  if grep -Fq "$binding" <<<"$region_output"; then fail "China binds none of the global web app hotkeys" "$binding"; fi
done
pass "the region picks its web app hotkeys file"

no_bindings_home="$tmpdir/no-bindings-home"
mkdir -p "$no_bindings_home"
no_bindings_output=$(run_omarchy_bindings "$no_bindings_home" 'omarchy_default_bindings = false') ||
  fail "default binding variable disables all Omarchy bindings"
[[ -z $no_bindings_output ]] || fail "default binding variable disables all Omarchy bindings" "$no_bindings_output"
pass "default binding variable disables all Omarchy bindings"

dictation_home="$tmpdir/dictation-home"
missing_bin="$tmpdir/missing-bin"
mkdir -p "$dictation_home/.config/omarchy/defaults" "$missing_bin"
ln -s "$(command -v lua)" "$missing_bin/lua"
ln -s "$(command -v lspci)" "$missing_bin/lspci"
ln -s "$(command -v sort)" "$missing_bin/sort"
dictation_output=$(PATH="$missing_bin" run_omarchy_bindings "$dictation_home") ||
  fail "unconfigured dictation leaves application shortcuts available"
if grep -Fq 'dictation' <<<"$dictation_output"; then fail "unconfigured dictation leaves application shortcuts available"; fi
printf 'future-backend\n' > "$dictation_home/.config/omarchy/defaults/dictation"
dictation_output=$(PATH="$missing_bin" run_omarchy_bindings "$dictation_home") ||
  fail "a selected backend that is not installed leaves application shortcuts available"
if grep -Fq 'dictation' <<<"$dictation_output"; then fail "a selected backend that is not installed leaves application shortcuts available"; fi
printf '#!/bin/bash\nexit 0\n' > "$missing_bin/future-backend"
chmod +x "$missing_bin/future-backend"
dictation_output=$(PATH="$missing_bin" run_omarchy_bindings "$dictation_home")
for binding in \
  $'ALT + SPACE\tToggle dictation' \
  $'ALT + Alt_R\tStart dictation (push-to-talk)' \
  $'ALT + Alt_R\tStop dictation (push-to-talk)'; do
  grep -Fq "$binding" <<<"$dictation_output" || fail "dictation bindings load for any selected backend" "$binding"
done
pass "dictation bindings require an installed selection without hardcoding backends"

# Lazydocker is optional on new installs, while existing installs keep the hotkey.
lazydocker_bin="$tmpdir/lazydocker-bin"
mkdir -p "$lazydocker_bin"
touch "$lazydocker_bin/lazydocker"
chmod +x "$lazydocker_bin/lazydocker"
lazydocker_output=$(PATH="$lazydocker_bin:$PATH" run_application_bindings "$fresh_home")
grep -Fqx $'SUPER + SHIFT + D\tDocker' <<<"$lazydocker_output" ||
  fail "installed Lazydocker keeps its Docker shortcut"
pass "installed Lazydocker keeps its Docker shortcut"

missing_lazydocker_output=$(PATH="$missing_bin" run_application_bindings "$fresh_home") ||
  fail "missing Lazydocker skips its Docker shortcut"
if grep -Fq $'SUPER + SHIFT + D\tDocker' <<<"$missing_lazydocker_output"; then
  fail "missing Lazydocker skips its Docker shortcut"
fi
pass "missing Lazydocker skips its Docker shortcut"

# The original scratchpad stays separate from the Quake console.
scratchpad_home="$tmpdir/scratchpad-home"
mkdir -p "$scratchpad_home"
scratchpad_output=$(run_omarchy_bindings "$scratchpad_home")
grep -Fqx $'SUPER + S	Toggle scratchpad' <<<"$scratchpad_output" ||
  fail "scratchpad keeps its existing toggle binding"
grep -Fqx $'SUPER + code:49	Toggle Quake console' <<<"$scratchpad_output" ||
  fail "Quake console has its own toggle binding"
grep -Fqx $'SUPER + ALT + S	Move window to scratchpad' <<<"$scratchpad_output" ||
  fail "scratchpad keeps its existing move binding"
grep -Fqx $'SUPER + SHIFT + code:49	Move window to Quake console' <<<"$scratchpad_output" ||
  fail "Quake console has its own move binding"
pass "scratchpad and Quake console have separate bindings"

# Hyprland matches a keysym bind against what a key types without Shift, so a
# bind on / moves to the key US types / on where / needs Shift, unless that key
# types a letter there instead: F on bépo, where it would take Super + F.
passwords_key() {
  local home="$tmpdir/layout-$1-$2"
  mkdir -p "$home/.config/omarchy"
  printf 'XKBLAYOUT=%s\nXKBVARIANT=%s\n' "$1" "$2" >"$home/.config/omarchy/keyboard-layouts"
  run_omarchy_bindings "$home" | awk -F '\t' '$2 == "Passwords" { print $1 }'
}
[[ $(passwords_key us "") == "SUPER + SHIFT + SLASH" ]] || fail "/ binds stay on / where it types without Shift" "$(passwords_key us "")"
[[ $(passwords_key dk "") == "SUPER + SHIFT + code:61" ]] || fail "/ binds move to the key left of right Shift where / needs Shift" "$(passwords_key dk "")"
[[ $(passwords_key fr bepo) == "SUPER + SHIFT + SLASH" ]] || fail "/ binds never move onto a letter" "$(passwords_key fr bepo)"
pass "/ binds follow the leading keyboard layout"

# The panel hotkeys claim a row of keys that workspace switching already uses
# under other modifiers, so the count matters as much as the bindings: a tenth
# claim on SUPER + CTRL + a number is a collision with one of these.
panels_home="$tmpdir/panels-home"
mkdir -p "$panels_home"
panels_output=$(run_omarchy_bindings "$panels_home")
for panel in 1 2 3 4 5 6 7 8 9; do
  grep -Fqx "SUPER + CTRL + code:$((panel + 9))"$'\t'"Bar panel $panel" <<<"$panels_output" ||
    fail "bar panel hotkeys count the right section" "$panel"
done
number_claims=$(cut -f1 <<<"$panels_output" | grep -cE '^SUPER \+ CTRL \+ code:1[0-9]$' || true)
(( number_claims == 9 )) ||
  fail "only the bar panel hotkeys bind SUPER + CTRL + a number" "$number_claims"
pass "bar panel hotkeys bind SUPER + CTRL + a number without a collision"

# Native Linux Steam games keep their own window class instead of
# steam_app_<appid>, so steam.lua detects them from SteamGameId in
# /proc/<pid>/environ on window.open and starts them fullscreen.
# Use Lua's own PID (with SteamGameId set) and this shell's PID (without it)
# so we read real /proc/<pid>/environ files with no background processes.
unset SteamGameId SteamAppId
HOME="$fresh_home" OMARCHY_PATH="$ROOT" SteamGameId=239820 PLAIN_APP_PID="$$" lua - <<'LUA' || fail "native Steam games fullscreen on open while dialogs and non-Steam apps do not"
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local handlers, dispatches = {}, {}
hl = {
  window_rule = function() end,
  on = function(event, fn) handlers[event] = fn end,
  dispatch = function(cmd) table.insert(dispatches, cmd) end,
  dsp = {
    window = {
      tag = function(spec) return { kind = "tag", tag = spec.tag, window = spec.window } end,
      fullscreen = function(spec) return { kind = "fullscreen", mode = spec.mode, action = spec.action, window = spec.window } end,
    },
  },
}
require("default.hypr.helpers")
require("default.hypr.apps.steam")
local on_open = assert(handlers["window.open"], "steam.lua did not subscribe to window.open")
local stat = assert(io.open("/proc/self/stat", "r"))
local game_pid = tonumber(stat:read("*a"):match("^(%d+)"))
stat:close()
local plain_pid = tonumber(os.getenv("PLAIN_APP_PID"))

local function check(win)
  dispatches = {}
  on_open(win)
  return dispatches
end

local native = check({ class = "Gamedevtycoon64-bin", pid = game_pid, floating = false, fullscreen = 0, tags = {} })
assert(#native == 2 and native[1].kind == "tag" and native[1].tag == "+steam-game", "native game not tagged")
assert(native[2].kind == "fullscreen" and native[2].mode == "fullscreen" and native[2].action == "set", "native game not fullscreened")

local on_float_ws = check({ class = "Gamedevtycoon64-bin", pid = game_pid, floating = true, fullscreen = 0, tags = { "omarchy-mode-opened*" } })
assert(#on_float_ws == 2 and on_float_ws[2].kind == "fullscreen", "native game on floating workspace not fullscreened")

assert(#check({ class = "Gamedevtycoon64-bin", pid = game_pid, floating = true, fullscreen = 0, tags = {} }) == 0, "floating game dialog should stay floating")
assert(#check({ class = "google-chrome", pid = game_pid, floating = false, fullscreen = 0, tags = { "chromium-based-browser*" } }) == 0, "browser launched from a game should be ignored")
assert(#check({ class = "foot", pid = game_pid, floating = false, fullscreen = 0, tags = { "terminal*" } }) == 0, "terminal launched from a game should be ignored")
assert(#check({ class = "steam", pid = game_pid, floating = false, fullscreen = 0, tags = {} }) == 0, "steam client should be ignored")
assert(#check({ class = "steam_app_battlenet", pid = game_pid, floating = false, fullscreen = 0, tags = {} }) == 0, "battle.net should be ignored")
assert(#check({ class = "foot", pid = plain_pid, floating = false, fullscreen = 0, tags = {} }) == 0, "non-Steam window should be ignored")
LUA
pass "native Linux Steam games fullscreen on open without affecting dialogs or other apps"
