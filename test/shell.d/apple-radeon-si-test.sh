#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-radeon-si.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1789165591.sh"

grep -Fq 'apple/fix-radeon-si.sh' "$all" ||
  fail "the radeon SI quirk runs during hardware setup"
pass "the radeon SI quirk runs during hardware setup"

grep -Fq 'fix-radeon-si.sh' "$migration" ||
  fail "the migration applies the radeon SI quirk" "$migration"
pass "the migration applies the radeon SI quirk"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
limine_dir="$test_tmp/etc/limine-entry-tool.d"
conf="$limine_dir/radeon-si.conf"
dmi_product="$test_tmp/dmi/product_name"
mkdir -p "$stub_bin" "$test_tmp/dmi" "$limine_dir"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash

[[ $1 == limine-mkinitcpio ]] && (( ${LIMINE_MKINITCPIO:-1} == 1 ))
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash

echo 'limine-mkinitcpio' >>"$TEST_LOG"
SH

cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash

printf 'omarchy-state' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local product="$1" keep="${2:-0}"
  if (( keep == 0 )); then
    rm -rf "$test_tmp/etc"
    mkdir -p "$limine_dir"
  fi
  printf '%s' "$product" >"$dmi_product"
  : >"$calls"

  OMARCHY_DMI_PRODUCT="$dmi_product" \
    OMARCHY_LIMINE_ENTRY_TOOL_D="$limine_dir" \
    PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -eE -o pipefail -c 'source "$1"' bash "$leaf" </dev/null
}

run_leaf "MacBookPro11,5" >/dev/null
[[ -f $conf ]] || fail "an 11,5 gets the SI arbitration drop-in"
grep -Fq 'radeon.si_support=1 amdgpu.si_support=0' "$conf" ||
  fail "the drop-in pins SI to radeon" "$(cat "$conf")"
pass "an 11,5 gets the SI arbitration drop-in"

printf 'custom\n' >"$conf"
run_leaf "MacBookPro11,5" 1 >/dev/null
[[ $(<"$conf") == "custom" ]] || fail "an existing drop-in is not overwritten"
pass "an existing drop-in is left in place"

run_leaf "MacBookPro14,3" >/dev/null
[[ ! -e $conf ]] || fail "other Macs are left alone"
[[ ! -s $calls ]] || fail "other Macs escalate nothing" "$(cat "$calls")"
pass "other Macs are left alone"

run_leaf "ThinkPad X1" >/dev/null
[[ ! -e $conf ]] || fail "non-Apple hardware is left alone"
[[ ! -s $calls ]] || fail "non-Apple hardware escalates nothing" "$(cat "$calls")"
pass "non-Apple hardware is left alone"

run_migration() {
  local product="$1"
  printf '%s' "$product" >"$dmi_product"
  : >"$calls"

  OMARCHY_PATH="$ROOT" \
    OMARCHY_DMI_PRODUCT="$dmi_product" \
    OMARCHY_LIMINE_ENTRY_TOOL_D="$limine_dir" \
    LIMINE_MKINITCPIO="${LIMINE_MKINITCPIO:-1}" \
    PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -euo pipefail "$migration" >/dev/null
}

rm -rf "$test_tmp/etc"
mkdir -p "$limine_dir"
run_migration "MacBookPro11,5"
[[ -f $conf ]] || fail "the migration writes the drop-in on an 11,5"
grep -Fxq 'limine-mkinitcpio' "$calls" ||
  fail "the migration rebuilds the boot image when it changed the drop-in" "$(cat "$calls")"
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the migration asks for the reboot that applies it" "$(cat "$calls")"
pass "the migration installs and rebuilds on an 11,5"

: >"$calls"
run_migration "MacBookPro11,5"
[[ ! -s $calls ]] || fail "a second run touches nothing" "$(cat "$calls")"
pass "the migration is idempotent"

run_migration "MacBookPro14,3"
[[ ! -s $calls ]] || fail "the migration leaves other hardware alone" "$(cat "$calls")"
pass "the migration leaves other hardware alone"
