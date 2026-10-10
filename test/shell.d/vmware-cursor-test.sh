#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

all="$ROOT/install/user/all.sh"
grep -q 'run_logged .*user/hardware/fix-vmware-cursor.sh' "$all" ||
  fail "the vmware cursor quirk runs during user hardware setup"
pass "the vmware cursor quirk runs during user hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/home/.config/hypr"
cat >"$test_tmp/bin/lspci" <<'SH'
#!/bin/bash
printf '%s\n' "Kernel driver in use: ${TEST_VIDEO_DRIVER:-vmwgfx}"
SH
chmod +x "$test_tmp/bin/lspci"

looknfeel="$test_tmp/home/.config/hypr/looknfeel.lua"
printf '%s\n' '-- User look and feel' >"$looknfeel"

run_fix() {
  HOME="$test_tmp/home" \
    PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    TEST_VIDEO_DRIVER="${1:-vmwgfx}" \
    bash -euo pipefail -c 'source "$ROOT/install/user/hardware/fix-vmware-cursor.sh"'
}

run_fix >/dev/null
grep -F 'no_hardware_cursors = true' "$looknfeel" >/dev/null
pass "vmware hardware setup enables software cursors"

run_fix >/dev/null
(( $(grep -c 'no_hardware_cursors = true' "$looknfeel") == 1 )) || fail "vmware cursor setup is idempotent"
pass "vmware cursor setup is idempotent"

printf '%s\n' '-- User look and feel' >"$looknfeel"
run_fix i915 >/dev/null
if grep -q 'no_hardware_cursors' "$looknfeel"; then
  fail "vmware cursor setup ignores other video drivers"
fi
pass "vmware cursor setup ignores other video drivers"

printf '%s\n' '-- User look and feel' '-- no_hardware_cursors is mentioned in a comment' >"$looknfeel"
run_fix >/dev/null
grep -F 'no_hardware_cursors = true' "$looknfeel" >/dev/null ||
  fail "a comment mentioning the setting still gets a real assignment"
pass "vmware cursor setup ignores a comment mentioning the setting"

for setting in 'hl.config({ cursor = { no_hardware_cursors = false } })' '  no_hardware_cursors = false,'; do
  printf '%s\n' "$setting" >"$looknfeel"
  run_fix >/dev/null
  [[ $(cat "$looknfeel") == "$setting" ]] || fail "an explicit cursor setting is preserved"
done
pass "one-line and multi-line explicit cursor settings are preserved"

# Existing installations reach the same idempotent repair through migrations.
printf '%s\n' '-- User look and feel' >"$looknfeel"
for attempt in 1 2; do
  HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$ROOT/migrations/1790350466.sh" >/dev/null
done
(( $(grep -c 'no_hardware_cursors = true' "$looknfeel") == 1 )) ||
  fail "migration enables software cursors exactly once"
pass "migration repairs existing VMware configurations idempotently"
