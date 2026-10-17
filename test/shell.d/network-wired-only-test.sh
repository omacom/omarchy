#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const network = requireFromRoot('shell/plugins/panels/network/Model.js')

const on = network.parseWiredOnlyStatus('enabled\ttrue\navailable\ttrue\n')
assertEqual(on.enabled, true, 'parses an enabled toggle')
assertEqual(on.available, true, 'parses availability')

const off = network.parseWiredOnlyStatus('enabled\tfalse\navailable\tfalse\n')
assertEqual(off.enabled, false, 'parses a disabled toggle')
assertEqual(off.available, false, 'parses a machine without both devices')

const empty = network.parseWiredOnlyStatus('')
assertEqual(empty.enabled, false, 'empty output reads as disabled')
assertEqual(empty.available, false, 'empty output reads as unavailable, so the section stays hidden')

assertEqual(network.wiredOnlyTooltip(false), 'Turn Wi-Fi off while Ethernet is connected', 'tooltip explains what turning it on does')
assertEqual(network.wiredOnlyTooltip(true), 'Leave Wi-Fi on while Ethernet is connected', 'tooltip explains what turning it off does')
const tr = (key, english) => `[${key}]`
assertEqual(network.wiredOnlyTooltip(false, tr), '[network.wiredOnlyTooltip]', 'tooltip reads the catalog when given a translator')
assertEqual(network.wiredOnlyTooltip(true, tr), '[network.wiredOnlyLeaveTooltip]', 'the other tooltip reads the catalog too')
JS

# The command itself, against scripted nmcli, loginctl and getent: the stubs
# serve device, radio, connection and session state from files and record
# every radio switch they are asked for.
TMPDIR=$(mktemp -d)
trap 'rm -rf -- "$TMPDIR"' EXIT

stub_bin="$TMPDIR/bin"
mkdir -p "$stub_bin"
export NMCLI_DEVICES="$TMPDIR/devices" NMCLI_RADIO="$TMPDIR/radio" NMCLI_LOG="$TMPDIR/nmcli.log"
export NMCLI_CONNECTION_TYPE="$TMPDIR/connection-type" NMCLI_DOWN="$TMPDIR/nmcli-down" NMCLI_RADIO_STUCK="$TMPDIR/radio-stuck"
export NMCLI_PROFILES="$TMPDIR/profiles"
export LOGINCTL_USERS="$TMPDIR/logged-in" ELSEWHERE_HOME="$TMPDIR/srv/elsewhere"
# `-g` picks columns the way real nmcli does, so the command's field lists are
# exercised rather than assumed. The device table is DEVICE:TYPE:STATE. While
# $NMCLI_DOWN exists every query fails, as it does when NetworkManager is away;
# while $NMCLI_RADIO_STUCK exists the radio refuses to switch.
cat >"$stub_bin/nmcli" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$NMCLI_LOG"
[[ -e $NMCLI_DOWN ]] && exit 1
fields=""
while (($#)); do
  case "$1" in
    -g) fields=$2; shift 2 ;;
    -e) shift 2 ;;
    *) break ;;
  esac
done
case "$*" in
  "device status")
    awk -F: -v fields="$fields" 'BEGIN { n = split(fields, want, ",") }
      { col["DEVICE"] = $1; col["TYPE"] = $2; col["STATE"] = $3
        out = ""; for (i = 1; i <= n; i++) out = out (i > 1 ? ":" : "") col[want[i]]; print out }' "$NMCLI_DEVICES" ;;
  "general") cat "$NMCLI_RADIO" ;;
  "device show "*) awk -F: -v dev="$3" '$1 == dev { found = 1; print $2 } END { exit !found }' "$NMCLI_DEVICES" ;;
  "connection show") cat "$NMCLI_PROFILES" ;;
  "connection show "*) cat "$NMCLI_CONNECTION_TYPE" ;;
  "radio wifi off") [[ -e $NMCLI_RADIO_STUCK ]] && exit 1; echo disabled >"$NMCLI_RADIO" ;;
  "radio wifi on") [[ -e $NMCLI_RADIO_STUCK ]] && exit 1; echo enabled >"$NMCLI_RADIO" ;;
esac
EOF
printf '#!/bin/bash\ncat "$LOGINCTL_USERS"\n' >"$stub_bin/loginctl"
# One account, "elsewhere", lives outside the home root.
printf '#!/bin/bash\nif [[ $2 == elsewhere ]]; then printf "elsewhere:x:1002:1002::%%s:/bin/bash\\n" "$ELSEWHERE_HOME"; else printf "%%s:x:1000:1000::%%s/%%s:/bin/bash\\n" "$2" "$OMARCHY_WIRED_ONLY_HOME_ROOT" "$2"; fi\n' >"$stub_bin/getent"
chmod +x "$stub_bin"/*
export PATH="$stub_bin:$ROOT/bin:$PATH"

# Physical devices as /sys/class/net shows them: a radio and, while docked, a
# port. Virtual devices have no `device` link and are not counted.
net="$TMPDIR/net"
mkdir -p "$net/wlp0s20f3/wireless" "$net/lo" "$net/tailscale0"
: >"$net/wlp0s20f3/device"
echo 1 >"$net/wlp0s20f3/type"
echo 772 >"$net/lo/type"
echo 65534 >"$net/tailscale0/type"
export OMARCHY_NET_CLASS_PATH="$net"
: >"$NMCLI_PROFILES"

port_present() {
  mkdir -p "$net/eth0"
  : >"$net/eth0/device"
  echo 1 >"$net/eth0/type"
}

port_absent() {
  rm -rf "$net/eth0"
}

port_present

homes="$TMPDIR/home"
test_home="$homes/tester"
mkdir -p "$test_home" "$homes/other"
export HOME="$test_home" OMARCHY_WIRED_ONLY_HOME_ROOT="$homes" OMARCHY_WIRED_ONLY_LOCK="$TMPDIR/lock"
flag="$test_home/.local/state/omarchy/toggles/wired-only"
marker="$test_home/.local/state/omarchy/wired-only-radio-off"

docked() {
  printf 'eth0:ethernet:connected\nwlp0s20f3:wifi:disconnected\nlo:loopback:connected (externally)\n' >"$NMCLI_DEVICES"
  port_present
}

unplugged() {
  printf 'eth0:ethernet:unavailable\nwlp0s20f3:wifi:connected\nlo:loopback:connected (externally)\n' >"$NMCLI_DEVICES"
}

# The dock is gone: its NIC no longer appears at all.
undocked() {
  printf 'wlp0s20f3:wifi:connected\nlo:loopback:connected (externally)\n' >"$NMCLI_DEVICES"
  port_absent
}

radio_switches() {
  grep -c '^radio wifi' "$NMCLI_LOG" 2>/dev/null || true
}

radio() {
  cat "$NMCLI_RADIO"
}

docked
echo enabled >"$NMCLI_RADIO"
: >"$NMCLI_LOG"
: >"$LOGINCTL_USERS"

status=$(omarchy-network-wired-only)
[[ $status == $'enabled\tfalse\navailable\ttrue' ]] || fail "status reports the toggle off on a docked machine" "$status"
pass "status reports the toggle off on a docked machine"

omarchy-network-wired-only on
[[ -f $flag ]] || fail "on sets the toggle flag"
pass "on sets the toggle flag"
[[ $(radio) == "disabled" ]] || fail "on turns the radio off while Ethernet is connected"
pass "on turns the radio off while Ethernet is connected"
[[ -f $marker ]] || fail "the command records that it took the radio"
pass "the command records that it took the radio"

status=$(omarchy-network-wired-only)
[[ $status == $'enabled\ttrue\navailable\ttrue' ]] || fail "status reports the toggle on" "$status"
pass "status reports the toggle on"

: >"$NMCLI_LOG"
omarchy-network-wired-only --dispatch eth0 up
(( $(radio_switches) == 0 )) || fail "a repeat up event leaves an already-off radio alone"
pass "a repeat up event leaves an already-off radio alone"

unplugged
omarchy-network-wired-only --dispatch eth0 down
[[ $(radio) == "enabled" ]] || fail "unplugging the cable turns the radio back on"
pass "unplugging the cable turns the radio back on"
[[ ! -e $marker ]] || fail "giving the radio back clears the marker"
pass "giving the radio back clears the marker"

docked
env -u HOME omarchy-network-wired-only --dispatch eth0 up
[[ $(radio) == "disabled" ]] || fail "plugging the cable in turns the radio off"
pass "plugging the cable in turns the radio off"

# Removing a dock takes its NIC with it, so the down event cannot ask the
# device; NetworkManager still hands the hook the connection it belonged to.
# The dispatcher also runs with no HOME in its environment, which is how the
# hook really runs, so this event is delivered without one.
undocked
echo 802-3-ethernet >"$NMCLI_CONNECTION_TYPE"
env -u HOME CONNECTION_UUID=dock omarchy-network-wired-only --dispatch eth0 down
[[ $(radio) == "enabled" ]] || fail "removing the dock turns the radio back on"
pass "removing the dock turns the radio back on"

docked
omarchy-network-wired-only --dispatch eth0 up
undocked
omarchy-network-wired-only --dispatch eth0 down
[[ $(radio) == "enabled" ]] || fail "a vanished device with no connection still counts as wired"
pass "a vanished device with no connection still counts as wired"

printf 'eth0:ethernet:connected (externally)\nwlp0s20f3:wifi:disconnected\n' >"$NMCLI_DEVICES"
omarchy-network-wired-only --dispatch eth0 up
[[ $(radio) == "disabled" ]] || fail "an externally connected Ethernet link counts as wired"
pass "an externally connected Ethernet link counts as wired"

docked
: >"$NMCLI_LOG"
omarchy-network-wired-only --dispatch wlp0s20f3 up
(( $(radio_switches) == 0 )) || fail "Wi-Fi device events are ignored"
pass "Wi-Fi device events are ignored"

omarchy-network-wired-only --dispatch eth0 connectivity-change
(( $(radio_switches) == 0 )) || fail "non up/down events are ignored"
pass "non up/down events are ignored"

omarchy-network-wired-only off
[[ ! -f $flag ]] || fail "off clears the toggle flag"
pass "off clears the toggle flag"
[[ $(radio) == "enabled" ]] || fail "off gives the radio back without waiting for an unplug"
pass "off gives the radio back without waiting for an unplug"

: >"$NMCLI_LOG"
omarchy-network-wired-only --dispatch eth0 up
(( $(radio_switches) == 0 )) || fail "the hook does nothing while the toggle is off"
pass "the hook does nothing while the toggle is off"

# A radio the user switched off is not this command's to give back.
echo disabled >"$NMCLI_RADIO"
omarchy-network-wired-only on
[[ -f $flag && ! -e $marker ]] || fail "on over an already-off radio takes nothing"
pass "on over an already-off radio takes nothing"
unplugged
omarchy-network-wired-only --dispatch eth0 down
[[ $(radio) == "disabled" ]] || fail "unplugging leaves a radio the user switched off alone"
pass "unplugging leaves a radio the user switched off alone"
omarchy-network-wired-only off
[[ $(radio) == "disabled" ]] || fail "off leaves a radio the user switched off alone"
pass "off leaves a radio the user switched off alone"

echo enabled >"$NMCLI_RADIO"
unplugged
omarchy-network-wired-only on
[[ -f $flag && $(radio) == "enabled" && ! -e $marker ]] || fail "on while unplugged leaves the radio on"
pass "on while unplugged leaves the radio on"
omarchy-network-wired-only off

docked
omarchy-network-wired-only toggle
[[ -f $flag && $(radio) == "disabled" ]] || fail "toggle flips the setting on and applies it"
pass "toggle flips the setting on and applies it"
omarchy-network-wired-only toggle
[[ ! -f $flag && $(radio) == "enabled" ]] || fail "toggle flips the setting off and applies it"
pass "toggle flips the setting off and applies it"

# The hook honors the flags of logged-in users, and every home only before
# anyone has logged in.
omarchy-network-wired-only on
unplugged
omarchy-network-wired-only --dispatch eth0 down
docked
echo "1001 other" >"$LOGINCTL_USERS"
: >"$NMCLI_LOG"
omarchy-network-wired-only --dispatch eth0 up
(( $(radio_switches) == 0 )) || fail "another user's session does not borrow this user's setting"
pass "another user's session does not borrow this user's setting"
echo "1000 tester" >"$LOGINCTL_USERS"
omarchy-network-wired-only --dispatch eth0 up
[[ $(radio) == "disabled" ]] || fail "the logged-in user's setting is honored"
pass "the logged-in user's setting is honored"
: >"$LOGINCTL_USERS"
unplugged
omarchy-network-wired-only --dispatch eth0 down
[[ $(radio) == "enabled" ]] || fail "before login every home is checked"
pass "before login every home is checked"
omarchy-network-wired-only off

# NetworkManager away: nothing is switched, and a preference that could not be
# applied is not saved.
docked
touch "$NMCLI_DOWN"
: >"$NMCLI_LOG"
if omarchy-network-wired-only on 2>/dev/null; then fail "on fails when NetworkManager cannot be asked"; fi
pass "on fails when NetworkManager cannot be asked"
[[ ! -f $flag ]] || fail "a preference that could not be applied is not saved"
pass "a preference that could not be applied is not saved"
omarchy-network-wired-only --dispatch eth0 up 2>/dev/null || true
(( $(radio_switches) == 0 )) || fail "the hook switches nothing when NetworkManager cannot be asked"
pass "the hook switches nothing when NetworkManager cannot be asked"
rm -f "$NMCLI_DOWN"

# A radio that refuses to switch: nothing is recorded or saved, and a marker
# stays until the radio really comes back.
docked
echo enabled >"$NMCLI_RADIO"
touch "$NMCLI_RADIO_STUCK"
if omarchy-network-wired-only on 2>/dev/null; then fail "on fails when the radio refuses to switch off"; fi
pass "on fails when the radio refuses to switch off"
[[ ! -f $flag && ! -e $marker ]] || fail "a refused switch saves no preference and claims no marker"
pass "a refused switch saves no preference and claims no marker"
rm -f "$NMCLI_RADIO_STUCK"
omarchy-network-wired-only on
touch "$NMCLI_RADIO_STUCK"
if omarchy-network-wired-only off 2>/dev/null; then fail "off fails when the radio refuses to switch on"; fi
pass "off fails when the radio refuses to switch on"
[[ -f $flag && -e $marker ]] || fail "a refused restore keeps the setting and the marker"
pass "a refused restore keeps the setting and the marker"
rm -f "$NMCLI_RADIO_STUCK"
omarchy-network-wired-only off
[[ ! -f $flag && ! -e $marker && $(radio) == "enabled" ]] || fail "the restore goes through once the radio answers"
pass "the restore goes through once the radio answers"

# A marker that cannot be written takes no radio: nothing to give back later
# means nothing is taken now.
docked
echo enabled >"$NMCLI_RADIO"
chmod 555 "$test_home/.local/state/omarchy"
if omarchy-network-wired-only on 2>/dev/null; then fail "on fails when the marker cannot be written"; fi
pass "on fails when the marker cannot be written"
[[ $(radio) == "enabled" && ! -f $flag ]] || fail "an unrecordable take leaves the radio on and saves no preference"
pass "an unrecordable take leaves the radio on and saves no preference"
chmod 755 "$test_home/.local/state/omarchy"

# At the login screen the greeter is the logged-in user; it does not stand in
# for the real users, so their homes are still checked.
omarchy-network-wired-only on
unplugged
omarchy-network-wired-only --dispatch eth0 down
docked
echo "999 sddm" >"$LOGINCTL_USERS"
omarchy-network-wired-only --dispatch eth0 up
[[ $(radio) == "disabled" ]] || fail "the greeter's session does not hide the users' settings"
pass "the greeter's session does not hide the users' settings"
: >"$LOGINCTL_USERS"
unplugged
omarchy-network-wired-only --dispatch eth0 down
omarchy-network-wired-only off

# The radio is shared: a marker another user's session left behind is honored
# by the hook even when that user is gone and nobody else has the toggle on.
mkdir -p "$homes/other/.local/state/omarchy"
: >"$homes/other/.local/state/omarchy/wired-only-radio-off"
echo disabled >"$NMCLI_RADIO"
unplugged
omarchy-network-wired-only --dispatch eth0 down
[[ $(radio) == "enabled" && ! -e $homes/other/.local/state/omarchy/wired-only-radio-off ]] || fail "unplugging gives back a radio taken for another user"
pass "unplugging gives back a radio taken for another user"

# A logged-in user whose home is not under the root still gets the radio back.
mkdir -p "$ELSEWHERE_HOME/.local/state/omarchy"
: >"$ELSEWHERE_HOME/.local/state/omarchy/wired-only-radio-off"
echo "1002 elsewhere" >"$LOGINCTL_USERS"
echo disabled >"$NMCLI_RADIO"
unplugged
omarchy-network-wired-only --dispatch eth0 down
[[ $(radio) == "enabled" && ! -e $ELSEWHERE_HOME/.local/state/omarchy/wired-only-radio-off ]] || fail "unplugging gives back a radio taken for a user whose home is elsewhere"
pass "unplugging gives back a radio taken for a user whose home is elsewhere"
: >"$LOGINCTL_USERS"

# But a user's own off leaves another user's record alone: it is not theirs
# to give back, and a record they cannot clear must not undo their setting.
: >"$homes/other/.local/state/omarchy/wired-only-radio-off"
echo disabled >"$NMCLI_RADIO"
omarchy-network-wired-only on
omarchy-network-wired-only off
[[ $(radio) == "disabled" && ! -f $flag && -e $homes/other/.local/state/omarchy/wired-only-radio-off ]] || fail "off ignores a radio taken for another user"
pass "off ignores a radio taken for another user"
rm -f "$homes/other/.local/state/omarchy/wired-only-radio-off"

# Booted without the dock after shutting down with the radio held: no cable
# event comes, and the loopback coming up at boot must not stand in for one
# (it arrives before the port is found). The session's reconcile at login is
# what gives the radio back.
docked
echo enabled >"$NMCLI_RADIO"
omarchy-network-wired-only on
undocked
: >"$NMCLI_LOG"
omarchy-network-wired-only --dispatch lo up
(( $(radio_switches) == 0 )) || fail "the loopback coming up is ignored"
pass "the loopback coming up is ignored"
omarchy-network-wired-only --reconcile
[[ $(radio) == "enabled" && ! -e $marker ]] || fail "reconcile at login gives back a held radio with no cable"
pass "reconcile at login gives back a held radio with no cable"
docked
omarchy-network-wired-only --reconcile
[[ $(radio) == "disabled" && -e $marker ]] || fail "reconcile at login takes the radio when the cable is in"
pass "reconcile at login takes the radio when the cable is in"
omarchy-network-wired-only off
: >"$NMCLI_LOG"
omarchy-network-wired-only --reconcile
(( $(radio_switches) == 0 )) || fail "reconcile with the setting off and nothing held changes nothing"
pass "reconcile with the setting off and nothing held changes nothing"

docked
omarchy-network-wired-only --available || fail "--available succeeds with a radio and a port"
pass "--available succeeds with a radio and a port"
: >"$NMCLI_LOG"
omarchy-network-wired-only --available
(( $(grep -c . "$NMCLI_LOG") == 0 )) || fail "--available asks nothing of nmcli while a port is present"
pass "--available asks nothing of nmcli while a port is present"
undocked
if omarchy-network-wired-only --available; then fail "--available fails without an Ethernet port"; fi
pass "--available fails without an Ethernet port"
status=$(omarchy-network-wired-only)
[[ $status == $'enabled\tfalse\navailable\tfalse' ]] || fail "status hides the section on a Wi-Fi-only machine" "$status"
pass "status hides the section on a Wi-Fi-only machine"
# A dock's port is only there while docked; a saved wired profile stands in
# for it, so the setting can be turned on before docking.
printf '802-11-wireless\n802-3-ethernet\nloopback\n' >"$NMCLI_PROFILES"
omarchy-network-wired-only --available || fail "--available succeeds undocked when a wired profile is saved"
pass "--available succeeds undocked when a wired profile is saved"
: >"$NMCLI_PROFILES"
rm -rf "$net/wlp0s20f3"
port_present
if omarchy-network-wired-only --available; then fail "--available fails without a radio"; fi
pass "--available fails without a radio"

if omarchy-network-wired-only on extra >/dev/null 2>&1; then fail "extra arguments are rejected"; fi
pass "extra arguments are rejected"
if omarchy-network-wired-only bogus >/dev/null 2>&1; then fail "unknown arguments are rejected"; fi
pass "unknown arguments are rejected"
