#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# Each argument is a PCI device as "vendor:class", in sysfs's own format.
write_pci_devices() {
  rm -rf "$tmp_dir/devices"
  mkdir -p "$tmp_dir/devices"

  local index=0
  local spec
  for spec in "$@"; do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$tmp_dir/devices/$slot"
    printf '%s\n' "${spec%%:*}" >"$tmp_dir/devices/$slot/vendor"
    printf '%s\n' "${spec##*:}" >"$tmp_dir/devices/$slot/class"
    index=$((index + 1))
  done
}

# Loads only the vmware module under a recording hl: env calls print as they
# happen, so an env line before "start" would be a parse-time call.
run_vmware_module() {
  HOME="$tmp_dir/home" OMARCHY_PATH="$ROOT" OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local start_handlers = {}

hl = {
  env = function(name, value)
    print("env\t" .. name .. "=" .. value)
  end,
  on = function(event, callback)
    assert(event == "hyprland.start", "unexpected event: " .. tostring(event))
    table.insert(start_handlers, callback)
  end,
}

require("default.hypr.helpers")
require("default.hypr.vmware")

print("start\t" .. #start_handlers)
for _, callback in ipairs(start_handlers) do
  callback()
end
LUA
}

# Loads the whole default config under the mock from
# hyprland-default-config-test.sh, then fires the collected start handlers in
# registration order, the way Hyprland does.
run_omarchy_config() {
  HOME="$tmp_dir/home" XDG_CONFIG_HOME="$tmp_dir/home/.config" XDG_STATE_HOME="$tmp_dir/home/.local/state" OMARCHY_PATH="$ROOT" OMARCHY_PCI_DEVICES_PATH="$tmp_dir/devices" lua <<'LUA'
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

local start_handlers = {}

hl = setmetatable({
  dsp = proxy(),
  bind = function() end,
  config = function() end,
  env = function(name)
    print("env\t" .. name)
  end,
  monitor = function() end,
  window_rule = function() end,
  workspace_rule = function() end,
  layer_rule = function() end,
  gesture = function() end,
  animation = function() end,
  curve = function() end,
  exec_cmd = function(command)
    print("exec\t" .. command)
  end,
  dispatch = function() end,
  on = function(event, callback)
    if event == "hyprland.start" then
      table.insert(start_handlers, callback)
    end
  end,
  timer = function() end,
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

print("start")
for _, callback in ipairs(start_handlers) do
  callback()
end
LUA
}

mkdir -p "$tmp_dir/home"

# VMware SVGA adapter, the device every VMware guest has.
write_pci_devices 0x15ad:0x030000
output=$(run_vmware_module)
expected=$'start\t1\nenv\tLIBGL_ALWAYS_SOFTWARE=1'
[[ $output == "$expected" ]] ||
  fail "a VMware guest sets LIBGL_ALWAYS_SOFTWARE from the start handler only" "$output"
pass "a VMware guest sets LIBGL_ALWAYS_SOFTWARE from the start handler only"

# AMD integrated graphics.
write_pci_devices 0x1002:0x030000
output=$(run_vmware_module)
[[ $output == $'start\t0' ]] ||
  fail "a machine without the VMware SVGA adapter registers no handler" "$output"
pass "a machine without the VMware SVGA adapter registers no handler"

write_pci_devices 0x15ad:0x030000
output=$(run_omarchy_config)
start_line=$(grep -nx 'start' <<<"$output" | cut -d: -f1 | head -n 1)
libgl_line=$(grep -nx $'env\tLIBGL_ALWAYS_SOFTWARE' <<<"$output" | cut -d: -f1 | head -n 1)
first_exec_line=$(grep -n $'^exec\t' <<<"$output" | cut -d: -f1 | head -n 1)
shell_line=$(grep -nx $'exec\tomarchy-launch-shell' <<<"$output" | cut -d: -f1 | head -n 1)
[[ -n $start_line && -n $libgl_line && -n $first_exec_line && -n $shell_line ]] ||
  fail "the default config records the start marker, the env call, and the shell launch" "$output"
(( libgl_line > start_line )) ||
  fail "the default config sets LIBGL_ALWAYS_SOFTWARE only after Hyprland starts" "$output"
(( libgl_line < first_exec_line )) ||
  fail "the default config sets LIBGL_ALWAYS_SOFTWARE before the first exec" "$output"
(( libgl_line < shell_line )) ||
  fail "the default config sets LIBGL_ALWAYS_SOFTWARE before launching the shell" "$output"
pass "the default config sets LIBGL_ALWAYS_SOFTWARE after start and before any exec"
