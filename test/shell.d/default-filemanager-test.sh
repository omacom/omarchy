#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
system_services="$test_tmp/usr/share/dbus-1/services"
mkdir -p "$mock_bin" "$system_services" "$test_tmp/home"

export HOME="$test_tmp/home"
export XDG_DATA_HOME="$test_tmp/data"
export OMARCHY_TEST_MIME_FILE="$test_tmp/inode-directory"
export OMARCHY_TEST_LAUNCH_LOG="$test_tmp/launch-log"
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

for command in setsid nautilus thunar flea nemo busctl omarchy-notification-send; do
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

omarchy-launch-filemanager
launched org.gnome.Nautilus.desktop "$HOME" || fail "an unset default launches Nautilus in the home directory" "$(<"$OMARCHY_TEST_LAUNCH_LOG")"
pass "an unset default launches Nautilus"

[[ $(omarchy-default-filemanager) == "nautilus" ]] || fail "an unset default reads as Nautilus"
omarchy-default-filemanager thunar
[[ $(omarchy-default-filemanager) == "thunar" ]] || fail "choosing Thunar makes it the inode/directory default"

omarchy-launch-filemanager "/tmp/a dir"
launched thunar.desktop "/tmp/a dir" || fail "the launcher opens the chosen desktop entry at the directory" "$(<"$OMARCHY_TEST_LAUNCH_LOG")"
omarchy-launch-filemanager-cwd
launched thunar.desktop "/tmp/a dir" || fail "the cwd launcher passes the terminal's directory"
omarchy-launch-nautilus
launched thunar.desktop "$HOME" || fail "the Nautilus launcher follows the default for bindings that still name it"
omarchy-launch-nautilus-cwd
launched thunar.desktop "/tmp/a dir" || fail "the Nautilus cwd launcher follows the default"
pass "every file manager launcher follows the chosen default"

grep -qx "# Written by omarchy-default-filemanager" "$user_service" ||
  fail "choosing Thunar writes a marked FileManager1 registration"
grep -qx "Exec=/usr/bin/Thunar --daemon" "$user_service" ||
  fail "the registration runs Thunar's own FileManager1 service"
pass "choosing Thunar claims FileManager1 for Thunar"

omarchy-default-filemanager nautilus
[[ ! -e $user_service ]] || fail "choosing Nautilus removes the registration Omarchy wrote"
pass "choosing Nautilus hands FileManager1 back to the system registration"

omarchy-default-filemanager flea
[[ $(omarchy-default-filemanager) == "flea" ]] || fail "choosing Flea makes it the inode/directory default"
omarchy-launch-filemanager "/tmp/a dir"
launched com.thisisgm.flea.desktop "/tmp/a dir" || fail "the launcher opens Flea at the directory" "$(<"$OMARCHY_TEST_LAUNCH_LOG")"
grep -qx "Exec=/usr/lib/flea/flea-filemanager1" "$user_service" || fail "choosing Flea runs Flea's own FileManager1 service"
omarchy-default-filemanager nautilus
[[ ! -e $user_service ]] || fail "choosing Nautilus after Flea removes the registration Omarchy wrote"
pass "Flea is a selectable file manager that takes over bindings and FileManager1 without touching Hyprland config"

printf '# Written by another tool\n[D-BUS Service]\nName=org.freedesktop.FileManager1\nExec=/usr/lib/other\n' >"$user_service"
omarchy-default-filemanager thunar 2>/dev/null
grep -qx "Exec=/usr/lib/other" "$user_service" || fail "choosing Thunar leaves another tool's registration in place"
omarchy-default-filemanager nautilus 2>/dev/null
grep -qx "Exec=/usr/lib/other" "$user_service" || fail "choosing Nautilus leaves another tool's registration in place"
pass "a FileManager1 registration Omarchy did not write is never touched"
