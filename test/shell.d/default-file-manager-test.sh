#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
owner_pids=()
cleanup() {
  if ((${#owner_pids[@]})); then
    kill "${owner_pids[@]}" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/config" "$test_tmp/data/applications" \
  "$test_tmp/system/applications" "$test_tmp/system/dbus-1/services" \
  "$test_tmp/home/.config/hypr" "$test_tmp/owners"

export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$test_tmp/config"
export XDG_CONFIG_DIRS="$test_tmp/etc"
export XDG_DATA_HOME="$test_tmp/data"
export XDG_DATA_DIRS="$test_tmp/system"
unset XDG_CURRENT_DESKTOP XDG_MENU_PREFIX

export OMARCHY_TEST_NOTIFICATION_HISTORY="$test_tmp/notification"
export OMARCHY_TEST_TERMINAL_LOG="$test_tmp/terminal"
export OMARCHY_TEST_PKG_LOG="$test_tmp/pkg"
export OMARCHY_TEST_MOCK_BIN="$mock_bin"
export OMARCHY_TEST_LAUNCH_LOG="$test_tmp/launch"
export OMARCHY_TEST_HYPRCTL_LOG="$test_tmp/hyprctl"
export OMARCHY_TEST_BUSCTL_LOG="$test_tmp/busctl"
export OMARCHY_TEST_BUS_OWNER="$test_tmp/bus-owner"
export OMARCHY_TEST_BUS_OWNER_PID="$test_tmp/bus-owner-pid"
export OMARCHY_TEST_BUS_QUIT_RELEASES=true
export OMARCHY_TEST_FM_LOG="$test_tmp/file-managers"
: >"$OMARCHY_TEST_BUS_OWNER"
: >"$OMARCHY_TEST_BUS_OWNER_PID"

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_NOTIFICATION_HISTORY"
SH
cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_TERMINAL_LOG"
SH
cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_PKG_LOG"
# Installing is what puts the command on PATH: become it, like pacman would.
for package in "$@"; do
  printf '#!/bin/bash\nprintf "%%s\\n" "$0 $*" >>"$OMARCHY_TEST_FM_LOG"\n' >"$OMARCHY_TEST_MOCK_BIN/$package"
  chmod +x "$OMARCHY_TEST_MOCK_BIN/$package"
done
SH
cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_LAUNCH_LOG"
SH
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_HYPRCTL_LOG"
SH

# The session bus, stubbed at the call level: the tests choose who owns
# org.freedesktop.FileManager1 and whether Quit is honoured. Quit clears the
# owner unless OMARCHY_TEST_BUS_QUIT_RELEASES says the manager ignores it.
cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_BUSCTL_LOG"
case "$*" in
*"GetNameOwner"*)
  owner=$(<"$OMARCHY_TEST_BUS_OWNER")
  if [[ -n $owner ]]; then
    printf 's "%s"\n' "$owner"
  else
    echo "Name org.freedesktop.FileManager1 is not owned" >&2
    exit 1
  fi
  ;;
*"GetConnectionUnixProcessID"*)
  printf 'u %s\n' "$(<"$OMARCHY_TEST_BUS_OWNER_PID")"
  ;;
*"Quit"*)
  if [[ $OMARCHY_TEST_BUS_QUIT_RELEASES == "true" ]]; then
    : >"$OMARCHY_TEST_BUS_OWNER"
  fi
  ;;
esac
SH

# The host's PATH with every file manager taken out of it: whether a command
# exists must depend on the fixtures alone, never on what the machine running
# this test happens to have installed.
host_bin="$test_tmp/host-bin"
mkdir -p "$host_bin"
for dir in /usr/local/bin /usr/bin /bin; do
  [[ -d $dir ]] || continue
  for entry in "$dir"/*; do
    [[ -x $entry && ! -d $entry ]] || continue
    name=${entry##*/}
    case "${name,,}" in
    nautilus | nemo | dolphin | flea | thunar) continue ;;
    esac
    ln -sf "$entry" "$host_bin/$name" 2>/dev/null || true
  done
done

export PATH="$mock_bin:$ROOT/bin:$host_bin"

write_file_manager_mock() {
  cat >"$mock_bin/$1" <<SH
#!/bin/bash
printf '%s\n' "\$0 \$*" >>"\$OMARCHY_TEST_FM_LOG"
SH
  chmod +x "$mock_bin/$1"
}

# The file managers, each with the desktop entry xdg-mime validates a handler
# through: the entry has to be readable in a data dir and its Exec on PATH.
declare -A desktop_files=(
  [nautilus]="org.gnome.Nautilus.desktop"
  [nemo]="nemo.desktop"
  [dolphin]="org.kde.dolphin.desktop"
  [thunar]="thunar.desktop"
  [flea]="com.thisisgm.flea.desktop"
)
for file_manager in "${!desktop_files[@]}"; do
  write_file_manager_mock "$file_manager"
  # Only Thunar's entry declares inode/directory: once the configured
  # handler's binary is gone, xdg-mime's fallback search then hands back
  # Thunar whatever else the machine running this has installed, which is
  # the entry point for the launcher's own fallback below.
  if [[ $file_manager == thunar ]]; then
    printf '[Desktop Entry]\nType=Application\nName=%s\nExec=%s %%U\nMimeType=inode/directory;\n' \
      "$file_manager" "$file_manager" >"$XDG_DATA_HOME/applications/${desktop_files[$file_manager]}"
  else
    printf '[Desktop Entry]\nType=Application\nName=%s\nExec=%s %%U\n' \
      "$file_manager" "$file_manager" >"$XDG_DATA_HOME/applications/${desktop_files[$file_manager]}"
  fi
done
chmod +x "$mock_bin"/*

# Every file manager registers for org.freedesktop.FileManager1 in the system
# data dirs; each with the service-mode command line the entry point hands
# back to the bus. The registration's filename is not what the scan matches
# on, only its content.
cat >"$XDG_DATA_DIRS/dbus-1/services/org.freedesktop.FileManager1.service" <<EOF
[D-BUS Service]
Name=org.freedesktop.FileManager1
Exec=$mock_bin/nautilus --gapplication-service
EOF
cat >"$XDG_DATA_DIRS/dbus-1/services/org.xfce.Thunar.FileManager1.service" <<EOF
[D-BUS Service]
Name=org.freedesktop.FileManager1
Exec=$mock_bin/thunar --gapplication-service
EOF

cat >"$XDG_CONFIG_HOME/mimeapps.list" <<'EOF'
[Default Applications]
inode/directory=org.kde.dolphin.desktop
EOF

[[ $(omarchy-default-file-manager) == "dolphin" ]] ||
  fail "default file manager is the installed handler in mimeapps.list" "$(omarchy-default-file-manager)"
pass "default file manager reads the inode/directory handler back as its name"

: >"$OMARCHY_TEST_NOTIFICATION_HISTORY"
omarchy-default-file-manager thunar
grep -qx "inode/directory=thunar.desktop" "$XDG_CONFIG_HOME/mimeapps.list" ||
  fail "setting the default records it in mimeapps.list" "$(cat "$XDG_CONFIG_HOME/mimeapps.list")"
[[ $(omarchy-default-file-manager) == "thunar" ]] ||
  fail "the new default reads back" "$(omarchy-default-file-manager)"

user_service="$XDG_DATA_HOME/dbus-1/services/org.freedesktop.FileManager1.service"
[[ -f $user_service ]] ||
  fail "setting the default registers it for Show in folder"
grep -qx "Name=org.freedesktop.FileManager1" "$user_service" ||
  fail "the user registration answers the FileManager1 name" "$(cat "$user_service")"
grep -qx "Exec=$ROOT/bin/omarchy-file-manager-dbus" "$user_service" ||
  fail "the user registration names Omarchy's own entry point, not a manager" "$(cat "$user_service")"
grep -q "omarchy-default-file-manager" "$user_service" ||
  fail "the user registration says where it came from"

mapfile -d '' -t notification <"$OMARCHY_TEST_NOTIFICATION_HISTORY"
[[ ${#notification[@]} == 3 && ${notification[2]} == "Thunar is now the default file manager" ]] ||
  fail "setting the default notifies with the chosen name" "argv: ${notification[*]}"
pass "setting the default writes mimeapps.list, the FileManager1 entry point and a notification"

# `flea --default` rebinds the file-manager keys through a marked block in the
# user's bindings; choosing another file manager here has to take that block
# back out, leaving the picker block and the user's own bindings alone.
cat >"$HOME/.config/hypr/bindings.lua" <<'EOF'
o.bind("SUPER + E", "Mail", { launch = "mail" })
-- flea --default: begin. Written by `flea --default`; `flea --default off` removes the block whole.
hl.unbind("SUPER + SHIFT + F")
o.bind("SUPER + SHIFT + F", "File manager", { launch = 'flea --gui' })
-- flea --default: end
-- flea --picker: begin. Written by `flea --picker`.
o.window("com.thisisgm.flea.picker", { tag = "+floating-window" })
-- flea --picker: end
EOF
: >"$OMARCHY_TEST_HYPRCTL_LOG"
omarchy-default-file-manager nemo
grep -q "flea --default" "$HOME/.config/hypr/bindings.lua" &&
  fail "setting the default removes the block flea --default wrote"
grep -q "flea --picker: begin" "$HOME/.config/hypr/bindings.lua" ||
  fail "setting the default leaves flea --picker's block alone"
grep -q 'SUPER + E' "$HOME/.config/hypr/bindings.lua" ||
  fail "setting the default leaves the user's own bindings alone"
grep -qx "reload" "$OMARCHY_TEST_HYPRCTL_LOG" ||
  fail "removing the block reloads Hyprland" "$(cat "$OMARCHY_TEST_HYPRCTL_LOG")"
pass "setting the default takes back the keys flea --default bound"

# A manager that already owns org.freedesktop.FileManager1 keeps the name
# until it exits, whatever the registration file says: ask the current owner
# to quit so the new default answers Show in folder right away.
: >"$OMARCHY_TEST_BUSCTL_LOG"
: >"$OMARCHY_TEST_NOTIFICATION_HISTORY"
omarchy-default-file-manager thunar
! grep -q "Quit" "$OMARCHY_TEST_BUSCTL_LOG" ||
  fail "with nobody owning the name, nothing is asked to quit" "$(cat "$OMARCHY_TEST_BUSCTL_LOG")"
mapfile -d '' -t notification <"$OMARCHY_TEST_NOTIFICATION_HISTORY"
[[ ${#notification[@]} == 3 && ${notification[2]} == "Thunar is now the default file manager" ]] ||
  fail "a nameless bus leaves only the switch notification" "argv: ${notification[*]}"
pass "an unowned FileManager1 name needs no handover"

cp "$host_bin/sleep" "$test_tmp/owners/nemo"
"$test_tmp/owners/nemo" 60 &
owner_pids+=("$!")
printf 'nemo\n' >"$OMARCHY_TEST_BUS_OWNER"
printf '%s\n' "$owner_pids" >"$OMARCHY_TEST_BUS_OWNER_PID"
: >"$OMARCHY_TEST_BUSCTL_LOG"
: >"$OMARCHY_TEST_NOTIFICATION_HISTORY"
omarchy-default-file-manager thunar
grep -q "org.freedesktop.FileManager1 Quit" "$OMARCHY_TEST_BUSCTL_LOG" ||
  fail "the previous owner is asked to quit so the new default answers" "$(cat "$OMARCHY_TEST_BUSCTL_LOG")"
[[ ! -s $OMARCHY_TEST_BUS_OWNER ]] ||
  fail "a manager that quits releases the name"
mapfile -d '' -t notification <"$OMARCHY_TEST_NOTIFICATION_HISTORY"
[[ ${#notification[@]} == 3 && ${notification[2]} == "Thunar is now the default file manager" ]] ||
  fail "a released name leaves only the switch notification" "argv: ${notification[*]}"
pass "the previous manager is asked to quit and the switch is silent once it does"

cp "$host_bin/sleep" "$test_tmp/owners/thunar"
"$test_tmp/owners/thunar" 60 &
owner_pids+=("$!")
printf 'thunar\n' >"$OMARCHY_TEST_BUS_OWNER"
printf '%s\n' "${owner_pids[-1]}" >"$OMARCHY_TEST_BUS_OWNER_PID"
: >"$OMARCHY_TEST_BUSCTL_LOG"
omarchy-default-file-manager thunar
! grep -q "Quit" "$OMARCHY_TEST_BUSCTL_LOG" ||
  fail "the chosen manager owning the name is left running" "$(cat "$OMARCHY_TEST_BUSCTL_LOG")"
pass "re-choosing the manager that owns the name does not close it"

export OMARCHY_TEST_BUS_QUIT_RELEASES=false
printf 'nemo\n' >"$OMARCHY_TEST_BUS_OWNER"
printf '%s\n' "${owner_pids[-2]}" >"$OMARCHY_TEST_BUS_OWNER_PID"
: >"$OMARCHY_TEST_NOTIFICATION_HISTORY"
omarchy-default-file-manager thunar
mapfile -d '' -t notification <"$OMARCHY_TEST_NOTIFICATION_HISTORY"
[[ ${#notification[@]} == 6 &&
  ${notification[2]} == "The previous file manager still answers Show in folder; close its windows to finish switching to Thunar" &&
  ${notification[5]} == "Thunar is now the default file manager" ]] ||
  fail "a manager that ignores Quit gets the user warned" "argv: ${notification[*]}"
export OMARCHY_TEST_BUS_QUIT_RELEASES=true
: >"$OMARCHY_TEST_BUS_OWNER"
pass "a manager that ignores Quit gets a warning instead of a silent stale name"

# A manager that is not installed yet installs first, in a terminal the
# user can give a password in, and only then becomes the default. Nemo is
# the selection at this point, so a refused install must leave it standing.
cat >"$XDG_CONFIG_HOME/mimeapps.list" <<'EOF'
[Default Applications]
inode/directory=nemo.desktop
EOF
rm "$mock_bin/thunar"
: >"$OMARCHY_TEST_TERMINAL_LOG"
: >"$OMARCHY_TEST_NOTIFICATION_HISTORY"
omarchy-default-file-manager thunar
mapfile -d '' -t terminal <"$OMARCHY_TEST_TERMINAL_LOG"
[[ ${terminal[*]} == "omarchy-default-file-manager --install thunar" ]] ||
  fail "a missing file manager installation opens in a terminal" "argv: ${terminal[*]}"
grep -qx "inode/directory=nemo.desktop" "$XDG_CONFIG_HOME/mimeapps.list" ||
  fail "a missing file manager leaves the selection alone" "$(cat "$XDG_CONFIG_HOME/mimeapps.list")"
[[ ! -s $OMARCHY_TEST_NOTIFICATION_HISTORY ]] ||
  fail "a missing file manager skips notifications"
pass "a missing file manager waits for the install terminal"

: >"$OMARCHY_TEST_PKG_LOG"
omarchy-default-file-manager --install thunar
[[ $(<"$OMARCHY_TEST_PKG_LOG") == "thunar" ]] ||
  fail "installing installs the package" "$(cat "$OMARCHY_TEST_PKG_LOG")"
grep -qx "inode/directory=thunar.desktop" "$XDG_CONFIG_HOME/mimeapps.list" ||
  fail "installing makes it the default" "$(cat "$XDG_CONFIG_HOME/mimeapps.list")"
pass "installing a missing file manager makes it the default"

# A registration the user wrote themselves is not ours to replace: choosing a
# file manager keeps it, says so, and leaves the bus alone -- the name belongs
# to whatever their file launches.
cat >"$user_service" <<'EOF'
[D-BUS Service]
Name=org.freedesktop.FileManager1
Exec=/home/someone/bin/my-file-manager
EOF
: >"$OMARCHY_TEST_BUSCTL_LOG"
output=$(omarchy-default-file-manager dolphin 2>&1) ||
  fail "choosing over a custom registration still succeeds" "$output"
grep -qx "Exec=/home/someone/bin/my-file-manager" "$user_service" ||
  fail "a custom FileManager1 registration is preserved" "$(cat "$user_service")"
[[ $output == *"it is not Omarchy's"* ]] ||
  fail "the conflict with a custom registration is explained" "$output"
grep -qx "inode/directory=org.kde.dolphin.desktop" "$XDG_CONFIG_HOME/mimeapps.list" ||
  fail "the handler still changes over a custom registration" "$(cat "$XDG_CONFIG_HOME/mimeapps.list")"
[[ ! -s $OMARCHY_TEST_BUSCTL_LOG ]] ||
  fail "a custom registration leaves the bus owner alone" "$(cat "$OMARCHY_TEST_BUSCTL_LOG")"
rm "$user_service"
omarchy-default-file-manager thunar >/dev/null
pass "a custom FileManager1 registration is preserved and explained"

# An old-style copy carrying our marker -- what the first version of this
# command wrote -- is ours, and gets upgraded to the entry point.
cat >"$user_service" <<'EOF'
# Written by omarchy-default-file-manager so the chosen file manager answers Show in folder.
[D-BUS Service]
Name=org.freedesktop.FileManager1
Exec=/usr/bin/Thunar --gapplication-service
EOF
omarchy-default-file-manager thunar >/dev/null
grep -qx "Exec=$ROOT/bin/omarchy-file-manager-dbus" "$user_service" ||
  fail "an Omarchy-written copy is upgraded to the entry point" "$(cat "$user_service")"
pass "a registration Omarchy wrote is replaced by the entry point"

# The D-Bus entry point picks the current default on every activation, runs
# the service command that manager registered, and falls back to a file
# manager the machine still has when the default package is gone.
cat >"$XDG_CONFIG_HOME/mimeapps.list" <<'EOF'
[Default Applications]
inode/directory=thunar.desktop
EOF
: >"$OMARCHY_TEST_FM_LOG"
omarchy-file-manager-dbus
[[ $(<"$OMARCHY_TEST_FM_LOG") == "$mock_bin/thunar --gapplication-service" ]] ||
  fail "the entry point launches the default's own service command" "$(cat "$OMARCHY_TEST_FM_LOG")"

rm "$mock_bin/thunar"
: >"$OMARCHY_TEST_FM_LOG"
omarchy-file-manager-dbus
[[ $(<"$OMARCHY_TEST_FM_LOG") == "$mock_bin/nautilus --gapplication-service" ]] ||
  fail "a default whose package is gone falls back to the first installed manager" "$(cat "$OMARCHY_TEST_FM_LOG")"

rm "$mock_bin/nautilus" "$mock_bin/nemo" "$mock_bin/dolphin" "$mock_bin/flea"
omarchy-file-manager-dbus && fail "with no file manager installed the entry point fails"
for file_manager in nautilus nemo dolphin thunar flea; do
  write_file_manager_mock "$file_manager"
done
pass "the entry point runs the default and falls back when its package is gone"

# The keys run whatever is the default, passing the directory the caller asked
# for, and fall back to a file manager the machine still has when the default
# package is gone.
cat >"$XDG_CONFIG_HOME/mimeapps.list" <<'EOF'
[Default Applications]
inode/directory=nemo.desktop
EOF
: >"$OMARCHY_TEST_LAUNCH_LOG"
omarchy-launch-file-manager "$test_tmp/some dir"
mapfile -d '' -t launch <"$OMARCHY_TEST_LAUNCH_LOG"
[[ ${#launch[@]} == 3 && ${launch[0]} == "--" && ${launch[1]} == "nemo" && ${launch[2]} == "$test_tmp/some dir" ]] ||
  fail "the launcher opens the default file manager on the given directory" "argv: ${launch[*]}"

rm "$mock_bin/nemo" "$mock_bin/dolphin" "$mock_bin/thunar" "$mock_bin/flea"
: >"$OMARCHY_TEST_LAUNCH_LOG"
omarchy-launch-file-manager-cwd
mapfile -d '' -t launch <"$OMARCHY_TEST_LAUNCH_LOG"
[[ ${#launch[@]} == 4 && ${launch[0]} == "--" && ${launch[1]} == "nautilus" &&
  ${launch[2]} == "--new-window" && ${launch[3]} == "$HOME" ]] ||
  fail "a default package that is gone falls back to the file manager installed" "argv: ${launch[*]}"
pass "the launcher runs the default and falls back when it is missing"
