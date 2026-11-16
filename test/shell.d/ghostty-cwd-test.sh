#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

ghostty_desktop="$ROOT/default/ghostty/com.mitchellh.ghostty.desktop"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

refresh_root="$test_tmp/omarchy"
refresh_home="$test_tmp/home"
refresh_bin="$test_tmp/bin"
installed_desktop="$refresh_home/.local/share/applications/com.mitchellh.ghostty.desktop"
custom_desktop="$test_tmp/custom-ghostty.desktop"

mkdir -p "$refresh_root/applications" "$refresh_root/default/ghostty" "$refresh_home/.local/share/applications" "$refresh_bin"
cp "$ROOT"/applications/*.desktop "$refresh_root/applications/"
cp "$ghostty_desktop" "$refresh_root/default/ghostty/"

cat >"$refresh_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "ghostty" ]]
SH

cat >"$refresh_bin/update-desktop-database" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$refresh_bin"/*

printf '%s\n' \
  '[Desktop Entry]' \
  'Name=Custom Ghostty' \
  'Exec=/usr/bin/ghostty --custom' >"$custom_desktop"
cp "$custom_desktop" "$installed_desktop"

HOME="$refresh_home" PATH="$refresh_bin:$PATH" OMARCHY_PATH="$refresh_root" \
  "$ROOT/bin/omarchy-refresh-applications"

cmp -s "$custom_desktop" "$installed_desktop" ||
  fail "application refresh preserves an existing Ghostty desktop entry"
pass "application refresh preserves an existing Ghostty desktop entry"

refresh_symlink_target="$test_tmp/custom-ghostty-target"
refresh_symlink_log="$test_tmp/refresh-symlink-log"
rm "$installed_desktop"
ln -s "$refresh_symlink_target" "$installed_desktop"
HOME="$refresh_home" PATH="$refresh_bin:$PATH" OMARCHY_PATH="$refresh_root" \
  "$ROOT/bin/omarchy-refresh-applications" >"$refresh_symlink_log" 2>&1

[[ ! -s $refresh_symlink_log ]] ||
  fail "application refresh does not write through a dangling Ghostty desktop symlink" "$(<"$refresh_symlink_log")"
[[ -L $installed_desktop && $(readlink "$installed_desktop") == "$refresh_symlink_target" ]] ||
  fail "application refresh preserves a dangling Ghostty desktop symlink"
[[ ! -e $refresh_symlink_target ]] ||
  fail "application refresh does not create a dangling Ghostty symlink target"
pass "application refresh preserves a dangling Ghostty desktop symlink"

rm "$installed_desktop"
HOME="$refresh_home" PATH="$refresh_bin:$PATH" OMARCHY_PATH="$refresh_root" \
  "$ROOT/bin/omarchy-refresh-applications"

cmp -s "$ghostty_desktop" "$installed_desktop" ||
  fail "application refresh installs the Ghostty desktop entry when missing"
pass "application refresh installs the Ghostty desktop entry when missing"
