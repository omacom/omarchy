#!/bin/bash
set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/dmi"

sed \
  -e "s|/sys/class/dmi/id|$test_dir/dmi|g" \
  -e "s|/etc/modprobe.d|$test_dir/modprobe.d|g" \
  -e "s|/etc/modules-load.d|$test_dir/modules-load.d|g" \
  "$ROOT/install/hardware/fix-msi-x870-tomahawk-fans.sh" > "$test_dir/setup.sh"

omarchy-pkg-add() {
  printf '%s\n' "$*" >> "$test_dir/packages"
}

printf '%s\n' 'Micro-Star International Co., Ltd.' > "$test_dir/dmi/board_vendor"
printf '%s\n' 'MAG X870 TOMAHAWK WIFI (MS-7E51)' > "$test_dir/dmi/board_name"
source "$test_dir/setup.sh"

[[ $(cat "$test_dir/packages") == 'nct6687d-dkms-git' ]] || fail 'MSI board installs the DKMS driver'
[[ $(cat "$test_dir/modprobe.d/omarchy-nct6683-blacklist.conf") == 'blacklist nct6683' ]] || fail 'MSI board blacklists the read-only driver'
[[ $(cat "$test_dir/modules-load.d/omarchy-nct6687.conf") == 'nct6687' ]] || fail 'MSI board loads the replacement driver'
pass 'MSI MAG X870 Tomahawk gets writable fan driver setup'

rm -f "$test_dir/packages"
printf '%s\n' 'MAG B650 TOMAHAWK WIFI (MS-7D75)' > "$test_dir/dmi/board_name"
source "$test_dir/setup.sh"
[[ ! -e "$test_dir/packages" ]] || fail 'unlisted MSI board is left alone'
pass 'unlisted MSI board does not receive the driver'
