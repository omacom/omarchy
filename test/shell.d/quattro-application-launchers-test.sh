#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
apps="$home/.local/share/applications"
icons="$apps/icons"
backup="$apps/icons.omarchy-upgrade-to-quattro.20260814150916.bak"
older="$apps/icons.omarchy-upgrade-to-quattro.20260101000000.bak"

write_desktop() {
  local path="$1" icon="$2"
  printf '%s\n' '[Desktop Entry]' 'Name=Test' "Icon=$icon" >"$path"
}

# Refresh is what the upgrade tells a user to rerun, so it must put back the PNGs
# leftover launchers still name. A fixture tree stands in for packaged launchers.
refresh_root="$test_dir/omarchy"
mkdir -p "$refresh_root/applications" "$refresh_root/install/helpers"
ln -s "$ROOT/install/helpers/quattro-app-icons.sh" "$refresh_root/install/helpers/quattro-app-icons.sh"
printf '%s\n' '[Desktop Entry]' 'Name=Basecamp' 'Icon=basecamp' >"$refresh_root/applications/Basecamp.desktop"

mkdir -p "$apps" "$backup" "$older"
printf 'older-icon\n' >"$older/GitHub.png"
printf 'newer-icon\n' >"$backup/GitHub.png"
printf 'unrelated\n' >"$backup/windows.png"
write_desktop "$apps/GitHub.desktop" "$icons/GitHub.png"
write_desktop "$apps/windows.desktop" "$icons/../windows.png"

HOME="$home" OMARCHY_PATH="$refresh_root" PATH="$ROOT/bin:$PATH" bash "$ROOT/bin/omarchy-refresh-applications" >/dev/null

[[ -f $icons/GitHub.png ]] || fail "refresh-applications restores a referenced icon from the Quattro backup"
[[ $(<"$icons/GitHub.png") == newer-icon ]] || fail "refresh-applications restores from the newest Quattro backup" "$(<"$icons/GitHub.png")"
[[ ! -e $icons/windows.png && ! -e $apps/windows.png ]] || fail "refresh-applications does not restore an unreferenced or non-exact icon"
[[ -f $apps/Basecamp.desktop ]] || fail "refresh-applications still installs packaged launchers"
pass "refresh-applications restores referenced icons from the Quattro backup"
