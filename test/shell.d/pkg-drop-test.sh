#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_path="$test_tmp/pkg-drop-bin"
mkdir -p "$mock_path"

cat >"$mock_path/pacman" <<'EOF'
#!/bin/bash
if [[ $1 == "-Qq" ]]; then
  if [[ ${EMPTY_DATABASE:-0} != "1" ]]; then
    printf '%s\n' exact-package provider-package
  fi
  exit "${QUERY_RESULT:-0}"
fi
EOF

cat >"$mock_path/sudo" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TMP/pkg-drop-command"
exit "${REMOVE_RESULT:-0}"
EOF

chmod +x "$mock_path/pacman" "$mock_path/sudo"

PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" \
  "$ROOT/bin/omarchy-pkg-drop" exact-package virtual-package provider-package exact-package

[[ $(<"$test_tmp/pkg-drop-command") == "pacman -Rns --noconfirm exact-package provider-package" ]] ||
  fail "package removal targets exact installed names only"
pass "package removal ignores providers and duplicate arguments"

run_drop() {
  PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" "$ROOT/bin/omarchy-pkg-drop" "$@"
}
if QUERY_RESULT=1 run_drop exact-package; then
  fail "a failed package query must not report successful removal"
fi
pass "failed queries are not treated as an empty package database"

if REMOVE_RESULT=1 run_drop exact-package; then
  fail "a failed removal must not report success"
fi
pass "removal failures reach callers"

EMPTY_DATABASE=1 run_drop absent-package || fail "an empty database is a successful no-op"
pass "a successfully queried empty database is supported"

# Exercise an actual caller whose next step deletes user configuration.
ln -s "$ROOT/bin/omarchy-pkg-drop" "$mock_path/omarchy-pkg-drop"
mkdir -p "$test_tmp/home/.config/heroic"
touch "$test_tmp/home/.config/heroic/keep-me"
if HOME="$test_tmp/home" QUERY_RESULT=1 PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" \
  bash "$ROOT/bin/omarchy-remove-gaming-heroic"; then
  fail "uninstall must stop after a failed package query"
fi
[[ -f $test_tmp/home/.config/heroic/keep-me ]] || fail "user data survives package query failure"
pass "uninstall callers keep user data when the package database cannot be read"
