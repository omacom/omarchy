#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua
require_command xkbcli

shortcuts="$ROOT/default/omarchy/shortcuts"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Load the helpers and every default binding against a stub hl, and print one
# line per binding: "global <name>" for a global shortcut, "exec <command>" for
# a command, then its description.
list_bindings() {
  HOME="$tmpdir" OMARCHY_PATH="$ROOT" lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

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

local dsp = proxy()
rawset(dsp, "global", function(name) return { global = name } end)
rawset(dsp, "exec_cmd", function(command) return { exec = command } end)
rawset(dsp, "send_key_state", function(spec) return spec end)

local bindings, events, timer = {}, {}, nil
local active_window = { tags = {} }
local config = {
  ["input.kb_layout"] = "us,th",
  ["input.kb_variant"] = "",
  ["input.kb_options"] = "omarchy:shift_caps_compose,grp:alts_toggle",
}

hl = setmetatable({
  dsp = dsp,
  bind = function(keys, dispatcher, opts)
    bindings[keys] = dispatcher
    local kind, target = "other", ""
    if type(dispatcher) == "table" and dispatcher.global then
      kind, target = "global", dispatcher.global
    elseif type(dispatcher) == "table" and dispatcher.exec then
      kind, target = "exec", dispatcher.exec
    end
    print(kind .. "\t" .. target .. "\t" .. ((opts or {}).description or ""))
  end,
  dispatch = function(dispatcher) table.insert(events, dispatcher) end,
  get_active_window = function() return active_window end,
  get_config = function(key) return config[key] end,
  timer = function(callback, opts) timer = { callback = callback, opts = opts } end,
}, {
  __index = function()
    return function() return {} end
  end,
})

require("default.hypr.helpers")

o.bind("A", "listed menu", { menu = "theme" })
o.bind("B", "unlisted menu", { menu = "setup.power" })
o.bind("C", "listed panel", { panel = "omarchy.emojis" })
o.bind("D", "unlisted panel", { panel = "omarchy.wifiqr" })
o.bind("E", "listed audio", { audio = "raise" })
o.bind("F", "unlisted audio", { audio = "+1" })
o.bind("I", "listed brightness", { brightness = "raise" })
o.bind("G", "listed ipc", { ipc = "media.next" })
o.bind("H", "unlisted ipc", { ipc = "media.sourceNext" })

for _, file in ipairs({ "utilities", "clipboard", "media" }) do
  dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bindings/" .. file .. ".lua")
end

-- Fire the real callbacks without sending keys to a compositor. xkbcli only
-- compiles keymaps; it proves the code:N values use XKB, not evdev, numbering.
local function expect_shortcut(action, key, mods)
  events, timer = {}, nil
  local description = type(action) == "string" and action or "universal paste"
  if type(action) == "string" then
    bindings[action]()
  else
    action()
  end

  local function expect_event(index, state)
    local event = events[index]
    assert(event and event.state == state and event.mods == mods and event.key == key,
      description .. ": expected " .. state .. " " .. mods .. " " .. key)
  end
  assert(#events == 1, description .. ": release must wait for the timer")
  expect_event(1, "down")
  assert(timer and timer.opts.timeout == 50 and timer.opts.type == "oneshot",
    description .. ": release uses a 50 ms oneshot timer")
  timer.callback()
  assert(#events == 2, description .. ": releases exactly once")
  expect_event(2, "up")
end

for letter, code in pairs({ A = 38, C = 54, V = 55, X = 53 }) do
  expect_shortcut("SUPER + " .. letter, "code:" .. code, "CTRL")
end
expect_shortcut(o.universal_paste, "code:55", "CTRL")
for _, tag in ipairs({ "terminal", "terminal*" }) do
  active_window = { tags = { tag } }
  expect_shortcut("SUPER + C", "code:54", "CTRL SHIFT")
  expect_shortcut("SUPER + V", "code:55", "CTRL SHIFT")
  expect_shortcut(o.universal_paste, "code:55", "CTRL SHIFT")
end
active_window = nil -- A focused layer-shell surface has no active window.
expect_shortcut(o.universal_paste, "code:55", "CTRL")
active_window = { tags = {} }

-- Reusing the same bindings also checks that changing the keymap invalidates
-- the lookup cache. A primary non-QWERTY layout must keep its logical letters.
for _, keymap in ipairs({
  { "us,ru", "dvorak,", { C = 31, V = 60, X = 56 } },
  { "us", "colemak_dh", { C = 53, V = 55, X = 52 } },
  { "fr,ru", ",", { A = 24 } },
  { "us", "3l", { A = 41 } }, -- Ignore A on a higher level of another key.
}) do
  config["input.kb_layout"], config["input.kb_variant"] = keymap[1], keymap[2]
  for letter, code in pairs(keymap[3]) do
    expect_shortcut("SUPER + " .. letter, "code:" .. code, "CTRL")
  end
  if keymap[2] == "dvorak," then
    active_window = { tags = { "terminal*" } }
    expect_shortcut("SUPER + C", "code:31", "CTRL SHIFT")
    expect_shortcut("SUPER + V", "code:60", "CTRL SHIFT")
    active_window = { tags = {} }
  end
end

config["input.kb_file"] = "/fixture/custom.xkb"
expect_shortcut("SUPER + C", "C", "CTRL")
expect_shortcut("SUPER + V", "V", "CTRL")
config["input.kb_file"] = nil
config["input.kb_layout"], config["input.kb_variant"] = "omarchy_nonexistent_test_layout", ""
for _, letter in ipairs({ "C", "V", "X" }) do
  expect_shortcut("SUPER + " .. letter, letter, "CTRL")
end
LUA
}

bindings=$(list_bindings)
pass "clipboard bindings preserve logical keys, terminal chords and timed release"

expect_binding() {
  local expected="$1"
  local message="$2"
  grep -Fxq "$expected" <<<"$bindings" || fail "$message: $(grep -F "$(cut -f3 <<<"$expected")" <<<"$bindings")"
}

expect_binding $'global\tomarchy:menu.theme\tlisted menu' "a listed menu route binds its global shortcut"
expect_binding $'exec\tomarchy-menu toggle \'setup.power\'\tunlisted menu' "an unlisted menu route falls back to the command"
expect_binding $'global\tomarchy:panel.omarchy.emojis\tlisted panel' "a listed panel binds its global shortcut"
expect_binding $'exec\tomarchy-shell shell toggle \'omarchy.wifiqr\'\tunlisted panel' "an unlisted panel falls back to the command"
expect_binding $'global\tomarchy:audio.raise\tlisted audio' "a listed volume key binds its global shortcut"
expect_binding $'exec\tomarchy-audio-output-volume \'+1\'\tunlisted audio' "an unlisted volume step falls back to the script"
expect_binding $'global\tomarchy:brightness.raise\tlisted brightness' "a listed brightness key binds its global shortcut"
expect_binding $'global\tomarchy:ipc.media.next\tlisted ipc' "a listed IPC call binds its global shortcut"
expect_binding $'exec\tomarchy-shell \'media\' \'sourceNext\'\tunlisted ipc' "an unlisted IPC call falls back to omarchy-shell"
pass "shell bindings use global shortcuts only for what the shell registers"

# Every default binding that toggles a listed route or panel goes through its
# shortcut, and none toggles one through a command any more.
! grep -E $'^exec\t(omarchy-menu toggle|omarchy-shell shell toggle) ' <<<"$bindings" | grep -v $'\tunlisted ' ||
  fail "default bindings toggle menus and panels through global shortcuts"
# The helper quotes the fallback's arguments, so this matches the form it writes.
! grep -E $'^exec\tomarchy-shell \'media\' ' <<<"$bindings" | grep -v $'\tunlisted ' ||
  fail "default media keys reach the media service through global shortcuts"
pass "default bindings reach menus, panels and the media service through global shortcuts"

# The shell and the helpers both read this list, so every line is a kind and a target.
while IFS= read -r line; do
  [[ -z $line || $line == \#* ]] && continue
  [[ $line =~ ^(menu|panel|audio|brightness|ipc)\ [^[:space:]]+$ ]] || fail "shortcuts lines are a kind and a target: $line"
  if [[ $line == ipc\ * ]]; then
    [[ $line =~ ^ipc\ (media|notifications)\.[A-Za-z]+$ ]] || fail "ipc shortcuts name a mapped target and method: $line"
  fi
done <"$shortcuts"
pass "shortcuts lines name a kind and a target"

# Every default menu binding target is a real menu route.
run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const entries = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const items = {}
const order = []
for (const entry of entries) { items[entry.id] = entry; order.push(entry.id) }
items.root = items.root || { id: 'root' }

const lines = fs.readFileSync(path.join(root, 'default/omarchy/shortcuts'), 'utf8').split('\n')
for (const line of lines) {
  const match = /^menu (\S+)$/.exec(line)
  if (!match) continue
  const route = match[1]
  assert(route === 'root' || items[menu.resolveRoute(items, order, route)], `shortcut menu route resolves: ${route}`)
}
JS
pass "every shortcut menu route resolves in the menu"
