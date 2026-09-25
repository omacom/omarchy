#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TEST_TMP=$(mktemp -d)
trap 'rm -rf "$TEST_TMP"' EXIT
STUB_BIN="$TEST_TMP/bin"
mkdir -p "$STUB_BIN"

export UFW_STATE="$TEST_TMP/ufw-state"
export UFW_LOG="$TEST_TMP/ufw-log"
export NMCLI_LOG="$TEST_TMP/nmcli-log"
export NMCLI_STATE="$TEST_TMP/nmcli-state"
export FORWARDING_STATE="$TEST_TMP/forwarding-state"
export SYSCTL_LOG="$TEST_TMP/sysctl-log"
export PROFILE_ADDRESS="10.55.0.1/24"
: >"$UFW_STATE"
: >"$UFW_LOG"
: >"$NMCLI_LOG"
: >"$SYSCTL_LOG"

cat >"$STUB_BIN/omarchy-cmd-present" <<'STUB'
#!/bin/bash
case "${1:-}" in
  ufw) (( ${UFW_PRESENT:-0} == 1 )) ;;
  firewalld) (( ${FIREWALLD_PRESENT:-0} == 1 )) ;;
  nft) (( ${NFT_PRESENT:-0} == 1 )) ;;
  *) exit 1 ;;
esac
STUB

cat >"$STUB_BIN/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
[[ ${1:-} == "dnsmasq" ]] && exit 1
exit 0
STUB

cat >"$STUB_BIN/systemctl" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "is-active" && ${2:-} == "ufw" ]]; then
  (( ${UFW_ACTIVE:-0} == 1 ))
  exit
fi
if [[ ${1:-} == "is-active" && ${2:-} == "firewalld" ]]; then
  (( ${FIREWALLD_ACTIVE:-0} == 1 ))
  exit
fi
if [[ ${1:-} == "is-active" && ${2:-} == "nftables" ]]; then
  (( ${NFT_SERVICE_ACTIVE:-0} == 1 ))
  exit
fi
exit 1
STUB

cat >"$STUB_BIN/nft" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "list" && ${2:-} == "ruleset" && ${NFT_ACTIVE:-0} == 1 ]]; then
  printf '%s\n' 'table inet hotspot-test'
  exit 0
fi
exit 1
STUB

cat >"$STUB_BIN/nmcli" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$NMCLI_LOG"
case "$*" in
  '-e no -g ipv4.addresses connection show omarchy-hotspot')
    printf '%s\n' "${PROFILE_ADDRESS:-}"
    ;;
  '-t -f NAME connection show --active')
    [[ -e $NMCLI_STATE ]] && printf '%s\n' 'omarchy-hotspot'
    ;;
  '-t -f DEVICE,TYPE device status')
    printf '%s\n' 'wlan2:wifi'
    ;;
  '-e no -g GENERAL.DEVICE connection show omarchy-hotspot')
    printf '%s\n' 'wlan2'
    ;;
  'connection up omarchy-hotspot')
    printf '%s\n' active >"$NMCLI_STATE"
    printf '%s\n' "${FORWARDING_AFTER_UP:-1}" >"$FORWARDING_STATE"
    ;;
  'connection down omarchy-hotspot')
    printf '%s\n' inactive >"$NMCLI_STATE"
    if [[ ${KEEP_FORWARDING_ON_DOWN:-0} == 1 ]]; then
      printf '%s\n' 1 >"$FORWARDING_STATE"
    else
      printf '%s\n' "${FORWARDING_AFTER_DOWN:-0}" >"$FORWARDING_STATE"
    fi
    ;;
  *) exit 1 ;;
esac
STUB

cat >"$STUB_BIN/sysctl" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "-n" && ${2:-} == "net.ipv4.ip_forward" ]]; then
  [[ -r $FORWARDING_STATE ]] || exit 1
  tr -d '\n' <"$FORWARDING_STATE"
  printf '\n'
  exit 0
fi
printf '%s\n' "$*" >>"$SYSCTL_LOG"
exit 99
STUB

cat >"$STUB_BIN/ufw" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "show" && ${2:-} == "added" ]]; then
  [[ -r $UFW_STATE ]] || exit 0
  while IFS= read -r rule; do
    [[ -n $rule ]] || continue
    if [[ $rule == *" comment "* ]]; then
      prefix=${rule%comment *}
      tag=${rule##*comment }
      prefix=${prefix% }
      case "$prefix" in
        *" proto udp to any port 67")
          prefix=${prefix%" proto udp to any port 67"}
          prefix+=" to any port 67 proto udp"
          ;;
        *" proto udp to any port 53")
          prefix=${prefix%" proto udp to any port 53"}
          prefix+=" to any port 53 proto udp"
          ;;
        *" proto tcp to any port 53")
          prefix=${prefix%" proto tcp to any port 53"}
          prefix+=" to any port 53 proto tcp"
          ;;
      esac
      printf 'ufw %s comment '\''%s'\''\n' "$prefix" "$tag"
    else
      printf 'ufw %s\n' "$rule"
    fi
  done <"$UFW_STATE"
  exit 0
fi
printf '%s\n' "$*" >>"$UFW_LOG"
if [[ ${1:-} == "allow" || ${1:-} == "route" ]]; then
  printf '%s\n' "$*" >>"$UFW_STATE"
fi
STUB

cat >"$STUB_BIN/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' 'sudo' >>"$SYSCTL_LOG"
exit 97
STUB
cp "$STUB_BIN/sudo" "$STUB_BIN/pkexec"
chmod +x "$STUB_BIN"/*

FUNCTIONS="$TEST_TMP/hotspot-functions.sh"
while IFS= read -r line; do
  [[ $line == 'case "${1:-}" in' ]] && break
  printf '%s\n' "$line"
done <"$ROOT/bin/omarchy-hotspot" >"$FUNCTIONS"

run_isolated() {
  local driver=$1
  (
    PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash -c 'source "$1"; source "$2"' _ "$FUNCTIONS" "$driver"
  )
}

hotspot_source=$(<"$ROOT/bin/omarchy-hotspot")
[[ $hotspot_source != *"/etc/ufw/user.rules"* ]] || fail "stale UFW rules never imply an active backend"
[[ $hotspot_source != *"sysctl -w"* ]] || fail "hotspot never mutates shared IPv4 forwarding directly"
pass "backend detection and lifecycle avoid stale state"

cat >"$TEST_TMP/backend-driver.sh" <<'DRIVER'
export UFW_PRESENT UFW_ACTIVE FIREWALLD_PRESENT FIREWALLD_ACTIVE NFT_PRESENT NFT_ACTIVE NFT_SERVICE_ACTIVE
UFW_PRESENT=1
UFW_ACTIVE=0
FIREWALLD_PRESENT=0
NFT_PRESENT=1
NFT_ACTIVE=0
NFT_SERVICE_ACTIVE=0
[[ $(firewall_backend) == "none" ]] || fail "inactive UFW is not an active backend"
UFW_PRESENT=0
FIREWALLD_PRESENT=1
FIREWALLD_ACTIVE=1
[[ $(firewall_backend) == "firewalld" ]] || fail "active firewalld is detected"
FIREWALLD_PRESENT=0
NFT_PRESENT=1
NFT_ACTIVE=1
NFT_SERVICE_ACTIVE=0
[[ $(firewall_backend) == "nftables" ]] || fail "active nftables is detected"
NFT_ACTIVE=0
NFT_SERVICE_ACTIVE=1
[[ $(firewall_backend) == "nftables" ]] || fail "active nftables service is detected without a ruleset read"
NFT_SERVICE_ACTIVE=0
[[ $(firewall_backend) == "none" ]] || fail "inactive nftables is not an active backend"
DRIVER
set +e
backend_output=$(run_isolated "$TEST_TMP/backend-driver.sh" 2>&1)
backend_status=$?
set -e
(( backend_status == 0 )) || fail "only active firewall backends are detected" "$backend_output"
pass "only active firewall backends are detected"

cat >"$TEST_TMP/apply-driver.sh" <<'DRIVER'
subnet=$(shared_subnet)
[[ $subnet == "10.55.0.0/24" ]]
firewall_apply wlan2 "$subnet"
count=0
while IFS= read -r rule; do
  (( count += 1 ))
  case "$rule" in
    "ufw allow in on wlan2 to any port 67 proto udp comment 'omarchy-hotspot:dhcp'" | \
    "ufw allow in on wlan2 from 10.55.0.0/24 to any port 53 proto udp comment 'omarchy-hotspot:dns'" | \
    "ufw allow in on wlan2 from 10.55.0.0/24 to any port 53 proto tcp comment 'omarchy-hotspot:dns'" | \
    "ufw route allow in on wlan2 from 10.55.0.0/24 comment 'omarchy-hotspot:forward'") ;;
    *) fail "unexpected firewall rule" "$rule" ;;
  esac
done < <(ufw show added)
(( count == 4 )) || fail "firewall apply creates four rules" "count: $count"
firewall_apply wlan2 "$subnet"
adds=0
while IFS= read -r call; do
  (( adds += 1 ))
done <"$UFW_LOG"
(( adds == 4 ))
[[ $(<"$UFW_STATE") != *"10.42.0.0/24"* ]]
broad=0
while IFS= read -r rule; do
  [[ $rule != "allow in on wlan2 from 10.55.0.0/24" ]] || broad=1
done <"$UFW_STATE"
(( broad == 0 )) || fail "firewall rules do not add a broad subnet allow"
DRIVER
set +e
apply_output=$(run_isolated "$TEST_TMP/apply-driver.sh" 2>&1)
apply_status=$?
set -e
(( apply_status == 0 )) || fail "custom shared subnet gets four idempotent least-privilege rules" "$apply_output"
pass "custom shared subnet gets four idempotent least-privilege rules"

cat >"$TEST_TMP/ownership-driver.sh" <<'DRIVER'
subnet=$(shared_subnet)
: >"$UFW_STATE"
: >"$UFW_LOG"
printf '%s\n' 'allow in on wlan2 from 10.55.0.0/24' 'route allow in on wlan2 from 10.55.0.0/24' >"$UFW_STATE"
firewall_remove wlan2 "$subnet"
[[ ! -s $UFW_LOG ]]
: >"$UFW_LOG"
printf '%s\n' \
  'allow in on wlan2 proto udp to any port 67 comment omarchy-hotspot:dhcp' \
  'allow in on wlan2 from 10.55.0.0/24 proto udp to any port 53 comment omarchy-hotspot:dns' \
  'allow in on wlan2 from 10.55.0.0/24 proto tcp to any port 53 comment omarchy-hotspot:dns' \
  'route allow in on wlan2 from 10.55.0.0/24 comment omarchy-hotspot:forward' >"$UFW_STATE"
firewall_remove wlan2 "$subnet"
deletes=0
while IFS= read -r call; do
  (( deletes += 1 ))
  [[ $call == *omarchy-hotspot:* ]]
done <"$UFW_LOG"
(( deletes == 4 ))
DRIVER
run_isolated "$TEST_TMP/ownership-driver.sh"
pass "teardown removes only rules carrying the hotspot owner tag"

for backend in firewalld nftables; do
  if [[ $backend == firewalld ]]; then
    export UFW_PRESENT=0 FIREWALLD_PRESENT=1 FIREWALLD_ACTIVE=1 NFT_PRESENT=0 NFT_ACTIVE=0
  else
    export UFW_PRESENT=0 FIREWALLD_PRESENT=0 FIREWALLD_ACTIVE=0 NFT_PRESENT=1 NFT_ACTIVE=1
  fi
  cat >"$TEST_TMP/unsupported-driver.sh" <<'DRIVER'
ap_iface() { printf '%s\n' wlan2; }
firewall_ensure
DRIVER
  set +e
  unsupported_output=$(run_isolated "$TEST_TMP/unsupported-driver.sh" 2>&1)
  unsupported_status=$?
  set -e
  (( unsupported_status != 0 )) || fail "$backend blocks hotspot start"
  [[ $unsupported_output == *"$backend is active but unsupported"* ]] || fail "$backend failure is explicit" "$unsupported_output"
  [[ $unsupported_output == *"DHCP"* && $unsupported_output == *"DNS"* && $unsupported_output == *"forwarding"* && $unsupported_output == *"wlan2"* ]] || fail "$backend failure is actionable" "$unsupported_output"
done
pass "active unsupported firewalls block broken sharing"

for backend in firewalld nftables; do
  if [[ $backend == firewalld ]]; then
    export UFW_PRESENT=0 FIREWALLD_PRESENT=1 FIREWALLD_ACTIVE=1 NFT_PRESENT=0 NFT_ACTIVE=0
  else
    export UFW_PRESENT=0 FIREWALLD_PRESENT=0 FIREWALLD_ACTIVE=0 NFT_PRESENT=1 NFT_ACTIVE=1
  fi
  cat >"$TEST_TMP/unsupported-teardown-driver.sh" <<'DRIVER'
require_root() { :; }
stop() { :; }
ap_iface() { printf '%s\n' wlan2; }
teardown
DRIVER
  set +e
  unsupported_teardown_output=$(run_isolated "$TEST_TMP/unsupported-teardown-driver.sh" 2>&1)
  unsupported_teardown_status=$?
  set -e
  (( unsupported_teardown_status != 0 )) || fail "$backend teardown fails explicitly"
  [[ $unsupported_teardown_output == *"$backend is active but unsupported"* ]] || fail "$backend teardown failure is explicit" "$unsupported_teardown_output"
done
pass "active unsupported firewalls fail teardown explicitly"

cat >"$TEST_TMP/forwarding-fail-driver.sh" <<'DRIVER'
apply() { :; }
firewall_ensure() { :; }
export FORWARDING_AFTER_UP=0
printf '%s\n' 0 >"$FORWARDING_STATE"
start Hotspot 2.4
DRIVER
set +e
forwarding_failure=$(run_isolated "$TEST_TMP/forwarding-fail-driver.sh" 2>&1)
forwarding_failure_status=$?
set -e
(( forwarding_failure_status != 0 )) || fail "hotspot start rejects disabled IPv4 forwarding"
[[ $forwarding_failure == *"IPv4 forwarding is not enabled"* ]] || fail "forwarding failure is explicit" "$forwarding_failure"
[[ $(<"$NMCLI_STATE") == "inactive" ]] || fail "failed forwarding check leaves the hotspot down"
[[ ! -s $SYSCTL_LOG ]] || fail "failed forwarding check does not mutate global sysctl state"
pass "start fails closed when NetworkManager does not enable forwarding"

cat >"$TEST_TMP/forwarding-driver.sh" <<'DRIVER'
apply() { :; }
firewall_ensure() { :; }
printf '%s\n' 0 >"$FORWARDING_STATE"
start Hotspot 2.4
[[ $(<"$FORWARDING_STATE") == "1" ]]
stop
[[ $(<"$NMCLI_STATE") == "inactive" ]]
[[ $(<"$FORWARDING_STATE") == "0" ]]
printf '%s\n' 0 >"$FORWARDING_STATE"
export KEEP_FORWARDING_ON_DOWN=1
start Hotspot 2.4
stop
[[ $(<"$FORWARDING_STATE") == "1" ]]
[[ ! -s $SYSCTL_LOG ]]
DRIVER
run_isolated "$TEST_TMP/forwarding-driver.sh"
pass "start and stop leave forwarding to NetworkManager's shared-connection lifecycle"
