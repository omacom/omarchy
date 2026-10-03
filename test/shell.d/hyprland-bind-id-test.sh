#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to load the Lua config in"
trap 'rm -rf "$tmpdir"' EXIT

# What o.bind hands to hl.bind, one declaration at a time. The dispatcher is
# printed as the command string Hyprland would run, since that is where a web
# app bind carries the name it matches a window by. locked stands in for the
# flags o.bind only forwards, having no opinion of its own about them.
bound() {
  cat >"$tmpdir/bind.lua" <<LUA
hl = {
  dsp = { exec_cmd = function(command) return command end },
  bind = function(keys, dispatcher, opts)
    print("description: " .. tostring(opts.description))
    print("id: " .. tostring(opts.id))
    print("locked: " .. tostring(opts.locked))
    print("dispatcher: " .. tostring(dispatcher))
  end,
}

dofile("$ROOT/default/hypr/helpers.lua")

$1
LUA

  lua "$tmpdir/bind.lua"
}

declared=$(bound 'o.bind("SUPER + K", "Calendar", "true")')
grep -qx 'id: Calendar' <<<"$declared" ||
  fail "a bind that names no id of its own answers to its description" "$declared"
pass "a bind that names no id of its own answers to its description"

declared=$(bound 'o.bind("SUPER + K", "Calendar", "true", { id = "calendar" })')
grep -qx 'id: calendar' <<<"$declared" ||
  fail "a declared id is the one the bind keeps" "$declared"
grep -qx 'description: Calendar' <<<"$declared" ||
  fail "a declared id leaves the description alone" "$declared"
pass "a declared id is the one the bind keeps"

# Nothing stops a config from handing one options table to several binds, and the
# id fills in only when none is set yet. Write that fallback into the table the
# caller passed and the first description becomes the id of every bind after it,
# which is the one way an id can be wrong without anyone declaring it.
declared=$(bound '
local shared = {}
o.bind("SUPER + K", "Calendar", "true", shared)
o.bind("SUPER + M", "Mail", "true", shared)
')
grep -qx 'id: Mail' <<<"$declared" ||
  fail "a reused options table does not keep the first bind's id" "$declared"
pass "a reused options table does not keep the first bind's id"

# Copying the options table is how that works, and a copy made key by key sees
# only the keys a table holds itself. A config that shares its flags through
# __index would have handed Hyprland the flags before the copy and nothing after
# it, so the copy carries the metatable too.
declared=$(bound '
local shared = { locked = true }
o.bind("SUPER + K", "Calendar", "true", setmetatable({}, { __index = shared }))
')
grep -qx 'locked: true' <<<"$declared" ||
  fail "a flag a bind inherits through a metatable survives the copy" "$declared"
pass "a flag a bind inherits through a metatable survives the copy"

# The whole point of the id: this command's first argument is matched against an
# open window's class or title, so it has to hold still while the label moves.
declared=$(bound 'o.bind("SUPER + K", "Photos", { webapp = "https://photos.test/", focus = true }, { id = "Google Photos" })')
grep -qF "omarchy-launch-or-focus-webapp 'Google Photos' 'https://photos.test/'" <<<"$declared" ||
  fail "a web app bind matches its window by id" "$declared"
! grep -qF "'Photos'" <<<"$declared" ||
  fail "a web app bind does not match its window by description" "$declared"
pass "a web app bind matches its window by id"

declared=$(bound 'o.bind_toggle("SUPER + K", "Nightlight", "nightlight", { id = "nightlight" })')
grep -qx 'id: nightlight' <<<"$declared" ||
  fail "a toggle bind carries a declared id too" "$declared"
pass "a toggle bind carries a declared id too"

# The menu keeps its own scan of the Lua config, because Hyprland reports every
# Lua bind as dispatcher __lua and reports no id at all. Read that scan out of
# the menu rather than keeping a second copy of it here.
sed -n "/^    lua <<'LUA'\$/,/^LUA\$/p" "$ROOT/bin/omarchy-menu-keybindings" |
  sed '1d;$d' >"$tmpdir/scan.lua"
[[ -s $tmpdir/scan.lua ]] ||
  fail "the menu's Lua bind scan can be read out of the script"

home="$tmpdir/home"
mkdir -p "$home/.config/hypr"

# The scan reads ~/.config/hypr/hyprland.lua. Pull in the one binding file this
# is about rather than the whole config: the rest of it is not what is under
# test. The three binds below are what a personal config adds: an id that is
# nothing like its label, a bind written straight against hl.bind, and a label
# and id with a tab and a newline of their own in them.
cat >"$home/.config/hypr/hyprland.lua" <<LUA
dofile("$ROOT/default/hypr/bootstrap.lua")
require("default.hypr.helpers")
require("default.hypr.bindings.applications")

o.bind("SUPER + ALT + Z", "Renamed later", { webapp = "https://example.test/", focus = true }, { id = "Stable Id" })
hl.bind("SUPER + ALT + Y", hl.dsp.exec_cmd("true"), { description = "Written against hl" })
o.bind("SUPER + ALT + X", "Tabbed\tlabel", "true", { id = "Split\nid" })
LUA

scanned=$(env -i PATH="$PATH" HOME="$home" OMARCHY_PATH="$ROOT" lua "$tmpdir/scan.lua")
[[ -n $scanned ]] || fail "the scan reports the binds in the Lua config"

# modmask, description, id, key, dispatcher kind, dispatcher arg
[[ -z $(awk -F '\t' '$3 == "" { print }' <<<"$scanned") ]] ||
  fail "every bind the scan reports answers to an id" "$scanned"
pass "every bind the scan reports answers to an id"

# The record is tab delimited, one bind to a line, and a description and an id
# are the author's own text. Whatever they put in it, the shape holds.
[[ -z $(awk -F '\t' 'NF != 6 { print }' <<<"$scanned") ]] ||
  fail "every record the scan reports keeps its six fields" "$scanned"
awk -F '\t' '$2 == "Tabbed label" && $3 == "Split id" { found = 1 } END { exit !found }' <<<"$scanned" ||
  fail "a tab or a newline in a bind's own text folds into a space" "$scanned"
pass "a tab or a newline in a bind's own text folds into a space"

awk -F '\t' '$2 == "Terminal" && $3 == "Terminal" { found = 1 } END { exit !found }' <<<"$scanned" ||
  fail "the scan reports the description as the id when no other was declared" "$scanned"
awk -F '\t' '$2 == "Written against hl" && $3 == $2 { found = 1 } END { exit !found }' <<<"$scanned" ||
  fail "a bind written against hl.bind still reports an id" "$scanned"
pass "the scan reports the description as the id when no other was declared"

awk -F '\t' '$2 == "Renamed later" && $3 == "Stable Id" { found = 1 } END { exit !found }' <<<"$scanned" ||
  fail "the scan reports the id a bind declared, not its label" "$scanned"
awk -F '\t' '$3 == "Stable Id" && $6 ~ /or-focus-webapp .Stable Id./ { found = 1 } END { exit !found }' <<<"$scanned" ||
  fail "the scan reports the command the id built" "$scanned"
pass "the scan reports the id a bind declared, not its label"

awk -F '\t' '$3 == "WhatsApp" && $6 ~ /or-focus-webapp .WhatsApp./ { found = 1 } END { exit !found }' <<<"$scanned" ||
  fail "a web app Omarchy ships focuses the window its id names" "$scanned"
pass "a web app Omarchy ships focuses the window its id names"

# A web app bind that focuses an open window spends its id on a pattern the web
# app decides, so it cannot inherit one from a description somebody may later
# translate. Anything added alongside the four has to say so out loud.
#
# Ask o.bind which binds those are rather than matching the source text. A call
# written across several lines reads the same to Lua and not at all to a grep
# that works a line at a time, and the declaration is only visible here anyway:
# an id the bind named itself and one that defaulted to the description are the
# same id by the time anything downstream sees it.
cat >"$tmpdir/webapps.lua" <<LUA
local inert = {}
local anything
anything = setmetatable({}, {
  __index = function() return anything end,
  __call = function() return setmetatable({}, inert) end,
})

hl = setmetatable({
  bind = function() end,
  unbind = function() end,
}, { __index = function() return anything end })

-- The four are declared behind this, and a box that has had its preinstalls
-- removed is not a reason to check nothing.
_G.omarchy_preinstalled_bindings = true

dofile("$ROOT/default/hypr/bootstrap.lua")
require("default.hypr.helpers")

local bound = o.bind

o.bind = function(keys, description, dispatcher, options)
  if type(dispatcher) == "table" and dispatcher.webapp and dispatcher.focus then
    local declared = options ~= nil and options.id ~= nil
    print(tostring(keys) .. "\t" .. tostring(declared))
  end

  return bound(keys, description, dispatcher, options)
end

for _, module in ipairs({
  "media", "clipboard", "tiling", "utilities", "voxtype", "applications",
}) do
  require("default.hypr.bindings." .. module)
end
LUA

webapps=$(env -i PATH="$PATH" HOME="$home" OMARCHY_PATH="$ROOT" lua "$tmpdir/webapps.lua")
[[ -n $webapps ]] ||
  fail "the binding files Omarchy ships declare a web app bind that focuses a window" "$webapps"
[[ -z $(awk -F '\t' '$2 != "true" { print }' <<<"$webapps") ]] ||
  fail "every web app bind that focuses an open window names its own id" "$webapps"
pass "every web app bind that focuses an open window names its own id"
