#!/bin/bash
# Security regression coverage for the Windows VM compose/mount boundary.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Bind mounts need CAP_SYS_ADMIN in a private mount namespace. Keep the
# caller's uid so the non-root development path is exercised.
if [[ ${OMARCHY_WINDOWS_TEST_NAMESPACE:-0} != 1 ]]; then
  # Auth checks do not require bind mounts.
  (
    python3 - <<'PY'
import os
import pty
import subprocess
import tempfile
from pathlib import Path

script = r'''
set -e
set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null
priv_target() { printf '/fixture/omarchy-windows-vm\n'; }
sudo() { printf sudo >"$MODE_LOG"; printf exited; }
pkexec() { printf pkexec >"$MODE_LOG"; printf exited; }
migrate_legacy_compose() { :; }
status_windows
'''
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    (root / 'docker-compose.yml').touch()
    log = root / 'mode'
    env = dict(os.environ, OMARCHY_WINDOWS_DIR=str(root), MODE_LOG=str(log), HOME=str(root))
    for name, terminal_input, terminal_error, expected in (
            ('terminal status', True, True, 'sudo'),
            ('redirected stdin', False, True, 'sudo'),
            ('graphical caller', False, False, 'pkexec')):
        master, slave = pty.openpty()
        try:
            result = subprocess.run(['/bin/bash', '-c', script], env=env,
                                    stdin=slave if terminal_input else subprocess.DEVNULL,
                                    stdout=subprocess.PIPE,
                                    stderr=slave if terminal_error else subprocess.PIPE,
                                    text=True, timeout=10)
            assert result.returncode == 0, (name, result.stdout, result.stderr)
            assert log.read_text() == expected, (name, log.read_text(), expected)
            assert 'Windows VM is stopped' in result.stdout
        finally:
            os.close(slave)
            os.close(master)
        print(f'ok - {name} uses {expected} while privileged status output is captured')
PY
  )

  # Credentials checks do not require bind mounts.
  (
    python3 - <<'PY'
import os
from pathlib import Path
import subprocess
import tempfile

prefix = r'''
set -euo pipefail
set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null
mkdir -p "$HOME/.config/windows" "$OMARCHY_WINDOWS_DIR"
CREDENTIALS_FILE="$HOME/.config/windows/credentials"
TEST_PUBLISH_PATH=$CREDENTIALS_FILE
prepare_user_mount_sources() { :; }
check_prerequisites() { :; }
omarchy-pkg-add() { :; }
available_storage_gb() { printf 128; }
timedatectl() { printf UTC; }
sleep() { :; }
xdg-open() { :; }
gum() {
  case "$1" in
    choose)
      cat >/dev/null
      if [[ $* == *RAM* ]]; then printf 4G; else printf 64G; fi
      ;;
    input)
      if [[ $* == *CPU* ]]; then printf 2
      elif [[ $* == *username* ]]; then printf testuser
      else printf testpass
      fi
      ;;
    style | confirm) : ;;
    *) return 1 ;;
  esac
}
write_compose() { printf 'compose\n' >>"$TEST_LOG"; }
priv() { printf 'priv:%s\n' "$1" >>"$TEST_LOG"; }
'''


def run_case(name, body, status=0, setup=None):
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        home = root / 'home'
        home.mkdir()
        env = dict(os.environ, HOME=str(home), OMARCHY_WINDOWS_DIR=str(root / 'runtime'),
                   TEST_ROOT=str(root), TEST_LOG=str(root / 'calls'))
        if setup:
            setup(root)
        result = subprocess.run(['/bin/bash', '-c', prefix + body], env=env,
                                capture_output=True, text=True, timeout=20)
        assert result.returncode == status, (name, result.returncode, result.stdout, result.stderr)
        print('ok - ' + name)
        return result


for fixture in ('dangling-parent', 'file-parent', 'directory-destination'):
    body = r'''
case "$FIXTURE" in
  dangling-parent)
    rmdir "$HOME/.config/windows"
    ln -s "$TEST_ROOT/missing" "$HOME/.config/windows"
    ;;
  file-parent)
    rmdir "$HOME/.config/windows"
    touch "$HOME/.config/windows"
    ;;
  directory-destination) mkdir "$CREDENTIALS_FILE" ;;
esac
if (install_windows); then exit 9; fi
[[ ! -e $TEST_LOG ]]
'''.replace('$FIXTURE', fixture)
    run_case('install rejects ' + fixture + ' before privileged configuration', body)

run_case('failed Compose staging preserves existing credentials and removes private candidates', r'''
write_credentials previous oldpass
before=$(sha256sum "$CREDENTIALS_FILE")
write_compose() {
  [[ $(read_credential PASSWORD) == oldpass ]] || exit 9
  candidates=("$HOME/.config/windows"/.credentials-install.*)
  [[ ${#candidates[@]} == 1 && -f ${candidates[0]} ]] || exit 9
  [[ $(stat -c '%a' "${candidates[0]}") == 600 ]] || exit 9
  printf 'compose\n' >>"$TEST_LOG"
  return 7
}
if (install_windows); then exit 9; fi
[[ $(sha256sum "$CREDENTIALS_FILE") == "$before" ]]
[[ $(<"$TEST_LOG") == compose ]]
[[ -z $(find "$HOME/.config/windows" -name '.credentials*' -print) ]]
''')

run_case('publication failure preserves prior credentials, cleans staging and never starts VM', r'''
write_credentials previous oldpass
before=$(sha256sum "$CREDENTIALS_FILE")
mv() {
  if [[ ${!#} == "$TEST_PUBLISH_PATH" ]]; then return 1; fi
  command mv "$@"
}
if (install_windows); then exit 9; fi
[[ $(sha256sum "$CREDENTIALS_FILE") == "$before" ]]
[[ $(<"$TEST_LOG") == compose ]]
[[ -z $(find "$HOME/.config/windows" -name '.credentials*' -print) ]]
''')

run_case('install publishes staged credentials before starting VM', r'''
priv() {
  [[ $1 == up && $(read_credential PASSWORD) == testpass ]] || exit 9
  printf 'priv:up\n' >>"$TEST_LOG"
}
install_windows
[[ $(<"$TEST_LOG") == $'compose\npriv:up' ]]
[[ $(stat -c '%a' "$CREDENTIALS_FILE") == 600 ]]
[[ -z $(find "$HOME/.config/windows" -name '.credentials*' -print) ]]
''')

run_case('linked config removal deletes actual credentials and preserves unrelated target files', r'''
mv "$HOME/.config/windows" "$TEST_ROOT/config-target"
ln -s "$TEST_ROOT/config-target" "$HOME/.config/windows"
chmod 0755 "$TEST_ROOT/config-target"
write_credentials linked secret
[[ $(stat -c '%a' "$TEST_ROOT/config-target") == 700 ]]
touch "$TEST_ROOT/config-target/keep"
# These private candidates model SIGKILL/power-loss leftovers with no EXIT trap.
for candidate in .credentials-install.ABC123 .credentials.XYZ123; do
  printf 'interrupted private credentials\n' >"$TEST_ROOT/config-target/$candidate"
  chmod 0600 "$TEST_ROOT/config-target/$candidate"
done
# Cleanup must unlink a planted candidate symlink without following its target.
printf 'external data\n' >"$TEST_ROOT/candidate-victim"
ln -s "$TEST_ROOT/candidate-victim" "$TEST_ROOT/config-target/.credentials.LINK12"
migrate_legacy_compose() { return 1; }
remove_windows
[[ -z $(find "$TEST_ROOT/config-target" -name '.credentials*' -print) ]]
[[ $(<"$TEST_ROOT/candidate-victim") == 'external data' ]]
[[ ! -e $TEST_ROOT/config-target/credentials && -f $TEST_ROOT/config-target/keep ]]
[[ ! -L $HOME/.config/windows && ! -e $HOME/.config/windows ]]
''')

run_case('credential deletion failure retains the config link and reports removal failure', r'''
mv "$HOME/.config/windows" "$TEST_ROOT/config-target"
ln -s "$TEST_ROOT/config-target" "$HOME/.config/windows"
write_credentials linked secret
migrate_legacy_compose() { return 1; }
rm() {
  if [[ " $* " == *" $CREDENTIALS_FILE "* ]]; then return 1; fi
  command rm "$@"
}
if (remove_windows); then exit 9; fi
[[ -L $HOME/.config/windows && -f $TEST_ROOT/config-target/credentials ]]
''')

run_case('real and dangling legacy Compose symlinks remain untouched without migration', r'''
printf 'legacy plaintext\n' >"$TEST_ROOT/legacy-target"
for target in "$TEST_ROOT/legacy-target" "$TEST_ROOT/missing-target"; do
  ln -s "$target" "$LEGACY_COMPOSE_FILE"
  if migrate_legacy_compose; then exit 9; fi
  [[ -L $LEGACY_COMPOSE_FILE && ! -e $TEST_LOG ]]
  [[ $(<"$TEST_ROOT/legacy-target") == 'legacy plaintext' ]]
  rm "$LEGACY_COMPOSE_FILE"
done
''')
PY
  )

  # Handover checks do not require bind mounts.
  (
    python3 - <<'PY'
import os
import subprocess
import tempfile
from pathlib import Path

with tempfile.TemporaryDirectory() as directory:
    fixture = Path(directory)
    startup = fixture / 'startup.sh'
    startup.write_text('''
pacman() {
  printf 'query\\n' >>"$QUERY_LOG"
  if [[ $1 == -Qq && ${2:-} == docker ]]; then
    case "$PROVIDER" in
      absent|broken) return 1 ;;
      *) printf '%s\\n' "$PROVIDER" ;;
    esac
  else
    [[ $PROVIDER != broken ]]
  fi
}
gum() { printf 'prompt\\n' >>"$ACTION_LOG"; return 0; }
podman() { printf 'engine\\n' >>"$ACTION_LOG"; return 1; }
podman-compose() { printf 'engine\\n' >>"$ACTION_LOG"; return 0; }
sudo() { printf 'elevation\\n' >>"$ACTION_LOG"; return 1; }
pkexec() { printf 'elevation\\n' >>"$ACTION_LOG"; return 1; }
''')
    action_log = fixture / 'actions'
    query_log = fixture / 'queries'
    home = fixture / 'home'
    disk = home / '.windows/disk.img'
    env = dict(os.environ, BASH_ENV=str(startup), HOME=str(home),
               OMARCHY_WINDOWS_DIR=str(fixture / 'runtime'),
               ACTION_LOG=str(action_log), QUERY_LOG=str(query_log))

    def invoke(provider, action):
        action_log.unlink(missing_ok=True)
        query_log.unlink(missing_ok=True)
        disk.parent.mkdir(parents=True, exist_ok=True)
        disk.write_text('retained Docker disk')
        return subprocess.run(['/bin/bash', os.environ['ROOT'] + '/bin/omarchy-windows-vm', action],
                              env=dict(env, PROVIDER=provider), capture_output=True, text=True, timeout=10)

    # Removal without a compose file still reaches user-side disk cleanup.
    # Run this first so the old implementation fails without any engine call.
    for provider in ('docker', 'docker-git', 'broken'):
        for action in ('remove', 'install', 'launch', 'start', 'stop', 'down', 'status', '__priv'):
            result = invoke(provider, action)
            assert result.returncode != 0, (provider, action, result.stdout, result.stderr)
            assert disk.read_text() == 'retained Docker disk', (provider, action)
            assert not action_log.exists(), (provider, action, action_log.read_text())
            assert ('migration is pending' if provider != 'broken' else 'Cannot verify') in result.stderr
        print(f'ok - {provider} blocks every Windows action before prompts, elevation, engines or disk cleanup')

    for provider in ('podman-docker', 'absent'):
        result = invoke(provider, 'status')
        assert result.returncode == 1 and 'Windows VM not configured' in result.stdout, (provider, result.stdout, result.stderr)
        assert disk.exists()
        result = invoke(provider, 'remove')
        assert result.returncode == 0, (provider, result.stdout, result.stderr)
        assert not disk.exists(), provider
        assert action_log.read_text() == 'prompt\n'
        print(f'ok - {provider} allows ordinary status and confirmed user-side cleanup')

    result = invoke('broken', 'help')
    assert result.returncode == 0 and 'Usage:' in result.stdout
    assert not query_log.exists() and not action_log.exists() and disk.exists()
    print('ok - help remains available without querying the engine package')
PY
  )

  # Local engine checks do not require bind mounts.
  (
    set -- help
    source "$ROOT/bin/omarchy-windows-vm" >/dev/null
    export PATH="$ROOT/bin:$PATH"

    # An empty remote engine must never authorize removal of an active local disk.
    # Stub all mount/destructive operations; no real engine or filesystem changes.
    export CONTAINER_HOST=unix:///tmp/omarchy-test-remote.sock
    USERS_DIR=/fixture/users
    CALLER_UID=1000
    CALLER_DATA_ROOT="$USERS_DIR/$CALLER_UID"
    EXPECTED_STORAGE="$USERS_DIR/$CALLER_UID/storage"
    EXPECTED_SHARED="$USERS_DIR/$CALLER_UID/shared"
    assert_mounts_safe() { :; }
    mount_layer_count() { echo 1; }
    mount_descendant_count() { echo 0; }
    mounts_ready() { :; }
    removal_trees_disjoint() { :; }
    deleted=0
    find() { [[ $* != *-delete* ]] || deleted=1; }
    umount() { :; }
    rm() { :; }
    rmdir() { :; }
    podman-compose() {
      [[ $1 == --podman-path="$ROOT/bin/omarchy-podman-local" ]] || fail "Windows Compose can use a remote engine"
      # Simulate an apparently successful down that left the local container.
      return 0
    }
    podman() {
      if [[ $1 == --remote=false ]]; then
        shift
        # Local container is still present; removal must refuse to delete its disk.
        [[ $1 != inspect ]] || return 0
      else
        # The unrelated remote is healthy but has no matching Windows container.
        [[ $1 != inspect ]] || return 1
      fi
      return 0
    }

    __priv_remove 2>/dev/null && fail "empty remote state authorized local Windows disk removal"
    (( deleted == 0 )) || fail "local Windows disk was deleted while its container remained"
    pass "Windows Compose and removal inspect the local engine despite a remote endpoint"

    # Use the real Compose frontend so this catches global options incorrectly
    # inserted after a Podman subcommand. Only the engine executable is a fixture.
    python3 - <<'PY'
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

provider = shutil.which('podman-compose')
if provider is None:
    print('ok - podman-compose unavailable; skipping real frontend argument ordering')
else:
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        engine = root / 'podman'
        engine.write_text('''#!/usr/bin/python3
import json, os, sys
with open(os.environ['ENGINE_LOG'], 'a') as log:
    log.write(json.dumps(sys.argv[1:]) + '\\n')
if sys.argv[1] != '--remote=false':
    sys.exit('global local-engine option must precede the subcommand')
if sys.argv[2] == '--version':
    print('podman version 6.1.1')
elif sys.argv[2] == 'ps':
    print('[]')
else:
    sys.exit('unexpected engine action')
''')
        engine.chmod(0o755)
        compose = root / 'compose.yml'
        compose.write_text('services:\n  windows:\n    image: docker.io/library/alpine:latest\n')
        log = root / 'engine.jsonl'
        env = dict(os.environ, HOME=str(root), ENGINE_LOG=str(log), COMPOSE_FIXTURE=str(compose),
                   PATH=f"{root}:{os.environ['ROOT']}/bin:{os.environ['PATH']}",
                   CONTAINER_HOST='unix:///nonexistent/remote.sock', CONTAINER_CONNECTION='unavailable')
        result = subprocess.run(['/bin/bash', '-c', '''
set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null
COMPOSE_FILE=$COMPOSE_FIXTURE
dc ps
'''], env=env, capture_output=True, text=True, timeout=20)
        assert result.returncode == 0, (result.stdout, result.stderr)
        calls = [json.loads(line) for line in log.read_text().splitlines()]
        assert any(call[1] == 'ps' for call in calls), calls
        assert all(call[0] == '--remote=false' for call in calls), calls
        print('ok - real Compose frontend places the local-engine option before every subcommand')
PY
  )

  # Readiness checks do not require bind mounts.
  (
    set -- help
    source "$ROOT/bin/omarchy-windows-vm" >/dev/null

    assert_mounts_safe() { :; }
    dc() { fail "running container should not be recreated"; }
    sleep() { :; }

    state=running
    rdp_checks=0
    podman() {
      [[ $1 == --remote=false ]] || fail "Windows readiness must inspect the local engine"
      shift
      case "$1:$2" in
        inspect:*Status*) printf '%s\n' "$state" ;;
        inspect:*StartedAt*)
          [[ $2 == *'json .State.StartedAt'* ]] || fail "Podman timestamp must be encoded as JSON"
          echo '"2026-09-09T12:00:00Z"' ;;
        logs:--since) echo 'Windows started successfully' ;;
        *) fail "unexpected Podman command: $*" ;;
      esac
    }
    nc() {
      [[ $* == '-z -w 1 127.0.0.1 3389' ]] || fail "readiness must probe the local RDP listener"
      ((++rdp_checks >= 3))
    }
    __priv_up_wait || fail "ready Windows VM failed to launch"
    ((rdp_checks == 3)) || fail "QEMU startup log was mistaken for Windows readiness"
    pass "launch waits for RDP after QEMU announces startup"

    state=exited
    dc() { :; }
    __priv_up_wait 2>/dev/null && fail "an exited installer was reported ready"
    pass "launch reports a stopped installer without waiting for the full deadline"

    state=running
    nc() { return 1; }
    __priv_up_wait 2>/dev/null && fail "launch succeeded without RDP"
    pass "unavailable RDP reaches a bounded failure"

    fixture=$(mktemp -d)
    trap 'rm -rf "$fixture"' EXIT
    COMPOSE_FILE="$fixture/missing-compose"
    CREDENTIALS_FILE="$fixture/config/credentials"
    migrate_legacy_compose() { :; }
    priv() { fail "missing credentials must not start the VM"; }
    launch_windows "" >"$fixture/output" 2>&1 && fail "missing credentials used a guessed Windows login"
    grep -q 'credentials are missing' "$fixture/output" || fail "missing credentials did not explain recovery"
    for username in omarchy docker custom_user; do
      write_credentials "$username" 'p=a$$w"x'
      load_rdp_credentials || fail "saved credentials were rejected"
      [[ $WIN_USER == "$username" && $WIN_PASS == 'p=a$$w"x' ]] || fail "saved Windows account changed"
    done
    rm "$CREDENTIALS_FILE"
    printf 'USERNAME: "legacy"\nPASSWORD: "from compose"\n' >"$COMPOSE_FILE"
    load_rdp_credentials || fail "readable legacy compose fallback was rejected"
    [[ $WIN_USER == "legacy" && $WIN_PASS == "from compose" ]] || fail "legacy Windows account changed"
    pass "missing credentials stop before VM launch; saved new, legacy and custom accounts are preserved"
  )

  if unshare --user --map-current-user --keep-caps --mount true 2>/dev/null; then
    exec env OMARCHY_WINDOWS_TEST_NAMESPACE=1 \
      unshare --user --map-current-user --keep-caps --mount --propagation private bash "$0"
  fi
  skip "unprivileged mount namespaces unavailable; skipping Windows VM mount runtime tests"
  exit 0
fi

TMPDIR=$(mktemp -d)
export OMARCHY_WINDOWS_DIR="$TMPDIR/win"
export HOME="$TMPDIR/home"
mkdir -p "$HOME"

# The command refuses any CPU but x86_64 before defining anything, and sourcing
# it there would exit this test with it. What is under test is the x86_64 path,
# so omarchy-hw-x86 answers as one.
STUB_BIN="$TMPDIR/bin"
mkdir -p "$STUB_BIN"
printf '#!/bin/bash\nexit 0\n' >"$STUB_BIN/omarchy-hw-x86"
chmod +x "$STUB_BIN/omarchy-hw-x86"
PATH="$STUB_BIN:$PATH"

set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null 2>&1
COMPOSE="$OMARCHY_WINDOWS_DIR/docker-compose.yml"

unmount_all() {
  local path
  resolve_caller >/dev/null 2>&1 || return 0
  for path in "$EXPECTED_SHARED" "$EXPECTED_STORAGE"; do
    while mountpoint -q -- "$path" 2>/dev/null; do umount -- "$path" || break; done
  done
}

cleanup() {
  set +e
  unmount_all
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

write() { # RAM CORES DISK USER PASS TZ
  printf 'RAM=%s\nCORES=%s\nDISK=%s\nUSERNAME=%s\nPASSWORD=%s\nTZ=%s\n' \
    "$@" | __priv_write_compose
}

# Counted by this shell itself. A command substitution would read the table
# while this shell may still hold the write end of the substitution's pipe,
# which bash closes only after the fork, and count it one time in a few.
fd_count() {
  local fds=("/proc/$$/fd"/*)
  FD_COUNT=${#fds[@]}
}

reset_case() {
  unmount_all
  rm -rf "$OMARCHY_WINDOWS_DIR" "$HOME/.windows" "$HOME/Windows"
  mkdir -p "$HOME"
}

# Fixed protected anchors consume the pinned source inodes.
prepare_user_mount_sources
write 4G 2 64G alice s3cret Europe/Copenhagen
resolve_caller
[[ -f $COMPOSE ]] || fail "writer produced a compose file"
grep -q 'image: docker.io/dockurr/windows' "$COMPOSE" || fail "image is pinned"
grep -q -- '- NET_ADMIN' "$COMPOSE" || fail "cap_add is pinned"
grep -q -- "- $EXPECTED_STORAGE:/storage" "$COMPOSE" || fail "storage uses the protected anchor"
grep -q -- "- $EXPECTED_SHARED:/shared" "$COMPOSE" || fail "shared uses the protected anchor"
grep -q 'PROTECT: "Y"' "$COMPOSE" || fail "web console is not password protected"
[[ ! -L $HOME/.windows && ! -L $HOME/Windows ]] || fail "fresh sources stay real directories"
[[ $(stat -Lc '%d:%i' "$HOME/.windows") == $(stat -Lc '%d:%i' "$EXPECTED_STORAGE") ]] || fail "storage bind did not pin source"
[[ $(stat -Lc '%d:%i' "$HOME/Windows") == $(stat -Lc '%d:%i' "$EXPECTED_SHARED") ]] || fail "shared bind did not pin source"
[[ $(stat -Lc '%a' "$EXPECTED_STORAGE") == 700 && $(stat -Lc '%a' "$EXPECTED_SHARED") == 700 ]] || fail "mount leaves are not private"
grep -q -- '- /:/' "$COMPOSE" && fail "compose contains host-root bind"
pass "writer emits fixed anchors bound to exact private source inodes"

# Dockur's Samba initialization sets setgid on the shared directory. A later
# launch must normalize the already-mounted inode without rejecting the VM.
chmod g+s "$HOME/Windows"
prepare_caller_mounts || fail "Samba setgid prevented relaunch"
[[ $(stat -Lc '%a' "$HOME/Windows") == 700 ]] || fail "shared directory special bits survived normalization"
mounts_ready || fail "normalized shared mount is not ready"
pass "relaunch clears Samba's setgid bit on the pinned shared inode"

# Input cannot widen a mount or compose field.
rm -f "$COMPOSE"
write 4G 2 64G 'x -v /:/h' p UTC 2>/dev/null && fail "malicious username accepted"
[[ ! -f $COMPOSE ]] || fail "bad input wrote compose"
printf 'RAM=4G\nCORES=2\nDISK=64G\nUSERNAME=ok\nPASSWORD=p\nTZ=UTC\nSTORAGE=/\nSHARED=/etc\n' | __priv_write_compose
grep -q -- "- $EXPECTED_STORAGE:/storage" "$COMPOSE" || fail "caller storage affected compose"
grep -q -- '- /:/storage' "$COMPOSE" && fail "host root accepted as storage"
write '4G; rm -rf /' 2 64G ok p UTC 2>/dev/null && fail "malicious RAM accepted"
pass "input cannot inject a host path or compose field"

tricky='p@$$w:rd$HOME"x\y'
write 8G 4 64G bob "$tricky" UTC
grep -q 'PASSWORD: ".*\$\$.*"' "$COMPOSE" || fail "dollar not escaped"
[[ $(unescape "$(read_compose_value PASSWORD "$COMPOSE")") == "$tricky" ]] || fail "password did not round-trip"
pass "password with quote, backslash, and dollar round-trips"

for action in write_compose up up_wait down status remove; do
  valid_priv_action "$action" || fail "known action rejected: $action"
done
for action in '/../evil/x' bogus 'up;rm' '' '__priv_up'; do
  valid_priv_action "$action" && fail "action whitelist accepted: [$action]"
done
pass "privileged action dispatch is allowlisted"

# A PATH symlink to bash must never become the pkexec target. Hide the packaged
# file from priv_target's stat checks to exercise the historical fallback.
attack_bin="$TMPDIR/attack-bin"
mkdir -p "$attack_bin"
ln -s /bin/bash "$attack_bin/omarchy-windows-vm"
printf 'printf exploited >"$TMPDIR/exploited"\n' >"$TMPDIR/__priv"
stat() {
  [[ ${!#} == /usr/bin/omarchy-windows-vm ]] && return 1
  command stat "$@"
}
PATH="$attack_bin:$PATH" priv_target >/dev/null 2>&1 && fail "PATH symlink became a privileged target"
unset -f stat
[[ ! -e $TMPDIR/exploited ]] || fail "attacker __priv script executed"
pass "pkexec target is only the canonical packaged regular file, never a PATH symlink"

# Legacy migration keeps directories and legitimate symlinks in place.
reset_case
external_shared="$TMPDIR/external-shared"
mkdir -m 0755 -p "$HOME/.windows" "$external_shared" "$HOME/.config/windows"
# dockur leaves an initially empty share setgid, which a numeric chmod keeps.
chmod 2777 "$external_shared"
ln -s "$external_shared" "$HOME/Windows"
touch "$HOME/.windows/existing-disk" "$external_shared/existing-shared-file"
LEGACY_COMPOSE_FILE="$HOME/.config/windows/docker-compose.yml"
COMPOSE_FILE="$COMPOSE"
cat >"$LEGACY_COMPOSE_FILE" <<'LEG'
services:
  windows:
    environment:
      RAM_SIZE: "16G"
      CPU_CORES: "6"
      DISK_SIZE: "128G"
      USERNAME: "legacyuser"
      PASSWORD: "legacypass"
      TZ: "America/New_York"
    volumes:
      - /./:/storage
      - /etc:/shared
LEG
priv() { local action=$1; shift; "__priv_$action" "$@"; }
migrate_legacy_compose
resolve_caller
[[ -f $COMPOSE ]] || fail "migration did not write compose"
grep -q 'USERNAME: "legacyuser"' "$COMPOSE" || fail "migration lost settings"
[[ -f $HOME/.windows/existing-disk && -f $external_shared/existing-shared-file ]] || fail "migration lost data"
[[ ! -L $HOME/.windows && $(readlink "$HOME/Windows") == "$external_shared" ]] || fail "migration consumed source path"
[[ $(stat -Lc '%a' "$HOME/.windows") == 700 && $(stat -Lc '%a' "$external_shared") == 700 ]] || fail "migration did not harden legacy directories"
grep -q -- '- /:/' "$COMPOSE" && fail "migration copied malicious storage"
grep -q -- '- /etc:/shared' "$COMPOSE" && fail "migration copied malicious share"
[[ ! -f $LEGACY_COMPOSE_FILE ]] || fail "migration left legacy compose"
pass "migration preserves data and symlinks while hardening permissions"

# Bring-up re-proves compose trust, cardinality, and mounted identities.
assert_mounts_safe || fail "verified sources rejected"
sed -i "s|$EXPECTED_SHARED:/shared|/etc:/shared|" "$COMPOSE"
assert_mounts_safe 2>/dev/null && fail "tampered host path accepted"
sed -i "s|/etc:/shared|$EXPECTED_SHARED:/shared|" "$COMPOSE"
printf '      - %s:/storage\n' "$EXPECTED_STORAGE" >>"$COMPOSE"
assert_mounts_safe 2>/dev/null && fail "duplicate destination accepted"
write 16G 6 128G legacyuser legacypass America/New_York
sed -i 's/PROTECT: "Y"/PROTECT: "N"/' "$COMPOSE"
assert_mounts_safe 2>/dev/null && fail "unprotected web console accepted"
sed -i 's/PROTECT: "N"/PROTECT: "Y"/' "$COMPOSE"
printf '      PROTECT: "N"\n' >>"$COMPOSE"
assert_mounts_safe 2>/dev/null && fail "duplicate web protection setting accepted"
sed -i '$d' "$COMPOSE"
chmod 0666 "$COMPOSE"
assert_mounts_safe 2>/dev/null && fail "writable compose accepted"
chmod 0640 "$COMPOSE"
pass "bring-up rejects tampered, duplicate, unprotected, and writable compose inputs"

# Both sources are pinned before a bind; bad symlinks stay untouched.
reset_case
mkdir -p "$HOME/.windows"
ln -s / "$HOME/Windows"
fd_count; before_fds=$FD_COUNT
prepare_user_mount_sources 2>/dev/null && fail "root symlink passed user preflight"
[[ -L $HOME/Windows && $(readlink "$HOME/Windows") == / ]] || fail "rejected symlink consumed"
printf 'RAM=4G\nCORES=2\nDISK=64G\nUSERNAME=x\nPASSWORD=p\nTZ=UTC\n' | __priv_write_compose 2>/dev/null && fail "root symlink passed privileged preflight"
resolve_caller
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 0 && $(mount_layer_count "$EXPECTED_SHARED") == 0 ]] || fail "one source mounted before other failed"
fd_count; (( FD_COUNT == before_fds )) || fail "source preflight leaked FD"
find "$CALLER_DATA_ROOT" -name 'rejected-*' -print -quit | grep -q . && fail "source was quarantined"
pass "invalid second source leaves paths and anchors untouched and leaks no FD"

# Distinct caller-owned symlink targets are supported and remain links.
reset_case
external_storage="$TMPDIR/external-storage"
external_shared2="$TMPDIR/external-shared-2"
mkdir -p "$external_storage" "$external_shared2"
ln -s "$external_storage" "$HOME/.windows"
ln -s "$external_shared2" "$HOME/Windows"
prepare_user_mount_sources
write 4G 2 64G symlinked pw UTC
resolve_caller
[[ $(readlink "$HOME/.windows") == "$external_storage" && $(readlink "$HOME/Windows") == "$external_shared2" ]] || fail "writer replaced symlinks"
[[ $(stat -Lc '%d:%i' "$EXPECTED_STORAGE") == $(stat -Lc '%d:%i' "$external_storage") ]] || fail "symlink target not pinned"
pass "legitimate caller-owned symlinks remain in place"

# Reproduce the original post-validation race at the last possible moment:
# replace the familiar shared path with / only after the final guard returns,
# inside the mocked Docker Compose invocation. Compose must still consume the
# protected anchor bound to the inode that was validated earlier.
raced_shared="$HOME/Windows.before-race"
shared_id_before_race=$(stat -Lc '%d:%i' "$external_shared2")
race_ran=0
dc() {
  [[ $1 == up && ${2:-} == -d ]] || return 1
  mv -T -- "$HOME/Windows" "$raced_shared"
  ln -s / "$HOME/Windows"
  race_ran=1
  [[ $(get_mount_source /shared) == "$EXPECTED_SHARED" ]] || return 1
  [[ $(stat -Lc '%d:%i' "$EXPECTED_SHARED") == "$shared_id_before_race" ]] || return 1
}
__priv_up || fail "post-validation home-path swap changed the Docker mount source"
(( race_ran == 1 )) || fail "post-validation race hook did not run"
[[ -L $HOME/Windows && $(readlink "$HOME/Windows") == / ]] || fail "race did not replace the familiar shared path"
rm "$HOME/Windows"
mv -T -- "$raced_shared" "$HOME/Windows"
unset -f dc
pass "a post-validation path swap cannot redirect Docker away from the pinned shared inode"

# Run the same attack as a genuinely concurrent process. A successful bring-up
# deliberately waits inside the Docker boundary until the attacker has replaced
# the familiar path with /, then verifies that the real bind anchor still names
# the caller-owned directory that was pinned before the race.
reset_case
prepare_user_mount_sources
touch "$HOME/Windows/safe-marker"
write 4G 2 64G concurrent pw UTC
resolve_caller
concurrent_shared_id=$(stat -Lc '%d:%i' "$HOME/Windows")
host_root_id=$(stat -Lc '%d:%i' /)
race_source="$HOME/Windows.race-source"
race_stop="$TMPDIR/stop-concurrent-race"
race_swaps="$TMPDIR/concurrent-race-swaps"
(
  set +e
  while [[ ! -e $race_stop ]]; do
    if [[ -d $HOME/Windows && ! -L $HOME/Windows ]] && mv -T -- "$HOME/Windows" "$race_source" 2>/dev/null; then
      ln -s / "$HOME/Windows" 2>/dev/null || true
      printf x >>"$race_swaps"
      sleep 0.002
    fi
    if [[ -L $HOME/Windows ]]; then
      rm -f -- "$HOME/Windows"
      mv -T -- "$race_source" "$HOME/Windows" 2>/dev/null || true
      sleep 0.005
    fi
  done
) >/dev/null &
racer_pid=$!
concurrent_dc_calls=0
dc() {
  local attempt
  [[ $1 == up && ${2:-} == -d ]] || return 1
  for ((attempt = 0; attempt < 20000; attempt++)); do
    if [[ -L $HOME/Windows && $(readlink "$HOME/Windows" 2>/dev/null) == / ]]; then
      break
    fi
  done
  [[ -L $HOME/Windows && $(readlink "$HOME/Windows" 2>/dev/null) == / ]] || return 1
  ((concurrent_dc_calls++))
  [[ $(get_mount_source /shared) == "$EXPECTED_SHARED" ]] || return 1
  [[ $(stat -Lc '%d:%i' "$EXPECTED_SHARED") == "$concurrent_shared_id" ]] || return 1
  [[ $(stat -Lc '%d:%i' "$EXPECTED_SHARED") != "$host_root_id" ]] || return 1
  [[ -f $EXPECTED_SHARED/safe-marker ]]
}
for ((attempt = 0; attempt < 200; attempt++)); do
  if __priv_up 2>/dev/null; then break; fi
done
touch "$race_stop"
wait "$racer_pid"
unset -f dc
if [[ -L $HOME/Windows ]]; then rm -f -- "$HOME/Windows"; fi
if [[ ! -e $HOME/Windows && -d $race_source ]]; then mv -T -- "$race_source" "$HOME/Windows"; fi
[[ -s $race_swaps ]] || fail "concurrent attacker never swapped the shared path"
((concurrent_dc_calls > 0)) || fail "concurrent race never reached Docker while the familiar path named host root"
[[ $(stat -Lc '%d:%i' "$EXPECTED_SHARED") == "$concurrent_shared_id" ]] || fail "concurrent race changed the protected shared inode"
pass "a concurrent home-path swap cannot redirect Docker away from the pinned shared inode"

# Same-inode sources fail before mounting and close both descriptors.
reset_case
same="$TMPDIR/same-source"
mkdir -p "$same"
ln -s "$same" "$HOME/.windows"
ln -s "$same" "$HOME/Windows"
fd_count; before_fds=$FD_COUNT
prepare_user_mount_sources 2>/dev/null && fail "same source passed user preflight"
printf 'RAM=4G\nCORES=2\nDISK=64G\nUSERNAME=x\nPASSWORD=p\nTZ=UTC\n' | __priv_write_compose 2>/dev/null && fail "same source passed root preflight"
resolve_caller
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 0 && $(mount_layer_count "$EXPECTED_SHARED") == 0 ]] || fail "same source left mount"
fd_count; (( FD_COUNT == before_fds )) || fail "same source leaked FDs"
pass "storage and shared must differ and failure closes FDs"

# Ancestor/descendant aliases are just as destructive as same-inode aliases:
# removal must never recurse from storage into shared (or accept the inverse).
reset_case
shared_inside="$TMPDIR/shared-inside-storage"
mkdir -p "$shared_inside/storage/shared"
ln -s "$shared_inside/storage" "$HOME/.windows"
ln -s "$shared_inside/storage/shared" "$HOME/Windows"
prepare_user_mount_sources
fd_count; before_fds=$FD_COUNT
write 4G 2 64G nested pw UTC 2>/dev/null && fail "shared-inside-storage sources were accepted"
resolve_caller
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 0 && $(mount_layer_count "$EXPECTED_SHARED") == 0 ]] || fail "shared-inside-storage failure left a mount"
fd_count; (( FD_COUNT == before_fds )) || fail "shared-inside-storage failure leaked FDs"

reset_case
storage_inside="$TMPDIR/storage-inside-shared"
mkdir -p "$storage_inside/shared/storage"
ln -s "$storage_inside/shared/storage" "$HOME/.windows"
ln -s "$storage_inside/shared" "$HOME/Windows"
prepare_user_mount_sources
fd_count; before_fds=$FD_COUNT
write 4G 2 64G nested pw UTC 2>/dev/null && fail "storage-inside-shared sources were accepted"
resolve_caller
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 0 && $(mount_layer_count "$EXPECTED_SHARED") == 0 ]] || fail "storage-inside-shared failure left a mount"
fd_count; (( FD_COUNT == before_fds )) || fail "storage-inside-shared failure leaked FDs"
pass "pinned-FD ancestry checks reject overlap in both directions before mounting"

# Exact bind-alias bypass regression: the shared FD's visible parent is the
# alias directory, but its inode is still reachable below storage.
reset_case
alias_under="$TMPDIR/bind-alias-under"
alias_shared="$TMPDIR/bind-alias-shared"
mkdir -p "$alias_under/storage/shared" "$alias_shared"
mount --no-canonicalize --bind "$alias_under/storage/shared" "$alias_shared"
ln -s "$alias_under/storage" "$HOME/.windows"
ln -s "$alias_shared" "$HOME/Windows"
prepare_user_mount_sources
fd_count; before_fds=$FD_COUNT
resolve_caller
open_mount_source "$LEGACY_STORAGE" storage
alias_storage_fd=$OPENED_MOUNT_FD
alias_storage_id=$OPENED_MOUNT_ID
open_mount_source "$LEGACY_SHARED" shared
alias_shared_fd=$OPENED_MOUNT_FD
pinned_dir_contains "$alias_storage_id" "$alias_shared_fd" && fail "bind-alias repro unexpectedly shared the underlying parent walk"
pinned_tree_contains "$alias_storage_fd" "$alias_shared_fd" || fail "tree-rooted discovery missed the bind-alias inode"
exec {alias_storage_fd}<&-
exec {alias_shared_fd}<&-
write 4G 2 64G alias pw UTC
resolve_caller
touch "$HOME/.windows/disk.img" "$HOME/Windows/keep.txt"
dc() { :; }
podman() { [[ $1 == --remote=false ]] || fail "Windows must use local Podman"; shift; [[ $1 == inspect ]] && return 1; :; }
__priv_remove 2>/dev/null && fail "removal accepted a shared bind alias into storage"
[[ -f $HOME/.windows/disk.img && -f $HOME/Windows/keep.txt && -f $COMPOSE ]] || fail "bind-alias removal refusal changed state"
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 1 && $(mount_layer_count "$EXPECTED_SHARED") == 1 ]] || fail "bind-alias removal refusal changed mounts"
fd_count; (( FD_COUNT == before_fds )) || fail "bind-alias removal refusal leaked FDs"
unmount_all
umount -- "$alias_shared"
pass "cheap startup permits a bind alias, but bounded removal discovery refuses it"

# A late writer failure rolls back both newly-created binds.
reset_case
prepare_user_mount_sources
mv() { return 1; }
write 4G 2 64G rollback pw UTC 2>/dev/null && fail "forced writer failure succeeded"
unset -f mv
resolve_caller
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 0 && $(mount_layer_count "$EXPECTED_SHARED") == 0 ]] || fail "writer failure left binds"
[[ ! -f $COMPOSE ]] || fail "writer failure replaced compose"
pass "atomic writer failure rolls back both new bind mounts"

# Revalidate ancestry during removal: move the already-bound shared inode below
# storage, keep its familiar path as a symlink, and prove nothing is deleted.
reset_case
prepare_user_mount_sources
write 4G 2 64G moved pw UTC
touch "$HOME/.windows/disk.img" "$HOME/Windows/keep.txt"
mv "$HOME/Windows" "$HOME/.windows/moved-shared"
ln -s "$HOME/.windows/moved-shared" "$HOME/Windows"
dc() { :; }
podman() { [[ $1 == --remote=false ]] || fail "Windows must use local Podman"; shift; [[ $1 == inspect ]] && return 1; :; }
__priv_remove 2>/dev/null && fail "removal accepted a shared inode moved below storage"
[[ -f $HOME/.windows/disk.img && -f $HOME/.windows/moved-shared/keep.txt && -f $COMPOSE ]] || fail "overlap rejection changed disk, shared data, or compose"
pass "removal revalidates pinned ancestry and leaves moved shared data untouched"

# Even when both familiar paths remain disjoint, a same-filesystem bind of the
# pinned shared inode introduced below storage must stop removal before change.
reset_case
prepare_user_mount_sources
write 4G 2 64G removal-alias pw UTC
touch "$HOME/.windows/disk.img" "$HOME/Windows/keep.txt"
mkdir "$HOME/.windows/shared-bind-alias"
mount --no-canonicalize --bind "$HOME/Windows" "$HOME/.windows/shared-bind-alias"
__priv_remove 2>/dev/null && fail "removal missed a shared bind alias introduced below storage"
[[ -f $HOME/.windows/disk.img && -f $HOME/Windows/keep.txt && -f $COMPOSE ]] || fail "removal bind-alias rejection changed state"
umount -- "$HOME/.windows/shared-bind-alias"
pass "removal tree discovery catches a shared alias not used by either home path"

# A direct alias on another filesystem is still visited by find -xdev at its
# mountpoint and must be rejected, while unrelated separate filesystems remain
# supported by the root suite.
reset_case
prepare_user_mount_sources
mount -t tmpfs -o uid="$(id -u)",gid="$(id -g)",mode=0700,size=8m crossdev-shared "$HOME/Windows"
touch "$HOME/Windows/keep.txt"
write 4G 2 64G crossdev-alias pw UTC
touch "$HOME/.windows/disk.img"
mkdir "$HOME/.windows/crossdev-shared-alias"
mount --no-canonicalize --bind "$HOME/Windows" "$HOME/.windows/crossdev-shared-alias"
__priv_remove 2>/dev/null && fail "removal missed a different-device shared alias below storage"
[[ -f $HOME/.windows/disk.img && -f $HOME/Windows/keep.txt && -f $COMPOSE ]] || fail "cross-device alias rejection changed state"
umount -- "$HOME/.windows/crossdev-shared-alias"
unmount_all
umount -- "$HOME/Windows"
pass "removal catches a direct different-filesystem shared alias at the xdev boundary"

# Recursive alias discovery is destructive-removal-only and bounded. A hung or
# failing scanner must fail closed before the disk, share, compose, or mounts
# are changed.
reset_case
prepare_user_mount_sources
write 4G 2 64G scan-failure pw UTC
touch "$HOME/.windows/disk.img" "$HOME/Windows/keep.txt"
scan_helper="$TMPDIR/tree-scan-helper"
saved_tree_scan_find=$TREE_SCAN_FIND
saved_tree_scan_timeout=$TREE_SCAN_TIMEOUT_SECONDS
saved_tree_scan_kill_after=$TREE_SCAN_KILL_AFTER_SECONDS
printf '#!/bin/bash\n/bin/sleep 10\n' >"$scan_helper"
chmod 0700 "$scan_helper"
TREE_SCAN_FIND=$scan_helper
TREE_SCAN_TIMEOUT_SECONDS=0.05
TREE_SCAN_KILL_AFTER_SECONDS=0.05
__priv_remove 2>/dev/null && fail "removal continued after its containment scan timed out"
[[ -f $HOME/.windows/disk.img && -f $HOME/Windows/keep.txt && -f $COMPOSE ]] || fail "timed-out containment scan changed state"
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 1 && $(mount_layer_count "$EXPECTED_SHARED") == 1 ]] || fail "timed-out containment scan changed mounts"

printf '#!/bin/bash\nexit 42\n' >"$scan_helper"
__priv_remove 2>/dev/null && fail "removal continued after its containment scanner failed"
[[ -f $HOME/.windows/disk.img && -f $HOME/Windows/keep.txt && -f $COMPOSE ]] || fail "failed containment scan changed state"
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 1 && $(mount_layer_count "$EXPECTED_SHARED") == 1 ]] || fail "failed containment scan changed mounts"
TREE_SCAN_FIND=$saved_tree_scan_find
TREE_SCAN_TIMEOUT_SECONDS=$saved_tree_scan_timeout
TREE_SCAN_KILL_AFTER_SECONDS=$saved_tree_scan_kill_after
pass "removal scan timeout and errors fail closed without changing VM state"

# Removal rejects stacks, then deletes disk only through verified binds.
reset_case
prepare_user_mount_sources
write 4G 2 64G remove pw UTC
resolve_caller
touch "$HOME/.windows/disk.img" "$HOME/Windows/keep.txt"
mount --no-canonicalize --bind "$HOME/.windows" "$EXPECTED_STORAGE"
dc() { :; }
podman() { [[ $1 == --remote=false ]] || fail "Windows must use local Podman"; shift; [[ $1 == inspect ]] && return 1; :; }
__priv_remove 2>/dev/null && fail "removal accepted stacked storage mount"
[[ -f $HOME/.windows/disk.img && -f $HOME/Windows/keep.txt && -f $COMPOSE ]] || fail "rejected removal changed state"
umount -- "$EXPECTED_STORAGE"
dc() { return 1; }
__priv_remove 2>/dev/null && fail "removal deleted data after podman-compose down failed"
[[ -f $HOME/.windows/disk.img && -f $HOME/Windows/keep.txt && -f $COMPOSE ]] || fail "failed down changed data or compose"
dc() { :; }
__priv_remove
[[ ! -e $HOME/.windows/disk.img ]] || fail "removal preserved disk data"
[[ -e $HOME/Windows/keep.txt ]] || fail "removal deleted shared data"
[[ ! -f $COMPOSE ]] || fail "removal left compose"
resolve_caller
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 0 && $(mount_layer_count "$EXPECTED_SHARED") == 0 ]] || fail "removal left binds"
pass "removal rejects stacks, deletes disk, and preserves shared files"

# Credentials replace a planted link rather than following it, and a failed
# atomic rename preserves the last complete private file.
credentials_dir="$TMPDIR/credentials"
CREDENTIALS_FILE="$credentials_dir/credentials"
credentials_victim="$TMPDIR/credentials-victim"
mkdir -m 0755 -p "$credentials_dir"
printf 'victim\n' >"$credentials_victim"
ln -s "$credentials_victim" "$CREDENTIALS_FILE"
write_credentials carol 'p=a$$w"x'
[[ -f $CREDENTIALS_FILE && ! -L $CREDENTIALS_FILE ]] || fail "credentials did not replace a planted symlink"
[[ $(stat -c '%a' "$credentials_dir") == 700 && $(stat -c '%a' "$CREDENTIALS_FILE") == 600 ]] || fail "credentials path is not private"
[[ $(cat "$credentials_victim") == victim ]] || fail "credentials write changed a symlink victim"
[[ $(read_credential USERNAME) == carol && $(read_credential PASSWORD) == 'p=a$$w"x' ]] || fail "credentials did not round-trip"
credentials_before=$(cat "$CREDENTIALS_FILE")
mv() { return 1; }
write_credentials changed replacement 2>/dev/null && fail "forced credentials rename failure succeeded"
unset -f mv
[[ $(cat "$CREDENTIALS_FILE") == "$credentials_before" ]] || fail "failed credentials rename replaced the live file"
! find "$credentials_dir" -name '.credentials.*' -print -quit | grep -q . || fail "failed credentials write left a temporary file"
pass "credentials are atomically replaced as a private regular file"

# Free-space accounting follows the real storage target.
reset_case
mkdir -p "$external_storage" "$HOME/Windows"
ln -s "$external_storage" "$HOME/.windows"
prepare_user_mount_sources
df_log="$TMPDIR/df-path"
df() {
  printf '%s\n' "${!#}" >"$df_log"
  printf 'Filesystem 1024-blocks Used Available Capacity Mounted on\nmock 104857600 0 94371840 0%% /mock\n'
}
[[ $(available_storage_gb) == 90 ]] || fail "free-space parsed wrong value"
unset -f df
[[ $(cat "$df_log") == "$external_storage" ]] || fail "free-space used home filesystem"
pass "disk-space checks follow the storage symlink target"
