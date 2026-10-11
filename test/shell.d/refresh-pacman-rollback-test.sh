#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-refresh-pacman

export OMARCHY_REFRESH_TEST_ROOT="$boundary_tmp/fs"
mkdir -p "$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.d" "$SUDO_TEST_ROOT/default/pacman"
cp "$ROOT/default/pacman/"{pacman-stable.conf,mirrorlist-stable,pacman-edge.conf,mirrorlist-edge} "$SUDO_TEST_ROOT/default/pacman/"

# Replace only the fixture's cp dispatcher: sudo and its cleanup remain real
# orchestration, while every /etc path is mapped into the disposable filesystem.
rm "$SUDO_TEST_ROOT/bin/cp"
cat >"$SUDO_TEST_ROOT/bin/cp" <<'STUB'
#!/bin/bash
set -euo pipefail
printf 'copy:%s\n' "$2" >>"$SUDO_TEST_LOG"
rerooted=()
for arg in "$@"; do
  case "$arg" in
    /etc/*) rerooted+=("$OMARCHY_REFRESH_TEST_ROOT$arg") ;;
    *) rerooted+=("$arg") ;;
  esac
done
if [[ $2 == "${OMARCHY_REFRESH_TEST_COPY_FAIL:-}" ]]; then
  # Model a failed copy that already truncated its destination.
  printf 'partial copy\n' >"${rerooted[2]}"
  exit 23
fi
if [[ $2 == "${OMARCHY_REFRESH_TEST_RESTORE_FAIL:-}" ]]; then
  exit 29
fi
/usr/bin/cp "${rerooted[@]}"
"$SUDO_TEST_ROOT/bin/test-pause" "$2"
STUB
chmod +x "$SUDO_TEST_ROOT/bin/cp"

cat >"$SUDO_TEST_ROOT/bin/test-pause" <<'STUB'
#!/bin/bash
if [[ $1 == "${OMARCHY_REFRESH_TEST_PAUSE:-}" ]]; then
  touch "$SUDO_TEST_ROOT/ready"
  while [[ ! -e $SUDO_TEST_ROOT/release ]]; do sleep 0.01; done
fi
STUB
chmod +x "$SUDO_TEST_ROOT/bin/test-pause"
python3 - "$SUDO_TEST_ROOT/bin/test-step" <<'PYTHON'
import sys
from pathlib import Path
p = Path(sys.argv[1])
p.write_text(p.read_text().replace('if [[ ${SUDO_TEST_FAIL_STEP:-}', r'''if [[ $step == "pacman" ]]; then
  printf 'selected channel database\n' >"$OMARCHY_REFRESH_TEST_ROOT/var/lib/pacman/sync/core.db"
  if [[ ${OMARCHY_REFRESH_TEST_PARTIAL_UPGRADE:-0} == "1" ]]; then
    printf 'updated package\n' >"$OMARCHY_REFRESH_TEST_ROOT/var/lib/pacman/local/example.desc"
  fi
fi
"$SUDO_TEST_ROOT/bin/test-pause" "$step"
if [[ ${SUDO_TEST_FAIL_STEP:-}'''))
PYTHON

# Model loss of authorization after the terminal disappears. Timestamp
# revocation still works, but neither privileged restore command may run.
python3 - "$SUDO_TEST_ROOT/mock/sudo" <<'PYTHON'
import sys
from pathlib import Path
p = Path(sys.argv[1])
p.write_text(p.read_text().replace('(( $# )) || exit 0', '''(( $# )) || exit 0
if [[ ${OMARCHY_REFRESH_TEST_RESTORE_AUTH_FAIL:-0} == 1 && ${1:-} == cp && ${3:-} == *.bak ]]; then
  echo 'sudo: a terminal is required to read the password' >&2
  exit 1
fi'''))
PYTHON

reset_config() {
  reset_boundary
  mkdir -p "$OMARCHY_REFRESH_TEST_ROOT/var/lib/pacman/"{sync,local}
  printf 'original package\n' >"$OMARCHY_REFRESH_TEST_ROOT/var/lib/pacman/local/example.desc"
  printf 'original channel database\n' >"$OMARCHY_REFRESH_TEST_ROOT/var/lib/pacman/sync/core.db"
  unset OMARCHY_REFRESH_TEST_COPY_FAIL OMARCHY_REFRESH_TEST_RESTORE_FAIL OMARCHY_REFRESH_TEST_PAUSE OMARCHY_REFRESH_TEST_RESTORE_AUTH_FAIL OMARCHY_REFRESH_TEST_PARTIAL_UPGRADE
  rm -f "$SUDO_TEST_ROOT/ready" "$SUDO_TEST_ROOT/release"
  printf 'original pacman config\n' >"$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.conf"
  printf 'original mirrorlist\n' >"$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.d/mirrorlist"
  rm -f "$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.conf.bak" "$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.d/mirrorlist.bak"
}

run_refresh() {
  "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" "${1:-stable}" >"$boundary_tmp/output" 2>&1
}

assert_status() {
  local expected=$1 actual=0
  shift
  run_refresh "$@" || actual=$?
  [[ $actual == "$expected" ]] || fail "refresh status: expected $expected, got $actual" "$(<"$boundary_tmp/output")"
  assert_boundary_cold "refresh status $expected"
}

assert_original_config() {
  grep -qx 'original pacman config' "$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.conf" ||
    fail "$1: pacman.conf was not restored"
  grep -qx 'original mirrorlist' "$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.d/mirrorlist" ||
    fail "$1: mirrorlist was not restored"
}

assert_no_downstream() {
  if grep -Eq '^step:(omarchy-hook|pacman) ' "$SUDO_TEST_LOG"; then
    fail "hook or transaction ran after a failed copy" "$(<"$SUDO_TEST_LOG")"
  fi
}

reset_config
assert_status 2 invalid
assert_original_config "invalid channel"
[[ $(grep -c '^copy:' "$SUDO_TEST_LOG") == 0 ]] || fail "invalid channel copied configuration"
pass "invalid channel fails before any copy and exits cold"

for file in /etc/pacman.conf /etc/pacman.d/mirrorlist; do
  reset_config
  export OMARCHY_REFRESH_TEST_COPY_FAIL=$file
  assert_status 23
  assert_original_config "failed backup of $file"
  assert_no_downstream
  if grep -q '^copy:.*\.bak$' "$SUDO_TEST_LOG"; then fail "failed backup must not be restored"; fi
  pass "failed backup of $file leaves live configuration unchanged and skips downstream work"
done

for file in pacman-stable.conf mirrorlist-stable; do
  reset_config
  export OMARCHY_REFRESH_TEST_COPY_FAIL="$SUDO_TEST_ROOT/default/pacman/$file"
  assert_status 23
  assert_original_config "failed channel copy of $file"
  assert_no_downstream
  pass "partial copy of $file restores both files, preserves status, and skips downstream work"
done

for step in omarchy-hook pacman; do
  reset_config
  export SUDO_TEST_FAIL_STEP=$step
  assert_status 17
  assert_original_config "failed $step"
  grep -q 'Previous pacman configuration restored.' "$boundary_tmp/output" || fail "rollback not reported"
  if [[ $step == "omarchy-hook" ]] && grep -q '^step:pacman ' "$SUDO_TEST_LOG"; then
    fail "transaction ran after hook runner failure"
  fi
  python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
lines = open(sys.argv[1]).read().splitlines()
restore = next(i for i, line in enumerate(lines) if line == 'sudo -N cp -f /etc/pacman.conf.bak /etc/pacman.conf')
assert lines[restore - 1] == 'sudo -k', lines
assert all(line in ('sudo -h', 'sudo -k') or line.startswith('sudo -N ') for line in lines if line.startswith('sudo ')), lines
PY
  pass "$step failure restores both files, preserves status, and revokes credentials before rollback and exit"
  if [[ $step == "pacman" ]]; then
    grep -qx 'selected channel database' "$OMARCHY_REFRESH_TEST_ROOT/var/lib/pacman/sync/core.db" || fail "database mismatch was not exercised"
    grep -Fq 'Package databases may still belong to the failed channel.' "$boundary_tmp/output" || fail "stale databases were not reported"
    grep -Fq "Run 'sudo pacman -Syy' before installing packages" "$boundary_tmp/output" || fail "database recovery guidance was not reported"
    [[ $(grep -c '^step:pacman ' "$SUDO_TEST_LOG") == 1 ]] || fail "cleanup unexpectedly started another package operation"
    pass "rollback warns about retained channel databases and requires a database refresh before installing packages"
  fi
done

reset_config
export SUDO_TEST_FAIL_STEP=pacman OMARCHY_REFRESH_TEST_PARTIAL_UPGRADE=1
assert_status 17 edge
assert_original_config "failed transaction after package changes"
grep -qx 'updated package' "$OMARCHY_REFRESH_TEST_ROOT/var/lib/pacman/local/example.desc" || fail "partial upgrade was not exercised"
grep -Fq 'A database refresh does not complete or undo any package changes.' "$boundary_tmp/output" || fail "partial upgrade limitation was not reported"
grep -Fq 'If package changes began, resolve the error and retry the command that started this refresh before installing more packages.' "$boundary_tmp/output" || fail "initiating-command retry guidance was not reported"
pass "rollback guidance after simulated package changes tells users to retry the initiating command"

for file in /etc/pacman.conf.bak /etc/pacman.d/mirrorlist.bak; do
  reset_config
  export SUDO_TEST_FAIL_STEP=pacman OMARCHY_REFRESH_TEST_RESTORE_FAIL=$file
  assert_status 17
  grep -q 'Failed to restore the previous pacman configuration.' "$boundary_tmp/output" || fail "restore failure not reported"
  [[ $(grep -c '^copy:.*\.bak$' "$SUDO_TEST_LOG") == 2 ]] || fail "both restorations must be attempted"
  if [[ $file == /etc/pacman.conf.bak ]]; then
    grep -qx 'original mirrorlist' "$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.d/mirrorlist" || fail "mirrorlist restore skipped"
  else
    grep -qx 'original pacman config' "$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.conf" || fail "pacman.conf restore skipped"
  fi
  pass "failed restore from $file still attempts both files, reports failure, and preserves transaction status"
done

reset_config
assert_status 0
cmp -s "$ROOT/default/pacman/pacman-stable.conf" "$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.conf" || fail "successful refresh lost channel config"
cmp -s "$ROOT/default/pacman/mirrorlist-stable" "$OMARCHY_REFRESH_TEST_ROOT/etc/pacman.d/mirrorlist" || fail "successful refresh lost mirrorlist"
[[ $(grep -c '^copy:' "$SUDO_TEST_LOG") == 4 ]] || fail "success must only back up and switch the two files"
grep -q '^step:pacman -Syyuu --noconfirm$' "$SUDO_TEST_LOG" || fail "transaction arguments changed"
pass "successful refresh keeps the selected channel, uses four copies, and exits cold"

# Launch from Python with default signal dispositions: asynchronous shells and
# nohup otherwise inherit ignored INT/HUP and would not exercise the real traps.
cat >"$boundary_tmp/interrupt.py" <<'PYTHON'
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

mode, stage, expected = sys.argv[1], sys.argv[2], int(sys.argv[3])
root = Path(os.environ['SUDO_TEST_ROOT'])
fs = Path(os.environ['OMARCHY_REFRESH_TEST_ROOT'])
log = Path(os.environ['SUDO_TEST_LOG'])
command = [str(root / 'bin/omarchy-refresh-pacman'), 'stable']
for sig in (signal.SIGHUP, signal.SIGINT, signal.SIGTERM):
    signal.signal(sig, signal.SIG_DFL)
with (root / 'first-output').open('w') as output:
    first = subprocess.Popen(command, stdout=output, stderr=output, start_new_session=True)
    try:
        deadline = time.monotonic() + 10
        while not (root / 'ready').exists():
            assert first.poll() is None, (root / 'first-output').read_text()
            assert time.monotonic() < deadline, 'first refresh did not reach pause'
            time.sleep(0.01)
        backups = [(fs / name).read_bytes() for name in ('etc/pacman.conf.bak', 'etc/pacman.d/mirrorlist.bak')]
        if mode != 'overlap':
            first.send_signal(getattr(signal, 'SIG' + mode))
            time.sleep(0.05)
            assert first.poll() is None, 'refresh exited before its child finished'
            if not stage.endswith('.bak'):
                assert 'copy:/etc/pacman.conf.bak' not in log.read_text(), 'rollback raced its child'
        # Use separate test credentials/logs to model a different caller. It
        # must contend on the same filesystem lock, not on a per-user lock.
        second_env = dict(os.environ, SUDO_TEST_LOG=str(root / 'second-log'),
                          SUDO_TEST_CACHE=str(root / 'second-cache'),
                          XDG_RUNTIME_DIR=str(root / 'another-runtime'))
        second_env.pop('OMARCHY_REFRESH_TEST_PAUSE', None)
        second_env.pop('SUDO_TEST_FAIL_STEP', None)
        second = subprocess.run(command, env=second_env, capture_output=True, text=True, timeout=10)
        assert second.returncode == 1, second
        assert 'already running' in second.stderr, second.stderr
        assert 'copy:' not in (root / 'second-log').read_text(), 'overlap changed backups'
        assert (root / 'second-log').read_text().splitlines()[-1] == 'sudo -k'
        assert backups == [(fs / name).read_bytes() for name in ('etc/pacman.conf.bak', 'etc/pacman.d/mirrorlist.bak')]
        (root / 'release').touch()
        assert first.wait(timeout=10) == expected, (root / 'first-output').read_text()
    finally:
        if first.poll() is None:
            os.killpg(first.pid, signal.SIGKILL)
            first.wait()
lines = log.read_text().splitlines()
assert lines[-1] == 'sudo -k', lines
assert not Path(os.environ['SUDO_TEST_CACHE']).exists()
if expected and os.environ.get('OMARCHY_REFRESH_TEST_RESTORE_AUTH_FAIL') == '1':
    output = (root / 'first-output').read_text()
    assert 'Failed to restore the previous pacman configuration.' in output, output
    assert 'Previous pacman configuration restored.' not in output, output
    assert "Run 'sudo pacman -Syy'" not in output, output
    for src, dst in [('pacman.conf.bak', 'pacman.conf'), ('pacman.d/mirrorlist.bak', 'pacman.d/mirrorlist')]:
        assert f'sudo -N cp -f /etc/{src} /etc/{dst}' in lines, lines
    assert (fs / 'etc/pacman.conf').read_bytes() == (root / 'default/pacman/pacman-stable.conf').read_bytes()
    assert (fs / 'etc/pacman.d/mirrorlist').read_bytes() == (root / 'default/pacman/mirrorlist-stable').read_bytes()
elif expected:
    assert (fs / 'etc/pacman.conf').read_text() == 'original pacman config\n'
    assert (fs / 'etc/pacman.d/mirrorlist').read_text() == 'original mirrorlist\n'
    assert lines.count('copy:/etc/pacman.conf.bak') == 1, lines
    assert lines.count('copy:/etc/pacman.d/mirrorlist.bak') == 1, lines
else:
    assert (fs / 'etc/pacman.conf').read_bytes() == (root / 'default/pacman/pacman-stable.conf').read_bytes()
    assert (fs / 'etc/pacman.d/mirrorlist').read_bytes() == (root / 'default/pacman/mirrorlist-stable').read_bytes()
if mode != 'overlap' and not stage.endswith('.bak'):
    if stage.endswith('pacman-stable.conf'):
        assert not any(line.startswith('copy:') and line.endswith('mirrorlist-stable') for line in lines), lines
    if stage not in ('omarchy-hook', 'pacman'):
        assert not any(line.startswith('step:omarchy-hook ') for line in lines), lines
    if stage != 'pacman':
        assert not any(line.startswith('step:pacman ') for line in lines), lines
PYTHON

for sig in HUP INT TERM; do
  case "$sig" in HUP) status=129 ;; INT) status=130 ;; TERM) status=143 ;; esac
  for stage in "$SUDO_TEST_ROOT/default/pacman/pacman-stable.conf" "$SUDO_TEST_ROOT/default/pacman/mirrorlist-stable" omarchy-hook pacman; do
    reset_config
    export OMARCHY_REFRESH_TEST_PAUSE=$stage
    python3 "$boundary_tmp/interrupt.py" "$sig" "$stage" "$status" || fail "$sig at $stage"
    # A completed cleanup must release the lock for the next invocation.
    unset OMARCHY_REFRESH_TEST_PAUSE
    assert_status 0
    pass "$sig at ${stage##*/} waits for the child, restores both files, skips later work, and releases the lock"
  done
done

reset_config
export OMARCHY_REFRESH_TEST_PAUSE=omarchy-hook OMARCHY_REFRESH_TEST_RESTORE_AUTH_FAIL=1
python3 "$boundary_tmp/interrupt.py" HUP omarchy-hook 129 || fail "HUP without restore authorization"
unset OMARCHY_REFRESH_TEST_PAUSE OMARCHY_REFRESH_TEST_RESTORE_AUTH_FAIL
assert_status 0
pass "HUP without sudo authorization reports failed restoration, preserves status, and releases the lock"

for stage in omarchy-hook pacman; do
  for status in 0 17; do
    reset_config
    export OMARCHY_REFRESH_TEST_PAUSE=$stage
    if (( status != 0 )); then export SUDO_TEST_FAIL_STEP=$stage; fi
    python3 "$boundary_tmp/interrupt.py" overlap "$stage" "$status" || fail "overlap at $stage with status $status"
    unset OMARCHY_REFRESH_TEST_PAUSE SUDO_TEST_FAIL_STEP
    assert_status 0
    pass "overlap during $stage cannot overwrite backups and the first refresh completes with status $status"
  done
done

for sig in HUP INT TERM; do
  reset_config
  export OMARCHY_REFRESH_TEST_PAUSE=/etc/pacman.conf.bak SUDO_TEST_FAIL_STEP=pacman
  python3 "$boundary_tmp/interrupt.py" "$sig" /etc/pacman.conf.bak 17 || fail "$sig during rollback"
  pass "$sig during rollback cannot interrupt restoration or release the lock early"
done

# The real hook runner deliberately swallows user-hook failures. Such a hook
# must still reach the transaction; the failure above models the runner itself.
reset_config
rm "$SUDO_TEST_ROOT/bin/omarchy-hook"
copy_boundary_file bin/omarchy-hook
mkdir -p "$SUDO_TEST_HOME/.config/omarchy/hooks"
printf 'exit 31\n' >"$SUDO_TEST_HOME/.config/omarchy/hooks/pre-refresh-pacman"
assert_status 0
grep -q 'Hook failed:' "$boundary_tmp/output" || fail "user hook failure not exercised"
grep -q '^step:pacman ' "$SUDO_TEST_LOG" || fail "user hook failure prevented transaction"
[[ $(grep -c '^copy:' "$SUDO_TEST_LOG") == 4 ]] || fail "swallowed hook failure triggered rollback"
pass "a failed user hook retains the real hook runner's continue-to-transaction behavior"

reset_config
cat >"$SUDO_TEST_HOME/.config/omarchy/hooks/pre-refresh-pacman" <<'HOOK'
sleep 30 >/dev/null 2>&1 &
printf '%s\n' "$!" >"$SUDO_TEST_ROOT/background-pid"
HOOK
assert_status 0
background_pid=$(<"$SUDO_TEST_ROOT/background-pid")
# Stop creating background children, then refresh while the first is still alive.
printf 'exit 0\n' >"$SUDO_TEST_HOME/.config/omarchy/hooks/pre-refresh-pacman"
kill -0 "$background_pid" || fail "background hook child exited too early"
assert_status 0
kill "$background_pid"
pass "background hook children do not retain the refresh lock"
