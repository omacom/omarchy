#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
mkdir -p "$stub_dir" "$tmpdir/sys/class/net/wlan0/wireless" "$tmpdir/sys/class/net/Meta" \
  "$tmpdir/sys/class/net/wlan0" "$tmpdir/sys/class/net/eth0"

# Fake sysfs type files: wlan wireless dir exists; Meta ARPHRD_NONE; eth0 ether.
printf '1\n' >"$tmpdir/sys/class/net/wlan0/type"
printf '65534\n' >"$tmpdir/sys/class/net/Meta/type"
printf '1\n' >"$tmpdir/sys/class/net/eth0/type"

cat >"$stub_dir/ip" <<'SH'
#!/bin/bash
# Minimal stubs for omarchy-network-status uplink + type probes.
if [[ $1 == "-j" && $2 == "route" && $3 == "show" && $4 == "table" && $5 == "main" && $6 == "default" ]]; then
  printf '%s\n' "$MOCK_MAIN_DEFAULT_JSON"
  exit 0
fi
if [[ $1 == "route" && $2 == "get" ]]; then
  printf '1.1.1.1 via 192.0.2.1 dev %s src 192.0.2.10 uid 1000\n' "${MOCK_ROUTE_GET_DEV:-Meta}"
  exit 0
fi
if [[ $1 == "-j" && $2 == "link" && $3 == "show" ]]; then
  case $4 in
    Meta) printf '[{"ifname":"Meta","link_type":"none"}]\n' ;;
    eth0) printf '[{"ifname":"eth0","link_type":"ether"}]\n' ;;
    wlan0) printf '[{"ifname":"wlan0","link_type":"ether"}]\n' ;;
    *) printf '[]\n' ;;
  esac
  exit 0
fi
if [[ $1 == "-j" && $2 == "addr" ]]; then
  printf '[{"addr_info":[{"family":"inet","local":"192.0.2.10","prefixlen":24}]}]\n'
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
