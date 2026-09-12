#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Session NVIDIA env must require both presence and a connected NVIDIA output
# (issue #10410). Presence alone on a hybrid laptop stalls browser VA-API.

require_command lua

nvidia_lua="$ROOT/default/hypr/nvidia.lua"
[[ -f $nvidia_lua ]] || fail "default hypr nvidia.lua exists"

grep -F 'omarchy-hw-nvidia-drives-display' "$nvidia_lua" >/dev/null ||
  fail "nvidia.lua gates session env on nvidia-drives-display"
grep -F 'LIBVA_DRIVER_NAME' "$nvidia_lua" >/dev/null ||
  fail "nvidia.lua still sets LIBVA_DRIVER_NAME when appropriate"
pass "nvidia.lua gates LIBVA on nvidia-drives-display"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Fake omarchy path with the real lua module and stub detectors.
fake_root="$test_tmp/omarchy"
mkdir -p "$fake_root/bin" "$fake_root/default/hypr"
cp "$ROOT/default/hypr/nvidia.lua" "$fake_root/default/hypr/nvidia.lua"
cp "$ROOT/default/hypr/paths.lua" "$fake_root/default/hypr/paths.lua" 2>/dev/null || true

# paths.lua may pull more; inject a minimal paths module via package.path override.
cat >"$fake_root/default/hypr/paths.lua" <<'LUA'
return {
  omarchy_path = os.getenv("OMARCHY_PATH"),
  home = os.getenv("HOME") or "",
}
LUA

# nvidia.lua invokes detectors via $OMARCHY_PATH/bin/..., not PATH.
for name in omarchy-hw-nvidia omarchy-hw-nvidia-gsp omarchy-hw-nvidia-without-gsp omarchy-hw-nvidia-drives-display; do
  cat >"$fake_root/bin/$name" <<'SH'
#!/bin/bash
case "${0##*/}" in
omarchy-hw-nvidia) [[ $OMARCHY_TEST_NVIDIA == 1 ]] && exit 0; exit 1 ;;
omarchy-hw-nvidia-gsp) [[ $OMARCHY_TEST_GSP == 1 ]] && exit 0; exit 1 ;;
omarchy-hw-nvidia-without-gsp) [[ $OMARCHY_TEST_WITHOUT_GSP == 1 ]] && exit 0; exit 1 ;;
omarchy-hw-nvidia-drives-display) [[ $OMARCHY_TEST_DRIVES == 1 ]] && exit 0; exit 1 ;;
esac
exit 1
SH
  chmod +x "$fake_root/bin/$name"
done

run_nvidia_lua() {
  local env_out
  env_out=$(
    OMARCHY_PATH="$fake_root" HOME="$test_tmp/home" PATH="/usr/bin:/bin" \
      OMARCHY_TEST_NVIDIA="${1:-0}" \
      OMARCHY_TEST_GSP="${2:-0}" \
      OMARCHY_TEST_WITHOUT_GSP="${3:-0}" \
      OMARCHY_TEST_DRIVES="${4:-0}" \
      lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
local envs = {}
hl = {
  env = function(k, v)
    envs[#envs + 1] = k .. "=" .. tostring(v)
  end,
}
o = {
  shell_quote = function(s) return "'" .. tostring(s):gsub("'", "'\\''") .. "'" end,
  shell_succeeds = function(cmd)
    -- Lua 5.1 returns exit status as a number; 5.2+ returns success, typ, code.
    local a, b, c = os.execute(cmd .. " >/dev/null 2>&1")
    if a == true then return true end
    if type(a) == "number" then return a == 0 end
    if b == "exit" and c == 0 then return true end
    return false
  end,
}
require("default.hypr.nvidia")
table.sort(envs)
print(table.concat(envs, " "))
LUA
  )
  printf '%s' "$env_out"
}

# Hybrid: NVIDIA GSP present, not driving display → no LIBVA.
out=$(run_nvidia_lua 1 1 0 0)
[[ $out != *LIBVA_DRIVER_NAME* ]] ||
  fail "hybrid idle dGPU must not set LIBVA_DRIVER_NAME" "envs: $out"
[[ $out != *__GLX_VENDOR_LIBRARY_NAME* ]] ||
  fail "hybrid idle dGPU must not set __GLX_VENDOR_LIBRARY_NAME" "envs: $out"
pass "hybrid idle dGPU sets no NVIDIA session env"

# NVIDIA GSP driving a display → full env.
out=$(run_nvidia_lua 1 1 0 1)
[[ $out == *LIBVA_DRIVER_NAME=nvidia* ]] ||
  fail "NVIDIA driving display sets LIBVA_DRIVER_NAME" "envs: $out"
[[ $out == *__GLX_VENDOR_LIBRARY_NAME=nvidia* ]] ||
  fail "NVIDIA driving display sets __GLX_VENDOR_LIBRARY_NAME" "envs: $out"
[[ $out == *NVD_BACKEND=direct* ]] ||
  fail "NVIDIA GSP driving display sets NVD_BACKEND=direct" "envs: $out"
pass "NVIDIA GSP driving display sets full session env"

# No NVIDIA at all → empty.
out=$(run_nvidia_lua 0 0 0 0)
[[ -z $out ]] || fail "no NVIDIA leaves session env empty" "envs: $out"
pass "no NVIDIA leaves session env empty"

# NVIDIA present + drives display but without GSP → egl path, no LIBVA (legacy).
out=$(run_nvidia_lua 1 0 1 1)
[[ $out == *NVD_BACKEND=egl* ]] ||
  fail "legacy NVIDIA driving display sets NVD_BACKEND=egl" "envs: $out"
[[ $out != *LIBVA_DRIVER_NAME* ]] ||
  fail "legacy without-gsp path does not set LIBVA" "envs: $out"
pass "legacy NVIDIA driving display sets egl path without LIBVA"
