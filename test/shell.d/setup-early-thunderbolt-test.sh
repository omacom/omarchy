#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-setup-early-thunderbolt"
conf_src="$ROOT/etc/mkinitcpio.conf.d/thunderbolt_module.conf"

[[ -x $script ]] || fail "setup-early-thunderbolt is executable"
grep -qxF 'MODULES+=(thunderbolt)' "$conf_src" ||
  fail "shipped conf still loads thunderbolt by default"
grep -Fq 'omarchy-setup-early-thunderbolt disable' "$conf_src" ||
  fail "shipped conf points at the opt-out command"

pass "default early thunderbolt conf documents the opt-out"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/etc/mkinitcpio.conf.d" "$test_tmp/bin" "$test_tmp/src/etc/mkinitcpio.conf.d"
cp "$conf_src" "$test_tmp/src/etc/mkinitcpio.conf.d/thunderbolt_module.conf"
cp "$conf_src" "$test_tmp/etc/mkinitcpio.conf.d/thunderbolt_module.conf"

cat >"$test_tmp/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
cat >"$test_tmp/bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ $1 == limine-mkinitcpio ]]
STUB
cat >"$test_tmp/bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
printf 'rebuilt\n' >"$TEST_TMP/rebuilt"
exit 0
STUB
chmod +x "$test_tmp/bin"/*

PATH="$test_tmp/bin:$PATH" \
  OMARCHY_PATH="$test_tmp/src" \
  OMARCHY_THUNDERBOLT_MKINITCPIO_CONF="$test_tmp/etc/mkinitcpio.conf.d/thunderbolt_module.conf" \
  TEST_TMP="$test_tmp" \
  bash "$script" disable

[[ ! -e $test_tmp/etc/mkinitcpio.conf.d/thunderbolt_module.conf ]] ||
  fail "disable removes the mkinitcpio drop-in"
[[ -f $test_tmp/rebuilt ]] || fail "disable rebuilds the initramfs"

pass "disable removes early thunderbolt and rebuilds"

rm -f "$test_tmp/rebuilt"
PATH="$test_tmp/bin:$PATH" \
  OMARCHY_PATH="$test_tmp/src" \
  OMARCHY_THUNDERBOLT_MKINITCPIO_CONF="$test_tmp/etc/mkinitcpio.conf.d/thunderbolt_module.conf" \
  TEST_TMP="$test_tmp" \
  bash "$script" enable

[[ -f $test_tmp/etc/mkinitcpio.conf.d/thunderbolt_module.conf ]] ||
  fail "enable restores the mkinitcpio drop-in"
grep -qxF 'MODULES+=(thunderbolt)' "$test_tmp/etc/mkinitcpio.conf.d/thunderbolt_module.conf" ||
  fail "restored conf loads thunderbolt"
[[ -f $test_tmp/rebuilt ]] || fail "enable rebuilds the initramfs"

pass "enable restores early thunderbolt and rebuilds"

if bash "$script" 2>/dev/null; then
  fail "missing action exits nonzero"
fi
pass "missing action is rejected"
