#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/msi-gs65-wifi"
leaf="$ROOT/install/hardware/fix-msi-gs65-wifi.sh"
all="$ROOT/install/hardware/all.sh"

[[ -x $hook ]] ||
  fail "the MSI GS65 Wi-Fi sleep hook is executable" "mode: $(stat -c '%A' "$hook")"
pass "the MSI GS65 Wi-Fi sleep hook is executable"

grep -q 'run_logged .*hardware/fix-msi-gs65-wifi.sh' "$all" ||
  fail "the MSI GS65 Wi-Fi quirk runs during hardware setup"
pass "the MSI GS65 Wi-Fi quirk runs during hardware setup"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
ec_io="$tmpdir/ec_io"
write_log="$tmpdir/writes"
mkdir -p "$mock_bin"

cat >"$mock_bin/modprobe" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/rfkill" <<'SH'
#!/bin/bash
if [[ ${TEST_WIFI_HARD_BLOCKED:-0} == "1" ]]; then
  cat <<'EOF'
1: phy0: Wireless LAN
	Soft blocked: no
	Hard blocked: yes
EOF
else
  cat <<'EOF'
1: phy0: Wireless LAN
	Soft blocked: no
	Hard blocked: no
EOF
fi
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
  OMARCHY_MSI_EC_DELAY=0 \
  OMARCHY_MSI_EC_RETRY_DELAY=0 \
  TEST_WIFI_HARD_BLOCKED=0 \
  "$hook" pre suspend

[[ $(read_ec_hex 0x34) == "30" && $(read_ec_hex 0x2e) == "4b" ]] ||
  fail "pre-suspend sets EC register 0x34 to 0x30 without touching 0x2e" \
    "0x34=$(read_ec_hex 0x34) 0x2e=$(read_ec_hex 0x2e)"
pass "pre-suspend sets EC register 0x34 to 0x30 without touching 0x2e"

# When Wi-Fi wakes hard-blocked with 0x2e bit 3 set (0x4b), the hook clears bit
# 3 (0x43) and sets it back (0x4b) while preserving the remaining bits (0x43).
cat >"$mock_bin/rfkill" <<SH
#!/bin/bash
val=\$(dd if="$ec_io" bs=1 skip=\$((0x2e)) count=1 2>/dev/null | od -A n -t x1 | tr -d " \n")
printf '%s\n' "\$val" >>"$write_log"
if (( \$(wc -l <"$write_log") == 1 )); then
  printf '1: phy0: Wireless LAN\n\tSoft blocked: no\n\tHard blocked: yes\n'
else
  printf '1: phy0: Wireless LAN\n\tSoft blocked: no\n\tHard blocked: no\n'
fi
SH
chmod +x "$mock_bin/rfkill"

init_ec
: >"$write_log"
PATH="$mock_bin:$PATH" \
  OMARCHY_MSI_EC_IO="$ec_io" \
  OMARCHY_MSI_EC_DELAY=0 \
  OMARCHY_MSI_EC_RETRY_DELAY=0 \
  "$hook" post suspend

[[ $(read_ec_hex 0x34) == "30" && $(read_ec_hex 0x2e) == "4b" ]] && (( $(wc -l <"$write_log") == 2 )) ||
  fail "post-resume clears the hard block and preserves non-killswitch bits in 0x2e" \
    "0x34=$(read_ec_hex 0x34) 0x2e=$(read_ec_hex 0x2e)"
pass "post-resume clears the hard block and preserves non-killswitch bits in 0x2e"
