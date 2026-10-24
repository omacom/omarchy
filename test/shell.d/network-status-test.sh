#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home"
mkdir -p "$HOME" "$tmp/bin" "$tmp/wlan0/wireless"

# The command decides Wi-Fi by testing /sys/class/net/<dev>/wireless. Route it
# through a device name that climbs out of /sys to a stand-in directory, so the
# Wi-Fi path runs without real wireless hardware.
export STATUS_DEVICE="../../..$tmp/wlan0"

cat >"$tmp/bin/ip" <<'STUB'
#!/bin/bash
printf '1.1.1.1 via 192.0.2.1 dev %s src 192.0.2.10 uid 1000\n' "$STATUS_DEVICE"
STUB

# Mirrors nmcli's terse escaping: ':' and '\' in a value are escaped unless
# `-e no` is given. -t prints KEY:value lines, -g prints bare values in order.
cat >"$tmp/bin/nmcli" <<'STUB'
#!/bin/bash
escape=yes
mode=""
args=("$@")
for ((i = 0; i < ${#args[@]}; i++)); do
  case "${args[i]}" in
    -e) escape=${args[i + 1]} ;;
    -t) mode=terse ;;
    -g) mode=get ;;
  esac
done

value() {
  local text=$1

  if [[ $escape != "no" ]]; then
    text=${text//\\/\\\\}
    text=${text//:/\\:}
  fi
  printf '%s' "$text"
}

if [[ $* == *"dev wifi list"* ]]; then
  printf ' :54\n*:72\n'
elif [[ $* == *"dev show"* ]]; then
  if [[ $mode == "get" ]]; then
    printf '%s\n%s\n' "$(value "100 (connected)")" "$(value "$STATUS_CONNECTION")"
  else
    printf 'GENERAL.STATE:%s\nGENERAL.CONNECTION:%s\n' "$(value "100 (connected)")" "$(value "$STATUS_CONNECTION")"
  fi
fi
STUB

cat >"$tmp/bin/iw" <<'STUB'
#!/bin/bash
printf 'Connected to 00:11:22:33:44:55 (on wlan0)\n\tSSID: %s\n\tfreq: 5745.0\n' "$STATUS_CONNECTION"
STUB
chmod +x "$tmp/bin/ip" "$tmp/bin/nmcli" "$tmp/bin/iw"

check_connection() {
  local description=$1 connection=$2 output expected

  export STATUS_CONNECTION=$connection
  output=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-network-status")
  expected=$(printf 'wifi\t%s\t72\t5745.0' "$connection")
  [[ $output == "$expected" ]] || fail "$description" "expected: $expected"$'\n'"actual: $output"
  pass "$description"
}

check_connection "network status reports a plain Wi-Fi connection name" "Home"
check_connection "network status keeps a ':' in the Wi-Fi connection name" "Cafe: Guest"
check_connection "network status keeps a backslash and outer spaces in the Wi-Fi connection name" ' Lab\5G: 2nd '
