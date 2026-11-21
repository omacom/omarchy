#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/dmi" "$test_tmp/etc"

# Redirect only hardware reads and the installed destination. Execute the real
# leaf and migration, with privilege and reboot-state calls isolated.
sed -e "s|/sys/class/dmi/id|$test_tmp/dmi|g" \
  -e "s|/etc/udev/rules.d|$test_tmp/etc|g" \
  "$ROOT/install/hardware/samsung/fix-950qed-clickpad.sh" > "$test_tmp/leaf.sh"
sed "s|/sys/class/dmi/id|$test_tmp/dmi|g" \
  "$ROOT/bin/omarchy-hw-match" > "$test_tmp/bin/omarchy-hw-match"
sed -e "s|/sys/class/dmi/id|$test_tmp/dmi|g" \
  -e "s|/etc/udev/rules.d|$test_tmp/etc|g" \
  -e "s|\$OMARCHY_PATH/install/hardware/samsung/fix-950qed-clickpad.sh|$test_tmp/leaf.sh|g" \
  "$ROOT/migrations/1791965814.sh" > "$test_tmp/migration.sh"
cat > "$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$TEST_CALLS"
"$@"
SH
cat > "$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >> "$TEST_CALLS"
SH
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" TEST_CALLS="$test_tmp/calls"

run_case() {
  printf '%s\n' "$1" > "$test_tmp/dmi/sys_vendor"
  printf '%s\n' "$2" > "$test_tmp/dmi/product_name"
  printf '%s\n' "${3:-}" > "$test_tmp/dmi/product_family"
  rm -f "$test_tmp/etc/61-znt-clickpad-mouse.rules" "$TEST_CALLS"
  bash -euo pipefail "$test_tmp/migration.sh" >/dev/null
}

run_case "SAMSUNG ELECTRONICS CO., LTD." "950QED"
rule="$test_tmp/etc/61-znt-clickpad-mouse.rules"
cmp -s "$rule" "$ROOT/default/udev/samsung-950qed-clickpad.rules" || fail "950QED gets the rule"
[[ $(stat -c %a "$rule") == "644" ]] || fail "rule is readable at mode 0644"
grep -Fxq 'state set reboot-required' "$TEST_CALLS" || fail "migration requests a reboot"
before=$(sha256sum "$rule")
rm -f "$TEST_CALLS"
bash -euo pipefail "$test_tmp/migration.sh" >/dev/null
[[ $(sha256sum "$rule") == "$before" ]] || fail "repeat migration is idempotent"
[[ ! -e $TEST_CALLS ]] || fail "repeat or second-user migration performs no privileged call or reboot request"
pass "tested Samsung gets the rule and subsequent users require no change or reboot"

rm -f "$rule" "$TEST_CALLS"
bash -euo pipefail "$test_tmp/leaf.sh"
cmp -s "$rule" "$ROOT/default/udev/samsung-950qed-clickpad.rules" || fail "fresh hardware setup installs the same rule"
pass "fresh hardware setup installs the same rule without a migration"

run_case "SAMSUNG ELECTRONICS CO., LTD." "950QED-KH1NL" "950QED"
[[ -f $rule ]] || fail "exact tested family is supported"
pass "exact DMI product family can identify the tested model"

for product in "950QDB" "960QED" "950QED-extra"; do
  run_case "SAMSUNG ELECTRONICS CO., LTD." "$product"
  [[ ! -e $rule && ! -e $TEST_CALLS ]] || fail "untested Samsung $product stays untouched"
done
run_case "Other vendor" "950QED"
[[ ! -e $rule && ! -e $TEST_CALLS ]] || fail "other vendors stay untouched"
rm -f "$test_tmp/dmi/"* "$TEST_CALLS"
bash -euo pipefail "$test_tmp/leaf.sh"
bash -euo pipefail "$test_tmp/migration.sh" >/dev/null
[[ ! -e $rule && ! -e $TEST_CALLS ]] || fail "missing DMI stays untouched"
pass "other models, vendors, and missing DMI never make privileged changes"

run_node_test <<'JS'
const fs = require('fs');
const rule = fs.readFileSync(path.join(root, 'default/udev/samsung-950qed-clickpad.rules'), 'utf8');
const lines = rule.split('\n').filter(line => line && !line.startsWith('#'));
assertEqual(lines.length, 1, 'only one event-device rule is shipped');
const name = lines[0].match(/ATTRS\{name\}=="([^"]+)"/)[1];
assertEqual(name, 'ZNT0001:00 14E5:650E Mouse', 'only the companion Mouse name matches');
assert('ZNT0001:00 14E5:650E Touchpad' !== name, 'the real Touchpad stays available');
assert(lines[0].includes('KERNEL=="event*"'), 'only event nodes are selected');
assert(lines[0].includes('ENV{LIBINPUT_IGNORE_DEVICE}="1"'), 'libinput receives the ignore property');
const all = fs.readFileSync(path.join(root, 'install/hardware/all.sh'), 'utf8');
assert(all.includes('run_logged "$OMARCHY_INSTALL/hardware/samsung/fix-950qed-clickpad.sh"'), 'fresh installs and deferred provisioning include the leaf');
JS
