#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua
require_command xkbcli

# Load the real clipboard bindings and fire them against a fake Hyprland.
# Layout and variant are the configured primary keymap, not the active group.
run_clipboard_shortcuts() {
  local layout="$1"
  local variant="$2"
  local file="${3:-}"

  TEST_KB_LAYOUT="$layout" TEST_KB_VARIANT="$variant" TEST_KB_FILE="$file" OMARCHY_PATH="$ROOT" \
    lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local bindings = {}
local active_tags = {}
local current_binding = ""
local config = {
  ["input.kb_layout"] = os.getenv("TEST_KB_LAYOUT"),
  ["input.kb_variant"] = os.getenv("TEST_KB_VARIANT"),
  ["input.kb_model"] = "",
  ["input.kb_options"] = os.getenv("TEST_KB_OPTIONS") or "",
  ["input.kb_rules"] = "",
  ["input.kb_file"] = os.getenv("TEST_KB_FILE"),
}

hl = {
  dsp = {
    exec_cmd = function(command)
      return { command = command }
    end,
    send_key_state = function(spec)
      return spec
    end,
    global = function(name)
      return { global = name }
    end,
  },
  bind = function(keys, dispatcher)
    bindings[keys] = dispatcher
  end,
  dispatch = function(dispatcher)
    print(table.concat({
      current_binding,
      dispatcher.state,
      dispatcher.mods,
      dispatcher.key,
    }, "\t"))
  end,
  get_active_window = function()
    return { tags = active_tags }
  end,
  get_config = function(key)
    return config[key]
  end,
  timer = function(callback, opts)
    print(table.concat({
      current_binding,
      "timer",
      tostring(opts.timeout),
      tostring(opts.type),
    }, "\t"))
    callback()
  end,
}

require("default.hypr.helpers")
require("default.hypr.bindings.clipboard")

local function invoke(label, keys)
  current_binding = label
  bindings[keys]()
end

invoke("gui-select-all", "SUPER + A")
invoke("gui-copy", "SUPER + C")
invoke("gui-paste", "SUPER + V")
current_binding = "dispatch-paste"
o.universal_paste()
invoke("gui-cut", "SUPER + X")

active_tags = { "terminal*" }
invoke("terminal-copy", "SUPER + C")
invoke("terminal-paste", "SUPER + V")

local after_layout = os.getenv("TEST_AFTER_LAYOUT") or ""
if after_layout ~= "" then
  active_tags = {}
  config["input.kb_layout"] = after_layout
  config["input.kb_variant"] = os.getenv("TEST_AFTER_VARIANT") or ""
  invoke("after-copy", "SUPER + C")
end
LUA
}

expect_lines() {
  local description="$1"
  local output="$2"
  shift 2

  local line
  for line in "$@"; do
    grep -Fqx "$line" <<<"$output" || fail "$description" "$output"
  done
  pass "$description"
}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

qwerty_output=$(TEST_KB_OPTIONS="omarchy:shift_caps_compose,grp:alts_toggle" TEST_AFTER_LAYOUT="us" TEST_AFTER_VARIANT="dvorak" run_clipboard_shortcuts "us,th" "") ||
  fail "universal clipboard shortcuts run for a us,th keymap" "$qwerty_output"
expect_lines "universal clipboard shortcuts resolve primary QWERTY letters for us,th" "$qwerty_output" \
  $'gui-select-all\tdown\tCTRL\tcode:38' \
  $'gui-select-all\ttimer\t50\toneshot' \
  $'gui-select-all\tup\tCTRL\tcode:38' \
  $'gui-copy\tdown\tCTRL\tcode:54' \
  $'gui-copy\tup\tCTRL\tcode:54' \
  $'gui-paste\tdown\tCTRL\tcode:55' \
  $'dispatch-paste\tdown\tCTRL\tcode:55' \
  $'gui-cut\tdown\tCTRL\tcode:53' \
  $'after-copy\tdown\tCTRL\tcode:31' \
  $'terminal-copy\tdown\tCTRL SHIFT\tcode:54' \
  $'terminal-paste\tdown\tCTRL SHIFT\tcode:55'

dvorak_output=$(run_clipboard_shortcuts "us,ru" "dvorak,") ||
  fail "universal clipboard shortcuts run for primary Dvorak" "$dvorak_output"
expect_lines "universal clipboard shortcuts keep logical letters on primary Dvorak" "$dvorak_output" \
  $'gui-copy\tdown\tCTRL\tcode:31' \
  $'gui-paste\tdown\tCTRL\tcode:60' \
  $'gui-cut\tdown\tCTRL\tcode:56' \
  $'terminal-copy\tdown\tCTRL SHIFT\tcode:31' \
  $'terminal-paste\tdown\tCTRL SHIFT\tcode:60'

colemak_output=$(run_clipboard_shortcuts "us" "colemak_dh") ||
  fail "universal clipboard shortcuts run for primary Colemak-DH" "$colemak_output"
expect_lines "universal clipboard shortcuts keep logical letters on primary Colemak-DH" "$colemak_output" \
  $'gui-copy\tdown\tCTRL\tcode:53' \
  $'gui-paste\tdown\tCTRL\tcode:55' \
  $'gui-cut\tdown\tCTRL\tcode:52'

azerty_output=$(run_clipboard_shortcuts "fr,ru" ",") ||
  fail "universal clipboard shortcuts run for primary French AZERTY" "$azerty_output"
expect_lines "select-all resolves A from primary French AZERTY" "$azerty_output" \
  $'gui-select-all\tdown\tCTRL\tcode:24'

third_level_output=$(run_clipboard_shortcuts "us" "3l") ||
  fail "universal clipboard shortcuts run for us(3l)" "$third_level_output"
expect_lines "select-all resolves the unshifted A, not a letter on a higher level" "$third_level_output" \
  $'gui-select-all\tdown\tCTRL\tcode:41'

kb_file_output=$(run_clipboard_shortcuts "us" "" "$tmpdir/custom.xkb") ||
  fail "universal clipboard shortcuts run with a keymap file" "$kb_file_output"
expect_lines "a keymap file keeps the named clipboard key" "$kb_file_output" \
  $'gui-paste\tdown\tCTRL\tV' \
  $'gui-copy\tdown\tCTRL\tC'

stub_bin="$tmpdir/bin"
mkdir -p "$stub_bin"
printf '#!/bin/bash\nexit 1\n' > "$stub_bin/xkbcli"
chmod +x "$stub_bin/xkbcli"
fallback_output=$(PATH="$stub_bin:$PATH" run_clipboard_shortcuts "us,th" "") ||
  fail "universal clipboard shortcuts run when xkbcli fails" "$fallback_output"
expect_lines "a failed layout lookup keeps the named clipboard key" "$fallback_output" \
  $'gui-copy\tdown\tCTRL\tC' \
  $'gui-paste\tdown\tCTRL\tV' \
  $'gui-cut\tdown\tCTRL\tX'
