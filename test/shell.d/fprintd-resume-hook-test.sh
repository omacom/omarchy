#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/fprintd-resume"

# systemd execs the files in system-sleep/ directly, so a hook without the
# executable bit silently never runs. The installers set the mode explicitly,
# but the checkout should not ship a hook that cannot run as-is either.
[[ -x $hook ]] ||
  fail "the resume hook is executable" "mode: $(stat -c '%A' "$hook")"
pass "the resume hook is executable"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/systemctl-calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
if [[ $* == "--quiet is-active fprintd.service" ]]; then
  exit "${ACTIVE:-0}"
fi
if [[ $1 == stop ]]; then
  exit "${STOP:-0}"
fi
printf 'unexpected systemctl %s\n' "$*" >&2
exit 99
SH
cat >"$mock_bin/timeout" <<'SH'
#!/bin/bash
shift
exec "$@"
SH
printf '#!/bin/sh\nexit 0\n' >"$mock_bin/sleep"
chmod +x "$mock_bin/"*

run_hook() {
  local active=$1 stop=$2
  shift 2
  : >"$call_log"
  ACTIVE=$active STOP=$stop CALL_LOG=$call_log PATH="$mock_bin:$PATH" "$hook" "$@"
}

# The lock screen starts fprintd while suspend is already running, and that
# daemon misses its sleep inhibitor. Stop it before the freezer so the claim
# is not frozen across resume. D-Bus starts a fresh one after thaw.
run_hook 0 0 pre suspend ||
  fail "pre-suspend stops an active fprintd"
grep -Fxq -- '--quiet is-active fprintd.service' "$call_log" ||
  fail "pre-suspend asks whether fprintd is active" "calls: $(<"$call_log")"
grep -Fxq 'stop fprintd.service' "$call_log" ||
  fail "pre-suspend stops an active fprintd" "calls: $(<"$call_log")"
if grep -q 'try-restart' "$call_log"; then
  fail "pre-suspend does not restart fprintd" "calls: $(<"$call_log")"
fi
pass "pre-suspend stops an active fprintd"

# Hibernate uses the same pre path. The hook does not care how the machine slept.
run_hook 0 0 pre hibernate ||
  fail "pre-hibernate stops an active fprintd"
grep -Fxq 'stop fprintd.service' "$call_log" ||
  fail "pre-hibernate stops an active fprintd" "calls: $(<"$call_log")"
pass "pre-hibernate stops an active fprintd"

# An already-stopped daemon must not fail the sleep, and there is nothing to stop.
run_hook 3 0 pre suspend ||
  fail "pre-suspend leaves an inactive fprintd alone"
if grep -q 'stop' "$call_log"; then
  fail "pre-suspend leaves an inactive fprintd alone" "calls: $(<"$call_log")"
fi
pass "pre-suspend leaves an inactive fprintd alone"

# A stop that fails must not fail the sleep. The hook's own timeout and the
# drop-in's TimeoutStopSec are the backstops; suspend still proceeds.
run_hook 0 1 pre suspend ||
  fail "a failed stop does not fail the hook" "calls: $(<"$call_log")"
grep -Fxq 'stop fprintd.service' "$call_log" ||
  fail "a failed stop was still attempted" "calls: $(<"$call_log")"
pass "a failed stop does not fail the hook"

# The drop-in bounds that stop. Without it a daemon that ignores SIGTERM
# holds the sleep transition for fprintd's default stop timeout.
dropin="$ROOT/default/systemd/system/fprintd.service.d/10-stop-timeout.conf"
grep -Eq '^TimeoutStopSec=[0-9]+s?$' "$dropin" ||
  fail "the stop-timeout drop-in bounds TimeoutStopSec" "content: $(<"$dropin")"
pass "the stop-timeout drop-in bounds TimeoutStopSec"

# After resume, do nothing. A try-restart queued here can stop the daemon the
# lock screen has just opened, and a restart from inside the hook waits on
# the sleep transaction that is waiting on the hook.
run_hook 0 0 post suspend ||
  fail "resume does not call systemctl"
[[ ! -s $call_log ]] ||
  fail "resume does not call systemctl" "calls: $(<"$call_log")"
pass "resume does not call systemctl"

run_hook 0 0 post hibernate ||
  fail "resume from hibernate does not call systemctl"
[[ ! -s $call_log ]] ||
  fail "resume from hibernate does not call systemctl" "calls: $(<"$call_log")"
pass "resume from hibernate does not call systemctl"

run_hook 0 0 ||
  fail "no phase does not call systemctl"
[[ ! -s $call_log ]] ||
  fail "no phase does not call systemctl" "calls: $(<"$call_log")"
pass "no phase does not call systemctl"
