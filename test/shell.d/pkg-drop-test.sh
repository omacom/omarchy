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
  if [[ ${TEST_PACKAGES_EMPTY:-0} == "0" ]]; then
    printf '%s\n' exact-package provider-package
  fi
  exit "${TEST_QUERY_STATUS:-0}"
fi
EOF

cat >"$mock_path/sudo" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TMP/pkg-drop-command"
exit "${TEST_REMOVE_STATUS:-0}"
EOF

chmod +x "$mock_path/pacman" "$mock_path/sudo"

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

# omarchy-pkg-add queues packages when OMARCHY_PKG_DEFER=1 with a queue file,
# skips already-installed queued packages on flush, and folds queued packages
# into the next immediate install.
add_bin="$test_tmp/pkg-add-bin"
mkdir -p "$add_bin"
cat >"$add_bin/pacman" <<'EOF'
#!/bin/bash
if [[ $1 == "-Q" ]]; then
  pkg="${!#}"
  grep -qxF "$pkg" "$TEST_TMP/installed" 2>/dev/null
  exit $?
fi
if [[ $1 == "-S" ]]; then
  printf '%s\n' "$*" >>"$TEST_TMP/pkg-add-calls"
  for arg in "$@"; do
    [[ $arg == -* ]] && continue
    echo "$arg" >>"$TEST_TMP/installed"
  done
  exit 0
fi
EOF
cat >"$add_bin/sudo" <<'EOF'
#!/bin/bash
exec "$@"
EOF
chmod +x "$add_bin/pacman" "$add_bin/sudo"

printf 'already-installed\n' >"$test_tmp/installed"
queue_file="$test_tmp/pkg-queue"
: >"$queue_file"

PATH="$add_bin:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" OMARCHY_PKG_QUEUE_FILE="$queue_file" OMARCHY_PKG_DEFER=1 \
  "$ROOT/bin/omarchy-pkg-add" pkg-a already-installed pkg-b
PATH="$add_bin:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" OMARCHY_PKG_QUEUE_FILE="$queue_file" OMARCHY_PKG_DEFER=1 \
  "$ROOT/bin/omarchy-pkg-add" pkg-b pkg-c
[[ ! -e $test_tmp/pkg-add-calls ]] || fail "deferred pkg-add must not invoke pacman immediately"

PATH="$add_bin:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" OMARCHY_PKG_QUEUE_FILE="$queue_file" \
  "$ROOT/bin/omarchy-pkg-add" pkg-d
[[ $(<"$test_tmp/pkg-add-calls") == "-S --noconfirm --needed -- pkg-a pkg-b pkg-c pkg-d" ]] ||
  fail "immediate pkg-add flushes deduplicated missing queued packages in one transaction" "$(<"$test_tmp/pkg-add-calls")"
[[ ! -s $queue_file ]] || fail "queue file must be empty after flush"
pass "pkg-add batches deferred packages into a single pacman transaction"
