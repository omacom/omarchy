#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

hardware_network="$ROOT/install/hardware/network.sh"
grep -F 'systemd-networkd.service' "$hardware_network" >/dev/null
grep -F 'systemd-networkd.socket' "$hardware_network" >/dev/null
grep -F '20-wlan.network' "$hardware_network" >/dev/null
grep -F 'omarchy-networkd-retired' "$hardware_network" >/dev/null
pass "hardware setup retires archinstall networkd state"
