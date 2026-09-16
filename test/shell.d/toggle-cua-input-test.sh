#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
export TEST_LOG="$tmp_dir/log"

# hyprctl answers from the environment; loads and reloads are logged.
cat >"$tmp_dir/bin/hyprctl" <<'SCRIPT'
#!/bin/bash
case "$*" in
  "-j plugin list")
    if [[ ${TEST_PLUGIN_LOADED:-0} == 1 ]]; then echo '[{"name":"cua-hyprland-plugin","handle":"1"}]'; else echo '[]'; fi ;;
  "-j cua:status")
    if [[ ${TEST_CUA_READY:-0} == 1 ]]; then ready=true; else ready=false; fi
    printf '{"configured":%s,"transport":{"ready":%s},"keyboard_layout_independent":%s}\n' "$ready" "$ready" "${TEST_LAYOUT_INDEPENDENT:-true}" ;;
  "-j getoption input:kb_layout") printf '{"str":"%s"}\n' "${TEST_LAYOUT:-us}" ;;
  "-j getoption input:kb_variant") printf '{"str":"%s"}\n' "${TEST_VARIANT:-}" ;;
  "plugin load "*) printf 'hyprctl:%s\n' "$*" >>"$TEST_LOG"; exit "${TEST_LOAD_STATUS:-0}" ;;
  *) printf 'hyprctl:%s\n' "$*" >>"$TEST_LOG" ;;
esac
SCRIPT

# The package's consumer check and the digest it takes: pass or fail on demand.
cat >"$tmp_dir/bin/python3" <<'SCRIPT'
#!/bin/bash
printf 'python3:%s\n' "$*" >>"$TEST_LOG"
if [[ -n ${TEST_VERIFY_PAUSE:-} ]]; then
  touch "$TEST_VERIFY_PAUSE.ready"
  for ((attempt = 0; attempt < 500; attempt++)); do
    [[ -e $TEST_VERIFY_PAUSE.release ]] && break
    sleep 0.01
  done
  [[ -e $TEST_VERIFY_PAUSE.release ]] || exit 1
fi
exit "${TEST_VERIFY_STATUS:-0}"
SCRIPT
cat >"$tmp_dir/bin/sha256sum" <<'SCRIPT'
#!/bin/bash
echo "0000000000000000000000000000000000000000000000000000000000000000  $1"
SCRIPT

cat >"$tmp_dir/bin/pacman" <<'SCRIPT'
#!/bin/bash
[[ $* == "-Q cua-hyprland-plugin" ]] || exit 1
printf 'cua-hyprland-plugin %s\n' "${TEST_PLUGIN_VERSION:-0.26.1-4}"
SCRIPT

cat >"$tmp_dir/bin/omarchy-pkg-present" <<'SCRIPT'
#!/bin/bash
[[ ${TEST_PLUGIN_INSTALLED:-1} == 1 ]]
SCRIPT

cat >"$tmp_dir/bin/omarchy-notification-send" <<'SCRIPT'
#!/bin/bash
printf 'notify:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin/"*

export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
export OMARCHY_PATH="$ROOT"

toggle="$ROOT/bin/omarchy-toggle-cua-input"
flag_file() { echo "$HOME/.local/state/omarchy/toggles/hypr/cua-input.lua"; }

fresh_home() {
  rm -rf "$tmp_dir/home"
  mkdir -p "$tmp_dir/home"
  export HOME="$tmp_dir/home"
  : >"$TEST_LOG"
}

# Nothing to turn on without the package.
fresh_home
rc=0
TEST_PLUGIN_INSTALLED=0 "$toggle" on 2>/dev/null || rc=$?
[[ $rc != 0 && ! -e $(flag_file) ]] || fail "cua input refuses without the plugin package"
grep -q '^notify:.*Cua input stays off' "$TEST_LOG" || fail "cua input refuses without the plugin package" "no notification"
pass "cua input refuses without the plugin package"

# Neither non-US layouts nor XKB variants prevent enabling background input.
for layout in dk us; do
  fresh_home
  TEST_LAYOUT="$layout" TEST_VARIANT=intl "$toggle" on
  [[ -e $(flag_file) ]] || fail "cua input accepts $layout with remaps"
  pass "cua input accepts $layout with remaps"
done

# Executing the shipped Lua must leave the user's keyboard settings intact.
require_command lua
lua - "$ROOT/default/hypr/toggles/cua-input.lua" <<'LUA'
local calls = 0
hl = {
  config = function(config)
    calls = calls + 1
    assert(config.input == nil, "toggle must not write human keyboard settings")
    assert(config.plugin.cua.enabled == true, "toggle must enable Cua input")
  end,
  on = function(event, callback)
    assert(event == "hyprland.start")
    hl.exec_cmd = function(command) assert(command == "omarchy-toggle-cua-input --load") end
    callback()
  end,
}
dofile(arg[1])
assert(calls == 1)
LUA
pass "cua input config preserves human keyboard settings"

# Older packages cannot supply the runtime capability, even if a stub reports it.
fresh_home
rc=0
TEST_PLUGIN_VERSION=0.26.1-3 "$toggle" on 2>/dev/null || rc=$?
[[ $rc != 0 && ! -e $(flag_file) ]] || fail "cua input refuses older packages"
! grep -q '^hyprctl:plugin load' "$TEST_LOG" || fail "cua input refuses older packages" "plugin loaded anyway"
pass "cua input refuses older packages"

# An upgraded package does not replace an older module already in memory.
fresh_home
mkdir -p "$(dirname "$(flag_file)")"
printf 'hl.config({input={kb_layout="us",kb_options=""}})\n' >"$(flag_file)"
rc=0
TEST_PLUGIN_LOADED=1 TEST_LAYOUT_INDEPENDENT=false "$toggle" on 2>/dev/null || rc=$?
[[ $rc != 0 && ! -e $(flag_file) ]] || fail "cua input disables a stale loaded module"
! grep -q '^hyprctl:plugin ' "$TEST_LOG" || fail "cua input disables a stale loaded module" "module replaced"
grep -q 'Log out and back in' "$TEST_LOG" || fail "cua input disables a stale loaded module" "restart instruction missing"
grep -q '^hyprctl:reload$' "$TEST_LOG" || fail "cua input disables a stale loaded module" "old keymap not restored"
pass "cua input disables a stale loaded module without replacing it"

# A failed load must clear a legacy flag rather than leave its keyboard override.
for action in on --load; do
  fresh_home
  mkdir -p "$(dirname "$(flag_file)")"
  printf 'hl.config({input={kb_layout="us",kb_options=""}})\n' >"$(flag_file)"
  rc=0
  TEST_LOAD_STATUS=1 "$toggle" "$action" 2>/dev/null || rc=$?
  [[ ! -e $(flag_file) ]] || fail "cua input clears old flags when $action cannot load"
  grep -q '^hyprctl:reload$' "$TEST_LOG" || fail "cua input clears old flags when $action cannot load" "old keymap not restored"
  pass "cua input clears old flags when $action cannot load"
done

# A failed compatibility check leaves the module unloaded.
fresh_home
rc=0
TEST_VERIFY_STATUS=1 "$toggle" on 2>/dev/null || rc=$?
[[ $rc != 0 && ! -e $(flag_file) ]] || fail "cua input refuses when the compatibility check fails"
! grep -q '^hyprctl:plugin load' "$TEST_LOG" || fail "cua input refuses when the compatibility check fails" "plugin loaded anyway"
pass "cua input refuses when the compatibility check fails"

# on: check, load, land the flag, reload, report.
fresh_home
TEST_CUA_READY=1 "$toggle" on
grep -q '^python3:.*profile_verify.py --kit /usr/share/cua-hyprland-plugin --kit-sha256 0000.* --consumer /usr/lib/cua/hyprland/cua-hyprland-plugin.so' "$TEST_LOG" ||
  fail "cua input runs the package's consumer check before loading" "$(cat "$TEST_LOG")"
pass "cua input runs the package's consumer check before loading"

grep -q '^hyprctl:plugin load /usr/lib/cua/hyprland/cua-hyprland-plugin.so$' "$TEST_LOG" || fail "cua input loads the plugin" "$(cat "$TEST_LOG")"
pass "cua input loads the plugin"

cmp -s "$(flag_file)" "$ROOT/default/hypr/toggles/cua-input.lua" || fail "cua input lands the shipped toggle flag"
grep -q '^hyprctl:reload$' "$TEST_LOG" || fail "cua input lands the shipped toggle flag" "no reload"
pass "cua input lands the shipped toggle flag"

grep -q '^notify:.*Cua input on Your keyboard layout and remaps stay unchanged.' "$TEST_LOG" || fail "cua input reports unchanged keyboard settings" "$(cat "$TEST_LOG")"
pass "cua input reports unchanged keyboard settings"

[[ $(TEST_CUA_READY=1 "$toggle" --status) == '{"enabled":true,"loaded":false,"ready":true}' ]] || fail "cua input reports status" "$(TEST_CUA_READY=1 "$toggle" --status)"
pass "cua input reports status"

# An already loaded module with independent keymaps is not loaded twice.
: >"$TEST_LOG"
TEST_PLUGIN_LOADED=1 TEST_LAYOUT=us "$toggle" on
! grep -q '^hyprctl:plugin load' "$TEST_LOG" || fail "cua input does not reload a loaded plugin"
pass "cua input does not reload a loaded plugin"

# off: the flag goes and Hyprland reloads; the module is left alone.
: >"$TEST_LOG"
"$toggle" off
[[ ! -e $(flag_file) ]] || fail "cua input off removes the flag"
grep -q '^hyprctl:reload$' "$TEST_LOG" || fail "cua input off removes the flag" "no reload"
! grep -q '^hyprctl:plugin unload' "$TEST_LOG" || fail "cua input off removes the flag" "unloaded the module"
pass "cua input off removes the flag"

[[ $("$toggle" --status) == '{"enabled":false,"loaded":false,"ready":false}' ]] || fail "cua input reports status when off"
pass "cua input reports status when off"

# toggle flips between the two.
: >"$TEST_LOG"
TEST_CUA_READY=1 "$toggle"
[[ -e $(flag_file) ]] || fail "cua input toggles on from off"
pass "cua input toggles on from off"
"$toggle"
[[ ! -e $(flag_file) ]] || fail "cua input toggles off from on"
pass "cua input toggles off from on"

# --load at session start: with the flag on, load again after the check.
fresh_home
TEST_CUA_READY=1 "$toggle" on >/dev/null
: >"$TEST_LOG"
"$toggle" --load
grep -q '^hyprctl:plugin load' "$TEST_LOG" || fail "cua input reloads the plugin at session start" "$(cat "$TEST_LOG")"
[[ -e $(flag_file) ]] || fail "cua input reloads the plugin at session start" "flag removed"
pass "cua input reloads the plugin at session start"

# Existing copied flags are replaced, removing their legacy keyboard overrides.
for ((line = 0; line < 20; line++)); do
  printf 'hl.config({input={kb_layout="us",kb_options=""}})\n'
done >"$(flag_file)"
: >"$TEST_LOG"
"$toggle" --load
cmp -s "$(flag_file)" "$ROOT/default/hypr/toggles/cua-input.lua" || fail "cua input refreshes old flags at session start"
grep -q '^hyprctl:reload$' "$TEST_LOG" || fail "cua input refreshes old flags at session start" "no reload"
pass "cua input refreshes old flags at session start"

# Turning off while startup verification runs must not recreate the flag.
: >"$TEST_LOG"
TEST_VERIFY_PAUSE="$tmp_dir/verify" "$toggle" --load &
load_pid=$!
for ((attempt = 0; attempt < 200; attempt++)); do
  [[ -e $tmp_dir/verify.ready ]] && break
  sleep 0.01
done
[[ -e $tmp_dir/verify.ready ]] || fail "cua input startup verifier reached the pause"
"$toggle" off
[[ ! -e $(flag_file) ]] || fail "cua input off removes the flag during startup verification"
touch "$tmp_dir/verify.release"
wait "$load_pid"
[[ ! -e $(flag_file) ]] || fail "cua input startup preserves a concurrent off"
pass "cua input startup preserves a concurrent off"
"$toggle" on >/dev/null

# A stale module found at startup also removes old keyboard overrides safely.
: >"$TEST_LOG"
TEST_PLUGIN_LOADED=1 TEST_LAYOUT_INDEPENDENT=false "$toggle" --load
[[ ! -e $(flag_file) ]] || fail "cua input disables stale loaded module at session start"
! grep -q '^hyprctl:plugin ' "$TEST_LOG" || fail "cua input disables stale loaded module at session start" "module replaced"
pass "cua input disables stale loaded module at session start"
"$toggle" on >/dev/null

# A check that no longer passes turns the flag off.
: >"$TEST_LOG"
TEST_VERIFY_STATUS=1 "$toggle" --load
[[ ! -e $(flag_file) ]] || fail "cua input turns itself off when the check fails at session start"
! grep -q '^hyprctl:plugin load' "$TEST_LOG" || fail "cua input turns itself off when the check fails at session start" "loaded anyway"
grep -q '^notify:.*Cua input turned off' "$TEST_LOG" || fail "cua input turns itself off when the check fails at session start" "no notification"
pass "cua input turns itself off when the check fails at session start"

# With the flag off, session start does nothing.
: >"$TEST_LOG"
"$toggle" --load
[[ ! -s $TEST_LOG ]] || fail "cua input --load is a no-op when off" "$(cat "$TEST_LOG")"
pass "cua input --load is a no-op when off"
