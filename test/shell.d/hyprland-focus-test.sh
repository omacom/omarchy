#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
state_home="$home_dir/.local/state"
toggles_dir="$state_home/omarchy/toggles/hypr"
mkdir -p "$stub_dir" "$home_dir"
export TEST_LOG="$tmpdir/commands.log"
: >"$TEST_LOG"

cat >"$stub_dir/hyprctl" <<'STUB'
#!/bin/bash
printf 'hyprctl %s\n' "$*" >>"$TEST_LOG"
[[ ${FAIL_COMMAND:-} != "hyprctl" ]]
STUB
cat >"$stub_dir/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf 'notification %s\n' "$*" >>"$TEST_LOG"
STUB
for command in mkdir cp rm; do
  cat >"$stub_dir/$command" <<STUB
#!/bin/bash
[[ \${FAIL_COMMAND:-} != "$command" ]] || exit 1
exec /usr/bin/$command "\$@"
STUB
done
chmod +x "$stub_dir"/*

run() {
  HOME="$home_dir" XDG_STATE_HOME="$state_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" "$@"
}

menu_check() {
  local mode guard
  mode=$(run omarchy-hyprland-focus)
  for choice in theme dim; do
    guard=$(node - "$ROOT" "$choice" <<'JS'
const root = process.argv[2]
const menu = require(root + '/shell/plugins/menu/MenuModel.js')
const fs = require('fs')
const items = menu.parseMenuJsonc(fs.readFileSync(root + '/default/omarchy/omarchy-menu.jsonc', 'utf8'))
const item = items.find(item => item.id === 'appearance.windows.focus.' + process.argv[3])
if (!item || item.action !== 'omarchy-hyprland-focus ' + process.argv[3] || item.aliases.length || !item.checked) process.exit(1)
process.stdout.write(item.checked)
JS
    ) || fail "focus menu actions and guards exist without aliases"
    if run bash -c "$guard"; then
      [[ $choice == "$mode" ]] || fail "only the current focus choice is checked"
    else
      [[ $choice != "$mode" ]] || fail "the current focus choice is checked"
    fi
  done
}

[[ -x $ROOT/bin/omarchy-hyprland-focus ]] || fail "focus command is executable"
[[ $(run omarchy-hyprland-focus) == "theme" ]] || fail "focus defaults to theme"
[[ ! -e $state_home && ! -s $TEST_LOG ]] || fail "default query has no side effects"
menu_check
pass "default focus follows the theme without side effects"

run omarchy-hyprland-focus dim
[[ $(run omarchy-hyprland-focus) == "dim" ]] || fail "dim focus is reported"
cmp -s "$ROOT/default/hypr/toggles/focus-dim.lua" "$toggles_dir/focus-dim.lua" || fail "dim focus persists as the shipped flag"
grep -qx 'hyprctl reload' "$TEST_LOG" || fail "setting focus reloads Hyprland"
grep -q '^notification .*Borderless windows with inactive dimming$' "$TEST_LOG" || fail "setting focus notifies in English"
run omarchy-hyprland-focus dim
cmp -s "$ROOT/default/hypr/toggles/focus-dim.lua" "$toggles_dir/focus-dim.lua" || fail "repeated dim keeps the flag"
menu_check
pass "dim persists, reloads and can be repeated"

# Restoring theme focus must not remove unrelated gap or corner choices.
cp "$ROOT/default/hypr/toggles/window-no-gaps.lua" "$toggles_dir/window-no-gaps.lua"
printf 'unrelated\n' >"$toggles_dir/corners-sharp.lua"
: >"$TEST_LOG"
run omarchy-hyprland-focus theme
[[ $(run omarchy-hyprland-focus) == "theme" && ! -e $toggles_dir/focus-dim.lua ]] || fail "theme removes the focus override"
[[ -f $toggles_dir/window-no-gaps.lua && -f $toggles_dir/corners-sharp.lua ]] || fail "theme keeps unrelated toggles"
grep -qx 'hyprctl reload' "$TEST_LOG" || fail "theme reloads Hyprland"
grep -q '^notification .*Window focus follows the theme$' "$TEST_LOG" || fail "theme notifies in English"
menu_check
pass "theme removes only the focus override and reloads"

for initial in theme dim; do
  run omarchy-hyprland-focus "$initial"
  for invalid in unknown theme dim ''; do
    : >"$TEST_LOG"
    if [[ $invalid == "unknown" || -z $invalid ]]; then
      args=("$invalid")
    else
      args=("$invalid" extra)
    fi
    if run omarchy-hyprland-focus "${args[@]}" 2>/dev/null; then
      fail "invalid and excess arguments are refused"
    fi
    [[ $(run omarchy-hyprland-focus) == "$initial" && ! -s $TEST_LOG ]] || fail "invalid arguments leave state and reload log unchanged"
  done
done
pass "invalid and excess arguments leave both states unchanged"

state_home="$tmpdir/custom state"
run omarchy-hyprland-focus dim
[[ -f $state_home/omarchy/toggles/hypr/focus-dim.lua && $(run omarchy-hyprland-focus) == "dim" ]] || fail "focus follows XDG_STATE_HOME"
menu_check
state_home=""
run omarchy-hyprland-focus theme
run omarchy-hyprland-focus dim
[[ -f $toggles_dir/focus-dim.lua && $(run omarchy-hyprland-focus) == "dim" ]] || fail "empty XDG_STATE_HOME falls back to HOME"
env -u XDG_STATE_HOME HOME="$home_dir" PATH="$stub_dir:$ROOT/bin:$PATH" omarchy-hyprland-focus | grep -qx dim || fail "unset XDG_STATE_HOME falls back to HOME"
menu_check
pass "custom, empty and unset XDG_STATE_HOME are supported"

# Stub failures deterministically, including when run as root.
for failure in mkdir cp; do
  run omarchy-hyprland-focus theme
  : >"$TEST_LOG"
  if FAIL_COMMAND="$failure" run omarchy-hyprland-focus dim 2>/dev/null; then
    fail "failed $failure is reported"
  fi
  [[ ! -e $toggles_dir/focus-dim.lua && ! -s $TEST_LOG ]] || fail "failed $failure does not reload or notify"
done
: >"$TEST_LOG"
if OMARCHY_PATH="$tmpdir/missing" HOME="$home_dir" XDG_STATE_HOME="" PATH="$stub_dir:$ROOT/bin:$PATH" omarchy-hyprland-focus dim 2>/dev/null; then
  fail "missing shipped flag is reported"
fi
[[ ! -e $toggles_dir/focus-dim.lua && ! -s $TEST_LOG ]] || fail "missing flag does not reload or notify"
pass "mkdir, copy and missing flag failures surface without success"

run omarchy-hyprland-focus dim
: >"$TEST_LOG"
if FAIL_COMMAND=rm run omarchy-hyprland-focus theme 2>/dev/null; then
  fail "failed removal is reported"
fi
[[ $(run omarchy-hyprland-focus) == "dim" && ! -s $TEST_LOG ]] || fail "failed removal retains state without reload or success"
for mode in theme dim; do
  : >"$TEST_LOG"
  if FAIL_COMMAND=hyprctl run omarchy-hyprland-focus "$mode" 2>/dev/null; then
    fail "failed reload is reported for $mode"
  fi
  grep -qx 'hyprctl reload' "$TEST_LOG" || fail "reload was attempted"
  ! grep -q '^notification ' "$TEST_LOG" || fail "failed reload never notifies success"
done
pass "removal and reload failures surface without success notifications"

# Keep fallback coverage independent of translations added by catalog sync.
locale_root="$tmpdir/locales"
mkdir -p "$locale_root/default/i18n/"{en,ja,da} "$locale_root/default/hypr/toggles"
cp "$ROOT/default/i18n/"{plural.jq,locales.json} "$locale_root/default/i18n/"
cp "$ROOT/default/i18n/en/cli.json" "$locale_root/default/i18n/en/cli.json"
cp "$ROOT/default/hypr/toggles/focus-dim.lua" "$locale_root/default/hypr/toggles/"
english_dim=$(jq -r '."focus.dim"' "$locale_root/default/i18n/en/cli.json")
for locale in ja da; do
  printf '{}\n' >"$locale_root/default/i18n/$locale/cli.json"
  printf '%s\n' "$locale" >"$tmpdir/language"
  : >"$TEST_LOG"
  HOME="$home_dir" XDG_STATE_HOME="$state_home" OMARCHY_PATH="$locale_root" \
    OMARCHY_LANGUAGE_FILE="$tmpdir/language" PATH="$stub_dir:$ROOT/bin:$PATH" omarchy-hyprland-focus dim
  grep -Fxq "notification -g 󰘇 $english_dim" "$TEST_LOG" || fail "$locale notification falls back to English"
done
pass "Japanese and Danish notifications fall back to English"

if command -v lua >/dev/null; then
  # Use the real sorted loader and its reload cache invalidation. Each reload
  # reapplies the personal/theme baseline before loading the saved flags.
  ROOT="$ROOT" LOAD_DIR="$tmpdir/load" lua - <<'LUA'
package.path = os.getenv("ROOT") .. "/?.lua;" .. os.getenv("LOAD_DIR") .. "/?.lua;" .. package.path
local loader = require("default.hypr.require_all")
local dir = os.getenv("LOAD_DIR")
assert(os.execute('mkdir -p "' .. dir .. '"'))
local state
hl = { config = function(config)
  for section, values in pairs(config) do
    for key, value in pairs(values) do state[section][key] = value end
  end
end }
local function save(name)
  local input = assert(io.open(os.getenv("ROOT") .. "/default/hypr/toggles/" .. name .. ".lua"))
  local output = assert(io.open(dir .. "/" .. name .. ".lua", "w"))
  output:write(input:read("*a"))
  input:close()
  output:close()
end
local function reload(baseline_dim, width, strength)
  state = {
    general = { border_size = width, gaps_in = 8, gaps_out = 9 },
    decoration = { rounding = 10, dim_inactive = baseline_dim, dim_strength = strength },
  }
  loader.files(dir, nil, { reload = true })
end
local function check(width, gaps_in, gaps_out, rounding, dim, strength)
  assert(state.general.border_size == width, "border width")
  assert(state.general.gaps_in == gaps_in and state.general.gaps_out == gaps_out, "gaps")
  assert(state.decoration.rounding == rounding, "rounding")
  assert(state.decoration.dim_inactive == dim, "inactive dimming")
  assert(state.decoration.dim_strength == strength, "dim strength")
end
for _, baseline_dim in ipairs({ false, true }) do
  reload(baseline_dim, 7, 0.65)
  check(7, 8, 9, 10, baseline_dim, 0.65)
  save("focus-dim")
  reload(baseline_dim, 7, 0.65)
  check(0, 8, 9, 10, true, 0.20)
  -- The saved choice also overrides a changed theme on subsequent reloads.
  reload(baseline_dim, 11, 0.80)
  check(0, 8, 9, 10, true, 0.20)
  assert(os.remove(dir .. "/focus-dim.lua"))
  reload(baseline_dim, 11, 0.80)
  check(11, 8, 9, 10, baseline_dim, 0.80)
  save("window-no-gaps")
  save("focus-dim")
  reload(baseline_dim, 7, 0.65)
  check(0, 0, 0, 0, true, 0.20)
  assert(os.remove(dir .. "/focus-dim.lua"))
  reload(baseline_dim, 7, 0.65)
  check(0, 0, 0, 0, baseline_dim, 0.65)
  assert(os.remove(dir .. "/window-no-gaps.lua"))
  reload(baseline_dim, 7, 0.65)
  check(7, 8, 9, 10, baseline_dim, 0.65)
end
LUA
  pass "real Lua loader restores custom borders and dimming, preserves gaps/corners and no-gaps precedence"
else
  skip "lua is not installed"
fi
