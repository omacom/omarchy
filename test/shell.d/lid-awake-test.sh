#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

toggle="$ROOT/bin/omarchy-toggle-lid-awake"
guard="$ROOT/bin/omarchy-lid-awake-guard"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
fake_bin="$test_tmp/bin"
log="$test_tmp/log"
mkdir -p "$HOME" "$fake_bin"
: >"$log"

# systemd is faked: systemd-run records the unit as active, systemctl reports
# and stops it. The unit hooks are exercised by hand, as systemd would run them.
cat >"$fake_bin/systemd-run" <<STUB
#!/bin/bash
printf 'run %s\n' "\$*" >>"$log"
touch "$test_tmp/active"
for arg in "\$@"; do
  [[ \$arg == --property=ExecStartPre=* ]] && \${arg#--property=ExecStartPre=}
done
STUB
cat >"$fake_bin/systemctl" <<STUB
#!/bin/bash
case "\$2" in
  is-active) [[ -f "$test_tmp/active" ]] ;;
  stop) rm -f "$test_tmp/active"; rm -f "$HOME/.local/state/omarchy/indicators/lid-awake" ;;
esac
STUB

# The guard's readings come from files the scenarios rewrite.
cat >"$fake_bin/df" <<STUB
#!/bin/bash
printf 'Avail\n'
echo \$(( \$(<"$test_tmp/free_gb") * 1024 * 1024 * 1024 ))
STUB
cat >"$fake_bin/omarchy-battery-status" <<STUB
#!/bin/bash
[[ -f "$test_tmp/battery" ]] && cat "$test_tmp/battery"
exit 0
STUB
cat >"$fake_bin/omarchy-notification-send" <<STUB
#!/bin/bash
printf 'notify %s\n' "\$*" >>"$log"
STUB
cat >"$fake_bin/omarchy-toggle-lid-awake" <<STUB
#!/bin/bash
printf 'toggle %s\n' "\$*" >>"$log"
STUB
chmod +x "$fake_bin"/*

state="$HOME/.local/state/omarchy/indicators/lid-awake"
run_toggle() { PATH="$fake_bin:$PATH" "$toggle" "$@"; }

# --- toggle ---
[[ $(run_toggle status) == *'"enabled":false'* ]] || fail "status starts disabled"

[[ $(run_toggle on) == "enabled" ]] || fail "on reports enabled"
[[ -f $state ]] || fail "on creates the state file"
grep -q 'handle-lid-switch' "$log" || fail "on holds the handle-lid-switch inhibitor" "$(<"$log")"

before=$(grep -c '^run ' "$log")
run_toggle on >/dev/null
(( $(grep -c '^run ' "$log") == before )) || fail "a second on does not start another unit"
pass "on holds one inhibitor and writes the state file"

[[ $(run_toggle status) == *'"enabled":true'* ]] || fail "status reports enabled"

[[ $(run_toggle toggle) == "disabled" ]] || fail "toggle turns it off"
[[ ! -f $state ]] || fail "off removes the state file"
run_toggle off >/dev/null || fail "off is idempotent"
pass "toggle and off release the inhibitor and clear state"

# A stale file with no unit behind it is cleared by off.
mkdir -p "${state%/*}"; touch "$state"
run_toggle off >/dev/null
[[ ! -f $state ]] || fail "off clears a stale state file"
pass "a stale state file is cleared"

if run_toggle bogus 2>/dev/null; then fail "an unknown argument is rejected"; fi
pass "unknown argument rejected"

# --- guard: one pass, then the fake sleep ends the loop ---
cat >"$fake_bin/sleep" <<'STUB'
#!/bin/bash
kill "$PPID"
STUB
chmod +x "$fake_bin/sleep"
run_guard() {
  : >"$log"
  # The fake sleep kills the guard, so it runs exactly one pass.
  PATH="$fake_bin:$PATH" OMARCHY_PATH="$ROOT" timeout 10 "$guard" 2>/dev/null || true
}
battery_file() { printf 'percentage\t%s%%\nstate\t%s\n' "$1" "$2" >"$test_tmp/battery"; }

echo 50 >"$test_tmp/free_gb"; rm -f "$test_tmp/battery"
run_guard
[[ ! -s $log ]] || fail "plenty of space and no battery: silent" "$(<"$log")"
pass "healthy machine stays silent"

echo 8 >"$test_tmp/free_gb"
run_guard
grep -q '^notify' "$log" && ! grep -q '^toggle' "$log" || fail "low disk warns without stopping" "$(<"$log")"
pass "low disk warns only"

echo 2 >"$test_tmp/free_gb"
run_guard
grep -q '^toggle off' "$log" || fail "critical disk releases the lid" "$(<"$log")"
pass "critical disk turns lid-awake off"

echo 50 >"$test_tmp/free_gb"; battery_file 5 discharging
run_guard
grep -q '^toggle off' "$log" || fail "critical battery releases the lid" "$(<"$log")"
pass "critical battery turns lid-awake off"

battery_file 5 charging
run_guard
[[ ! -s $log ]] || fail "a low but charging battery is ignored" "$(<"$log")"
pass "charging battery is ignored"
