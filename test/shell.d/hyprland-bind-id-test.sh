#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

tmpdir=$(mktemp -d) && [[ -n $tmpdir && -d $tmpdir ]] ||
  fail "the test gets a temporary directory to load the Lua config in"
trap 'rm -rf "$tmpdir"' EXIT

# What o.bind hands to hl.bind, one declaration at a time. The dispatcher is
# printed as the command string Hyprland would run, since that is where a web
# app bind carries the name it matches a window by.
bound() {
  cat >"$tmpdir/bind.lua" <<LUA
hl = {
  dsp = { exec_cmd = function(command) return command end },
  bind = function(keys, dispatcher, opts)
    print("description: " .. tostring(opts.description))
    print("id: " .. tostring(opts.id))
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
# test. The two binds below are what a personal config adds, an id that is
# nothing like its label and a bind written straight against hl.bind.
cat >"$home/.config/hypr/hyprland.lua" <<LUA
dofile("$ROOT/default/hypr/bootstrap.lua")
require("default.hypr.helpers")
require("default.hypr.bindings.applications")

o.bind("SUPER + ALT + Z", "Renamed later", { webapp = "https://example.test/", focus = true }, { id = "Stable Id" })
hl.bind("SUPER + ALT + Y", hl.dsp.exec_cmd("true"), { description = "Written against hl" })
LUA

scanned=$(env -i PATH="$PATH" HOME="$home" OMARCHY_PATH="$ROOT" lua "$tmpdir/scan.lua")
[[ -n $scanned ]] || fail "the scan reports the binds in the Lua config"

# modmask, description, id, key, dispatcher kind, dispatcher arg
[[ -z $(awk -F '\t' '$3 == "" { print }' <<<"$scanned") ]] ||
  fail "every bind the scan reports answers to an id" "$scanned"
pass "every bind the scan reports answers to an id"

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
while IFS= read -r binding; do
  [[ $binding == *"id = "* ]] ||
    fail "every web app bind that focuses an open window names its own id" "$binding"
done < <(grep -rh 'webapp = ' "$ROOT/default/hypr/bindings" | grep -F 'focus = true')
pass "every web app bind that focuses an open window names its own id"
