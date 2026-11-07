#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/msi-gs65-wifi"

[[ -x $hook ]] ||
  fail "the MSI GS65 Wi-Fi sleep hook is executable" "mode: $(stat -c '%A' "$hook")"
pass "the MSI GS65 Wi-Fi sleep hook is executable"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
ec_io="$tmpdir/ec_io"
sleep_log="$tmpdir/sleeps"
modprobe_log="$tmpdir/modprobe"
mkdir -p "$mock_bin"

cat >"$mock_bin/modprobe" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"$modprobe_log"
SH

chmod +x "$mock_bin"/*

init_ec() {
  dd if=/dev/zero of="$ec_io" bs=1 count=256 2>/dev/null
  printf '\x4b' | dd of="$ec_io" bs=1 seek=$((0x2e)) conv=notrunc 2>/dev/null
  printf '\x50' | dd of="$ec_io" bs=1 seek=$((0x34)) conv=notrunc 2>/dev/null
}

read_ec_hex() {
  dd if="$ec_io" bs=1 skip=$(($1)) count=1 2>/dev/null | od -A n -t x1 | tr -d " \n"
}

init_ec
PATH="$mock_bin:$PATH" \
  OMARCHY_MSI_EC_IO="$ec_io" \
  OMARCHY_MSI_EC_SYS_MODULE="$tmpdir/no-module" \
  "$hook" pre suspend

[[ $(read_ec_hex 0x34) == "30" && $(read_ec_hex 0x2e) == "4b" ]] ||
  fail "pre-suspend sets EC register 0x34 to 0x30 without touching 0x2e" \
    "0x34=$(read_ec_hex 0x34) 0x2e=$(read_ec_hex 0x2e)"
pass "pre-suspend sets EC register 0x34 to 0x30 without touching 0x2e"

# An ec_sys already loaded writable (fan tools load it at boot) is used but not unloaded.
mkdir -p "$tmpdir/module/parameters"
echo Y >"$tmpdir/module/parameters/write_support"
init_ec
: >"$modprobe_log"
PATH="$mock_bin:$PATH" \
  OMARCHY_MSI_EC_IO="$ec_io" \
  OMARCHY_MSI_EC_SYS_MODULE="$tmpdir/module" \
  "$hook" pre suspend

[[ $(read_ec_hex 0x34) == "30" && ! -s $modprobe_log ]] ||
  fail "an ec_sys loaded by someone else is used and left loaded" "modprobe: $(paste -sd ' ' "$modprobe_log")"
pass "an ec_sys loaded by someone else is used and left loaded"

# Wi-Fi wakes hard-blocked with 0x2e bit 3 set (0x4b): bit 3 must read clear
# (0x43) during the toggle delay and set again (0x4b) after, other bits kept.
cat >"$mock_bin/sleep" <<SH
#!/bin/bash
dd if="$ec_io" bs=1 skip=\$((0x2e)) count=1 2>/dev/null | od -A n -t x1 | tr -d " \n" >>"$sleep_log"
echo >>"$sleep_log"
SH

cat >"$mock_bin/rfkill" <<SH
#!/bin/bash
if grep -qx 43 "$sleep_log" && [[ \$(dd if="$ec_io" bs=1 skip=\$((0x2e)) count=1 2>/dev/null | od -A n -t x1 | tr -d " \n") == "4b" ]]; then
  blocked=no
else
  blocked=yes
fi
printf '1: phy0: Wireless LAN\n\tSoft blocked: no\n\tHard blocked: %s\n' "\$blocked"
SH
chmod +x "$mock_bin"/*

init_ec
: >"$sleep_log"
PATH="$mock_bin:$PATH" \
  OMARCHY_MSI_EC_IO="$ec_io" \
  OMARCHY_MSI_EC_SYS_MODULE="$tmpdir/no-module" \
  "$hook" post suspend

[[ $(read_ec_hex 0x34) == "30" && $(paste -sd ' ' "$sleep_log") == "43 4b" ]] ||
  fail "post-resume toggles 0x2e bit 3 off and on, keeping the other bits" \
    "0x34=$(read_ec_hex 0x34) 0x2e during sleeps: $(paste -sd ' ' "$sleep_log")"
pass "post-resume toggles 0x2e bit 3 off and on, keeping the other bits"
