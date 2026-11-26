#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

template="$ROOT/default/snapper/root"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
STUB
chmod +x "$fake_bin/snapper"

cat >"$fake_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$TEST_LOG"
STUB
chmod +x "$fake_bin/systemctl"

cat >"$fake_bin/omarchy-boot-backend" <<'STUB'
#!/bin/bash
echo "${BOOT_BACKEND:-limine}"
STUB
chmod +x "$fake_bin/omarchy-boot-backend"

configure() {
  TEST_LOG="$test_tmp/calls.log" \
  PATH="$fake_bin:$PATH" \
  OMARCHY_SNAPPER_CONFIGURE_TEST=1 \
  OMARCHY_PATH="$ROOT" \
  OMARCHY_SNAPPER_CONFIG_PATH="$test_tmp/etc/snapper/configs/root" \
  OMARCHY_SNAPPER_CONF_PATH="$test_tmp/etc/conf.d/snapper" \
    bash -euo pipefail "$ROOT/install/config/snapper.sh" >/dev/null
}

configure

cmp -s "$template" "$test_tmp/etc/snapper/configs/root" || fail "snapshot configure installs the Omarchy Snapper template"
grep -Fx 'SNAPPER_CONFIGS="root"' "$test_tmp/etc/conf.d/snapper" >/dev/null || fail "snapshot configure writes /etc/conf.d/snapper"
grep -Fx 'systemctl disable --now snapper-timeline.timer' "$test_tmp/calls.log" >/dev/null || fail "snapshot configure disables timeline snapshots"
grep -Fx 'systemctl enable --now snapper-cleanup.timer limine-snapper-sync.service' "$test_tmp/calls.log" >/dev/null || fail "snapshot configure enables cleanup and Limine snapshot sync"
pass "snapshot configure normalizes Snapper policy and services"

: >"$test_tmp/calls.log"
BOOT_BACKEND=systemd-boot configure
grep -Fx 'systemctl enable --now snapper-cleanup.timer' "$test_tmp/calls.log" >/dev/null ||
  fail "on systemd-boot, snapshot configure enables cleanup without Limine snapshot sync" "$(cat "$test_tmp/calls.log")"
pass "on systemd-boot, Limine snapshot sync stays off"
