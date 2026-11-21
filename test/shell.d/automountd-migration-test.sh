#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

migration="$ROOT/migrations/1792376022.sh"
mock_bin="$test_tmp/bin"
export TEST_LOG="$test_tmp/log"
mkdir -p "$mock_bin"

for command in omarchy-pkg-add omarchy-pkg-drop pkill systemctl; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
echo "${0##*/} $*" >>"$TEST_LOG"
case "$*" in
  'automountd') [[ ${TEST_ADD_FAIL:-0} == 0 ]] ;;
  '--user enable automountd.service' | '--user is-active --quiet graphical-session.target') [[ ${TEST_TTY:-0} == 0 ]] ;;
  '-x udiskie') [[ ${TEST_UDISKIE:-1} == 1 ]] ;;
  *) exit 0 ;;
esac
SH
done
chmod +x "$mock_bin"/*

migrate() {
  : >"$TEST_LOG"
  HOME="$test_tmp/home" PATH="$mock_bin:$PATH" bash -euo pipefail "$migration" >"$test_tmp/output" 2>&1
}

logged() {
  grep -Fx -- "$1" "$TEST_LOG" >/dev/null
}

migrate || fail "migrating in a graphical session succeeds" "$(cat "$test_tmp/output")"
logged "omarchy-pkg-add automountd" || fail "automountd is installed" "$(cat "$TEST_LOG")"
logged "systemctl --user enable automountd.service" || fail "automountd is enabled" "$(cat "$TEST_LOG")"
logged "omarchy-pkg-drop udiskie" || fail "udiskie is removed" "$(cat "$TEST_LOG")"
[[ $(grep -n -e '^pkill -x udiskie$' -e '^systemctl --user start automountd.service$' "$TEST_LOG" | cut -d: -f2-) == $'pkill -x udiskie\nsystemctl --user start automountd.service' ]] ||
  fail "the session's udiskie stops before automountd starts, so they never race" "$(cat "$TEST_LOG")"
pass "a graphical session swaps udiskie for automountd right away"

TEST_UDISKIE=0 migrate || fail "a session without udiskie running still migrates" "$(cat "$test_tmp/output")"
migrate || fail "the migration can run twice" "$(cat "$test_tmp/output")"
pass "the migration is idempotent and tolerates udiskie not running"

rm -rf "$test_tmp/home"
TEST_TTY=1 migrate || fail "migrating from a TTY succeeds" "$(cat "$test_tmp/output")"
[[ $(readlink "$test_tmp/home/.config/systemd/user/graphical-session.target.wants/automountd.service") == /usr/lib/systemd/user/automountd.service ]] ||
  fail "a TTY update enables automountd for the next login"
logged "systemctl --user start automountd.service" && fail "a TTY update starts automountd with no session" "$(cat "$TEST_LOG")"
pass "a TTY update enables automountd for the next login without starting it"

TEST_ADD_FAIL=1 migrate && fail "a failed install leaves the migration pending"
logged "omarchy-pkg-drop udiskie" && fail "a failed install keeps udiskie" "$(cat "$TEST_LOG")"
pass "a failed install keeps udiskie and leaves the migration pending"

grep -F 'automountd.service' "$ROOT/install/user/first-run/enable-user-units.sh" >/dev/null ||
  fail "fresh installs do not enable automountd"
grep -F 'udiskie' "$ROOT/default/hypr/autostart.lua" "$ROOT/install/omarchy-base.packages" &&
  fail "udiskie still starts or installs alongside automountd"
pass "fresh installs enable automountd instead of starting udiskie"
