#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/etc/NetworkManager/dispatcher.d/90-omarchy-resync-time"

# NetworkManager only runs dispatcher scripts that are executable, so the
# checkout must carry the bit the package copies into /etc.
[[ -x $hook ]] ||
  fail "the dispatcher script is executable" "mode: $(stat -c '%A' "$hook")"
pass "the dispatcher script is executable"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/systemctl-calls"
stamp="$tmpdir/stamp"
mkdir -p "$mock_bin"

cat >"$mock_bin/systemctl" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"$call_log"
SH
chmod +x "$mock_bin/systemctl"

restart="--no-block try-restart systemd-timesyncd.service"

# run_hook <interface> <action> [VAR=value...]: the variables stand in for the
# environment NetworkManager passes. The stamp carries over between calls, the
# way /run does between dispatcher events.
run_hook() {
  local interface="$1" action="$2"
  shift 2
  : >"$call_log"
  env -u IP4_GATEWAY -u IP6_GATEWAY PATH="$mock_bin:$PATH" OMARCHY_RESYNC_TIME_STAMP="$stamp" "$@" \
    "$hook" "$interface" "$action"
}

uptime_now() {
  local uptime
  read -r uptime _ </proc/uptime
  echo "${uptime%.*}"
}

# A connection with an IPv4 gateway coming up resyncs the clock, without
# making NetworkManager wait for timesyncd.
run_hook wlan0 up IP4_GATEWAY=192.168.1.1
[[ $(<"$call_log") == "$restart" ]] ||
  fail "a connection coming up restarts timesyncd" "calls: $(<"$call_log")"
pass "a connection coming up restarts timesyncd"

# A second connection right after (Wi-Fi and Ethernet at boot) is covered by
# the first restart.
run_hook enp1s0 up IP4_GATEWAY=10.0.0.1
[[ -z $(<"$call_log") ]] ||
  fail "a second connection within 10 seconds does not restart again" "calls: $(<"$call_log")"
pass "a second connection within 10 seconds does not restart again"

# Once the window has passed, the next connection resyncs again.
echo $(( $(uptime_now) - 11 )) >"$stamp"
run_hook wlan0 up IP4_GATEWAY=192.168.1.1
[[ $(<"$call_log") == "$restart" ]] ||
  fail "a connection after the window restarts timesyncd again" "calls: $(<"$call_log")"
pass "a connection after the window restarts timesyncd again"

# An IPv6-only connection counts too.
rm -f "$stamp"
run_hook wlan0 up IP6_GATEWAY=fe80::1
[[ $(<"$call_log") == "$restart" ]] ||
  fail "an IPv6-only connection restarts timesyncd" "calls: $(<"$call_log")"
pass "an IPv6-only connection restarts timesyncd"

# A stamp that cannot be read as a number does not block the resync.
echo garbage >"$stamp"
run_hook wlan0 up IP4_GATEWAY=192.168.1.1
[[ $(<"$call_log") == "$restart" ]] ||
  fail "an unreadable stamp does not block the resync" "calls: $(<"$call_log")"
pass "an unreadable stamp does not block the resync"

# Local-only links (loopback, container bridges) come up without a gateway,
# which NetworkManager passes as 0.0.0.0 once the link has an address. Each
# case starts without a stamp, so an earlier restart cannot hide this one.
for gateways in "" "IP4_GATEWAY=0.0.0.0" "IP4_GATEWAY=0.0.0.0 IP6_GATEWAY=0.0.0.0" "IP6_GATEWAY=::"; do
  rm -f "$stamp"
  run_hook docker0 up $gateways
  [[ -z $(<"$call_log") ]] ||
    fail "a link without a gateway leaves timesyncd alone" "gateways: ${gateways:-none}; calls: $(<"$call_log")"
done
pass "a link without a gateway leaves timesyncd alone"

# Only "up": going down, DHCP renewals and VPNs do not change whether the
# clock can be reached.
for action in down pre-up dhcp4-change vpn-up connectivity-change hostname; do
  rm -f "$stamp"
  run_hook wlan0 "$action" IP4_GATEWAY=192.168.1.1
  [[ -z $(<"$call_log") ]] ||
    fail "the $action event leaves timesyncd alone" "calls: $(<"$call_log")"
done
pass "events other than up leave timesyncd alone"
