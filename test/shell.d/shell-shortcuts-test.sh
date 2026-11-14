#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

shortcuts="$ROOT/default/omarchy/shortcuts"

# Load the helpers and every default binding against a stub hl, and print one
# line per binding: "global <name>" for a global shortcut, "exec <command>" for
# a command, then its description.
list_bindings() {
  HOME="$(mktemp -d)" OMARCHY_PATH="$ROOT" lua - <<'LUA'
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

hl = setmetatable({
  dsp = dsp,
  bind = function(keys, dispatcher, opts)
    local kind, target = "other", ""
    if type(dispatcher) == "table" and dispatcher.global then
      kind, target = "global", dispatcher.global
    elseif type(dispatcher) == "table" and dispatcher.exec then
      kind, target = "exec", dispatcher.exec
    end
    print(kind .. "\t" .. target .. "\t" .. ((opts or {}).description or ""))
  end,
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
LUA
}

bindings=$(list_bindings)

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

# Exercise real XKB resolution: a non-Latin group must not turn clipboard
# injection into an active-group keysym lookup, nor pin other layouts to US.
require_command xkbcli
OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "clipboard injection uses primary-layout keys with paired releases"
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local binds, events, pending = {}, {}, nil
local window
local config = { ["input.kb_layout"] = "us,il" }
hl = {
  get_config = function(key) return config[key] end,
  get_active_window = function() return window end,
  dsp = { send_key_state = function(spec) return spec end },
  dispatch = function(spec) events[#events + 1] = spec end,
  timer = function(callback, options)
    assert(options.timeout == 50 and options.type == "oneshot")
    pending = callback
  end,
}
require("default.hypr.helpers")
o.bind = function(keys, _, callback) binds[keys] = callback end
require("default.hypr.bindings.clipboard")
local function check(callback, mods, code)
  events, pending = {}, nil
  callback()
  assert(#events == 1 and pending, "release must be deferred")
  -- A layout change while the key is down must still release the same key.
  local layout = config["input.kb_layout"]
  config["input.kb_layout"] = "fr,il"
  pending()
  config["input.kb_layout"] = layout
  assert(#events == 2)
  for i, state in ipairs({ "down", "up" }) do
    local event = events[i]
    assert(event.mods == mods and event.key == "code:" .. code and event.state == state,
      ("expected %s code:%s %s, got %s %s %s"):format(mods, code, state, event.mods, event.key, event.state))
    assert(event.window == nil, "injection must reach the focused surface")
  end
end
for _, tags in ipairs({ {}, { "terminal" }, { "terminal*" } }) do
  window = { tags = tags }
  local clipboard_mods = #tags > 0 and "CTRL SHIFT" or "CTRL"
  check(binds["SUPER + A"], "CTRL", 38)
  check(binds["SUPER + C"], clipboard_mods, 54)
  check(binds["SUPER + V"], clipboard_mods, 55)
  check(binds["SUPER + X"], "CTRL", 53)
  check(o.universal_paste, clipboard_mods, 55)
end
window = nil
check(o.universal_paste, "CTRL", 55)
config["input.kb_layout"] = "us,il"
config["input.kb_variant"] = "dvorak,"
check(binds["SUPER + C"], "CTRL", 31)
check(binds["SUPER + V"], "CTRL", 60)
config["input.kb_layout"], config["input.kb_variant"] = "fr,il", ""
check(binds["SUPER + A"], "CTRL", 24)
config["input.kb_layout"], config["input.kb_variant"] = "us", "3l"
check(binds["SUPER + A"], "CTRL", 41)
LUA
pass "clipboard injection uses primary-layout keys with paired releases"
