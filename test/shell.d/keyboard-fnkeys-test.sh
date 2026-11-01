#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
modprobe_dir="$test_tmp/modprobe.d"
sys_module="$test_tmp/sys-module"
conf="$modprobe_dir/omarchy-fnkeys.conf"
mkdir -p "$stub_bin" "$modprobe_dir" "$sys_module/hid_asus" "$sys_module/hid_apple/parameters"
printf '3\n' >"$sys_module/hid_apple/parameters/fnmode"

cat >"$stub_bin/omarchy-hw-aarch64-apple" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH

cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo rebuild >>"$TEST_LOG"
[[ -z ${REBUILD_FAILS:-} ]] || echo "mkinitcpio failed for kernel linux"
SH

chmod +x "$stub_bin"/*

fnkeys() {
  OMARCHY_MODPROBE_DIR="$modprobe_dir" OMARCHY_SYS_MODULE="$sys_module" \
    OMARCHY_FNKEYS_REBUILD_PENDING="$test_tmp/rebuild-pending" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash "$ROOT/bin/omarchy-keyboard-fnkeys" "$@"
}

# Omarchy's own earlier file goes; an administrator's own stays and is overridden.
printf 'options hid_apple fnmode=2\n' >"$modprobe_dir/hid_apple.conf"
printf 'options hid_asus fnlock_default=1\n' >"$modprobe_dir/hid_asus.conf"
fnkeys off >/dev/null
[[ ! -e $modprobe_dir/hid_apple.conf && -e $modprobe_dir/hid_asus.conf ]] || fail "fnkeys replaces only Omarchy's earlier files"
grep -qx 'options asus_wmi fnlock_default=0' "$conf" || fail "fnkeys off sets every host-kept Fn-lock" "$(cat "$conf")"
[[ $(<"$sys_module/hid_apple/parameters/fnmode") == "1" ]] || fail "fnkeys switches hid_apple right away"
[[ $(<"$calls") == "rebuild" && $(fnkeys) == "off" ]] || fail "fnkeys off rebuilds the boot image for a loaded keyboard driver" "$(cat "$calls")"
pass "fnkeys off sets every host-kept Fn-lock and rebuilds the boot image"

: >"$calls"
fnkeys off >/dev/null
[[ ! -s $calls ]] || fail "fnkeys rebuilds nothing when nothing changed"
pass "fnkeys rebuilds nothing when nothing changed"

REBUILD_FAILS=1 fnkeys on >/dev/null 2>&1 && fail "fnkeys fails when the boot image is not rebuilt"
: >"$calls"
fnkeys on >/dev/null
[[ $(<"$calls") == "rebuild" && $(fnkeys) == "on" ]] || fail "fnkeys retries a failed rebuild" "$(cat "$calls")"
pass "fnkeys retries a failed rebuild"
