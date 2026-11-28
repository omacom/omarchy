#!/bin/bash
# Exercise the real EUID-0/PKEXEC_UID boundary in an isolated user+mount namespace.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Run user-side regressions before checking namespace availability. Their
# stubs and traps stay in a subshell and do not leak into the root boundary probe.
if [[ ${1:-} != "--namespace-only" ]]; then
  if ((EUID == 0)); then
    skip "user-side VM fixtures require an unprivileged test invocation"
  else
(
  windows_vm_command="$ROOT/bin/omarchy-windows-vm"

  # These source the helper's pure logic, not an x86 VM or the host user manager.
  # Export the stubs for the scheduling fixtures' child bash processes as well.
  omarchy-hw-x86() { return 0; }
  systemctl() { return 0; }
  export -f omarchy-hw-x86 systemctl

  # User-side source hardening must clear leftover directory setgid. GNU chmod
  # 0700 does not, so a pre-existing ~/Windows mode 2700/2777 used to survive
  # prepare_user_mount_sources and then fail the privileged exact-700 check.
  (
    test_home=$(mktemp -d)
    trap 'rm -rf "$test_home"' EXIT
    mkdir -p "$test_home/.windows" "$test_home/Windows" "$test_home/.config/windows"
    chmod 2700 "$test_home/.windows"
    chmod 2777 "$test_home/Windows"
    chmod 2755 "$test_home/.config/windows"
    HOME=$test_home
    set -- help
    source "$windows_vm_command" >/dev/null
    prepare_user_mount_sources || fail "user mount source hardening failed on setgid directories"
    [[ $(stat -Lc '%a' "$HOME/.windows") == 700 ]] || fail "storage mode is $(stat -Lc '%a' "$HOME/.windows"), expected 700"
    [[ $(stat -Lc '%a' "$HOME/Windows") == 700 ]] || fail "shared mode is $(stat -Lc '%a' "$HOME/Windows"), expected 700"
    write_credentials alice secret || fail "write_credentials failed on a setgid config dir"
    [[ $(stat -Lc '%a' "$HOME/.config/windows") == 700 ]] || fail "credentials dir mode is $(stat -Lc '%a' "$HOME/.config/windows"), expected 700"
    chmod 2777 "$HOME/Windows"
    EXPECTED_SHARED=$HOME/Windows LEGACY_SHARED=$HOME/Windows restore_shared_privacy
    [[ $(stat -Lc '%a' "$HOME/Windows") == 700 ]] || fail "restore_shared_privacy left mode $(stat -Lc '%a' "$HOME/Windows")"
    mkdir -p "$HOME/missing-parent"
    EXPECTED_SHARED=$HOME/missing-parent/nope LEGACY_SHARED="" restore_shared_privacy || fail "restore_shared_privacy failed on a missing path"
    # The home pathname is caller-controlled, so root must never chmod it directly.
    mkdir -p "$HOME/legacy-only"
    chmod 2777 "$HOME/legacy-only"
    EXPECTED_SHARED="" LEGACY_SHARED=$HOME/legacy-only restore_shared_privacy
    [[ $(stat -Lc '%a' "$HOME/legacy-only") == 2777 ]] ||
      fail "restore_shared_privacy chmodded the caller-controlled home pathname"
    mkdir -p "$test_home/runtime/mounts/users/1000/shared" "$test_home/runtime/mounts/users/1001/shared"
    chmod 2777 "$test_home/runtime/mounts/users/1000/shared" "$test_home/runtime/mounts/users/1001/shared"
    chmod 2777 "$HOME/Windows"
    # The mounts tree is root-owned and not listable unprivileged, so the walk is
    # root-only: here it must do nothing at all, not look like a restore.
    RUNTIME_DIR=$test_home/runtime restore_all_shared_privacy
    [[ $(stat -Lc '%a' "$test_home/runtime/mounts/users/1000/shared") == 2777 ]] ||
      fail "unprivileged restore_all_shared_privacy touched uid 1000 share: $(stat -Lc '%a' "$test_home/runtime/mounts/users/1000/shared")"
    [[ $(stat -Lc '%a' "$test_home/runtime/mounts/users/1001/shared") == 2777 ]] ||
      fail "unprivileged restore_all_shared_privacy touched uid 1001 share: $(stat -Lc '%a' "$test_home/runtime/mounts/users/1001/shared")"
    # A sudoless-Docker stop instead restores the caller's own anchor owner-side,
    # and never another user's.
    EXPECTED_SHARED=$test_home/runtime/mounts/users/1000/shared restore_shared_privacy
    [[ $(stat -Lc '%a' "$test_home/runtime/mounts/users/1000/shared") == 700 ]] ||
      fail "owner-side restore left uid 1000 share at $(stat -Lc '%a' "$test_home/runtime/mounts/users/1000/shared")"
    [[ $(stat -Lc '%a' "$test_home/runtime/mounts/users/1001/shared") == 2777 ]] ||
      fail "owner-side restore touched uid 1001 share: $(stat -Lc '%a' "$test_home/runtime/mounts/users/1001/shared")"
    [[ $(stat -Lc '%a' "$HOME/Windows") == 2777 ]] ||
      fail "restore_all_shared_privacy chmodded the caller home share"
  )
  pass "user mount sources with leftover setgid harden to exactly 700"

  # install runs in a floating terminal that closes as soon as it returns, while
  # dockur is still ten minutes from the chmod 2777 the watcher exists to undo.
  # Production leaves that wait in a user unit so dismissing the uwsm-app scope
  # cannot SIGTERM it. script(1) plus a systemd-run stub that still dies with the
  # pty proves the fallback also outlives the terminal.
  (
    test_home=$(mktemp -d)
    trap 'rm -rf "$test_home"' EXIT
    mkdir -p "$test_home/Windows" "$test_home/bin"
    chmod 700 "$test_home/Windows"
    cat >"$test_home/bin/systemd-run" <<'EOF'
#!/bin/bash
printf 'systemd-run' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
exit 1
EOF
    chmod +x "$test_home/bin/systemd-run"
    cat >"$test_home/install.sh" <<EOF
export HOME=$test_home
export PATH=$test_home/bin:\$PATH
export TEST_LOG=$test_home/systemd-run.log
: >"\$TEST_LOG"
set -- help
source "$windows_vm_command" >/dev/null
schedule_share_privacy_restore
EOF
    script -q -c "bash $test_home/install.sh" /dev/null >/dev/null 2>&1
    grep -q '^systemd-run' "$test_home/systemd-run.log" ||
      fail "the install share watcher did not try to leave the terminal scope"
    chmod 2777 "$test_home/Windows"
    for _ in {1..40}; do
      [[ $(stat -Lc '%a' "$test_home/Windows") == 700 ]] && break
      sleep 0.25
    done
    [[ $(stat -Lc '%a' "$test_home/Windows") == 700 ]] ||
      fail "the install share watcher left the share at $(stat -Lc '%a' "$test_home/Windows")"
  )
  pass "the install share watcher outlives the terminal install ran in"

  # The user unit used to source "help" instead of the helper (`set -- help`
  # clobbered the service arguments), so the watcher silently never started
  # while the successful unit launch skipped the fallback entirely. A stub that
  # runs the service command the way a successful start would must leave a 2777
  # share at 700 — the broken wiring leaves it exposed.
  (
    test_home=$(mktemp -d)
    trap 'rm -rf "$test_home"' EXIT
    mkdir -p "$test_home/Windows" "$test_home/bin"
    chmod 2777 "$test_home/Windows"
    cat >"$test_home/bin/systemd-run" <<'EOF'
#!/bin/bash
printf 'systemd-run' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
# Simulate a successful transient unit start by running the service command.
while [[ $# -gt 0 && $1 != /bin/bash ]]; do shift; done
[[ $1 == /bin/bash ]] || exit 1
exec "$@"
EOF
    chmod +x "$test_home/bin/systemd-run"
    cat >"$test_home/schedule.sh" <<EOF
export HOME=$test_home
export PATH=$test_home/bin:\$PATH
export TEST_LOG=$test_home/systemd-run.log
: >"\$TEST_LOG"
set -- help
source "$windows_vm_command" >/dev/null
schedule_share_privacy_restore
EOF
    bash "$test_home/schedule.sh" || fail "the systemd share watcher failed to start"
    grep -q 'omarchy-windows-share-privacy' "$test_home/systemd-run.log" ||
      fail "the share watcher did not start as a user unit"
    [[ $(stat -Lc '%a' "$test_home/Windows") == 700 ]] ||
      fail "the systemd share watcher left the share at $(stat -Lc '%a' "$test_home/Windows")"
  )
  pass "the systemd share watcher starts and hardens the share"

  # A launch that fails (up_wait timeout, slow guest) leaves the container
  # coming up in the background: the one-shot priv-side restore cannot cover a
  # samba flip that lands after the failure, so the failure path must arm the
  # owner-side watcher before reporting.
  (
    test_home=$(mktemp -d)
    trap 'rm -rf "$test_home"' EXIT
    mkdir -p "$test_home/runtime" "$test_home/Windows"
    touch "$test_home/runtime/docker-compose.yml"
    chmod 700 "$test_home/Windows"
    HOME=$test_home
    OMARCHY_WINDOWS_DIR=$test_home/runtime
    export HOME OMARCHY_WINDOWS_DIR
    set -- help
    source "$windows_vm_command" >/dev/null
    read_credential() { return 1; }
    priv() { return 1; }
    omarchy-notification-send() { return 0; }
    schedule_share_privacy_restore() { : >"$test_home/scheduled"; }
    if ( launch_windows "" ); then
      fail "launch_windows succeeded with a failing up_wait"
    fi
    [[ -e $test_home/scheduled ]] || fail "a failed launch did not arm the share watcher"
  )
  pass "a failed launch arms the share privacy watcher"

  # The watcher must outlive a slow download: a flip that lands after minutes
  # of private share still gets fixed while the container runs.
  (
    test_home=$(mktemp -d)
    trap 'rm -rf "$test_home"' EXIT
    mkdir -p "$test_home/Windows"
    chmod 700 "$test_home/Windows"
    HOME=$test_home
    export HOME
    set -- help
    source "$windows_vm_command" >/dev/null
    docker() { echo "running"; return 0; }
    ( sleep 2; chmod 2777 "$test_home/Windows" ) &
    flipper=$!
    watch_share_privacy "$test_home/Windows" & watcher=$!
    # Bounded wait: the fix lands seconds after the flip; a broken watcher
    # would sit on the loop until its hour budget instead.
    for _ in {1..40}; do
      kill -0 $watcher 2>/dev/null || break
      sleep 0.5
    done
    if kill -0 $watcher 2>/dev/null; then
      kill "$watcher" 2>/dev/null || true
      wait "$watcher" 2>/dev/null || true
      fail "the watcher did not fix a flip that landed while watching"
    fi
    wait "$watcher" 2>/dev/null || true
    wait "$flipper" 2>/dev/null || true
    [[ $(stat -Lc '%a' "$test_home/Windows") == 700 ]] ||
      fail "a late flip left the share at $(stat -Lc '%a' "$test_home/Windows")"
  )
  pass "the share watcher fixes a flip that lands while watching"

  # …but it must not watch forever: once the container is gone nothing can flip
  # the share again, so the wait ends instead of sitting out its whole budget.
  # (Only a successful inspect reporting a live container keeps it alive.)
  (
    test_home=$(mktemp -d)
    trap 'rm -rf "$test_home"' EXIT
    mkdir -p "$test_home/Windows"
    chmod 700 "$test_home/Windows"
    HOME=$test_home
    export HOME
    set -- help
    source "$windows_vm_command" >/dev/null
    cat >"$test_home/watch.sh" <<EOF
export HOME=$test_home
set -- help
source "$windows_vm_command" >/dev/null
sleep() { :; }
docker() { echo "Error: No such object: omarchy-windows" >&2; return 1; }
watch_share_privacy "\$HOME/Windows"
EOF
    timeout 120 bash "$test_home/watch.sh" ||
      fail "the watcher outlived a gone container"
    [[ $(stat -Lc '%a' "$test_home/Windows") == 700 ]] ||
      fail "the watcher exit left the share at $(stat -Lc '%a' "$test_home/Windows")"
    docker() { echo "Error: No such object: omarchy-windows" >&2; return 1; }
    container_gone || fail "a missing container does not read as gone"
    # A default install cannot inspect the root-owned daemon at all: that
    # permission failure must keep watching, not read as gone while samba can
    # still flip the share later.
    docker() { echo "permission denied while trying to connect to the Docker daemon socket" >&2; return 1; }
    if container_gone; then
      fail "an uninspectable daemon reads as a gone container"
    fi
    docker() { echo "running"; return 0; }
    if container_gone; then
      fail "a running container reads as gone"
    fi
    docker() { echo "restarting"; return 0; }
    if container_gone; then
      fail "a restarting container reads as gone"
    fi
    # A paused entrypoint resumes: samba can still flip the share afterwards,
    # so paused keeps the watcher alive rather than ending it.
    docker() { echo "paused"; return 0; }
    if container_gone; then
      fail "a paused container reads as gone"
    fi
    docker() { echo "exited"; return 0; }
    container_gone || fail "a stopped container does not read as gone"
    # A successful inspect that also warns on stderr must not poison the
    # status match: diagnostics travel separately from the reported state.
    docker() { echo "WARNING: API deprecation notice" >&2; echo "running"; return 0; }
    if container_gone; then
      fail "a warning on stderr reads a live container as gone"
    fi
  )
  pass "the share watcher leaves once the container is gone"

  # pkexec runs the packaged copy, which a dev link cannot shadow. A stale
  # packaged copy used to re-apply the pre-fix chmod semantics with no diagnostic,
  # failing a launch and leaving the share at 2700. The skew check must refuse
  # before pkexec and say why, and must accept an identical copy.
  (
    test_home=$(mktemp -d)
    trap 'rm -rf "$test_home"' EXIT
    set -- help
    source "$windows_vm_command" >/dev/null
    cp "$windows_vm_command" "$test_home/copy"
    privileged_copy_matches "$test_home/copy" || fail "the skew check rejected an identical packaged copy"
    printf drift >>"$test_home/copy"
    privileged_copy_matches "$test_home/copy" && fail "the skew check accepted a drifted packaged copy"
    docker_needs_sudo() { return 0; }
    printf '#!/bin/bash\n' >"$test_home/packaged"
    chmod 755 "$test_home/packaged"
    priv_target() { printf '%s\n' "$test_home/packaged"; }
    pkexec() { : >"$test_home/elevated"; }
    privileged_copy_matches() { return 1; }
    priv status >/dev/null 2>&1 && fail "priv elevated despite a mismatched privileged copy"
    [[ ! -e $test_home/elevated ]] || fail "priv reached pkexec with a mismatched privileged copy"
    privileged_copy_matches() { return 0; }
    priv status >/dev/null 2>&1 || fail "priv refused a matching privileged copy"
    [[ -e $test_home/elevated ]] || fail "priv did not reach pkexec with a matching privileged copy"
  )
  pass "elevation refuses a mismatched privileged copy and accepts an identical one"
)
  fi
fi

if ((EUID != 0)); then
  if unshare --user --map-auto --map-root-user --mount true 2>/dev/null; then
    exec unshare --user --map-auto --map-root-user --mount --propagation private bash "$0" --namespace-only
  fi
  skip "automatic subordinate-id namespace unavailable; skipping root Windows VM boundary probe"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# The checkout may live under /home, which the tmpfs below hides, so take a
# mount-safe copy of the helper before the mounts land.
cp "$ROOT/bin/omarchy-windows-vm" "$test_tmp/omarchy-windows-vm"

# A host VM leaves its anchors mounted at exactly the production anchor paths
# this test re-creates for its fixture uid. The tmpfs below hides them from the
# filesystem, but the user-ns copy of the mount table keeps them listed in
# /proc/self/mountinfo — and they are MNT_LOCKED, so they cannot be detached —
# while mountpoint(1) matches entries by path: the fresh anchors then look like
# existing mounts and prepare_mount_anchor short-circuits without creating
# them. Pick fixture uids whose anchor paths cannot collide with whatever the
# host VM left behind.
TEST_UID=4242
TEST_UID_OTHER=$((TEST_UID + 1))
while grep -qE "mounts/users/(${TEST_UID}|${TEST_UID_OTHER})/(storage|shared) " /proc/self/mountinfo; do
  TEST_UID=$((TEST_UID + 2))
  TEST_UID_OTHER=$((TEST_UID + 1))
done
export TEST_UID TEST_UID_OTHER

# Hide host state before creating the production paths used by the root helper.
mount -t tmpfs -o mode=0755,size=8m run-test /run
mkdir -p /run/lock
mount -t tmpfs -o mode=0755,size=16m var-test /var
mkdir -p /var/lib/omarchy
mount -t tmpfs -o mode=0755,size=16m home-parent /home
mkdir /home/alice
mount -t tmpfs -o uid=0,gid=0,mode=0710,size=1g home-alice /home/alice

export HOME=/home/alice
unset OMARCHY_WINDOWS_DIR
# The command refuses any CPU but x86_64 before defining anything, and sourcing
# it there would exit this test with it. What is under test is the x86_64 path,
# so omarchy-hw-x86 answers as one.
mkdir -p "$test_tmp/bin"
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/omarchy-hw-x86"
chmod +x "$test_tmp/bin/omarchy-hw-x86"
PATH="$test_tmp/bin:$PATH"
set -- help
source "$test_tmp/omarchy-windows-vm" >/dev/null 2>&1

# The namespace maps the host filesystem's uid 0 to nobody. Only / remains on
# that filesystem; all paths the helper mutates are isolated tmpfs mounts.
stat() {
  if [[ ${!#} == / && $* == *"%u"* ]]; then printf '0\n'; return; fi
  command stat "$@"
}

TEST_PASSWD_HOME=/home/alice
getent() {
  if [[ $1 == passwd && ${2:-} == ${TEST_UID} ]]; then
    printf "alice:x:${TEST_UID}:${TEST_UID}::%s:/bin/bash\n" "$TEST_PASSWD_HOME"
    return 0
  fi
  return 2
}

assert_no_runtime_mutation() {
  [[ ! -e /var/lib/omarchy/windows && ! -L /var/lib/omarchy/windows ]] ||
    fail "$1 mutated the production runtime"
}

unset PKEXEC_UID
resolve_caller 2>/dev/null && fail "root accepted missing PKEXEC_UID"
assert_no_runtime_mutation "missing PKEXEC_UID"
PKEXEC_UID=0
resolve_caller 2>/dev/null && fail "root accepted PKEXEC_UID=0"
assert_no_runtime_mutation "zero PKEXEC_UID"
PKEXEC_UID=not-a-number
resolve_caller 2>/dev/null && fail "root accepted nonnumeric PKEXEC_UID"
assert_no_runtime_mutation "nonnumeric PKEXEC_UID"
PKEXEC_UID=${TEST_UID_OTHER}
resolve_caller 2>/dev/null && fail "root accepted uid absent from passwd"
assert_no_runtime_mutation "missing passwd entry"

PKEXEC_UID=${TEST_UID}
resolve_caller 2>/dev/null && fail "root accepted a home not owned by caller"
assert_no_runtime_mutation "wrong-owned home"
chown ${TEST_UID}:${TEST_UID} /home/alice

chmod 0777 /home
resolve_caller 2>/dev/null && fail "root accepted writable home parent"
assert_no_runtime_mutation "writable parent"
chmod 0755 /home

mkdir /home/real-alice
chown ${TEST_UID}:${TEST_UID} /home/real-alice
ln -s /home/real-alice /home/link-alice
TEST_PASSWD_HOME=/home/link-alice
resolve_caller 2>/dev/null && fail "root accepted symlinked passwd home"
assert_no_runtime_mutation "symlinked home"
TEST_PASSWD_HOME=/home/alice
resolve_caller || fail "valid root PKEXEC_UID/home boundary was rejected"
pass "root dispatch rejects missing/invalid uid, passwd, owner, symlink, and writable-parent boundaries without mutation"

# Put each familiar source on its own filesystem. Both start with legacy 0755
# permissions and world-readable payloads to prove migration hardens the leaves.
mkdir /home/storage-target /home/shared-target
mount -t tmpfs -o uid=${TEST_UID},gid=${TEST_UID},mode=0755,size=3g storage-test /home/storage-target
mount -t tmpfs -o uid=${TEST_UID},gid=${TEST_UID},mode=0755,size=64m shared-test /home/shared-target
ln -s /home/storage-target /home/alice/.windows
ln -s /home/shared-target /home/alice/Windows
chown -h ${TEST_UID}:${TEST_UID} /home/alice/.windows /home/alice/Windows
printf disk >/home/storage-target/disk.img
printf shared >/home/shared-target/shared.txt
chown ${TEST_UID}:${TEST_UID} /home/storage-target/disk.img /home/shared-target/shared.txt
chmod 0644 /home/storage-target/disk.img /home/shared-target/shared.txt

home_dev=$(command stat -Lc '%d' /home/alice)
storage_dev=$(command stat -Lc '%d' /home/storage-target)
[[ $home_dev != "$storage_dev" ]] || fail "storage target did not land on a separate filesystem"

with_vm_lock prepare_caller_mounts || fail "root could not create verified production bind anchors"
resolve_caller
[[ $(readlink /home/alice/.windows) == /home/storage-target &&
  $(readlink /home/alice/Windows) == /home/shared-target ]] || fail "root consumed legitimate symlinks"
[[ $(command stat -Lc '%d:%i' "$EXPECTED_STORAGE") == $(command stat -Lc '%d:%i' /home/storage-target) ]] || fail "storage bind identity differs from pinned source"
[[ $(command stat -Lc '%d:%i' "$EXPECTED_SHARED") == $(command stat -Lc '%d:%i' /home/shared-target) ]] || fail "shared bind identity differs from pinned source"
[[ $(command stat -Lc '%d' "$CALLER_DATA_ROOT") != "$storage_dev" ]] || fail "Docker boundary unexpectedly shares the storage filesystem"
[[ $(command stat -Lc '%u:%a' "$MOUNT_ROOT") == 0:711 &&
  $(command stat -Lc '%u:%a' "$CALLER_DATA_ROOT") == 0:711 ]] || fail "production ancestors are not root-owned/private-boundary modes"
[[ $(command stat -Lc '%u:%a' "$EXPECTED_STORAGE") == ${TEST_UID}:700 &&
  $(command stat -Lc '%u:%a' "$EXPECTED_SHARED") == ${TEST_UID}:700 ]] || fail "migrated leaves are not caller-owned 0700"
if setpriv --reuid=${TEST_UID_OTHER} --regid=${TEST_UID_OTHER} --clear-groups cat "$EXPECTED_STORAGE/disk.img" >/dev/null 2>&1; then
  fail "another local account read the VM disk through its anchor"
fi
if setpriv --reuid=${TEST_UID_OTHER} --regid=${TEST_UID_OTHER} --clear-groups cat "$EXPECTED_SHARED/shared.txt" >/dev/null 2>&1; then
  fail "another local account read shared files through their anchor"
fi
pass "cross-filesystem symlink sources bind by identity and migrated 0700 leaves deny another account"

# GNU chmod 0700 leaves directory setgid; leftover g+s used to fail the
# exact-700 check and block every privileged action (omacom/omarchy#9698).
chmod 2700 /home/storage-target
chmod 2777 /home/shared-target
chown ${TEST_UID}:${TEST_UID} /home/storage-target /home/shared-target
with_vm_lock prepare_caller_mounts || fail "root could not harden setgid VM source directories"
[[ $(command stat -Lc '%a' /home/storage-target) == 700 ]] || fail "storage still had special bits after hardening"
[[ $(command stat -Lc '%a' /home/shared-target) == 700 ]] || fail "shared still had special bits after hardening"
[[ $(command stat -Lc '%u:%a' "$EXPECTED_STORAGE") == ${TEST_UID}:700 &&
  $(command stat -Lc '%u:%a' "$EXPECTED_SHARED") == ${TEST_UID}:700 ]] || fail "setgid hardening did not leave caller-owned 0700 anchors"
pass "setgid VM source directories harden to exactly 700"

# Stop-time restore must cover every caller shape. Root walks the mounts tree
# for a direct `sudo ... stop`; a sudoless-Docker stop is unelevated, where the
# 0711 tree is not listable, and must restore the caller's own anchor
# owner-side instead. A second account's anchor is never another user's to
# chmod, and nothing runs through a non-standard privileged runtime path.
mkdir -p "$USERS_DIR/${TEST_UID_OTHER}/shared" "$test_tmp/mounts/users/${TEST_UID}/shared"
chmod 2777 "$USERS_DIR/${TEST_UID_OTHER}/shared" "$EXPECTED_SHARED" "$test_tmp/mounts/users/${TEST_UID}/shared"
RUNTIME_DIR=$test_tmp restore_all_shared_privacy
[[ $(command stat -Lc '%a' "$EXPECTED_SHARED") == 2777 &&
  $(command stat -Lc '%a' "$USERS_DIR/${TEST_UID_OTHER}/shared") == 2777 &&
  $(command stat -Lc '%a' "$test_tmp/mounts/users/${TEST_UID}/shared") == 2777 ]] ||
  fail "root restored anchors through a non-standard runtime path"
install -d -m 0755 /var/vm-test-bin
install -m 0644 "$test_tmp/omarchy-windows-vm" /var/vm-test-bin/omarchy-windows-vm
child_rc=0
setpriv --reuid=${TEST_UID} --regid=${TEST_UID} --clear-groups bash -c '
  # The namespace has no passwd entry for uid ${TEST_UID}, so mirror the stub above.
  getent() {
    if [[ $1 == passwd && $2 == ${TEST_UID} ]]; then
      printf "alice:x:${TEST_UID}:${TEST_UID}::/home/alice:/bin/bash\n"
      return 0
    fi
    return 2
  }
  set -- help
  source /var/vm-test-bin/omarchy-windows-vm >/dev/null 2>&1
  resolve_caller || exit 10
  restore_all_shared_privacy || exit 11
  [[ $(command stat -Lc "%a" "$USERS_DIR/${TEST_UID}/shared") == 2777 ]] || exit 12
  [[ $(command stat -Lc "%a" "$USERS_DIR/${TEST_UID_OTHER}/shared") == 2777 ]] || exit 13
  restore_shared_privacy || exit 14
  [[ $(command stat -Lc "%a" "$USERS_DIR/${TEST_UID}/shared") == 700 ]] || exit 15
  [[ $(command stat -Lc "%a" "$USERS_DIR/${TEST_UID_OTHER}/shared") == 2777 ]] || exit 16
' || child_rc=$?
[[ $child_rc == 0 ]] || fail "sudoless stop restore misbehaved (rc=$child_rc)"
chmod 2777 "$EXPECTED_SHARED"
restore_all_shared_privacy
[[ $(command stat -Lc '%a' "$EXPECTED_SHARED") == 700 &&
  $(command stat -Lc '%a' "$USERS_DIR/${TEST_UID_OTHER}/shared") == 700 ]] ||
  fail "root walk did not restore every anchor to 700"
rm -rf /var/vm-test-bin
pass "stop-time restore walks the tree as root and restores only the caller's anchor unprivileged"

# Existing production boundary components are never repaired in place when
# their ownership or write permissions are unsafe. Both the preparation path
# and the final pre-Docker guard must fail closed without disturbing the binds.
chmod 0731 "$MOUNT_ROOT"
with_vm_lock prepare_caller_mounts 2>/dev/null && fail "root repaired a group-writable mount boundary instead of rejecting it"
mounts_ready 2>/dev/null && fail "final guard accepted a group-writable mount boundary"
[[ $(command stat -Lc '%a' "$MOUNT_ROOT") == 731 ]] || fail "rejection unexpectedly changed the writable boundary"
chmod 0711 "$MOUNT_ROOT"

chown ${TEST_UID}:${TEST_UID} "$USERS_DIR"
with_vm_lock prepare_caller_mounts 2>/dev/null && fail "root repaired a caller-owned mount boundary instead of rejecting it"
mounts_ready 2>/dev/null && fail "final guard accepted a caller-owned mount boundary"
[[ $(command stat -Lc '%u' "$USERS_DIR") == ${TEST_UID} ]] || fail "rejection unexpectedly changed the boundary owner"
chown root:root "$USERS_DIR"

[[ $(mount_layer_count "$EXPECTED_STORAGE") == 1 &&
  $(mount_layer_count "$EXPECTED_SHARED") == 1 ]] || fail "boundary rejection changed the verified mount pair"
mounts_ready || fail "restored production boundaries were rejected"
pass "root rejects wrong-owned and group-writable production mount boundaries without mutation"

# dockur marks an empty /shared setgid (chmod 2777) on first boot, and a numeric
# chmod keeps setuid/setgid on directories. Hardening has to clear the special
# bits behind live anchors and again when the binds are recreated after reboot.
chmod 2777 /home/shared-target
chmod 6755 /home/storage-target
with_vm_lock prepare_caller_mounts || fail "root rejected setgid sources behind live anchors"
mounts_ready || fail "final guard rejected re-hardened setgid sources"
umount "$EXPECTED_SHARED"
umount "$EXPECTED_STORAGE"
chmod 2777 /home/shared-target
chmod 6755 /home/storage-target
with_vm_lock prepare_caller_mounts || fail "root could not rebind setgid sources"
[[ $(command stat -Lc '%u:%a' "$EXPECTED_STORAGE") == ${TEST_UID}:700 &&
  $(command stat -Lc '%u:%a' "$EXPECTED_SHARED") == ${TEST_UID}:700 ]] || fail "setgid sources were not hardened to 0700"
mounts_ready || fail "final guard rejected rebound setgid sources"
pass "hardening clears the setuid/setgid bits a numeric chmod keeps on directories"

# When hardening still leaves a source non-private, the rejection names the
# directory and its mode instead of failing silently.
chmod() { command chmod "$@" && command chmod g+s /home/shared-target; }
hardening_error=$(with_vm_lock prepare_caller_mounts 2>&1) && fail "root accepted a source that stayed setgid after hardening"
unset -f chmod
[[ $hardening_error == *"/home/alice/Windows is mode 2700"* ]] || fail "setgid rejection did not name the directory and mode: $hardening_error"
chmod g-s /home/shared-target
mounts_ready || fail "verified anchors were disturbed by the rejected hardening"
pass "a source that cannot be made private is rejected with its path and mode"

expected_space=$(command df -P -- /home/storage-target | awk 'NR==2 {print int($4/1024/1024)}')
actual_space=$(available_storage_gb)
[[ $actual_space == "$expected_space" ]] || fail "disk-space helper did not measure the storage target filesystem"
[[ $(command df -P -- /home/alice | awk 'NR==2 {print int($4/1024/1024)}') != "$actual_space" ]] || fail "test filesystems do not distinguish home from storage"
pass "disk-space accounting measures the actual storage filesystem, not home"

# Exercise the real root writer and final guard against the production paths.
printf 'RAM=4G\nCORES=2\nDISK=64G\nUSERNAME=alice\nPASSWORD=pw\nTZ=UTC\n' |
  with_vm_lock __priv_write_compose
[[ $(command stat -Lc '%u:%a' "$COMPOSE_FILE") == 0:640 ]] || fail "root compose ownership/mode is wrong"
with_vm_lock assert_mounts_safe || fail "final root mount/compose assertion rejected the verified pair"
pass "root writer and final pre-Docker guard revalidate the pinned production mounts"

# Upgrade the exact sibling-anchor pair emitted by the earlier fix without
# moving or replacing either familiar home symlink.
sed -i "s|$EXPECTED_STORAGE:/storage|$OLD_EXPECTED_STORAGE:/storage|" "$COMPOSE_FILE"
sed -i "s|$EXPECTED_SHARED:/shared|$OLD_EXPECTED_SHARED:/shared|" "$COMPOSE_FILE"
sed -i '/PROTECT: "Y"/d' "$COMPOSE_FILE"
compose_needs_security_migration || fail "previous protected compose was not recognized for upgrade"
with_vm_lock assert_mounts_safe || fail "root could not upgrade previous protected anchors"
grep -q -- "- $EXPECTED_STORAGE:/storage" "$COMPOSE_FILE" || fail "upgrade did not rewrite storage anchor"
grep -q -- "- $EXPECTED_SHARED:/shared" "$COMPOSE_FILE" || fail "upgrade did not rewrite shared anchor"
grep -q 'PROTECT: "Y"' "$COMPOSE_FILE" || fail "upgrade did not protect the web console"
[[ $(readlink /home/alice/.windows) == /home/storage-target ]] || fail "protected-anchor upgrade replaced home storage link"
pass "previous sibling-anchor installs upgrade in place to the fixed /var/lib boundary"

# A compose that already uses the fixed anchors still needs an authorized
# upgrade when it predates web-console authentication.
sed -i '/PROTECT: "Y"/d' "$COMPOSE_FILE"
compose_needs_security_migration || fail "unprotected fixed-anchor compose was not recognized for upgrade"
with_vm_lock assert_mounts_safe || fail "root could not protect an existing fixed-anchor compose"
grep -q 'PROTECT: "Y"' "$COMPOSE_FILE" || fail "fixed-anchor upgrade did not protect the web console"
pass "existing fixed-anchor compose gains web-console authentication"

# Preflight both sources before either bind on a clean anchor pair.
umount "$EXPECTED_SHARED"
umount "$EXPECTED_STORAGE"
rm /home/alice/Windows
ln -s / /home/alice/Windows
chown -h ${TEST_UID}:${TEST_UID} /home/alice/Windows
with_vm_lock prepare_caller_mounts 2>/dev/null && fail "root accepted a non-caller-owned second source"
[[ $(mount_layer_count "$EXPECTED_STORAGE") == 0 && $(mount_layer_count "$EXPECTED_SHARED") == 0 ]] || fail "failed second-source preflight left a partial bind"
[[ $(readlink /home/alice/Windows) == / ]] || fail "failed preflight consumed or quarantined symlink"
pass "root preflights both sources before mounting either and preserves rejection evidence"

# mountpoint(1) follows symlinks, so explicitly pin the invariant that even a
# root-planted anchor symlink to the expected mounted source is rejected.
rm /home/alice/Windows
ln -s /home/shared-target /home/alice/Windows
chown -h ${TEST_UID}:${TEST_UID} /home/alice/Windows
rmdir "$EXPECTED_STORAGE"
ln -s /home/storage-target "$EXPECTED_STORAGE"
storage_id=$(command stat -Lc '%d:%i' /home/storage-target)
mounted_leaf_matches "$EXPECTED_STORAGE" "$storage_id" && fail "symlink mount anchor passed final identity check"
with_vm_lock prepare_caller_mounts 2>/dev/null && fail "root followed a symlink mount anchor"
[[ -L $EXPECTED_STORAGE ]] || fail "rejected anchor symlink was consumed"
pass "final guard rejects a symlink even when it resolves to the expected mounted source"
