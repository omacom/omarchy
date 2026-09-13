#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin"

# Keep package-path checks scoped to the fixture, even with a live app open.
python3 - "$ROOT/bin/omarchy-remove-ai-hermes" "$test_tmp" <<'PY'
from pathlib import Path
import sys
source, scratch = map(Path, sys.argv[1:])
(scratch / 'remover').write_text(source.read_text().replace('/opt/hermes-desktop', str(scratch / 'package')))
PY

cat >"$mock_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_DROP_LOG"
SH

# The CLI teardown is the installer's own, exercised in hermes-cli-test.sh; here
# it is mocked to a logger so this test stays about what Remove Hermes does with
# ~/.hermes, and to keep real mise out of a run with HOME pointed at a fixture.
cat >"$mock_bin/omarchy-install-hermes-cli" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_INSTALLER_LOG"
exit "${OMARCHY_TEST_INSTALLER_STATUS:-0}"
SH

# The remover asks through gum whether the user's data should go too. The stub
# answers "no" unless a test says otherwise, and logs every call: a real gum
# would hang a test run, and one that answered "yes" on its own would be the
# very data loss the default-no exists to prevent.
cat >"$mock_bin/gum" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_GUM_LOG"
if [[ -n ${OMARCHY_TEST_PROMPT_GATE:-} ]]; then
  touch "$OMARCHY_TEST_PROMPT_GATE.started"
  for (( attempt=0; attempt<500; attempt++ )); do
    [[ ! -e $OMARCHY_TEST_PROMPT_GATE.continue ]] || exit 0
    sleep 0.01
  done
  exit 1
fi
exit "${OMARCHY_TEST_GUM_STATUS:-1}"
SH
cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
echo "systemctl $*" >>"$OMARCHY_TEST_SYSTEMCTL_LOG"
SH

chmod +x "$mock_bin"/*

seed_install() {
  rm -rf "$test_home"
  mkdir -p "$test_home/.hermes/hermes-agent" "$test_home/.hermes/bootstrap-cache" \
    "$test_home/.hermes/bin" "$test_home/.hermes/node/bin" \
    "$test_home/.hermes/memories" "$test_home/.hermes/sessions" \
    "$test_home/.config/Hermes" "$test_home/.local/bin"
  printf 'chat\n' >"$test_home/.hermes/sessions/one.json"
  printf 'memory\n' >"$test_home/.hermes/memories/one.md"
  printf 'soul\n' >"$test_home/.hermes/SOUL.md"
  printf 'uv\n' >"$test_home/.hermes/bin/uv"
  ln -sf "$test_home/.hermes/node/bin/node" "$test_home/.local/bin/node"
  ln -sf "$test_home/.hermes/node/bin/npm" "$test_home/.local/bin/npm"
  ln -sf /usr/bin/npx "$test_home/.local/bin/npx"
  printf 'node\n' >"$test_home/.hermes/node/bin/node"
  touch "$test_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
}

# </dev/null pins stdin off a terminal, so these runs exercise the
# non-interactive path no matter where the suite itself is running.
remove() {
  : >"$test_tmp/installer-log"
  : >"$test_tmp/gum-log"
  : >"$test_tmp/systemctl-log"
  OMARCHY_TEST_DROP_LOG="$test_tmp/drop-log" \
    OMARCHY_TEST_INSTALLER_LOG="$test_tmp/installer-log" \
    OMARCHY_TEST_INSTALLER_STATUS="${OMARCHY_TEST_INSTALLER_STATUS:-0}" \
    OMARCHY_TEST_SYSTEMCTL_LOG="$test_tmp/systemctl-log" \
    OMARCHY_TEST_GUM_LOG="$test_tmp/gum-log" \
    HOME="$test_home" PATH="$mock_bin:$PATH" \
    bash "$test_tmp/remover" </dev/null >"$test_tmp/output" 2>&1
}

# script(1) puts the remover on a pty, which is the only way -t 0 answers true
# without a person at a real one; the stubbed gum then supplies the answer.
remove_tty() {
  : >"$test_tmp/installer-log"
  : >"$test_tmp/gum-log"
  : >"$test_tmp/systemctl-log"
  OMARCHY_TEST_DROP_LOG="$test_tmp/drop-log" \
    OMARCHY_TEST_INSTALLER_LOG="$test_tmp/installer-log" \
    OMARCHY_TEST_SYSTEMCTL_LOG="$test_tmp/systemctl-log" \
    OMARCHY_TEST_GUM_LOG="$test_tmp/gum-log" \
    OMARCHY_TEST_GUM_STATUS="${OMARCHY_TEST_GUM_STATUS:-1}" \
    HOME="$test_home" PATH="$mock_bin:$PATH" \
    script -qec "bash '$test_tmp/remover'" /dev/null >"$test_tmp/output" 2>&1
}

# The app brings its own uv and its own node; both are runtime, not data.
seed_install
printf '%s\n' "#!/bin/bash" "exec $test_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\"" \
  >"$test_home/.local/bin/hermes"
remove || fail "remove succeeds"
[[ ! -d $test_home/.hermes/hermes-agent ]] || fail "the runtime checkout is removed"
[[ ! -d $test_home/.hermes/bin ]] || fail "the uv the app installed is removed"
[[ ! -d $test_home/.hermes/node ]] || fail "the node the app installed is removed"
pass "removal takes the whole runtime the app installed"

grep -Fxq 'systemctl --user stop omarchy-hermes-theme.service' "$test_tmp/systemctl-log" ||
  fail "the unit the installer left waiting to hand over the theme is stopped" "$(cat "$test_tmp/systemctl-log")"
pass "removal stops the installer's theme hand-over"

[[ -d $test_home/.config/Hermes ]] ||
  fail "gateway connections, tokens and settings survive removal"
pass "removal keeps the app's connections and settings"

# -L, not -e: a dangling symlink fails -e while very much still being there.
[[ ! -L $test_home/.local/bin/node ]] || fail "a node symlink into ~/.hermes is removed"
[[ ! -L $test_home/.local/bin/npm ]] || fail "an npm symlink into ~/.hermes is removed"
[[ -L $test_home/.local/bin/npx ]] || fail "an npx symlink pointing elsewhere survives"
pass "removal clears only the managed Node links it stranded"

[[ -f $test_home/.hermes/sessions/one.json ]] || fail "chats survive removal"
[[ -f $test_home/.hermes/memories/one.md ]] || fail "memories survive removal"
[[ -f $test_home/.hermes/SOUL.md ]] || fail "SOUL.md survives removal"
pass "removal keeps what belongs to the user"

# Without a terminal there is nobody to ask, so gum must not even be reached:
# a gum that answered "yes" on its own would be a data loss.
[[ ! -s $test_tmp/gum-log ]] ||
  fail "removal does not ask about the user's data without a terminal"
pass "removal keeps the user's data unasked when there is no terminal"

[[ ! -e $test_home/.local/bin/hermes ]] || fail "the app's own hermes command is removed"
pass "removal takes the command the app installed"

# Removal also asks the installer to tear down a mise CLI the app superseded, so
# a copy left from before the app took over does not linger once Hermes is gone.
tr '\0' '\n' <"$test_tmp/installer-log" | grep -qx -- '--remove' ||
  fail "removal asks the installer to tear down its own CLI"
pass "removal tears down the mise CLI through the installer"

# A hermes command the app did not write survives even when the app did install
# a runtime of its own.
seed_install
printf '%s\n' "#!/bin/bash" "exec /usr/local/bin/my-own-hermes \"\$@\"" \
  >"$test_home/.local/bin/hermes"
remove || fail "remove succeeds with a foreign hermes present"
[[ -f $test_home/.local/bin/hermes ]] ||
  fail "a hermes command the app did not write survives removal"
pass "removal leaves a hermes it does not own"

# Installed but never launched. The app provisions its runtime on first launch
# and marks it complete when it lands, so without that marker everything under
# ~/.hermes predates the app -- an official install, or one built by hand -- and
# the paths are identical either way. Dropping the package is the whole job.
seed_install
rm -f "$test_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
printf 'my local edit\n' >"$test_home/.hermes/hermes-agent/PATCH"
printf '%s\n' "#!/bin/bash" "exec $test_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\"" \
  >"$test_home/.local/bin/hermes"
remove || fail "remove succeeds when the app never finished installing Hermes"
# The stranded pre-desktop CLI is exactly the interrupted-install case, so the
# teardown must be asked for here too, not only when the app's runtime landed.
tr '\0' '\n' <"$test_tmp/installer-log" | grep -qx -- '--remove' ||
  fail "removal tears down the CLI even when the app never finished installing"
[[ -d $test_home/.hermes/hermes-agent ]] ||
  fail "a Hermes runtime the app never installed survives removal"
[[ -f $test_home/.hermes/hermes-agent/PATCH ]] ||
  fail "local changes to a runtime the app never installed survive removal"
[[ -d $test_home/.hermes/bin && -d $test_home/.hermes/node ]] ||
  fail "the rest of a runtime the app never installed survives removal"
[[ -f $test_home/.local/bin/hermes ]] ||
  fail "the command a runtime the app never installed put on PATH survives removal"
[[ -L $test_home/.local/bin/node ]] ||
  fail "node links belonging to a runtime the app never installed survive removal"
pass "removal leaves a Hermes the app never installed"

# ~/.hermes carries a dot, so a pattern rather than a plain string would also
# claim a wrapper pointing at a sibling directory that merely looks like it.
seed_install
mkdir -p "$test_home/xhermes/bin"
sibling_body="#!/bin/bash
exec $test_home/xhermes/bin/hermes \"\$@\""
printf '%s\n' "$sibling_body" >"$test_home/.local/bin/hermes"
remove || fail "remove succeeds with a wrapper pointing at a sibling directory"
[[ -f $test_home/.local/bin/hermes && $(cat "$test_home/.local/bin/hermes") == "$sibling_body" ]] ||
  fail "a wrapper pointing at ~/xhermes is not mistaken for one pointing into ~/.hermes"
pass "removal matches the runtime path as a plain string"

# On a terminal the user is asked, default no: declining leaves every piece of
# data where it was.
seed_install
remove_tty || fail "remove succeeds when the data question is declined"
tr '\0' '\n' <"$test_tmp/gum-log" | grep -qx 'confirm' ||
  fail "removal asks about the user's data on a terminal"
[[ -f $test_home/.hermes/sessions/one.json && -d $test_home/.config/Hermes ]] ||
  fail "declining the question keeps the user's data"
pass "removal asks on a terminal and declining keeps the data"

# An explicit yes is the one path that takes the data too.
seed_install
OMARCHY_TEST_GUM_STATUS=0 remove_tty || fail "remove succeeds when the data goes too"
[[ ! -e $test_home/.hermes && ! -e $test_home/.config/Hermes ]] ||
  fail "a yes deletes ~/.hermes and ~/.config/Hermes"
pass "removal deletes the user's data only on an explicit yes"

# Without the bootstrap marker the runtime is not the app's to take unasked,
# but the data question is still the user's to answer: declining keeps the
# whole tree -- runtime included -- untouched.
seed_install
rm -f "$test_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
remove_tty || fail "remove succeeds when the app never installed Hermes"
tr '\0' '\n' <"$test_tmp/gum-log" | grep -qx 'confirm' ||
  fail "removal still asks about the data without the bootstrap marker"
[[ -d $test_home/.hermes/hermes-agent && -d $test_home/.config/Hermes ]] ||
  fail "declining keeps a Hermes the app never installed"
pass "removal asks without the marker and declining keeps everything"

# The prompt names ~/.hermes itself, so a yes takes the whole tree there too,
# unowned runtime and all -- that is what was asked and answered.
seed_install
rm -f "$test_home/.hermes/hermes-agent/.hermes-bootstrap-complete"
OMARCHY_TEST_GUM_STATUS=0 remove_tty ||
  fail "remove succeeds when the data goes too without the marker"
[[ ! -e $test_home/.hermes && ! -e $test_home/.config/Hermes ]] ||
  fail "a yes takes ~/.hermes whole when the marker never appeared"
pass "removal honors a yes on the named paths without the marker"

# A CLI teardown that fails must not stop the runtime handling, and must not be
# papered over either: the data work still happens, and the failure reaches the
# caller's exit code.
seed_install
printf '%s\n' "#!/bin/bash" "exec $test_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\"" \
  >"$test_home/.local/bin/hermes"
OMARCHY_TEST_INSTALLER_STATUS=1 remove && fail "a failed CLI teardown surfaces in the exit code"
[[ ! -d $test_home/.hermes/hermes-agent ]] ||
  fail "a failed CLI teardown does not stop the runtime removal"
pass "a failed CLI teardown is reported after the runtime is handled"

# Real SQLite writers exercise the kernel's live/deleted file descriptors.
# Package, service and confirmation commands remain confined to the mocks.
python3 - "$test_tmp" <<'PY'
import os
from pathlib import Path
import pty
import subprocess
import sys
import time

scratch = Path(sys.argv[1])
writer_code = '''import os, sqlite3, sys
c = sqlite3.connect(os.environ['TEST_DB'])
c.execute('pragma journal_mode=wal')
c.execute('create table fixture(value)')
c.execute("insert into fixture values ('keep')")
c.commit()
print('ready', flush=True)
sys.stdin.readline()
c.close()
'''

def setup(name):
    home = scratch / name
    runtime = home / '.hermes/hermes-agent'
    runtime.mkdir(parents=True)
    (runtime / '.hermes-bootstrap-complete').touch()
    (home / '.config/Hermes').mkdir(parents=True)
    env = {**os.environ, 'HOME': str(home), 'PATH': f"{scratch / 'bin'}:/usr/bin:/bin",
           'OMARCHY_TEST_GUM_STATUS': '0'}
    for key in ('DROP', 'INSTALLER', 'SYSTEMCTL', 'GUM'):
        log = home / (key + '.log')
        log.touch()
        env['OMARCHY_TEST_' + key + '_LOG'] = str(log)
    return home, runtime, env

def writer(db):
    child = subprocess.Popen([sys.executable, '-u', '-c', writer_code],
                             env={**os.environ, 'TEST_DB': str(db)},
                             stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    assert child.stdout.readline().strip() == 'ready'
    return child

def stop(child):
    if child.poll() is None:
        child.stdin.write('\n')
        child.stdin.flush()
        child.wait(timeout=5)

def remove(env):
    master, slave = pty.openpty()
    try:
        return subprocess.run(['bash', str(scratch / 'remover')], env=env,
                              stdin=slave, capture_output=True, text=True, timeout=10)
    finally:
        os.close(master)
        os.close(slave)

def blocked(result, home, runtime, child):
    assert result.returncode != 0 and str(child.pid) in result.stderr, result
    assert 'Close Hermes' in result.stderr, result.stderr
    assert (runtime / '.hermes-bootstrap-complete').exists()
    assert all((home / (name + '.log')).stat().st_size == 0
               for name in ('DROP', 'INSTALLER', 'SYSTEMCTL', 'GUM'))
    assert child.poll() is None, 'remover must not kill sessions'

for deleted in (False, True):
    home, runtime, env = setup('deleted-writer' if deleted else 'live-writer')
    db = home / '.hermes/state.db'
    child = writer(db)
    try:
        if deleted:
            for suffix in ('', '-wal', '-shm'):
                Path(str(db) + suffix).unlink()
            db.write_bytes(b'new database generation')
        blocked(remove(env), home, runtime, child)
        if deleted:
            assert db.read_bytes() == b'new database generation'
    finally:
        stop(child)
    assert remove(env).returncode == 0, 'removal succeeds once the writer closes'
    assert not (home / '.hermes').exists()
print('ok - live and deleted SQLite holders block removal before any side effects; closing them allows retry')

for kind in ('terminal', 'desktop', 'working-directory'):
    home, runtime, env = setup(kind)
    executable_name = str(scratch / 'package/Hermes') if kind == 'desktop' else str(runtime / 'hermes')
    args = ['sleep', '30'] if kind == 'working-directory' else [executable_name, '30']
    child = subprocess.Popen(args, executable='/usr/bin/sleep',
                             cwd=runtime if kind == 'working-directory' else scratch)
    try:
        blocked(remove(env), home, runtime, child)
    finally:
        child.terminate()
        child.wait(timeout=5)
print('ok - terminal, packaged desktop and runtime working-directory processes are detected without a database')

home, runtime, env = setup('unrelated-writer')
sibling = home / '.hermes-other'
sibling.mkdir()
child = writer(sibling / 'state.db')
try:
    assert remove(env).returncode == 0, 'a sibling database does not block Hermes removal'
    assert child.poll() is None
finally:
    stop(child)
print('ok - unrelated database holders are left alone')

home, runtime, env = setup('prompt-race')
gate = home / 'prompt'
env['OMARCHY_TEST_PROMPT_GATE'] = str(gate)
master, slave = pty.openpty()
remover = subprocess.Popen(['bash', str(scratch / 'remover')], env=env, stdin=slave,
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
os.close(slave)
child = None
try:
    deadline = time.monotonic() + 5
    while not Path(str(gate) + '.started').exists():
        assert remover.poll() is None and time.monotonic() < deadline, 'prompt was not reached'
        time.sleep(0.01)
    child = writer(home / '.hermes/state.db')
    Path(str(gate) + '.continue').touch()
    stdout, stderr = remover.communicate(timeout=10)
    assert remover.returncode != 0 and str(child.pid) in stderr, (stdout, stderr)
    assert (home / '.hermes/state.db-wal').exists()
    assert (home / '.config/Hermes').exists()
finally:
    if child is not None:
        stop(child)
    if remover.poll() is None:
        remover.terminate()
        remover.wait(timeout=5)
    os.close(master)
print('ok - a writer started during confirmation blocks data deletion')
PY
