#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/data/applications" "$tmp_dir/system/applications" "$tmp_dir/bin"

write_fake_command() {
  local name="$1"
  local prefix="$2"

  cat >"$tmp_dir/bin/$name" <<SCRIPT
#!/bin/bash
printf '%s:%s:%s\\n' '$prefix' "\${OMARCHY_REMOVE_NOTIFY:-}" "\$*" >>"\$TEST_LOG"
SCRIPT
  chmod +x "$tmp_dir/bin/$name"
}

write_fake_command omarchy-webapp-remove web
write_fake_command omarchy-tui-remove tui
write_fake_command omarchy-launch-floating-terminal-with-presentation terminal

cat >"$tmp_dir/bin/omarchy-notification-send" <<'SCRIPT'
#!/bin/bash
printf 'notify::%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin/omarchy-notification-send"

cat >"$tmp_dir/bin/update-desktop-database" <<'SCRIPT'
#!/bin/bash
:
SCRIPT
chmod +x "$tmp_dir/bin/update-desktop-database"

cat >"$tmp_dir/bin/pacman" <<'SCRIPT'
#!/bin/bash
if [[ $1 == "-Qqo" ]]; then
  case "$2" in
    */native.desktop) printf 'native-pkg\n' ;;
    */renamed.desktop) printf 'renamed-pkg\n' ;;
  esac
fi
SCRIPT
chmod +x "$tmp_dir/bin/pacman"

cat >"$tmp_dir/data/applications/Basecamp.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Basecamp
Exec=omarchy-launch-webapp https://example.com
DESKTOP

cat >"$tmp_dir/data/applications/Docker.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Docker
Exec=xdg-terminal-exec --app-id=TUI.tile -e lazydocker
DESKTOP

cat >"$tmp_dir/system/applications/native.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Native
Exec=native
DESKTOP

cat >"$tmp_dir/system/applications/renamed.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Original
Exec=renamed
DESKTOP

cat >"$tmp_dir/data/applications/renamed.desktop" <<'DESKTOP'
[Desktop Entry]
X-Omarchy-Renamed=true
Name=Custom Name
Exec=renamed
DESKTOP

cat >"$tmp_dir/data/applications/aliens.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Aliens
Exec=retroarch -L /usr/lib/libretro/fbneo_libretro.so /home/example/Games/roms/fbneo/aliens.zip
DESKTOP

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export XDG_DATA_HOME="$tmp_dir/data"
export XDG_DATA_DIRS="$tmp_dir/system"

"$ROOT/bin/omarchy-remove-launcher-entry" Basecamp.desktop Basecamp
"$ROOT/bin/omarchy-remove-launcher-entry" Docker.desktop Docker
"$ROOT/bin/omarchy-remove-launcher-entry" native.desktop Native
"$ROOT/bin/omarchy-remove-launcher-entry" aliens.desktop Aliens
"$ROOT/bin/omarchy-remove-launcher-entry" renamed.desktop 'Custom Name'

mapfile -t lines <"$TEST_LOG"

[[ ${lines[0]} == "web:false:Basecamp" ]] || fail "launcher remove routes web apps by desktop name" "${lines[0]}"
pass "launcher remove routes web apps by desktop name"

[[ ${lines[1]} == "tui:false:Docker" ]] || fail "launcher remove routes TUIs by desktop name" "${lines[1]}"
pass "launcher remove routes TUIs by desktop name"

[[ ${lines[2]} == "terminal::echo Uninstalling Native...; omarchy-pkg-drop native-pkg" ]] || fail "launcher remove opens package uninstall flow" "${lines[2]}"
pass "launcher remove opens package uninstall flow"

[[ ! -e $tmp_dir/data/applications/aliens.desktop ]] || fail "launcher remove deletes user-owned desktop files"
pass "launcher remove deletes user-owned desktop files"

[[ ${lines[3]} == "terminal::echo Uninstalling Custom\\ Name...; omarchy-pkg-drop renamed-pkg" ]] || fail "launcher remove uninstalls through a managed rename override" "${lines[3]}"
pass "launcher remove uninstalls through a managed rename override"

(( ${#lines[@]} == 4 )) || fail "launcher remove does not notify for user-owned desktop files" "$(printf '%s\n' "${lines[@]}")"
pass "launcher remove does not notify for user-owned desktop files"

cat >"$tmp_dir/data/applications/slack.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Slack
Exec=omarchy-launch-slack --ozone-platform=wayland %U
DESKTOP
"$ROOT/bin/omarchy-remove-launcher-entry" slack.desktop Slack
[[ $(tail -1 "$TEST_LOG") == "terminal::omarchy-remove-service-slack" ]] || fail "the themed Slack launcher opens its package removal flow"
[[ -f $tmp_dir/data/applications/slack.desktop ]] || fail "the override remains until package removal succeeds"
pass "the themed Slack override routes to package removal before any cleanup"

(
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/data/applications" "$tmp_dir/system/applications" "$tmp_dir/bin"

cat >"$tmp_dir/bin/update-desktop-database" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$1" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin/update-desktop-database"

cat >"$tmp_dir/system/applications/org.example.Editor.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Editor
Name[fr]=Éditeur
Comment=Edit files
Exec=editor --open %F
Type=Application

[Desktop Action New]
Name=New document
Exec=editor --new
DESKTOP

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export XDG_DATA_HOME="$tmp_dir/data"
export XDG_DATA_DIRS="$tmp_dir/system"

"$ROOT/bin/omarchy-rename-launcher-entry" org.example.Editor 'Work\Editor = Primary'

renamed="$tmp_dir/data/applications/org.example.Editor.desktop"
[[ -f $renamed ]] || fail "launcher rename creates a user desktop override"
pass "launcher rename creates a user desktop override"

grep -Fx 'Name=Work\\Editor = Primary' "$renamed" >/dev/null || fail "launcher rename escapes the replacement display name"
pass "launcher rename escapes the replacement display name"

grep -Fx 'X-Omarchy-Renamed=true' "$renamed" >/dev/null || fail "launcher rename marks an override of a system entry"
pass "launcher rename marks system overrides for the uninstall path"

[[ $(grep -c '^Name=' "$renamed") == 2 ]] || fail "launcher rename changes only the main desktop-entry name" "$(grep '^Name' "$renamed")"
grep -Fx 'Name=New document' "$renamed" >/dev/null || fail "launcher rename preserves desktop action names"
! grep -q '^Name\[' "$renamed" || fail "launcher rename removes localized names that would override the chosen name"
grep -Fx 'Exec=editor --open %F' "$renamed" >/dev/null || fail "launcher rename preserves launch commands"
pass "launcher rename changes only the application display name"

grep -Fx 'Name=Editor' "$tmp_dir/system/applications/org.example.Editor.desktop" >/dev/null || fail "launcher rename leaves package-owned desktop files untouched"
pass "launcher rename leaves package-owned desktop files untouched"

[[ $(stat -c '%a' "$renamed") == 644 ]] || fail "launcher rename writes a non-executable desktop override"
[[ $(cat "$TEST_LOG") == "$tmp_dir/data/applications" ]] || fail "launcher rename refreshes the user desktop database"
pass "launcher rename installs the override safely"

cp "$renamed" "$tmp_dir/data/applications/no-name.desktop"
sed -i '/^X-Omarchy-Renamed=/d' "$tmp_dir/data/applications/no-name.desktop"
sed -i '/^Name=/d' "$tmp_dir/data/applications/no-name.desktop"
"$ROOT/bin/omarchy-rename-launcher-entry" no-name.desktop 'Added Name'
grep -Fx 'Name=Added Name' "$tmp_dir/data/applications/no-name.desktop" >/dev/null || fail "launcher rename adds a missing main name"
! grep -q '^X-Omarchy-Renamed=' "$tmp_dir/data/applications/no-name.desktop" || fail "launcher rename does not mark an in-place user entry"
pass "launcher rename adds a missing main name"

outside="$tmp_dir/outside.desktop"
printf 'keep\n' >"$outside"
ln -s "$outside" "$tmp_dir/data/applications/symlink.desktop"
if "$ROOT/bin/omarchy-rename-launcher-entry" symlink Changed 2>/dev/null; then
  fail "launcher rename rejects a symlink destination"
fi
[[ $(cat "$outside") == "keep" ]] || fail "launcher rename does not follow a destination symlink"
pass "launcher rename refuses destination symlinks"

if "$ROOT/bin/omarchy-rename-launcher-entry" '../outside' Changed 2>/dev/null; then
  fail "launcher rename rejects path traversal ids"
fi
[[ $(cat "$outside") == "keep" ]] || fail "launcher rename path validation protects files outside the applications directory"
pass "launcher rename rejects path traversal ids"

if "$ROOT/bin/omarchy-rename-launcher-entry" org.example.Editor $'Injected\nExec=bad' 2>/dev/null; then
  fail "launcher rename rejects multiline names"
fi
! grep -q '^Exec=bad$' "$renamed" || fail "launcher rename does not inject desktop-entry keys"
pass "launcher rename rejects desktop-entry injection"


# Desktop IDs ending in .desktop and nested entries follow the app library.
cp "$tmp_dir/system/applications/org.example.Editor.desktop" "$tmp_dir/system/applications/org.telegram.desktop.desktop"
printf '[Desktop Entry]\r\nName=Telegram\r\nExec=telegram\r\n' >"$tmp_dir/system/applications/org.telegram.desktop.desktop"
"$ROOT/bin/omarchy-rename-launcher-entry" org.telegram.desktop Chat
grep -Fxq 'Name=Chat' "$tmp_dir/data/applications/org.telegram.desktop.desktop" || fail "bare IDs ending in .desktop and CRLF entries can be renamed"
mkdir -p "$tmp_dir/system/applications/vendor"
cp "$tmp_dir/system/applications/org.example.Editor.desktop" "$tmp_dir/system/applications/vendor/editor.desktop"
"$ROOT/bin/omarchy-rename-launcher-entry" vendor-editor Nested
grep -Fxq 'Name=Nested' "$tmp_dir/data/applications/vendor-editor.desktop" || fail "nested desktop IDs can be renamed"
pass "launcher lookup handles nested IDs, desktop suffixes and CRLF entries"

# Removing a package's source entries clears every managed copy, while keeping
# overrides whose originals and unrelated user entries are still present.
mkdir -p "$tmp_dir/fallback/applications"
cp "$tmp_dir/system/applications/org.example.Editor.desktop" "$tmp_dir/fallback/applications/org.example.Editor.desktop"
export XDG_DATA_DIRS="$tmp_dir/system:$tmp_dir/fallback"
rm "$tmp_dir/system/applications/org.example.Editor.desktop" "$tmp_dir/system/applications/org.telegram.desktop.desktop"
"$ROOT/bin/omarchy-refresh-launcher-renames"
[[ ! -e $renamed && ! -e $tmp_dir/data/applications/org.telegram.desktop.desktop ]] || fail "removed sources leave no managed copies"
[[ -f $tmp_dir/data/applications/vendor-editor.desktop && -f $tmp_dir/data/applications/no-name.desktop ]] || fail "cleanup preserves existing sources and user-owned entries"
pass "launcher cleanup removes all orphaned managed copies and retains valid entries"

)
