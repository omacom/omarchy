#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
mock_bin="$test_dir/bin"
mkdir -p "$test_home/.config/wezterm" "$mock_bin"

cat >"$mock_bin/fc-list" <<'SH'
#!/bin/bash
printf '%s\n' "$WEZTERM_TEST_FONT"
SH
for command in omarchy-cmd-present pgrep; do
  printf '#!/bin/bash\nexit 1\n' >"$mock_bin/$command"
done
for command in omarchy-restart-shell omarchy-hook omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$command"
done
chmod +x "$mock_bin/"*
cp "$ROOT/config/wezterm/wezterm.lua" "$test_home/.config/wezterm/wezterm.lua"

for font_name in 'Test Font' 'Ampersand & Font' 'Slash/Font' 'Quoted "Font"' 'Back\slash & / "Font"' 'Final Font'; do
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$PATH" WEZTERM_TEST_FONT="$font_name" \
    "$ROOT/bin/omarchy-font-set" "$font_name"
  env HOME="$test_home" WEZTERM_TEST_FONT="$font_name" lua <<'LUA'
package.preload.wezterm = function()
  return {
    config_builder = function() return {} end,
    font = function(name, options)
      assert(name == os.getenv("WEZTERM_TEST_FONT"), "font name changed during escaping")
      assert(options.weight == "Regular", "font options were changed")
      return name
    end,
    action = {
      CopyTo = function() end,
      PasteFrom = function() end,
      SendString = function() end,
    },
  }
end
local config = dofile(os.getenv("HOME") .. "/.config/wezterm/wezterm.lua")
assert(config.font_size == 9, "unrelated settings were changed")
LUA
done
pass "font updates preserve literal names and can replace previously escaped names"
