#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A machine that switched to systemd-boot goes back to Limine with its factory
# root: the reset puts Limine's binary and boot entry back next to systemd-boot,
# leaves systemd-boot first until the factory root is in place, and only then
# hands the boot order, the fallback loader and the ESP to Limine.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

awk '
  /^[a-z_]+\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-system-factory-reset" >"$test_tmp/functions"

PARTUUID=bd3f1a3e-749d-43f1-b47b-eb683c17b230
mkdir -p "$test_tmp/bin"

# NVRAM lives in two files: the entries (number, label, loader) and the order.
cat >"$test_tmp/bin/efibootmgr" <<'SH'
#!/bin/bash
nv=$NVRAM
args=()
for a in "$@"; do [[ $a == --quiet ]] || args+=("$a"); done
set -- "${args[@]}"
case ${1:-} in
-v | "")
  printf 'BootCurrent: 0001\nBootOrder: %s\n' "$(<"$nv/order")"
  while IFS=$'\t' read -r num label loader; do
    printf 'Boot%s* %s\tHD(1,GPT,%s,0x800,0x400000)/%s\n' "$num" "$label" "$PARTUUID" "$loader"
  done <"$nv/entries"
  ;;
--bootorder) echo "$2" >"$nv/order" ;;
--delete-bootnum)
  grep -v "^$3"$'\t' "$nv/entries" >"$nv/entries.new" || true
  mv "$nv/entries.new" "$nv/entries"
  tr ',' '\n' <"$nv/order" | grep -vx "$3" | paste -sd, - >"$nv/order.new"
  mv "$nv/order.new" "$nv/order"
  ;;
--create)
  [[ -z ${REFUSE_CREATE:-} ]] || exit 1
  while (( $# )); do
    case $1 in --label) label=$2 ;; --loader) loader=$2 ;; esac
    shift
  done
  printf '0007\t%s\t%s\n' "$label" "$loader" >>"$nv/entries"
  echo "0007,$(<"$nv/order")" >"$nv/order"
  ;;
esac
SH
cat >"$test_tmp/bin/lsblk" <<'SH'
#!/bin/bash
case $2 in PARTUUID) echo "$PARTUUID" ;; PKNAME) echo nvme0n1 ;; PARTN) echo 1 ;; esac
SH
# limine-install lays Limine's binary down as the real one does.
cat >"$test_tmp/bin/chroot" <<'SH'
#!/bin/bash
[[ $2 == /usr/bin/limine-install && $3 == --no-efi-register ]] || exit 1
mkdir -p "$ESP_MNT/EFI/limine"
printf 'limine\n' >"$ESP_MNT/EFI/limine/limine_x64.efi"
SH
chmod +x "$test_tmp/bin/"*

new_machine() {
  local nv=$test_tmp/nvram esp=$test_tmp/esp
  rm -rf "$nv" "$esp"
  mkdir -p "$nv" "$esp/EFI/systemd" "$esp/EFI/BOOT" "$esp/EFI/Linux" "$esp/loader"
  printf '0003\tsystemd-boot\t\\EFI\\systemd\\systemd-bootx64.efi\n0000\tUEFI Shell\tFvFile(shell)\n' >"$nv/entries"
  echo 0003,0000 >"$nv/order"
  printf 'systemd-boot\n' >"$esp/EFI/systemd/systemd-bootx64.efi"
  printf 'systemd-boot\n' >"$esp/EFI/BOOT/BOOTX64.EFI"
  printf 'default omarchy\n' >"$esp/loader/loader.conf"
  printf 'old\n' >"$esp/EFI/Linux/omarchy-11111111-linux-omarchy-abc.efi"
  printf 'other\n' >"$esp/EFI/Linux/other-os.efi"
  # What limine-update writes while systemd-boot is still on the ESP.
  cat >"$esp/limine.conf" <<'EOF'
default_entry: 2

/+Omarchy
comment: machine-id=22222222222222222222222222222222 order-priority=50
  //linux-omarchy
  path: boot():/EFI/Linux/omarchy_linux-omarchy.efi#abc

/Systemd-boot
comment: Systemd bootloader
protocol: efi
path: boot():/EFI/systemd/systemd-bootx64.efi

/Windows
protocol: efi
path: boot():/EFI/Microsoft/Boot/bootmgfw.efi

/EFI fallback
comment: Default EFI loader
protocol: efi
path: boot():/EFI/BOOT/BOOTX64.EFI
EOF
}

# Runs production functions in one shell, so state set by one reaches the next.
run_reset() {
  env PATH="$test_tmp/bin:$PATH" NVRAM="$test_tmp/nvram" PARTUUID="$PARTUUID" \
    ESP_MNT="$test_tmp/esp" bash -c '
    set -euo pipefail
    source "$1/functions"
    ESP_MNT=$1/esp
    esp_device=/dev/nvme0n1p1
    esp_old_id=11111111111111111111111111111111
    LOG_FILE=$1/reset.log
    log() { printf "%s\n" "$1" >>"$ESP_MNT/../log"; }
    fail() { printf "%s\n" "$1" >&2; exit 1; }
    eval "$2"
  ' _ "$test_tmp" "$1"
}

order() { cat "$test_tmp/nvram/order"; }

new_machine
run_reset 'prepare_limine_return /next' || fail "the reset puts Limine back"
grep -q $'^0007\tLimine\t\\\\EFI\\\\limine\\\\limine_x64.efi$' "$test_tmp/nvram/entries" ||
  fail "Limine gets a boot entry for its binary" "$(cat "$test_tmp/nvram/entries")"
[[ $(order) == 0003,0000 ]] || fail "systemd-boot stays first until the factory root is in place" "$(order)"
pass "the reset gives Limine a boot entry and leaves systemd-boot first"

new_machine
run_reset 'prepare_limine_return /next
  efibootmgr --quiet --delete-bootnum --bootnum "$limine_entry"
  efibootmgr --quiet --bootorder "$limine_boot_order"' || fail "a failed reset drops Limine's new entry"
! grep -q Limine "$test_tmp/nvram/entries" && [[ $(order) == 0003,0000 ]] ||
  fail "a failed reset leaves NVRAM as it was" "$(cat "$test_tmp/nvram/entries"; order)"
grep -q 'limine_entry_created:-0} == 1 && -n ${limine_entry:-}' "$ROOT/bin/omarchy-system-factory-reset" ||
  fail "the cleanup trap removes the entry a failed reset created"
pass "a reset that fails before the switch leaves systemd-boot booting"

new_machine
run_reset 'prepare_limine_return /next; commit_systemd_boot_return' || fail "the reset commits the return to Limine"
[[ $(order) == 0007,0000 ]] || fail "Limine goes first and systemd-boot's entry goes" "$(order)"
! grep -q systemd-boot "$test_tmp/nvram/entries" || fail "systemd-boot's boot entry is removed"
[[ $(<"$test_tmp/esp/EFI/BOOT/BOOTX64.EFI") == limine ]] || fail "Limine is the fallback loader again"
[[ ! -e $test_tmp/esp/EFI/systemd && ! -e $test_tmp/esp/loader/loader.conf ]] || fail "systemd-boot's files leave the ESP"
[[ ! -e $test_tmp/esp/EFI/Linux/omarchy-11111111-linux-omarchy-abc.efi ]] || fail "the old system's boot images leave the ESP"
[[ -f $test_tmp/esp/EFI/Linux/other-os.efi ]] || fail "another system's boot image stays"
menu=$(grep '^/' "$test_tmp/esp/limine.conf" | paste -sd' ' -)
[[ $menu == "/+Omarchy /Windows" ]] || fail "Limine's menu loses systemd-boot and the fallback that is Limine now" "$menu"
pass "once the factory root is in place, Limine boots it and systemd-boot is gone"

# A fallback that is not systemd-boot's, such as another system's, stays.
new_machine
printf 'windows\n' >"$test_tmp/esp/EFI/BOOT/BOOTX64.EFI"
run_reset 'prepare_limine_return /next; commit_systemd_boot_return' || fail "the reset commits with a foreign fallback"
[[ $(<"$test_tmp/esp/EFI/BOOT/BOOTX64.EFI") == windows ]] || fail "another system's fallback loader stays"
grep -q '^/EFI fallback' "$test_tmp/esp/limine.conf" || fail "Limine's menu keeps another system's fallback loader"
pass "the reset leaves a fallback loader that isn't systemd-boot's"

# Limine's entry survived from before the switch: the reset reuses it.
new_machine
printf '0005\tLimine\t\\EFI\\limine\\limine_x64.efi\n' >>"$test_tmp/nvram/entries"
echo 0003,0000,0005 >"$test_tmp/nvram/order"
run_reset 'prepare_limine_return /next; [[ $limine_entry == 0005 && -z ${limine_entry_created:-} ]]
  commit_systemd_boot_return' || fail "the reset reuses Limine's entry"
[[ $(grep -c Limine "$test_tmp/nvram/entries") == 1 && $(order) == 0005,0000 ]] ||
  fail "Limine's old entry goes first, with no second one" "$(cat "$test_tmp/nvram/entries"; order)"
pass "the reset reuses a Limine boot entry that survived the switch"

new_machine
status=0
REFUSE_CREATE=1 run_reset 'prepare_limine_return /next' 2>"$test_tmp/err" || status=$?
(( status == 1 )) && grep -q 'refused a boot entry' "$test_tmp/err" ||
  fail "firmware that refuses the entry stops the reset" "$(cat "$test_tmp/err")"
pass "the reset stops when the firmware refuses Limine's boot entry"
