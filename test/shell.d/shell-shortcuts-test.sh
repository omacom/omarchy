#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

shortcuts="$ROOT/default/omarchy/shortcuts"

# Load the helpers and every default binding against a stub hl, and print one
# line per binding: "global <name>" for a global shortcut, "exec <command>" for
# a command, then its description.
list_bindings() {
  HOME="$test_dir" OMARCHY_PATH="$ROOT" lua - <<'LUA'
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

# The compositor waits for a worker response, preserves request order and paired
# releases, and drops late responses or requests whose target lost focus.
OMARCHY_PATH="$ROOT" lua - <<'LUA' || fail "clipboard requests preserve targeting, order and paired releases"
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local binds, events, commands, timers = {}, {}, {}, {}
local window = { address = "editor", tags = {} }
hl = {
  get_active_window = function() return window end,
  dsp = { send_key_state = function(spec) return spec end },
  dispatch = function(spec) events[#events + 1] = spec end,
  exec_cmd = function(command) commands[#commands + 1] = command end,
  timer = function(callback, options)
    local timer = { callback = callback, options = options, enabled = true }
    function timer:set_enabled(enabled) self.enabled = enabled end
    timers[#timers + 1] = timer
    return timer
  end,
}
require("default.hypr.helpers")
o.bind = function(keys, _, callback) binds[keys] = callback end
require("default.hypr.bindings.clipboard")
local function check(callback, mods, code)
  events, timers = {}, {}
  callback()
  local id = o.clipboard_request_id
  assert(#events == 0 and #timers == 1, "resolution must be asynchronous")
  o.clipboard_keycode_ready(id, code)
  assert(#events == 1 and not timers[1].enabled)
  o.clipboard_keycode_ready(id, code + 1)
  assert(#events == 1, "duplicate response must not press again")
  assert(timers[2].options.timeout == 50 and timers[2].options.type == "oneshot")
  timers[2].callback()
  for i, state in ipairs({ "down", "up" }) do
    local event = events[i]
    assert(event.mods == mods and event.key == "code:" .. code and event.state == state)
    assert(event.window == nil, "injection must reach the focused surface")
  end
end
for _, tags in ipairs({ {}, { "terminal" }, { "terminal*" } }) do
  window.tags = tags
  local mods = #tags > 0 and "CTRL SHIFT" or "CTRL"
  check(binds["SUPER + A"], "CTRL", 24)
  check(binds["SUPER + C"], mods, 31)
  check(binds["SUPER + V"], mods, 60)
  check(binds["SUPER + X"], "CTRL", 56)
  check(o.universal_paste, mods, 60)
end
window = nil
check(o.universal_paste, "CTRL", 55)
window = { address = "editor", tags = {} }
events, commands, timers = {}, {}, {}
binds["SUPER + C"]()
local copy_id = o.clipboard_request_id
binds["SUPER + V"]()
local paste_id = o.clipboard_request_id
assert(#commands == 1, "workers must start in order")
o.clipboard_keycode_ready(paste_id, 55)
assert(#events == 0, "out-of-order responses must be ignored")
o.clipboard_keycode_ready(copy_id, 54)
timers[1].callback()
assert(#commands == 1, "late deadline must not advance a request already sending keys")
timers[2].callback()
assert(#commands == 2)
o.clipboard_keycode_ready(paste_id, 55)
timers[4].callback()
assert(events[1].key == "code:54" and events[2].state == "up" and events[3].key == "code:55")
events, timers = {}, {}
binds["SUPER + A"]()
local id = o.clipboard_request_id
window.address = "other-editor"
o.clipboard_keycode_ready(id, 24)
assert(#events == 0, "focus change must not send to another window")
binds["SUPER + A"]()
id = o.clipboard_request_id
o.clipboard_keycode_ready(id, 0)
assert(events[1].key == "A", "failed resolution must retain native named dispatch")
timers[#timers].callback()
assert(events[2].key == "A")
events, timers = {}, {}
binds["SUPER + A"]()
id = o.clipboard_request_id
timers[1].callback()
o.clipboard_keycode_ready(id, 24)
assert(#events == 0, "expired response must not inject")
local device = { type = "keyboard", main = true, address = "kbd", active_keymap = "French" }
hl.get_devices = function() return { device } end
binds["SUPER + A"]()
id = o.clipboard_request_id
device.active_keymap = "English (US)"
o.clipboard_keycode_ready(id, 24)
assert(#events == 0, "changed seat keymap must not receive a stale code")

-- A fresh Lua state must reject a worker started before the config reloaded.
events, timers = {}, {}
o = { bind = function(keys, _, callback) binds[keys] = callback end }
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bindings/clipboard.lua")
binds["SUPER + C"]()
local old_id = o.clipboard_request_id
o = { bind = function(keys, _, callback) binds[keys] = callback end }
dofile(os.getenv("OMARCHY_PATH") .. "/default/hypr/bindings/clipboard.lua")
binds["SUPER + V"]()
local new_id = o.clipboard_request_id
o.clipboard_keycode_ready(old_id, 54)
assert(#events == 0, "a worker from before reload must not satisfy a new request")
o.clipboard_keycode_ready(new_id, 55)
assert(#events == 1 and events[1].key == "code:55")
timers[#timers].callback()
LUA
pass "clipboard requests preserve targeting, order and paired releases"

# Stub only the Wayland transport and outgoing IPC. Resolution uses real XKB
# keymaps, so the actual client keymap wins over any configured-layout guess.
require_command xkbcli
export REAL_XKBCLI=$(command -v xkbcli)
mkdir -p "$test_dir/bin"
cat >"$test_dir/bin/xkbcli" <<'SH'
#!/bin/bash
if [[ $1 == "dump-keymap-wayland" ]]; then
  cat "$TEST_SEAT_KEYMAP"
else
  exec "$REAL_XKBCLI" "$@"
fi
SH
cat >"$test_dir/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_HYPRCTL_LOG"
SH
chmod +x "$test_dir/bin/xkbcli" "$test_dir/bin/hyprctl"
export TEST_SEAT_KEYMAP="$test_dir/seat keymap.xkb" TEST_HYPRCTL_LOG="$test_dir/ipc"
request_id='01234567-89ab-4def-8123-456789abcdef:7'
for spec in 'us,il::a:38' 'fr,il::a:24' 'us,il:dvorak,:c:31' 'us,il:dvorak,:x:56' 'us:3l:a:41'; do
  IFS=: read -r layout variant key code <<<"$spec"
  HOME="$test_dir" "$REAL_XKBCLI" compile-keymap --layout "$layout" --variant "$variant" >"$TEST_SEAT_KEYMAP"
  HOME="$test_dir" PATH="$test_dir/bin:$PATH" "$ROOT/bin/omarchy-clipboard-keycode" "$request_id" "$key"
  [[ $(<"$TEST_HYPRCTL_LOG") == "eval o.clipboard_keycode_ready(\"$request_id\",$code)" ]] || fail "clipboard worker resolves $layout/$variant $key from the seat keymap"
done
: >"$TEST_SEAT_KEYMAP"
PATH="$test_dir/bin:$PATH" "$ROOT/bin/omarchy-clipboard-keycode" "$request_id" a
[[ $(<"$TEST_HYPRCTL_LOG") == "eval o.clipboard_keycode_ready(\"$request_id\",0)" ]] || fail "unreadable keymaps retain named resolution"
pass "clipboard worker resolves actual seat keymaps and reports failures"
