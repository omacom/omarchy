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
    numlock_capability=""
    if [[ ${TEST_NUMLOCK_COMPATIBLE:-true} != missing ]]; then
      numlock_capability=",\"foreground_numlock_compatible\":${TEST_NUMLOCK_COMPATIBLE:-true}"
    fi
    guard_capability=""
    if [[ ${TEST_IME_GUARD:-true} != missing ]]; then
      guard_capability=",\"ime_popup_guard\":${TEST_IME_GUARD:-true}"
    fi
    printf '{"configured":%s,"transport":{"ready":%s},"keyboard_layout_independent":%s%s%s}\n' "$ready" "$ready" "${TEST_LAYOUT_INDEPENDENT:-true}" "$numlock_capability" "$guard_capability" ;;
  "-j getoption input:kb_layout") printf '{"str":"%s"}\n' "${TEST_LAYOUT:-us}" ;;
  "-j getoption input:kb_variant") printf '{"str":"%s"}\n' "${TEST_VARIANT:-}" ;;
  "plugin load "*)
    printf 'hyprctl:%s\n' "$*" >>"$TEST_LOG"
    if grep -q 'enabled = false' "$HOME/.local/state/omarchy/toggles/hypr/cua-input.lua" 2>/dev/null; then echo 'flag-at-load:held' >>"$TEST_LOG"; fi
    exit "${TEST_LOAD_STATUS:-0}" ;;
  "eval "*)
    printf 'hyprctl:%s\n' "$*" >>"$TEST_LOG"
    if [[ ${TEST_EVAL_STATUS:-0} == 0 ]]; then echo ok; else echo "error: eval failed"; fi ;;
  reload)
    printf 'hyprctl:%s\n' "$*" >>"$TEST_LOG"
    reloads=$(($(cat "$TEST_LOG.reloads" 2>/dev/null || echo 0) + 1))
    echo "$reloads" >"$TEST_LOG.reloads"
    if [[ -n ${TEST_RELOAD_FAIL_FROM:-} ]] && ((reloads >= TEST_RELOAD_FAIL_FROM)); then exit 1; fi
    exit "${TEST_RELOAD_STATUS:-0}" ;;
  *) printf 'hyprctl:%s\n' "$*" >>"$TEST_LOG" ;;
esac
SCRIPT

# dd fails on demand for copies from a file, which is how the flag is restored.
cat >"$tmp_dir/bin/dd" <<'SCRIPT'
#!/bin/bash
if [[ ${TEST_RESTORE_FAIL:-0} == 1 && " $* " == *" if="* ]]; then exit 1; fi
exec /usr/bin/dd "$@"
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
if [[ -n ${TEST_PACMAN_PAUSE:-} ]]; then
  touch "$TEST_PACMAN_PAUSE.ready"
  for ((attempt = 0; attempt < 500; attempt++)); do
    [[ -e $TEST_PACMAN_PAUSE.release ]] && break
    sleep 0.01
  done
fi
printf 'cua-hyprland-plugin %s\n' "${TEST_PLUGIN_VERSION:-0.32.0-3}"
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

# Executing the shipped Lua must leave the user's keyboard settings intact, and
# must not name the plugin's option before the module is loaded: at login that
# is an unknown config key, which Hyprland reports as a config error.
require_command lua
for loaded in false true; do
  lua - "$ROOT/default/hypr/toggles/cua-input.lua" "$loaded" <<'LUA'
local loaded = arg[2] == "true"
local calls = 0
hl = {
  get_config = function(key)
    assert(key == "plugin.cua.enabled")
    if loaded then return false end
    return nil
  end,
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
assert(calls == (loaded and 1 or 0), "plugin option set " .. calls .. " times with the module " .. (loaded and "loaded" or "unloaded"))
LUA
done
pass "cua input config preserves human keyboard settings"
pass "cua input config names the plugin option only once the module is loaded"

# Older packages cannot supply the runtime capability, even if a stub reports it.
fresh_home
rc=0
TEST_PLUGIN_VERSION=0.28.2-2 "$toggle" on 2>/dev/null || rc=$?
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

# Package 4 already has independent keymaps, but lacks the Num Lock fix.
# Both interactive enable and startup must reject that still-mapped module.
for action in on --load; do
  fresh_home
  mkdir -p "$(dirname "$(flag_file)")"
  cp "$ROOT/default/hypr/toggles/cua-input.lua" "$(flag_file)"
  rc=0
  TEST_PLUGIN_LOADED=1 TEST_NUMLOCK_COMPATIBLE=missing "$toggle" "$action" 2>/dev/null || rc=$?
  if [[ $action == on ]]; then
    [[ $rc != 0 ]] || fail "cua input refuses the old Num Lock guard during $action"
  fi
  [[ ! -e $(flag_file) ]] || fail "cua input refuses the old Num Lock guard during $action" "flag remains"
  ! grep -q '^hyprctl:plugin ' "$TEST_LOG" || fail "cua input refuses the old Num Lock guard during $action" "module replaced"
  grep -q 'Log out and back in' "$TEST_LOG" || fail "cua input refuses the old Num Lock guard during $action" "restart instruction missing"
  pass "cua input refuses the old Num Lock guard during $action without replacing the module"
done

# A module mapped before the input-method guard, or one whose hooks did not
# install, must not get input: fcitx5 restarting could crash Hyprland. Only
# the old module is fixed by logging out; a failed hook would fail again.
for guard in missing false; do
  if [[ $guard == missing ]]; then expected='Log out and back in'; else expected='could not install its input-method crash guard'; fi
  for action in on --load; do
    fresh_home
    mkdir -p "$(dirname "$(flag_file)")"
    cp "$ROOT/default/hypr/toggles/cua-input.lua" "$(flag_file)"
    rc=0
    TEST_PLUGIN_LOADED=1 TEST_IME_GUARD=$guard "$toggle" "$action" 2>/dev/null || rc=$?
    if [[ $action == on ]]; then
      [[ $rc != 0 ]] || fail "cua input refuses a $guard input-method guard during $action"
    fi
    [[ ! -e $(flag_file) ]] || fail "cua input refuses a $guard input-method guard during $action" "flag remains"
    ! grep -q '^hyprctl:plugin ' "$TEST_LOG" || fail "cua input refuses a $guard input-method guard during $action" "module replaced"
    grep -q "$expected" "$TEST_LOG" || fail "cua input refuses a $guard input-method guard during $action" "wrong instruction: $(cat "$TEST_LOG")"
    if [[ $guard == false ]] && grep -q 'Log out and back in' "$TEST_LOG"; then
      fail "cua input refuses a $guard input-method guard during $action" "a failed hook is not fixed by logging out"
    fi
    pass "cua input refuses a $guard input-method guard during $action without replacing the module"
  done
done

# Compiled capabilities are available before input is enabled or ready.
fresh_home
TEST_CUA_READY=0 "$toggle" on
[[ -e $(flag_file) ]] || fail "cua input checks compiled capabilities before input is ready"
grep -q '^notify:.*Cua plugin loaded, input not ready' "$TEST_LOG" || fail "cua input checks compiled capabilities before input is ready" "not-ready state hidden"
pass "cua input checks compiled capabilities before input is ready"

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

# The load reloads Hyprland's configuration before the module is checked, so
# input stays held off through it and is restored only after the checks.
grep -qx 'flag-at-load:held' "$TEST_LOG" || fail "cua input holds input off while a fresh module loads" "$(cat "$TEST_LOG")"
[[ $(grep -nm1 '^hyprctl:reload$' "$TEST_LOG" | cut -d: -f1) -lt $(grep -nm1 '^hyprctl:plugin load' "$TEST_LOG" | cut -d: -f1) ]] ||
  fail "cua input holds input off while a fresh module loads" "held flag not reloaded before the load"
cmp -s "$(flag_file)" "$ROOT/default/hypr/toggles/cua-input.lua" || fail "cua input holds input off while a fresh module loads" "flag not restored"
pass "cua input holds input off while a fresh module loads"

# A fresh module whose guard did not install never gets the enabled flag back.
: >"$TEST_LOG"
TEST_IME_GUARD=false "$toggle" --load
grep -qx 'flag-at-load:held' "$TEST_LOG" || fail "cua input keeps a fresh unguarded module off at session start" "not held during load"
[[ ! -e $(flag_file) ]] || fail "cua input keeps a fresh unguarded module off at session start" "flag remains"
pass "cua input keeps a fresh unguarded module off at session start"
"$toggle" on >/dev/null

# Neither a failed hold nor a failed restore may leave a held flag that
# reports Cua Input on while input stays off.
for failure in TEST_RELOAD_STATUS=1 TEST_RELOAD_FAIL_FROM=2 TEST_RESTORE_FAIL=1; do
  : >"$TEST_LOG"
  rm -f "$TEST_LOG.reloads"
  rc=0
  env "$failure" "$toggle" --load 2>/dev/null || rc=$?
  [[ ! -e $(flag_file) ]] || fail "cua input clears a held flag when $failure" "flag left: $(cat "$(flag_file)")"
  grep -q '^notify:.*Cua input turned off' "$TEST_LOG" || fail "cua input clears a held flag when $failure" "no notification"
  pass "cua input clears a held flag when $failure"
  "$toggle" on >/dev/null
done

# on with the flag already set and the module not yet loaded holds input off
# through the load as well, and refuses a module whose guard did not install.
for guard in true false; do
  fresh_home
  mkdir -p "$(dirname "$(flag_file)")"
  cp "$ROOT/default/hypr/toggles/cua-input.lua" "$(flag_file)"
  rc=0
  TEST_CUA_READY=1 TEST_IME_GUARD=$guard "$toggle" on 2>/dev/null || rc=$?
  grep -qx 'flag-at-load:held' "$TEST_LOG" || fail "cua input on holds input off while loading (guard $guard)" "$(cat "$TEST_LOG")"
  if [[ $guard == true ]]; then
    cmp -s "$(flag_file)" "$ROOT/default/hypr/toggles/cua-input.lua" || fail "cua input on holds input off while loading (guard $guard)" "flag not restored"
  else
    [[ $rc != 0 && ! -e $(flag_file) ]] || fail "cua input on holds input off while loading (guard $guard)" "unguarded module kept its flag"
  fi
  pass "cua input on holds input off while loading (guard $guard)"
done

# A failed reload while landing the flag must not leave it reporting on.
fresh_home
rm -f "$TEST_LOG.reloads"
rc=0
TEST_RELOAD_STATUS=1 "$toggle" on 2>/dev/null || rc=$?
[[ $rc != 0 && ! -e $(flag_file) ]] || fail "cua input on clears the flag when the reload fails"
grep -q '^notify:.*Cua input stays off Hyprland could not reload' "$TEST_LOG" || fail "cua input on clears the flag when the reload fails" "no notification: $(cat "$TEST_LOG")"
pass "cua input on clears the flag when the reload fails"

# Turning off while on verifies must win: on's held flag goes and is not recreated.
fresh_home
rc=0
TEST_CUA_READY=1 TEST_VERIFY_PAUSE="$tmp_dir/onverify" "$toggle" on 2>/dev/null &
on_pid=$!
for ((attempt = 0; attempt < 200; attempt++)); do
  [[ -e $tmp_dir/onverify.ready ]] && break
  sleep 0.01
done
[[ -e $tmp_dir/onverify.ready ]] || fail "cua input on reached its verification pause"
"$toggle" off
touch "$tmp_dir/onverify.release"
wait "$on_pid" || rc=$?
[[ ! -e $(flag_file) ]] || fail "cua input on preserves a concurrent off" "flag recreated"
! grep -q '^notify:.*Cua input on ' "$TEST_LOG" || fail "cua input on preserves a concurrent off" "reported on: $(cat "$TEST_LOG")"
pass "cua input on preserves a concurrent off"
rm -f "$tmp_dir/onverify".*

# A failed reload while turning off falls back to switching the live option off.
fresh_home
"$toggle" on >/dev/null
: >"$TEST_LOG"
TEST_RELOAD_STATUS=1 "$toggle" off
[[ ! -e $(flag_file) ]] || fail "cua input off switches the live option off when the reload fails" "flag kept"
grep -q '^hyprctl:eval .*enabled = false' "$TEST_LOG" || fail "cua input off switches the live option off when the reload fails" "$(cat "$TEST_LOG")"
grep -q '^notify:.*Cua input off' "$TEST_LOG" || fail "cua input off switches the live option off when the reload fails" "not reported off"
pass "cua input off switches the live option off when the reload fails"

# When neither takes, off says so rather than claiming input is off.
fresh_home
"$toggle" on >/dev/null
: >"$TEST_LOG"
rc=0
TEST_RELOAD_STATUS=1 TEST_EVAL_STATUS=1 "$toggle" off 2>/dev/null || rc=$?
[[ $rc != 0 ]] || fail "cua input off reports input that may still be on" "exited 0"
grep -q '^notify:.*Cua input may still be on' "$TEST_LOG" || fail "cua input off reports input that may still be on" "$(cat "$TEST_LOG")"
! grep -q '^notify:.*Cua input off' "$TEST_LOG" || fail "cua input off reports input that may still be on" "claimed off"
pass "cua input off reports input that may still be on"

# A refusal says the same when it cannot take the setting back.
fresh_home
"$toggle" on >/dev/null
: >"$TEST_LOG"
rc=0
TEST_RELOAD_STATUS=1 TEST_EVAL_STATUS=1 "$toggle" on 2>/dev/null || rc=$?
[[ $rc != 0 ]] || fail "cua input refusal reports input that may still be on" "exited 0"
grep -q '^notify:.*Cua input may still be on' "$TEST_LOG" || fail "cua input refusal reports input that may still be on" "$(cat "$TEST_LOG")"
pass "cua input refusal reports input that may still be on"

# A reload that keeps the old settings still answers ok, so off always sets the live option.
fresh_home
"$toggle" on >/dev/null
: >"$TEST_LOG"
"$toggle" off
grep -q '^hyprctl:eval .*enabled = false' "$TEST_LOG" || fail "cua input off sets the live option even when the reload answers ok" "$(cat "$TEST_LOG")"
pass "cua input off sets the live option even when the reload answers ok"

# An off during on's package checks wins too: on's held flag is its first step.
fresh_home
TEST_CUA_READY=1 TEST_PACMAN_PAUSE="$tmp_dir/onpkg" "$toggle" on 2>/dev/null &
on_pid=$!
for ((attempt = 0; attempt < 200; attempt++)); do
  [[ -e $tmp_dir/onpkg.ready ]] && break
  sleep 0.01
done
[[ -e $tmp_dir/onpkg.ready ]] || fail "cua input on reached its package check pause"
"$toggle" off
touch "$tmp_dir/onpkg.release"
wait "$on_pid" || true
[[ ! -e $(flag_file) ]] || fail "cua input on preserves an off during its package checks" "flag recreated"
! grep -q '^notify:.*Cua input on ' "$TEST_LOG" || fail "cua input on preserves an off during its package checks" "reported on"
pass "cua input on preserves an off during its package checks"
rm -f "$tmp_dir/onpkg".*

# A session-start failure that cannot take the setting back says so.
fresh_home
"$toggle" on >/dev/null
: >"$TEST_LOG"
TEST_PLUGIN_VERSION=0.28.2-2 TEST_RELOAD_STATUS=1 TEST_EVAL_STATUS=1 "$toggle" --load
grep -q '^notify:.*Cua input may still be on' "$TEST_LOG" || fail "cua input startup reports input that may still be on" "$(cat "$TEST_LOG")"
! grep -q '^notify:.*Cua input turned off' "$TEST_LOG" || fail "cua input startup reports input that may still be on" "claimed off"
pass "cua input startup reports input that may still be on"

# A flag that cannot be deleted would enable input again at the next reload.
fresh_home
"$toggle" on >/dev/null
: >"$TEST_LOG"
chmod a-w "$(dirname "$(flag_file)")"
rc=0
"$toggle" off 2>/dev/null || rc=$?
chmod u+w "$(dirname "$(flag_file)")"
[[ $rc != 0 ]] || fail "cua input off reports a flag it could not delete" "exited 0"
grep -q '^notify:.*Cua input may still be on' "$TEST_LOG" || fail "cua input off reports a flag it could not delete" "$(cat "$TEST_LOG")"
pass "cua input off reports a flag it could not delete"

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
