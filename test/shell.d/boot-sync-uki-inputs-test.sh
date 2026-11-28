#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A boot image's inputs include uki.conf and every device tree it names, so a
# changed tree reaches the next boot (boot-sync-test.sh has the sync rebuild
# the published image).

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

awk '
  /^[a-z_]+\(\) \{/ { copying = 1 }
  copying { print }
  /^}/ { copying = 0 }
' "$ROOT/bin/omarchy-boot-sync" >"$test_tmp/functions"

inputs() {
  bash -c 'set -euo pipefail; source "$1/functions"; UKI_CONFIG=$1/uki.conf; uki_inputs | sha256sum' _ "$test_tmp"
}

none=$(inputs) || fail "no uki.conf is no input"

mkdir -p "$test_tmp/dtbs"
printf 'tree-1\n' >"$test_tmp/dtbs/x1e80100-laptop.dtb"
printf '[UKI]\nDeviceTree=%s/dtbs/x1e80100-laptop.dtb\n' "$test_tmp" >"$test_tmp/uki.conf"
first=$(inputs)
[[ $first != "$none" ]] || fail "a uki.conf changes the key"

printf 'tree-2\n' >"$test_tmp/dtbs/x1e80100-laptop.dtb"
second=$(inputs)
[[ $second != "$first" ]] || fail "a changed device tree changes the key"

printf 'tree-2\n' >"$test_tmp/dtbs/other.dtb"
printf '[UKI]\nDeviceTreeAuto=%s/dtbs/x1e80100-laptop.dtb %s/dtbs/other.dtb\n' "$test_tmp" "$test_tmp" >"$test_tmp/uki.conf"
third=$(inputs)
printf 'tree-3\n' >"$test_tmp/dtbs/other.dtb"
[[ $(inputs) != "$third" ]] || fail "every tree a list names counts"

pass "uki.conf and the device trees it names are part of a boot image's key"
