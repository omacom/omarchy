#!/bin/bash
#
# Installing and removing packages changes the whole machine, so it takes an
# administrator. Anyone else is told so before sudo or yay is asked anything,
# rather than being asked for a password sudo then refuses. Nothing to do needs
# no administrator, and root needs no sudo.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin"

# Every package manager call is recorded; a package counts as installed once
# it is in $TEST_INSTALLED.
for command in sudo yay fzf omarchy-show-done; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$TEST_CALLS"
SH
done
cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
case "$1" in
  -Q | -Qq)
    if [[ $1 == "-Qq" && $# == 1 ]]; then
      printf '%s\n' $TEST_INSTALLED
      exit 0
    fi
    [[ " $TEST_INSTALLED " == *" ${!#} "* ]]
    ;;
  *) printf 'pacman %s\n' "$*" >>"$TEST_CALLS" ;;
esac
SH
cat >"$mock_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash
for pkg in "$@"; do
  [[ " $TEST_INSTALLED " == *" $pkg "* ]] || exit 0
done
exit 1
SH
cat >"$mock_bin/omarchy-sudo-allowed" <<'SH'
#!/bin/bash
[[ $TEST_ADMIN == "yes" ]]
SH
chmod +x "$mock_bin"/*

run() { # ADMIN INSTALLED COMMAND [packages...]
  : >"$calls"
  env PATH="$mock_bin:$PATH" TEST_ADMIN="$1" TEST_INSTALLED="$2" TEST_CALLS="$calls" \
    bash "$ROOT/bin/$3" "${@:4}" >"$test_tmp/out" 2>"$test_tmp/err"
}

for command in omarchy-pkg-add omarchy-pkg-aur-add; do
  if run no "" "$command" firefox; then
    fail "$command reports success for an account that isn't an administrator"
  fi
  grep -Fx 'Only an administrator can install software.' "$test_tmp/err" >/dev/null ||
    fail "$command doesn't say an administrator installs software" "$(cat "$test_tmp/err")"
  [[ ! -s $calls ]] || fail "$command asked the package manager anyway" "$(cat "$calls")"

  run yes "" "$command" firefox || true
  [[ -s $calls ]] || fail "$command doesn't install for an administrator"

  run no "firefox" "$command" firefox || fail "$command fails for an installed package" "$(cat "$test_tmp/err")"
  [[ ! -s $calls ]] || fail "$command asked the package manager for an installed package" "$(cat "$calls")"
done
pass "installing takes an administrator, and nothing to install takes no one"

if run no "firefox" omarchy-pkg-drop firefox; then
  fail "omarchy-pkg-drop reports success for an account that isn't an administrator"
fi
grep -Fx 'Only an administrator can remove software.' "$test_tmp/err" >/dev/null ||
  fail "omarchy-pkg-drop doesn't say an administrator removes software" "$(cat "$test_tmp/err")"
[[ ! -s $calls ]] || fail "omarchy-pkg-drop asked sudo anyway" "$(cat "$calls")"

run yes "firefox" omarchy-pkg-drop firefox || fail "omarchy-pkg-drop fails for an administrator" "$(cat "$test_tmp/err")"
grep -Fx 'sudo pacman -Rns --noconfirm firefox' "$calls" >/dev/null || fail "omarchy-pkg-drop doesn't remove for an administrator" "$(cat "$calls")"

run no "" omarchy-pkg-drop firefox || fail "omarchy-pkg-drop fails when there is nothing to remove"
[[ ! -s $calls ]] || fail "omarchy-pkg-drop asked sudo with nothing to remove" "$(cat "$calls")"
pass "removing takes an administrator, and nothing to remove takes no one"

# The pickers say so before there is anything to pick.
for command in omarchy-pkg-install omarchy-pkg-aur-install omarchy-pkg-remove; do
  verb=install
  [[ $command != "omarchy-pkg-remove" ]] || verb=remove
  run no "" "$command" || true
  grep -Fx "Only an administrator can $verb software." "$test_tmp/err" >/dev/null ||
    fail "$command doesn't say an administrator does this" "$(cat "$test_tmp/err")"
  [[ $(cat "$calls") == "omarchy-show-done 1" ]] || fail "$command only waits for a key, picking and asking nothing" "$(cat "$calls")"
  run yes "" "$command" || true
  grep -q "^fzf " "$calls" || fail "$command shows the picker to an administrator" "$(cat "$calls")"
done
pass "the package pickers take an administrator, and say so before picking"
