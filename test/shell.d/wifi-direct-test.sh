#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export OMARCHY_PATH="$ROOT"

# Redirect absolute system paths in a copy; run the real setup without root or
# access to the host network. No service commands should be needed at install.
sed -e "s|/etc/|$scratch/etc/|g" \
  -e "s|/run/|$scratch/run/|g" \
  -e "s|/usr/lib/|$scratch/usr/lib/|g" \
  -e "s|/{etc,run,usr/lib}/|$scratch/{etc,run,usr/lib}/|g" \
  "$ROOT/install/hardware/wifi-direct.sh" > "$scratch/setup.sh"
mkdir -p "$scratch/usr/lib/systemd/system" "$scratch/etc/systemd/system"
printf 'ExecStart=/usr/bin/wpa_supplicant -u -s -O %s/run/wpa_supplicant\n' "$scratch" > "$scratch/usr/lib/systemd/system/wpa_supplicant.service"
config="$scratch/etc/wpa_supplicant/wifi-direct-pc.conf"
dropin="$scratch/etc/systemd/system/wpa_supplicant.service.d/50-wifi-direct-pc.conf"

run_setup() { bash -euo pipefail "$scratch/setup.sh"; }
run_setup
cmp -s "$config" "$ROOT/default/wpa_supplicant/wifi-direct-pc.conf" || fail "PC identity installed"
cmp -s "$dropin" "$ROOT/default/systemd/wpa_supplicant.service.d/50-wifi-direct-pc.conf" || fail "tested service flags installed"
pass "fresh install uses tested files"
run_setup
pass "repeated setup succeeds"
rm "$dropin"
run_setup
[[ -f $dropin ]] || fail "partial installation repaired"
pass "partial installation repaired"

rm "$dropin"
printf 'device_type=custom\n' > "$config"
run_setup
[[ $(cat "$config") == 'device_type=custom' && ! -e $dropin ]] || fail "custom identity preserved"
pass "custom identity preserved"
rm "$config"
printf '[Service]\nExecStart=custom -m /custom.conf\n' > "$scratch/etc/systemd/system/custom.conf"
mkdir -p "$(dirname "$dropin")"
mv "$scratch/etc/systemd/system/custom.conf" "$(dirname "$dropin")/custom.conf"
run_setup
[[ ! -e $config && ! -e $dropin ]] || fail "custom service preserved"
pass "custom service flags and existing -m preserved"
rm "$(dirname "$dropin")/custom.conf"
ln -s /dev/null "$scratch/etc/systemd/system/wpa_supplicant.service"
run_setup
[[ ! -e $dropin ]] || fail "masked unit preserved"
pass "masked unit preserved"

rm "$scratch/etc/systemd/system/wpa_supplicant.service"
printf '[Service]\nEnvironment=CUSTOM=1\n' > "$dropin"
run_setup
[[ ! -e $config && $(cat "$dropin") == $'[Service]\nEnvironment=CUSTOM=1' ]] || fail "custom destination drop-in preserved"
pass "custom destination drop-in preserved"
rm "$dropin"

# Exercise the migration entry point using a fake sudo and redirected leaf.
mkdir -p "$scratch/bin" "$scratch/tree/install/hardware"
cp "$scratch/setup.sh" "$scratch/tree/install/hardware/wifi-direct.sh"
ln -s "$ROOT/default" "$scratch/tree/default"
printf '#!/bin/bash\nexec "$@"\n' > "$scratch/bin/sudo"
chmod +x "$scratch/bin/sudo"
PATH="$scratch/bin:$PATH" OMARCHY_PATH="$scratch/tree" bash -euo pipefail "$ROOT/migrations/1789095456.sh"
[[ -f $config && -f $dropin ]] || fail "migration installs identity and service configuration"
PATH="$scratch/bin:$PATH" OMARCHY_PATH="$scratch/tree" bash -euo pipefail "$ROOT/migrations/1789095456.sh"
pass "migration runs shared setup"
