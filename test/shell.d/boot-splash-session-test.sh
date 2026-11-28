#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# default/splash/session picks the display the splash draws on from sysfs. Its
# own find_cards runs here against a fixture DRM tree, with the session's
# sysfs and /dev paths pointed into it.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

drm=$test_tmp/sys/class/drm
dri=$test_tmp/dev/dri
drivers=$test_tmp/sys/bus/platform/drivers
sed -n '/^find_cards() {/,/^}/p; /^has_connectors() {/,/^}/p' "$ROOT/default/splash/session" |
  sed -e "s|/sys/class/drm|$drm|g" -e "s|/dev/dri|$dri|g" >"$test_tmp/find-cards.sh"
if ! grep -qF "$drm/card" "$test_tmp/find-cards.sh" || ! grep -qF "$dri/" "$test_tmp/find-cards.sh"; then
  fail "find_cards reads its DRM cards from the fixture"
fi

# A card with a display connector and a device node, bound to driver $2, or to
# none while its driver is being unbound.
card() {
  mkdir -p "$drm/$1/device" "$drm/$1-eDP-1" "$dri"
  touch "$dri/$1"
  if [[ $2 != "none" ]]; then
    mkdir -p "$drivers/$2"
    ln -s "$drivers/$2" "$drm/$1/device/driver"
  fi
}

# The displays find_cards finds, as native|firmware.
cards() {
  sh -c '. "$1"; find_cards; printf "%s|%s\n" "$native" "$firmware"' sh "$test_tmp/find-cards.sh"
}

# The native driver binding takes the firmware framebuffer away: for a moment
# its card keeps a connector and a device node, but no driver.
card card0 none
found=$(cards)
[[ $found == "|" ]] || fail "a card whose driver is being unbound is not a display to draw on" "found: $found"
pass "a card whose driver is being unbound is not a display to draw on"

# simpledrm, efidrm and vesadrm.
for firmware in simple-framebuffer efi-framebuffer vesa-framebuffer; do
  rm -rf "$drm" "$dri"
  card card0 "$firmware"
  card card1 msm_dpu
  found=$(cards)
  [[ $found == "$dri/card1|$dri/card0" ]] || fail "the firmware framebuffer and the GPU's own driver are told apart" "$firmware found: $found"
done
pass "the firmware framebuffer and the GPU's own driver are told apart"

# The late hook takes the splash down for a volume in the real root's crypttab
# that asks for its passphrase on the console, and only for one.
asks_passphrase() {
  printf '%s\n' "$@" >"$test_tmp/crypttab"
  sh -c '. "$1" && asks_passphrase "$2"' sh "$ROOT/etc/initcpio/hooks/omarchy-splash" "$test_tmp/crypttab"
}
if asks_passphrase '# home UUID=1 none' '' 'swap /dev/sda2 /dev/urandom swap' 'data UUID=2 /etc/data.key' 'later UUID=3 - luks,noauto'; then
  fail "comments, key files and noauto volumes ask for no passphrase"
fi
pass "comments, key files and noauto volumes ask for no passphrase"
for volume in 'home UUID=1' $'home\tUUID=1\tnone\tluks,discard' 'home UUID=1 - nofail'; do
  asks_passphrase "$volume" || fail "a volume without a key file asks for its passphrase" "$volume"
done
pass "a volume without a key file asks for its passphrase"

# stop signals only the splash's own processes, those systemd didn't start: in
# the root cgroup in the initramfs, and in init.scope in the real root, where
# systemd moves them. A unit's, such as a seatd.service, are left alone.
proc=$test_tmp/proc
sed -n '/^signal_splash() {/,/^}/p' "$ROOT/default/splash/stop" | sed "s|/proc/|$proc/|g" >"$test_tmp/signal-splash.sh"
grep -qF "$proc/" "$test_tmp/signal-splash.sh" || fail "signal_splash reads processes from the fixture"
mkdir -p "$proc/1" "$proc/2" "$proc/3"
echo "0::/" >"$proc/1/cgroup"
echo "0::/init.scope" >"$proc/2/cgroup"
echo "0::/system.slice/seatd.service" >"$proc/3/cgroup"
signalled=$(sh -c '. "$1"; pidof() { echo 1 2 3; }; kill() { echo "$2"; }; signal_splash TERM seatd' sh "$test_tmp/signal-splash.sh" | tr '\n' ' ')
[[ $signalled == "1 2 " ]] ||
  fail "stop signals the splash's processes in the initramfs and the real root, and no unit's" "signalled: $signalled"
pass "stop signals the splash's processes in the initramfs and the real root, and no unit's"
