#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# An installed launcher gets a real icon or the install says so, and removing
# the launcher takes its icon with it whatever format the icon has.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export OMARCHY_PATH="$ROOT"
export XDG_CURRENT_DESKTOP=Hyprland
# The icon search follows the data directories the desktop searches, so the
# test owns them: the data home follows the fake home, and the data
# directories hold only what this file puts there.
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_DATA_DIRS="$test_tmp/data"
mkdir -p "$HOME" "$test_tmp/bin" "$test_tmp/icons"

# A real one pixel PNG, so the icon check sees an image and not a body.
printf '%s' 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' | base64 -d >"$test_tmp/icon.png"

# The endpoint answers, so the download is exercised without a network. A 404
# answers with a body and exits 0, which is what the install has to catch.
cat >"$test_tmp/bin/curl" <<SH
#!/bin/bash
dest=""
url=""
while (( \$# )); do
  case \$1 in
    -o) dest=\$2; shift 2 ;;
    -*) shift ;;
    *) url=\$1; shift ;;
  esac
done
case "\$url" in
  *notfound*) printf '404: Not Found\n' >"\$dest"; exit 0 ;;
  *notimage*) printf 'this is not an image\n' >"\$dest"; exit 0 ;;
  *) cp "$test_tmp/icon.png" "\$dest"; exit 0 ;;
esac
SH
chmod +x "$test_tmp/bin/curl"

# The desktop database updater is not needed to exercise the icon handling,
# and it is not installed everywhere, so the test brings its own.
cat >"$test_tmp/bin/update-desktop-database" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$test_tmp/bin/update-desktop-database"

export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

install_tui() {
  "$ROOT/bin/omarchy-tui-install" "$@"
}

icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
desktop_file() {
  printf '%s\n' "$HOME/.local/share/applications/$1.desktop"
}

# A URL that answers with an error body must not install that body as the
# icon, and the launcher must not be written either.
output=$(install_tui T1 true tile "https://example.invalid/notfound.png" 2>&1) && status=0 || status=$?
(( status != 0 )) || fail "an icon URL that answers with an error body fails the install" "$output"
[[ ! -e $icon_dir/t1.png ]] || fail "an icon URL that answers with an error body leaves no icon" "$(ls "$icon_dir")"
[[ ! -e $(desktop_file T1) ]] || fail "an icon URL that answers with an error body writes no launcher"
pass "an icon URL that answers with an error body fails the install"

# A URL that answers with something that is not an image is the same failure.
output=$(install_tui T2 true tile "https://example.invalid/notimage.png" 2>&1) && status=0 || status=$?
(( status != 0 )) || fail "an icon URL that answers with something else fails the install" "$output"
[[ ! -e $icon_dir/t2.png ]] || fail "an icon URL that answers with something else leaves no icon" "$(ls "$icon_dir")"
pass "an icon URL that answers with something else fails the install"

# A URL that answers with an image installs that image.
install_tui T3 true tile "https://example.invalid/icon.png" >/dev/null
[[ -s $icon_dir/t3.png ]] || fail "an icon URL that answers with an image installs it" "$(ls "$icon_dir")"
# The answer is written to a temporary file, which is owner-only, and the icon
# is moved into place, so the icon has to be readable like the one a direct
# download would have written.
[[ $(stat -c '%a' "$icon_dir/t3.png") == 644 ]] ||
  fail "the installed icon is readable" "$(stat -c '%a' "$icon_dir/t3.png")"
pass "an icon URL that answers with an image installs it"

# A name that resolves to no icon in the theme is reported, and the launcher
# is still written so the app can be started.
missing="omarchy-test-missing-4f7c2a"
output=$(install_tui T4 true tile "$missing" 2>&1) && status=0 || status=$?
(( status == 0 )) || fail "a name that resolves to no icon still installs the launcher" "$output"
[[ $output == *"$missing"* ]] || fail "a name that resolves to no icon is reported" "$output"
grep -qx "Icon=$missing" "$(desktop_file T4)" || fail "the launcher keeps the icon name it was given" "$(cat "$(desktop_file T4)")"
pass "a name that resolves to no icon is reported"

# A failed reinstall leaves the icon that was installed before it alone.
install_tui T8 true tile "https://example.invalid/icon.png" >/dev/null
[[ -s $icon_dir/t8.png ]] || fail "the first install writes the icon" "$(ls "$icon_dir")"
cp "$icon_dir/t8.png" "$test_tmp/kept-icon.png"
output=$(install_tui T8 true tile "https://example.invalid/notfound.png" 2>&1) && status=0 || status=$?
(( status != 0 )) || fail "a reinstall with a broken icon URL fails" "$output"
cmp -s "$icon_dir/t8.png" "$test_tmp/kept-icon.png" ||
  fail "a failed reinstall keeps the installed icon" "$(file -b "$icon_dir/t8.png")"
pass "a failed reinstall keeps the installed icon"

# The answer is written to a temporary file beside the icon, and the icon
# directory is left holding only the icons that belong there.
[[ $(ls -A "$icon_dir" | grep -c 't[0-9]*\.png\.' || true) == 0 ]] ||
  fail "a failed download leaves no temporary file behind" "$(ls -A "$icon_dir")"
pass "a failed download leaves no temporary file behind"

# An icon the desktop finds in a configured data directory is found here too.
mkdir -p "$test_tmp/data/icons/hicolor/256x256/apps"
cp "$test_tmp/icon.png" "$test_tmp/data/icons/hicolor/256x256/apps/data-dir-icon.png"
output=$(XDG_DATA_DIRS="$test_tmp/data" install_tui T9 true tile data-dir-icon 2>&1) && status=0 || status=$?
[[ $output != *'No icon named'* ]] || fail "an icon in a configured data directory is found" "$output"
pass "an icon in a configured data directory is found"

# A file whose name starts with the icon name is indexed under its own name,
# so it does not answer for the name that was asked for.
# A theme entry is often a symbolic link to the real image, and the search
# has to see through it, the way the desktop does.
ln -sf "$test_tmp/icon.png" "$icon_dir/linked-icon.png"
output=$(install_tui T11 true tile linked-icon 2>&1) && status=0 || status=$?
[[ $output != *'No icon named'* ]] || fail "an icon the theme links to is found" "$output"
rm -f "$icon_dir/linked-icon.png"
pass "an icon the theme links to is found"

cp "$test_tmp/icon.png" "$icon_dir/prefixed.other.png"
output=$(install_tui T10 true tile prefixed 2>&1) && status=0 || status=$?
[[ $output == *'No icon named'* ]] || fail "a name that is a prefix of another is reported" "$output"
rm -f "$icon_dir/prefixed.other.png"
pass "a name that is a prefix of another is reported"

# A name that is not an icon at all is reported too, even when the icon
# directory holds a dotfile the search would otherwise match.
printf 'hidden\n' >"$icon_dir/.hidden"
output=$(install_tui T7 true tile . 2>&1) && status=0 || status=$?
(( status == 0 )) || fail "a name that is not an icon still installs the launcher" "$output"
[[ $output == *'No icon named'* ]] || fail "a name that is not an icon is reported" "$output"
rm -f "$icon_dir/.hidden"
pass "a name that is not an icon is reported"

# A name that does resolve is not reported.
mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
cp "$test_tmp/icon.png" "$HOME/.local/share/icons/hicolor/256x256/apps/known-icon.png"
output=$(install_tui T5 true tile known-icon 2>&1) && status=0 || status=$?
(( status == 0 )) || fail "a name that resolves to an icon installs the launcher" "$output"
[[ $output != *known-icon* ]] || fail "a name that resolves to an icon is not reported" "$output"
pass "a name that resolves to an icon is not reported"

# A local icon keeps its format, and removing the launcher takes it away.
printf '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><rect width="16" height="16" fill="red"/></svg>' >"$test_tmp/local.svg"
install_tui T6 true tile "$test_tmp/local.svg" >/dev/null
[[ -e $icon_dir/t6.svg ]] || fail "a local icon is installed with its own format" "$(ls "$icon_dir")"
OMARCHY_REMOVE_NOTIFY=false "$ROOT/bin/omarchy-tui-remove" T6 >/dev/null 2>&1
[[ ! -e $icon_dir/t6.svg ]] || fail "removing a launcher removes its icon" "$(ls "$icon_dir")"
[[ ! -e $(desktop_file T6) ]] || fail "removing a launcher removes the launcher"
pass "removing a launcher removes its icon"

# The web app launcher has the same icon to take away.
cp "$test_tmp/local.svg" "$test_tmp/webapp.svg"
install_tui W1 true tile "$test_tmp/webapp.svg" >/dev/null
cp "$test_tmp/webapp.svg" "$icon_dir/w1.svg"
cat >"$HOME/.local/share/applications/W1.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=W1
Exec=omarchy-launch-webapp https://example.com
Icon=w1
EOF
OMARCHY_REMOVE_NOTIFY=false "$ROOT/bin/omarchy-webapp-remove" W1 >/dev/null 2>&1
[[ ! -e $icon_dir/w1.svg ]] || fail "removing a web app removes its icon" "$(ls "$icon_dir")"
pass "removing a web app removes its icon"

# A name the user typed can hold a glob or a path, so it is never matched as
# one: the icons of the other apps stay where they are.
cp "$test_tmp/icon.png" "$icon_dir/other-app.png"
printf 'hidden\n' >"$icon_dir/.hidden"
OMARCHY_REMOVE_NOTIFY=false "$ROOT/bin/omarchy-tui-remove" 'T*' >/dev/null 2>&1
[[ -e $icon_dir/other-app.png ]] || fail "a name with a glob removes no other icon" "$(ls -a "$icon_dir")"
[[ -e $icon_dir/.hidden ]] || fail "a name with a glob removes no hidden file" "$(ls -a "$icon_dir")"
OMARCHY_REMOVE_NOTIFY=false "$ROOT/bin/omarchy-tui-remove" '!!!' >/dev/null 2>&1
[[ -e $icon_dir/other-app.png ]] || fail "a name without a letter removes no other icon" "$(ls -a "$icon_dir")"
[[ -e $icon_dir/.hidden ]] || fail "a name without a letter removes no hidden file" "$(ls -a "$icon_dir")"
pass "a name the user typed never removes another icon"
