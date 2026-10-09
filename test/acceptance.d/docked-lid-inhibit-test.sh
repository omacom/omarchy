#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Exercise the package paths used by the system service, without session or
# development-checkout helpers masking a missing runtime binary.
export PATH=/usr/bin
unset OMARCHY_DRM_PATH

for helper in omarchy-system-docked-lid-inhibit omarchy-hw-external-monitors; do
  [[ -x /usr/bin/$helper ]] || fail "docked lid helpers are installed in the service PATH" "$helper is missing"
  pacman -Qo "/usr/bin/$helper" >/dev/null || fail "docked lid helpers are package-owned" "$helper is unowned"
done
pass "docked lid helpers are package-owned and available in the service PATH"

unit=omarchy-docked-lid-inhibit.service
pacman -Qo "/usr/lib/systemd/system/$unit" >/dev/null || fail "docked lid unit is package-owned"
[[ $(systemctl show --property=FragmentPath --value "$unit") == "/usr/lib/systemd/system/$unit" ]] ||
  fail "docked lid protection uses the updatable vendor unit"
[[ $(systemctl show --property=Type --value "$unit") == "notify" ]] || fail "docked lid protection waits for readiness"
pass "docked lid protection uses the package-owned vendor unit and readiness notification"
systemctl is-enabled --quiet "$unit" || fail "docked lid protection is enabled after installation or update"
wait_until "docked lid protection is running after installation or update" 10 systemctl is-active --quiet "$unit"

docked_lid_inhibited() {
  systemd-inhibit --list --json=short | jq -e '
    any(.[]; .who == "Omarchy" and .what == "handle-lid-switch" and .mode == "block")
  ' >/dev/null
}

policy=$(busctl --system get-property org.freedesktop.login1 /org/freedesktop/login1 \
  org.freedesktop.login1.Manager HandleLidSwitchDocked)
if [[ $policy != 's "ignore"' ]]; then
  pass "docked lid inhibitor check # SKIP administrator docked policy is not ignore"
elif omarchy-hw-external-monitors; then
  wait_until "an external monitor acquires the docked lid inhibitor" 10 docked_lid_inhibited
else
  pass "docked lid inhibitor check # SKIP no external monitor is physically connected"
fi
