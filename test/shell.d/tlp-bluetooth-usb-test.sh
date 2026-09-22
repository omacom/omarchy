#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

packaged_conf="$ROOT/etc/tlp.d/omarchy-bluetooth-usb.conf"
upgrade_script="$ROOT/bin/omarchy-upgrade-to-quattro"

[[ -f $packaged_conf ]] ||
  fail "Omarchy ships a TLP drop-in that keeps Bluetooth USB controllers awake"

grep -Eq '^USB_DENYLIST="8087:[0-9a-f]{4}( 8087:[0-9a-f]{4})*"$' "$packaged_conf" ||
  fail "the TLP drop-in denylists Intel Bluetooth controllers"

grep -Fq "8087:0aaa" "$packaged_conf" ||
  fail "the TLP drop-in covers the Jefferson Peak Bluetooth controllers"

grep -Fq -- "--overwrite '/etc/tlp.d/omarchy-bluetooth-usb.conf'" "$upgrade_script" ||
  fail "the upgrade registers the TLP drop-in for conflict-free replacement"

pass "TLP installations keep Bluetooth USB controllers awake"
