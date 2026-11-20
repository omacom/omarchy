#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export OMARCHY_PATH="$ROOT"

if "$ROOT/bin/omarchy-cmd-present" -p; then
  fail "cmd-present treats an option-shaped command name literally"
fi
pass "cmd-present treats an option-shaped command name literally"

"$ROOT/bin/omarchy-cmd-missing" -p ||
  fail "cmd-missing treats an option-shaped command name literally"
pass "cmd-missing treats an option-shaped command name literally"

"$ROOT/bin/omarchy-cmd-present" bash || fail "cmd-present still finds an ordinary command"
pass "cmd-present still finds an ordinary command"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/pacman" <<'STUB'
#!/bin/bash

if [[ -n ${OMARCHY_TEST_PACKAGE_CALLS:-} ]]; then
  {
    printf 'pacman'
    printf ' <%s>' "$@"
    printf '\n'
  } >>"$OMARCHY_TEST_PACKAGE_CALLS"
fi

if [[ $1 == "-S" ]]; then
  exit 0
elif [[ $1 != "-Q" ]]; then
  exit 2
fi
shift

if [[ -n ${OMARCHY_TEST_PACKAGE_CALLS:-} ]]; then
  exit 0
elif [[ ${1:-} == "--" ]]; then
  shift
  [[ ${1:-} == "installed" ]]
elif [[ ${1:-} == "--help" ]]; then
  exit 0
else
  [[ ${1:-} == "installed" ]]
fi
STUB
chmod +x "$mock_bin/pacman"

if PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-pkg-present" --help; then
  fail "pkg-present treats an option-shaped package name literally"
fi
pass "pkg-present treats an option-shaped package name literally"

PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-pkg-missing" --help ||
  fail "pkg-missing treats an option-shaped package name literally"
pass "pkg-missing treats an option-shaped package name literally"

PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-pkg-present" installed ||
  fail "pkg-present still finds an installed package"
pass "pkg-present still finds an installed package"

package_calls="$test_tmp/package-calls"
cat >"$mock_bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash

exit 0
STUB
cat >"$mock_bin/sudo" <<'STUB'
#!/bin/bash

# Like sudo, outlive a Ctrl-C at the password prompt and exit 1 rather than die of the signal.
if [[ -n ${OMARCHY_TEST_SUDO_SLEEP:-} ]]; then
  trap : INT
  : >"$OMARCHY_TEST_SUDO_READY"
  sleep "$OMARCHY_TEST_SUDO_SLEEP"
  exit 1
elif [[ -n ${OMARCHY_TEST_SUDO_STATUS:-} ]]; then
  exit "$OMARCHY_TEST_SUDO_STATUS"
else
  exec "$@"
fi
STUB
cat >"$mock_bin/yay" <<'STUB'
#!/bin/bash

: "${OMARCHY_TEST_PACKAGE_CALLS:?}"
{
  printf 'yay'
  printf ' <%s>' "$@"
  printf '\n'
} >>"$OMARCHY_TEST_PACKAGE_CALLS"
STUB
chmod +x "$mock_bin/omarchy-pkg-missing" "$mock_bin/sudo" "$mock_bin/yay"

: >"$package_calls"
PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_PACKAGE_CALLS="$package_calls" \
  "$ROOT/bin/omarchy-pkg-add" --hookdir=/tmp/hooks

grep -Fx 'pacman <-S> <--noconfirm> <--needed> <--> <--hookdir=/tmp/hooks>' "$package_calls" >/dev/null ||
  fail "pkg-add separates package operands from pacman options" "$(<"$package_calls")"
grep -Fx 'pacman <-Q> <--> <--hookdir=/tmp/hooks>' "$package_calls" >/dev/null ||
  fail "pkg-add verifies an option-shaped package name literally" "$(<"$package_calls")"
pass "pkg-add keeps option-shaped package names out of pacman option parsing"

if (( EUID == 0 )); then
  skip "pkg-add sudo authentication cancellation checks do not apply to root"
else
  service_mock_bin="$test_tmp/service-bin"
  mkdir -p "$service_mock_bin"
  for helper in omarchy-plugin-enable uwsm-app systemctl tailscale omarchy-webapp-install; do
    cat >"$service_mock_bin/$helper" <<STUB
#!/bin/bash

printf '$helper %s\n' "\$*" >>"\$OMARCHY_TEST_PACKAGE_CALLS"
exit 0
STUB
  done
  chmod +x "$service_mock_bin"/*

  : >"$package_calls"
  status=0
  PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_PACKAGE_CALLS="$package_calls" \
    OMARCHY_TEST_SUDO_STATUS=1 \
    "$ROOT/bin/omarchy-pkg-add" demo-pkg >/dev/null 2>&1 || status=$?
  (( status == 1 )) || fail "a sudo failure nobody cancelled in omarchy-pkg-add exits 1" "status=$status"
  [[ ! -s $package_calls ]] || fail "a sudo failure in omarchy-pkg-add must not start pacman" "$(<"$package_calls")"
  pass "a sudo failure nobody cancelled in omarchy-pkg-add exits 1, so it is reported as failed"

  for installer in omarchy-install-service-dropbox omarchy-install-service-tailscale; do
    : >"$package_calls"
    status=0
    PATH="$service_mock_bin:$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_PACKAGE_CALLS="$package_calls" \
      OMARCHY_TEST_SUDO_STATUS=1 \
      "$ROOT/bin/$installer" >/dev/null 2>&1 || status=$?
    (( status == 1 )) || fail "$installer stops with the package install's status" "status=$status"
    [[ ! -s $package_calls ]] || fail "$installer must not run later service steps after a failed package install" "$(<"$package_calls")"
  done
  pass "service installers stop at a failed package install without running later service steps"

  require_command python3
  ready="$test_tmp/sudo-ready"
  : >"$package_calls"
  rm -f "$ready"
  interrupt_output=$(
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_PACKAGE_CALLS="$package_calls" \
    OMARCHY_TEST_SUDO_SLEEP=3 \
    OMARCHY_TEST_SUDO_READY="$ready" \
    python3 - "$ROOT/bin/omarchy-pkg-add" "$ready" 2>&1 <<'PY'
import os
from pathlib import Path
import signal
import sys
import time

cmd, ready_path = sys.argv[1], Path(sys.argv[2])
pid = os.fork()
if pid == 0:
    try:
        os.setsid()
        signal.signal(signal.SIGINT, signal.SIG_DFL)
        devnull = os.open(os.devnull, os.O_RDWR)
        for fd in (0, 1, 2):
            os.dup2(devnull, fd)
        if devnull > 2:
            os.close(devnull)
        os.execv(cmd, [cmd, "demo-pkg"])
    except BaseException:
        os._exit(127)

status = None
try:
    deadline = time.monotonic() + 5
    while time.monotonic() < deadline:
        if ready_path.exists():
            break
        waited, wait_status = os.waitpid(pid, os.WNOHANG)
        if waited == pid:
            status = wait_status
            raise SystemExit(f"omarchy-pkg-add exited before sudo started (wait status {status})")
        time.sleep(0.02)
    if not ready_path.exists():
        raise SystemExit("sudo authentication did not start in time")

    os.killpg(pid, signal.SIGINT)

    deadline = time.monotonic() + 10
    while time.monotonic() < deadline:
        waited, wait_status = os.waitpid(pid, os.WNOHANG)
        if waited == pid:
            status = wait_status
            break
        time.sleep(0.02)
    if status is None:
        raise SystemExit("omarchy-pkg-add did not exit after SIGINT")
    if os.WIFSIGNALED(status):
        raise SystemExit(f"killed by signal {os.WTERMSIG(status)} instead of exiting 130")
    code = os.WEXITSTATUS(status)
    if code != 130:
        raise SystemExit(f"status={code}")
finally:
    if status is None:
        try:
            os.killpg(pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        try:
            os.waitpid(pid, 0)
        except ChildProcessError:
            pass
PY
  ) || fail "SIGINT during omarchy-pkg-add sudo prompt exits 130" "$interrupt_output"
  [[ ! -s $package_calls ]] || fail "SIGINT during sudo prompt must not run pacman" "$(<"$package_calls")"
  pass "SIGINT during omarchy-pkg-add sudo prompt exits 130 without running pacman"
fi

: >"$package_calls"
PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_PACKAGE_CALLS="$package_calls" \
  "$ROOT/bin/omarchy-pkg-aur-add" --hookdir=/tmp/hooks

grep -Fx 'yay <-S> <--noconfirm> <--needed> <--> <--hookdir=/tmp/hooks>' "$package_calls" >/dev/null ||
  fail "pkg-aur-add separates package operands from yay options" "$(<"$package_calls")"
grep -Fx 'pacman <-Q> <--> <--hookdir=/tmp/hooks>' "$package_calls" >/dev/null ||
  fail "pkg-aur-add verifies an option-shaped package name literally" "$(<"$package_calls")"
pass "pkg-aur-add keeps option-shaped package names out of package-manager option parsing"

cat >"$mock_bin/grep" <<'STUB'
#!/bin/bash

if [[ $1 != "-qi" ]]; then
  exit 2
fi
shift

if [[ ${1:-} == "--help" ]]; then
  exit 0
elif [[ ${1:-} == "--" ]]; then
  shift
fi
[[ ${1:-} == "known-hardware" ]]
STUB
chmod +x "$mock_bin/grep"

if PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-hw-match" --help; then
  fail "hw-match treats an option-shaped hardware pattern literally"
fi
pass "hw-match treats an option-shaped hardware pattern literally"

PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-hw-match" known-hardware ||
  fail "hw-match still accepts an ordinary hardware pattern"
pass "hw-match still accepts an ordinary hardware pattern"

pkill_calls="$test_tmp/pkill-calls"
cat >"$mock_bin/pkill" <<'STUB'
#!/bin/bash

: "${OMARCHY_TEST_PKILL_CALLS:?}"
printf '<%s>\n' "$@" >"$OMARCHY_TEST_PKILL_CALLS"
STUB
cat >"$mock_bin/setsid" <<'STUB'
#!/bin/bash

if [[ -n ${OMARCHY_TEST_SETSID_CALLS:-} ]]; then
  printf '<%s>\n' "$@" >"$OMARCHY_TEST_SETSID_CALLS"
fi
exit 0
STUB
chmod +x "$mock_bin/pkill" "$mock_bin/setsid"

PATH="$mock_bin:$PATH" OMARCHY_TEST_PKILL_CALLS="$pkill_calls" \
  "$ROOT/bin/omarchy-restart-app" "-9 kitty"

pkill_argv=$(<"$pkill_calls")
[[ $pkill_argv == $'<-x>\n<-->\n<-9 kitty>' ]] ||
  fail "restart-app treats the application name as one literal pkill pattern" "$pkill_argv"
pass "restart-app treats the application name as one literal pkill pattern"

fake_home="$test_tmp/home"
editor_calls="$test_tmp/editor-calls"
mkdir -p "$fake_home/.local/state/omarchy/defaults"
printf 'nvim\n' >"$fake_home/.local/state/omarchy/defaults/editor"

cat >"$mock_bin/nvim" <<'STUB'
#!/bin/bash

: "${OMARCHY_TEST_EDITOR_CALLS:?}"
printf '<%s>\n' "$@" >"$OMARCHY_TEST_EDITOR_CALLS"
STUB
chmod +x "$mock_bin/nvim"

HOME="$fake_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_EDITOR_CALLS="$editor_calls" \
  "$ROOT/bin/omarchy-launch-editor" --inline -cquit

editor_argv=$(<"$editor_calls")
[[ $editor_argv == $'<-->\n<-cquit>' ]] ||
  fail "launch-editor separates an option-shaped path from editor options" "$editor_argv"
pass "launch-editor separates an option-shaped path from editor options"

cat >"$mock_bin/omarchy-launch-tui" <<'STUB'
#!/bin/bash

: "${OMARCHY_TEST_EDITOR_CALLS:?}"
printf '<%s>\n' "$@" >"$OMARCHY_TEST_EDITOR_CALLS"
STUB
chmod +x "$mock_bin/omarchy-launch-tui"

HOME="$fake_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_EDITOR_CALLS="$editor_calls" \
  "$ROOT/bin/omarchy-launch-editor" -cquit

editor_argv=$(<"$editor_calls")
[[ $editor_argv == $'<nvim>\n<-->\n<-cquit>' ]] ||
  fail "launch-editor separates a terminal editor path from editor options" "$editor_argv"
pass "launch-editor separates a terminal editor path from editor options"

setsid_calls="$test_tmp/setsid-calls"
printf 'code\n' >"$fake_home/.local/state/omarchy/defaults/editor"
cat >"$mock_bin/code" <<'STUB'
#!/bin/bash

exit 0
STUB
chmod +x "$mock_bin/code"

HOME="$fake_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_SETSID_CALLS="$setsid_calls" \
  "$ROOT/bin/omarchy-launch-editor" -cquit

setsid_argv=$(<"$setsid_calls")
[[ $setsid_argv == $'<uwsm-app>\n<-->\n<code>\n<-->\n<-cquit>' ]] ||
  fail "launch-editor separates a graphical editor path from editor options" "$setsid_argv"
pass "launch-editor separates a graphical editor path from editor options"

# Plain, the default without a saved choice, runs inline for $EDITOR so the
# caller waits for its window, and falls back to Neovim without a display.
rm -f "$fake_home/.local/state/omarchy/defaults/editor"
cat >"$mock_bin/plain" <<'STUB'
#!/bin/bash

: "${OMARCHY_TEST_EDITOR_CALLS:?}"
printf '<plain>\n' >"$OMARCHY_TEST_EDITOR_CALLS"
printf '<%s>\n' "$@" >>"$OMARCHY_TEST_EDITOR_CALLS"
STUB
chmod +x "$mock_bin/plain"

HOME="$fake_home" PATH="$mock_bin:$ROOT/bin:$PATH" WAYLAND_DISPLAY=wayland-1 OMARCHY_TEST_EDITOR_CALLS="$editor_calls" \
  "$ROOT/bin/omarchy-launch-editor" --inline -cquit
editor_argv=$(<"$editor_calls")
[[ $editor_argv == $'<plain>\n<-->\n<-cquit>' ]] ||
  fail "launch-editor runs Plain inline as the default editor" "$editor_argv"

HOME="$fake_home" PATH="$mock_bin:$ROOT/bin:$PATH" WAYLAND_DISPLAY=wayland-1 OMARCHY_TEST_SETSID_CALLS="$setsid_calls" \
  "$ROOT/bin/omarchy-launch-editor" -cquit
setsid_argv=$(<"$setsid_calls")
[[ $setsid_argv == $'<uwsm-app>\n<-->\n<plain>\n<-->\n<-cquit>' ]] ||
  fail "launch-editor opens Plain as an app when not inline" "$setsid_argv"

cat >"$mock_bin/vi" <<'STUB'
#!/bin/bash

: "${OMARCHY_TEST_EDITOR_CALLS:?}"
printf '<vi>\n' >"$OMARCHY_TEST_EDITOR_CALLS"
printf '<%s>\n' "$@" >>"$OMARCHY_TEST_EDITOR_CALLS"
STUB
chmod +x "$mock_bin/vi"

env -u WAYLAND_DISPLAY HOME="$fake_home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_EDITOR_CALLS="$editor_calls" \
  "$ROOT/bin/omarchy-launch-editor" --inline -cquit
editor_argv=$(<"$editor_calls")
[[ $editor_argv == $'<vi>\n<-->\n<-cquit>' ]] ||
  fail "launch-editor uses vi for Plain without a display" "$editor_argv"
rm -f "$mock_bin/vi"
pass "launch-editor defaults to Plain, inline for \$EDITOR, and vi without a display"

hook_calls="$test_tmp/hook-calls"
hook_home="$test_tmp/hook-home"
printf '#!/bin/bash\n' >"$test_tmp/--help"
cat >"$mock_bin/basename" <<'STUB'
#!/bin/bash

: "${OMARCHY_TEST_HOOK_CALLS:?}"
{
  printf 'basename'
  printf ' <%s>' "$@"
  printf '\n'
} >>"$OMARCHY_TEST_HOOK_CALLS"
printf 'literal-hook\n'
STUB
cat >"$mock_bin/cp" <<'STUB'
#!/bin/bash

: "${OMARCHY_TEST_HOOK_CALLS:?}"
{
  printf 'cp'
  printf ' <%s>' "$@"
  printf '\n'
} >>"$OMARCHY_TEST_HOOK_CALLS"
STUB
for command in mkdir chmod; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$command"
done
chmod +x "$mock_bin/basename" "$mock_bin/cp" "$mock_bin/mkdir" "$mock_bin/chmod"

: >"$hook_calls"
(
  cd -- "$test_tmp"
  HOME="$hook_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_HOOK_CALLS="$hook_calls" \
    "$ROOT/bin/omarchy-hook-install" post-update --help >/dev/null
)

hook_argv=$(<"$hook_calls")
expected_hook_argv=$'basename <--> <--help>\ncp <--> <--help> <'"$hook_home"'/.config/omarchy/hooks/post-update.d/literal-hook>'
[[ $hook_argv == $expected_hook_argv ]] ||
  fail "hook-install treats its source file as an operand" "$hook_argv"
pass "hook-install treats its source file as an operand"
