#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-macbookpro11-1-hibernate.sh"
migration="$ROOT/migrations/1791689221.sh"

grep -qx 'run_logged "$OMARCHY_INSTALL/hardware/apple/fix-macbookpro11-1-hibernate.sh"' "$ROOT/install/hardware/all.sh" ||
  fail "hardware setup runs the MacBookPro11,1 hibernate fix"
pass "hardware setup runs the MacBookPro11,1 hibernate fix"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
conf="$test_tmp/root/etc/systemd/sleep.conf.d/hibernatemode.conf"
mkdir -p "$stub_bin"

# Run the privileged command against a scratch root rather than the real /etc.
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$TEST_LOG"
args=()
for arg in "$@"; do
  [[ $arg == /etc/* ]] && arg="$FAKE_ROOT$arg"
  args+=("$arg")
done
"${args[@]}"
SH

# Matches the way the real helper does, so a looser gate shows.
cat >"$stub_bin/omarchy-hw-match" <<'SH'
#!/bin/bash

grep -qi -- "$1" <<<"$PRODUCT_NAME"
SH

chmod +x "$stub_bin"/*

run() {
  local script="$1" product="$2" keep="${3:-0}"
  (( keep )) || rm -rf "$test_tmp/root"
  : >"$calls"

  OMARCHY_PATH="$ROOT" PRODUCT_NAME="$product" FAKE_ROOT="$test_tmp/root" \
    OMARCHY_HIBERNATE_MODE_CONF="$conf" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -euo pipefail "$script" </dev/null >/dev/null
}

run "$leaf" "MacBookPro11,1"
grep -qx 'HibernateMode=shutdown' "$conf" 2>/dev/null ||
  fail "MacBookPro11,1 hibernates in shutdown mode"
grep -qx '\[Sleep\]' "$conf" ||
  fail "the drop-in sets HibernateMode in the Sleep section" "$(cat "$conf")"
pass "MacBookPro11,1 hibernates in shutdown mode"

for product in "MacBookPro11,5" "MacBookPro11,10"; do
  run "$leaf" "$product"
  [[ ! -e $conf && ! -s $calls ]] ||
    fail "$product keeps the default hibernate mode" "$(cat "$calls")"
done
pass "other Macs keep the default hibernate mode"

run "$migration" "MacBookPro11,1"
grep -qx 'HibernateMode=shutdown' "$conf" 2>/dev/null ||
  fail "the migration switches an existing MacBookPro11,1 to shutdown mode"
pass "the migration switches an existing MacBookPro11,1 to shutdown mode"

run "$migration" "MacBookPro11,1" 1
[[ ! -s $calls ]] || fail "a second run of the migration escalates nothing" "$(cat "$calls")"
pass "a second run of the migration escalates nothing"

printf '[Sleep]\nHibernateMode=shutdown\nHibernateMode=platform\n' >"$conf"
run "$migration" "MacBookPro11,1" 1
[[ $(<"$conf") == $'[Sleep]\nHibernateMode=shutdown' ]] ||
  fail "the migration repairs a drop-in that does not end in shutdown mode" "$(cat "$conf")"
pass "the migration repairs a drop-in that does not end in shutdown mode"

run "$migration" "MacBookPro11,5"
[[ ! -e $conf && ! -s $calls ]] ||
  fail "the migration leaves other machines alone" "$(cat "$calls")"
pass "the migration leaves other machines alone"
