#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

shortcuts="$ROOT/default/omarchy/shortcuts"

# Load the helpers and every default binding against a stub hl, and print one
# line per binding: "global <name>" for a global shortcut, "exec <command>" for
# a command, then its description.
list_bindings() {
  HOME="$(mktemp -d)" OMARCHY_PATH="$ROOT" lua <<'LUA'
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

for _, file in ipairs({ "utilities", "clipboard" }) do
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
pass "shell bindings use global shortcuts only for what the shell registers"

# Every default binding that toggles a listed route or panel goes through its
# shortcut, and none toggles one through a command any more.
! grep -E $'^exec\t(omarchy-menu toggle|omarchy-shell shell toggle) ' <<<"$bindings" | grep -v $'\tunlisted ' ||
  fail "default bindings toggle menus and panels through global shortcuts"
expect_binding $'global\tomarchy:menu.root\tOmarchy menu' "SUPER+SPACE opens the menu through its shortcut"
expect_binding $'global\tomarchy:menu.theme\tTheme menu' "the theme menu binding uses its shortcut"
expect_binding $'global\tomarchy:panel.omarchy.clipboard\tClipboard manager' "the clipboard binding uses its shortcut"
pass "default bindings toggle menus and panels through global shortcuts"

# The shell and the helpers read the same list, in the same format.
while IFS= read -r line; do
  [[ -z $line || $line == \#* ]] && continue
  [[ $line =~ ^(menu|panel)\ [^[:space:]]+$ ]] || fail "shortcuts lines are a kind and a target: $line"
done <"$shortcuts"
grep -q 'path: shell.omarchyPath + "/default/omarchy/shortcuts"' "$ROOT/shell/shell.qml" ||
  fail "the shell registers the shortcuts the helpers bind"
grep -q 'paths.omarchy_path .. "/default/omarchy/shortcuts"' "$ROOT/default/hypr/helpers.lua" ||
  fail "the helpers bind the shortcuts the shell registers"
pass "the shell and the helpers share one shortcut list"

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
