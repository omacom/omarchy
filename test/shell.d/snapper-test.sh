#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

template="$ROOT/default/snapper/root"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"
cp "$ROOT/bin/omarchy-cmd-missing" "$fake_bin/"

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

cat >"$fake_bin/findmnt" <<'STUB'
#!/bin/bash
printf 'btrfs\n'
STUB
chmod +x "$fake_bin/findmnt"

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

# A missing snapper binary (aarch64 does not ship it) must skip the step with
# exit 0 instead of failing with 127 and aborting `omarchy apply system`.
skip_bin="$test_tmp/skip-bin"
mkdir -p "$skip_bin" "$test_tmp/skip/etc/snapper/configs"
cp "$fake_bin/systemctl" "$ROOT/bin/omarchy-cmd-missing" "$skip_bin/"
cat >"$skip_bin/findmnt" <<'STUB'
#!/bin/bash
printf 'btrfs\n'
STUB
chmod +x "$skip_bin/findmnt"

: >"$test_tmp/skip-calls.log"
skip_rc=0
TEST_LOG="$test_tmp/skip-calls.log" \
PATH="$skip_bin" \
OMARCHY_SNAPPER_CONFIGURE_TEST=0 \
OMARCHY_PATH="$ROOT" \
OMARCHY_SNAPPER_CONFIG_PATH="$test_tmp/skip/etc/snapper/configs/root" \
OMARCHY_SNAPPER_CONF_PATH="$test_tmp/skip/etc/conf.d/snapper" \
  /bin/bash -euo pipefail "$ROOT/install/config/snapper.sh" >"$test_tmp/skip-out.log" 2>&1 || skip_rc=$?
(( skip_rc == 0 )) || fail "a missing snapper binary exits 0 (got $skip_rc: $(cat "$test_tmp/skip-out.log"))"
grep -F 'snapper is not installed' "$test_tmp/skip-out.log" >/dev/null || fail "a missing snapper binary prints the skip reason"
[[ ! -e $test_tmp/skip/etc/snapper/configs/root ]] || fail "a missing snapper binary writes no config"
(( $(wc -l <"$test_tmp/skip-calls.log") == 0 )) || fail "a missing snapper binary touches no systemd units"
pass "a missing snapper binary skips the step cleanly"

# A non-btrfs root (ext4, xfs) must not install a config that claims btrfs and
# then fail snapper-cleanup.service daily.
ext4_bin="$test_tmp/ext4-bin"
mkdir -p "$ext4_bin" "$test_tmp/ext4/etc/snapper/configs"
cp "$fake_bin/snapper" "$fake_bin/systemctl" "$fake_bin/findmnt" "$ROOT/bin/omarchy-cmd-missing" "$ext4_bin/"
cat >"$ext4_bin/findmnt" <<'STUB'
#!/bin/bash
printf 'ext4\n'
STUB
chmod +x "$ext4_bin/findmnt"

: >"$test_tmp/ext4-calls.log"
ext4_rc=0
TEST_LOG="$test_tmp/ext4-calls.log" \
PATH="$ext4_bin" \
OMARCHY_SNAPPER_CONFIGURE_TEST=0 \
OMARCHY_PATH="$ROOT" \
OMARCHY_SNAPPER_CONFIG_PATH="$test_tmp/ext4/etc/snapper/configs/root" \
OMARCHY_SNAPPER_CONF_PATH="$test_tmp/ext4/etc/conf.d/snapper" \
  /bin/bash -euo pipefail "$ROOT/install/config/snapper.sh" >"$test_tmp/ext4-out.log" 2>&1 || ext4_rc=$?
(( ext4_rc == 0 )) || fail "a non-btrfs root exits 0 (got $ext4_rc: $(cat "$test_tmp/ext4-out.log"))"
grep -F 'not btrfs' "$test_tmp/ext4-out.log" >/dev/null || fail "a non-btrfs root prints the skip reason"
[[ ! -e $test_tmp/ext4/etc/snapper/configs/root ]] || fail "a non-btrfs root writes no config"
(( $(wc -l <"$test_tmp/ext4-calls.log") == 0 )) || fail "a non-btrfs root enables no snapper units"
pass "a non-btrfs root skips the step cleanly"
