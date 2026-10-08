#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua
require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# ---- json.lua ---------------------------------------------------------------

json_cases=$(ROOT="$ROOT" lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
local json = require("default.hypr.json")

local function show(text)
  local value, err = json.decode(text)
  if err then
    return "error"
  end
  if json.is_array(value) then
    return "array:" .. #value
  end
  if type(value) == "table" then
    local keys = {}
    for key in pairs(value) do keys[#keys + 1] = key end
    table.sort(keys)
    return "object:" .. table.concat(keys, ",")
  end
  return type(value) .. ":" .. tostring(value)
end

for _, text in ipairs({
  '{"a":1,"b":[true,false]}',
  "[]",
  "{}",
  '"caf\\u00e9 \\ud83d\\ude00"',
  "-12.5e1",
  "01",
  "1.",
  '{"a":1,}',
  "[1 2]",
  '"tab\there"',
  "{} junk",
  ('['):rep(40) .. (']'):rep(40),
  "nul",
}) do
  print(show(text))
end
LUA
)

expected_json=$'object:a,b\narray:0\nobject:\nstring:café 😀\nnumber:-125.0\nerror\nerror\nerror\nerror\nerror\nerror\nerror\nerror'
[[ $json_cases == "$expected_json" ]] ||
  fail "the JSON decoder accepts valid documents and rejects malformed ones" "expected:"$'\n'"$expected_json"$'\n'"actual:"$'\n'"$json_cases"
pass "the JSON decoder accepts valid documents and rejects malformed ones"

# ---- touchpad.lua -----------------------------------------------------------

# Records every Hyprland call apply() makes, one line each, in a stable order.
run_apply() {
  local file="$1"
  local times="${2:-1}"

  ROOT="$ROOT" SETTINGS="$file" TIMES="$times" lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path

local function flat(value, prefix, out)
  if type(value) ~= "table" then
    out[#out + 1] = prefix .. "=" .. tostring(value)
    return out
  end
  local keys = {}
  for key in pairs(value) do keys[#keys + 1] = key end
  table.sort(keys)
  for _, key in ipairs(keys) do
    flat(value[key], prefix == "" and key or (prefix .. "." .. key), out)
  end
  return out
end

hl = {
  config = function(config) print("config " .. table.concat(flat(config, "", {}), " ")) end,
  device = function(spec) print("device " .. table.concat(flat(spec, "", {}), " ")) end,
  gesture = function(spec)
    local action = type(spec.action) == "function" and "<fn>" or spec.action
    print(("gesture %d %s %s %s"):format(spec.fingers, spec.direction, spec.mods or "-", action))
  end,
  window_rule = function(rule)
    print(("rule %s %s"):format(rule.match.class, rule.scroll_touchpad))
    return { set_enabled = function(_, on) print("rule-enabled " .. tostring(on)) end }
  end,
  dispatch = function() end,
  dsp = {
    focus = function(arg) return arg end,
    exec_cmd = function(arg) return arg end,
  },
}

local touchpad = require("default.hypr.touchpad")
for i = 1, tonumber(os.getenv("TIMES")) do
  if i > 1 then print("--") end
  touchpad.apply(os.getenv("SETTINGS"))
end
LUA
}

missing_output=$(run_apply "$tmpdir/missing.json")
expected_missing=$'rule (Alacritty|kitty) 1.5\nrule foot 2.0\nrule com.mitchellh.ghostty 0.2'
[[ $missing_output == "$expected_missing" ]] ||
  fail "without a settings file only Omarchy's per-app scroll speeds apply" "$missing_output"
pass "without a settings file only Omarchy's per-app scroll speeds apply"

printf 'not json' >"$tmpdir/broken.json"
broken_output=$(run_apply "$tmpdir/broken.json")
[[ $broken_output == *"Ignoring malformed"* && $broken_output == *"rule foot 2.0"* && $broken_output != *config* ]] ||
  fail "a malformed settings file is ignored rather than half-applied" "$broken_output"
pass "a malformed settings file is ignored rather than half-applied"

cat >"$tmpdir/settings.json" <<'JSON'
{
  "version": 1,
  "touchpad": {
    "natural_scroll": true,
    "scroll_factor": 0.6,
    "drag_3fg": 1,
    "sensitivity": 0.3,
    "accel_profile": "flat",
    "tap_button_map": "rml",
    "scroll_factor_typo": 2,
    "drag_lock": 1.5,
    "disable_while_typing": "no"
  },
  "devices": {
    "elan-touchpad": {},
    "apple-trackpad": { "natural_scroll": false, "sensitivity": -0.2, "kb_layout": "us" },
    "bad\nname": { "natural_scroll": true }
  },
  "gestures": {
    "settings": { "workspace_swipe_invert": false, "workspace_swipe_distance": 5 },
    "bindings": [
      { "fingers": 3, "direction": "horizontal", "action": "workspace" },
      { "fingers": 3, "direction": "left", "action": "focus_left" },
      { "fingers": 3, "direction": "left", "mods": "SUPER", "action": "focus_left" },
      { "fingers": 2, "direction": "up", "action": "close" },
      { "fingers": 2, "direction": "pinchin", "action": "close" },
      { "fingers": 4, "direction": "up", "action": "os.execute" },
      { "fingers": 6, "direction": "up", "action": "close" },
      { "fingers": 4, "direction": "down", "mods": "HYPER", "action": "close" },
      { "fingers": 4, "direction": "up", "action": "menu" }
    ]
  },
  "apps": [
    { "match": "firefox", "scroll": 0.8 },
    { "match": "", "scroll": 1 },
    { "match": "foot", "scroll": 50 }
  ]
}
JSON

settings_output=$(run_apply "$tmpdir/settings.json")
expected_settings=$'config gestures.workspace_swipe_invert=false input.touchpad.drag_3fg=1 input.touchpad.natural_scroll=true input.touchpad.scroll_factor=0.6
device accel_profile=flat name=apple-trackpad natural_scroll=false sensitivity=-0.2
device accel_profile=flat name=elan-touchpad sensitivity=0.3
gesture 3 horizontal - workspace
gesture 3 left SUPER <fn>
gesture 2 pinchin - close
gesture 4 up - <fn>
rule firefox 0.8'
[[ $settings_output == "$expected_settings" ]] ||
  fail "settings are validated against the schema before they reach Hyprland" "expected:"$'\n'"$expected_settings"$'\n'"actual:"$'\n'"$settings_output"
pass "settings are validated against the schema before they reach Hyprland"
pass "pointer settings target each touchpad by name instead of every mouse"
pass "shadowed, two-finger, and unknown gestures are dropped before Hyprland rejects them"

reapply_output=$(run_apply "$tmpdir/settings.json" 2)
second=${reapply_output#*$'--\n'}
removals=${second%%config*}
expected_removals=$'gesture 3 horizontal - unset
gesture 3 left SUPER unset
gesture 2 pinchin - unset
gesture 4 up - unset
rule-enabled false
'
[[ $removals == "$expected_removals" ]] ||
  fail "a live re-apply removes the gestures and rules it added before adding the new set" "$removals"
[[ ${second#"$removals"} == "$expected_settings" ]] ||
  fail "a live re-apply adds the same settings again" "$second"
pass "a live re-apply removes the gestures and rules it added before adding the new set"

# ---- the window is the source of truth ---------------------------------------

cat >"$tmpdir/winner.json" <<'JSON'
{
  "touchpad": { "natural_scroll": true },
  "gestures": { "bindings": [{ "fingers": 3, "direction": "left", "action": "focus_left" }] }
}
JSON

# watch() runs before the user's files and apply() after them, as
# default/hypr/omarchy.lua and default/hypr/toggles.lua do.
precedence_output=$(ROOT="$ROOT" SETTINGS="$tmpdir/winner.json" lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
hl = {
  config = function(config)
    print("config natural_scroll=" .. tostring(config.input.touchpad.natural_scroll))
  end,
  device = function() end,
  gesture = function(spec)
    local action = type(spec.action) == "function" and "<fn>" or spec.action
    print(("gesture %d %s %s %s"):format(spec.fingers, spec.direction, spec.mods or "-", action))
  end,
  window_rule = function() return { set_enabled = function() end } end,
  dispatch = function() end,
  dsp = { focus = function(arg) return arg end, exec_cmd = function(arg) return arg end },
}

local touchpad = require("default.hypr.touchpad")
touchpad.watch()

print("-- input.lua")
hl.config({ input = { touchpad = { natural_scroll = false } } })
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "up", action = "close" })
hl.gesture({ fingers = 4, direction = "up", action = "unset" })
hl.gesture({ fingers = 3, direction = "up", mods = "SUPER", action = "close" })

print("-- toggles")
touchpad.apply(os.getenv("SETTINGS"))
print("-- live re-apply")
touchpad.apply(os.getenv("SETTINGS"))
LUA
)

expected_precedence='-- input.lua
config natural_scroll=false
gesture 3 horizontal - workspace
gesture 4 up - close
gesture 4 up - unset
gesture 3 up SUPER close
-- toggles
config natural_scroll=true
gesture 3 horizontal - unset
gesture 3 left - <fn>
-- live re-apply
gesture 3 left - unset
config natural_scroll=true
gesture 3 left - <fn>'
[[ $precedence_output == "$expected_precedence" ]] ||
  fail "saved settings override input.lua and replace its clashing gestures" "expected:"$'\n'"$expected_precedence"$'\n'"actual:"$'\n'"$precedence_output"
pass "saved settings override input.lua and replace its clashing gestures"
pass "only recorded input.lua gestures that clash are unset, and only once"

user_config="$ROOT/config/hypr/hyprland.lua"
input_line=$(grep -n '^require("hypr.input")' "$user_config" | cut -d: -f1)
toggles_line=$(grep -n '^require("default.hypr.toggles")' "$user_config" | cut -d: -f1)
omarchy_line=$(grep -n '^require("default.hypr.omarchy")' "$user_config" | cut -d: -f1)
(( omarchy_line < input_line && input_line < toggles_line )) ||
  fail "the user config loads Omarchy, then input.lua, then the toggles"
grep -Fqx 'require("default.hypr.touchpad").apply()' "$ROOT/default/hypr/toggles.lua" ||
  fail "touchpad settings apply from the toggles, after input.lua"
grep -Fqx 'require("default.hypr.touchpad").watch()' "$ROOT/default/hypr/omarchy.lua" ||
  fail "touchpad gesture watching starts with Omarchy's defaults, before input.lua"
! grep -Fq 'default.hypr.touchpad").apply' "$ROOT/default/hypr/omarchy.lua" ||
  fail "touchpad settings do not also apply before input.lua"
pass "touchpad settings apply after input.lua, and gesture watching starts before it"

# ---- Model.js and touchpad.lua stay in sync -----------------------------------

lua_lists=$(ROOT="$ROOT" lua <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
hl = {}
local touchpad = require("default.hypr.touchpad")
local function keys(map)
  local list = {}
  for key in pairs(map) do list[#list + 1] = key end
  table.sort(list)
  return table.concat(list, ",")
end
local settings = {}
for key in pairs(touchpad.touchpad_schema) do settings[key] = true end
for key in pairs(touchpad.pointer_schema) do settings[key] = true end
print(keys(touchpad.actions))
print(keys(touchpad.directions))
print(keys(settings))
print(keys(touchpad.gesture_settings_schema))
local apps = {}
for _, app in ipairs(touchpad.default_apps) do apps[#apps + 1] = app.match .. "=" .. app.scroll end
print(table.concat(apps, ","))
local function specs(...)
  local list = {}
  for _, schema in ipairs({ ... }) do
    for key, spec in pairs(schema) do
      local text = key .. ":" .. spec.type
      if spec.min then text = text .. ":" .. spec.min .. ":" .. spec.max end
      if spec.values then text = text .. ":" .. keys(spec.values) end
      list[#list + 1] = text
    end
  end
  table.sort(list)
  return table.concat(list, ";")
end
print(specs(touchpad.touchpad_schema, touchpad.pointer_schema))
print(specs(touchpad.gesture_settings_schema))
LUA
)

LUA_LISTS="$lua_lists" run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/touchpad/Model.js')
const [actions, directions, settings, gestureSettings, apps, loaderSettings, loaderGestureSettings] = process.env.LUA_LISTS.split('\n')
const sorted = list => list.slice().sort().join(',')

assertEqual(sorted(model.ACTIONS.map(a => a.value)), actions, 'the window offers exactly the gesture actions the loader maps')
assertEqual(sorted(model.DIRECTIONS.map(d => d.value)), directions, 'the window offers exactly the gesture directions the loader accepts')
// flip_x / flip_y are accepted from a hand-edited file but not offered in the window.
assertEqual(
  sorted(Object.keys(model.SETTINGS).concat(['flip_x', 'flip_y'])),
  settings,
  'every setting the window offers is one the loader accepts'
)
for (const key of Object.keys(model.GESTURE_SETTINGS)) {
  assert(gestureSettings.split(',').includes(key), `the loader accepts the ${key} gesture setting`)
}
const specs = schema => Object.keys(schema).map(key => {
  const spec = schema[key]
  if (spec.type === 'bool') return `${key}:boolean`
  if (spec.type === 'choice') return `${key}:enum:${spec.options.map(o => o.value).sort().join(',')}`
  return `${key}:${spec.integer ? 'integer' : 'number'}:${spec.min}:${spec.max}`
}).sort().join(';')
assertEqual(specs(model.LOADER_SETTINGS), loaderSettings, 'the window keeps exactly the settings and ranges the loader accepts')
assertEqual(specs(model.LOADER_GESTURE_SETTINGS), loaderGestureSettings, 'the window keeps exactly the gesture settings and ranges the loader accepts')
assertEqual(
  model.DEFAULT_APPS.map(app => `${app.match}=${app.scroll.toFixed(1)}`).join(','),
  apps,
  'the window and the loader agree on the default per-app scroll speeds'
)

// ---- normalize / serialize ----
const state = model.parse(JSON.stringify({
  touchpad: { natural_scroll: true, scroll_factor: 9, drag_3fg: 1, junk: 1 },
  devices: { 'elan-touchpad': { sensitivity: 0.5, bogus: true } },
  gestures: {
    settings: { workspace_swipe_invert: false, nope: 1 },
    bindings: [{ fingers: 3, direction: 'horizontal', action: 'workspace', extra: 1 }, { fingers: 3, action: 'close' }]
  },
  apps: [{ match: 'foot', scroll: 2 }, { match: '', scroll: 1 }]
}))
assertDeepEqual(state.touchpad, { natural_scroll: true, drag_3fg: 1 }, 'the window keeps only valid touchpad settings')
assertDeepEqual(state.devices, { 'elan-touchpad': { sensitivity: 0.5 } }, 'the window keeps only valid device overrides')

const handEdited = model.normalize({
  touchpad: { flip_x: true, scroll_factor: 3, scroll_method: 'on_button_down' },
  gestures: {
    settings: { workspace_swipe_cancel_ratio: 0.3, workspace_swipe_distance: 1500, workspace_swipe_min_speed_to_force: 40 },
    bindings: [
      { fingers: 3, direction: 'up', action: 'special', scale: 1.5, workspace_name: 'notes' },
      { fingers: 4, direction: 'up', action: 'special', scale: 20, workspace_name: 'bad name' }
    ]
  }
})
assertDeepEqual(handEdited.touchpad, { scroll_factor: 3, flip_x: true, scroll_method: 'on_button_down' }, 'settings the window does not offer survive a save')
assertDeepEqual(handEdited.gestures.settings, { workspace_swipe_distance: 1500, workspace_swipe_cancel_ratio: 0.3, workspace_swipe_min_speed_to_force: 40 }, 'gesture settings beyond the sliders survive a save')
assertDeepEqual(handEdited.gestures.bindings, [
  { fingers: 3, direction: 'up', action: 'special', scale: 1.5, workspace_name: 'notes' },
  { fingers: 4, direction: 'up', action: 'special' }
], 'valid gesture scale and scratchpad names survive a save')
assertDeepEqual(state.gestures.bindings, [{ fingers: 3, direction: 'horizontal', action: 'workspace' }], 'the window keeps only complete gesture bindings')
assertDeepEqual(state.apps, [{ match: 'foot', scroll: 2 }], 'the window keeps only valid app rules')
assertDeepEqual(model.parse('not json'), model.normalize({}), 'a malformed file reads as an empty document')
assertEqual(model.serialize(model.normalize({})), '{\n  "version": 1\n}\n', 'an untouched document saves only its version')
assert(!('apps' in JSON.parse(model.serialize(model.normalize({})))), 'default app speeds are not written out')

// ---- effective values ----
assertEqual(model.effective('scroll_factor', { scroll_factor: 1 }, { scroll_factor: 0.4 }), 1, 'a saved value wins over the running one')
assertEqual(model.effective('scroll_factor', {}, { scroll_factor: 0.7 }), 0.7, 'without a saved value the running value shows')
assertEqual(model.effective('accel_profile', {}, { accel_profile: '' }), 'adaptive', 'an unset acceleration profile shows as adaptive')
assertEqual(model.effective('tap_button_map', {}, {}), 'lrm', 'without any value the default shows')
assertEqual(
  model.deviceEffective('natural_scroll', model.normalize({ touchpad: { natural_scroll: true }, devices: { pad: {} } }), 'pad', {}),
  true,
  'a device without its own value follows the shared setting'
)

// ---- input.lua overrides ----
const overrides = model.userOverrides([
  '-- hl.config({ input = { touchpad = { tap_to_click = false } } })',
  '--[[ touchpad = { drag_3fg = 1 } ]]',
  'hl.config({',
  '  input = {',
  '    sensitivity = 0.35,',
  '    touchpad = {',
  '      natural_scroll = true, -- trailing comment',
  '      scroll_factor = 0.3,',
  '    },',
  '  },',
  '  gestures = { workspace_swipe_invert = false },',
  '})',
  'hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })',
  'o.window("foot", { scroll_touchpad = 2 })'
].join('\n'))
assertDeepEqual(overrides.touchpad, { natural_scroll: true, scroll_factor: true }, 'input.lua touchpad settings are detected and commented ones ignored')
assertDeepEqual(overrides.gestureSettings, { workspace_swipe_invert: true }, 'input.lua gesture settings are detected')
assertEqual(overrides.gestures, 1, 'input.lua gestures are counted')
assertEqual(overrides.appScroll, true, 'input.lua per-app scroll rules are detected')
const template = require('fs').readFileSync(require('path').join(root, 'config/hypr/input.lua'), 'utf8')
assertDeepEqual(model.userOverrides(template), { touchpad: {}, gestureSettings: {}, gestures: 0, appScroll: false }, 'the stock input.lua template overrides nothing')

// ---- gestures ----
assertDeepEqual(
  model.gestureProblems([
    { fingers: 3, direction: 'horizontal', action: 'workspace' },
    { fingers: 3, direction: 'left', action: 'close' },
    { fingers: 3, direction: 'left', mods: 'SUPER', action: 'close' },
    { fingers: 2, direction: 'up', action: 'close' },
    { fingers: 2, direction: 'pinch', action: 'zoom' }
  ]),
  ['', 'Gesture 1 already uses this swipe', '', 'Two-finger swipes are used for scrolling', ''],
  'shadowed and two-finger swipes are flagged like the loader drops them'
)
const taken = [{ fingers: 3, direction: 'horizontal', action: 'workspace' }]
assertEqual(model.gestureProblems(taken.concat([model.nextBinding(taken)]))[1], '', 'a new gesture starts on a free swipe')

// ---- labels ----
assertEqual(model.deviceLabel('elan0678:00-04f3:3195-touchpad'), 'ELAN Touchpad', 'bus ids are dropped from device names')
assertEqual(model.deviceLabel('synps/2-synaptics-touchpad'), 'Synps/2 Synaptics Touchpad', 'plain device names are title-cased')
JS

# ---- commands ---------------------------------------------------------------

stub_bin="$tmpdir/bin"
mkdir -p "$stub_bin" "$tmpdir/home/.local/state/omarchy/toggles/hypr"
log="$tmpdir/hyprctl.log"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$HYPRCTL_LOG"
case "$1 $2" in
  "eval "*) [[ -n ${HYPRCTL_FAIL-} ]] && { echo "error: boom"; exit 7; }; echo ok ;;
  "reload"*) echo ok ;;
  "getoption -j")
    case $3 in
      input:touchpad:natural_scroll) echo '{"option": "input:touchpad:natural_scroll", "bool": true, "set": true }' ;;
      input:touchpad:scroll_factor) echo '{"option": "input:touchpad:scroll_factor", "float": 0.400000, "set": true }' ;;
      input:accel_profile) echo '{"option": "input:accel_profile", "str": "[[EMPTY]]", "set": false }' ;;
      *) echo "no such option" ;;
    esac
    ;;
  "devices -j") echo '{"mice":[{"name":"logitech-mouse"},{"name":"elan-touchpad"},{"name":"Apple Magic Trackpad"}]}' ;;
  "clients -j") echo '[{"class":"foot"},{"class":"firefox"},{"class":"foot"},{"class":""}]' ;;
esac
SH
chmod +x "$stub_bin/hyprctl"

: >"$log"
PATH="$stub_bin:$PATH" HYPRCTL_LOG="$log" "$ROOT/bin/omarchy-touchpad-apply" ||
  fail "applying settings evaluates the touchpad module"
grep -Fqx 'eval require("default.hypr.touchpad").apply()' "$log" ||
  fail "applying settings evaluates the touchpad module" "$(cat "$log")"
pass "applying settings evaluates the touchpad module"

: >"$log"
PATH="$stub_bin:$PATH" HYPRCTL_LOG="$log" "$ROOT/bin/omarchy-touchpad-apply" --reload
grep -Fqx 'reload' "$log" || fail "removing a setting reloads Hyprland" "$(cat "$log")"
pass "removing a setting reloads Hyprland"

if error=$(PATH="$stub_bin:$PATH" HYPRCTL_LOG="$log" HYPRCTL_FAIL=1 "$ROOT/bin/omarchy-touchpad-apply" 2>&1 >/dev/null); then
  fail "a rejected apply exits with an error"
fi
[[ $error == "error: boom" ]] || fail "a rejected apply passes Hyprland's error through" "$error"
pass "a rejected apply exits with Hyprland's error"

printf 'elan-touchpad\n' >"$tmpdir/home/.local/state/omarchy/toggles/hypr/touchpad-disabled-name"
status=$(HOME="$tmpdir/home" PATH="$stub_bin:$PATH" HYPRCTL_LOG="$log" "$ROOT/bin/omarchy-touchpad-status")
jq -e '.options == {natural_scroll: true, scroll_factor: 0.4, accel_profile: ""}' <<<"$status" >/dev/null ||
  fail "status reports the running options" "$status"
pass "status reports the running options"
[[ $(jq -c '.devices' <<<"$status") == '["elan-touchpad","Apple Magic Trackpad"]' ]] ||
  fail "status lists touchpads and trackpads but not mice" "$status"
pass "status lists touchpads and trackpads but not mice"
[[ $(jq -c '.clients' <<<"$status") == '["firefox","foot"]' ]] ||
  fail "status lists each open window class once" "$status"
pass "status lists each open window class once"
[[ $(jq -r '.disabled' <<<"$status") == "elan-touchpad" ]] ||
  fail "status reports a touchpad disabled by the toggle" "$status"
pass "status reports a touchpad disabled by the toggle"

grep -Fq '"setup.config.touchpad"' "$ROOT/default/omarchy/omarchy-menu.jsonc" &&
  grep -Fq '"action":"omarchy-shell shell summon omarchy.touchpad"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the touchpad window is reachable from Setup > Config"
pass "the touchpad window is reachable from Setup > Config"
