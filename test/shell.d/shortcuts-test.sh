#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua
require_command jq

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_RUNTIME_DIR="$tmp/run"
export OMARCHY_PATH="$ROOT"
registry="$XDG_CONFIG_HOME/omarchy/shortcuts"
mkdir -p "$XDG_RUNTIME_DIR"
mkdir -p "$registry"

# Bind shortcuts the way the config does, against a recording hl, and run
# whatever Lua the test appends.
run_lua() {
  lua - <<LUA
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

binds, unbound, ran = {}, {}, {}
hl = setmetatable({
  dsp = setmetatable({}, {
    __index = function(_, name)
      return function(arg) return { dsp = name, arg = arg } end
    end,
  }),
  bind = function(keys, dispatcher, opts)
    table.insert(binds, { keys = keys, dispatcher = dispatcher, opts = opts or {} })
  end,
  -- As Hyprland does: "all" clears every binding, and anything else matches
  -- the text it was bound with, spaces removed and case folded, in any submap.
  unbind = function(keys)
    table.insert(unbound, keys)
    local function text(value) return value:gsub("%s", ""):lower() end
    for index = #binds, 1, -1 do
      if keys == "all" or text(binds[index].keys) == text(keys) then
        table.remove(binds, index)
      end
    end
  end,
  exec_cmd = function(command) table.insert(ran, command) end,
}, {
  __index = function()
    return function() return {} end
  end,
})

require("default.hypr.helpers")
require("default.hypr.shortcuts")

function bound(keys)
  local found = {}
  for _, binding in ipairs(binds) do
    if o.chord(binding.keys) == o.chord(keys) then
      table.insert(found, binding)
    end
  end
  return found
end

$1
LUA
}

run_lua '
o.bind("SUPER + W", "Close window", "close-window")
o.shortcut("omarchy.dictation.hold", {
  description = "Start dictation (push-to-talk)",
  release_description = "Stop dictation (push-to-talk)",
  keys = { "F9", "ALT + Alt_R" },
  command = "omarchy-dictation start",
  release = "omarchy-dictation stop",
})
o.shortcuts.apply()

local f9 = bound("F9")
assert(#f9 == 2, "a hold shortcut binds press and release")
assert(f9[1].opts.description == "Start dictation (push-to-talk)" and f9[2].opts.description == "Stop dictation (push-to-talk)")
assert(o.bind_commands[f9[1].dispatcher] == "omarchy-dictation start", "the keybindings menu can run it")
local alt = bound("Alt_R")
assert(#alt == 2 and alt[1].opts.ignore_mods, "a modifier key alone ignores the mask that changes as it is pressed")
assert(not f9[1].opts.ignore_mods, "other keys keep their modifiers")
assert(#bound("SUPER + W") == 1, "defaults stay bound")
assert(o.bound_keys["SUPER+W"]["SUPER + W"] and not o.bound_keys["F9"], "only bindings outside shortcuts count as defaults")
'
pass "Omarchy shortcuts bind their default keys"

# bash and Lua must agree on every chord, or a conflict check passes keys that
# then never bind.
chords=("SUPER + ctrl + x" "CTRL+SUPER+X" "META + R" "MOD4 + R" "control + mod1 + T" "ALT + Alt_R" "Super_R" "SUPER + code:191" "SUPER + mouse:275" "F9 + " "+F9" "META")
lua_chords=$(run_lua "for _, keys in ipairs({ $(printf '"%s",' "${chords[@]}") }) do print(o.chord(keys)) end")
# A subshell, so the helpers' snapshot and exit trap stay out of this test.
(
  source "$ROOT/bin/omarchy-shortcut-functions"
  bash_chords=$(for keys in "${chords[@]}"; do shortcut_chord "$keys"; done)
  [[ $lua_chords == "$bash_chords" ]] || fail "bash and Lua normalize chords alike" "$(paste <(echo "$lua_chords") <(echo "$bash_chords"))"
  for keys in "F9 + " "+F9" "SUPER + + R" " " "all"; do
    shortcut_valid_keys "$keys" && fail "\"$keys\" is not valid keys"
  done
  for keys in "F9" "SUPER + R" "Super_R" "SUPER + code:191"; do
    shortcut_valid_keys "$keys" || fail "\"$keys\" is valid keys"
  done
)
pass "bash and Lua agree on chords and on which keys are valid"

printf '%s\n' 'keys=SUPER + R' 'keys=super + w' 'description=Ignored' 'command=ignored' >"$registry/omarchy.dictation.hold"
printf '%s\n' 'description=Record' 'command=example record' 'keys=SUPER + ALT + R' 'keys=CTRL + SUPER + T' >"$registry/com.example.record"
printf '%s\n' 'description=Talk' 'command=example start' 'release=example stop' 'keys=Super_R' >"$registry/com.example.talk"
printf '%s\n' 'description=No command' 'keys=F1' >"$registry/com.example.orphan"
printf '%s\n' 'description=Everything' 'command=x' 'keys=all' 'keys=SUPER + catchall' 'keys=F10 + ' >"$registry/com.example.all"
printf '%s\n' 'command=bad' 'keys=F2' >"$registry/.hidden"
run_lua '
o.bind("SUPER + W", "Close window", "close-window")
o.shortcut("omarchy.dictation.hold", {
  description = "Start dictation (push-to-talk)",
  release_description = "Stop dictation (push-to-talk)",
  keys = { "F9", "ALT + Alt_R" },
  command = "omarchy-dictation start",
  release = "omarchy-dictation stop",
})
o.bind("SUPER + CTRL + T", "Terminal", "terminal")
o.shortcuts.apply()

assert(#bound("F9") == 0 and #bound("Alt_R") == 0, "chosen keys replace the defaults")
local t = bound("CTRL + SUPER + T")
assert(#t == 1 and t[1].opts.description == "Record", "a default spelled another way is still taken")
local r = bound("SUPER + R")
assert(#r == 2 and o.bind_commands[r[1].dispatcher] == "omarchy-dictation start", "Omarchy shortcuts keep their own command")
assert(r[1].opts.description == "Start dictation (push-to-talk)", "and their own description")
local w = bound("SUPER + W")
assert(#w == 2 and w[1].opts.description == "Start dictation (push-to-talk)", "a shortcut takes its keys from a default")
assert(bound("SUPER + ALT + R")[1].opts.description == "Record", "apps register shortcuts of their own")
assert(#bound("Super_R") == 2 and bound("Super_R")[1].opts.ignore_mods, "apps get hold shortcuts too")
assert(#bound("F1") == 0, "a shortcut with nothing to run binds nothing")
assert(#bound("F2") == 0, "hidden files are not shortcuts")
for _, keys in ipairs(unbound) do
  assert(keys ~= "all" and not keys:find("catchall"), "reserved keys never reach hl.unbind: " .. keys)
end
assert(#bound("SUPER + W") > 0, "a registry naming all keys does not clear the bindings")
assert(#bound("F10") == 0, "keys with an empty part never bind")

-- Moving off keys taken from a default needs the config to bring it back.
local file = io.open(os.getenv("XDG_CONFIG_HOME") .. "/omarchy/shortcuts/omarchy.dictation.hold", "w")
file:write("keys=SUPER + R\n")
file:close()
o.shortcuts.apply()
assert(ran[#ran] == "hyprctl reload", "releasing a default reloads to restore it")

local path = os.tmpname()
o.shortcuts.snapshot(path)
local snapshot = io.open(path):read("a")
os.remove(path)
assert(snapshot:find([==["id":"omarchy.dictation.hold","source":"omarchy","keys":["SUPER + R","super + w"]]==], 1, true), snapshot)
assert(snapshot:find([==["default_keys":["F9","ALT + Alt_R"]]==], 1, true), "the snapshot keeps the defaults")
assert(snapshot:find([==["id":"com.example.orphan","source":"app","keys":["F1"],"bound":[]]==], 1, true), "unbound shortcuts show as such")
'
pass "chosen keys replace defaults and apps register their own shortcuts"

printf '%s\n' 'keys=' >"$registry/omarchy.dictation.hold"
run_lua '
o.shortcut("omarchy.dictation.hold", { description = "Dictate", keys = "F9", command = "start" })
o.shortcuts.apply()
assert(#bound("F9") == 0, "an empty choice disables a default shortcut")
'
pass "an Omarchy shortcut can be turned off"

rm -f "$registry/omarchy.dictation.hold"
run_lua '
o.shortcut("omarchy.dictation.toggle", { description = "Toggle dictation", keys = "SUPER + CTRL + X", command = "toggle" })
o.shortcut("omarchy.dictation.hold", { description = "Dictate", keys = "F9", command = "start", release = "stop" })
o.shortcuts.apply()
-- The user or a dictation backend removes a key after the shortcuts bind.
hl.unbind("SUPER + CTRL + X")
local file = io.open(os.getenv("XDG_CONFIG_HOME") .. "/omarchy/shortcuts/omarchy.dictation.hold", "w")
file:write("keys=F10\n")
file:close()
o.shortcuts.apply({ "omarchy.dictation.hold" })
assert(#bound("SUPER + CTRL + X") == 0, "a live apply leaves keys someone unbound alone")
assert(#bound("F9") == 0 and #bound("F10") == 2, "a live apply rebinds the shortcut it names")
'
rm -f "$registry/omarchy.dictation.hold"
apply_line=$(grep -n '^o.shortcuts.apply()' "$ROOT/default/hypr/omarchy.lua" | cut -d: -f1)
backend_line=$(grep -n 'require("default.hypr.dictation-backend")' "$ROOT/default/hypr/omarchy.lua" | cut -d: -f1)
((apply_line < backend_line)) || fail "shortcuts bind before the dictation backend can replace them"
pass "a live apply only touches the shortcuts it names"

run_lua '
o.shortcut("omarchy.dictation.hold", { description = "Dictate", keys = "F9", command = "start", release = "stop" })
o.shortcuts.apply()
local f9 = bound("F9")
assert(f9[1].opts.hold_state == nil, "the shared state is not a Hyprland option")
f9[1].dispatcher()
o.shortcuts.apply({ "com.example.unrelated" })
assert(ran[#ran] == "start", "an unrelated change leaves a held key held")
o.shortcuts.apply({ "omarchy.dictation.hold" })
assert(ran[#ran] == "stop", "rebinding a held shortcut finishes the hold")
bound("F9")[2].dispatcher()
assert(ran[#ran] == "stop" and #ran == 2, "letting go afterwards does not stop it twice")
'
pass "rebinding a held shortcut finishes the hold"

printf '%s\n' 'description=Zed' 'command=zed' 'keys=F6' >"$registry/com.zed"
printf '%s\n' 'description=Alpha' 'command=alpha' 'keys=F6' 'keys=F5' >"$registry/com.alpha"
printf '%s\n' 'keys=F5' >"$registry/omarchy.second"
run_lua '
o.shortcut("omarchy.second", { description = "Second", keys = "F4", command = "second" })
o.shortcut("omarchy.first", { description = "First", keys = "F5", command = "first" })
o.shortcuts.apply()
local ids = {}
local wanted = { ["omarchy.second"] = true, ["omarchy.first"] = true, ["com.alpha"] = true, ["com.zed"] = true }
for _, shortcut in ipairs(o.shortcuts.current) do
  if wanted[shortcut.id] then table.insert(ids, shortcut.id) end
end
assert(table.concat(ids, " ") == "omarchy.second omarchy.first com.alpha com.zed", table.concat(ids, " "))
assert(bound("F5")[1].opts.description == "Second", "the first declared keeps shared keys")
assert(bound("F6")[1].opts.description == "Alpha", "apps share keys by id")
'
rm -f "$registry/com.zed" "$registry/com.alpha" "$registry/omarchy.second"
pass "Omarchy shortcuts bind in declaration order, then apps by id"

printf '%s\n' 'release=evil' 'release_description=Evil' 'command=evil' 'keys=F8' >"$registry/omarchy.dictation.toggle"
printf '%s\n' 'description=Fake' 'command=fake' 'keys=F12' >"$registry/omarchy.fake"
run_lua '
o.shortcut("omarchy.dictation.toggle", { description = "Toggle dictation", keys = "SUPER + CTRL + X", command = "toggle" })
o.shortcuts.apply()
local f8 = bound("F8")
assert(#f8 == 1 and o.bind_commands[f8[1].dispatcher] == nil and f8[1].opts.description == "Toggle dictation",
  "a file for an Omarchy shortcut only changes its keys")
assert(#bound("F12") == 0, "an undeclared Omarchy id never binds")
'
rm -f "$registry/omarchy.dictation.toggle" "$registry/omarchy.fake"
pass "files for Omarchy shortcuts only change their keys"

run_lua '
o.bind("SUPER + W", "Close window", "close")
o.shortcuts.apply()
o.bind("SUPER + P", "Personal", "personal")
local path = os.tmpname()
o.shortcuts.snapshot(path)
local snapshot = io.open(path):read("a")
os.remove(path)
assert(snapshot:find([==["defaults":["SUPER+W"]]==], 1, true), "only bindings made before the shortcuts can be taken: " .. snapshot)
'
pass "the snapshot names the bindings a shortcut can take"

printf '%s\n' 'description=Quote "this" \ and	tab' 'command=x' 'keys=F3' >"$registry/com.example.record"
run_lua '
o.shortcuts.apply()
local path = os.tmpname()
o.shortcuts.snapshot(path)
local snapshot = io.open(path):read("a")
os.remove(path)
io.open(os.getenv("HOME") .. "/snapshot.json", "w"):write(snapshot):close()
'
jq -e '.shortcuts[] | select(.id == "com.example.record") | .description == "Quote \"this\" \\ and\ttab"' "$HOME/snapshot.json" >/dev/null ||
  fail "the snapshot is valid JSON whatever the text" "$(cat "$HOME/snapshot.json")"
pass "the snapshot escapes text into valid JSON"

rm -rf "$registry" && mkdir -p "$registry"

# The CLI against a stand-in Hyprland: binds -j lists what is bound, and eval
# answers snapshot() with a fixture and records apply().
bin="$tmp/bin"
mkdir -p "$bin"
cat >"$bin/hyprctl" <<'SH'
#!/bin/bash
case $1 in
  version) exit 0 ;;
  binds) cat "$HYPRCTL_BINDS" ;;
  eval)
    if [[ $2 =~ ^o\.shortcuts\.snapshot\(\"(.*)\"\)$ ]]; then
      cp "$HYPRCTL_SNAPSHOT" "${BASH_REMATCH[1]}"
    else
      echo "$2" >>"$HYPRCTL_LOG"
    fi
    ;;
  *) echo "$*" >>"$HYPRCTL_LOG" ;;
esac
SH
chmod +x "$bin/hyprctl"
export PATH="$bin:$ROOT/bin:$PATH"
export HYPRLAND_INSTANCE_SIGNATURE=test
export HYPRCTL_BINDS="$tmp/binds.json" HYPRCTL_SNAPSHOT="$tmp/snapshot.json" HYPRCTL_LOG="$tmp/hyprctl.log"
: >"$HYPRCTL_LOG"

cat >"$HYPRCTL_BINDS" <<'JSON'
[
  { "modmask": 64, "key": "W", "keycode": 0, "release": false, "submap": "", "description": "Close window" },
  { "modmask": 0, "key": "F9", "keycode": 0, "release": false, "submap": "", "description": "Start dictation (push-to-talk)" },
  { "modmask": 0, "key": "F9", "keycode": 0, "release": true, "submap": "", "description": "Stop dictation (push-to-talk)" },
  { "modmask": 8, "key": "Alt_R", "keycode": 0, "release": false, "submap": "", "description": "Start dictation (push-to-talk)" },
  { "modmask": 68, "key": "X", "keycode": 0, "release": false, "submap": "", "description": "Toggle dictation" },
  { "modmask": 64, "key": "", "keycode": 191, "release": false, "submap": "", "description": "Coded" },
  { "modmask": 64, "key": "Q", "keycode": 0, "release": false, "submap": "resize", "description": "In a submap" },
  { "modmask": 64, "key": "P", "keycode": 0, "release": false, "submap": "", "description": "Personal" },
  { "modmask": 0, "key": "Super_L", "keycode": 0, "release": true, "submap": "", "description": "Open the launcher" },
  { "modmask": 64, "key": "V", "keycode": 0, "release": true, "submap": "", "description": "Stop talking" },
  { "modmask": 64, "key": "V", "keycode": 0, "release": false, "submap": "", "description": "Start talking" }
]
JSON
cat >"$HYPRCTL_SNAPSHOT" <<'JSON'
{ "defaults": ["SUPER+CODE:191", "SUPER+W"], "shortcuts": [
  { "id": "omarchy.dictation.toggle", "source": "omarchy", "keys": ["SUPER + CTRL + X"], "bound": ["SUPER + CTRL + X"], "changed": false, "description": "Toggle dictation", "command": "omarchy-dictation toggle", "default_keys": ["SUPER + CTRL + X"] },
  { "id": "omarchy.dictation.hold", "source": "omarchy", "keys": ["F9", "ALT + Alt_R"], "bound": ["F9", "ALT + Alt_R"], "changed": false, "description": "Start dictation (push-to-talk)", "command": "omarchy-dictation start", "release": "omarchy-dictation stop", "default_keys": ["F9", "ALT + Alt_R"] }
] }
JSON

[[ $(omarchy-shortcut-get omarchy.dictation.hold) == $'F9\nALT + Alt_R' ]] || fail "get prints the default keys one per line"
[[ $(omarchy-shortcut-get omarchy.dictation.hold --json | jq -r '.default_keys | length') == 2 ]] || fail "get --json carries the snapshot"
if omarchy-shortcut-get com.example.missing 2>/dev/null; then fail "get fails for an unknown shortcut"; fi
pass "get reads what Hyprland bound"

omarchy-shortcut-set omarchy.dictation.hold F9 "Alt_R" "SUPER + R" || fail "keys a shortcut already holds are no conflict"
[[ $(omarchy-shortcut-get omarchy.dictation.hold) == $'F9\nAlt_R\nSUPER + R' ]] || fail "get prints the chosen keys"
[[ $(cat "$registry/omarchy.dictation.hold") == $'keys=F9\nkeys=Alt_R\nkeys=SUPER + R' ]] || fail "Omarchy's shortcut stores only keys"
grep -qx 'o.shortcuts.apply({"omarchy.dictation.hold"})' "$HYPRCTL_LOG" || fail "set applies the change live, to that shortcut only" "$(cat "$HYPRCTL_LOG")"
pass "set rebinds an Omarchy shortcut"

if omarchy-shortcut-set omarchy.dictation.hold F9 --command evil 2>/dev/null; then fail "Omarchy shortcuts keep their command"; fi
if omarchy-shortcut-set com.example.record "SUPER + ALT + R" 2>/dev/null; then fail "a new shortcut needs a command"; fi
if omarchy-shortcut-set "../escape" F1 --command x 2>/dev/null; then fail "ids cannot leave the registry"; fi
if omarchy-shortcut-set com.example.record $'F1\nkeys=F2' --command x 2>/dev/null; then fail "values cannot add lines"; fi
if omarchy-shortcut-set com.example.record 2>/dev/null; then fail "set needs keys"; fi
if omarchy-shortcut-set omarchy.dictation.hld F10 2>/dev/null; then fail "set refuses an Omarchy id Omarchy doesn't declare"; fi
[[ ! -e $registry/omarchy.dictation.hld ]] || fail "a misspelled Omarchy id writes nothing"
for reserved in all ALL "SUPER + catchall"; do
  if omarchy-shortcut-set com.example.record "$reserved" --command x 2>/dev/null; then fail "set refuses the reserved key $reserved"; fi
done
pass "set refuses invalid changes"

set +e
output=$(omarchy-shortcut-set com.example.record "super + w" "SUPER + code:191" "SUPER + CTRL + X" "SUPER + R" "SUPER + SHIFT + R" "SUPER + Q" --command "example record" --description "Record" 2>&1)
status=$?
set -e
((status == 2)) || fail "conflicts exit 2" "$output"
[[ $output == *'super + w is already used by "Close window"'* ]] || fail "conflicts name the binding" "$output"
[[ $output == *'SUPER + code:191 is already used by "Coded"'* ]] || fail "conflicts compare keycodes" "$output"
[[ $output == *'SUPER + CTRL + X is already used by "Toggle dictation" (omarchy.dictation.toggle)'* ]] || fail "conflicts name a shortcut's id" "$output"
[[ $output == *'SUPER + R is already used by "Start dictation (push-to-talk)" (omarchy.dictation.hold)'* ]] || fail "conflicts include chosen keys not bound yet" "$output"
[[ $output != *'SHIFT + R'* ]] || fail "free keys are not conflicts" "$output"
[[ $output == *'SUPER + Q is used by "In a submap" in the resize submap'* ]] || fail "submap keys are conflicts" "$output"
[[ ! -e $registry/com.example.record ]] || fail "a refused set changes nothing"

json=$(omarchy-shortcut-set com.example.record "SUPER + W" --command x --json) && fail "json conflicts still fail"
[[ $(jq -r '.conflicts[0].description' <<<"$json") == "Close window" ]] || fail "conflicts come as JSON" "$json"
if omarchy-shortcut-set com.example.record Super_L --command x 2>"$tmp/err"; then fail "a release-only binding holds its key"; fi
grep -q 'Super_L is used by "Open the launcher"' "$tmp/err" || fail "a release-only binding is named" "$(cat "$tmp/err")"
[[ $(omarchy-shortcut-set com.example.record "SUPER + V" --command x --json | jq -r '.conflicts[0].description') == "Start talking" ]] ||
  fail "a hold is named by its press"
pass "set refuses keys another binding uses"

if omarchy-shortcut-set com.example.record "SUPER + Q" --command x --force 2>/dev/null; then fail "force can't take a submap's keys"; fi
if omarchy-shortcut-set com.example.record "SUPER + P" --command x --force 2>"$tmp/err"; then fail "force can't take the user's own binding"; fi
grep -q 'SUPER + P is used by "Personal", bound in your own Hyprland config' "$tmp/err" || fail "the user's binding is named" "$(cat "$tmp/err")"
[[ $(omarchy-shortcut-set com.example.record "SUPER + Q" --command x --json | jq -r '.conflicts[] | select(.submap) | .submap') == "resize" ]] ||
  fail "json names the submap"
[[ $(omarchy-shortcut-set com.example.record "SUPER + P" "SUPER + W" --command x --json | jq -c '[.conflicts[] | [.keys, .can_take]]') == '[["SUPER + W",true],["SUPER + P",false]]' ]] ||
  fail "json says which keys force can take" "$(omarchy-shortcut-set com.example.record "SUPER + P" "SUPER + W" --command x --json)"
omarchy-shortcut-set com.example.record "SUPER + R" "SUPER + SHIFT + R" --command "example record" --description "Record" --force ||
  fail "force takes conflicting keys"
grep -qx 'o.shortcuts.apply({"com.example.record","omarchy.dictation.hold"})' "$HYPRCTL_LOG" ||
  fail "force rebinds the shortcut it took keys from" "$(cat "$HYPRCTL_LOG")"
[[ $(omarchy-shortcut-get omarchy.dictation.hold) == $'F9\nAlt_R' ]] || fail "force takes keys from the shortcut that had them"
[[ $(omarchy-shortcut-get com.example.record) == $'SUPER + R\nSUPER + SHIFT + R' ]] || fail "force binds the new shortcut"
grep -qx 'description=Record' "$registry/com.example.record" && grep -qx 'command=example record' "$registry/com.example.record" ||
  fail "an app shortcut stores what it runs"
pass "set --force takes keys from other shortcuts"

omarchy-shortcut-set com.example.record "SUPER + ALT + R" || fail "an app changes its own keys without restating the command"
grep -qx 'command=example record' "$registry/com.example.record" || fail "the command is kept"
[[ $(omarchy-shortcut-list --json | jq -r '.[] | select(.id == "com.example.record") | .keys[0]') == "SUPER + ALT + R" ]] ||
  fail "list --json includes app shortcuts"
omarchy-shortcut-list | grep -q '^omarchy.dictation.toggle  *SUPER + CTRL + X  *Toggle dictation$' || fail "list prints a table" "$(omarchy-shortcut-list)"
omarchy-shortcut-set com.example.talk F12 --command "talk start" --release "talk stop" --description "Talk" --release-description "Stop talking" ||
  fail "set registers a hold with a release description"
grep -qx 'release_description=Stop talking' "$registry/com.example.talk" || fail "the release description is saved"
omarchy-shortcut-reset com.example.talk
pass "list shows every shortcut"

omarchy-shortcut-set omarchy.dictation.toggle --none || fail "--none disables a shortcut"
[[ -z $(omarchy-shortcut-get omarchy.dictation.toggle) ]] || fail "a disabled shortcut has no keys"
omarchy-shortcut-reset omarchy.dictation.toggle
[[ $(omarchy-shortcut-get omarchy.dictation.toggle) == "SUPER + CTRL + X" ]] || fail "reset returns to the default"
omarchy-shortcut-reset com.example.record
if omarchy-shortcut-get com.example.record 2>/dev/null; then fail "reset removes an app's shortcut"; fi
pass "reset returns to defaults and removes app shortcuts"

# A registry that can't be written fails the change rather than reporting it.
if ((EUID != 0)); then
  touch "$registry/.lock"
  chmod a-w "$registry"
  if omarchy-shortcut-set com.example.readonly F11 --command x 2>"$tmp/err"; then fail "set fails when it can't save"; fi
  grep -q "could not save com.example.readonly" "$tmp/err" || fail "set says it could not save" "$(cat "$tmp/err")"
  chmod u+w "$registry" && rm -f "$registry/.lock"
  chmod a-w "$registry"
  if omarchy-shortcut-set com.example.readonly F11 --command x 2>"$tmp/err"; then fail "set fails when it can't lock"; fi
  grep -q "could not write to" "$tmp/err" || fail "set says the registry can't be written" "$(cat "$tmp/err")"
  chmod u+w "$registry"
  pass "set fails when the registry can't be written"
else
  skip "set fails when the registry can't be written (root ignores permissions)"
fi

# Without Hyprland nothing knows Omarchy's defaults or the other bindings.
cat >"$bin/hyprctl" <<'SH'
#!/bin/bash
exit 1
SH
if omarchy-shortcut-set com.example.offline F1 --command x 2>"$tmp/err"; then fail "set refuses without Hyprland"; fi
grep -q "Hyprland isn't running" "$tmp/err" || fail "set says why it refused" "$(cat "$tmp/err")"
[[ ! -e $registry/com.example.offline ]] || fail "a refused set writes nothing"
if omarchy-shortcut-get omarchy.dictation.toggle 2>"$tmp/err"; then fail "get can't know Omarchy's defaults without Hyprland"; fi
grep -q "aren't known" "$tmp/err" || fail "get says why Omarchy's defaults are unknown" "$(cat "$tmp/err")"
printf '%s\n' 'keys=F7' >"$registry/omarchy.dictation.hold"
[[ $(omarchy-shortcut-get omarchy.dictation.hold) == "F7" ]] || fail "get shows chosen keys without Hyprland"
[[ $(omarchy-shortcut-get omarchy.dictation.hold --json | jq -c '[.source, .command]') == '["omarchy",null]' ]] ||
  fail "get --json keeps an Omarchy shortcut Omarchy's without Hyprland" "$(omarchy-shortcut-get omarchy.dictation.hold --json)"
rm -f "$registry/omarchy.dictation.hold"
pass "without Hyprland set refuses and get shows only chosen keys"

# A snapshot Hyprland can't give is an error, not an empty desktop that would
# make every shortcut look unbound.
cat >"$bin/hyprctl" <<'SH'
#!/bin/bash
case $1 in
  version | binds) [[ $1 == binds ]] && echo '[]'; exit 0 ;;
  eval) exit 7 ;;
esac
SH
if omarchy-shortcut-set com.example.record F1 --command x 2>"$tmp/err"; then fail "set refuses when Hyprland can't say what is bound"; fi
grep -q "could not read shortcuts from Hyprland" "$tmp/err" || fail "the failure says what to do" "$(cat "$tmp/err")"
mkdir -p "$tmp/odd dir"
cp "$HYPRCTL_SNAPSHOT" "$tmp/fixture.json"
cat >"$bin/hyprctl" <<'SH'
#!/bin/bash
case $1 in
  version) exit 0 ;;
  binds) echo '[{ "modmask": 68, "key": "X", "keycode": 0, "release": false, "submap": "", "description": "Toggle dictation" }]' ;;
  eval) [[ $2 =~ ^o\.shortcuts\.snapshot\(\"(.*)\"\)$ ]] && cp "$HYPRCTL_SNAPSHOT" "${BASH_REMATCH[1]}" ;;
esac
SH
TMPDIR="$tmp/odd dir" omarchy-shortcut-set omarchy.dictation.toggle "SUPER + CTRL + X" ||
  fail "a shortcut does not conflict with itself whatever TMPDIR holds"
rm -f "$registry/omarchy.dictation.toggle"
pass "set reads Hyprland's bindings or refuses"

# A config from before named shortcuts can't apply them live; reload instead.
cat >"$bin/hyprctl" <<'SH'
#!/bin/bash
case $1 in
  version | binds) [[ $1 == binds ]] && echo '[]'; exit 0 ;;
  eval)
    if [[ $2 =~ ^o\.shortcuts\.snapshot\(\"(.*)\"\)$ ]]; then
      echo '{"shortcuts": [], "defaults": []}' >"${BASH_REMATCH[1]}"
    else
      exit 7
    fi
    ;;
  *) echo "$*" >>"$HYPRCTL_LOG" ;;
esac
SH
: >"$HYPRCTL_LOG"
omarchy-shortcut-set com.example.record F1 --command x || fail "set works without the live apply"
grep -qx 'reload' "$HYPRCTL_LOG" || fail "an older config reloads"
pass "set reloads a config that cannot apply live"
