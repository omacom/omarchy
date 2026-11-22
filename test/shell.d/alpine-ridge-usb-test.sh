#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-alpine-ridge-usb.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1792055925.sh"
rule_src="$ROOT/default/udev/macbook-alpine-ridge-usb.rules"
hook_src="$ROOT/default/systemd/system-sleep/macbook-alpine-ridge-usb"

grep -Fq 'apple/fix-alpine-ridge-usb.sh' "$all" ||
  fail "the Alpine Ridge quirk runs during hardware setup"
pass "the Alpine Ridge quirk runs during hardware setup"

grep -Fq 'default/udev/macbook-alpine-ridge-usb.rules' "$leaf" ||
  fail "new installs ship the udev rule"
grep -Fq 'default/systemd/system-sleep/macbook-alpine-ridge-usb' "$leaf" ||
  fail "new installs ship the resume hook"
guard_line=$(grep -n '/run/udev/control' "$leaf" | head -n 1 | cut -d: -f1)
reload_line=$(grep -n 'udevadm control --reload-rules' "$leaf" | head -n 1 | cut -d: -f1)
[[ -n $guard_line && -n $reload_line && $guard_line -lt $reload_line ]] &&
  pass "install reload waits for a running udev" ||
  fail "install reload waits for a running udev"
grep -Fq 'default/udev/macbook-alpine-ridge-usb.rules' "$migration" ||
  fail "existing installs ship the same udev rule"
grep -Fq 'default/systemd/system-sleep/macbook-alpine-ridge-usb' "$migration" ||
  fail "existing installs ship the same resume hook"
pass "new installs and the migration publish the same files"

[[ $(stat -c %a "$migration") == "644" ]] &&
  pass "the migration is not executable" ||
  fail "the migration is not executable"
! head -n 1 "$migration" | grep -q '^#!' ||
  fail "the migration has no shebang"

if udevadm verify --help >/dev/null 2>&1; then
  udevadm verify --no-summary "$rule_src" >/dev/null 2>&1 &&
    pass "udevadm verify accepts the rule" ||
    fail "udevadm verify accepts the rule" "$(udevadm verify --no-summary "$rule_src" 2>&1 || true)"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# A MacBookPro14,1 PCI tree: Alpine Ridge xHCI, the PCH xHCI left alone, the
# Alpine Ridge root hubs (their serial is the PCI slot), and the PCH root hub.
write_tree() {
  local alpine_control="$1" hub_control="$2"
  rm -rf "$tmp/pci" "$tmp/usb"
  mkdir -p "$tmp/pci/0000:07:00.0/power" "$tmp/pci/0000:00:14.0/power" \
    "$tmp/usb/usb4/power" "$tmp/usb/usb1/power" "$tmp/usb/4-1/power"
  echo 0x8086 > "$tmp/pci/0000:07:00.0/vendor"
  echo 0x15d4 > "$tmp/pci/0000:07:00.0/device"
  echo "$alpine_control" > "$tmp/pci/0000:07:00.0/power/control"
  echo 0x8086 > "$tmp/pci/0000:00:14.0/vendor"
  echo 0x9d2f > "$tmp/pci/0000:00:14.0/device"
  echo auto > "$tmp/pci/0000:00:14.0/power/control"
  echo 1d6b > "$tmp/usb/usb4/idVendor"
  echo 0000:07:00.0 > "$tmp/usb/usb4/serial"
  echo "$hub_control" > "$tmp/usb/usb4/power/control"
  echo 1d6b > "$tmp/usb/usb1/idVendor"
  echo 0000:00:14.0 > "$tmp/usb/usb1/serial"
  echo auto > "$tmp/usb/usb1/power/control"
  echo 0781 > "$tmp/usb/4-1/idVendor"
  echo "" > "$tmp/usb/4-1/serial"
  echo auto > "$tmp/usb/4-1/power/control"
}

control() { cat "$1"; }

run_hook() {
  local product="$1" action="$2"
  printf '%s\n' "$product" > "$tmp/product"
  OMARCHY_DMI_PRODUCT_PATH="$tmp/product" \
    OMARCHY_PCI_DEVICES_PATH="$tmp/pci" \
    OMARCHY_USB_DEVICES_PATH="$tmp/usb" \
    bash "$hook_src" "$action"
}

write_tree auto auto
run_hook "MacBookPro14,2" post
[[ $(control "$tmp/pci/0000:07:00.0/power/control") == "auto" && $(control "$tmp/usb/usb4/power/control") == "auto" ]] &&
  pass "other Macs are left asleep" ||
  fail "other Macs are left asleep"

run_hook "MacBookPro14,1" pre
[[ $(control "$tmp/pci/0000:07:00.0/power/control") == "auto" ]] &&
  pass "the hook does nothing before sleep" ||
  fail "the hook does nothing before sleep"

run_hook "MacBookPro14,1" post
[[ $(control "$tmp/pci/0000:07:00.0/power/control") == "on" ]] &&
  pass "the Alpine Ridge controller is kept awake" ||
  fail "the Alpine Ridge controller is kept awake"
[[ $(control "$tmp/usb/usb4/power/control") == "on" ]] &&
  pass "the Alpine Ridge root hub is kept awake" ||
  fail "the Alpine Ridge root hub is kept awake"
[[ $(control "$tmp/pci/0000:00:14.0/power/control") == "auto" && $(control "$tmp/usb/usb1/power/control") == "auto" && $(control "$tmp/usb/4-1/power/control") == "auto" ]] &&
  pass "the PCH xHCI and a plugged device are left alone" ||
  fail "the PCH xHCI and a plugged device are left alone"

stub="$tmp/bin"
mkdir -p "$stub"
call_log="$tmp/calls"
cat > "$stub/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${PRODUCT:-MacBookPro14,1} == "$1" ]]
SH
cat > "$stub/sudo" <<'SH'
#!/bin/bash
printf 'sudo' >>"$CALL_LOG"
printf '\t%s' "$@" >>"$CALL_LOG"
printf '\n' >>"$CALL_LOG"
"$@"
SH
cat > "$stub/udevadm" <<'SH'
#!/bin/bash
printf 'udevadm' >>"$CALL_LOG"
printf '\t%s' "$@" >>"$CALL_LOG"
printf '\n' >>"$CALL_LOG"
[[ ${UDEVADM_FAIL:-0} == 0 ]]
SH
chmod +x "$stub"/*

rules="$tmp/etc/udev/rules.d/71-omarchy-macbook-alpine-ridge-usb.rules"
hook="$tmp/system-sleep/macbook-alpine-ridge-usb"
reload_marker="$tmp/reload-needed"
udev_control="$tmp/udev-control"

run_migration() {
  : > "$call_log"
  PRODUCT="${PRODUCT:-MacBookPro14,1}" CALL_LOG="$call_log" \
    UDEVADM_FAIL="${UDEVADM_FAIL:-0}" PATH="$stub:$PATH" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_ALPINE_RIDGE_USB_RULES="$rules" \
    OMARCHY_ALPINE_RIDGE_USB_HOOK="$hook" \
    OMARCHY_ALPINE_RIDGE_USB_RELOAD_MARKER="$reload_marker" \
    OMARCHY_UDEV_CONTROL="$udev_control" \
    OMARCHY_PCI_DEVICES_PATH="$tmp/pci" \
    OMARCHY_USB_DEVICES_PATH="$tmp/usb" \
    OMARCHY_DMI_PRODUCT_PATH="$tmp/product" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}

printf '%s\n' MacBookPro14,1 > "$tmp/product"
: > "$udev_control"
write_tree auto auto
PRODUCT=MacBookPro14,2 run_migration
[[ ! -e $rules && ! -e $hook && ! -e $reload_marker && ! -s $call_log ]] &&
  pass "the migration leaves other machines alone" ||
  fail "the migration leaves other machines alone"

write_tree auto auto
run_migration
cmp -s "$rule_src" "$rules" &&
  pass "the migration installs the udev rule" ||
  fail "the migration installs the udev rule"
cmp -s "$hook_src" "$hook" &&
  pass "the migration installs the resume hook" ||
  fail "the migration installs the resume hook"
[[ $(stat -c %a "$rules") == "644" && $(stat -c %a "$hook") == "755" ]] &&
  pass "the rule is config and the hook is executable" ||
  fail "the rule is config and the hook is executable"
grep -Fq $'udevadm\tcontrol\t--reload-rules' "$call_log" &&
  pass "a new rule is loaded without a reboot" ||
  fail "a new rule is loaded without a reboot" "$(cat "$call_log")"
[[ ! -e $reload_marker ]] &&
  pass "a successful reload clears its marker" ||
  fail "a successful reload clears its marker"
[[ $(control "$tmp/pci/0000:07:00.0/power/control") == "on" && $(control "$tmp/usb/usb4/power/control") == "on" ]] &&
  pass "the migration wakes a controller that is still suspended" ||
  fail "the migration wakes a controller that is still suspended"
[[ $(control "$tmp/pci/0000:00:14.0/power/control") == "auto" ]] &&
  pass "the migration does not wake the PCH xHCI" ||
  fail "the migration does not wake the PCH xHCI"

run_migration
[[ ! -s $call_log ]] &&
  pass "another user's run is a no-op" ||
  fail "another user's run is a no-op" "$(cat "$call_log")"

echo '# administrator copy' > "$rules"
echo '# administrator hook' > "$hook"
run_migration
grep -Fxq '# administrator copy' "$rules" &&
  pass "an existing rule file is kept" ||
  fail "an existing rule file is kept"
grep -Fxq '# administrator hook' "$hook" &&
  pass "an existing resume hook is kept" ||
  fail "an existing resume hook is kept"

rm -f "$rules" "$hook" "$reload_marker" "$udev_control"
write_tree auto auto
run_migration
[[ ! -e $reload_marker ]] &&
  pass "no running udev still finishes the reload" ||
  fail "no running udev still finishes the reload"
! grep -Fq udevadm "$call_log" &&
  pass "no running udev skips the reload" ||
  fail "no running udev skips the reload" "$(cat "$call_log")"

rm -f "$rules" "$hook" "$reload_marker"
: > "$udev_control"
write_tree auto auto
UDEVADM_FAIL=1
if run_migration; then
  fail "a failed reload stays pending"
else
  pass "a failed reload stays pending"
fi
[[ -e $reload_marker && -f $rules ]] &&
  pass "a failed reload keeps the rule and the marker" ||
  fail "a failed reload keeps the rule and the marker"
UDEVADM_FAIL=0
run_migration
grep -Fq $'udevadm\tcontrol\t--reload-rules' "$call_log" &&
  pass "the next run reloads the rule" ||
  fail "the next run reloads the rule" "$(cat "$call_log")"
[[ ! -e $reload_marker ]] &&
  pass "the retried reload clears the marker" ||
  fail "the retried reload clears the marker"
