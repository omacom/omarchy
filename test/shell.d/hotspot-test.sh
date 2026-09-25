#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TEST_TMP=$(mktemp -d)
trap 'rm -rf "$TEST_TMP"' EXIT
STUB_BIN="$TEST_TMP/bin"
mkdir -p "$STUB_BIN"

cat >"$STUB_BIN/iw" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "dev" ]]; then
  printf '%s\n' "Interface ${2:-}" '  type managed' '  wiphy 0'
  exit 0
fi
if [[ ${1:-} == "phy" ]]; then
  printf '%s\n' 'Wiphy phy0' '    * AP'
  exit 0
fi
exit 0
STUB

cat >"$STUB_BIN/nmcli" <<'STUB'
#!/bin/bash
case "$*" in
  '-t -f DEVICE,TYPE device status') printf '%s\n' 'wlan1:wifi' ;;
  '-e no -g NAME connection show') printf '%s\n' 'omarchy-hotspot' ;;
  '-e no -g GENERAL.DEVICE connection show omarchy-hotspot') printf '%s\n' 'wlan1' ;;
  '-e no -g 802-11-wireless.ssid connection show omarchy-hotspot') printf '%s\n' 'Saved Hotspot' ;;
  '-e no -g 802-11-wireless.band connection show omarchy-hotspot') printf '%s\n' 'bg' ;;
  '--show-secrets --escape no --get-values 802-11-wireless-security.psk connection show omarchy-hotspot') printf '%s\n' 'savedpassword' ;;
  *) exit 1 ;;
esac
STUB

cat >"$STUB_BIN/ip" <<'STUB'
#!/bin/bash
printf '%s\n' 'RTNETLINK answers: Network is unreachable' >&2
exit 2
STUB

chmod +x "$STUB_BIN/iw" "$STUB_BIN/nmcli" "$STUB_BIN/ip"

UPSTREAM_FUNCTION="$TEST_TMP/upstream-type.sh"
in_function=0
while IFS= read -r line; do
  if [[ $line == "upstream_type() {" ]]; then
    in_function=1
  fi
  if (( in_function )); then
    printf '%s\n' "$line" >>"$UPSTREAM_FUNCTION"
    [[ $line != "}" ]] || break
  fi
done <"$ROOT/bin/omarchy-hotspot"
printf '%s\n' 'upstream_type' >>"$UPSTREAM_FUNCTION"

set +e
PATH="$STUB_BIN:$PATH" bash -euo pipefail "$UPSTREAM_FUNCTION" >"$TEST_TMP/upstream.out" 2>"$TEST_TMP/upstream.err"
upstream_status=$?
set -e
(( upstream_status == 0 )) || fail "upstream_type handles a missing default route under errexit" "exit: $upstream_status
stderr: $(<"$TEST_TMP/upstream.err")"
[[ $(<"$TEST_TMP/upstream.out") == "none" ]] || fail "upstream_type returns none for a missing default route" "$(<"$TEST_TMP/upstream.out")"
pass "upstream_type survives a missing default route under errexit"

set +e
PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" status >"$TEST_TMP/status.out" 2>"$TEST_TMP/status.err"
status=$?
set -e

(( status == 0 )) || fail "no-route status exits successfully" "exit: $status
stderr: $(<"$TEST_TMP/status.err")"

declare -A values=()
declare -A seen=()
expected=(ap_capable ap_bands active configured iface ssid band password freq ip client_count clients upstream)
index=0
while IFS=$'\t' read -r key value; do
  [[ -n $key ]] || continue
  (( index < ${#expected[@]} )) || fail "no-route status preserves protocol order" "unexpected key after index $index: $key"
  [[ $key == "${expected[$index]}" ]] || fail "no-route status preserves protocol order" "expected ${expected[$index]}, got $key"
  values[$key]=$value
  seen[$key]=1
  (( index += 1 ))
done <"$TEST_TMP/status.out"
(( index == ${#expected[@]} )) || fail "no-route status emits the complete protocol" "emitted $index of ${#expected[@]} keys"
[[ -z $(<"$TEST_TMP/status.err") ]] || fail "no-route status keeps stderr empty" "$(<"$TEST_TMP/status.err")"
(( seen[ap_capable] == 1 )) || fail "no-route status reports AP capability"
(( seen[ap_bands] == 1 )) || fail "no-route status reports AP bands"
(( seen[active] == 1 )) || fail "no-route status reports activity"
(( seen[configured] == 1 )) || fail "no-route status reports configuration"
(( seen[iface] == 1 )) || fail "no-route status reports the interface"
(( seen[ssid] == 1 )) || fail "no-route status reports the SSID"
(( seen[band] == 1 )) || fail "no-route status reports the band"
(( seen[password] == 1 )) || fail "no-route status reports the saved password"
(( seen[freq] == 1 )) || fail "no-route status reports frequency"
(( seen[ip] == 1 )) || fail "no-route status reports IP"
(( seen[client_count] == 1 )) || fail "no-route status reports client count"
(( seen[clients] == 1 )) || fail "no-route status reports clients"
(( seen[upstream] == 1 )) || fail "no-route status reports upstream"
[[ ${values[upstream]} == "none" ]] || fail "no-route status reports upstream none" "${values[upstream]}"
[[ ${values[ap_capable]} == "1" ]] || fail "no-route status remains AP-capable" "${values[ap_capable]}"
[[ ${values[active]} == "0" ]] || fail "no-route status remains inactive" "${values[active]}"
[[ ${values[configured]} == "1" ]] || fail "no-route status remains configured" "${values[configured]}"
[[ ${values[iface]} == "wlan1" ]] || fail "no-route status preserves the profile interface" "${values[iface]}"
[[ ${values[ssid]} == "Saved Hotspot" ]] || fail "no-route status preserves the profile SSID" "${values[ssid]}"
[[ ${values[band]} == "2.4" ]] || fail "no-route status preserves the profile band" "${values[band]}"
[[ ${values[password]} == "savedpassword" ]] || fail "no-route status preserves the profile password" "${values[password]}"

pass "no-route status returns a complete upstream=none response"

cat >"$STUB_BIN/iw" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "dev" ]]; then
  case ${2:-} in
    wlan0) printf '%s\n' 'Interface wlan0' '  type managed' '  wiphy 0' ;;
    wlan1) printf '%s\n' 'Interface wlan1' '  type managed' '  wiphy 1' ;;
    *) exit 1 ;;
  esac
  exit 0
fi
if [[ ${1:-} == "phy" ]]; then
  case ${2:-} in
    phy0)
      printf '%s\n' 'Wiphy phy0' '  Band 1:' '  Band 2:' '    * AP'
      ;;
    phy1)
      printf '%s\n' 'Wiphy phy1' '  Band 3:' '    * AP'
      ;;
    '')
      printf '%s\n' 'Wiphy phy0' '  Band 1:' '  Band 2:' '    * AP' 'Wiphy phy1' '  Band 3:' '    * AP'
      ;;
    *) exit 1 ;;
  esac
  exit 0
fi
exit 1
STUB

cat >"$STUB_BIN/nmcli" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$NMCLI_LOG"
if [[ ${1:-} == "-t" && ${2:-} == "-f" && ${3:-} == "DEVICE,TYPE" ]]; then
  printf '%s\n' 'p2p-dev-wlan9:wifi' 'wlan0:wifi' 'wlan1:wifi'
  exit 0
fi
if [[ ${1:-} == "--show-secrets" ]]; then
  if [[ -e $PROFILE_STATE ]]; then
    printf '%s\n' 'savedpassword'
  fi
  exit 0
fi
case "$*" in
  '-e no -g NAME connection show')
    [[ -e $PROFILE_STATE ]] && printf '%s\n' 'omarchy-hotspot'
    ;;
  '-e no -g GENERAL.DEVICE connection show omarchy-hotspot') ;;
  '-e no -g connection.interface-name connection show omarchy-hotspot')
    [[ -e $PROFILE_STATE ]] && printf '%s\n' 'wlan0'
    ;;
  '-e no -g 802-11-wireless.ssid connection show omarchy-hotspot')
    [[ -e $PROFILE_STATE ]] && printf '%s\n' 'Shared Hotspot'
    ;;
  '-e no -g 802-11-wireless.band connection show omarchy-hotspot')
    [[ -e $PROFILE_STATE ]] && printf '%s\n' 'bg'
    ;;
  'connection add type wifi ifname wlan0 con-name omarchy-hotspot ssid Shared mode ap 802-11-wireless.band a wifi-sec.key-mgmt wpa-psk ipv4.method shared autoconnect no') touch "$PROFILE_STATE" ;;
  'connection edit omarchy-hotspot')
    while IFS= read -r line; do
      :
    done
    ;;
esac
exit 0
STUB

chmod +x "$STUB_BIN/iw" "$STUB_BIN/nmcli"

NMCLI_LOG="$TEST_TMP/nmcli.log"
PROFILE_STATE="$TEST_TMP/profile"
export NMCLI_LOG PROFILE_STATE
PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" status >"$TEST_TMP/radio-status.out" 2>"$TEST_TMP/radio-status.err"

declare -A radio_status=()
while IFS=$'\t' read -r key value; do
  [[ -n $key ]] || continue
  radio_status[$key]=$value
done <"$TEST_TMP/radio-status.out"
[[ ${radio_status[iface]} == "wlan0" ]] || fail "multi-radio status selects the first Wi-Fi interface" "${radio_status[iface]}"
[[ ${radio_status[ap_capable]} == "1" ]] || fail "selected radio reports its own AP capability" "${radio_status[ap_capable]}"
[[ ${radio_status[ap_bands]} == "2.4,5" ]] || fail "status bands stay scoped to the selected PHY" "${radio_status[ap_bands]}"
[[ ${radio_status[ap_bands]} != *"6"* ]] || fail "status does not aggregate bands from another PHY" "${radio_status[ap_bands]}"
pass "status derives capability and bands from one selected PHY"

set +e
printf '%s\n' savedpassword | PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" apply Shared 6 >"$TEST_TMP/band6.out" 2>"$TEST_TMP/band6.err"
band6_status=$?
set -e
(( band6_status != 0 )) || fail "band validation rejects another radio's 6 GHz band"
[[ $(<"$TEST_TMP/band6.err") == *"band '6' is not available"* ]] || fail "band validation identifies the unsupported selected-radio band" "$(<"$TEST_TMP/band6.err")"
[[ ! -e $PROFILE_STATE ]] || fail "rejected band does not create a profile"
pass "band validation uses the selected radio"

printf '%s\n' savedpassword | PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" apply Shared 5 >"$TEST_TMP/band5.out" 2>"$TEST_TMP/band5.err"
printf '%s\n' savedpassword | PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" apply Shared 2.4 >"$TEST_TMP/reuse.out" 2>"$TEST_TMP/reuse.err"

add_bound=0
modify_bound=0
while IFS= read -r call; do
  if [[ $call == 'connection add type wifi ifname wlan0 '* ]]; then
    add_bound=1
  fi
  if [[ $call == 'connection modify omarchy-hotspot ssid Shared '* && $call == *' connection.interface-name wlan0' ]]; then
    modify_bound=1
  fi
done <"$NMCLI_LOG"
(( add_bound == 1 )) || fail "new profile binds to the selected Wi-Fi interface"
(( modify_bound == 1 )) || fail "existing profile is rebound to the selected Wi-Fi interface"
nmcli_log=$(<"$NMCLI_LOG")
[[ $nmcli_log != *"ifname p2p-dev-wlan9"* && $nmcli_log != *"connection.interface-name p2p-dev-wlan9"* ]] || fail "Wi-Fi selection never falls back to a P2P device"
pass "NM profile create and reuse follow the selected Wi-Fi interface"
