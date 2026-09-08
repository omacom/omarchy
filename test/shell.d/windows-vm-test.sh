#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

windows_vm_command="$ROOT/bin/omarchy-windows-vm"
windows_vm_rules="$ROOT/default/hypr/apps/windows-vm.lua"

rg -q '^    restart: "no"$' "$windows_vm_command" ||
  fail "Windows VM uses manual startup by default"
pass "Windows VM uses manual startup by default"

if rg -q '^    restart: unless-stopped$' "$windows_vm_command"; then
  fail "Windows VM does not restart automatically at boot"
fi
pass "Windows VM does not restart automatically at boot"

# Tolerate either shell quoting of the argument -- what must not drift is the
# title itself, since the Hyprland rule below matches on it.
rg -q 'title:"?Windows VM - Omarchy"' "$windows_vm_command" ||
  fail "Windows VM launches FreeRDP with its expected title"
rg -q 'class = "\^xfreerdp\$", title = "\^Windows VM - Omarchy\$"' "$windows_vm_rules" ||
  fail "Windows VM opacity rule targets its FreeRDP window"
rg -q 'tag = "-default-opacity"' "$windows_vm_rules" ||
  fail "Windows VM opts out of default opacity"
rg -q 'opacity = "1 1"' "$windows_vm_rules" ||
  fail "Windows VM stays fully opaque"
pass "Windows VM stays fully opaque"

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
