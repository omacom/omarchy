#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Apple Silicon's boot package ships mkinitcpio drop-ins 90- to 94- that sort
# after the HOOKS baseline and add the Asahi firmware and systemd unlock hooks
# to it. The fixtures are the drop-ins omarchy-mac-boot 20260926-1.45 installs,
# as read from an encrypted M1 Pro, byte for byte the same as
# packages/omarchy-mac/boot/files/etc/mkinitcpio.conf.d in omacom/omarchy-mac at
# f77d965e (MIT). The encryption drop-in leaves a line carrying
# busybox encrypt alone, since that is a Mac unlocked through cryptdevice=, so
# the baseline must give a Mac the systemd line.
require_platform_fixtures "the Apple boot drop-ins on the HOOKS baseline"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fake_platform "$tmp/platform" apple-silicon
# No kernel modules here: the HID drop-in adds only what modinfo finds.
printf '#!/bin/bash\nexit 1\n' >"$tmp/platform/bin/modinfo"
chmod +x "$tmp/platform/bin/modinfo"

# $1 is the HOOKS line in mkinitcpio.conf. The drop-ins read /etc/vconsole.conf,
# so point them at a fixture.
compose() {
  local config=$tmp/buildconfig conf
  local -a conf_files=()
  rm -rf "$tmp/conf.d"
  mkdir -p "$tmp/conf.d"
  cp "$ROOT"/etc/mkinitcpio.conf.d/*.conf "$ROOT"/test/shell.d/fixtures/omarchy-mac-boot-mkinitcpio/*.conf "$tmp/conf.d/"
  sed -i "s|/etc/vconsole.conf|$tmp/vconsole.conf|g" "$tmp/conf.d"/*.conf
  printf 'MODULES=()\nBINARIES=()\nFILES=()\nHOOKS=(%s)\n' "$1" >"$config"
  mapfile -d '' conf_files < <(LC_ALL=C.UTF-8 find "$tmp/conf.d" -maxdepth 1 -xtype f -name '*.conf' -print0 |
    sed -z 's/.*\///' | LC_ALL=C.UTF-8 sort -zVu)
  for conf in "${conf_files[@]}"; do
    cat -- "$tmp/conf.d/$conf" >>"$config"
  done
  OMARCHY_PROC_ROOT="$tmp/platform/proc" PATH="$tmp/platform/bin:$ROOT/bin:$PATH" "$BASH" -c '
    . "$1" || exit 1
    printf "HOOKS=%s\nFILES=%s\n" "${HOOKS[*]}" "${FILES[*]}"
  ' -- "$config"
}

assert_hooks() {
  local description="$1" stock="$2" expected="$3" out
  out=$(compose "$stock") || fail "$description" "the drop-ins do not source cleanly"
  [[ $(sed -n 's/^HOOKS=//p' <<<"$out") == "$expected" ]] ||
    fail "$description" "expected: HOOKS=$expected"$'\n'"actual:   $out"
  pass "$description"
}

# The HOOKS the M1 Pro builds its encrypted image from today.
apple="base systemd plymouth autodetect microcode modconf kms keyboard sd-vconsole block asahi omarchy-vendorfw omarchy-mac-encrypt sd-encrypt filesystems fsck"
alarm_systemd="base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck"
alarm_busybox="base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck"

printf 'KEYMAP=us\nXKBLAYOUT=us\n' >"$tmp/vconsole.conf"
assert_hooks "a Mac keeps its firmware and systemd unlock hooks" "$alarm_systemd" "$apple"
assert_hooks "a Mac whose mkinitcpio.conf has the busybox line gets the same hooks" "$alarm_busybox" "$apple"
out=$(compose "$alarm_systemd")
[[ $(sed -n 's/^FILES=//p' <<<"$out") == *"$tmp/vconsole.conf"* ]] ||
  fail "a Latin layout reaches the image" "$out"
pass "a Latin layout reaches the image"

printf 'KEYMAP=ru\nXKBLAYOUT=ru\n' >"$tmp/vconsole.conf"
assert_hooks "a non-Latin layout keeps the prompt on the US map" "$alarm_systemd" "${apple/ sd-vconsole / }"
out=$(compose "$alarm_systemd")
[[ $(sed -n 's/^FILES=//p' <<<"$out") != *vconsole* ]] ||
  fail "a non-Latin layout stays out of the image" "$out"
pass "a non-Latin layout stays out of the image"

# A Mac that unlocks through cryptdevice= keeps its busybox line, drop-ins and all.
printf 'KEYMAP=us\nXKBLAYOUT=us\n' >"$tmp/vconsole.conf"
legacy="base udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block encrypt asahi filesystems fsck"
assert_hooks "a busybox encrypt Mac keeps its own line" "$legacy" "$legacy"
