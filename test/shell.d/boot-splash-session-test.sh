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

# The late hook waits for a splash that has already picked a display to finish
# starting before switch_root deletes the initramfs under it, and takes down a
# splash that is still waiting for a GPU or died before coming up.
late_root=$test_tmp/late
late_hook=$test_tmp/late-hook.sh
sed -e "s|/run/omarchy-splash|$late_root/run/omarchy-splash|g" \
    -e "s|/run/systemd/system|$late_root/run/systemd/system|g" \
    -e "s|/sysroot/etc/crypttab|$late_root/sysroot/etc/crypttab|g" \
    -e "s|/usr/lib/omarchy-splash/stop|$late_root/stop|g" \
    -e "s|/etc/systemd/system/omarchy-splash-hold.service|$late_root/etc/omarchy-splash-hold.service|g" \
    "$ROOT/etc/initcpio/hooks/omarchy-splash" >"$late_hook"
grep -qF "$late_root/run/omarchy-splash" "$late_hook" || fail "late hook reads its state from the fixture"

reset_late() {
  rm -rf "$late_root"
  mkdir -p "$late_root/run/omarchy-splash" "$late_root/sysroot/etc" "$late_root/etc"
  cat >"$late_root/stop" <<SH
#!/bin/sh
touch "$late_root/stopped"
SH
  chmod +x "$late_root/stop"
}

# Case 1: splash already picked a display and writes ready shortly after.
reset_late
sleep 10 &
bg_pid=$!
echo "$bg_pid" >"$late_root/run/omarchy-splash/session.pid"
touch "$late_root/run/omarchy-splash/starting"
(sleep 0.2 && touch "$late_root/run/omarchy-splash/ready") &
ready_writer=$!
sh -c '. "$1" && run_latehook' sh "$late_hook"
wait "$ready_writer" 2>/dev/null || true
kill "$bg_pid" 2>/dev/null || true
wait "$bg_pid" 2>/dev/null || true
[[ ! -e "$late_root/stopped" && -L "$late_root/run/systemd/system/graphical.target.wants/omarchy-splash-hold.service" ]] ||
  fail "late hook waits for a starting splash to become ready and schedules hold"
pass "late hook waits for a starting splash to become ready and schedules hold"

# Case 2: splash is still waiting for a native GPU (no starting marker).
reset_late
sleep 10 &
bg_pid=$!
echo "$bg_pid" >"$late_root/run/omarchy-splash/session.pid"
sh -c '. "$1" && run_latehook' sh "$late_hook"
kill "$bg_pid" 2>/dev/null || true
wait "$bg_pid" 2>/dev/null || true
[[ -e "$late_root/stopped" && ! -e "$late_root/run/systemd/system/graphical.target.wants/omarchy-splash-hold.service" ]] ||
  fail "late hook stops a splash still waiting for a GPU instead of stalling boot"
pass "late hook stops a splash still waiting for a GPU instead of stalling boot"

# Case 3: splash picked a display, then died before writing ready.
reset_late
(sleep 0.15) &
bg_pid=$!
echo "$bg_pid" >"$late_root/run/omarchy-splash/session.pid"
touch "$late_root/run/omarchy-splash/starting"
sh -c '. "$1" && run_latehook' sh "$late_hook"
wait "$bg_pid" 2>/dev/null || true
[[ -e "$late_root/stopped" && ! -e "$late_root/run/systemd/system/graphical.target.wants/omarchy-splash-hold.service" ]] ||
  fail "late hook stops cleanly when a starting splash exits before ready"
pass "late hook stops cleanly when a starting splash exits before ready"

# With /usr/lib/omarchy-splash/no-kms present, wait_native settles on a
# firmware framebuffer immediately (zero sleep calls) instead of waiting 8 s.
rm -rf "$drm" "$dri"
card card0 simple-framebuffer
nokms_marker=$test_tmp/no-kms
touch "$nokms_marker"
sed -n '/^find_cards() {/,/^devices=/p' "$ROOT/default/splash/session" |
  sed -e "s|/sys/class/drm|$drm|g" \
      -e "s|/dev/dri|$dri|g" \
      -e "s|/usr/lib/omarchy-splash/no-kms|$nokms_marker|g" >"$test_tmp/wait-nokms.sh"
picked=$(sh -c '
  run="$1"; sleeps=0
  sleep() { sleeps=$((sleeps + 1)); }
  . "$2"
  printf "%s|%s\n" "$devices" "$sleeps"
' sh "$test_tmp" "$test_tmp/wait-nokms.sh")
[[ $picked == "$dri/card0|0" ]] || fail "no-kms marker selects simpledrm without sleeping" "got: $picked"
pass "no-kms marker draws on the firmware framebuffer immediately without sleeping"
