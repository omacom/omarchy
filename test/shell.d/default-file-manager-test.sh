#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
system_services="$test_tmp/usr/share/dbus-1/services"
mkdir -p "$mock_bin" "$system_services" "$test_tmp/home/.config/hypr"

export OMARCHY_PATH="$ROOT"
export HOME="$test_tmp/home"
export XDG_DATA_HOME="$test_tmp/data"
export XDG_CONFIG_HOME="$test_tmp/home/.config"
export OMARCHY_TEST_MIME_FILE="$test_tmp/inode-directory"
export OMARCHY_TEST_LAUNCH_LOG="$test_tmp/launch-log"
export OMARCHY_TEST_NOTIFY_LOG="$test_tmp/notify-log"
export OMARCHY_TEST_BUSCTL_LOG="$test_tmp/busctl-log"
export OMARCHY_TEST_BUS_OWNER="$test_tmp/bus-owner"
export OMARCHY_TEST_BUS_OWNER_PID="$test_tmp/bus-owner-pid"
export OMARCHY_TEST_BUS_QUIT_RELEASES=true
export OMARCHY_TEST_HYPRCTL_LOG="$test_tmp/hyprctl-log"
export OMARCHY_TEST_PKG_LOG="$test_tmp/pkg-log"
export OMARCHY_TEST_TERMINAL_LOG="$test_tmp/terminal-log"
export OMARCHY_TEST_SYSTEM_SERVICES="$system_services"
user_service="$XDG_DATA_HOME/dbus-1/services/org.freedesktop.FileManager1.service"

cat >"$mock_bin/xdg-mime" <<'SH'
#!/bin/bash
case $1 in
query) [[ -f $OMARCHY_TEST_MIME_FILE ]] && cat "$OMARCHY_TEST_MIME_FILE" ;;
default) printf '%s\n' "$2" >"$OMARCHY_TEST_MIME_FILE" ;;
esac
SH

cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_LAUNCH_LOG"
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
[[ $1 == "-Qql" ]] || exit 1
case $2 in
nautilus) echo "$OMARCHY_TEST_SYSTEM_SERVICES/org.freedesktop.FileManager1.service" ;;
thunar) echo "$OMARCHY_TEST_SYSTEM_SERVICES/org.xfce.Thunar.FileManager1.service" ;;
flea) echo "$OMARCHY_TEST_SYSTEM_SERVICES/com.thisisgm.flea.FileManager1.service" ;;
esac
SH

cat >"$mock_bin/omarchy-cmd-terminal-cwd" <<'SH'
#!/bin/bash
echo "/tmp/a dir"
SH

cat >"$mock_bin/omarchy-i18n" <<'SH'
#!/bin/bash
case $1 in
default.fileManagerSet) printf '%s is now the default file manager\n' "$2" ;;
default.fileManagerStillOpen) printf 'The previous file manager still answers Show in folder; close its windows to finish switching to %s\n' "$2" ;;
*) printf '%s\n' "$1" ;;
esac
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_NOTIFY_LOG"
SH

cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_BUSCTL_LOG"
if [[ $* == *ReloadConfig* ]]; then
  exit 0
fi
if [[ $* == *GetNameOwner* ]]; then
  if [[ -s ${OMARCHY_TEST_BUS_OWNER:-} ]]; then
    printf 's "%s"\n' "$(<"$OMARCHY_TEST_BUS_OWNER")"
    exit 0
  fi
  exit 1
fi
if [[ $* == *GetConnectionUnixProcessID* ]]; then
  if [[ -s ${OMARCHY_TEST_BUS_OWNER_PID:-} ]]; then
    printf 'u %s\n' "$(<"$OMARCHY_TEST_BUS_OWNER_PID")"
    exit 0
  fi
  exit 1
fi
if [[ $* == *Quit* ]]; then
  if [[ ${OMARCHY_TEST_BUS_QUIT_RELEASES:-true} == true ]]; then
    : >"$OMARCHY_TEST_BUS_OWNER"
  fi
  exit 0
fi
exit 0
SH

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_HYPRCTL_LOG"
SH

cat >"$mock_bin/omarchy-pkg-add" <<SH
#!/bin/bash
printf '%s\n' "\$*" >"\$OMARCHY_TEST_PKG_LOG"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/\$1"
chmod +x "$mock_bin/\$1"
SH

cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_TERMINAL_LOG"
SH

for command in setsid folio flea thunar nemo dolphin pcmanfm nautilus; do
  printf '#!/bin/bash\n[[ ${0##*/} == "setsid" ]] && exec "$@"\nexit 0\n' >"$mock_bin/$command"
done
chmod +x "$mock_bin"/*

export PATH="$mock_bin:$ROOT/bin:$PATH"

printf '[D-BUS Service]\nName=org.freedesktop.FileManager1\nExec=/usr/bin/nautilus --gapplication-service\n' \
  >"$system_services/org.freedesktop.FileManager1.service"
printf '[D-BUS Service]\nName=org.freedesktop.FileManager1\nExec=/usr/bin/Thunar --daemon\n' \
  >"$system_services/org.xfce.Thunar.FileManager1.service"
printf '[D-BUS Service]\nName=org.freedesktop.FileManager1\nExec=/usr/lib/flea/flea-filemanager1\n' \
  >"$system_services/com.thisisgm.flea.FileManager1.service"

launched() {
  local expected
  printf -v expected '%s\n' -- "$@"
  [[ "$(<"$OMARCHY_TEST_LAUNCH_LOG")"$'\n' == "$expected" ]]
}

notified() {
  local expected
  printf -v expected '%s\n' "$*"
  [[ "$(<"$OMARCHY_TEST_NOTIFY_LOG")"$'\n' == "$expected" ]]
}

: >"$OMARCHY_TEST_NOTIFY_LOG"
: >"$OMARCHY_TEST_BUSCTL_LOG"

omarchy-launch-files
launched folio.desktop || fail "an unset default launches Files" "$(<"$OMARCHY_TEST_LAUNCH_LOG")"
pass "an unset default launches Files"

[[ $(omarchy-default-file-manager) == "files" ]] || fail "an unset default reads as Files"
omarchy-default-file-manager thunar
[[ $(omarchy-default-file-manager) == "thunar" ]] || fail "choosing Thunar makes it the inode/directory default"
notified "-g  Thunar is now the default file manager" || fail "choosing Thunar sends notification with glyph" "$(<"$OMARCHY_TEST_NOTIFY_LOG")"

omarchy-launch-files "/tmp/a dir"
launched thunar.desktop "/tmp/a dir" || fail "the launcher opens the chosen desktop entry at the directory" "$(<"$OMARCHY_TEST_LAUNCH_LOG")"
omarchy-launch-files-cwd
launched thunar.desktop "/tmp/a dir" || fail "the cwd launcher passes the terminal's directory"
omarchy-launch-nautilus
launched thunar.desktop || fail "the Nautilus launcher follows the default for bindings that still name it" "$(<"$OMARCHY_TEST_LAUNCH_LOG")"
omarchy-launch-nautilus-cwd
launched thunar.desktop "/tmp/a dir" || fail "the Nautilus cwd launcher follows the default"
pass "every file manager launcher follows the chosen default"

grep -qx "# Written by omarchy-default-file-manager" "$user_service" ||
  fail "choosing Thunar writes a marked FileManager1 registration"
grep -qx "Exec=/usr/bin/Thunar --daemon" "$user_service" ||
  fail "the registration runs Thunar's own FileManager1 service"
pass "choosing Thunar claims FileManager1 for Thunar"

: >"$OMARCHY_TEST_NOTIFY_LOG"
omarchy-default-file-manager files
[[ $(omarchy-default-file-manager) == "files" ]] || fail "choosing Files makes it the inode/directory default"
notified "-g  Files is now the default file manager" || fail "choosing Files sends notification with glyph" "$(<"$OMARCHY_TEST_NOTIFY_LOG")"
grep -qx "# Written by omarchy-default-file-manager" "$user_service" ||
  fail "choosing Files writes a marked FileManager1 registration"
grep -qx "Exec=$mock_bin/folio" "$user_service" ||
  fail "the registration launches Files itself, which implements FileManager1" "$(cat "$user_service")"
omarchy-launch-files
launched folio.desktop || fail "the launcher opens Files" "$(<"$OMARCHY_TEST_LAUNCH_LOG")"
pass "choosing Files claims FileManager1 for Files"

: >"$OMARCHY_TEST_NOTIFY_LOG"
omarchy-default-file-manager flea
[[ $(omarchy-default-file-manager) == "flea" ]] || fail "choosing Flea makes it the inode/directory default"
notified "-g  Flea is now the default file manager" || fail "choosing Flea sends notification with glyph"
omarchy-launch-files "/tmp/a dir"
launched com.thisisgm.flea.desktop "/tmp/a dir" || fail "the launcher opens Flea at the directory" "$(<"$OMARCHY_TEST_LAUNCH_LOG")"
grep -qx "Exec=/usr/lib/flea/flea-filemanager1" "$user_service" || fail "choosing Flea runs Flea's own FileManager1 service"
: >"$OMARCHY_TEST_NOTIFY_LOG"
omarchy-default-file-manager files
grep -qx "Exec=$mock_bin/folio" "$user_service" ||
  fail "choosing Files after Flea takes FileManager1 back to Files" "$(cat "$user_service")"
pass "Flea is a selectable file manager that hands FileManager1 back to Files"

omarchy-default-file-manager nemo
[[ $(omarchy-default-file-manager) == "nemo" ]] || fail "choosing Nemo makes it the inode/directory default"
grep -qx "Exec=$mock_bin/nemo" "$user_service" ||
  fail "a file manager without a D-Bus service still gets a user registration" "$(cat "$user_service")"
pass "choosing a file manager with no D-Bus service writes a registration that launches it"

printf '# Written by another tool\n[D-BUS Service]\nName=org.freedesktop.FileManager1\nExec=/usr/lib/other\n' >"$user_service"
omarchy-default-file-manager thunar 2>/dev/null
grep -qx "Exec=/usr/lib/other" "$user_service" || fail "choosing Thunar leaves another tool's registration in place"
omarchy-default-file-manager files 2>/dev/null
grep -qx "Exec=/usr/lib/other" "$user_service" || fail "choosing Files leaves another tool's registration in place"
pass "a FileManager1 registration Omarchy did not write is never touched"
rm -f "$user_service"

cat >"$HOME/.config/hypr/bindings.lua" <<'LUA'
o.bind("SUPER + E", "Mail", { launch = "mail" })
-- flea --default: begin. Written by `flea --default`; `flea --default off` removes the block whole.
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = 'flea --gui' })
-- flea --default: end
-- flea --picker: begin. Written by `flea --picker`.
o.window("com.thisisgm.flea.picker", { tag = "+floating-window" })
-- flea --picker: end
LUA
: >"$OMARCHY_TEST_HYPRCTL_LOG"
omarchy-default-file-manager nemo >/dev/null
grep -q "flea --default" "$HOME/.config/hypr/bindings.lua" &&
  fail "setting the default removes the block flea --default wrote"
grep -q "flea --picker: begin" "$HOME/.config/hypr/bindings.lua" ||
  fail "setting the default leaves flea --picker's block alone"
grep -q 'SUPER + E' "$HOME/.config/hypr/bindings.lua" ||
  fail "setting the default leaves the user's own bindings alone"
grep -qx "reload" "$OMARCHY_TEST_HYPRCTL_LOG" ||
  fail "removing the block reloads Hyprland" "$(cat "$OMARCHY_TEST_HYPRCTL_LOG")"
pass "setting the default takes back the keys flea --default bound"

: >"$OMARCHY_TEST_BUSCTL_LOG"
: >"$OMARCHY_TEST_NOTIFY_LOG"
omarchy-default-file-manager thunar
! grep -q "Quit" "$OMARCHY_TEST_BUSCTL_LOG" ||
  fail "with nobody owning the name, nothing is asked to quit" "$(cat "$OMARCHY_TEST_BUSCTL_LOG")"
notified "-g  Thunar is now the default file manager" ||
  fail "an unowned name leaves only the switch notification" "$(<"$OMARCHY_TEST_NOTIFY_LOG")"
pass "an unowned FileManager1 name needs no handover"

printf 'nemo-owner\n' >"$OMARCHY_TEST_BUS_OWNER"
# A pid whose comm is not thunar, so Quit is asked.
printf '1\n' >"$OMARCHY_TEST_BUS_OWNER_PID"
: >"$OMARCHY_TEST_BUSCTL_LOG"
: >"$OMARCHY_TEST_NOTIFY_LOG"
omarchy-default-file-manager thunar
grep -q "org.freedesktop.FileManager1 Quit" "$OMARCHY_TEST_BUSCTL_LOG" ||
  fail "the previous owner is asked to quit so the new default answers" "$(cat "$OMARCHY_TEST_BUSCTL_LOG")"
[[ ! -s $OMARCHY_TEST_BUS_OWNER ]] || fail "a manager that quits releases the name"
notified "-g  Thunar is now the default file manager" ||
  fail "a released name leaves only the switch notification" "$(<"$OMARCHY_TEST_NOTIFY_LOG")"
pass "the previous manager is asked to quit and the switch is silent once it does"

export OMARCHY_TEST_BUS_QUIT_RELEASES=false
printf 'nemo-owner\n' >"$OMARCHY_TEST_BUS_OWNER"
printf '1\n' >"$OMARCHY_TEST_BUS_OWNER_PID"
: >"$OMARCHY_TEST_NOTIFY_LOG"
omarchy-default-file-manager files
notified "-g  The previous file manager still answers Show in folder; close its windows to finish switching to Files
-g  Files is now the default file manager" ||
  fail "a manager that ignores Quit gets the user warned" "$(<"$OMARCHY_TEST_NOTIFY_LOG")"
export OMARCHY_TEST_BUS_QUIT_RELEASES=true
: >"$OMARCHY_TEST_BUS_OWNER"
pass "a manager that ignores Quit gets a warning instead of a silent stale name"

# A manager that is not installed yet opens the install terminal and leaves
# the current default alone.
printf 'nemo.desktop\n' >"$OMARCHY_TEST_MIME_FILE"
rm -f "$mock_bin/thunar"
: >"$OMARCHY_TEST_TERMINAL_LOG"
: >"$OMARCHY_TEST_NOTIFY_LOG"
omarchy-default-file-manager thunar
[[ $(<"$OMARCHY_TEST_TERMINAL_LOG") == "omarchy-default-file-manager --install thunar" ]] ||
  fail "a missing file manager installation opens in a terminal" "$(cat "$OMARCHY_TEST_TERMINAL_LOG")"
[[ $(<"$OMARCHY_TEST_MIME_FILE") == "nemo.desktop" ]] ||
  fail "a missing file manager leaves the selection alone"
[[ ! -s $OMARCHY_TEST_NOTIFY_LOG ]] || fail "a missing file manager skips notifications"
pass "a missing file manager waits for the install terminal"

: >"$OMARCHY_TEST_PKG_LOG"
omarchy-default-file-manager --install thunar
[[ $(<"$OMARCHY_TEST_PKG_LOG") == "thunar" ]] ||
  fail "installing installs the package" "$(cat "$OMARCHY_TEST_PKG_LOG")"
[[ -x $mock_bin/thunar ]] || fail "installing places the command on PATH"
[[ $(omarchy-default-file-manager) == "thunar" ]] || fail "installing makes it the default"
pass "installing a missing file manager makes it the default"
