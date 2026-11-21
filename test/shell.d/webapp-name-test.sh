#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/home"

for stub in gtk-update-icon-cache update-desktop-database omarchy-notification-send; do
  printf '#!/bin/bash\n:\n' >"$tmp_dir/bin/$stub"
  chmod +x "$tmp_dir/bin/$stub"
done

run_install() {
  HOME="$tmp_dir/home" PATH="$tmp_dir/bin:$PATH" \
    "$ROOT/bin/omarchy-webapp-install" "$@"
}

run_remove() {
  HOME="$tmp_dir/home" PATH="$tmp_dir/bin:$PATH" OMARCHY_REMOVE_NOTIFY=false \
    "$ROOT/bin/omarchy-webapp-remove" "$@"
}

run_remove_all() {
  HOME="$tmp_dir/home" PATH="$tmp_dir/bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-webapp-remove-all" "$@"
}

apps_dir="$tmp_dir/home/.local/share/applications"
icons_dir="$tmp_dir/home/.local/share/icons/hicolor/256x256/apps"

# A URL typed into the name field is the reported way in. Every slash used to
# become a directory level, leaving a launcher nothing could address. Assert on
# the message: creating the launcher directly in the applications directory
# already makes the redirect fail on its own, so a bare non-zero exit would pass
# just as well with no validation at all.
output=$(run_install "http://example.test/oops" "https://example.com" hey 2>&1) &&
  fail "webapp install rejects a name containing a slash"
[[ $output == *"App name cannot contain '/'"* ]] ||
  fail "webapp install says why it refused a slashed name" "$output"
[[ -e "$apps_dir/http:" ]] &&
  fail "webapp install does not create a directory from a slashed name"
pass "webapp install rejects a name that would nest the launcher"

# The name was a path fragment until something said otherwise, so ../ climbed
# out of the applications directory entirely and wrote wherever it landed.
if run_install "../../../../escaped" "https://example.com" hey >/dev/null 2>&1; then
  fail "webapp install rejects a name that climbs out of the applications directory"
fi
[[ -e "$tmp_dir/escaped.desktop" ]] &&
  fail "webapp install writes no launcher outside the applications directory"
pass "webapp install refuses a name that would escape the applications directory"

# The interactive prompt reads the name long before it is used as a path, and
# fetches the site icon in between. Rejecting only at the write leaves that icon
# behind in the user's icon theme, once per attempt.
mkdir -p "$tmp_dir/ibin"
cp "$tmp_dir/bin"/* "$tmp_dir/ibin/"
cat >"$tmp_dir/ibin/gum" <<'STUB'
#!/bin/bash
count_file="${GUM_STUB_COUNT:?}"
count=$(cat "$count_file" 2>/dev/null || echo 0)
count=$((count + 1))
echo "$count" >"$count_file"
if (( count == 1 )); then
  echo "http://example.test/oops"
else
  echo "https://example.com"
fi
STUB
cat >"$tmp_dir/ibin/curl" <<'STUB'
#!/bin/bash
# Answer any download with a real PNG so the icon fetch reports success.
out=""
prev=""
for arg in "$@"; do
  [[ $prev == "-o" ]] && out="$arg"
  prev="$arg"
done
if [[ -n $out ]]; then
  printf '%s' 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' | base64 -d >"$out"
fi
STUB
chmod +x "$tmp_dir/ibin/gum" "$tmp_dir/ibin/curl"

if HOME="$tmp_dir/home" PATH="$tmp_dir/ibin:$PATH" \
  GUM_STUB_COUNT="$tmp_dir/gum-count" \
  "$ROOT/bin/omarchy-webapp-install" >/dev/null 2>&1; then
  fail "interactive webapp install rejects a name containing a slash"
fi
if compgen -G "$icons_dir/*.png" >/dev/null; then
  fail "interactive webapp install downloads no icon for a name it refuses" \
    "$(ls "$icons_dir")"
fi
pass "webapp install refuses a slashed name before fetching its icon"

# A normal name still installs and removes.
run_install "Example App" "https://example.com" hey >/dev/null
[[ -f "$apps_dir/Example App.desktop" ]] ||
  fail "webapp install writes the launcher for an ordinary name"
run_remove "Example App" >/dev/null
[[ -f "$apps_dir/Example App.desktop" ]] &&
  fail "webapp remove deletes the launcher it installed"
pass "webapp install and remove round-trip an ordinary name"

# Anything installed by an older version can still be nested. Removal has to
# reach it, which a path rebuilt from the displayed name never could.
mkdir -p "$apps_dir/http:/127.0.0.1:4000"
cat >"$apps_dir/http:/127.0.0.1:4000/.desktop" <<'DESKTOP'
[Desktop Entry]
Name=http://127.0.0.1:4000
Exec=omarchy-launch-webapp https://127.0.0.1:4000
Type=Application
DESKTOP

# This is the name the picker shows for that file: the script strips .desktop
# from the path and then takes the basename, which lands on the directory.
run_remove "127.0.0.1:4000" >/dev/null
[[ -f "$apps_dir/http:/127.0.0.1:4000/.desktop" ]] &&
  fail "webapp remove deletes a launcher left nested by an older install"
pass "webapp remove reaches a nested legacy launcher"

# Removing by name on a machine with no applications directory yet must stay
# quiet: omarchy-remove-gaming-xbox-cloud calls it without hiding stderr.
noise=$(HOME="$tmp_dir/empty" PATH="$tmp_dir/bin:$PATH" OMARCHY_REMOVE_NOTIFY=false \
  "$ROOT/bin/omarchy-webapp-remove" "Xbox Cloud Gaming" 2>&1 >/dev/null)
[[ -n $noise ]] &&
  fail "webapp remove stays quiet with no applications directory" "$noise"
pass "webapp remove stays quiet when there is no applications directory"

# Local icon files keep their format during installation. Removing the app
# must clean up each format supported by the icon theme, not just PNG files.
printf '%s' 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' |
  base64 -d >"$tmp_dir/icon.png"
printf '%s\n' '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24"><rect width="24" height="24" fill="blue"/></svg>' >"$tmp_dir/icon.svg"
cat >"$tmp_dir/icon.xpm" <<'XPM'
/* XPM */
static char *icon[] = {"1 1 1 1", "b c blue", "b"};
XPM

mkdir -p "$icons_dir"
for extension in png svg xpm; do
  app_name="Local $extension"
  icon_file="$icons_dir/local-$extension.$extension"
  neighbor="$icons_dir/local-$extension-other.$extension"
  backup="$icon_file.bak"
  cp "$tmp_dir/icon.$extension" "$neighbor"
  cp "$tmp_dir/icon.$extension" "$backup"

  run_install "$app_name" "https://example.com" "$tmp_dir/icon.$extension" >/dev/null
  cmp -s "$tmp_dir/icon.$extension" "$icon_file" ||
    fail "webapp install copies the local $extension icon"
  run_remove "$app_name" >/dev/null

  [[ ! -e $icon_file ]] || fail "webapp remove deletes its local $extension icon"
  [[ ! -e $apps_dir/$app_name.desktop ]] || fail "webapp remove deletes the $extension launcher"
  cmp -s "$tmp_dir/icon.$extension" "$neighbor" ||
    fail "webapp remove preserves a neighboring $extension icon"
  cmp -s "$tmp_dir/icon.$extension" "$backup" ||
    fail "webapp remove preserves the $extension icon backup"
  pass "webapp remove cleans up its local $extension icon and preserves neighboring icons and backups"
done

# Bulk removal must clean up the same formats and leave ordinary launchers alone.
printf '%s\n' '[Desktop Entry]' 'Name=Unrelated App' 'Exec=foot' 'Type=Application' >"$tmp_dir/unrelated.desktop"
cp "$tmp_dir/unrelated.desktop" "$apps_dir/Unrelated App.desktop"
for extension in png svg xpm; do
  run_install "Local $extension" "https://example.com" "$tmp_dir/icon.$extension" >/dev/null
done
run_remove_all "$apps_dir" >/dev/null
cmp -s "$tmp_dir/unrelated.desktop" "$apps_dir/Unrelated App.desktop" ||
  fail "webapp remove-all preserves an ordinary launcher"
for extension in png svg xpm; do
  app_name="Local $extension"
  icon_file="$icons_dir/local-$extension.$extension"
  [[ ! -e $icon_file ]] || fail "webapp remove-all deletes its local $extension icon"
  [[ ! -e $apps_dir/$app_name.desktop ]] || fail "webapp remove-all deletes the $extension launcher"
  cmp -s "$tmp_dir/icon.$extension" "$icons_dir/local-$extension-other.$extension" ||
    fail "webapp remove-all preserves a neighboring $extension icon"
  cmp -s "$tmp_dir/icon.$extension" "$icon_file.bak" ||
    fail "webapp remove-all preserves the $extension icon backup"
  pass "webapp remove-all cleans up its local $extension icon and preserves neighboring icons and backups"
done
