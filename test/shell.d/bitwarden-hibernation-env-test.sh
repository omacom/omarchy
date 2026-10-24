#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

env_file="$ROOT/default/uwsm/default"
stubs=$(mktemp -d)
trap 'rm -rf "$stubs"' EXIT
touch "$stubs/swapfile"

cat >"$stubs/swapon" <<'STUB'
#!/bin/bash
[[ -n $STUB_SWAPS ]] && printf '%s\n' $STUB_SWAPS
true
STUB
cat >"$stubs/findmnt" <<'STUB'
#!/bin/bash
echo "/dev/mapper/root[/@swap]"
STUB
# lsblk -J -s: each device with the devices it sits on as children.
cat >"$stubs/lsblk" <<'STUB'
#!/bin/bash
disk='{"name":"/dev/nvme0n1","type":"disk"}'
luks='{"name":"/dev/mapper/pv","type":"crypt","children":[{"name":"/dev/nvme0n1p2","type":"part","children":['"$disk"']}]}'
plain='{"name":"/dev/sdb1","type":"part","children":[{"name":"/dev/sdb","type":"disk"}]}'
case ${@: -1} in
  /dev/mapper/root) device='{"name":"/dev/mapper/root","type":"crypt","children":[{"name":"/dev/nvme0n1p2","type":"part","children":['"$disk"']}]}' ;;
  /dev/nvme0n1p3) device='{"name":"/dev/nvme0n1p3","type":"part","children":['"$disk"']}' ;;
  /dev/vg/swap) device='{"name":"/dev/vg/swap","type":"lvm","children":['"$luks"']}' ;;
  /dev/vg/spanned) device='{"name":"/dev/vg/spanned","type":"lvm","children":['"$luks"','"$plain"']}' ;;
  *) exit 32 ;;
esac
printf '{"blockdevices":[%s]}\n' "$device"
STUB
chmod +x "$stubs/swapon" "$stubs/findmnt" "$stubs/lsblk"

# The value a program started from the session sees, so a lost export shows.
backend() {
  env -u SECURE_KEY_CONTAINER_BACKEND PATH="$stubs:$ROOT/bin:$PATH" STUB_SWAPS="$1" "${@:2}" \
    bash -c 'source "$1"; printenv SECURE_KEY_CONTAINER_BACKEND || echo unset' bash "$env_file"
}

value=$(backend "$stubs/swapfile /dev/zram0")
[[ $value == "mlock" ]] || fail "Bitwarden uses locked memory when the swap file is encrypted" "actual: $value"
pass "Bitwarden uses locked memory when the swap file is encrypted"

value=$(backend "/dev/vg/swap")
[[ $value == "mlock" ]] || fail "Bitwarden uses locked memory on swap in LVM on LUKS" "actual: $value"
pass "Bitwarden uses locked memory on swap in LVM on LUKS"

value=$(backend "$stubs/swapfile /dev/nvme0n1p3")
[[ $value == "unset" ]] || fail "Bitwarden keeps memfd_secret next to an unencrypted swap partition" "actual: $value"
pass "Bitwarden keeps memfd_secret next to an unencrypted swap partition"

value=$(backend "/dev/vg/spanned")
[[ $value == "unset" ]] || fail "Bitwarden keeps memfd_secret on swap spread over an encrypted and a plain disk" "actual: $value"
pass "Bitwarden keeps memfd_secret on swap spread over an encrypted and a plain disk"

value=$(backend "/dev/zram0")
[[ $value == "unset" ]] || fail "Bitwarden keeps memfd_secret with only zram swap" "actual: $value"
pass "Bitwarden keeps memfd_secret with only zram swap"

value=$(backend "")
[[ $value == "unset" ]] || fail "Bitwarden keeps memfd_secret without swap" "actual: $value"
pass "Bitwarden keeps memfd_secret without swap"

value=$(backend "$stubs/swapfile" SECURE_KEY_CONTAINER_BACKEND=keyctl)
[[ $value == "keyctl" ]] || fail "a backend the user chose is kept" "actual: $value"
pass "a backend the user chose is kept"
