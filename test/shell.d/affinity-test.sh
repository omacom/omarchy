#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

log="$tmp_dir/log"
: >"$log"

# The installer and remover shell out to package, MIME, icon, and desktop
# helpers; the sandbox has none of them, and the real ones would touch the
# developer's own machine.
for command in omarchy-pkg-aur-add omarchy-pkg-drop update-mime-database update-desktop-database gtk-update-icon-cache; do
  cat >"$tmp_dir/bin/$command" <<'SCRIPT'
#!/bin/bash
printf '%s:%s\n' "${0##*/}" "$*" >>"$TEST_LOG"
SCRIPT
  chmod +x "$tmp_dir/bin/$command"
done

cat >"$tmp_dir/bin/xdg-mime" <<'SCRIPT'
#!/bin/bash
printf 'xdg-mime:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin/xdg-mime"

# omarchy-cmd-present is a real Omarchy command, but the test's PATH does not
# include bin/; stub it to answer for omarchy-launch-affinity only.
cat >"$tmp_dir/bin/omarchy-cmd-present" <<'SCRIPT'
#!/bin/bash
[[ $1 == "omarchy-launch-affinity" ]]
SCRIPT
chmod +x "$tmp_dir/bin/omarchy-cmd-present"

cat >"$tmp_dir/bin/omarchy-launch-affinity" <<'SCRIPT'
#!/bin/bash
printf 'launch-affinity:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin/omarchy-launch-affinity"

cat >"$tmp_dir/bin/pgrep" <<'SCRIPT'
#!/bin/bash
exit 1
SCRIPT
chmod +x "$tmp_dir/bin/pgrep"

export TEST_LOG="$log"
export PATH="$tmp_dir/bin:$PATH"
export OMARCHY_PATH="$ROOT"

install_script="$ROOT/bin/omarchy-install-creative-affinity"
remove_script="$ROOT/bin/omarchy-remove-creative-affinity"

# The installer's metadata drives both the CLI router and the menu's sudo
# handoff; a missing summary fails test/cli, and a missing sudo flag would run
# the AUR install without a password prompt.
for script in "$install_script" "$remove_script"; do
  grep -q '^# omarchy:summary=' "$script" ||
    fail "${script##*/} declares a summary"
  grep -qx '# omarchy:requires-sudo=true' "$script" ||
    fail "${script##*/} declares it needs sudo"
done
pass "Affinity install and remove commands carry their metadata"

xml="$ROOT/default/applications/affinity-filetypes.xml"
xml_types=$(grep -c '<mime-type type=' "$xml" || true)
[[ $xml_types == 16 ]] ||
  fail "Affinity MIME definitions declare all 16 types" "$xml_types"
pass "Affinity MIME definitions declare all 16 types"

# The opener must still open a file on a machine where omarchy-launch-affinity
# is absent (a packaged install predating this command, or a partial setup):
# falling through to the AppImage is what keeps the association working.
opener="$ROOT/default/applications/affinity-open"
grep -q 'omarchy-cmd-present omarchy-launch-affinity' "$opener" ||
  fail "affinity-open checks for the Omarchy launcher before using it"
grep -q 'exec /usr/bin/affinity' "$opener" ||
  fail "affinity-open falls back to the AppImage without the Omarchy launcher"
pass "affinity-open falls back to the AppImage when the Omarchy launcher is missing"

fresh_home() {
  rm -rf "$tmp_dir/home"
  mkdir -p "$tmp_dir/home"
  export HOME="$tmp_dir/home"
}

# A file manager hands the opener a path; Wine needs it as a Z:\ path because
# the AppImage's prefix maps z: to /.
touch "$tmp_dir/artwork.afphoto"
: >"$log"
"$opener" "$tmp_dir/artwork.afphoto"
expected_launch="launch-affinity:Z:${tmp_dir//\//\\}\\artwork.afphoto"
grep -Fxq "$expected_launch" "$log" ||
  fail "affinity-open converts a Unix path to a Wine Z: path" "$(cat "$log")"
pass "affinity-open converts a Unix path to a Wine Z: path"

fresh_home
"$install_script" >/dev/null

[[ -x $HOME/.local/bin/affinity-open ]] ||
  fail "Affinity install lands the opener on PATH"
[[ -f $HOME/.local/share/mime/packages/affinity-filetypes.xml ]] ||
  fail "Affinity install lands the MIME definitions"
[[ -f $HOME/.local/share/applications/affinity.desktop ]] ||
  fail "Affinity install lands the desktop entry"
[[ -f $HOME/.local/share/icons/hicolor/512x512/apps/affinity.png ]] ||
  fail "Affinity install lands the icon the desktop entry names"
pass "Affinity install lands the opener, MIME definitions, desktop entry, and icon"

desktop="$HOME/.local/share/applications/affinity.desktop"
grep -qx 'Exec=affinity-open %F' "$desktop" ||
  fail "Affinity desktop entry opens files through the opener" "$(cat "$desktop")"
grep -qx 'Icon=affinity' "$desktop" ||
  fail "Affinity desktop entry names the packaged icon" "$(cat "$desktop")"
grep -q '^MimeType=application/af;.*application/afstyles;$' "$desktop" ||
  fail "Affinity desktop entry advertises every MIME type" "$(cat "$desktop")"
pass "Affinity desktop entry opens files and advertises their types"

grep -qx 'omarchy-pkg-aur-add:affinity-appimage-bin' "$log" ||
  fail "Affinity install adds the AUR package"
grep -q '^update-mime-database:' "$log" ||
  fail "Affinity install refreshes the MIME database"
(( $(grep -c '^xdg-mime:default affinity.desktop application/' "$log") == 16 )) ||
  fail "Affinity install sets the default handler for all 16 types" "$(cat "$log")"
pass "Affinity install registers the package and every default handler"

# The remover has to undo the defaults the installer wrote, or the types keep
# pointing at a desktop entry that no longer exists.
mkdir -p "$HOME/.config"
{
  printf '[Default Applications]\n'
  printf 'application/af=affinity.desktop\n'
  printf 'application/afphoto=affinity.desktop\n'
  printf 'text/plain=nvim.desktop\n'
} >"$HOME/.config/mimeapps.list"

: >"$log"
"$remove_script" >/dev/null

for gone in .local/bin/affinity-open \
  .local/share/mime/packages/affinity-filetypes.xml \
  .local/share/applications/affinity.desktop \
  .local/share/icons/hicolor/512x512/apps/affinity.png; do
  [[ ! -e $HOME/$gone ]] || fail "Affinity removal deletes the files it installed" "$gone"
done
pass "Affinity removal deletes the files it installed"

grep -qx 'omarchy-pkg-drop:affinity-appimage-bin' "$log" ||
  fail "Affinity removal drops the AUR package"
! grep -q '^application/af=affinity.desktop$' "$HOME/.config/mimeapps.list" ||
  fail "Affinity removal clears the default handlers it set"
grep -qx 'text/plain=nvim.desktop' "$HOME/.config/mimeapps.list" ||
  fail "Affinity removal leaves unrelated defaults alone"
pass "Affinity removal drops the package and clears only its own defaults"

# The launcher computes the Wine system DPI from the focused monitor scale and
# writes it into the prefix's registry. Its own commands are stubbed so the test
# never touches the developer's Hyprland session or Affinity install.
launcher="$ROOT/bin/omarchy-launch-affinity"

cat >"$tmp_dir/bin/hyprctl" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "${AFFINITY_TEST_MONITORS-1.25}"
SCRIPT
chmod +x "$tmp_dir/bin/hyprctl"

cat >"$tmp_dir/bin/jq" <<'SCRIPT'
#!/bin/bash
# The launcher only uses jq to read the focused scale and to multiply it.
# Answer both shapes without depending on the real jq being installed. The
# unset-only default keeps an explicitly empty scale empty, which is what a
# failed hyprctl produces.
if [[ $* == *"select(.focused"* ]]; then
  cat >/dev/null
  printf '%s\n' "${AFFINITY_TEST_MONITORS-1.25}"
else
  awk -v scale="${AFFINITY_TEST_MONITORS-1.25}" 'BEGIN { printf "%d\n", scale * 96 + 0.5 }'
fi
SCRIPT
chmod +x "$tmp_dir/bin/jq"

cat >"$tmp_dir/bin/pgrep" <<'SCRIPT'
#!/bin/bash
exit "${AFFINITY_TEST_RUNNING:-1}"
SCRIPT
chmod +x "$tmp_dir/bin/pgrep"

cat >"$tmp_dir/bin/affinity" <<'SCRIPT'
#!/bin/bash
printf 'affinity:%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin/affinity"

launcher_home="$tmp_dir/launcher-home"
winereg_dir="$launcher_home/.AffinityLinux-Appimage"
mkdir -p "$winereg_dir"
printf '"LogPixels"=dword:00000060\n' >"$winereg_dir/user.reg"
printf '"LogPixels"=dword:00000060\n' >"$winereg_dir/system.reg"

run_launcher() {
  HOME="$launcher_home" \
    PATH="$tmp_dir/bin:$PATH" \
    OMARCHY_AFFINITY_BIN="$tmp_dir/bin/affinity" \
    TEST_LOG="$log" \
    "$launcher" "$@"
}

# 1.25 scale -> 120 DPI -> 0x78.
: >"$log"
run_launcher
grep -q '"LogPixels"=dword:00000078' "$winereg_dir/user.reg" ||
  fail "Affinity launcher scales DPI to the focused monitor" "$(cat "$winereg_dir/user.reg")"
grep -q '"LogPixels"=dword:00000078' "$winereg_dir/system.reg" ||
  fail "Affinity launcher scales DPI in both registry files"
grep -qx 'affinity:' "$log" ||
  fail "Affinity launcher starts the app after writing DPI" "$(cat "$log")"
pass "Affinity launcher scales DPI to the focused monitor"

# The override wins over the computed value: 96 -> 0x60.
: >"$log"
printf '"LogPixels"=dword:00000078\n' >"$winereg_dir/user.reg"
printf '"LogPixels"=dword:00000078\n' >"$winereg_dir/system.reg"
HOME="$launcher_home" \
  PATH="$tmp_dir/bin:$PATH" \
  OMARCHY_AFFINITY_BIN="$tmp_dir/bin/affinity" \
  OMARCHY_AFFINITY_DPI=96 \
  TEST_LOG="$log" \
  "$launcher" >/dev/null
grep -q '"LogPixels"=dword:00000060' "$winereg_dir/user.reg" ||
  fail "Affinity launcher honors the DPI override" "$(cat "$winereg_dir/user.reg")"
pass "Affinity launcher honors the DPI override"

# A running Affinity must not block or rewrite the registry: the live window
# already has its DPI, and the running wineserver would clobber the edit.
: >"$log"
printf '"LogPixels"=dword:00000060\n' >"$winereg_dir/user.reg"
printf '"LogPixels"=dword:00000060\n' >"$winereg_dir/system.reg"
HOME="$launcher_home" \
  PATH="$tmp_dir/bin:$PATH" \
  OMARCHY_AFFINITY_BIN="$tmp_dir/bin/affinity" \
  AFFINITY_TEST_RUNNING=0 \
  TEST_LOG="$log" \
  "$launcher" >/dev/null
grep -q '"LogPixels"=dword:00000060' "$winereg_dir/user.reg" ||
  fail "Affinity launcher leaves the registry alone while Affinity runs"
grep -qx 'affinity:' "$log" ||
  fail "Affinity launcher forwards to the running instance"
pass "Affinity launcher forwards without blocking while Affinity runs"

# A failed hyprctl leaves the scale empty; the launcher must not write DPI 0.
: >"$log"
printf '"LogPixels"=dword:00000060\n' >"$winereg_dir/user.reg"
printf '"LogPixels"=dword:00000060\n' >"$winereg_dir/system.reg"
HOME="$launcher_home" \
  PATH="$tmp_dir/bin:$PATH" \
  OMARCHY_AFFINITY_BIN="$tmp_dir/bin/affinity" \
  AFFINITY_TEST_MONITORS="" \
  TEST_LOG="$log" \
  "$launcher" >/dev/null
grep -q '"LogPixels"=dword:00000060' "$winereg_dir/user.reg" ||
  fail "Affinity launcher refuses to write a zero DPI" "$(cat "$winereg_dir/user.reg")"
pass "Affinity launcher refuses to write a zero DPI"

# The window rules keep Affinity's canvas opaque, and deliberately do not
# center it: Wine draws each menu-bar dropdown as its own top-level window that
# no rule can tell from a real dialog, so centering lands the menus in the
# middle of the screen instead of under File/Edit.
apps_rule="$ROOT/default/hypr/apps/affinity.lua"
[[ -f $apps_rule ]] || fail "Affinity window rules are shipped"
grep -q 'center = true' "$apps_rule" &&
  fail "Affinity window rules leave the menus where Wine puts them" "$(cat "$apps_rule")"
grep -q 'tag = "-default-opacity"' "$apps_rule" ||
  fail "Affinity window rules keep the canvas opaque"
pass "Affinity window rules keep the canvas opaque without centering the menus"
