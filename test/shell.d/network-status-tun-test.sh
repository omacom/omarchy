#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
mkdir -p "$stub_dir" "$tmpdir/sys/class/net/wlan0/wireless" "$tmpdir/sys/class/net/Meta" \
  "$tmpdir/sys/class/net/wlan0" "$tmpdir/sys/class/net/eth0" "$tmpdir/sys/class/net/tap0"

# Fake sysfs type files: wlan wireless dir exists; Meta ARPHRD_NONE; eth0 ether.
printf '1\n' >"$tmpdir/sys/class/net/wlan0/type"
printf '65534\n' >"$tmpdir/sys/class/net/Meta/type"
printf '1\n' >"$tmpdir/sys/class/net/eth0/type"

printf '1\n' >"$tmpdir/sys/class/net/tap0/type"
touch "$tmpdir/sys/class/net/tap0/tun_flags"

cat >"$stub_dir/ip" <<'SH'
#!/bin/bash
# Minimal stubs for omarchy-network-status uplink + type probes.
if [[ $1 == "-j" && $2 == "route" && $3 == "show" && $4 == "table" && $5 == "main" && $6 == "default" ]]; then
  printf '%s\n' "$MOCK_MAIN_DEFAULT_JSON"
  exit 0
fi
if [[ $1 == "-j" && $2 == "route" && $3 == "get" ]]; then
  printf '%s\n' "${MOCK_ROUTE_GET_JSON:-[]}"
  exit 0
fi
if [[ $1 == "route" && $2 == "get" ]]; then
  printf '1.1.1.1 via 192.0.2.1 dev %s src 192.0.2.10 uid 1000\n' "${MOCK_ROUTE_GET_DEV:-Meta}"
  exit 0
fi
if [[ $1 == "-j" && $2 == "link" && $3 == "show" ]]; then
  case $4 in
    Meta) printf '[{"ifname":"Meta","link_type":"none"}]\n' ;;
    tap0 | eth0) printf '[{"ifname":"eth0","link_type":"ether"}]\n' ;;
    wlan0) printf '[{"ifname":"wlan0","link_type":"ether"}]\n' ;;
    *) printf '[]\n' ;;
  esac
  exit 0
fi
if [[ $1 == "-j" && $2 == "addr" ]]; then
  printf '%s\n' "$MOCK_ADDR_JSON"
  exit 0
fi
exit 0
SH
chmod +x "$stub_dir/ip"

cat >"$stub_dir/jq" <<'SH'
#!/bin/bash
exec /usr/bin/jq "$@"
SH
chmod +x "$stub_dir/jq"

cat >"$stub_dir/nmcli" <<'SH'
#!/bin/bash
if [[ $* == *GENERAL.STATE* ]]; then
  printf 'GENERAL.STATE:100 (connected)\nGENERAL.CONNECTION:Cafe\n'
  exit 0
fi
if [[ $* == *wifi* ]]; then
  printf '*:80\n'
  exit 0
fi
exit 0
SH
chmod +x "$stub_dir/nmcli"

cat >"$stub_dir/iw" <<'SH'
#!/bin/bash
printf 'Connected to aa:bb:cc (on wlan0)\n\tfreq: 5200\n'
SH
chmod +x "$stub_dir/iw"

# Point the script at our fake sysfs by wrapping a copy that rewrites paths.
status_script="$tmpdir/omarchy-network-status"
sed 's|/sys/class/net/|'"$tmpdir"'/sys/class/net/|g' \
  "$ROOT/bin/omarchy-network-status" >"$status_script"
chmod +x "$status_script"

export PATH="$stub_dir:$PATH"
export MOCK_ADDR_JSON='[{"addr_info":[{"family":"inet","local":"192.0.2.10","prefixlen":24}]}]'
# Keep verbose tests deterministic without probing the host network.
printf '#!/bin/bash\nexit 1\n' >"$stub_dir/omarchy-cmd-present"
chmod +x "$stub_dir/omarchy-cmd-present"

# Main-table Wi-Fi wins over a TUN that owns `ip route get` (#13525).
export MOCK_MAIN_DEFAULT_JSON='[{"dev":"wlan0","metric":600,"gateway":"192.0.2.1"}]'
export MOCK_ROUTE_GET_DEV=Meta
out=$(bash "$status_script")
[[ $out == wifi$'\t'Cafe$'\t'80$'\t'5200 ]] || fail "main-table wifi preferred over TUN route get" "$out"
pass "main-table wifi preferred over TUN route get"

# No main default: fall back to route get, but classify TUN as vpn not ethernet.
export MOCK_MAIN_DEFAULT_JSON='[]'
export MOCK_ROUTE_GET_DEV=Meta
out=$(bash "$status_script")
[[ $out == vpn$'\t'Meta$'\t'$'\t' ]] || fail "TUN uplink reports vpn" "$out"
pass "TUN uplink reports vpn"

export MOCK_MAIN_DEFAULT_JSON='[{"dev":"eth0","metric":100,"gateway":"192.0.2.1"}]'
out=$(bash "$status_script")
[[ $out == ethernet$'\t'eth0$'\t'$'\t' ]] || fail "plain ethernet still reports ethernet" "$out"
pass "plain ethernet still reports ethernet"


export MOCK_MAIN_DEFAULT_JSON='[{"dev":"tap0","metric":100}]'
out=$(bash "$status_script")
[[ $out == vpn$'\t'tap0$'\t'$'\t' ]] || fail "TAP uplink reports vpn" "$out"
pass "TAP uplink reports vpn"
out=$(bash "$status_script" --verbose)
[[ $out == *$'type\tvpn'* ]] || fail "verbose TAP type reports vpn" "$out"
pass "verbose TAP type reports vpn"

export MOCK_ADDR_JSON='[{"addr_info":[{"family":"inet","local":"192.0.2.10","prefixlen":24},{"family":"inet","local":"198.51.100.20","prefixlen":25}]}]'
export MOCK_MAIN_DEFAULT_JSON='[{"dev":"eth0","metric":200,"prefsrc":"192.0.2.10"},{"dev":"eth0","metric":100,"prefsrc":"198.51.100.20"}]'
out=$(bash "$status_script" --verbose)
[[ $out == *$'ip\t198.51.100.20\nprefix\t25\n'* ]] || fail "lowest-metric route selects second address and prefix" "$out"
pass "lowest-metric route selects second address and prefix"

export MOCK_MAIN_DEFAULT_JSON='[{"dev":"eth0","metric":100}]'
export MOCK_ROUTE_GET_JSON='[]'
out=$(bash "$status_script" --verbose)
[[ $out == *$'ip\t192.0.2.10\nprefix\t24\n'* ]] || fail "missing source falls back to first IPv4 address" "$out"
pass "missing source falls back to first IPv4 address"

export MOCK_ROUTE_GET_JSON='[{"dev":"eth0","prefsrc":"198.51.100.20"}]'
out=$(bash "$status_script" --verbose)
[[ $out == *$'ip\t198.51.100.20\nprefix\t25\n'* ]] || fail "matching route-get source selects its address and prefix" "$out"
pass "matching route-get source selects its address and prefix"

export MOCK_ROUTE_GET_JSON='[{"dev":"Meta","prefsrc":"198.18.0.1"}]'
out=$(bash "$status_script" --verbose)
[[ $out == *$'iface\teth0\nip\t192.0.2.10\nprefix\t24\n'* ]] || fail "policy TUN source cannot override main uplink address" "$out"
pass "policy TUN source cannot override main uplink address"

# Enable the ping dependency so this verifies suppression rather than absence.
printf '#!/bin/bash\nexit 0\n' >"$stub_dir/omarchy-cmd-present"
cat >"$stub_dir/ping" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$MOCK_PING_LOG"
printf '64 bytes: time=4.2 ms\n'
STUB
chmod +x "$stub_dir/ping"
export MOCK_PING_LOG="$tmpdir/ping.log"
export MOCK_MAIN_DEFAULT_JSON='[{"dev":"eth0","metric":100,"gateway":"192.0.2.1"}]'
out=$(bash "$status_script" --verbose --no-ping)
[[ ! -e $MOCK_PING_LOG && $out != *ping_ms* ]] || fail "no-ping details never invoke ping or emit samples" "$out"
[[ $out == *$'iface\teth0\nip\t192.0.2.10\nprefix\t24\ngateway\t192.0.2.1\n'* && $out == *$'type\tethernet'* ]] || fail "no-ping retains uplink details" "$out"
pass "no-ping retains uplink details without invoking ping"
out=$(bash "$status_script" --verbose)
[[ $(wc -l < "$MOCK_PING_LOG") == 2 && $out == *$'router_ping_ms\t4.2'* && $out == *$'internet_ping_ms\t4.2'* ]] || fail "verbose still samples gateway and internet pings" "$out"
pass "verbose still samples gateway and internet pings"
