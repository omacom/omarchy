#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

conf="$ROOT/etc/NetworkManager/conf.d/omarchy-privacy.conf"
migration=$(ls "$ROOT"/migrations/*.sh | xargs grep -l "dhcp-send-hostname" | head -n 1)

grep -F 'ipv4.dhcp-send-hostname = 0' "$conf" >/dev/null ||
  fail "privacy drop-in stops sending the hostname over DHCPv4"
grep -F 'ipv6.dhcp-send-hostname = 0' "$conf" >/dev/null ||
  fail "privacy drop-in stops sending the hostname over DHCPv6"
grep -F 'wifi.cloned-mac-address = stable' "$conf" >/dev/null ||
  fail "privacy drop-in rotates the wifi MAC per network"
grep -F 'ethernet.cloned-mac-address = stable' "$conf" >/dev/null ||
  fail "privacy drop-in rotates the ethernet MAC per network"
grep -F 'ipv6.ip6-privacy = 2' "$conf" >/dev/null ||
  fail "privacy drop-in enables IPv6 privacy addresses"
pass "privacy drop-in carries the hardened NetworkManager defaults"

[[ -n $migration ]] || fail "a migration retrofits saved connections"

# The migration must update saved wireless and wired profiles, skip
# everything else, and leave MACs alone so MAC-filtered networks survive.
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/nmcli" <<'STUB'
#!/bin/bash
if [[ $1 == "-t" && $2 == "-f" && $3 == "NAME,UUID,TYPE" ]]; then
  cat <<'LIST'
Home Wi-Fi:uuid-wifi:802-11-wireless
Office LAN:uuid-lan:802-3-ethernet
VPN:uuid-vpn:wireguard
LIST
  exit 0
fi
if [[ $1 == "connection" && $2 == "modify" ]]; then
  printf '%s\n' "$*" >>"$NMCLI_CALLS_FILE"
fi
exit 0
STUB
chmod +x "$tmp_dir/bin/nmcli"
cat >"$tmp_dir/bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$tmp_dir/bin/omarchy-cmd-present"

NMCLI_CALLS_FILE="$tmp_dir/nmcli-calls" PATH="$tmp_dir/bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash "$migration" >/dev/null

grep -F 'connection modify uuid-wifi ipv4.dhcp-send-hostname no ipv6.dhcp-send-hostname no ipv6.ip6-privacy 2' "$tmp_dir/nmcli-calls" >/dev/null ||
  fail "migration retrofits saved wifi profiles" "$(cat "$tmp_dir/nmcli-calls")"
grep -F 'connection modify uuid-lan ipv4.dhcp-send-hostname no ipv6.dhcp-send-hostname no ipv6.ip6-privacy 2' "$tmp_dir/nmcli-calls" >/dev/null ||
  fail "migration retrofits saved ethernet profiles" "$(cat "$tmp_dir/nmcli-calls")"
if grep -F 'uuid-vpn' "$tmp_dir/nmcli-calls" >/dev/null; then
  fail "migration must not touch VPN or tunnel profiles" "$(cat "$tmp_dir/nmcli-calls")"
fi
if grep -F 'cloned-mac' "$tmp_dir/nmcli-calls" >/dev/null; then
  fail "migration must not change MACs on saved connections" "$(cat "$tmp_dir/nmcli-calls")"
fi
pass "migration retrofits saved profiles without touching MACs"
