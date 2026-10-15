#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

run_application_bindings() {
  local home="$1"
  local prelude="${2:-}"

  HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_STATE_HOME="$home/.local/state" OMARCHY_PATH="$ROOT" OMARCHY_BINDING_PRELUDE="$prelude" lua - <<'LUA'
package.path = os.getenv("HOME") .. "/.config/?.lua;" .. os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local prelude = os.getenv("OMARCHY_BINDING_PRELUDE") or ""
if prelude ~= "" then
  assert(load(prelude))()
end

hl = {
  dsp = {
    exec_cmd = function(command)
      return { kind = "exec", arg = command }
    end,
  },
  bind = function(keys, dispatcher, opts)
    opts = opts or {}
    if opts.description then
      print(keys .. "\t" .. opts.description)
    end
  end,
}

require("default.hypr.helpers")
require("default.hypr.bindings.applications")
LUA
}

run_omarchy_bindings() {
  local home="$1"
  local prelude="${2:-}"

  HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_STATE_HOME="$home/.local/state" OMARCHY_PATH="$ROOT" OMARCHY_BINDING_PRELUDE="$prelude" lua - <<'LUA'
package.path = os.getenv("HOME") .. "/.config/?.lua;" .. os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

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

local prelude = os.getenv("OMARCHY_BINDING_PRELUDE") or ""
if prelude ~= "" then
  assert(load(prelude))()
end

hl = setmetatable({
  dsp = proxy(),
  bind = function(keys, dispatcher, opts)
    opts = opts or {}
    if opts.description then
      print(keys .. "\t" .. opts.description)
    end
  end,
  config = function() end,
  env = function() end,
  monitor = function() end,
  window_rule = function() end,
  workspace_rule = function() end,
  layer_rule = function() end,
  gesture = function() end,
  animation = function() end,
  curve = function() end,
  exec_cmd = function() end,
  dispatch = function() end,
  on = function() end,
  timer = function() end,
  notification = {
    create = function(notification)
      print("notify\t" .. notification.text)
    end,
  },
  get_config = function() return nil end,
  get_active_window = function() return nil end,
}, {
  __index = function()
    return function()
      return {}
    end
  end,
})

require("default.hypr.omarchy")
LUA
}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

fresh_home="$tmpdir/fresh-home"
mkdir -p "$fresh_home"
fresh_output=$(run_application_bindings "$fresh_home")
grep -Fq $'SUPER + RETURN	Terminal' <<<"$fresh_output" || fail "default application bindings include essentials"
grep -Fq $'SUPER + SHIFT + A	ChatGPT' <<<"$fresh_output" || fail "default application bindings include preinstalled web apps"
grep -Fq $'SUPER + SHIFT + Q	Calculator' <<<"$fresh_output" || fail "default application bindings include the preinstalled calculator"
grep -Fq $'XF86Calculator	Calculator' <<<"$fresh_output" || fail "default application bindings include the calculator hardware key"
pass "default application bindings load from package defaults"

removed_home="$tmpdir/removed-home"
mkdir -p "$removed_home/.local/state/omarchy"
touch "$removed_home/.local/state/omarchy/preinstalls-removed"
removed_output=$(run_omarchy_bindings "$removed_home")
grep -Fq $'SUPER + RETURN	Terminal' <<<"$removed_output" || fail "preinstall removal keeps essential bindings"
if grep -Fq $'SUPER + SHIFT + A	ChatGPT' <<<"$removed_output"; then
  fail "preinstall removal skips preinstalled web app bindings"
fi
if grep -Fq $'	Calculator' <<<"$removed_output"; then
  fail "preinstall removal skips calculator bindings"
fi
pass "preinstall removal flag skips optional application bindings"

variable_home="$tmpdir/variable-home"
mkdir -p "$variable_home"
variable_output=$(run_omarchy_bindings "$variable_home" 'omarchy_preinstalled_bindings = false')
grep -Fq $'SUPER + RETURN	Terminal' <<<"$variable_output" || fail "preinstalled binding variable keeps essential bindings"
if grep -Fq $'SUPER + SHIFT + A	ChatGPT' <<<"$variable_output"; then
  fail "preinstalled binding variable skips optional application bindings"
fi
if grep -Fq $'	Calculator' <<<"$variable_output"; then
  fail "preinstalled binding variable skips calculator bindings"
fi
pass "preinstalled binding variable skips optional application bindings"

no_bindings_home="$tmpdir/no-bindings-home"
mkdir -p "$no_bindings_home"
no_bindings_output=$(run_omarchy_bindings "$no_bindings_home" 'omarchy_default_bindings = false') ||
  fail "default binding variable disables all Omarchy bindings"
[[ -z $no_bindings_output ]] || fail "default binding variable disables all Omarchy bindings" "$no_bindings_output"
pass "default binding variable disables all Omarchy bindings"

dictation_home="$tmpdir/dictation-home"
missing_bin="$tmpdir/missing-bin"
mkdir -p "$dictation_home" "$missing_bin"
ln -s "$(command -v lua)" "$missing_bin/lua"
ln -s "$(command -v lspci)" "$missing_bin/lspci"
ln -s "$(command -v sort)" "$missing_bin/sort"
dictation_output=$(PATH="$missing_bin" run_omarchy_bindings "$dictation_home") ||
  fail "unconfigured dictation leaves application shortcuts available"
if grep -Fq 'dictation' <<<"$dictation_output"; then fail "unconfigured dictation leaves application shortcuts available"; fi
cat > "$missing_bin/omarchy-default-dictation" <<'SH'
#!/bin/bash
echo future-backend
SH
chmod +x "$missing_bin/omarchy-default-dictation"
dictation_output=$(PATH="$missing_bin" run_omarchy_bindings "$dictation_home") ||
  fail "a selected backend that is not installed leaves application shortcuts available"
if grep -Fq 'dictation' <<<"$dictation_output"; then fail "a selected backend that is not installed leaves application shortcuts available"; fi
printf '#!/bin/bash\nexit 0\n' > "$missing_bin/future-backend"
chmod +x "$missing_bin/future-backend"
dictation_output=$(PATH="$missing_bin" run_omarchy_bindings "$dictation_home")
for binding in \
  $'ALT + SPACE\tToggle dictation' \
  $'ALT + Alt_R\tStart dictation (push-to-talk)' \
  $'ALT + Alt_R\tStop dictation (push-to-talk)'; do
  grep -Fq "$binding" <<<"$dictation_output" || fail "dictation bindings load for any selected backend" "$binding"
done
pass "dictation bindings require an installed selection without hardcoding backends"

# Lazydocker is optional on new installs, while existing installs keep the hotkey.
lazydocker_bin="$tmpdir/lazydocker-bin"
mkdir -p "$lazydocker_bin"
touch "$lazydocker_bin/lazydocker"
chmod +x "$lazydocker_bin/lazydocker"
lazydocker_output=$(PATH="$lazydocker_bin:$PATH" run_application_bindings "$fresh_home")
grep -Fqx $'SUPER + SHIFT + D\tDocker' <<<"$lazydocker_output" ||
  fail "installed Lazydocker keeps its Docker shortcut"
pass "installed Lazydocker keeps its Docker shortcut"

missing_lazydocker_output=$(PATH="$missing_bin" run_application_bindings "$fresh_home") ||
  fail "missing Lazydocker skips its Docker shortcut"
if grep -Fq $'SUPER + SHIFT + D\tDocker' <<<"$missing_lazydocker_output"; then
  fail "missing Lazydocker skips its Docker shortcut"
fi
pass "missing Lazydocker skips its Docker shortcut"

# The original scratchpad stays separate from the Quake console.
scratchpad_home="$tmpdir/scratchpad-home"
mkdir -p "$scratchpad_home"
scratchpad_output=$(run_omarchy_bindings "$scratchpad_home")
grep -Fqx $'SUPER + S	Toggle scratchpad' <<<"$scratchpad_output" ||
  fail "scratchpad keeps its existing toggle binding"
grep -Fqx $'SUPER + grave	Toggle Quake console' <<<"$scratchpad_output" ||
  fail "Quake console has its own toggle binding"
grep -Fqx $'SUPER + ALT + S	Move window to scratchpad' <<<"$scratchpad_output" ||
  fail "scratchpad keeps its existing move binding"
grep -Fqx $'SUPER + SHIFT + grave	Move window to Quake console' <<<"$scratchpad_output" ||
  fail "Quake console has its own move binding"
pass "scratchpad and Quake console have separate bindings"

# The panel hotkeys claim a row of keys that workspace switching already uses
# under other modifiers, so the count matters as much as the bindings: a tenth
# claim on SUPER + CTRL + a number is a collision with one of these.
panels_home="$tmpdir/panels-home"
mkdir -p "$panels_home"
panels_output=$(run_omarchy_bindings "$panels_home")
for panel in 1 2 3 4 5 6 7 8 9; do
  grep -Fqx "SUPER + CTRL + code:$((panel + 9))"$'\t'"Bar panel $panel" <<<"$panels_output" ||
    fail "bar panel hotkeys count the right section" "$panel"
done
number_claims=$(cut -f1 <<<"$panels_output" | grep -cE '^SUPER \+ CTRL \+ code:1[0-9]$' || true)
(( number_claims == 9 )) ||
  fail "only the bar panel hotkeys bind SUPER + CTRL + a number" "$number_claims"
pass "bar panel hotkeys bind SUPER + CTRL + a number without a collision"

# Add-ons in ~/.config/hypr/extensions load in name order after the defaults,
# so they can rebind them, and a broken one doesn't stop the rest.
extensions_home="$tmpdir/extensions-home"
extensions="$extensions_home/.config/hypr/extensions"
mkdir -p "$extensions/nested"
echo 'o.rebind("SUPER + W", "Extension close", "true")' >"$extensions/b-rebind.lua"
echo 'o.bind("SUPER + F12", "Extension first", "true")' >"$extensions/a-first.lua"
echo 'error("boom")' >"$extensions/c-broken.lua"
echo 'o.bind("SUPER + F11", "Extension last", "true")' >"$extensions/d-last.lua"
echo 'o.bind("SUPER + F10", "Nested extension", "true")' >"$extensions/nested/deep.lua"
extensions_output=$(run_omarchy_bindings "$extensions_home") || fail "a config with extensions loads" "$extensions_output"
default_close=$(grep -nxF $'SUPER + W\tClose window' <<<"$extensions_output" | cut -d: -f1)
order=$(grep -E $'\tExtension |^notify\t' <<<"$extensions_output" | cut -f2 | cut -d" " -f1-5)
expected=$'Extension first\nExtension close\nCould not load Hyprland extension\nExtension last'
[[ $order == "$expected" ]] || fail "extensions load in name order, skipping a broken one" "$extensions_output"
(( default_close < $(grep -nxF $'SUPER + W\tExtension close' <<<"$extensions_output" | cut -d: -f1) )) ||
  fail "extensions load after Omarchy's default bindings" "$extensions_output"
if grep -q 'Nested extension' <<<"$extensions_output"; then
  fail "only top-level extension files load" "$extensions_output"
fi
pass "extensions load in name order after the defaults, and a broken one is reported and skipped"

no_defaults_output=$(run_omarchy_bindings "$extensions_home" 'omarchy_default_bindings = false')
grep -qxF $'SUPER + F12\tExtension first' <<<"$no_defaults_output" ||
  fail "extensions load with Omarchy's default bindings off" "$no_defaults_output"
pass "extensions load with Omarchy's default bindings off"
