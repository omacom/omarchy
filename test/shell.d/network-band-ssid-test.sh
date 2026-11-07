#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/iw" <<'SH'
#!/bin/bash
printf 'Connected to 00:11:22:33:44:55 (on wlan0)\n\tSSID: %s\n\tfreq: 5180\n' "$OMARCHY_TEST_IW_SSID"
SH

cat >"$test_tmp/bin/nmcli" <<'SH'
#!/bin/bash
if [[ $1 == "-e" ]]; then
  case "$4" in
    DEVICE,TYPE,STATE) echo 'wlan0:wifi:connected' ;;
    GENERAL.CONNECTION) echo test-profile ;;
    802-11-wireless.band) echo '' ;;
    FREQ,SSID)
      printf '2412:%s\n5180:%s\n5975:Other network\n' "$OMARCHY_TEST_RAW_SSID" "$OMARCHY_TEST_RAW_SSID"
      ;;
    *) exit 1 ;;
  esac
else
  printf '%s\n' "$*" >>"$OMARCHY_TEST_NM_LOG"
fi
SH

chmod +x "$test_tmp/bin"/*
export PATH="$test_tmp/bin:$PATH"
export OMARCHY_TEST_NM_LOG="$test_tmp/nmcli.log"

check_ssid() {
  local label=$1 raw=$2 escaped=$3 output
  export OMARCHY_TEST_RAW_SSID="$raw" OMARCHY_TEST_IW_SSID="$escaped"
  : >"$OMARCHY_TEST_NM_LOG"

  output=$("$ROOT/bin/omarchy-network-band")
  [[ $output == $'band\t5\navailable\t2.4 5\nselected\tauto' ]] ||
    fail "band status includes both bands for $label" "$output"
  [[ ! -s $OMARCHY_TEST_NM_LOG ]] || fail "reading band status changes no connection settings"

  "$ROOT/bin/omarchy-network-band" 2.4
  [[ $(<"$OMARCHY_TEST_NM_LOG") == $'connection modify test-profile 802-11-wireless.band bg\nconnection up test-profile' ]] ||
    fail "band pinning accepts the scanned 2.4 GHz band for $label" "$(<"$OMARCHY_TEST_NM_LOG")"
  pass "band status and pinning match $label"
}

check_ssid "a plain ASCII SSID with a colon" 'Home:Wi-Fi' 'Home:Wi-Fi'
check_ssid "an accented SSID" 'Café' 'Caf\xc3\xa9'
check_ssid "a CJK SSID" '網路' '\xe7\xb6\xb2\xe8\xb7\xaf'
check_ssid "an emoji SSID" 'Home😀' 'Home\xf0\x9f\x98\x80'
check_ssid "a literal backslash followed by c" 'Home\cWi-Fi' 'Home\x5ccWi-Fi'
check_ssid "a literal backslash followed by x41" 'Home\x41' 'Home\x5cx41'
check_ssid "leading and trailing spaces" ' Home ' '\x20Home\x20'

: >"$OMARCHY_TEST_NM_LOG"
if "$ROOT/bin/omarchy-network-band" 6 >"$test_tmp/output" 2>&1; then
  fail "a band advertised only by another SSID must not be available"
fi
grep -Fq '6GHz is not available on this network' "$test_tmp/output" ||
  fail "an unavailable band still reports the reason" "$(<"$test_tmp/output")"
[[ ! -s $OMARCHY_TEST_NM_LOG ]] || fail "an unavailable band must not change the connection"
pass "band matching rejects frequencies advertised by another SSID"
