#!/bin/bash

set -euo pipefail

# Any theme can describe Hyprland's look in hyprland.toml, including one cloned
# from a git repo, which may not ship hyprland.lua. default/hypr/theme-looknfeel.lua
# reads it as data against a fixed list of options and never runs any of it.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

module="$ROOT/default/hypr/theme-looknfeel.lua"

# Apply a hyprland.toml against a stand-in hl that prints one line per call.
cat >"$test_tmp/record.lua" <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path

local function show(value)
  if type(value) == "table" then
    local parts = {}
    for index, item in ipairs(value) do
      parts[index] = show(item)
    end
    return "{" .. table.concat(parts, ",") .. "}"
  end
  return tostring(value)
end

local function config(prefix, tree)
  local keys = {}
  for key in pairs(tree) do
    keys[#keys + 1] = key
  end
  table.sort(keys)

  for _, key in ipairs(keys) do
    local value = tree[key]
    if type(value) == "table" and value[1] == nil then
      config(prefix .. key .. ".", value)
    else
      print(("config %s%s = %s (%s)"):format(prefix, key, show(value), math.type(value) or type(value)))
    end
  end
end

hl = {
  config = function(tree)
    config("", tree)
  end,
  window_rule = function(rule)
    print(("window tag=%s opacity=%s"):format(rule.match.tag, rule.opacity))
  end,
  layer_rule = function(rule)
    print(("layer %s blur=%s popups=%s ignore_alpha=%s"):format(rule.match.namespace, tostring(rule.blur), tostring(rule.blur_popups), tostring(rule.ignore_alpha)))
  end,
  curve = function(name, curve)
    local points = curve.points
    print(("curve %s %s"):format(name, show({ points[1][1], points[1][2], points[2][1], points[2][2] })))
  end,
  animation = function(spec)
    print(("animation %s enabled=%s speed=%s bezier=%s style=%s"):format(spec.leaf, tostring(spec.enabled), tostring(spec.speed), tostring(spec.bezier), tostring(spec.style)))
  end,
}

require("default.hypr.helpers")
local look = require("default.hypr.theme-looknfeel")

-- Anything that could run code fails loudly, and leaves a trace in case the
-- failure itself is swallowed.
local marker = os.getenv("TRAP_MARKER") or ""
if marker ~= "" then
  local function trap(name)
    return function()
      local file = io.open(marker, "a")
      file:write(name .. "\n")
      file:close()
      error(name .. " was called while applying hyprland.toml")
    end
  end

  load, loadfile, dofile, require = trap("load"), trap("loadfile"), trap("dofile"), trap("require")
  os.execute, os.exit, io.popen = trap("os.execute"), trap("os.exit"), trap("io.popen")
end

look.apply_file(arg[1])
LUA

look() {
  ROOT="$ROOT" HOME="$test_tmp" TRAP_MARKER="${TRAP_MARKER:-}" lua "$test_tmp/record.lua" "$1"
}

expect() {
  grep -Fxq -- "$2" <<<"$1" || fail "$3" "missing: $2"$'\n'"$1"
}

# ------------------------------------------------------------ accepted values

cat >"$test_tmp/good.toml" <<'TOML'
# A dotted key works before any section.
decoration.blur.size = 20

[general]
gaps_in = 4
gaps_out = 8.0   # an integer written as a float
border_size = 2

[decoration]
rounding = 10
rounding_power = 3
active_opacity = 0.92
dim_inactive = false

[decoration.shadow]
enabled = true
color = "rgba(00000055)"
color_inactive = 'rgba(0, 0, 0, 0.3)'
offset = [0, 5]

[decoration.blur]
enabled = true
passes = 3
contrast = 1.15
popups = true

[opacity]
windows = [0.92, 0.88]
browsers = [0.95]
terminals = [0.80, 0.76, 1]

[shell]
blur = true
blur_ignore_alpha = 0.33

[curves]
water = [0.22, 0.9, 0.36, 1.0]
overshot = [0.05, 0.9, 0.1, 1.05]

# Listed before its parent on purpose.
[animations.windowsIn]
speed = 2.8
curve = "water"
style = "popin 80%"

[animations.windows]
speed = 3
curve = "default"

[animations.layersIn]
speed = 1.5
curve = "overshot"
style = "slide top"

[animations.workspaces]
enabled = false
TOML

output=$(look "$test_tmp/good.toml") || fail "a valid hyprland.toml applies" "$output"

for line in \
  "config decoration.blur.size = 20 (integer)" \
  "config general.gaps_in = 4 (integer)" \
  "config general.gaps_out = 8 (integer)" \
  "config general.border_size = 2 (integer)" \
  "config decoration.rounding = 10 (integer)" \
  "config decoration.rounding_power = 3 (integer)" \
  "config decoration.active_opacity = 0.92 (float)" \
  "config decoration.dim_inactive = false (boolean)" \
  "config decoration.shadow.enabled = true (boolean)" \
  "config decoration.shadow.color = rgba(00000055) (string)" \
  "config decoration.shadow.color_inactive = rgba(0, 0, 0, 0.3) (string)" \
  "config decoration.shadow.offset = {0,5} (table)" \
  "config decoration.blur.enabled = true (boolean)" \
  "config decoration.blur.passes = 3 (integer)" \
  "config decoration.blur.contrast = 1.15 (float)" \
  "config decoration.blur.popups = true (boolean)"; do
  expect "$output" "$line" "hyprland.toml sets the Hyprland options it lists"
done
pass "hyprland.toml sets the Hyprland options it lists, integers as integers"

expect "$output" "window tag=default-opacity opacity=0.92 0.88" "[opacity] windows sets the default-opacity tag"
expect "$output" "window tag=chromium-based-browser opacity=0.95" "[opacity] browsers sets Chromium-based browsers"
expect "$output" "window tag=firefox-based-browser opacity=0.95" "[opacity] browsers sets Firefox-based browsers"
expect "$output" "window tag=terminal opacity=0.8 0.76 1" "[opacity] terminals sets the terminal tag"
pass "[opacity] sets window opacity through Omarchy's window tags"

grep -Eq '^layer \^\(omarchy-bar\|.*\)\$ blur=true popups=true ignore_alpha=0\.33$' <<<"$output" ||
  fail "[shell] blur frosts Omarchy's shell surfaces" "$output"
pass "[shell] blur frosts Omarchy's shell surfaces, popups included"

expect "$output" "curve theme_water {0.22,0.9,0.36,1.0}" "theme curves are registered under a theme_ prefix"
expect "$output" "animation windowsIn enabled=true speed=2.8 bezier=theme_water style=popin 80%" "an animation uses a theme curve and style"
expect "$output" "animation windows enabled=true speed=3 bezier=default style=nil" "an animation may use Hyprland's default curve"
expect "$output" "animation layersIn enabled=true speed=1.5 bezier=theme_overshot style=slide top" "a layer animation takes a layer style"
expect "$output" "animation workspaces enabled=false speed=nil bezier=nil style=nil" "an animation can be switched off"
windows_line=$(grep -n '^animation windows ' <<<"$output" | cut -d: -f1)
windows_in_line=$(grep -n '^animation windowsIn ' <<<"$output" | cut -d: -f1)
(( windows_line < windows_in_line )) || fail "a parent animation is applied before its children" "$output"
pass "curves and animations apply, parents before children"

# ------------------------------------------------------------ refused values

cat >"$test_tmp/refused.toml" <<'TOML'
# Nothing here is a look option Omarchy lets a theme set, or a valid one.
exec = "notify-send hello"
misc.disable_autoreload = true
input.kb_layout = "us"
general.layout = "master"

[general]
gaps_in = 4.5
border_size = 21

[decoration]
rounding = "10"
rounding_power = 1
active_opacity = 1.5
inactive_opacity = -0.1

[decoration.blur]
enabled = 1
passes = 11
size = [20]

[decoration.shadow]
color = "red"
color_inactive = "rgba(300, 0, 0, 1)"
offset = [0, 5, 9]

[opacity]
windows = [0.9, 0.8, 0.7, 0.6]
terminals = [1.2]
browsers = "0.9 0.8"

[shell]
blur = "yes"

[curves]
wild = [1.5, 0, 0.5, 1]
fine = [0.2, 0, 0, 1]

[animations.windows]
speed = 3
curve = "wild"

[animations.windowsIn]
speed = 3
curve = "easeOutQuint"

[animations.bogusLeaf]
speed = 3
curve = "fine"

[animations.fade]
speed = 0
curve = "fine"

[animations.layersIn]
speed = 2
curve = "fine"
style = "gnomed"
TOML

output=$(look "$test_tmp/refused.toml") || fail "an invalid hyprland.toml applies what is valid" "$output"

! grep -Eq '^(config|window|layer) ' <<<"$output" || fail "a value outside the list, its type or its range is skipped" "$output"
pass "a value outside the list, its type or its range is skipped"

expect "$output" "curve theme_fine {0.2,0,0,1}" "a valid curve beside an invalid one still registers"
! grep -q '^curve theme_wild' <<<"$output" || fail "a curve with x outside 0-1 is skipped" "$output"
expect "$output" "animation layersIn enabled=true speed=2 bezier=theme_fine style=nil" "a style from another family is dropped, not the animation"
[[ $(grep -c '^animation ' <<<"$output") == 1 ]] ||
  fail "an animation with an unknown leaf, an unknown or invalid curve, or no speed is skipped" "$output"
pass "curves and animations are checked before Hyprland sees them"

[[ -z $(look "$test_tmp/missing.toml") ]] || fail "a theme without hyprland.toml changes nothing"
head -c 70000 /dev/zero | tr '\0' '#' >"$test_tmp/huge.toml"
printf '\n[general]\ngaps_in = 4\n' >>"$test_tmp/huge.toml"
[[ -z $(look "$test_tmp/huge.toml") ]] || fail "a hyprland.toml far larger than any theme needs is ignored"
pass "a missing or oversized hyprland.toml changes nothing"

# ------------------------------------------------------------ never code

cat >"$test_tmp/hostile.toml" <<'TOML'
rounding = os.exit(1)
[decoration]
rounding = os.execute("touch /tmp/omarchy-theme-looknfeel-pwned")
active_opacity = 0.5 os.exit(1)
shadow.color = "rgba(00000055)" .. os.execute("id")
shadow.color_inactive = "rgba(00000055)\" os.exit(1) --"
[[general]]
gaps_in = 4 --[[
]] os.exit(1) --[[
border_size = [[2]]
gaps_out = load("os.exit(1)")()
[animations.windows]
speed = 1
curve = "default"
style = "popin 80%\") os.exit(1) --"
TOML

output=$(TRAP_MARKER="$test_tmp/trapped" look "$test_tmp/hostile.toml") ||
  fail "a hyprland.toml written as Lua is read without running it" "$(cat "$test_tmp/trapped" 2>/dev/null)"
[[ ! -e $test_tmp/trapped ]] || fail "a hyprland.toml written as Lua is read without running it" "$(cat "$test_tmp/trapped")"
! grep -q '^config ' <<<"$output" || fail "Lua in hyprland.toml values is not a value" "$output"
expect "$output" "animation windows enabled=true speed=1 bezier=default style=nil" "a style carrying Lua is dropped"
pass "a hyprland.toml written as Lua is read without running it"

if grep -nE '(^|[^.%w_])(load|loadstring|loadfile|dofile)[[:space:]]*\(|os\.execute|os\.exit|io\.popen' "$module"; then
  fail "theme-looknfeel.lua never compiles, runs or shells out" "the lines above can turn theme data into code"
fi
pass "theme-looknfeel.lua never compiles, runs or shells out"

# ------------------------------------------------------------ wiring

order=$(grep -nE 'theme-looknfeel|omarchy\.current\.theme\.hyprland' "$ROOT/default/hypr/omarchy.lua" | cut -d: -f1 | tr '\n' ' ')
read -r look_line lua_line <<<"$order"
[[ -n ${look_line:-} && -n ${lua_line:-} ]] && (( look_line < lua_line )) ||
  fail "omarchy.lua applies hyprland.toml before the theme's own hyprland.lua"
pass "omarchy.lua applies hyprland.toml before the theme's own hyprland.lua"

# Every shell surface is either frosted by [shell] blur or deliberately left out,
# so a new surface fails here until someone decides which.
excluded=(omarchy-background omarchy-bar-drag-ghost omarchy-bar-move-ghost omarchy-keyboard-panel-dismiss omarchy-lock-preview)
mapfile -t blurred < <(ROOT="$ROOT" HOME="$test_tmp" lua -e '
  package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
  for _, namespace in ipairs(require("default.hypr.theme-looknfeel").shell_blur_namespaces) do print(namespace) end
')
mapfile -t surfaces < <(grep -rhoE '(WlrLayershell\.namespace|layerNamespace):[[:space:]]*"omarchy-[a-z-]+"' "$ROOT/shell" --include=*.qml | grep -oE 'omarchy-[a-z-]+' | sort -u)

(( ${#surfaces[@]} > 0 )) || fail "the shell's layer namespaces can be found"
for surface in "${surfaces[@]}"; do
  [[ " ${blurred[*]} ${excluded[*]} " == *" $surface "* ]] ||
    fail "every shell surface is classified for [shell] blur" "$surface is in neither theme-looknfeel.lua's list nor this test's excluded list"
done
for namespace in "${blurred[@]}"; do
  [[ " ${surfaces[*]} " == *" $namespace "* ]] ||
    fail "every surface [shell] blur names exists" "$namespace is not a layer namespace in shell/"
done
pass "every shell surface is classified for [shell] blur"

# ------------------------------------------------------------ Hyprland agrees

# Hand every option, opacity tag, animation leaf and style the module accepts to
# Hyprland's own config check, so the list cannot drift from what Hyprland takes.
if ! command -v Hyprland >/dev/null 2>&1; then
  skip "Hyprland accepts everything hyprland.toml can set (Hyprland is not installed)"
else
  home="$test_tmp/hypr-home"
  mkdir -p "$home/.config/hypr" "$home/.local/state"
  cp "$ROOT"/config/hypr/*.lua "$home/.config/hypr/"

  cat >"$home/.config/hypr/looknfeel.lua" <<'LUA'
local look = require("default.hypr.theme-looknfeel")
local curve = { 0.2, 0, 0, 1 }
local values = { ["curves.check"] = curve }
local expected = 0

for path, spec in pairs(look.options) do
  local kind, min, max = spec[1], spec[2], spec[3]
  if kind == "bool" then
    values[path] = true
  elseif kind == "int" then
    values[path] = (min + max) // 2
  elseif kind == "float" then
    values[path] = (min + max) / 2
  elseif kind == "color" then
    values[path] = "rgba(00000055)"
  elseif kind == "vec2" then
    values[path] = { min, max }
  end
  expected = expected + 1
end

values["opacity.windows"] = { 0.9, 0.8, 1 }
values["opacity.browsers"] = { 0.9 }
values["opacity.terminals"] = { 0.8, 0.7 }
values["shell.blur"] = true
values["shell.blur_ignore_alpha"] = 0.3

for _, animation in ipairs(look.animations) do
  values["animations." .. animation[1] .. ".speed"] = 2
  values["animations." .. animation[1] .. ".curve"] = "check"
end

-- Count what reaches Hyprland, so a check that skipped everything cannot pass.
local real_config, real_animation = hl.config, hl.animation
local set, animated, styled = 0, 0, nil

local function count(tree)
  for _, value in pairs(tree) do
    if type(value) == "table" and value[1] == nil then
      count(value)
    else
      set = set + 1
    end
  end
end

hl.config = function(tree)
  count(tree)
  return real_config(tree)
end

hl.animation = function(spec)
  animated = animated + 1
  assert(styled == nil or spec.style == styled, "style " .. tostring(styled) .. " did not reach Hyprland")
  return real_animation(spec)
end

look.apply(values)
assert(set == expected, ("%d of %d options reached Hyprland"):format(set, expected))
assert(animated == #look.animations, ("%d of %d animations reached Hyprland"):format(animated, #look.animations))

for _, animation in ipairs(look.animations) do
  local leaf, family = animation[1], animation[2]
  if family then
    local styles = {}
    for style in pairs(look.styles[family]) do
      styles[#styles + 1] = style
    end
    for style in pairs(look.percent_styles[family] or {}) do
      styles[#styles + 1] = style .. " 50%"
    end
    table.sort(styles)

    for _, style in ipairs(styles) do
      styled = style
      look.apply({
        ["curves.check"] = curve,
        ["animations." .. leaf .. ".speed"] = 2,
        ["animations." .. leaf .. ".curve"] = "check",
        ["animations." .. leaf .. ".style"] = style,
      })
    end
  end
end

hl.config, hl.animation = real_config, real_animation
LUA

  verify_output=$(cd "$test_tmp" && HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_STATE_HOME="$home/.local/state" \
    XDG_RUNTIME_DIR="$test_tmp" OMARCHY_PATH="$ROOT" timeout 60 Hyprland --verify-config -c "$home/.config/hypr/hyprland.lua" 2>&1) || true

  grep -qx "config ok" <<<"$verify_output" ||
    fail "Hyprland accepts everything hyprland.toml can set" "$(grep -vE '^[[:space:]]+no file' <<<"$verify_output")"
  pass "Hyprland accepts everything hyprland.toml can set"
fi

# ------------------------------------------------------------ Hyprland's ranges

# The ranges in theme-looknfeel.lua are the ones Hyprland publishes, except for
# gaps and the shadow offset, which publish none. A running Hyprland is the only place to read them.
require_compositor "theme-looknfeel.lua uses the ranges Hyprland publishes"
require_command jq

descriptions=$(hyprctl descriptions -j) || fail "hyprctl describes Hyprland's options"

while read -r path min max; do
  name=${path//./:}
  published=$(jq -r --arg name "$name" '.[] | select(.name == $name) | "\(.min) \(.max)"' <<<"$descriptions")
  [[ -n $published ]] || fail "every option theme-looknfeel.lua accepts is one Hyprland describes" "$name"

  if [[ $published == "null null" ]]; then
    [[ $path == general.gaps_* || $path == "decoration.shadow.offset" || $min == "-" ]] ||
      fail "only options Hyprland gives no range get one of Omarchy's own" "$name has no published range but is limited to $min..$max"
  else
    read -r published_min published_max <<<"$published"
    awk -v a="$min" -v b="$published_min" -v c="$max" -v d="$published_max" 'BEGIN { exit !(a == b && c == d) }' ||
      fail "theme-looknfeel.lua uses the ranges Hyprland publishes" "$name: $min..$max here, $published_min..$published_max in Hyprland"
  fi
done < <(ROOT="$ROOT" HOME="$test_tmp" lua -e '
  package.path = os.getenv("ROOT") .. "/?.lua;" .. package.path
  for path, spec in pairs(require("default.hypr.theme-looknfeel").options) do
    print(path, spec[2] or "-", spec[3] or "-")
  end
')
pass "theme-looknfeel.lua uses the ranges Hyprland publishes"
