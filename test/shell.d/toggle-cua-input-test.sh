#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
export TEST_LOG="$tmp_dir/log"

# hyprctl answers from the environment: whether the plugin is loaded, whether
# its input route is ready, and the session's keymap. Loads and reloads are
# logged rather than done.
cat >"$tmp_dir/bin/hyprctl" <<'SCRIPT'
#!/bin/bash
case "$*" in
  "-j plugin list")
    if [[ ${TEST_PLUGIN_LOADED:-0} == 1 ]]; then echo '[{"name":"cua-hyprland-plugin","handle":"1"}]'; else echo '[]'; fi ;;
  "-j cua:status")
    if [[ ${TEST_CUA_READY:-0} == 1 ]]; then echo '{"configured":true,"transport":{"ready":true}}'; else echo '{"configured":false,"transport":{"ready":false}}'; fi ;;
  "-j getoption input:kb_layout") printf '{"str":"%s"}\n' "${TEST_LAYOUT:-us}" ;;
  "-j getoption input:kb_variant") printf '{"str":"%s"}\n' "${TEST_VARIANT:-}" ;;
  *) printf 'hyprctl:%s\n' "$*" >>"$TEST_LOG" ;;
esac
SCRIPT

# The package's consumer check and the digest it takes: pass or fail on demand.
cat >"$tmp_dir/bin/python3" <<'SCRIPT'
#!/bin/bash
printf 'python3:%s\n' "$*" >>"$TEST_LOG"
exit "${TEST_VERIFY_STATUS:-0}"
SCRIPT
cat >"$tmp_dir/bin/sha256sum" <<'SCRIPT'
#!/bin/bash
echo "0000000000000000000000000000000000000000000000000000000000000000  $1"
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

# The route only admits a plain US keymap, so other layouts are not replaced.
fresh_home
rc=0
TEST_LAYOUT=dk "$toggle" on 2>/dev/null || rc=$?
[[ $rc != 0 && ! -e $(flag_file) ]] || fail "cua input refuses a non-US layout"
! grep -q '^hyprctl:plugin load' "$TEST_LOG" || fail "cua input refuses a non-US layout" "plugin loaded anyway"
pass "cua input refuses a non-US layout"

fresh_home
rc=0
TEST_VARIANT=intl "$toggle" on 2>/dev/null || rc=$?
[[ $rc != 0 && ! -e $(flag_file) ]] || fail "cua input refuses a US variant"
pass "cua input refuses a US variant"

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

grep -q '^notify:.*Cua input on' "$TEST_LOG" || fail "cua input reports the keymap change" "$(cat "$TEST_LOG")"
pass "cua input reports the keymap change"

[[ $(TEST_CUA_READY=1 "$toggle" --status) == '{"enabled":true,"loaded":false,"ready":true}' ]] || fail "cua input reports status" "$(TEST_CUA_READY=1 "$toggle" --status)"
pass "cua input reports status"

# An already loaded module is not loaded twice; a keymap the flag already set
# is not re-checked against the flag.
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

# A check that no longer passes turns the flag off instead of keeping the
# keymap changed for a plugin that never loads.
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
