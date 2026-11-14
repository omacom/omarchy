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

case "$1" in
  -T)
    shift
    if [[ ${1:-} == "--help" ]]; then
      exit 0
    fi
    if [[ ${1:-} == "--" ]]; then
      shift
    fi
    if [[ -n ${OMARCHY_TEST_PACKAGE_CALLS:-} && -z ${SATISFIED:-} && -z ${INSTALLED:-} ]]; then
      printf '%s\n' "$@"
      exit 127
    fi
    unsatisfied=0
    for dep in "$@"; do
      if [[ -n ${SATISFIED:-} ]] && grep -qxF -- "$dep" <<< "$SATISFIED"; then
        continue
      fi
      if [[ -n ${INSTALLED:-} ]] && grep -qxF -- "$dep" <<< "$INSTALLED"; then
        continue
      fi
      if [[ -n ${NOW_INSTALLED:-} && -f $NOW_INSTALLED ]] && grep -qxF -- "$dep" "$NOW_INSTALLED"; then
        continue
      fi
      printf '%s\n' "$dep"
      unsatisfied=1
    done
    (( unsatisfied )) && exit 127
    exit 0
    ;;
  -Q)
    shift
    if [[ -n ${OMARCHY_TEST_PACKAGE_CALLS:-} ]]; then
      exit 0
    elif [[ ${1:-} == "--help" ]]; then
      exit 0
    fi
    if [[ ${1:-} == "--" ]]; then
      shift
    fi
    if [[ -n ${SATISFIED:-} ]] && grep -qxF -- "$1" <<< "$SATISFIED"; then
      exit 0
    fi
    if [[ -n ${INSTALLED:-} ]] && grep -qxF -- "$1" <<< "$INSTALLED"; then
      exit 0
    fi
    if [[ -n ${NOW_INSTALLED:-} && -f $NOW_INSTALLED ]] && grep -qxF -- "$1" "$NOW_INSTALLED"; then
      exit 0
    fi
    [[ ${1:-} == "installed" ]]
    ;;
  -S)
    if [[ -n ${CALL_LOG:-} ]]; then
      printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    fi
    shift
    while [[ $# -gt 0 && $1 != "--" ]]; do
      shift
    done
    [[ ${1:-} == "--" ]] && shift
    if [[ -n ${NOW_INSTALLED:-} ]]; then
      printf '%s\n' "$@" >> "$NOW_INSTALLED"
    fi
    exit "${INSTALL_STATUS:-0}"
    ;;
  *)
    if [[ -n ${CALL_LOG:-} ]]; then
      printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    fi
    exit 2
    ;;
esac
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

case "$1" in
  pacman) exec "$@" ;;
  *)
    if [[ -n ${CALL_LOG:-} ]]; then
      echo "Unexpected privileged call: $*" >> "$CALL_LOG"
      exit 99
    fi
    exec "$@"
    ;;
esac
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

grep -Fx 'pacman <-T> <--> <--hookdir=/tmp/hooks>' "$package_calls" >/dev/null ||
  fail "pkg-add separates dependency operands from pacman options" "$(<"$package_calls")"
grep -Fx 'pacman <-S> <--noconfirm> <--needed> <--> <--hookdir=/tmp/hooks>' "$package_calls" >/dev/null ||
  fail "pkg-add separates package operands from pacman options" "$(<"$package_calls")"
grep -Fx 'pacman <-Q> <--> <--hookdir=/tmp/hooks>' "$package_calls" >/dev/null ||
  fail "pkg-add verifies an option-shaped package name literally" "$(<"$package_calls")"
pass "pkg-add keeps option-shaped package names out of pacman option parsing"

: >"$package_calls"
PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_PACKAGE_CALLS="$package_calls" \
  "$ROOT/bin/omarchy-pkg-aur-add" --hookdir=/tmp/hooks

grep -Fx 'yay <-S> <--noconfirm> <--needed> <--> <--hookdir=/tmp/hooks>' "$package_calls" >/dev/null ||
  fail "pkg-aur-add separates package operands from yay options" "$(<"$package_calls")"
grep -Fx 'pacman <-Q> <--> <--hookdir=/tmp/hooks>' "$package_calls" >/dev/null ||
  fail "pkg-aur-add verifies an option-shaped package name literally" "$(<"$package_calls")"
pass "pkg-aur-add keeps option-shaped package names out of package-manager option parsing"

rm -f "$mock_bin/omarchy-pkg-missing"

call_log="$test_tmp/calls"
now_installed="$test_tmp/installed-now"
output="$test_tmp/output"

run_pkg_add() {
  : >"$call_log"
  rm -f "$now_installed"
  pkg_add_status=0
  CALL_LOG="$call_log" NOW_INSTALLED="$now_installed" INSTALL_STATUS="${INSTALL_STATUS:-0}" \
    INSTALLED="${INSTALLED:-}" SATISFIED="${SATISFIED:-}" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-pkg-add" "$@" >"$output" 2>&1 ||
    pkg_add_status=$?
}

mozc_args=(fcitx5-mozc fcitx5-hangul fcitx5-chinese-addons fcitx5-chewing)

# The issue's state: the -ut pair installed (its fcitx5-mozc provide answers
# pacman -Q), the other three input-method packages missing.
INSTALLED=$'mozc-ut\nfcitx5-mozc-ut' SATISFIED='fcitx5-mozc' run_pkg_add "${mozc_args[@]}"
[[ $pkg_add_status == 0 ]] || fail "the mozc-ut machine installs the missing input methods" "$(<"$output")"
(( $(grep -c '^pacman -S ' "$call_log") == 1 )) || fail "the mozc-ut machine runs one transaction" "$(<"$call_log")"
grep -qxF 'pacman -S --noconfirm --needed -- fcitx5-hangul fcitx5-chinese-addons fcitx5-chewing' "$call_log" ||
  fail "a provided name stays out of the transaction" "$(<"$call_log")"
! grep -qF 'fcitx5-mozc' <(grep '^pacman -S ' "$call_log") ||
  fail "the conflicting provided name never reaches pacman" "$(<"$call_log")"
pass "a provided name stays out of the transaction; the missing names still install"

# Everything already provided: nothing to do, pacman is not touched at all.
INSTALLED=$'mozc-ut\nfcitx5-mozc-ut' SATISFIED=$'fcitx5-mozc\nfcitx5-hangul\nfcitx5-chinese-addons\nfcitx5-chewing' \
  run_pkg_add "${mozc_args[@]}"
[[ $pkg_add_status == 0 ]] || fail "an all-provided request succeeds" "$(<"$output")"
[[ ! -s $call_log ]] || fail "an all-provided request runs no transaction" "$(<"$call_log")"
pass "an all-provided request succeeds without touching pacman"

# A fresh machine still installs everything it was asked for.
run_pkg_add "${mozc_args[@]}"
[[ $pkg_add_status == 0 ]] || fail "a fresh machine installs all requested packages" "$(<"$output")"
grep -qxF 'pacman -S --noconfirm --needed -- fcitx5-mozc fcitx5-hangul fcitx5-chinese-addons fcitx5-chewing' "$call_log" ||
  fail "a fresh machine's transaction keeps every requested package" "$(<"$call_log")"
pass "a fresh machine installs every requested package"

# An exactly-installed target stays out of the transaction on its own name,
# not only through --needed.
INSTALLED='fcitx5-hangul' run_pkg_add "${mozc_args[@]}"
[[ $pkg_add_status == 0 ]] || fail "a partly installed request succeeds" "$(<"$output")"
grep -qxF 'pacman -S --noconfirm --needed -- fcitx5-mozc fcitx5-chinese-addons fcitx5-chewing' "$call_log" ||
  fail "an installed target stays out of the transaction" "$(<"$call_log")"
! grep -qF 'fcitx5-hangul' <(grep '^pacman -S ' "$call_log") ||
  fail "an installed target never reaches pacman" "$(<"$call_log")"
pass "an installed target stays out of the transaction"

# A failed transaction still fails the command.
INSTALL_STATUS=1 run_pkg_add "${mozc_args[@]}"
[[ $pkg_add_status == 1 ]] || fail "a failed transaction fails the command" "$(<"$output")"
pass "a failed transaction still fails the command"

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
