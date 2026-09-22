#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin" "$test_tmp/home"

cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
[[ $* == "-Qem" ]] || exit 99
echo pacman >>"$AUR_TEST_LOG"
exit "${AUR_TEST_PACMAN_STATUS:-0}"
STUB

cat >"$stub_bin/omarchy-pkg-aur-accessible" <<'STUB'
#!/bin/bash
echo accessible >>"$AUR_TEST_LOG"
exit "${AUR_TEST_ACCESSIBLE_STATUS:-0}"
STUB

cat >"$stub_bin/yay" <<'STUB'
#!/bin/bash
printf 'yay %s\n' "$*" >>"$AUR_TEST_LOG"
if (( ${AUR_TEST_YAY_STATUS:-0} != 0 )); then
  echo "AUR transaction failed" >&2
fi
exit "${AUR_TEST_YAY_STATUS:-0}"
STUB
chmod +x "$stub_bin/"*

run_aur_update() {
  : >"$test_tmp/calls"
  HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" \
    PATH="$stub_bin:$PATH" AUR_TEST_LOG="$test_tmp/calls" \
    "$ROOT/bin/omarchy-update-aur-pkgs" >"$test_tmp/out" 2>"$test_tmp/err"
}

AUR_TEST_PACMAN_STATUS=1 run_aur_update || fail "no foreign packages is a successful skip"
[[ $(cat "$test_tmp/calls") == "pacman" ]] || fail "no foreign packages skips AUR probes and updates"
pass "no foreign packages skips the AUR successfully"

AUR_TEST_ACCESSIBLE_STATUS=1 run_aur_update || fail "an unavailable AUR is a successful skip"
! grep -q '^yay ' "$test_tmp/calls" || fail "an unavailable AUR skips yay"
grep -q 'AUR is unavailable' "$test_tmp/out" || fail "an unavailable AUR explains the skip"
pass "an unavailable AUR skips the update with an explanation"

run_aur_update || fail "a successful AUR transaction succeeds"
grep -q '^yay -Sua ' "$test_tmp/calls" || fail "foreign packages are updated with yay"
pass "a successful AUR transaction succeeds"

for status in 1 42 130; do
  if AUR_TEST_YAY_STATUS="$status" run_aur_update; then
    fail "a failed AUR transaction must fail the helper"
  else
    actual=$?
  fi
  (( actual == status )) || fail "the helper preserves yay exit status $status" "got $actual"
  grep -q 'AUR transaction failed' "$test_tmp/err" || fail "the helper preserves yay diagnostics"
  pass "the helper preserves yay exit status $status and diagnostics"
done
