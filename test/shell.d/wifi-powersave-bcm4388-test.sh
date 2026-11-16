#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/wifi-powersave-bcm4388.sh"
all="$ROOT/install/hardware/all.sh"
base="$ROOT/etc/NetworkManager/conf.d/omarchy-wifi-powersave.conf"

grep -q 'apple/wifi-powersave-bcm4388.sh' "$all" ||
  fail "the BCM4388 power save leaf runs during hardware setup"
pass "the BCM4388 power save leaf runs during hardware setup"

# NetworkManager applies conf.d in name order, the later file winning. The
# override only works if its name sorts after the default it overrides.
[[ "$(printf '%s\n' omarchy-wifi-powersave_bcm4388.conf "$(basename "$base")" | LC_ALL=C sort | tail -1)" == omarchy-wifi-powersave_bcm4388.conf ]] ||
  fail "the BCM4388 override sorts after the global default"
pass "the BCM4388 override sorts after the global default"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
conf="$test_tmp/etc/NetworkManager/conf.d/omarchy-wifi-powersave_bcm4388.conf"
mkdir -p "$stub_bin"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

# Chatty like real lspci, so a grep -q consumer would kill it with SIGPIPE.
if [[ -n ${WIFI_ID:-} ]]; then
  echo "01:00.0 Network controller [0280]: Broadcom Inc. Wireless [14e4:$WIFI_ID]"
fi
for _ in {1..4096}; do
  echo '02:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/omarchy-hw-aarch64-apple" <<'SH'
#!/bin/bash

(( ${APPLE_SILICON:-0} == 1 ))
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local wifi_id="$1" apple_silicon="$2"
  rm -rf "$test_tmp/etc"
  local script="$test_tmp/leaf.sh"
  sed -e "s|/etc/NetworkManager|$test_tmp/etc/NetworkManager|g" "$leaf" >"$script"

  WIFI_ID="$wifi_id" APPLE_SILICON="$apple_silicon" PATH="$stub_bin:$PATH" \
    bash -eE -o pipefail -c 'source "$1"' bash "$script" </dev/null
}

run_leaf 4434 1 >/dev/null
grep -q '^wifi.powersave = 3$' "$conf" 2>/dev/null ||
  fail "a BCM4388 on Apple Silicon gets power save on" "$(ls -R "$test_tmp/etc" 2>&1)"
pass "a BCM4388 on Apple Silicon gets power save on"

# Only the measured part: the BCM4387 and BCM4378 in M1/M2 Macs keep the default.
for wifi_id in 4433 4425; do
  run_leaf "$wifi_id" 1 >/dev/null
  [[ ! -f $conf ]] || fail "other Apple Silicon Wi-Fi parts keep the default" "14e4:$wifi_id"
done
pass "other Apple Silicon Wi-Fi parts keep the default"

run_leaf 4434 0 >/dev/null
[[ ! -f $conf ]] || fail "a BCM4388 outside Apple Silicon keeps the default"
pass "a BCM4388 outside Apple Silicon keeps the default"

run_leaf "" 1 >/dev/null
[[ ! -f $conf ]] || fail "a Mac with no wireless device is left alone"
pass "a Mac with no wireless device is left alone"
