#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

base_packages="$ROOT/install/omarchy-base.packages"
server_packages="$ROOT/install/omarchy-server.packages"

[[ -f $server_packages ]] || fail "the server package list is shipped"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

read_list() {
  sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$1"
}

read_list "$base_packages" >"$workdir/base"
read_list "$server_packages" >"$workdir/server"

[[ -s $workdir/server ]] || fail "the server package list is not empty"

# The list is derived from the base list by subtraction. Anything else in it is
# either a typo or an addition that deserves to be named here on purpose.
#
#   openssh              - the desktop gets it from the ISO's archinstall.packages, and
#                          the server edition cannot assume that list.
#   rsync                - the transport a headless box is administered over.
#   lazyjournal          - the menu's log door, packaged in omarchy-pkgs.
#   dua-cli              - disk usage analyzer, CLI replacement for baobab
#   lazydocker           - Docker TUI for the [D] door
#   mkinitcpio-dropbear  - SSH server in initramfs for remote LUKS unlock
#   mkinitcpio-netconf   - network configuration in initramfs
#   mkinitcpio-utils     - utilities for initramfs (including encryptssh hook)
printf 'openssh\nrsync\nlazyjournal\ndua-cli\nlazydocker\nmkinitcpio-dropbear\nmkinitcpio-netconf\nmkinitcpio-utils\n' >"$workdir/server-only"

while IFS= read -r package; do
  grep -Fxq "$package" "$workdir/base" && continue
  grep -Fxq "$package" "$workdir/server-only" ||
    fail "every server package comes from omarchy-base.packages or is a declared addition" \
      "$package is in neither"
done <"$workdir/server"
pass "the server list is a subtraction from the base list, plus its declared additions"

while IFS= read -r package; do
  grep -Fxq "$package" "$workdir/server" ||
    fail "the declared server-only additions are actually shipped" "$package is missing"
done <"$workdir/server-only"
pass "the declared server-only additions are shipped"

duplicates=$(sort "$workdir/server" | uniq -d)
[[ -z $duplicates ]] || fail "the server list has no duplicates" "$duplicates"
pass "the server list has no duplicates"

# A server edition that drags in a compositor, a login manager, or a browser has
# failed at the one thing it exists to do.
for package in hyprland quickshell sddm uwsm chromium nautilus plymouth \
  wireplumber bluez cups xdg-desktop-portal-hyprland; do
  ! grep -Fxq "$package" "$workdir/server" ||
    fail "the server list ships no desktop stack" "$package is present"
done
pass "the server list ships no compositor, shell, login manager, or GUI stack"

# The point of the edition is that the CLI and the TUI toolbox survive intact.
for package in docker docker-compose btop lazygit lazydocker lazyjournal ufw tmux git gum \
  starship bat eza fzf ripgrep jq nvim openssh; do
  grep -Fxq "$package" "$workdir/server" ||
    fail "the server list keeps the CLI and TUI toolbox" "$package is missing"
done
pass "the server list keeps the CLI and TUI toolbox"

# Every base package must have a retain/drop decision
read_dropped() {
  sed -n 's/^# dropped: //p' "$1"
}

read_dropped "$server_packages" >"$workdir/dropped"
while IFS= read -r package; do
  if ! grep -Fxq "$package" "$workdir/server" && ! grep -Fxq "$package" "$workdir/server-only"; then
    grep -Fxq "$package" "$workdir/dropped" ||
      fail "every base package is either retained in the server list or marked as dropped" \
        "$package is in neither"
  fi
done <"$workdir/base"
pass "every base package has a retain/drop decision"

# No package can be both retained and dropped
while IFS= read -r package; do
  ! grep -Fxq "$package" "$workdir/server" ||
    fail "no package can be both retained and marked as dropped" "$package is both"
done <"$workdir/dropped"
pass "no package is both retained and marked as dropped"

# The union of retained and dropped should equal base
cat "$workdir/server" "$workdir/dropped" | sort | uniq >"$workdir/union-pre"
sort "$workdir/server-only" >"$workdir/server-only-sorted"
comm -23 "$workdir/union-pre" "$workdir/server-only-sorted" >"$workdir/union"
sort "$workdir/base" >"$workdir/base-sorted"
diff -u "$workdir/base-sorted" "$workdir/union" >/dev/null ||
  fail "retained + dropped should equal base" "$(diff -u "$workdir/base-sorted" "$workdir/union" || true)"
pass "retained + dropped equals base"
