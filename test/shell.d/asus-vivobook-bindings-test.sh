#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command lua

lua - "$ROOT" <<'LUA'
local root = arg[1]
local original_open = io.open
local function bindings(vendor, product)
  local result = {}
  io.open = function(path, mode)
    local values = {
      ["/sys/class/dmi/id/sys_vendor"] = vendor,
      ["/sys/class/dmi/id/product_name"] = product,
    }
    local value = values[path]
    if value == nil then
      return nil
    end
    return { read = function() return value end, close = function() end }
  end
  o = { bind = function(key, label, action) result[key] = action end }
  dofile(root .. "/default/hypr/bindings/asus-vivobook.lua")
  io.open = original_open
  return result
end
local supported = bindings("ASUSTeK COMPUTER INC.", "ASUS Vivobook S 16 M5606UA_M5606UA")
assert(supported.XF86Launch2.panel == "omarchy.emojis")
assert(supported["code:192"].panel == "omarchy.audio")
assert(supported.XF86Launch1.menu == "hardware")
for _, identity in ipairs({
  {"ASUSTeK COMPUTER INC.", "ASUS Vivobook S 16 M5606WA_M5606WA"},
  {"Other vendor", "ASUS Vivobook S 16 M5606UA_M5606UA"},
  {"ASUSTeK COMPUTER INC.", "ROG"},
  {},
}) do
  assert(next(bindings(identity[1], identity[2])) == nil, "unrelated hardware must not acquire these bindings")
end
LUA
pass "Vivobook hotkeys apply only to the tested vendor and model"

require_command systemd-hwdb
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/etc/udev/hwdb.d"
cp "$ROOT/default/udev/asus-vivobook-m5606-keyboard.hwdb" "$stage/etc/udev/hwdb.d/90-test.hwdb"
systemd-hwdb --root="$stage" update
match='evdev:name:Asus WMI hotkeys:dmi:bvnBIOS:bvr1:bd01:svnASUSTeKCOMPUTERINC.:pnASUSVivobookS16M5606UA_M5606UA:pvr1:'
[[ $(systemd-hwdb --root="$stage" query "$match") == "KEYBOARD_KEY_7e=prog2" ]] || fail "emoji scan maps to a non-rfkill key"
[[ -z $(systemd-hwdb --root="$stage" query "${match/M5606UA_M5606UA/M5606WA_M5606WA}") ]] || fail "hwdb does not remap another model"
[[ -z $(systemd-hwdb --root="$stage" query "${match/Asus WMI hotkeys/Other keyboard}") ]] || fail "hwdb does not remap another keyboard"
pass "compiled hwdb maps only the verified emoji scan code"
