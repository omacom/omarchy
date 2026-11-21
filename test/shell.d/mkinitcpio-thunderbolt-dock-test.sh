#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_hook="$ROOT/etc/initcpio/install/omarchy-thunderbolt-dock"
runtime_hook="$ROOT/etc/initcpio/hooks/omarchy-thunderbolt-dock"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# --- Install hook tests ---

write_boltd_entry() {
  local dir="$1" name="$2"
  mkdir -p "$dir"
  cat >"$dir/$name"
}

run_install_hook() {
  local case_dir="$1" boltd_dir="$2" systemd_mode="${3:-0}"
  rm -rf "$case_dir"
  mkdir -p "$case_dir/buildroot"
  : >"$case_dir/modules.log"
  : >"$case_dir/files.log"
  : >"$case_dir/runscript.log"

  OMARCHY_BOLTD_DEVICES_DIR="$boltd_dir" CASE_DIR="$case_dir" SYSTEMD_MODE="$systemd_mode" \
    "$BASH" -c '
      set -euo pipefail
      add_module() { printf "%s\n" "$1" >>"$CASE_DIR/modules.log"; }
      add_file() {
        local src="$1" dest="$2" mode="${3:-}"
        printf "%s %s\n" "$dest" "$mode" >>"$CASE_DIR/files.log"
        mkdir -p "$CASE_DIR/buildroot$(dirname -- "$dest")"
        if [[ $src == "-" ]]; then
          cat >"$CASE_DIR/buildroot$dest"
        else
          cp "$src" "$CASE_DIR/buildroot$dest"
        fi
        if [[ -n $mode ]]; then
          chmod "$mode" "$CASE_DIR/buildroot$dest"
        fi
      }
      add_runscript() { printf "runscript\n" >>"$CASE_DIR/runscript.log"; }
      if (( SYSTEMD_MODE )); then
        add_systemd_unit() { :; }
      fi
      source "$1"
      build
    ' -- "$install_hook"
}

# 1. Missing boltd store is a complete no-op.
run_install_hook "$test_tmp/missing" "$test_tmp/does-not-exist"
[[ ! -s $test_tmp/missing/modules.log && ! -s $test_tmp/missing/files.log && ! -s $test_tmp/missing/runscript.log ]] ||
  fail "missing boltd devices dir is a no-op" "unexpected artifacts written"
pass "missing boltd devices dir is a no-op"

# 2. Empty boltd store is a complete no-op.
mkdir -p "$test_tmp/boltd-empty"
run_install_hook "$test_tmp/empty" "$test_tmp/boltd-empty"
[[ ! -s $test_tmp/empty/modules.log && ! -s $test_tmp/empty/files.log && ! -s $test_tmp/empty/runscript.log ]] ||
  fail "empty boltd devices dir is a no-op" "unexpected artifacts written"
pass "empty boltd devices dir is a no-op"

# 3. Non-qualifying entries (host, manual, default, swapped sections, bad name, symlink) stay out.
boltd_untrusted="$test_tmp/boltd-untrusted"
write_boltd_entry "$boltd_untrusted" "c7030000-0080-6f08-238a-74100804b120" <<'EOF'
[device]
name=Host Controller
type=host

[user]
policy=auto
EOF
write_boltd_entry "$boltd_untrusted" "11111111-1111-1111-1111-111111111111" <<'EOF'
[device]
type=peripheral

[user]
policy=manual
EOF
write_boltd_entry "$boltd_untrusted" "22222222-2222-2222-2222-222222222222" <<'EOF'
[device]
type=peripheral

[user]
policy=default
EOF
write_boltd_entry "$boltd_untrusted" "33333333-3333-3333-3333-333333333333" <<'EOF'
[device]
policy=auto

[user]
type=peripheral
EOF
write_boltd_entry "$boltd_untrusted" "not-a-valid-uuid" <<'EOF'
[device]
type=peripheral

[user]
policy=auto
EOF
write_boltd_entry "$test_tmp/outside" "target-dock" <<'EOF'
[device]
type=peripheral

[user]
policy=auto
EOF
ln -s "$test_tmp/outside/target-dock" "$boltd_untrusted/44444444-4444-4444-4444-444444444444"

run_install_hook "$test_tmp/untrusted" "$boltd_untrusted"
[[ ! -s $test_tmp/untrusted/modules.log && ! -s $test_tmp/untrusted/files.log && ! -s $test_tmp/untrusted/runscript.log ]] ||
  fail "host, manual, default, swapped-section, bad-name, and symlinked entries are ignored" \
    "modules=$(<"$test_tmp/untrusted/modules.log") files=$(<"$test_tmp/untrusted/files.log")"
pass "host, manual, default, swapped-section, bad-name, and symlinked entries are ignored"

# 4. Busybox initramfs with enrolled policy=auto peripherals (mixed with untrusted entries,
# uppercase hex, CRLF line endings, whitespace around '=').
boltd_mixed="$test_tmp/boltd-mixed"
cp -a "$boltd_untrusted" "$boltd_mixed"
printf '[device]\r\nname = ThinkPad Dock\r\ntype = peripheral\r\n\r\n[user]\r\npolicy = auto\r\n' \
  >"$boltd_mixed/0071F980-902A-F000-FFFF-FFFFFFFFFFFF"
write_boltd_entry "$boltd_mixed" "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" <<'EOF'
# comment
[device]
type=peripheral

[user]
policy=auto
EOF

run_install_hook "$test_tmp/busybox" "$boltd_mixed" 0

expected_modules=$(printf '%s\n' \
  thunderbolt? xhci_pci? xhci_pci_renesas? xhci_hcd? \
  usbhid? hid_generic? hid_logitech_dj? hid_logitech_hidpp? hid_apple?)
actual_modules=$(<"$test_tmp/busybox/modules.log")
[[ $actual_modules == "$expected_modules" ]] ||
  fail "install hook adds optional dock USB/HID modules" "expected:"$'\n'"$expected_modules"$'\n'"actual:"$'\n'"$actual_modules"
pass "install hook adds optional dock USB/HID modules"

rules_file="$test_tmp/busybox/buildroot/usr/lib/udev/rules.d/99-omarchy-thunderbolt-dock.rules"
uuids_file="$test_tmp/busybox/buildroot/etc/omarchy-thunderbolt-dock.uuids"
[[ -f $rules_file && -f $uuids_file ]] ||
  fail "busybox build writes udev rule and allowlist" "files=$(<"$test_tmp/busybox/files.log")"

expected_uuids=$(printf '%s\n' \
  "0071f980-902a-f000-ffff-ffffffffffff" \
  "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
actual_uuids=$(<"$uuids_file")
[[ $actual_uuids == "$expected_uuids" ]] ||
  fail "allowlist contains only normalized policy=auto peripheral UUIDs" \
    "expected:"$'\n'"$expected_uuids"$'\n'"actual:"$'\n'"$actual_uuids"
pass "allowlist contains only normalized policy=auto peripheral UUIDs"

actual_rules=$(grep -v '^#' "$rules_file")
expected_rules=$(printf '%s\n' \
  'ACTION=="add|change", SUBSYSTEM=="thunderbolt", ATTR{unique_id}=="0071f980-902a-f000-ffff-ffffffffffff", ATTR{authorized}=="0", ATTR{authorized}="1"' \
  'ACTION=="add|change", SUBSYSTEM=="thunderbolt", ATTR{unique_id}=="aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee", ATTR{authorized}=="0", ATTR{authorized}="1"')
[[ $actual_rules == "$expected_rules" ]] ||
  fail "udev rule matches only trusted UUIDs and assigns ATTR{authorized}=\"1\"" \
    "expected:"$'\n'"$expected_rules"$'\n'"actual:"$'\n'"$actual_rules"
pass "udev rule matches only trusted UUIDs and assigns ATTR{authorized}=\"1\""

[[ $(<"$test_tmp/busybox/runscript.log") == "runscript" ]] ||
  fail "busybox build registers runscript" "runscript.log=$(<"$test_tmp/busybox/runscript.log")"
pass "busybox build registers runscript"

# 5. Case-variant duplicate UUIDs are deduplicated.
boltd_dup="$test_tmp/boltd-dup"
write_boltd_entry "$boltd_dup" "ABCDEF01-2345-6789-ABCD-EF0123456789" <<'EOF'
[device]
type=peripheral
[user]
policy=auto
EOF
write_boltd_entry "$boltd_dup" "abcdef01-2345-6789-abcd-ef0123456789" <<'EOF'
[device]
type=peripheral
[user]
policy=auto
EOF
run_install_hook "$test_tmp/dup" "$boltd_dup" 0
dup_uuids=$(<"$test_tmp/dup/buildroot/etc/omarchy-thunderbolt-dock.uuids")
[[ $dup_uuids == "abcdef01-2345-6789-abcd-ef0123456789" ]] ||
  fail "case-variant duplicate UUIDs are deduplicated" "actual: $dup_uuids"
pass "case-variant duplicate UUIDs are deduplicated"

# 6. Systemd initramfs skips the busybox runscript and allowlist, keeping modules + udev rule.
run_install_hook "$test_tmp/systemd" "$boltd_mixed" 1
[[ -s $test_tmp/systemd/modules.log ]] || fail "systemd build adds dock modules" "no modules added"
[[ -f $test_tmp/systemd/buildroot/usr/lib/udev/rules.d/99-omarchy-thunderbolt-dock.rules ]] ||
  fail "systemd build installs udev rule" "rule missing"
[[ ! -e $test_tmp/systemd/buildroot/etc/omarchy-thunderbolt-dock.uuids ]] ||
  fail "systemd build omits busybox allowlist" "allowlist unexpectedly created"
[[ ! -s $test_tmp/systemd/runscript.log ]] ||
  fail "systemd build skips busybox add_runscript" "runscript unexpectedly registered"
pass "systemd initramfs installs modules and udev rule without busybox runscript"

# 7. Real mkinitcpio add_file integration (streaming via add_file - <dest> 644).
if [[ -r /usr/lib/initcpio/functions ]]; then
  real_br="$test_tmp/real-buildroot"
  mkdir -p "$real_br"
  OMARCHY_BOLTD_DEVICES_DIR="$boltd_dup" BUILDROOT="$real_br" \
    "$BASH" -c '
      set -eo pipefail
      _optquiet=1
      source /usr/lib/initcpio/functions
      add_module() { :; }
      add_runscript() { :; }
      source "$1"
      build
    ' -- "$install_hook"
  real_rule="$real_br/usr/lib/udev/rules.d/99-omarchy-thunderbolt-dock.rules"
  real_list="$real_br/etc/omarchy-thunderbolt-dock.uuids"
  [[ -f $real_rule && -f $real_list ]] ||
    fail "real mkinitcpio add_file streams rule and allowlist into BUILDROOT" "missing output file"
  [[ $(stat -c '%a' "$real_rule") == "644" && $(stat -c '%a' "$real_list") == "644" ]] ||
    fail "real mkinitcpio add_file sets 0644 permissions" \
      "modes: $(stat -c '%a' "$real_rule") $(stat -c '%a' "$real_list")"
  grep -Fq 'ATTR{unique_id}=="abcdef01-2345-6789-abcd-ef0123456789", ATTR{authorized}=="0", ATTR{authorized}="1"' "$real_rule" ||
    fail "real mkinitcpio add_file writes expected udev rule" "content: $(<"$real_rule")"
  pass "real mkinitcpio add_file streams rule and allowlist with mode 644"
fi

# 8. Root ignores OMARCHY_BOLTD_DEVICES_DIR override.
if unshare --user --map-root-user true 2>/dev/null; then
  boltd_injected="$test_tmp/boltd-injected"
  write_boltd_entry "$boltd_injected" "deadbeef-dead-beef-dead-beefdeadbeef" <<'EOF'
[device]
type=peripheral
[user]
policy=auto
EOF
  mkdir -p "$test_tmp/root-check/buildroot"
  : >"$test_tmp/root-check/modules.log"
  : >"$test_tmp/root-check/files.log"
  : >"$test_tmp/root-check/runscript.log"
  unshare --user --map-root-user env OMARCHY_BOLTD_DEVICES_DIR="$boltd_injected" CASE_DIR="$test_tmp/root-check" \
    "$BASH" -c '
      set -euo pipefail
      add_module() { printf "%s\n" "$1" >>"$CASE_DIR/modules.log"; }
      add_file() {
        local src="$1" dest="$2"
        mkdir -p "$CASE_DIR/buildroot$(dirname -- "$dest")"
        if [[ $src == "-" ]]; then cat >"$CASE_DIR/buildroot$dest"; else cp "$src" "$CASE_DIR/buildroot$dest"; fi
      }
      add_runscript() { :; }
      source "$1"
      build
    ' -- "$install_hook"
  if [[ -f $test_tmp/root-check/buildroot/etc/omarchy-thunderbolt-dock.uuids ]] &&
     grep -Fq "deadbeef-dead-beef-dead-beefdeadbeef" "$test_tmp/root-check/buildroot/etc/omarchy-thunderbolt-dock.uuids"; then
    fail "root ignores OMARCHY_BOLTD_DEVICES_DIR override" "injected UUID reached allowlist"
  fi
  pass "root ignores OMARCHY_BOLTD_DEVICES_DIR override"
fi

# --- Runtime hook tests (busybox ash) ---

ash_cmd=(sh)
if [[ -x /usr/lib/initcpio/busybox ]]; then
  ash_cmd=(/usr/lib/initcpio/busybox ash)
fi

add_tb_device() {
  local case_dir="$1" slot="$2" uid="$3" auth="$4"
  mkdir -p "$case_dir/sys/bus/thunderbolt/devices/$slot"
  printf '%s\n' "$uid" >"$case_dir/sys/bus/thunderbolt/devices/$slot/unique_id"
  printf '%s\n' "$auth" >"$case_dir/sys/bus/thunderbolt/devices/$slot/authorized"
}

add_drm_connector() {
  local case_dir="$1" name="$2" status="$3"
  mkdir -p "$case_dir/sys/class/drm/$name"
  printf '%s\n' "$status" >"$case_dir/sys/class/drm/$name/status"
}

setup_runtime_case() {
  local case_dir="$1"
  rm -rf "$case_dir"
  mkdir -p "$case_dir/bin" "$case_dir/etc" "$case_dir/sys/bus/thunderbolt/devices" "$case_dir/sys/class/drm"
  : >"$case_dir/calls.log"

  sed \
    -e "s|/etc/omarchy-thunderbolt-dock.uuids|$case_dir/etc/omarchy-thunderbolt-dock.uuids|g" \
    -e "s|/sys/bus/thunderbolt/devices|$case_dir/sys/bus/thunderbolt/devices|g" \
    -e "s|/sys/class/drm|$case_dir/sys/class/drm|g" \
    "$runtime_hook" >"$case_dir/hook.ash"

  cat >"$case_dir/bin/udevadm" <<'SH'
#!/bin/sh
printf 'udevadm %s\n' "$*" >>"$CASE_DIR/calls.log"
if [ -n "${ON_FIRST_SETTLE:-}" ] && [ ! -e "$CASE_DIR/settled-once" ]; then
  : >"$CASE_DIR/settled-once"
  sh -c "$ON_FIRST_SETTLE"
fi
SH
  chmod +x "$case_dir/bin/udevadm"
}

run_runtime_case() {
  local case_dir="$1" on_first_settle="${2:-}"
  # Define sleep as a shell function so busybox ash (standalone applet mode)
  # logs calls instead of invoking its built-in sleep applet.
  CASE_DIR="$case_dir" ON_FIRST_SETTLE="$on_first_settle" PATH="$case_dir/bin:$PATH" \
    "${ash_cmd[@]}" -c '
      sleep() { printf "sleep %s\n" "$*" >>"$CASE_DIR/calls.log"; }
      . "$1"
      run_hook
    ' -- "$case_dir/hook.ash"
}

enrolled_uuid="0071f980-902a-f000-ffff-ffffffffffff"
daisy_uuid="bbbbbbbb-cccc-dddd-eeee-ffffffffffff"
unknown_uuid="99999999-8888-7777-6666-555555555555"
host_uuid="c7030000-0080-6f08-238a-74100804b120"

# 9. Undocked boot (only host router present) exits immediately with zero delay.
setup_runtime_case "$test_tmp/rt-undocked"
printf '%s\n' "$enrolled_uuid" >"$test_tmp/rt-undocked/etc/omarchy-thunderbolt-dock.uuids"
add_tb_device "$test_tmp/rt-undocked" "0-0" "$host_uuid" "1"
add_drm_connector "$test_tmp/rt-undocked" "card0-DP-1" "disconnected"
run_runtime_case "$test_tmp/rt-undocked"
[[ ! -s $test_tmp/rt-undocked/calls.log ]] ||
  fail "undocked boot exits immediately without sleep or udevadm" "calls: $(<"$test_tmp/rt-undocked/calls.log")"
[[ $(<"$test_tmp/rt-undocked/sys/class/drm/card0-DP-1/status") == "disconnected" ]] ||
  fail "undocked boot does not touch DRM connectors" "status changed"
pass "undocked boot exits immediately with zero settle/sleep/DRM overhead"

# 10. Unknown peripheral device is never authorized.
setup_runtime_case "$test_tmp/rt-unknown"
printf '%s\n' "$enrolled_uuid" >"$test_tmp/rt-unknown/etc/omarchy-thunderbolt-dock.uuids"
add_tb_device "$test_tmp/rt-unknown" "0-0" "$host_uuid" "1"
add_tb_device "$test_tmp/rt-unknown" "0-1" "$unknown_uuid" "0"
add_drm_connector "$test_tmp/rt-unknown" "card0-DP-1" "disconnected"
run_runtime_case "$test_tmp/rt-unknown"
[[ $(<"$test_tmp/rt-unknown/sys/bus/thunderbolt/devices/0-1/authorized") == "0" ]] ||
  fail "unknown Thunderbolt peripheral is never authorized" "authorized became $(<"$test_tmp/rt-unknown/sys/bus/thunderbolt/devices/0-1/authorized")"
[[ ! -s $test_tmp/rt-unknown/calls.log ]] ||
  fail "unknown-only boot exits immediately" "calls: $(<"$test_tmp/rt-unknown/calls.log")"
pass "unknown Thunderbolt peripheral stays unauthorized with zero boot delay"

# 11. Enrolled dock is authorized while unknown sibling stays unauthorized; settles and probes DP only.
setup_runtime_case "$test_tmp/rt-docked"
printf '%s\n' "$enrolled_uuid" >"$test_tmp/rt-docked/etc/omarchy-thunderbolt-dock.uuids"
add_tb_device "$test_tmp/rt-docked" "0-0" "$host_uuid" "1"
add_tb_device "$test_tmp/rt-docked" "0-1" "$enrolled_uuid" "0"
add_tb_device "$test_tmp/rt-docked" "0-3" "$unknown_uuid" "0"
add_drm_connector "$test_tmp/rt-docked" "card0-DP-1" "disconnected"
add_drm_connector "$test_tmp/rt-docked" "card0-eDP-1" "connected"
run_runtime_case "$test_tmp/rt-docked"
[[ $(<"$test_tmp/rt-docked/sys/bus/thunderbolt/devices/0-1/authorized") == "1" ]] ||
  fail "enrolled dock is authorized" "authorized=$(<"$test_tmp/rt-docked/sys/bus/thunderbolt/devices/0-1/authorized")"
[[ $(<"$test_tmp/rt-docked/sys/bus/thunderbolt/devices/0-3/authorized") == "0" ]] ||
  fail "unknown sibling stays unauthorized" "authorized=$(<"$test_tmp/rt-docked/sys/bus/thunderbolt/devices/0-3/authorized")"
grep -q '^udevadm settle ' "$test_tmp/rt-docked/calls.log" ||
  fail "docked boot settles udev" "calls: $(<"$test_tmp/rt-docked/calls.log")"
grep -q '^sleep 0\.5$' "$test_tmp/rt-docked/calls.log" ||
  fail "docked boot waits between settles" "calls: $(<"$test_tmp/rt-docked/calls.log")"
[[ $(<"$test_tmp/rt-docked/sys/class/drm/card0-DP-1/status") == "detect" ]] ||
  fail "docked boot probes DP connectors" "status=$(<"$test_tmp/rt-docked/sys/class/drm/card0-DP-1/status")"
[[ $(<"$test_tmp/rt-docked/sys/class/drm/card0-eDP-1/status") == "connected" ]] ||
  fail "docked boot leaves eDP connector untouched" "status=$(<"$test_tmp/rt-docked/sys/class/drm/card0-eDP-1/status")"
pass "enrolled dock is authorized, unknown sibling untouched, udev settled, and DP connectors probed"

# 12. Already-authorized enrolled dock (e.g. authorized by udev rule) still settles and probes DP.
setup_runtime_case "$test_tmp/rt-preauth"
printf '%s\n' "$enrolled_uuid" >"$test_tmp/rt-preauth/etc/omarchy-thunderbolt-dock.uuids"
add_tb_device "$test_tmp/rt-preauth" "0-1" "$enrolled_uuid" "1"
add_drm_connector "$test_tmp/rt-preauth" "card1-DP-2" "disconnected"
run_runtime_case "$test_tmp/rt-preauth"
grep -q '^udevadm settle ' "$test_tmp/rt-preauth/calls.log" ||
  fail "udev-authorized dock still settles" "calls: $(<"$test_tmp/rt-preauth/calls.log")"
[[ $(<"$test_tmp/rt-preauth/sys/class/drm/card1-DP-2/status") == "detect" ]] ||
  fail "udev-authorized dock probes DP connectors" "status=$(<"$test_tmp/rt-preauth/sys/class/drm/card1-DP-2/status")"
pass "udev-authorized enrolled dock still settles USB/PCIe and probes DP"

# 13. Daisy-chained enrolled peripheral appearing after first dock authorization is authorized on pass 2.
setup_runtime_case "$test_tmp/rt-daisy"
printf '%s\n%s\n' "$enrolled_uuid" "$daisy_uuid" >"$test_tmp/rt-daisy/etc/omarchy-thunderbolt-dock.uuids"
add_tb_device "$test_tmp/rt-daisy" "0-1" "$enrolled_uuid" "0"
spawn_daisy="mkdir -p '$test_tmp/rt-daisy/sys/bus/thunderbolt/devices/0-101'; \
  printf '%s\n' '$daisy_uuid' >'$test_tmp/rt-daisy/sys/bus/thunderbolt/devices/0-101/unique_id'; \
  printf '0\n' >'$test_tmp/rt-daisy/sys/bus/thunderbolt/devices/0-101/authorized'"
run_runtime_case "$test_tmp/rt-daisy" "$spawn_daisy"
[[ $(<"$test_tmp/rt-daisy/sys/bus/thunderbolt/devices/0-1/authorized") == "1" ]] ||
  fail "first dock in chain is authorized" "authorized=$(<"$test_tmp/rt-daisy/sys/bus/thunderbolt/devices/0-1/authorized")"
[[ $(<"$test_tmp/rt-daisy/sys/bus/thunderbolt/devices/0-101/authorized") == "1" ]] ||
  fail "daisy-chained enrolled peripheral is authorized on second pass" "authorized=$(<"$test_tmp/rt-daisy/sys/bus/thunderbolt/devices/0-101/authorized")"
pass "daisy-chained enrolled peripheral is authorized on second pass"

# 14. Unwritable authorized attribute does not fail or enter the wait polling loop.
setup_runtime_case "$test_tmp/rt-ro"
printf '%s\n' "$enrolled_uuid" >"$test_tmp/rt-ro/etc/omarchy-thunderbolt-dock.uuids"
add_tb_device "$test_tmp/rt-ro" "0-1" "$enrolled_uuid" "0"
chmod 444 "$test_tmp/rt-ro/sys/bus/thunderbolt/devices/0-1/authorized"
run_runtime_case "$test_tmp/rt-ro"
chmod 644 "$test_tmp/rt-ro/sys/bus/thunderbolt/devices/0-1/authorized"
grep -q '^sleep 0\.5$' "$test_tmp/rt-ro/calls.log" ||
  fail "unwritable authorized still reaches settle path" "calls: $(<"$test_tmp/rt-ro/calls.log")"
if grep -q '^sleep 0\.1$' "$test_tmp/rt-ro/calls.log"; then
  fail "unwritable authorized does not spin in _tb_wait_authorized" "calls: $(<"$test_tmp/rt-ro/calls.log")"
fi
pass "unwritable authorized exits cleanly without polling stall"
