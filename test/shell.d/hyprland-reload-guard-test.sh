#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command lua
require_command sha256sum

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

run_root="$test_tmp/run-user"
state_dir="$test_tmp/state"
hyprctl_log="$test_tmp/hyprctl.log"
fake_hyprctl="$test_tmp/hyprctl"
signature="test-signature"
runtime_dir="$run_root/1000"

dead_signature="dead-signature"

mkdir -p "$runtime_dir/hypr/$signature" "$runtime_dir/hypr/$dead_signature"

cat >"$fake_hyprctl" <<'BASH'
#!/bin/bash

printf '%s\t%s\n' "$XDG_RUNTIME_DIR" "$*" >>"$FAKE_HYPRCTL_LOG"

case "$*" in
  *'--instance dead-signature '*)
    printf "Couldn't connect to %s/hypr/dead-signature/.socket.sock. (4)\n" "$XDG_RUNTIME_DIR"
    exit 4
    ;;
  *'getoption misc.disable_autoreload'*)
    printf '{"option":"misc.disable_autoreload","bool":%s,"set":true}\n' "${FAKE_DISABLE_AUTORELOAD:-false}"
    ;;
  *'getoption debug.suppress_errors'*)
    printf '{"option":"debug.suppress_errors","bool":%s,"set":true}\n' "${FAKE_SUPPRESS_ERRORS:-false}"
    ;;
  *)
    printf 'ok\n'
    ;;
esac
BASH
chmod 0755 "$fake_hyprctl"

FAKE_HYPRCTL_LOG="$hyprctl_log" \
  HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" pause 2>"$test_tmp/pause-stderr"

state_file="$state_dir/$signature"
[[ -f $state_file ]] || fail "reload guard stores Hyprland state on pause"
expected_state=$(printf '%s\tfalse\tfalse' "$runtime_dir")
grep -Fx "$expected_state" "$state_file" >/dev/null || fail "reload guard records previous Hyprland reload settings"
grep -F 'hl.config({ misc = { disable_autoreload = true }, debug = { suppress_errors = true } })' "$hyprctl_log" >/dev/null || fail "reload guard pauses autoreload with hyprctl eval"
pass "reload guard pauses live Hyprland reloads"

[[ ! -e $state_dir/$dead_signature ]] || fail "reload guard skips instances hyprctl cannot reach"
[[ ! -s $test_tmp/pause-stderr ]] || fail "reload guard pauses dead Hyprland instances quietly" "$(cat "$test_tmp/pause-stderr")"
pass "reload guard skips dead Hyprland instances quietly"

: >"$hyprctl_log"
FAKE_HYPRCTL_LOG="$hyprctl_log" \
  HYPRCTL="$fake_hyprctl" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_RUN_ROOT="$run_root" \
  OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" \
  "$ROOT/bin/omarchy-hyprland-reload-guard" resume

[[ ! -e $state_file ]] || fail "reload guard clears Hyprland state after resume"
grep -F -- '--instance test-signature reload' "$hyprctl_log" >/dev/null || fail "reload guard forces one Hyprland reload after package transaction"
grep -F 'hl.config({ misc = { disable_autoreload = false }, debug = { suppress_errors = false } })' "$hyprctl_log" >/dev/null || fail "reload guard restores previous Hyprland reload settings"
pass "reload guard resumes live Hyprland reloads"

# The modeless monitor recovery loop reloads on its own schedule, so it needs to
# ask whether a transaction is in flight.
rm -rf "$state_dir"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused &&
  fail "reload guard reports itself unpaused before any transaction"

mkdir -p "$state_dir"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused &&
  fail "an empty state directory is not a paused transaction"

touch "$state_dir/some-signature"
OMARCHY_HYPRLAND_RELOAD_GUARD_STATE_DIR="$state_dir" "$ROOT/bin/omarchy-hyprland-reload-guard" paused ||
  fail "reload guard reports itself paused during a transaction"
pass "reload guard reports whether a transaction is holding reloads"

# The config hook is the other half of this reload domain: Hyprland announces a
# finished reload, and the hook reports which config files changed since the
# previous one. omarchy-hook is stubbed, so the assertions read the dispatched
# hook line instead of the user's own hooks.
config_hook_bin="$test_tmp/hook-bin"
config_hook_home="$test_tmp/hook-home"
config_dir="$config_hook_home/.config/hypr"
config_hook_log="$test_tmp/hook.log"
mkdir -p "$config_hook_bin" "$config_dir"

cat >"$config_hook_bin/omarchy-hook" <<SH
#!/bin/bash
echo "HOOK CALL: \$*" >>"$config_hook_log"
SH
chmod +x "$config_hook_bin/omarchy-hook"

run_config_hook() {
  HOME="$config_hook_home" \
  XDG_CONFIG_HOME="$config_hook_home/.config" \
  XDG_STATE_HOME="$config_hook_home/.local/state" \
  PATH="$config_hook_bin:$PATH" \
    "$ROOT/bin/omarchy-hyprland-config-reloaded"
}

last_hook_line() {
  tail -n 1 "$config_hook_log"
}

for config_file in \
  bindings.lua looknfeel.lua monitors.lua input.lua autostart.lua hyprland.lua foo.lua; do
  echo "-- $config_file" >"$config_dir/$config_file"
done

run_config_hook
[[ $(last_hook_line) == 'HOOK CALL: hyprland-config ' ]] ||
  fail "first config hook run establishes the baseline with no files"
pass "first config hook run establishes the baseline with no files"

echo '-- changed' >>"$config_dir/bindings.lua"
echo '-- changed' >>"$config_dir/looknfeel.lua"
run_config_hook
[[ $(last_hook_line) == 'HOOK CALL: hyprland-config bindings,looknfeel' ]] ||
  fail "config hook reports changed config files in filename order"
pass "config hook reports changed config files in filename order"

run_config_hook
(( $(grep -c '^HOOK CALL:' "$config_hook_log") == 3 )) ||
  fail "unchanged reload still fires the hook"
[[ $(last_hook_line) == 'HOOK CALL: hyprland-config ' ]] ||
  fail "unchanged reload fires the hook with no files"
pass "unchanged reload fires the hook with no files"

# A snapshot row keyed by `bindings.lua` must not match `mybindings.lua`: the
# next unchanged reload would otherwise keep reporting `bindings`.
echo '-- new' >"$config_dir/mybindings.lua"
run_config_hook
[[ $(last_hook_line) == 'HOOK CALL: hyprland-config mybindings' ]] ||
  fail "added suffix file is reported once"
run_config_hook
[[ $(last_hook_line) == 'HOOK CALL: hyprland-config ' ]] ||
  fail "suffix file keeps the base file changed"
pass "config hook compares full filenames, not substrings"

rm "$config_dir/foo.lua"
run_config_hook
[[ $(last_hook_line) == 'HOOK CALL: hyprland-config foo' ]] ||
  fail "removed config file is reported"
run_config_hook
[[ $(last_hook_line) == 'HOOK CALL: hyprland-config ' ]] ||
  fail "removed config file is reported only once"
pass "config hook reports removed config files"

# A broken symlink stays in the glob; it must not abort the run before the
# snapshot is written and the hook fires.
ln -s "$config_dir/missing.lua" "$config_dir/broken.lua"
hook_calls_before=$(grep -c '^HOOK CALL:' "$config_hook_log")
run_config_hook
(( $(grep -c '^HOOK CALL:' "$config_hook_log") == hook_calls_before + 1 )) ||
  fail "broken symlink still fires the hook"
rm "$config_dir/broken.lua"
pass "config hook skips broken symlinks"

# The hook only runs because default/hypr/hooks.lua subscribes to the reload
# event, so loading the module has to register it and dispatch the command.
cat >"$test_tmp/hooks-check.lua" <<'LUA_EOF'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local registered = {}
local exec_cmds = {}
hl = {
  on = function(event, callback)
    registered[event] = callback
  end,
  exec_cmd = function(command)
    exec_cmds[#exec_cmds + 1] = command
  end,
}

require("default.hypr.hooks")

if not registered["config.reloaded"] then
  print("not ok - hooks module registers config.reloaded")
  os.exit(1)
end
print("ok - hooks module registers config.reloaded")

registered["config.reloaded"]()
if exec_cmds[1] ~= "omarchy-hyprland-config-reloaded" then
  print("not ok - config reload fires the hook command")
  os.exit(1)
end
print("ok - config reload fires the hook command")
LUA_EOF
lua_output=$(OMARCHY_PATH="$ROOT" lua "$test_tmp/hooks-check.lua" 2>&1) ||
  fail "hooks module lua check failed" "$lua_output"
grep -q '^ok - hooks module registers config.reloaded$' <<<"$lua_output" ||
  fail "hooks module registers config.reloaded" "$lua_output"
grep -q '^ok - config reload fires the hook command$' <<<"$lua_output" ||
  fail "config reload fires the hook command" "$lua_output"
pass "hooks module registers config.reloaded and fires the hook command"
