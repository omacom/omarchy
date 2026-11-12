#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/with-driver" "$tmp_dir/without-driver"
printf '#!/bin/bash\n' >"$tmp_dir/with-driver/cua-driver"
chmod +x "$tmp_dir/with-driver/cua-driver"

# Prints every variable envs.lua exports, with the hardware and theme modules
# it pulls in left out: they read the machine running the test.
exported_envs() {
  HOME="$tmp_dir" OMARCHY_PATH="$ROOT" PATH="$1" /usr/bin/lua - <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
hl = {
  env = function(name, value) print(name .. "=" .. value) end,
  config = function() end,
}
package.loaded["default.hypr.nvidia"] = true
package.loaded["default.hypr.require_optional"] = { module = function() end }
require("default.hypr.helpers")
require("default.hypr.envs")
LUA
}

with_driver=$(exported_envs "$tmp_dir/with-driver:/usr/bin")
grep -qx 'CUA_DRIVER_RS_ENABLE_WAYLAND=1' <<<"$with_driver" ||
  fail "a session on a machine with Cua Driver exports its Wayland switch" "$with_driver"
pass "a session on a machine with Cua Driver exports its Wayland switch"

without_driver=$(exported_envs "$tmp_dir/without-driver")
! grep -q 'CUA_DRIVER' <<<"$without_driver" ||
  fail "a session on a machine without Cua Driver carries none of its environment" "$without_driver"
grep -qx 'XDG_SESSION_TYPE=wayland' <<<"$without_driver" ||
  fail "a session on a machine without Cua Driver carries none of its environment" "the rest of the environment went missing"
pass "a session on a machine without Cua Driver carries none of its environment"
