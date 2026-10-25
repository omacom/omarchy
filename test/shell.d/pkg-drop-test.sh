#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_path="$test_tmp/pkg-drop-bin"
mkdir -p "$mock_path"

cat >"$mock_path/pacman" <<'EOF'
#!/bin/bash
if [[ $1 == "-Q" ]]; then
  [[ ${!#} == exact-package || ${!#} == provider-package ]]
  exit
fi
if [[ $1 == "-Qq" ]]; then
  if [[ ${TEST_PACKAGES_EMPTY:-0} == "0" ]]; then
    printf '%s\n' exact-package provider-package
  fi
  exit "${TEST_QUERY_STATUS:-0}"
fi
EOF

cat >"$mock_path/sudo" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_TMP/pkg-drop-command"
exit "${TEST_REMOVE_STATUS:-0}"
EOF

for command in yay fzf omarchy-show-done; do
  cat >"$mock_path/$command" <<'EOF'
#!/bin/bash
printf '%s\n' "${0##*/} $*" >>"$TEST_TMP/pkg-drop-command"
EOF
done

# Changing packages takes an administrator; these cases run as one unless
# TEST_ADMIN=no.
cat >"$mock_path/omarchy-sudo-allowed" <<'EOF'
#!/bin/bash
[[ ${TEST_ADMIN:-yes} == yes ]]
EOF

chmod +x "$mock_path"/*

PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" \
  "$ROOT/bin/omarchy-pkg-drop" exact-package virtual-package provider-package exact-package

[[ $(<"$test_tmp/pkg-drop-command") == "pacman -Rns --noconfirm exact-package provider-package" ]] ||
  fail "package removal targets exact installed names only"
pass "package removal ignores providers and duplicate arguments"

rm "$test_tmp/pkg-drop-command"
if PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" TEST_QUERY_STATUS=1 \
  "$ROOT/bin/omarchy-pkg-drop" exact-package >"$test_tmp/output" 2>&1; then
  fail "failed package discovery must fail removal even with partial output"
fi
[[ ! -e $test_tmp/pkg-drop-command ]] || fail "failed discovery must not request privileges"
pass "package removal propagates discovery errors before requesting privileges"

PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" TEST_PACKAGES_EMPTY=1 \
  "$ROOT/bin/omarchy-pkg-drop" exact-package
[[ ! -e $test_tmp/pkg-drop-command ]] || fail "empty package database must not request privileges"
pass "an empty package database is a successful no-op"

if PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" TEST_REMOVE_STATUS=1 \
  "$ROOT/bin/omarchy-pkg-drop" exact-package; then
  fail "failed package transaction must fail removal"
fi
pass "package removal propagates transaction failures"

# Anyone but an administrator is told so before sudo or yay is asked anything,
# rather than asked for a password sudo then refuses. Nothing to do takes no
# administrator.
packages() { # yes|no COMMAND [packages...]: run a package command as an administrator or not
  rm -f "$test_tmp/pkg-drop-command"
  PATH="$mock_path:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" TEST_ADMIN="$1" \
    "$ROOT/bin/$2" "${@:3}" >"$test_tmp/output" 2>&1
}

declare -A install_call=(
  [omarchy-pkg-add]="pacman -S --noconfirm --needed -- new-package"
  [omarchy-pkg-aur-add]="yay -S --noconfirm --needed -- new-package"
)
for command in "${!install_call[@]}"; do
  if packages no "$command" new-package; then
    fail "$command reports success for an account that isn't an administrator"
  fi
  [[ $(<"$test_tmp/output") == "Only an administrator can install software." && ! -e $test_tmp/pkg-drop-command ]] ||
    fail "$command tells anyone else that an administrator installs software, asking nothing" "$(cat "$test_tmp/output")"
  packages yes "$command" new-package || true
  [[ $(cat "$test_tmp/pkg-drop-command" 2>/dev/null) == "${install_call[$command]}" ]] || fail "$command installs for an administrator"
  packages no "$command" exact-package || fail "$command fails for an installed package" "$(cat "$test_tmp/output")"
  [[ ! -e $test_tmp/pkg-drop-command ]] || fail "$command asks for an installed package" "$(cat "$test_tmp/pkg-drop-command")"
done
pass "installing takes an administrator, and nothing to install takes no one"

if packages no omarchy-pkg-drop exact-package; then
  fail "omarchy-pkg-drop reports success for an account that isn't an administrator"
fi
[[ $(<"$test_tmp/output") == "Only an administrator can remove software." && ! -e $test_tmp/pkg-drop-command ]] ||
  fail "omarchy-pkg-drop tells anyone else that an administrator removes software, asking nothing" "$(cat "$test_tmp/output")"
packages no omarchy-pkg-drop missing-package || fail "omarchy-pkg-drop fails when there is nothing to remove"
[[ ! -e $test_tmp/pkg-drop-command ]] || fail "omarchy-pkg-drop asks with nothing to remove"
pass "removing takes an administrator, and nothing to remove takes no one"

# The pickers say so before there is anything to pick.
for command in omarchy-pkg-install omarchy-pkg-aur-install omarchy-pkg-remove; do
  verb=install
  [[ $command != omarchy-pkg-remove ]] || verb=remove
  packages no "$command" || true
  [[ $(<"$test_tmp/output") == "Only an administrator can $verb software." && $(<"$test_tmp/pkg-drop-command") == "omarchy-show-done 1" ]] ||
    fail "$command tells anyone else before picking or asking anything" "$(cat "$test_tmp/output" "$test_tmp/pkg-drop-command")"
  packages yes "$command" || true
  grep -q "^fzf " "$test_tmp/pkg-drop-command" || fail "$command shows an administrator the picker"
done
pass "the package pickers take an administrator, and say so before picking"
