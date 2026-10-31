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

cat >"$mock_bin/systemctl" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"$call_log"
SH
chmod +x "$mock_bin/systemctl"

run_hook() {
  : >"$call_log"
  PATH="$mock_bin:$PATH" "$hook" "$@"
}

# Resume ("post") is the only edge that clears a claim wedged across suspend.
# The restart is enqueued, not awaited: user sessions stay frozen until the
# hook returns, and a wedged fprintd can ride out its whole stop timeout.
run_hook post suspend
[[ $(<"$call_log") == "--no-block try-restart fprintd.service" ]] ||
  fail "resume enqueues an fprintd restart to clear a wedged claim" "calls: $(<"$call_log")"
pass "resume enqueues an fprintd restart to clear a wedged claim"

# The claim only wedges once the verify dies under suspend, so there is
# nothing to clear before sleep; a restart there would just take the reader
# away from the verify the lock screen still has open. "pre" must do nothing.
run_hook pre suspend
[[ -z $(<"$call_log") ]] ||
  fail "pre-suspend leaves fprintd alone" "calls: $(<"$call_log")"
pass "pre-suspend leaves fprintd alone"

# Exercise the runtime installer through a real inaccessible directory. These
# tests run without host privileges: the sudo boundary opens only that fixture
# directory while running the real stat/install command, then closes it again.
# Mode 000 gives the unprivileged process the same EACCES as root-owned 0700.
if (( EUID == 0 )); then
  skip "the protected-parent installer fixture needs an unprivileged caller"
  exit 0
fi

private_dir="$tmpdir/private"
mkdir -p "$private_dir"
export TEST_RESUME_PRIVATE_DIR="$private_dir"
export TEST_RESUME_SYSTEMCTL_LOG="$call_log"
export TEST_RESUME_PROBE_FAILURE=0
export TEST_RESUME_RELOAD_NEEDED=yes
export OMARCHY_FPRINTD_RESUME_SRC="$ROOT/default/systemd/system-sleep/fprintd-resume"
export OMARCHY_FPRINTD_RESUME_DST="$private_dir/fprintd-resume"
export OMARCHY_FPRINTD_STOP_TIMEOUT_SRC="$ROOT/default/systemd/system/fprintd.service.d/10-stop-timeout.conf"
export OMARCHY_FPRINTD_STOP_TIMEOUT_DST="$private_dir/10-stop-timeout.conf"
export OMARCHY_LOCK_FINGERPRINT_PAM="$tmpdir/lock-pam"
printf '# fixture fingerprint stack\n' >"$OMARCHY_LOCK_FINGERPRINT_PAM"

cat >"$mock_bin/sudo" <<'SHIM'
#!/bin/bash
set -uo pipefail
if [[ ${TEST_RESUME_SUDO_FAILURE:-0} == 1 ]]; then
  exit 1
fi
if [[ ${TEST_RESUME_SUDO_FAIL_ONCE:-0} == 1 && ! -e $TEST_RESUME_SUDO_MARKER ]]; then
  : >"$TEST_RESUME_SUDO_MARKER"
  exit 1
fi
if [[ ${TEST_RESUME_PROBE_FAILURE:-0} == 1 && $1 == /usr/bin/python3 ]]; then
  # Keep the path inaccessible even at the boundary: the real lstat must
  # report EACCES, which cannot be interpreted as permission to install.
  exec "$@"
fi
mode=$(stat -c %a "$TEST_RESUME_PRIVATE_DIR")
chmod 700 "$TEST_RESUME_PRIVATE_DIR"
trap 'chmod "$mode" "$TEST_RESUME_PRIVATE_DIR"' EXIT
"$@"
SHIM
cat >"$mock_bin/systemctl" <<'SHIM'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_RESUME_SYSTEMCTL_LOG"
if [[ $1 == show ]]; then
  printf '%s\n' "$TEST_RESUME_RELOAD_NEEDED"
fi
SHIM
chmod +x "$mock_bin/sudo" "$mock_bin/systemctl"
# Retarget only the service binary; production decisions and filesystem calls
# are unchanged, and no command can reach the live systemd instance.
resume_apply="$tmpdir/apply-resume"
sed "s|/usr/bin/systemctl|$mock_bin/systemctl|g" "$ROOT/bin/omarchy-apply-fprintd-resume" >"$resume_apply"
chmod +x "$resume_apply"
trap 'chmod 700 "$private_dir"; rm -rf "$tmpdir"' EXIT

run_apply() {
  : >"$call_log"
  PATH="$mock_bin:$PATH" "$resume_apply" "$@"
}

chmod 000 "$private_dir"
run_apply
chmod 700 "$private_dir"
[[ -x $OMARCHY_FPRINTD_RESUME_DST && -f $OMARCHY_FPRINTD_STOP_TIMEOUT_DST ]] ||
  fail "missing recovery files install through a protected parent"
[[ $(<"$call_log") == $'show fprintd.service --property=NeedDaemonReload --value\ndaemon-reload' ]] ||
  fail "a newly installed protected drop-in triggers daemon reload" "calls: $(<"$call_log")"
pass "missing recovery files install and reload through a protected parent"

printf '# custom resume hook\n' >"$OMARCHY_FPRINTD_RESUME_DST"
printf '[Service]\nTimeoutStopSec=11s\n' >"$OMARCHY_FPRINTD_STOP_TIMEOUT_DST"
cp "$OMARCHY_FPRINTD_RESUME_DST" "$tmpdir/custom-hook"
cp "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST" "$tmpdir/custom-timeout"
chmod 000 "$private_dir"
run_apply
chmod 700 "$private_dir"
cmp -s "$OMARCHY_FPRINTD_RESUME_DST" "$tmpdir/custom-hook" &&
  cmp -s "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST" "$tmpdir/custom-timeout" ||
  fail "existing custom recovery files behind a protected parent are preserved"
[[ $(<"$call_log") == $'show fprintd.service --property=NeedDaemonReload --value\ndaemon-reload' ]] ||
  fail "an existing protected drop-in can finish a pending reload"
pass "custom protected recovery files survive and a pending reload completes"

rm "$OMARCHY_FPRINTD_RESUME_DST" "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST"
ln -s "$tmpdir/missing-hook" "$OMARCHY_FPRINTD_RESUME_DST"
ln -s "$tmpdir/missing-timeout" "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST"
chmod 000 "$private_dir"
run_apply
chmod 700 "$private_dir"
[[ -L $OMARCHY_FPRINTD_RESUME_DST && $(readlink "$OMARCHY_FPRINTD_RESUME_DST") == "$tmpdir/missing-hook" &&
  -L $OMARCHY_FPRINTD_STOP_TIMEOUT_DST && $(readlink "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST") == "$tmpdir/missing-timeout" &&
  ! -e $tmpdir/missing-hook && ! -e $tmpdir/missing-timeout && ! -s $call_log ]] ||
  fail "dangling recovery symlinks are preserved without creating their targets or reloading"
rm "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST"
ln -s "$tmpdir/custom-timeout" "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST"
chmod 000 "$private_dir"
run_apply
chmod 700 "$private_dir"
[[ -L $OMARCHY_FPRINTD_STOP_TIMEOUT_DST && $(readlink "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST") == "$tmpdir/custom-timeout" &&
  $(<"$tmpdir/custom-timeout") == $'[Service]\nTimeoutStopSec=11s' &&
  $(<"$call_log") == $'show fprintd.service --property=NeedDaemonReload --value\ndaemon-reload' ]] ||
  fail "a symlink to an existing custom drop-in is preserved and permits a pending reload"
pass "dangling and existing-target recovery symlinks behind a protected parent survive"

rm "$OMARCHY_FPRINTD_RESUME_DST" "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST"
chmod 000 "$private_dir"
export TEST_RESUME_PROBE_FAILURE=1
if run_apply; then
  fail "an unavailable privileged lookup must leave the operation pending"
fi
chmod 700 "$private_dir"
[[ ! -e $OMARCHY_FPRINTD_RESUME_DST && ! -e $OMARCHY_FPRINTD_STOP_TIMEOUT_DST && ! -s $call_log ]] ||
  fail "an unknown protected-path state must not install or reload"
pass "an unavailable privileged lookup does not authorize writes"
export TEST_RESUME_PROBE_FAILURE=0

# The prerequisite itself is protected, so its state must be classified by
# the same authority that will install the recovery files.
export OMARCHY_LOCK_FINGERPRINT_PAM="$private_dir/lock-pam"
printf '# protected fixture stack\n' >"$OMARCHY_LOCK_FINGERPRINT_PAM"
chmod 000 "$private_dir"
run_apply
chmod 700 "$private_dir"
[[ -x $OMARCHY_FPRINTD_RESUME_DST && -f $OMARCHY_FPRINTD_STOP_TIMEOUT_DST ]] ||
  fail "a protected PAM prerequisite permits installation"
rm "$OMARCHY_FPRINTD_RESUME_DST" "$OMARCHY_FPRINTD_STOP_TIMEOUT_DST" "$OMARCHY_LOCK_FINGERPRINT_PAM"
chmod 000 "$private_dir"
run_apply
chmod 700 "$private_dir"
[[ ! -e $OMARCHY_FPRINTD_RESUME_DST && ! -e $OMARCHY_FPRINTD_STOP_TIMEOUT_DST && ! -s $call_log ]] ||
  fail "a confirmed absent prerequisite does not install"
printf '# protected fixture stack\n' >"$OMARCHY_LOCK_FINGERPRINT_PAM"
chmod 000 "$private_dir"
export TEST_RESUME_SUDO_FAIL_ONCE=1 TEST_RESUME_SUDO_MARKER="$tmpdir/first-sudo-failed"
if run_apply; then fail "first sudo failure must not be classified as absence"; fi
[[ -e $TEST_RESUME_SUDO_MARKER ]] || fail "the first sudo call must have failed"
export TEST_RESUME_SUDO_FAIL_ONCE=0
chmod 700 "$private_dir"
[[ ! -e $OMARCHY_FPRINTD_RESUME_DST && ! -e $OMARCHY_FPRINTD_STOP_TIMEOUT_DST && ! -s $call_log ]] ||
  fail "a failed prerequisite lookup leaves recovery pending"
pass "protected and absent PAM prerequisites and failed sudo are distinguished"
export OMARCHY_LOCK_FINGERPRINT_PAM="$tmpdir/lock-pam"

chmod 000 "$private_dir"
run_apply --reload-only
chmod 700 "$private_dir"
[[ ! -e $OMARCHY_FPRINTD_RESUME_DST && ! -e $OMARCHY_FPRINTD_STOP_TIMEOUT_DST && ! -s $call_log ]] ||
  fail "reload-only repair must not recreate files an owner removed"
printf '[Service]\nTimeoutStopSec=11s\n' >"$OMARCHY_FPRINTD_STOP_TIMEOUT_DST"
chmod 000 "$private_dir"
run_apply --reload-only
chmod 700 "$private_dir"
[[ ! -e $OMARCHY_FPRINTD_RESUME_DST && $(<"$call_log") == $'show fprintd.service --property=NeedDaemonReload --value\ndaemon-reload' ]] ||
  fail "reload-only repair sees the existing protected drop-in without replaying setup"
export TEST_RESUME_RELOAD_NEEDED=no
chmod 000 "$private_dir"
run_apply --reload-only
[[ $(<"$call_log") == 'show fprintd.service --property=NeedDaemonReload --value' ]] ||
  fail "an already-current unit does not reload"
pass "reload-only repair preserves absent hooks and reloads only a stale existing drop-in"
