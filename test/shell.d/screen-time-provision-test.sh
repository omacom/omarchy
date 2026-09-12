#!/bin/bash
#
# How screen time ships and turns on: enforcement runs from a root unit on
# system paths, not out of the widget, so removing the widget cannot switch it
# off; the child install enables it and puts the kid under a profile, a "Me"
# install leaves it dormant; and the PIN is typed in the parent's own service,
# never in the panel a third-party bar widget shares a scene with.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

etc="$ROOT/etc"
bin="$ROOT/bin"

# --- the daemon is a root system service, not a user or plugin thing --------

unit="$etc/systemd/system/omarchy-screen-time.service"
[[ -f $unit ]] || fail "the daemon ships a system unit"
grep -q '^ExecStart=/usr/bin/omarchy-screen-timed' "$unit" || fail "the unit runs the daemon from the package path"
grep -q '^ProtectSystem=strict' "$unit" || fail "the unit hardens the filesystem"
grep -q '^WantedBy=multi-user.target' "$unit" || fail "the unit is a system service, not a user one"
# The config under /etc is written by the parent command and the control
# command through sudo, never by the daemon: strict keeps /etc read-only for it.
if grep -q '^ReadWritePaths=.*etc/omarchy-screen-time' "$unit"; then
  fail "the daemon has no business writing its config under /etc"
fi
pass "enforcement runs from a hardened root unit on the package path"

# The state and config directories are root's alone.
grep -q '^d /etc/omarchy-screen-time 0700 root root' "$etc/tmpfiles.d/omarchy-screen-time.conf" || fail "the config dir is root-only"
grep -q '^d /var/lib/omarchy-screen-time 0700 root root' "$etc/tmpfiles.d/omarchy-screen-time.conf" || fail "the state dir is root-only"
pass "the config and state directories belong to root alone"

# --- the child install turns it on, a default install does not --------------

step="$ROOT/install/config/screen-time.sh"
[[ -f $step ]] || fail "there is an install step for screen time"
grep -q 'OMARCHY_INSTALL_PROFILE:-default.*== "child"' "$step" || fail "the install step keys on the child profile"
grep -q 'omarchy-parent-screen-time on' "$step" || fail "the child install turns the daemon on"
grep -q 'omarchy-parent-screen-time add' "$step" || fail "the child install puts the kid account under a profile"
grep -Fq 'run_logged "$OMARCHY_INSTALL/config/screen-time.sh"' "$ROOT/install/config/all.sh" || fail "the install step is wired into the config run"
pass "the child install enables screen time and rosters the kid; a default install leaves it dormant"

# --- the parent command owns setup, the roster and the PIN ------------------

parent="$bin/omarchy-parent-screen-time"
[[ -x $parent ]] || fail "the parent command is present"
grep -q '^# omarchy:summary=' "$parent" || fail "the parent command carries metadata"
help=$(bash "$parent" --help)
for word in on off status add remove pin grant; do
  [[ $help == *"$word"* ]] || fail "the parent command documents its $word subcommand"
done
pass "omarchy-parent screen-time covers on/off, the roster, the PIN and grants"

# --- the widget is a view; the PIN is not in it -----------------------------

widget="$ROOT/shell/plugins/panels/screen-time/BarWidget.qml"
kid_manifest="$ROOT/shell/plugins/panels/screen-time/manifest.json"
parent_manifest="$ROOT/shell/plugins/screen-time-parent/manifest.json"

[[ $(jq -r .id "$kid_manifest") == omarchy.screen-time ]] || fail "the widget is omarchy.screen-time"
[[ $(jq -r .id "$parent_manifest") == omarchy.screen-time-parent ]] || fail "the parent side is a plugin of its own"
[[ $(jq -r '.omarchy.capabilities[0]' "$parent_manifest") == authentication ]] || fail "the parent side declares the authentication capability"
jq -e '.omarchy.capabilities // [] | index("authentication") | not' "$kid_manifest" >/dev/null || fail "the kid widget is not an authentication service"
pass "the parent side is a separate authentication service, the kid widget is not"

# The widget never reads a PIN field or holds the PIN: it asks the parent
# service for its window over IPC, and that service is the one with the field.
grep -q 'screen-time-parent' "$widget" || fail "the widget opens the parent service over IPC"
# The note and the quiz answer are the widget's own fields; a PIN is not. A
# password-masked field or a parentPin property would mean the PIN passes
# through the shared scene.
if grep -qiE 'passwordCharacter|password: true|parentPin' "$widget"; then
  fail "the widget has no PIN entry of its own"
fi
grep -qE 'passwordCharacter|echoMode: TextInput.Password' "$ROOT/shell/plugins/screen-time-parent/Service.qml" || fail "the PIN field lives in the parent service"
pass "the PIN is typed in the parent service, never in the shared panel"

# The bar ships the widget on a child install, in the default layout.
grep -q 'omarchy.screen-time' "$ROOT/config/omarchy/shell.json" || fail "the widget is in the default bar layout"
pass "the countdown ships in the bar"
