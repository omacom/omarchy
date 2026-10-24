#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

windows_vm_command="$ROOT/bin/omarchy-windows-vm"

rg -q '^    restart: "no"$' "$windows_vm_command" ||
  fail "Windows VM uses manual startup by default"
pass "Windows VM uses manual startup by default"

if rg -q '^    restart: unless-stopped$' "$windows_vm_command"; then
  fail "Windows VM does not restart automatically at boot"
fi
pass "Windows VM does not restart automatically at boot"

# Tolerate either shell quoting of the argument.
rg -q 'title:"?Windows VM - Omarchy"' "$windows_vm_command" ||
  fail "Windows VM launches FreeRDP with its expected title"
pass "Windows VM launches FreeRDP with its expected title"

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
