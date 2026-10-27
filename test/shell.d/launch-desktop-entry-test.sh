#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
user_apps="$test_tmp/home/.local/share/applications"
system_apps="$test_tmp/system/applications"
log="$test_tmp/launched"
mkdir -p "$mock_bin" "$user_apps" "$system_apps"

for launcher in gio gtk-launch gdbus; do
  cat >"$mock_bin/$launcher" <<SH
#!/bin/bash
printf '%s %s token=%s\n' "$launcher" "\$*" "\${XDG_ACTIVATION_TOKEN:-none}" >"$log"
SH
done
chmod +x "$mock_bin"/*

touch "$system_apps/org.gnome.Nautilus.desktop" "$user_apps/Google Maps.desktop" \
  "$system_apps/org.telegram.desktop.desktop" "$user_apps/org.gnome.Nautilus.desktop"

launch() {
  rm -f "$log"
  env -u XDG_ACTIVATION_TOKEN HOME="$test_tmp/home" XDG_DATA_HOME= XDG_DATA_DIRS="$test_tmp/system" \
    PATH="$mock_bin:$PATH" "$@"
}

launch XDG_ACTIVATION_TOKEN=from-click "$ROOT/bin/omarchy-launch-desktop-entry" org.gnome.Nautilus.desktop
[[ $(cat "$log") == "gio launch $user_apps/org.gnome.Nautilus.desktop token=from-click" ]] ||
  fail "an entry launches through gio with the caller's activation token" "$(cat "$log")"
pass "an entry launches through gio with the caller's activation token, the user's copy first"

launch "$ROOT/bin/omarchy-launch-desktop-entry" "Google Maps.desktop"
[[ $(cat "$log") == "gio launch $user_apps/Google Maps.desktop token=none" ]] ||
  fail "an id with a space resolves to its file" "$(cat "$log")"
launch "$ROOT/bin/omarchy-launch-desktop-entry" org.telegram.desktop.desktop
[[ $(cat "$log") == "gio launch $system_apps/org.telegram.desktop.desktop token=none" ]] ||
  fail "an id ending in .desktop resolves to its file" "$(cat "$log")"
pass "ids with spaces or ending in .desktop resolve to their files"

echo "DBusActivatable=true" >"$system_apps/org.gnome.Calculator.desktop"
launch XDG_ACTIVATION_TOKEN=from-click "$ROOT/bin/omarchy-launch-desktop-entry" org.gnome.Calculator.desktop
[[ $(cat "$log") == "gdbus call --session --dest org.gnome.Calculator --object-path /org/gnome/Calculator --method org.freedesktop.Application.Activate {'activation-token': <'from-click'>, 'desktop-startup-id': <'from-click'>} token=from-click" ]] ||
  fail "a D-Bus activatable app is activated with the caller's token" "$(cat "$log")"
launch "$ROOT/bin/omarchy-launch-desktop-entry" org.gnome.Calculator.desktop
[[ $(cat "$log") == "gio launch $system_apps/org.gnome.Calculator.desktop token=none" ]] ||
  fail "a D-Bus activatable app without a token launches through gio" "$(cat "$log")"
pass "a D-Bus activatable app is activated with the caller's token"

launch XDG_ACTIVATION_TOKEN=from-click "$ROOT/bin/omarchy-launch-desktop-entry" kde-dolphin.desktop
[[ $(cat "$log") == "gtk-launch kde-dolphin.desktop token=from-click" ]] ||
  fail "an id without a matching file falls back to gtk-launch" "$(cat "$log")"
pass "an id without a matching file falls back to gtk-launch"
