#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

units=(
  systemd-pcrphase-sysinit.service
  systemd-pcrphase.service
  systemd-pcrmachine.service
  systemd-pcrfs-root.service
  'systemd-pcrfs@.service'
)

for unit in "${units[@]}"; do
  drop_in="$ROOT/etc/systemd/system/${unit}.d/10-omarchy-no-force-reboot.conf"
  [[ -f $drop_in ]] || fail "shipped drop-in exists for $unit"

  # systemd ignores FailureAction= outside [Unit], so the section matters as much as the value.
  settings=$(grep -vE '^[[:space:]]*(#|$)' "$drop_in")
  [[ $settings == $'[Unit]\nFailureAction=none' ]] ||
    fail "drop-in sets FailureAction=none under [Unit] for $unit" "$settings"
done

pass "PCR measurement units ship FailureAction=none drop-ins"
