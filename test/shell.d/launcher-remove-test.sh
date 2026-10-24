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

cat >"$tmp_dir/data/applications/borrowed-tryexec.desktop" <<DESKTOP
[Desktop Entry]
Name=Borrowed Availability Check
Exec=/usr/bin/editor
TryExec=$tmp_dir/home/.config/omarchy/plugins/omacom.mail/bin/handler
DESKTOP

# A hand-authored launcher may USE a plugin utility without belonging to it.
mkdir -p "$tmp_dir/home/.config/omarchy/plugins/omamail/scripts"
cat >"$tmp_dir/data/applications/borrowed-plugin.desktop" <<DESKTOP
[Desktop Entry]
Name=Borrowed Plugin Utility
Exec=$tmp_dir/home/.config/omarchy/plugins/omamail/scripts/utility.sh
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

# Model the actual plugin remover's confirmation boundary, not ownership.
cat >"$tmp_dir/bin/omarchy-plugin-remove" <<'STUB'
#!/bin/bash
printf 'plugin:%s:%s\n' "${OMARCHY_REMOVE_NOTIFY:-}" "$*" >>"$TEST_LOG"
[[ ${ALLOW_PLUGIN_REMOVAL:-no} == yes ]]
STUB
chmod +x "$tmp_dir/bin/omarchy-plugin-remove"

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
"$ROOT/bin/omarchy-remove-launcher-entry" borrowed-plugin.desktop "Borrowed Plugin Utility"

actions_before_tryexec=$(cat "$TEST_LOG")
"$ROOT/bin/omarchy-remove-launcher-entry" borrowed-tryexec.desktop "Borrowed Availability Check"
[[ $(cat "$TEST_LOG") == "$actions_before_tryexec" ]] ||
  fail "TryExec-only plugin references do not remove a plugin" "$(cat "$TEST_LOG")"
[[ ! -e $tmp_dir/data/applications/borrowed-tryexec.desktop ]] ||
  fail "TryExec-only plugin references still remove the selected desktop file"
pass "TryExec-only references cannot remove a plugin"

mapfile -t lines <"$TEST_LOG"

[[ ${lines[0]} == "web:false:Basecamp" ]] || fail "launcher remove routes web apps by desktop name" "${lines[0]}"
pass "launcher remove routes web apps by desktop name"

[[ ${lines[1]} == "tui:false:Docker" ]] || fail "launcher remove routes TUIs by desktop name" "${lines[1]}"
pass "launcher remove routes TUIs by desktop name"

[[ ${lines[2]} == "terminal::echo Uninstalling Native...; sudo pacman -Rns native-pkg" ]] || fail "launcher remove opens package uninstall flow" "${lines[2]}"
pass "launcher remove opens package uninstall flow"

[[ ! -e $tmp_dir/data/applications/aliens.desktop ]] || fail "launcher remove deletes user-owned desktop files"
pass "launcher remove deletes user-owned desktop files"

# Inspect the scheduled terminal commands before any confirmation is simulated.
[[ ${lines[3]} == "terminal::omarchy-plugin-remove omamail && rm -f -- "* ]] ||
  fail "quoted plugin executable schedules a confirmation" "${lines[3]}"
[[ ${lines[4]} == "terminal::omarchy-plugin-remove omacom.mail && rm -f -- "* ]] ||
  fail "plugin executable schedules a confirmation" "${lines[4]}"
[[ ${lines[5]} == "terminal::omarchy-plugin-remove linked.widget && rm -f -- "* ]] ||
  fail "symlinked plugin executable schedules a confirmation" "${lines[5]}"
[[ ${lines[6]} == "terminal::omarchy-plugin-remove omamail && rm -f -- "* ]] ||
  fail "a hand-authored launcher never causes automatic plugin removal" "${lines[6]}"
(( ${#lines[@]} == 7 )) ||
  fail "ordinary user launchers emit no extra actions" "$(printf '%s\n' "${lines[@]}")"
(( $(grep -c '^plugin:' "$TEST_LOG" || true) == 0 )) ||
  fail "no plugin was removed before explicit confirmation"
[[ -e $tmp_dir/data/applications/omamail.desktop && -e $tmp_dir/data/applications/borrowed-plugin.desktop ]] ||
  fail "pending confirmation leaves the selected launchers intact"
pass "plugin references schedule confirmation instead of automatic deletion"

# Execute the exact deferred shell command: refusing must preserve the launcher,
# while accepting must remove the selected desktop only after the remover succeeds.
command=${lines[3]#terminal::}
[[ $command != *"--yes"* ]] || fail "plugin removal silently bypasses confirmation"
if ALLOW_PLUGIN_REMOVAL=no bash -c "$command"; then
  fail "refusing plugin removal unexpectedly succeeded"
fi
[[ -e $tmp_dir/data/applications/omamail.desktop ]] ||
  fail "cancelled plugin confirmation deleted the launcher"
pass "declining plugin confirmation retains the launcher"

ALLOW_PLUGIN_REMOVAL=yes bash -c "$command" ||
  fail "accepted plugin confirmation did not finish launcher removal"
[[ ! -e $tmp_dir/data/applications/omamail.desktop ]] ||
  fail "accepted plugin removal did not delete the selected launcher"
pass "accepted plugin removal is followed by launcher cleanup"

borrowed_command=${lines[6]#terminal::}
if ALLOW_PLUGIN_REMOVAL=no bash -c "$borrowed_command"; then
  fail "hand-authored launcher bypassed plugin confirmation"
fi
[[ -e $tmp_dir/data/applications/borrowed-plugin.desktop ]] ||
  fail "hand-authored launcher was removed after plugin confirmation failed"
pass "borrowed plugin utility cannot remove an unrelated plugin without consent"

[[ ! -e $tmp_dir/data/applications/borrowed-icon.desktop ]] ||
  fail "Icon-only plugin references remain ordinary user desktop files"
(( $(grep -c '^plugin:' "$TEST_LOG" || true) == 3 )) ||
  fail "Icon=, TryExec= and Path= must never trigger plugin removal"
pass "Icon-only references cannot remove a plugin"

[[ ! -e $tmp_dir/data/applications/notes.desktop && ! -e $tmp_dir/data/applications/editor.desktop && ! -e $tmp_dir/data/applications/escape.desktop ]] ||
  fail "a desktop id, Path=, desktop action or path leaving a plugin removes only the desktop file"
pass "a desktop id, Path=, desktop action or path leaving a plugin cannot remove a plugin"
