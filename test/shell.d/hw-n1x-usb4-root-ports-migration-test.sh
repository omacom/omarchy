#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export CALL_LOG="$tmp_dir/calls"
real_udevadm=$(command -v udevadm || true)
export PATH="$tmp_dir/bin:$PATH"

printf '#!/bin/bash\necho "udevadm $*" >> "$CALL_LOG"\n' > "$tmp_dir/bin/udevadm"
cat > "$tmp_dir/bin/omarchy-hw-aarch64-n1x" <<'SH'
#!/bin/bash
[[ ${IS_N1X:-1} == 1 ]]
SH
cat > "$tmp_dir/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${PRODUCT:-H7407BA} == *"$1"* ]]
SH
cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
chmod +x "$tmp_dir/bin/"*

migration="$ROOT/migrations/1791134093.sh"
rules="$tmp_dir/etc/udev/rules.d/71-omarchy-n1x-usb4-root-ports.rules"

# A ProArt's PCI tree: the three tunnel root ports, plus the NVMe root port,
# which has to be left alone.
write_ports() {
  rm -rf "$tmp_dir/pci"
  local slot spec
  for spec in "000b:00:00.0 0x22cf $1" "000c:00:00.0 0x22cf $1" "000d:00:00.0 0x22cf $1" "0002:00:00.0 0x22ce auto"; do
    read -r slot device control <<<"$spec"
    mkdir -p "$tmp_dir/pci/$slot/power"
    echo 0x10de > "$tmp_dir/pci/$slot/vendor"
    echo "$device" > "$tmp_dir/pci/$slot/device"
    echo "$control" > "$tmp_dir/pci/$slot/power/control"
  done
}

run_migration() {
  : > "$CALL_LOG"
  OMARCHY_N1X_USB4_ROOT_PORT_RULES="$rules" OMARCHY_PCI_DEVICES_PATH="$tmp_dir/pci" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}

write_ports auto
IS_N1X=0 run_migration
[[ ! -e $rules && ! -s $CALL_LOG ]] && pass "other machines are left alone" || fail "other machines are left alone"

PRODUCT=DX16263 run_migration
[[ ! -e $rules && ! -s $CALL_LOG ]] && pass "N1x machines without USB4 set up are left alone" || fail "N1x machines without USB4 set up are left alone"

run_migration
grep -Fxq 'ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{device}=="0x22cf", ATTR{power/control}="on"' "$rules" &&
  pass "the ProArt keeps its tunnel root ports in D0" || fail "the ProArt keeps its tunnel root ports in D0"
[[ $(stat -c %a "$rules") == "644" ]] && pass "the rule is world-readable, root-writable" || fail "the rule is world-readable, root-writable"
grep -Fxq 'udevadm trigger --action=add --subsystem-match=pci --attr-match=vendor=0x10de --attr-match=device=0x22cf' "$CALL_LOG" &&
  pass "the running system gets the rule without a reboot" || fail "the running system gets the rule without a reboot"
(( $(grep -c 'udevadm trigger' "$CALL_LOG") == 1 )) && pass "one trigger covers all three ports" || fail "one trigger covers all three ports"

write_ports on
run_migration
[[ ! -s $CALL_LOG ]] && pass "another user's run is a no-op" || fail "another user's run is a no-op"

echo '# administrator copy' > "$rules"
write_ports auto
run_migration
grep -Fxq '# administrator copy' "$rules" && pass "an existing rule file is kept" || fail "an existing rule file is kept"

# n1x.sh writes the same rule for new installs, inside the ProArt-only USB4
# block, so the two cannot drift apart.
n1x="$ROOT/install/hardware/n1x.sh"
rule_from() { sed -n "/$2/,/^ *$3\$/p" "$1" | sed '1d;$d;s/^ *//'; }
n1x_rule=$(rule_from "$n1x" '71-omarchy-n1x-usb4-root-ports.rules <<' RULES)
if [[ -n $n1x_rule && $n1x_rule == "$(rule_from "$migration" '"$rules" <<' EOF)" ]]; then
  pass "new installs and the migration write the same rule"
else
  fail "new installs and the migration write the same rule"
fi
usb4_block=$(sed -n '/^if omarchy-hw-match "H7407BA"; then$/,/^fi$/p' "$n1x")
[[ $usb4_block == *71-omarchy-n1x-usb4-root-ports.rules* ]] && pass "new installs only get the rule where USB4 is set up" || fail "new installs only get the rule where USB4 is set up"

if [[ -n $real_udevadm ]] && "$real_udevadm" verify --help >/dev/null 2>&1; then
  printf '%s\n' "$n1x_rule" > "$tmp_dir/71-omarchy-n1x-usb4-root-ports.rules"
  "$real_udevadm" verify --no-summary "$tmp_dir/71-omarchy-n1x-usb4-root-ports.rules" >/dev/null 2>&1 &&
    pass "udevadm verify accepts the rule" || fail "udevadm verify accepts the rule"
fi
