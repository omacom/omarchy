#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua
require_command jq

output=$(lua "$ROOT/test/shell.d/fixtures/keybindings/registry.lua" "$ROOT") || fail "live binding registry behavior"
printf '%s\n' "$output" | grep '^ok -'
snapshot=$(sed -n 's/^SNAPSHOT://p' <<<"$output")
jq -e '.bindings | length == 3' <<<"$snapshot" >/dev/null || fail "registry emits valid JSON"
jq -e '.bindings[0].description == "comma, tab\tquote\" backslash\\\nUnicode →"' <<<"$snapshot" >/dev/null || fail "JSON metadata round-trips without corruption"
pass "binding metadata survives JSON serialization"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"
task_home="$tmpdir/home"
mkdir -p "$task_home/.config/hypr"
cp "$ROOT/config/hypr/hyprland.lua" "$task_home/.config/hypr/hyprland.lua"
cat >"$tmpdir/bin/hyprctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$CALLS"
exit "${RELOAD_STATUS:-0}"
STUB
chmod +x "$tmpdir/bin/hyprctl"
for i in 1 2; do
  HOME="$task_home" CALLS="$tmpdir/calls" PATH="$tmpdir/bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=test \
    bash -euo pipefail "$ROOT/migrations/1789328800.sh" >/dev/null
done
[[ $(cat "$tmpdir/calls") == $'reload\nreload' ]] || fail "migration only reloads the existing session"
rm "$tmpdir/calls"
HOME="$task_home" CALLS="$tmpdir/calls" PATH="$tmpdir/bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE= \
  bash -euo pipefail "$ROOT/migrations/1789328800.sh" >/dev/null
[[ ! -e $tmpdir/calls ]] || fail "offline upgrade must wait for next login"
pass "migration is repeatable and leaves offline upgrades for next login"

HOME="$task_home" CALLS="$tmpdir/calls" PATH="$tmpdir/bin:$PATH" HYPRLAND_INSTANCE_SIGNATURE=expired RELOAD_STATUS=4 \
  bash -euo pipefail "$ROOT/migrations/1789328800.sh" >/dev/null || fail "an expired compositor must not block the migration queue"
pass "migration tolerates an expired compositor signature under strict shell flags"

printf 'package.path = "/custom/?.lua;" .. package.path\n' >"$task_home/.config/hypr/hyprland.lua"
cp "$task_home/.config/hypr/hyprland.lua" "$tmpdir/original.lua"
for i in 1 2; do
  HOME="$task_home" HYPRLAND_INSTANCE_SIGNATURE= bash -euo pipefail "$ROOT/migrations/1789328800.sh" >"$tmpdir/message"
  grep -Fq 'dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")' "$tmpdir/message" || fail "custom entrypoint receives the exact missing bootstrap line"
  grep -Fq 'before any bindings or module imports' "$tmpdir/message" || fail "bootstrap guidance explains load order"
  cmp "$task_home/.config/hypr/hyprland.lua" "$tmpdir/original.lua" || fail "custom Lua must remain intact"
done
pass "custom entrypoints get actionable bootstrap guidance without a rewrite"

sed -n '/^dofile(/p' "$tmpdir/message" >"$tmpdir/recovery.lua"
for install_path in /usr/share/omarchy "$tmpdir/custom install"; do
  env -u OMARCHY_PATH lua - "$tmpdir/recovery.lua" "$install_path" <<'LUA' || fail "bootstrap recovery resolves the install path without requiring OMARCHY_PATH"
local recovery = assert(loadfile(arg[1]))
local expected = arg[2]
local getenv = os.getenv
os.getenv = function(name)
  if name == "OMARCHY_PATH" and expected ~= "/usr/share/omarchy" then return expected end
  return getenv(name)
end
dofile = function(path) assert(path == expected .. "/default/hypr/bootstrap.lua", path) end
recovery()
LUA
done
pass "bootstrap recovery supports an unset OMARCHY_PATH and custom install paths"
