#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
esp="$test_tmp/boot"
config="$esp/limine.conf"
calls="$test_tmp/calls"
old_id=11111111111111111111111111111111
foreign_id=22222222222222222222222222222222
new_id=33333333333333333333333333333333
mkdir -p "$stub_bin" "$esp/$old_id" "$esp/$foreign_id"

cat >"$stub_bin/limine-entry-tool" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALLS"
awk -v marker="machine-id=$2" '
  function flush() { if (block !~ marker) printf "%s", block; block = "" }
  /^[[:space:]]*\/[^/]/ { flush() }
  { block = block $0 "\n" }
  END { flush() }
' "$OMARCHY_LIMINE_CONFIG" >"$OMARCHY_LIMINE_CONFIG.tmp"
mv "$OMARCHY_LIMINE_CONFIG.tmp" "$OMARCHY_LIMINE_CONFIG"
SH
chmod +x "$stub_bin/limine-entry-tool"

cat >"$stub_bin/limine-enroll-config" <<'SH'
#!/bin/bash
echo enroll >>"$CALLS"
SH
chmod +x "$stub_bin/limine-enroll-config"

cat >"$config" <<EOF
/Omarchy
  comment: machine-id=$old_id
  //Linux
    path: boot():/EFI/Linux/omarchy_linux.efi#oldhash
/Other Linux
  comment: machine-id=$foreign_id
  //Linux
    path: boot():/EFI/Linux/other_linux.efi#foreignhash
/Windows Boot Manager
  protocol: efi
  path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
EOF

CALLS="$calls" \
  OMARCHY_LIMINE_ESP_PATH="$esp" \
  OMARCHY_LIMINE_CONFIG="$config" \
  PATH="$stub_bin:$PATH" \
  bash "$ROOT/bin/omarchy-limine-remove-machine-entry" "$old_id"

grep -Fxq -- "--remove-entry $old_id --no-hooks" "$calls" ||
  fail "factory reset does not target only its previous Limine identity"
[[ ! -e $esp/$old_id ]] || fail "factory reset keeps its retired machine-ID directory"
[[ -d $esp/$foreign_id ]] || fail "factory reset deletes another installation's boot directory"
grep -Fq "machine-id=$foreign_id" "$config" || fail "factory reset deletes another Linux boot entry"
grep -Fq '/Windows Boot Manager' "$config" || fail "factory reset deletes the Windows boot entry"
if grep -qE '^/Omarchy$|omarchy_linux\.efi|machine-id=11111111111111111111111111111111' "$config"; then
  fail "the retired boot entry must be absent, not just its machine-ID comment"
fi
pass "factory reset retires only its own Limine identity"

: >"$calls"
if CALLS="$calls" OMARCHY_LIMINE_ESP_PATH="$esp" OMARCHY_LIMINE_CONFIG="$config" \
  PATH="$stub_bin:$PATH" bash "$ROOT/bin/omarchy-limine-remove-machine-entry" '../other' 2>/dev/null; then
  fail "an invalid machine ID reaches destructive cleanup"
fi
[[ -d $esp/$foreign_id ]] || fail "an invalid machine ID removes another installation"
[[ ! -s $calls ]] || fail "an invalid machine ID reaches limine-entry-tool"
pass "machine-ID cleanup rejects paths and malformed identities"

cat >"$config" <<EOF
default_entry: 2
/Windows
  protocol: efi
  path: boot():/EFI/Microsoft/Boot/bootmgfw.efi
/+Other Linux
  comment: machine-id=$foreign_id
  //Linux
    path: boot():/EFI/Linux/other_linux.efi#foreignhash
/+Omarchy
  comment: machine-id=$new_id
  //Linux
    path: boot():/EFI/Linux/omarchy_linux.efi#newhash
EOF

: >"$calls"
CALLS="$calls" \
  OMARCHY_LIMINE_ESP_PATH="$esp" \
  OMARCHY_LIMINE_CONFIG="$config" \
  PATH="$stub_bin:$PATH" \
  bash "$ROOT/bin/omarchy-limine-default-machine-entry" "$new_id"

grep -Fxq 'default_entry: Omarchy/Linux' "$config" ||
  fail "factory reset leaves Limine targeting another OS after entry reordering"
grep -Fxq 'enroll' "$calls" || fail "the updated Limine config is not re-enrolled"
pass "factory reset keeps the rebuilt Omarchy entry as the boot target"

factory_reset=$(<"$ROOT/bin/omarchy-system-factory-reset")
provision_owner=$(<"$ROOT/bin/omarchy-provision-owner")
[[ $factory_reset == *'previous-machine-id'* &&
  $factory_reset == *'omarchy-limine-remove-machine-entry'* &&
  $factory_reset == *'omarchy-limine-default-machine-entry'* ]] ||
  fail "factory-reset staging does not carry its old identity into the fresh root"
[[ $provision_owner == *'previous-machine-id'* && $provision_owner == *'remove_previous_limine_entry'* ]] ||
  fail "first-boot provisioning does not retire the staged identity"
pass "the previous identity survives staging until first-boot cleanup completes"

[[ $factory_reset != *'stage_provisioning_runtime'* &&
  $factory_reset == *'install_provisioning_units "$next" "$unit_src"'* ]] ||
  fail "factory reset mixes a live provisioning worker with frozen snapshot helpers"
pass "factory reset keeps the snapshot provisioning runtime internally consistent"

eval "$(awk '/^verify_limine_hashes\(\) \{/ { copying=1 } copying { print } copying && /^\}$/ { exit }' "$ROOT/bin/omarchy-system-factory-reset")"
mkdir -p "$esp/EFI/Linux"
printf rebuilt >"$esp/EFI/Linux/omarchy_linux.efi"
hash=$(b2sum "$esp/EFI/Linux/omarchy_linux.efi" | cut -d' ' -f1)
sed -i "s/newhash/$hash/; s/foreignhash/deadbeef/" "$config"
verify_limine_hashes "" "$esp" "$new_id"
pass "matching rebuilt hashes pass while unrelated entry hashes are ignored"
sed -i "s/$hash/deadbeef/" "$config"
if (verify_limine_hashes "" "$esp" "$new_id") >"$test_tmp/hash-error" 2>&1; then
  fail "a mismatched rebuilt entry hash must fail verification"
fi
grep -q 'does not match' "$test_tmp/hash-error" || fail "a mismatched hash explains the failure"
pass "a mismatched rebuilt entry hash stops factory reset verification"
