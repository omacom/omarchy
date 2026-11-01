#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

stubs="$TMPDIR/bin"
mkdir -p "$stubs" "$TMPDIR/home"

export STUB="$TMPDIR/stub"
mkdir -p "$STUB"

# Each stub answers from a file under $STUB, so a case sets the world up by
# writing files and reads back what was asked by reading logs.
cat >"$stubs/nmcli" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$STUB/nmcli-log"
case "$*" in
  *"BSSID,SIGNAL,SSID device wifi list"*) cat "$STUB/scan" 2>/dev/null ;;
  *"IN-USE,BSSID device wifi list"*) cat "$STUB/in-use" 2>/dev/null ;;
  *"TYPE connection show --active"*) cat "$STUB/active" 2>/dev/null ;;
esac
SH

cat >"$stubs/curl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$STUB/curl-log"
url=${*: -1}
case $url in
  *geolocate*)
    while (($#)); do
      [[ $1 == "--data" ]] && printf '%s' "$2" >"$STUB/request"
      shift
    done
    # beacon-status: "down" times out, a number is the HTTP status; the
    # detector asks for the status after the body with -w.
    status=$(cat "$STUB/beacon-status" 2>/dev/null || echo 200)
    [[ $status == "down" ]] && exit 28
    if [[ $status == "200" ]]; then cat "$STUB/beacon"; else echo '{"error":{}}'; fi
    printf '\n%s' "$status"
    ;;
  *forecast*)
    jq -cn --arg zone "$(cat "$STUB/meteo")" '{timezone: $zone}'
    ;;
esac
SH

cat >"$stubs/ip" <<'SH'
#!/bin/bash
case "$*" in
  *"route get"*) echo "1.1.1.1 via 10.0.0.1 dev $(cat "$STUB/route-dev") src 10.0.0.2 uid 1000" ;;
  *"link show dev"*) cat "$STUB/link" ;;
esac
SH

cat >"$stubs/tzupdate" <<'SH'
#!/bin/bash
echo called >>"$STUB/tzupdate-log"
cat "$STUB/ip-zone"
SH

cat >"$stubs/timedatectl" <<'SH'
#!/bin/bash
cat "$STUB/zone"
SH

cat >"$stubs/sudo" <<'SH'
#!/bin/bash
[[ $1 == "-n" && $2 == "timedatectl" && $3 == "set-timezone" ]] || exit 1
printf '%s\n' "$4" >"$STUB/zone"
SH

cat >"$stubs/omarchy-shell" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stubs/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$STUB/notify-log"
SH

cat >"$stubs/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$STUB/systemctl-log"
SH

chmod +x "$stubs"/*

run() {
  PATH="$stubs:$ROOT/bin:$PATH" HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" "$@"
}

state="$TMPDIR/home/.local/state/omarchy/timezone"

reset_world() {
  rm -rf "${STUB:?}"/* "$TMPDIR/home/.local"
  echo "America/New_York" >"$STUB/zone"
  echo "America/Chicago" >"$STUB/meteo"
  echo '{"location":{"lat":36.16,"lng":-86.78},"accuracy":30}' >"$STUB/beacon"
  echo "wlan0" >"$STUB/route-dev"
  echo "3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 link/ether" >"$STUB/link"
  echo "Europe/Copenhagen" >"$STUB/ip-zone"
  : >"$STUB/active"
  # Two networks worth sending, plus a hotspot's randomized address and an
  # opted-out network that must never leave the machine. One SSID carries a
  # colon, which nmcli -t escapes.
  cat >"$STUB/scan" <<'EOF'
A4\:2B\:B0\:11\:22\:33:62:Cafe\: Upstairs
F2\:11\:22\:33\:44\:55:90:Pixel hotspot
A4\:2B\:B0\:11\:22\:44:40:Neighbors_nomap
00\:1A\:2B\:3C\:4D\:5E:80:Library
EOF
  printf '%s\n' '*:00\:1A\:2B\:3C\:4D\:5E' ' :A4\:2B\:B0\:11\:22\:33' >"$STUB/in-use"
}

few_networks() {
  echo '00\:1A\:2B\:3C\:4D\:5E:80:Library' >"$STUB/scan"
}

# --- detection ---------------------------------------------------------------

reset_world
out=$(run omarchy-timezone-detect) || fail "wifi detection answers"
[[ $out == "America/Chicago wifi 30" ]] || fail "wifi detection prints zone, source and accuracy" "$out"
pass "wifi detection resolves nearby networks to a zone"

jq -e '.considerIp == false and .fallbacks.ipf == false' "$STUB/request" >/dev/null ||
  fail "geolocation never falls back to the request's address, which would be the VPN's" "$(cat "$STUB/request")"
macs=$(jq -r '[.wifiAccessPoints[].macAddress] | join(",")' "$STUB/request")
[[ $macs == "00:1a:2b:3c:4d:5e,a4:2b:b0:11:22:33" ]] ||
  fail "only fixed, opted-in access points are sent, strongest first" "$macs"
pass "randomized and _nomap access points never leave the machine"

reset_world
echo "4: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 link/none wireguard " >"$STUB/link"
echo "wg0" >"$STUB/route-dev"
out=$(run omarchy-timezone-detect) || fail "wifi detection works with the default route through a VPN"
[[ $out == "America/Chicago wifi 30" ]] || fail "a VPN does not change the wifi answer" "$out"
pass "wifi detection is unaffected by a VPN carrying the default route"

few_networks
if out=$(run omarchy-timezone-detect); then
  fail "no address lookup while a WireGuard tunnel carries the default route" "$out"
fi
[[ ! -f $STUB/tzupdate-log ]] || fail "the address lookup is not even attempted behind a VPN"
pass "address fallback is skipped behind a WireGuard default route"

reset_world
few_networks
echo "vpn" >"$STUB/active"
if run omarchy-timezone-detect >/dev/null; then
  fail "no address lookup while NetworkManager has a VPN up"
fi
pass "address fallback is skipped while a NetworkManager VPN is active"

reset_world
few_networks
out=$(run omarchy-timezone-detect) || fail "address fallback answers without a VPN"
[[ $out == "Europe/Copenhagen ip -" ]] || fail "address fallback reports its source" "$out"
out=$(run omarchy-timezone-detect --no-ip) && fail "--no-ip never looks the address up" "$out"
pass "address fallback is used only with no usable wifi and no VPN"

reset_world
echo '{"location":{"lat":36.16,"lng":-86.78},"accuracy":40000}' >"$STUB/beacon"
echo "vpn" >"$STUB/active"
out=$(run omarchy-timezone-detect) && fail "a fix too vague to tell zones apart is no fix" "$out"
pass "imprecise wifi fixes are rejected"

reset_world
echo "Etc/GMT" >"$STUB/meteo"
echo "vpn" >"$STUB/active"
out=$(run omarchy-timezone-detect) && fail "open sea is not somewhere to set the clock to" "$out"
pass "Etc zones from open sea are rejected"

reset_world
echo "vpn" >"$STUB/active"
echo 404 >"$STUB/beacon-status"
status=0
run omarchy-timezone-detect >/dev/null || status=$?
((status == 1)) || fail "networks BeaconDB doesn't know are an answer, not a failure" "status $status"
for outage in down 503; do
  echo "$outage" >"$STUB/beacon-status"
  status=0
  run omarchy-timezone-detect >/dev/null || status=$?
  ((status == 2)) || fail "a lookup that failed ($outage) is reported as worth retrying" "status $status"
done
pass "failed lookups exit 2, unknown networks exit 1"

reset_world
[[ $(run omarchy-timezone-detect --network) == "001a2b3c4d5e" ]] || fail "the connected access point keys remembered zones"
echo '*:F2\:11\:22\:33\:44\:55' >"$STUB/in-use"
run omarchy-timezone-detect --network >/dev/null && fail "a randomized hotspot address is never remembered"
pass "network keys come from the connected access point, never a hotspot"

# --- watcher decisions --------------------------------------------------------

reset_world
run omarchy-timezone-watch --check >/dev/null
[[ $(cat "$STUB/zone") == "America/New_York" ]] || fail "one reading never moves the clock"
[[ $(cat "$state/candidate") == "America/Chicago" ]] || fail "the first reading is held as a candidate"
run omarchy-timezone-watch --check >/dev/null
[[ $(cat "$STUB/zone") == "America/Chicago" ]] || fail "a confirming second reading moves the clock"
[[ $(cat "$state/networks/001a2b3c4d5e") == "America/Chicago" ]] || fail "the new zone is remembered for this network"
grep -Fq -- "--action Undo omarchy-timezone-set --undo --with America/New_York" "$STUB/notify-log" ||
  fail "the move is announced with an undo back to the old zone" "$(cat "$STUB/notify-log")"
pass "a new zone is taken after two agreeing readings, with an undo"

: >"$STUB/curl-log"
run omarchy-timezone-set --undo America/New_York
[[ $(cat "$STUB/zone") == "America/New_York" ]] || fail "undo puts the old zone back"
run omarchy-timezone-watch --check >/dev/null
run omarchy-timezone-watch --check >/dev/null
[[ $(cat "$STUB/zone") == "America/New_York" ]] || fail "an undone zone stays undone on that network"
[[ ! -s $STUB/curl-log ]] || fail "a remembered network needs no lookup" "$(cat "$STUB/curl-log")"
pass "undo pins the old zone to this network without further lookups"

reset_world
: >"$STUB/in-use"
run omarchy-timezone-set --detected wifi America/Chicago
run omarchy-timezone-set --undo America/New_York
run omarchy-timezone-watch --check >/dev/null
run omarchy-timezone-watch --check >/dev/null
[[ $(cat "$STUB/zone") == "America/New_York" ]] || fail "off a known network, an undone zone is declined"
echo "America/Denver" >"$STUB/meteo"
run omarchy-timezone-watch --check >/dev/null
run omarchy-timezone-watch --check >/dev/null
[[ $(cat "$STUB/zone") == "America/Denver" ]] || fail "a different zone turning up lifts the decline"
pass "undo off a known network declines that zone until somewhere else turns up"

reset_world
echo "America/Chicago" >"$STUB/zone"
run omarchy-timezone-watch --check >/dev/null
[[ $(cat "$state/networks/001a2b3c4d5e") == "America/Chicago" ]] || fail "agreement is remembered for the network"
[[ ! -f $STUB/notify-log ]] || fail "agreement is silent"
pass "a reading that matches the clock quietly teaches the network its zone"

reset_world
mkdir -p "$state/networks"
echo "Europe/Copenhagen" >"$state/networks/001a2b3c4d5e"
run omarchy-timezone-watch --check >/dev/null
[[ $(cat "$STUB/zone") == "Europe/Copenhagen" ]] || fail "a remembered network moves the clock straight back"
[[ ! -f $STUB/curl-log ]] || fail "a remembered network is never looked up"
pass "returning to a remembered network restores its zone without a lookup"

reset_world
run omarchy-timezone-set Europe/Paris
[[ $(cat "$state/networks/001a2b3c4d5e") == "Europe/Paris" ]] || fail "a manual pick is remembered for the network"
grep -Fq "Timezone is now set to Europe/Paris" "$STUB/notify-log" || fail "a manual pick is confirmed" "$(cat "$STUB/notify-log")"
pass "a manual pick wins on its network"

reset_world
: >"$STUB/in-use"
run omarchy-timezone-watch --check >/dev/null
echo down >"$STUB/beacon-status"
echo "vpn" >"$STUB/active"
[[ $(run omarchy-timezone-watch --check) == "retry" ]] || fail "a failed confirming lookup asks for a retry"
[[ $(cat "$state/candidate") == "America/Chicago" ]] || fail "a failed lookup keeps the candidate for the retry to confirm"
rm "$STUB/beacon-status"
[[ $(run omarchy-timezone-watch --check) == "done" ]] || fail "the retry confirms and finishes"
[[ $(cat "$STUB/zone") == "America/Chicago" ]] || fail "the retry is the confirming reading"
pass "a failed lookup is retried and still counts toward confirmation"

# --- toggle -------------------------------------------------------------------

reset_world
run omarchy-toggle-timezone-auto
[[ -f $TMPDIR/home/.local/state/omarchy/toggles/timezone-auto ]] || fail "the toggle turns automatic timezone on"
grep -Fqx -- "--user enable --now omarchy-timezone-watch.service" "$STUB/systemctl-log" || fail "turning it on starts the watcher"
run omarchy-toggle-timezone-auto
grep -Fqx -- "--user disable --now omarchy-timezone-watch.service" "$STUB/systemctl-log" || fail "turning it off stops the watcher"
pass "the toggle enables and disables the watcher"

# --- event loop -----------------------------------------------------------------

# A real NetworkManager signal as dbus-monitor prints it, then the bus going
# away. The watcher must check after the settle, confirm, move the clock, and
# exit for systemd to restart it once its event source is gone.
cat >"$stubs/dbus-monitor" <<'SH'
#!/bin/bash
# $STUB/events holds signals to print; a "sleep N" line pauses between them.
while IFS= read -r line; do
  if [[ $line == "sleep "* ]]; then sleep "${line#sleep }"; else printf '%s\n' "$line"; fi
done <"$STUB/events"
sleep "${STUB_BUS_SECONDS:-3}"
SH
chmod +x "$stubs/dbus-monitor"

reset_world
cat >"$STUB/events" <<'EVENTS'
signal time=1.0 sender=:1.5 -> destination=(null destination) serial=9 path=/org/freedesktop/NetworkManager; interface=org.freedesktop.NetworkManager; member=StateChanged
   uint32 70
EVENTS
status=0
OMARCHY_TIMEZONE_SETTLE_SECONDS=1 OMARCHY_TIMEZONE_CONFIRM_SECONDS=1 \
  run timeout 15 omarchy-timezone-watch || status=$?
((status == 1)) || fail "the watcher exits when its event source goes away" "status $status"
[[ $(cat "$STUB/zone") == "America/Chicago" ]] || fail "the watcher moves the clock after a network event and a confirming reading"
pass "the event loop checks after a network event, confirms, and moves the clock"

# Count checks by how often the connected access point is asked for. Sitting
# on a remembered network keeps each check to that one question.
checks_for() {
  local events=$1
  reset_world
  mkdir -p "$state/networks"
  echo "America/New_York" >"$state/networks/001a2b3c4d5e"
  printf '%s\n' "$events" >"$STUB/events"
  OMARCHY_TIMEZONE_SETTLE_SECONDS=1 run timeout 20 omarchy-timezone-watch || true
  grep -c "IN-USE,BSSID" "$STUB/nmcli-log"
}

properties() {
  echo "signal time=1.0 sender=:1.5 -> destination=(null destination) serial=9 path=$1; interface=org.freedesktop.DBus.Properties; member=PropertiesChanged"
  echo "   string \"$2\""
  echo "   array ["
  echo "      dict entry("
  echo "         string \"$3\""
  echo "         variant             object path \"/org/freedesktop/NetworkManager/AccessPoint/7\""
  echo "      )"
  echo "   ]"
}

roam=$(printf 'sleep 2\n%s' "$(properties /org/freedesktop/NetworkManager/Devices/3 org.freedesktop.NetworkManager.Device.Wireless ActiveAccessPoint)")
count=$(checks_for "$roam")
((count == 2)) || fail "moving to another access point sets off a check, even while Ethernet stays connected" "checks: $count"

scan=$(printf 'sleep 2\n%s' "$(properties /org/freedesktop/NetworkManager/Devices/3 org.freedesktop.NetworkManager.Device.Wireless LastScan)")
count=$(checks_for "$scan")
((count == 1)) || fail "a finished scan alone never sets off a check" "checks: $count"
pass "access point and connection changes set off a check; scans do not"

reset_world
: >"$STUB/in-use"
echo down >"$STUB/beacon-status"
echo "vpn" >"$STUB/active"
: >"$STUB/events"
STUB_BUS_SECONDS=8 OMARCHY_TIMEZONE_SETTLE_SECONDS=1 OMARCHY_TIMEZONE_RETRY_SECONDS="1 1" \
  run timeout 20 omarchy-timezone-watch || true
count=$(grep -c geolocate "$STUB/curl-log")
((count == 3)) || fail "a failing lookup is tried once and retried twice, then left for the next event" "lookups: $count"
pass "failed lookups are retried a bounded number of times"
