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
if [[ $1 == "-Qqo" && $2 == */native.desktop ]]; then
  printf 'native-pkg\n'
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

cat >"$tmp_dir/system/applications/native.desktop" <<DESKTOP
[Desktop Entry]
Name=Native
Exec=$tmp_dir/home/.config/omarchy/plugins/native/bin/native
DESKTOP

cat >"$tmp_dir/data/applications/aliens.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Aliens
Exec=retroarch -L /usr/lib/libretro/fbneo_libretro.so /home/example/Games/roms/fbneo/aliens.zip
DESKTOP

mkdir -p "$tmp_dir/home/.config/omarchy/plugins/omamail/icons"
touch "$tmp_dir/home/.config/omarchy/plugins/omamail/icons/app.png"
cat >"$tmp_dir/data/applications/omamail.desktop" <<DESKTOP
[Desktop Entry]
Name=Omamail
Exec="$tmp_dir/home/.config/omarchy/plugins/omamail/scripts/mailto.sh" %u
MimeType=x-scheme-handler/mailto;
DESKTOP

mkdir -p "$tmp_dir/home/.config/omarchy/plugins/omacom.mail/bin"
touch "$tmp_dir/home/.config/omarchy/plugins/omacom.mail/bin/handler"
cat >"$tmp_dir/data/applications/mail-handler.desktop" <<DESKTOP
[Desktop Entry]
Name=Mail Handler
Exec=$tmp_dir/home/.config/omarchy/plugins/omacom.mail/bin/handler %u
DESKTOP

cat >"$tmp_dir/data/applications/borrowed-icon.desktop" <<DESKTOP
[Desktop Entry]
Name=Borrowed Icon
Exec=true
Icon=$tmp_dir/home/.config/omarchy/plugins/omamail/icons/app.png
DESKTOP

mkdir -p "$tmp_dir/dev/linked/bin"
ln -s "$tmp_dir/dev/linked" "$tmp_dir/home/.config/omarchy/plugins/linked.widget"
cat >"$tmp_dir/data/applications/linked.desktop" <<DESKTOP
[Desktop Entry]
Name=Linked
Exec = $tmp_dir/home/.config/omarchy/plugins/linked.widget/bin/run
DESKTOP

mkdir -p "$tmp_dir/home/.config/omarchy/plugins/notes"
cat >"$tmp_dir/data/applications/notes.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Notes
Exec=/usr/bin/notes
DESKTOP

cat >"$tmp_dir/data/applications/editor.desktop" <<DESKTOP
[Desktop Entry]
Name=Editor
Exec=/usr/bin/editor
Path=$tmp_dir/home/.config/omarchy/plugins/omacom.mail

[Desktop Action helper]
Exec=$tmp_dir/home/.config/omarchy/plugins/omacom.mail/bin/handler
DESKTOP

cat >"$tmp_dir/data/applications/escape.desktop" <<DESKTOP
[Desktop Entry]
Name=Escape
Exec="$tmp_dir/home/.config/omarchy/plugins/notes/bin dir/../../../../../usr/bin/run" %u
DESKTOP

mkdir -p "$tmp_dir/home/.config/omarchy/plugins/native"

write_fake_command omarchy-plugin-remove plugin

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export XDG_DATA_HOME="$tmp_dir/data"
export XDG_DATA_DIRS="$tmp_dir/system"
export XDG_CONFIG_HOME="$tmp_dir/config"
export HOME="$tmp_dir/home"

"$ROOT/bin/omarchy-remove-launcher-entry" Basecamp.desktop Basecamp
"$ROOT/bin/omarchy-remove-launcher-entry" Docker.desktop Docker
"$ROOT/bin/omarchy-remove-launcher-entry" native.desktop Native
"$ROOT/bin/omarchy-remove-launcher-entry" aliens.desktop Aliens
"$ROOT/bin/omarchy-remove-launcher-entry" omamail.desktop Omamail
"$ROOT/bin/omarchy-remove-launcher-entry" mail-handler.desktop "Mail Handler"
"$ROOT/bin/omarchy-remove-launcher-entry" linked.desktop Linked
"$ROOT/bin/omarchy-remove-launcher-entry" borrowed-icon.desktop "Borrowed Icon"
"$ROOT/bin/omarchy-remove-launcher-entry" notes.desktop Notes
"$ROOT/bin/omarchy-remove-launcher-entry" editor.desktop Editor
"$ROOT/bin/omarchy-remove-launcher-entry" escape.desktop Escape

mapfile -t lines <"$TEST_LOG"

[[ ${lines[0]} == "web:false:Basecamp" ]] || fail "launcher remove routes web apps by desktop name" "${lines[0]}"
pass "launcher remove routes web apps by desktop name"

[[ ${lines[1]} == "tui:false:Docker" ]] || fail "launcher remove routes TUIs by desktop name" "${lines[1]}"
pass "launcher remove routes TUIs by desktop name"

[[ ${lines[2]} == "terminal::echo Uninstalling Native...; sudo pacman -Rns native-pkg" ]] || fail "launcher remove opens package uninstall flow" "${lines[2]}"
pass "launcher remove opens package uninstall flow"

[[ ! -e $tmp_dir/data/applications/aliens.desktop ]] || fail "launcher remove deletes user-owned desktop files"
pass "launcher remove deletes user-owned desktop files"

[[ ${lines[3]} == "plugin:false:--yes omamail" || ${lines[3]} == "plugin::--yes omamail" ]] ||
  fail "launcher remove detects a quoted executable inside a plugin tree" "${lines[3]}"
pass "launcher remove detects quoted plugin-owned executable paths"

[[ ${lines[4]} == "plugin:false:--yes omacom.mail" || ${lines[4]} == "plugin::--yes omacom.mail" ]] ||
  fail "launcher remove detects an executable inside a plugin tree" "${lines[4]}"
pass "launcher remove detects plugin-owned executable paths"

[[ ${lines[5]} == "plugin:false:--yes linked.widget" || ${lines[5]} == "plugin::--yes linked.widget" ]] ||
  fail "launcher remove detects an executable inside a symlinked plugin" "${lines[5]}"
pass "launcher remove detects executables inside symlinked plugins"

(( ${#lines[@]} == 6 )) || fail "plain user desktop removal emits no extra actions" "$(printf '%s\n' "${lines[@]}")"
pass "plain user desktop removal emits no extra actions"

[[ ! -e $tmp_dir/data/applications/omamail.desktop ]] ||
  fail "launcher remove deletes a plugin desktop file matched by quoted executable"
[[ ! -e $tmp_dir/data/applications/mail-handler.desktop ]] ||
  fail "launcher remove deletes a plugin desktop file matched by executable"
pass "launcher remove deletes plugin desktop files after removing the plugin"

[[ ! -e $tmp_dir/data/applications/borrowed-icon.desktop ]] ||
  fail "Icon-only plugin references remain ordinary user desktop files"
(( $(grep -c '^plugin:' "$TEST_LOG" || true) == 3 )) ||
  fail "Icon= under a plugin tree never implies plugin ownership"
pass "Icon-only references cannot remove a plugin"

[[ ! -e $tmp_dir/data/applications/notes.desktop && ! -e $tmp_dir/data/applications/editor.desktop && ! -e $tmp_dir/data/applications/escape.desktop ]] ||
  fail "a desktop id, Path=, desktop action or path leaving a plugin removes only the desktop file"
pass "a desktop id, Path=, desktop action or path leaving a plugin cannot remove a plugin"
