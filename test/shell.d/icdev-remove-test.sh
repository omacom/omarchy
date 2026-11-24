#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin"

# mise, docker and gum are stubbed and record how they were called. gum
# answers "no" unless a test says otherwise: one that answered "yes" on its own
# would be the data loss the default-no exists to prevent.
for stub in mise docker gum; do
  cat >"$mock_bin/$stub" <<'SH'
#!/bin/bash
echo "$(basename "$0") $*" >>"$OMARCHY_TEST_CALLS"
case "$(basename "$0") $1" in
  "docker inspect") [[ ${OMARCHY_TEST_CONTAINER:-0} == "1" ]] ;;
  "gum confirm") exit "${OMARCHY_TEST_GUM_STATUS:-1}" ;;
esac
SH
  chmod +x "$mock_bin/$stub"
done

# A fresh home holding what the installer and `icdev omarchy setup` leave: the
# wrapper, here a stub that records its arguments, and ICDEV's settings.
fresh_home() {
  : >"$calls"
  rm -rf "$test_tmp/home"
  mkdir -p "$test_tmp/home/.local/bin" "$test_tmp/home/.config/icdev"
  echo "ICDEV_PG_PASSWORD=x" >"$test_tmp/home/.config/icdev/.env"
  cat >"$test_tmp/home/.local/bin/icdev" <<'SH'
#!/bin/bash
echo "icdev $*" >>"$OMARCHY_TEST_CALLS"
exit "${OMARCHY_TEST_UNINSTALL_STATUS:-0}"
SH
  chmod +x "$test_tmp/home/.local/bin/icdev"
}

remove() {
  HOME="$test_tmp/home" XDG_CONFIG_HOME="" OMARCHY_PATH="$ROOT" OMARCHY_TEST_CALLS="$calls" \
    PATH="$mock_bin:$ROOT/bin:/usr/bin:/bin" "$ROOT/bin/omarchy-remove-ai-icdev" "$@"
}

# script(1) puts the remover on a pty, the only way -t 0 answers true.
remove_on_tty() {
  HOME="$test_tmp/home" XDG_CONFIG_HOME="" OMARCHY_PATH="$ROOT" OMARCHY_TEST_CALLS="$calls" \
    PATH="$mock_bin:$ROOT/bin:/usr/bin:/bin" \
    script -qec "'$ROOT/bin/omarchy-remove-ai-icdev'" /dev/null >"$test_tmp/output" 2>&1
}

fresh_home
OMARCHY_TEST_CONTAINER=1 remove </dev/null >"$test_tmp/output" 2>&1 || fail "removing ICDEV succeeds" "$(cat "$test_tmp/output")"
grep -qx 'icdev omarchy uninstall' "$calls" || fail "setup is undone through icdev omarchy uninstall" "$(cat "$calls")"
grep -qx 'mise uninstall pipx:icdev --all' "$calls" || fail "mise uninstalls ICDEV" "$(cat "$calls")"
grep -qx 'mise rm -g pipx:icdev' "$calls" || fail "ICDEV leaves the global mise config" "$(cat "$calls")"
[[ ! -e $test_tmp/home/.local/bin/icdev ]] || fail "the icdev wrapper is deleted"
(( $(grep -n 'icdev omarchy uninstall' "$calls" | cut -d: -f1) < $(grep -n 'mise uninstall' "$calls" | cut -d: -f1) )) ||
  fail "setup is undone while ICDEV is still installed" "$(cat "$calls")"
pass "a removal undoes setup first, then uninstalls ICDEV and its wrapper"

! grep -q '^gum' "$calls" || fail "without a terminal nothing is asked" "$(cat "$calls")"
! grep -qE '^docker (rm|volume)' "$calls" || fail "without a terminal the database is kept" "$(cat "$calls")"
[[ -f $test_tmp/home/.config/icdev/.env ]] || fail "without a terminal the settings are kept"
grep -q 'docker rm -f icdev-postgres && docker volume rm icdev-postgres-data' "$test_tmp/output" ||
  fail "a kept database says how to delete it" "$(cat "$test_tmp/output")"
grep -q "mise rm -g uv" "$test_tmp/output" || fail "the output says uv was left in place" "$(cat "$test_tmp/output")"
pass "without a terminal the database and settings are kept, and the output says where"

fresh_home
OMARCHY_TEST_UNINSTALL_STATUS=1 remove </dev/null >"$test_tmp/output" 2>&1 && fail "a failed uninstall fails the removal"
grep -q 'ICDEV was not removed' "$test_tmp/output" || fail "a failed uninstall says so" "$(cat "$test_tmp/output")"
[[ -x $test_tmp/home/.local/bin/icdev ]] || fail "a failed uninstall keeps the wrapper, so the removal can run again"
! grep -q '^mise' "$calls" || fail "a failed uninstall leaves ICDEV installed" "$(cat "$calls")"
pass "a failed uninstall stops before anything is deleted"

if ! command -v script >/dev/null 2>&1; then
  skip "the database question (script(1) is not installed)"
  exit 0
fi

fresh_home
OMARCHY_TEST_CONTAINER=1 remove_on_tty || fail "removing ICDEV on a terminal succeeds" "$(cat "$test_tmp/output")"
grep -q '^gum confirm --default=false' "$calls" || fail "the database question defaults to no" "$(cat "$calls")"
! grep -qE '^docker (rm|volume)' "$calls" || fail "answering no keeps the database" "$(cat "$calls")"
[[ -f $test_tmp/home/.config/icdev/.env ]] || fail "answering no keeps the settings"
pass "answering no keeps the database and settings"

fresh_home
OMARCHY_TEST_CONTAINER=1 OMARCHY_TEST_GUM_STATUS=0 remove_on_tty || fail "removing ICDEV and its data succeeds" "$(cat "$test_tmp/output")"
grep -qx 'docker rm -f icdev-postgres' "$calls" || fail "answering yes deletes the container" "$(cat "$calls")"
grep -qx 'docker volume rm icdev-postgres-data' "$calls" || fail "answering yes deletes the volume" "$(cat "$calls")"
[[ ! -e $test_tmp/home/.config/icdev ]] || fail "answering yes deletes the settings"
pass "answering yes deletes the container, its volume and the settings"
