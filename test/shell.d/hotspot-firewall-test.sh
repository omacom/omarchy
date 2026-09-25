#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TEST_TMP=$(mktemp -d)
trap 'rm -rf "$TEST_TMP"' EXIT
STUB_BIN="$TEST_TMP/bin"
STATE_DIR="$TEST_TMP/state"
FIREWALL_STATE="$STATE_DIR/firewall.state"
FORWARDING_STATE="$STATE_DIR/forwarding.state"
UFW_RULES_FILE="$TEST_TMP/user.rules"
mkdir -p "$STUB_BIN" "$STATE_DIR"

export TEST_TMP TEST_STATE_DIR="$STATE_DIR" HOTSPOT_FUNCTIONS="$TEST_TMP/hotspot-functions.sh"
export UFW_STATE="$TEST_TMP/ufw-state"
export UFW_LOG="$TEST_TMP/ufw-log"
export UFW_SHOW_LOG="$TEST_TMP/ufw-show-log"
export NMCLI_LOG="$TEST_TMP/nmcli-log"
export NMCLI_UP_LOG="$TEST_TMP/nmcli-up-log"
export NMCLI_ACTIVE="$TEST_TMP/nmcli-active"
export PROFILE_STATE="$TEST_TMP/profile"
export PROFILE_ADDRESS="10.55.0.1/24"
export SAVED_INTERFACE=""
export GENERAL_DEVICE=""
export FORWARDING_STATE_VALUE="$TEST_TMP/forwarding-value"
export SYSCTL_LOG="$TEST_TMP/sysctl-log"
export PRIVILEGED_LOG="$TEST_TMP/privileged-log"
export UFW_SHOW_ALLOWED=0
export OMARCHY_HOTSPOT_UFW_RULES="$UFW_RULES_FILE"
: >"$UFW_STATE"
: >"$UFW_LOG"
: >"$UFW_SHOW_LOG"
: >"$NMCLI_LOG"
: >"$NMCLI_UP_LOG"
: >"$SYSCTL_LOG"
: >"$PRIVILEGED_LOG"

cat >"$STUB_BIN/omarchy-cmd-present" <<'STUB'
#!/bin/bash
case "${1:-}" in
  ufw) (( ${UFW_PRESENT:-0} == 1 )) ;;
  firewalld) (( ${FIREWALLD_PRESENT:-0} == 1 )) ;;
  nft) (( ${NFT_PRESENT:-0} == 1 )) ;;
  dnsmasq) (( ${DNSMASQ_PRESENT:-1} == 1 )) ;;
  *) exit 1 ;;
esac
STUB

cat >"$STUB_BIN/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
[[ ${1:-} == "dnsmasq" ]] && (( ${DNSMASQ_PRESENT:-1} == 0 ))
STUB

cat >"$STUB_BIN/systemctl" <<'STUB'
#!/bin/bash
case "${1:-}:${2:-}" in
  is-active:ufw) (( ${UFW_ACTIVE:-0} == 1 )) ;;
  is-active:firewalld) (( ${FIREWALLD_ACTIVE:-0} == 1 )) ;;
  is-active:nftables) (( ${NFT_SERVICE_ACTIVE:-0} == 1 )) ;;
  *) exit 1 ;;
esac
STUB

cat >"$STUB_BIN/nft" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "list" && ${2:-} == "ruleset" ]]; then
  [[ ${NFT_ACTIVE:-0} == 1 ]] || exit 1
  [[ -n ${NFT_RULESET:-} ]] && printf '%s\n' "$NFT_RULESET"
  exit 0
fi
exit 1
STUB

cat >"$STUB_BIN/iw" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "dev" && ${2:-} == "wlan2" ]]; then
  printf '%s\n' 'Interface wlan2' '  type managed' '  wiphy 2'
  exit 0
fi
if [[ ${1:-} == "phy" && ${2:-} == "phy2" ]]; then
  printf '%s\n' 'Wiphy phy2' '  Band 1:' '    * AP'
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
  '-e no -g NAME connection show')
    [[ -e $PROFILE_STATE ]] && printf '%s\n' 'omarchy-hotspot'
    ;;
  '-t -f NAME connection show --active')
    [[ -e $NMCLI_ACTIVE ]] && printf '%s\n' 'omarchy-hotspot'
    ;;
  '-t -f DEVICE,TYPE device status')
    printf '%s\n' 'wlan2:wifi'
    ;;
  '-e no -g GENERAL.DEVICE connection show omarchy-hotspot')
    [[ -n ${GENERAL_DEVICE:-} ]] && printf '%s\n' "$GENERAL_DEVICE"
    ;;
  '-e no -g connection.interface-name connection show omarchy-hotspot')
    [[ -e $PROFILE_STATE && -n ${SAVED_INTERFACE:-} ]] && printf '%s\n' "$SAVED_INTERFACE"
    ;;
  '-e no -g 802-11-wireless.ssid connection show omarchy-hotspot')
    [[ -e $PROFILE_STATE ]] && printf '%s\n' 'Saved Hotspot'
    ;;
  '-e no -g 802-11-wireless.band connection show omarchy-hotspot')
    [[ -e $PROFILE_STATE ]] && printf '%s\n' 'bg'
    ;;
  'connection edit omarchy-hotspot')
    while IFS= read -r line; do
      :
    done
    ;;
  'connection add type wifi ifname wlan2 con-name omarchy-hotspot ssid Shared mode ap 802-11-wireless.band bg wifi-sec.key-mgmt wpa-psk ipv4.method shared ipv4.addresses 10.42.0.1/24 autoconnect no')
    touch "$PROFILE_STATE"
    ;;
  'connection up omarchy-hotspot')
    printf '%s\n' up >>"$NMCLI_UP_LOG"
    (( ${NMCLI_UP_SUCCEED:-1} == 1 )) || exit 1
    touch "$NMCLI_ACTIVE"
    printf '%s\n' "${FORWARDING_AFTER_UP:-1}" >"$FORWARDING_STATE_VALUE"
    ;;
  'connection down omarchy-hotspot')
    rm -f "$NMCLI_ACTIVE"
    (( ${NMCLI_DOWN_SUCCEED:-1} == 1 )) || exit 1
    if [[ ${KEEP_FORWARDING_ON_DOWN:-0} == 1 ]]; then
      :
    else
      printf '%s\n' "${FORWARDING_AFTER_DOWN:-0}" >"$FORWARDING_STATE_VALUE"
    fi
    ;;
esac
exit 0
STUB

cat >"$STUB_BIN/sysctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSCTL_LOG"
if [[ ${1:-} == "-n" && ${2:-} == "net.ipv4.ip_forward" ]]; then
  [[ -r $FORWARDING_STATE_VALUE ]] || exit 1
  tr -d '\n' <"$FORWARDING_STATE_VALUE"
  printf '\n'
  exit 0
fi
if [[ ${1:-} == "-q" && ${2:-} == "-w" && ${3:-} == "net.ipv4.ip_forward=0" ]]; then
  (( ${SYSCTL_FORWARDING_RESTORE_FAILS:-0} == 0 )) || exit 1
  printf '%s\n' 0 >"$FORWARDING_STATE_VALUE"
  exit 0
fi
if [[ ${1:-} == "-q" && ${2:-} == "-w" && ${3:-} == "net.ipv4.ip_forward=1" ]]; then
  printf '%s\n' 1 >"$FORWARDING_STATE_VALUE"
  exit 0
fi
exit 99
STUB

cat >"$STUB_BIN/ufw" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "show" && ${2:-} == "added" ]]; then
  printf '%s\n' 'show added' >>"$UFW_SHOW_LOG"
  if [[ ${UFW_SHOW_ALLOWED:-0} != 1 && ${EUID:-$(id -u)} != 0 ]]; then
    exit 77
  fi
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
  exit 0
fi
if [[ ${1:-} == "delete" ]]; then
  shift
  target=$*
  tmp="$TEST_TMP/ufw-state-next"
  : >"$tmp"
  while IFS= read -r rule; do
    [[ $rule == "$target" ]] || printf '%s\n' "$rule" >>"$tmp"
  done <"$UFW_STATE"
  mv "$tmp" "$UFW_STATE"
  exit 0
fi
exit 0
STUB

cat >"$STUB_BIN/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$PRIVILEGED_LOG"
shift
source "$HOTSPOT_FUNCTIONS"
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
require_privileged() { :; }
export UFW_SHOW_ALLOWED=1
case "${1:-}" in
  firewall-apply) shift; firewall_apply "$@" ;;
  firewall-rollback) shift; firewall_rollback "$@" ;;
  forwarding-enable) shift; forwarding_enable "$@" ;;
  forwarding-restore) shift; forwarding_restore "$@" ;;
  *) exit 97 ;;
esac
STUB
cp "$STUB_BIN/sudo" "$STUB_BIN/pkexec"
chmod +x "$STUB_BIN"/*

FUNCTIONS="$HOTSPOT_FUNCTIONS"
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

cat >"$TEST_TMP/backend-driver.sh" <<'DRIVER'
export UFW_PRESENT UFW_ACTIVE FIREWALLD_PRESENT FIREWALLD_ACTIVE NFT_PRESENT NFT_ACTIVE NFT_SERVICE_ACTIVE NFT_RULESET
UFW_PRESENT=1
UFW_ACTIVE=0
NFT_PRESENT=1
NFT_ACTIVE=0
NFT_SERVICE_ACTIVE=0
NFT_RULESET=''
[[ $(firewall_backend) == "none" ]] || fail "inactive firewall commands do not imply an active backend"
FIREWALLD_PRESENT=1
FIREWALLD_ACTIVE=1
[[ $(firewall_backend) == "firewalld" ]] || fail "active firewalld is detected"
FIREWALLD_ACTIVE=0
NFT_ACTIVE=1
NFT_RULESET=$'table ip docker-bridge\n  chain DOCKER-BRIDGE { type filter hook forward priority 0; }'
[[ $(firewall_backend) == "none" ]] || fail "Docker nft tables do not imply a firewall backend"
NFT_RULESET=$'table inet hotspot-test\n  chain input { type filter hook input priority filter; }'
[[ $(firewall_backend) == "none" ]] || fail "an unrelated nft table does not imply a firewall backend"
NFT_RULESET=$'table inet filter\n  chain DOCKER {\n  }\n  chain FORWARD { type filter hook forward priority 0; policy drop; }'
[[ $(firewall_backend) == "none" ]] || fail "Docker-shaped chains inside a filter table are not a firewall"
NFT_RULESET=$'table inet filter\n  chain input {\n  }'
[[ $(firewall_backend) == "none" ]] || fail "a regular chain without a base hook is not a firewall"
NFT_RULESET=$'table inet filter\n  chain input { type filter hook input priority filter; }'
[[ $(firewall_backend) == "nftables" ]] || fail "an nft filter table and input chain are detected"
NFT_RULESET=$'table inet firewalld\n  chain forward {\n    type filter hook forward priority filter;\n  }'
[[ $(firewall_backend) == "nftables" ]] || fail "an nft base chain declared on its own line is detected"
NFT_RULESET=''
NFT_SERVICE_ACTIVE=1
[[ $(firewall_backend) == "nftables" ]] || fail "an active nftables service is detected"
DRIVER
set +e
backend_output=$(run_isolated "$TEST_TMP/backend-driver.sh" 2>&1)
backend_status=$?
set -e
(( backend_status == 0 )) || fail "firewall backend detection requires active firewall state" "$backend_output"
pass "firewall backend detection excludes unrelated Docker nft state"

cat >"$TEST_TMP/apply-driver.sh" <<'DRIVER'
require_privileged() { :; }
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
export UFW_SHOW_ALLOWED=1
subnet=$(shared_subnet)
[[ $subnet == "10.55.0.0/24" ]]
mapfile -t added < <(firewall_apply wlan2 "$subnet")
(( ${#added[@]} == 4 ))
[[ $(stat -c %a "$FIREWALL_STATE_FILE") == "644" ]]
mapfile -t second < <(firewall_apply wlan2 "$subnet")
(( ${#second[@]} == 0 ))
count=0
while IFS=$'\t' read -r iface saved_subnet tag; do
  [[ $iface == "wlan2" ]]
  [[ $saved_subnet == "10.55.0.0/24" ]]
  case "$tag" in dhcp | dns-udp | dns-tcp | forward) ;; *) exit 1 ;; esac
  (( count += 1 ))
done <"$FIREWALL_STATE_FILE"
(( count == 4 ))
DRIVER
run_isolated "$TEST_TMP/apply-driver.sh"
: >"$UFW_SHOW_LOG"
: >"$PRIVILEGED_LOG"
cat >"$TEST_TMP/idempotent-driver.sh" <<'DRIVER'
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
UFW_PRESENT=1
UFW_ACTIVE=1
firewall_ensure
firewall_ensure
DRIVER
run_isolated "$TEST_TMP/idempotent-driver.sh"
[[ ! -s $UFW_SHOW_LOG ]] || fail "unprivileged idempotency does not read root-only UFW rules" "$(<"$UFW_SHOW_LOG")"
[[ ! -s $PRIVILEGED_LOG ]] || fail "complete readable ownership state avoids repeated privilege prompts" "$(<"$PRIVILEGED_LOG")"
pass "readable ownership state makes unprivileged starts idempotent"

cat >"$TEST_TMP/ownership-driver.sh" <<'DRIVER'
require_privileged() { :; }
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
export UFW_SHOW_ALLOWED=1
PROFILE_ADDRESS='10.55.0.1/24,10.66.0.1/24'
[[ $(shared_subnet) == "10.55.0.0/24" ]]
firewall_apply wlan2 10.42.0.0/24 >/dev/null
PROFILE_ADDRESS='10.55.0.1/24'
firewall_apply wlan2 10.55.0.0/24 >/dev/null
[[ $(wc -l <"$FIREWALL_STATE_FILE") == 8 ]]
firewall_remove
[[ ! -s $UFW_STATE ]]
[[ ! -s $FIREWALL_STATE_FILE ]]
DRIVER
run_isolated "$TEST_TMP/ownership-driver.sh"
pass "teardown removes retained interface and subnet ownership after profile changes"

cat >"$TEST_TMP/guard-driver.sh" <<'DRIVER'
firewall_apply wlan2 10.55.0.0/24
DRIVER
: >"$UFW_LOG"
if (( EUID != 0 )); then
  set +e
  guard_output=$(run_isolated "$TEST_TMP/guard-driver.sh" 2>&1)
  guard_status=$?
  set -e
  (( guard_status != 0 )) || fail "privileged firewall mutation rejects an unprivileged caller"
  [[ $guard_output == *"firewall rules need root"* ]] || fail "privileged firewall mutation explains the EUID guard" "$guard_output"
  [[ ! -s $UFW_LOG ]] || fail "rejected firewall mutation does not touch UFW" "$(<"$UFW_LOG")"
  pass "privileged firewall mutation rejects an unprivileged caller"
else
  skip "running as root; the unprivileged EUID guard cannot be proven here"
fi

for args in \
  'firewall-apply' \
  'firewall-apply wlan2' \
  'firewall-apply wlan2 10.55.0.0/24 extra' \
  'firewall-apply wlan2 not-a-subnet' \
  'firewall-rollback wlan2 10.55.0.0/24 all'; do
  : >"$PRIVILEGED_LOG"
  set +e
  dispatch_output=$(PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" $args 2>&1)
  dispatch_status=$?
  set -e
  (( dispatch_status != 0 )) || fail "invalid internal dispatch is rejected: $args"
  [[ $dispatch_output == *"invalid internal"* ]] || fail "invalid internal dispatch explains the contract: $args" "$dispatch_output"
  [[ ! -s $PRIVILEGED_LOG ]] || fail "invalid internal dispatch never escalates: $args" "$(<"$PRIVILEGED_LOG")"
done
pass "privileged firewall functions enforce EUID and dispatch argument contracts"

for backend in firewalld nftables; do
  if [[ $backend == firewalld ]]; then
    export UFW_PRESENT=0 FIREWALLD_PRESENT=1 FIREWALLD_ACTIVE=1 NFT_PRESENT=0 NFT_ACTIVE=0
  else
    export UFW_PRESENT=0 FIREWALLD_PRESENT=0 FIREWALLD_ACTIVE=0 NFT_PRESENT=1 NFT_ACTIVE=1 NFT_RULESET=$'table inet filter\n  chain input { type filter hook input priority filter; }'
  fi
  cat >"$TEST_TMP/start-unsupported-driver.sh" <<'DRIVER'
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
apply() { :; }
start Hotspot 2.4
DRIVER
  : >"$NMCLI_UP_LOG"
  set +e
  unsupported_start_output=$(run_isolated "$TEST_TMP/start-unsupported-driver.sh" 2>&1)
  unsupported_start_status=$?
  set -e
  (( unsupported_start_status != 0 )) || fail "$backend blocks hotspot activation explicitly"
  [[ $unsupported_start_output == *"$backend is active but unsupported"* ]] || fail "$backend start failure names the backend" "$unsupported_start_output"
  [[ ! -s $NMCLI_UP_LOG ]] || fail "$backend failure happens before AP activation" "$(<"$NMCLI_UP_LOG")"

  touch "$TEST_TMP/nmcli-active"
  cat >"$TEST_TMP/teardown-unsupported-driver.sh" <<'DRIVER'
require_root() { :; }
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
teardown
teardown
DRIVER
  set +e
  unsupported_teardown_output=$(run_isolated "$TEST_TMP/teardown-unsupported-driver.sh" 2>&1)
  unsupported_teardown_status=$?
  set -e
  (( unsupported_teardown_status == 0 )) || fail "$backend teardown warns without failing" "$unsupported_teardown_output"
  [[ ! -e $TEST_TMP/nmcli-active ]] || fail "$backend teardown stops the AP before warning"
  warnings=0
  while IFS= read -r line; do
    [[ $line != *"$backend is active but unsupported"* ]] || (( warnings += 1 ))
  done <<<"$unsupported_teardown_output"
  (( warnings == 2 )) || fail "$backend teardown warning is idempotent" "$unsupported_teardown_output"

  cat >"$TEST_TMP/setup-unsupported-driver.sh" <<'DRIVER'
require_root() { :; }
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
setup
setup
DRIVER
  set +e
  unsupported_setup_output=$(run_isolated "$TEST_TMP/setup-unsupported-driver.sh" 2>&1)
  unsupported_setup_status=$?
  set -e
  (( unsupported_setup_status == 0 )) || fail "$backend setup warns without failing" "$unsupported_setup_output"
  setup_warnings=0
  while IFS= read -r line; do
    [[ $line != *"$backend is active but unsupported"* ]] || (( setup_warnings += 1 ))
  done <<<"$unsupported_setup_output"
  (( setup_warnings == 2 )) || fail "$backend setup warning is idempotent" "$unsupported_setup_output"
done
pass "unsupported firewalls warn on setup and teardown but block start"

reset_firewall_fixture() {
  export UFW_PRESENT=1 UFW_ACTIVE=1 FIREWALLD_PRESENT=0 FIREWALLD_ACTIVE=0 NFT_PRESENT=0 NFT_ACTIVE=0 NFT_SERVICE_ACTIVE=0 NFT_RULESET=""
  : >"$UFW_STATE"
  : >"$UFW_LOG"
  rm -f "$FIREWALL_STATE" "$FORWARDING_STATE" "$PROFILE_STATE" "$TEST_TMP/nmcli-active" "$UFW_RULES_FILE"
  printf '%s\n' 0 >"$FORWARDING_STATE_VALUE"
  : >"$NMCLI_LOG"
  : >"$NMCLI_UP_LOG"
  : >"$SYSCTL_LOG"
  : >"$PRIVILEGED_LOG"
}

reset_firewall_fixture
cat >"$TEST_TMP/seed-one-rule-driver.sh" <<'DRIVER'
require_privileged() { :; }
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
export UFW_SHOW_ALLOWED=1
printf '%s\n' 'allow in on wlan2 proto udp to any port 67 comment omarchy-hotspot:dhcp' >"$UFW_STATE"
printf '%s\n' $'wlan2\t10.55.0.0/24\tdhcp' >"$FIREWALL_STATE_FILE"
printf '%s\n' 'allow in on wlan0 from 192.168.9.0/24 comment unrelated' >>"$UFW_STATE"
DRIVER
run_isolated "$TEST_TMP/seed-one-rule-driver.sh"
if (( EUID != 0 )); then
  set +e
  printf '%s\n' savedpassword | NMCLI_UP_SUCCEED=0 OMARCHY_HOTSPOT_STATE_DIR="$STATE_DIR" PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" start Shared 2.4 >"$TEST_TMP/start-failure.out" 2>"$TEST_TMP/start-failure.err"
  start_failure_status=$?
  set -e
  (( start_failure_status != 0 )) || fail "a real AP activation failure fails hotspot start"
  [[ $(<"$TEST_TMP/start-failure.err") == *"could not start hotspot"* ]] || fail "AP activation failure is explicit" "$(<"$TEST_TMP/start-failure.err")"
  [[ $(wc -l <"$NMCLI_UP_LOG") == 1 ]] || fail "real failure attempts AP activation once" "$(<"$NMCLI_UP_LOG")"
  [[ ! -e $TEST_TMP/nmcli-active ]] || fail "failed activation leaves the AP down"
  hotspot_rules=0
  while IFS= read -r rule; do
    [[ $rule == *omarchy-hotspot:* ]] && (( hotspot_rules += 1 ))
  done <"$UFW_STATE"
  (( hotspot_rules == 1 )) || fail "failed start removes only rules installed by that invocation" "$(<"$UFW_STATE")"
  grep -q 'wlan2.*port 67.*omarchy-hotspot:dhcp' "$UFW_STATE" || fail "rollback preserves a rule present before the invocation" "$(<"$UFW_STATE")"
  grep -q 'unrelated' "$UFW_STATE" || fail "rollback preserves unrelated firewall rules" "$(<"$UFW_STATE")"
  [[ $(<"$FIREWALL_STATE") == $'wlan2\t10.55.0.0/24\tdhcp' ]] || fail "rollback retains ownership only for preexisting rules" "$(<"$FIREWALL_STATE")"
  [[ $(<"$FORWARDING_STATE_VALUE") == 0 ]] || fail "failed start restores forwarding it enabled" "$(<"$FORWARDING_STATE_VALUE")"
  [[ ! -e $FORWARDING_STATE ]] || fail "failed start releases forwarding ownership" "$(<"$FORWARDING_STATE")"
  pass "real start failure rolls back only invocation-owned firewall and forwarding state"
else
  skip "running as root; the escalated start path would write the production state directory"
fi

cat >"$TEST_TMP/seed-complete-driver.sh" <<'DRIVER'
require_privileged() { :; }
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
export UFW_SHOW_ALLOWED=1
firewall_apply wlan2 10.55.0.0/24 >/dev/null
DRIVER
if (( EUID != 0 )); then
  run_isolated "$TEST_TMP/seed-complete-driver.sh"
  printf '%s\n' savedpassword | NMCLI_UP_SUCCEED=1 KEEP_FORWARDING_ON_DOWN=1 OMARCHY_HOTSPOT_STATE_DIR="$STATE_DIR" PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" start Shared 2.4
  [[ $(<"$FORWARDING_STATE_VALUE") == 1 ]] || fail "hotspot start explicitly enables forwarding"
  [[ -e $FORWARDING_STATE ]] || fail "hotspot records forwarding ownership"
  KEEP_FORWARDING_ON_DOWN=1 OMARCHY_HOTSPOT_STATE_DIR="$STATE_DIR" PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" stop
  [[ $(<"$FORWARDING_STATE_VALUE") == 0 ]] || fail "hotspot stop restores forwarding it enabled"
  [[ ! -e $FORWARDING_STATE ]] || fail "hotspot stop releases forwarding ownership"

  reset_firewall_fixture
  run_isolated "$TEST_TMP/seed-complete-driver.sh"
  printf '%s\n' 1 >"$FORWARDING_STATE_VALUE"
  : >"$PRIVILEGED_LOG"
  printf '%s\n' savedpassword | NMCLI_UP_SUCCEED=1 KEEP_FORWARDING_ON_DOWN=1 OMARCHY_HOTSPOT_STATE_DIR="$STATE_DIR" PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" start Shared 2.4
  KEEP_FORWARDING_ON_DOWN=1 OMARCHY_HOTSPOT_STATE_DIR="$STATE_DIR" PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" stop
  [[ $(<"$FORWARDING_STATE_VALUE") == 1 ]] || fail "hotspot stop preserves forwarding enabled by another routing user"
  [[ ! -e $FORWARDING_STATE ]] || fail "hotspot never claims externally enabled forwarding"

  reset_firewall_fixture
  run_isolated "$TEST_TMP/seed-complete-driver.sh"
  printf '%s\n' 1 >"$FORWARDING_STATE_VALUE"
  printf '%s\n' enabled >"$FORWARDING_STATE"
  touch "$TEST_TMP/nmcli-active"
  : >"$NMCLI_LOG"
  : >"$SYSCTL_LOG"
  set +e
  NMCLI_DOWN_SUCCEED=0 SYSCTL_FORWARDING_RESTORE_FAILS=1 OMARCHY_HOTSPOT_STATE_DIR="$STATE_DIR" PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" bash "$ROOT/bin/omarchy-hotspot" stop >"$TEST_TMP/stop.out" 2>"$TEST_TMP/stop.err"
  stop_status=$?
  set -e
  (( stop_status != 0 )) || fail "a failed teardown step still fails stop"
  stop_error=$(<"$TEST_TMP/stop.err")
  [[ $stop_error == *"could not stop hotspot"* ]] || fail "stop names the teardown failure" "$stop_error"
  [[ $stop_error == *"AP deactivation"* ]] || fail "stop reports the refused AP deactivation" "$stop_error"
  [[ $stop_error == *"IPv4 forwarding restore"* ]] || fail "stop reports the failed forwarding restore" "$stop_error"
  grep -q 'connection down omarchy-hotspot' "$NMCLI_LOG" || fail "stop still attempts AP deactivation" "$(<"$NMCLI_LOG")"
  grep -q 'net.ipv4.ip_forward=0' "$SYSCTL_LOG" || fail "stop still attempts the forwarding restore" "$(<"$SYSCTL_LOG")"
  pass "forwarding ownership is explicit, reversible, and preserves existing routing users"
  pass "stop attempts every teardown step and reports both failures together"
else
  skip "running as root; the escalated start and stop paths would write the production state directory"
fi

write_user_rules() {
  local path=$1 iface=$2 subnet=$3 omit=${4:-}
  local tag
  : >"$path"
  for tag in dhcp dns-udp dns-tcp forward; do
    [[ $tag == "$omit" ]] && continue
    case "$tag" in
      dhcp) printf -- '-A ufw-user-input -i %s -p udp --dport 67 -m comment --comment omarchy-hotspot:dhcp -j ACCEPT\n' "$iface" >>"$path" ;;
      dns-udp) printf -- '-A ufw-user-input -i %s -s %s -p udp --dport 53 -m comment --comment omarchy-hotspot:dns -j ACCEPT\n' "$iface" "$subnet" >>"$path" ;;
      dns-tcp) printf -- '-A ufw-user-input -i %s -s %s -p tcp --dport 53 -m comment --comment omarchy-hotspot:dns -j ACCEPT\n' "$iface" "$subnet" >>"$path" ;;
      forward) printf -- '-A ufw-user-forward -s %s -i %s -m comment --comment omarchy-hotspot:forward -j ACCEPT\n' "$subnet" "$iface" >>"$path" ;;
    esac
  done
}

reset_firewall_fixture
run_isolated "$TEST_TMP/seed-complete-driver.sh"
write_user_rules "$UFW_RULES_FILE" wlan2 10.55.0.0/24
: >"$UFW_STATE"
: >"$UFW_LOG"
: >"$UFW_SHOW_LOG"
: >"$PRIVILEGED_LOG"
cat >"$TEST_TMP/reconcile-present-driver.sh" <<'DRIVER'
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
UFW_PRESENT=1
UFW_ACTIVE=1
firewall_rules_present wlan2 10.55.0.0/24
firewall_ensure
DRIVER
run_isolated "$TEST_TMP/reconcile-present-driver.sh"
[[ ! -s $UFW_SHOW_LOG ]] || fail "reconciling rules does not need root-only UFW output" "$(<"$UFW_SHOW_LOG")"
[[ ! -s $PRIVILEGED_LOG ]] || fail "state and rules both intact avoids a privilege prompt" "$(<"$PRIVILEGED_LOG")"
[[ ! -s $UFW_LOG ]] || fail "intact rules are not reinstalled" "$(<"$UFW_LOG")"

write_user_rules "$UFW_RULES_FILE" wlan2 10.55.0.0/24 dns-tcp
: >"$UFW_LOG"
: >"$UFW_SHOW_LOG"
: >"$PRIVILEGED_LOG"
cat >"$TEST_TMP/reconcile-absent-driver.sh" <<'DRIVER'
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
UFW_PRESENT=1
UFW_ACTIVE=1
if firewall_rules_present wlan2 10.55.0.0/24; then
  echo "a rule deleted out of band still reads as installed" >&2
  exit 1
fi
firewall_ensure
DRIVER
run_isolated "$TEST_TMP/reconcile-absent-driver.sh"
[[ $(wc -l <"$UFW_STATE") == 4 ]] || fail "the repair reinstalls every hotspot rule" "$(<"$UFW_STATE")"
grep -q 'proto tcp to any port 53 comment omarchy-hotspot:dns' "$UFW_LOG" || fail "the repair reinstalls the deleted rule" "$(<"$UFW_LOG")"
if (( EUID != 0 )); then
  [[ -s $PRIVILEGED_LOG ]] || fail "an out-of-band rule deletion escalates instead of starting broken" "$(<"$UFW_LOG")"
fi
pass "firewall presence reconciles ownership state with the rules UFW enforces"

write_user_rules "$UFW_RULES_FILE" wlan0 10.66.0.0/24
cat >"$TEST_TMP/reconcile-foreign-driver.sh" <<'DRIVER'
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
if firewall_rules_present wlan2 10.55.0.0/24; then
  echo "another interface's rules read as this hotspot's rules" >&2
  exit 1
fi
DRIVER
run_isolated "$TEST_TMP/reconcile-foreign-driver.sh"
rm -f "$UFW_RULES_FILE"
cat >"$TEST_TMP/reconcile-unreadable-driver.sh" <<'DRIVER'
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
firewall_rules_present wlan2 10.55.0.0/24
printf '%s\n' $'wlan2\t10.55.0.0/24\tdhcp' >"$FIREWALL_STATE_FILE"
if firewall_rules_present wlan2 10.55.0.0/24; then
  echo "an incomplete ownership state reads as installed" >&2
  exit 1
fi
DRIVER
: >"$PRIVILEGED_LOG"
run_isolated "$TEST_TMP/reconcile-unreadable-driver.sh"
[[ ! -s $PRIVILEGED_LOG ]] || fail "an unreadable rules file leaves the ownership state decisive" "$(<"$PRIVILEGED_LOG")"
pass "an unreadable rules file leaves complete ownership state authoritative"

extract_function() {
  local name=$1 source=$2 destination=$3
  awk -v name="$name" '
    $0 == name "() {" { copying = 1 }
    copying { print }
    copying && $0 == "}" { exit }
  ' "$source" >"$destination"
}

extract_function privileged_run "$ROOT/bin/omarchy-hotspot" "$TEST_TMP/privileged-run.sh"
[[ -s $TEST_TMP/privileged-run.sh ]] || fail "hotspot has a privileged_run escalation path"
[[ $(grep -c '"\$function" "\$@"' "$TEST_TMP/privileged-run.sh" || true) == 1 ]] ||
  fail "privileged_run's root branch calls the mapped function" "$(<"$TEST_TMP/privileged-run.sh")"
[[ $(grep -c '"\$action" "\$@"' "$TEST_TMP/privileged-run.sh" || true) == 2 ]] ||
  fail "privileged_run escalates the action name to the helper entrypoints" "$(<"$TEST_TMP/privileged-run.sh")"

extract_function privileged_function "$ROOT/bin/omarchy-hotspot" "$TEST_TMP/privileged-function.sh"
[[ -s $TEST_TMP/privileged-function.sh ]] || fail "hotspot maps privileged action names to functions"
for action in firewall-apply firewall-rollback forwarding-enable forwarding-restore; do
  mapped=$(bash -c 'source "$1"; privileged_function "$2"' _ "$TEST_TMP/privileged-function.sh" "$action") ||
    fail "privileged action $action has a function mapping"
  [[ $mapped == "${action//-/_}" ]] || fail "privileged action $action maps to its own function name" "$mapped"
  grep -q "^${mapped}() {" "$ROOT/bin/omarchy-hotspot" || fail "the root path resolves a defined function for $action" "$mapped"
done
unknown_status=0
mapped=$(bash -c 'source "$1"; privileged_function firewall-explode' _ "$TEST_TMP/privileged-function.sh" 2>/dev/null) || unknown_status=$?
(( unknown_status == 1 )) || fail "an unknown privileged action is rejected" "exit: $unknown_status"
[[ -z $mapped ]] || fail "an unknown privileged action has no function mapping" "$mapped"
pass "privileged action names map to real function names"

if unshare --user --map-root-user true 2>/dev/null; then
  reset_firewall_fixture
  : >"$PRIVILEGED_LOG"
  cat >"$TEST_TMP/root-path-driver.sh" <<'DRIVER'
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
export UFW_SHOW_ALLOWED=1
privileged_run forwarding-enable
[[ $(<"$FORWARDING_STATE_VALUE") == 1 ]]
[[ -e $FORWARDING_STATE_FILE ]]
out=$(privileged_run firewall-apply wlan2 10.55.0.0/24)
[[ $out == $'dhcp\ndns-udp\ndns-tcp\nforward' ]]
[[ $(wc -l <"$FIREWALL_STATE_FILE") == 4 ]]
privileged_run firewall-rollback wlan2 10.55.0.0/24 dhcp dns-udp dns-tcp forward
[[ ! -s $UFW_STATE ]]
[[ ! -s $FIREWALL_STATE_FILE ]]
privileged_run forwarding-restore
[[ $(<"$FORWARDING_STATE_VALUE") == 0 ]]
[[ ! -e $FORWARDING_STATE_FILE ]]
root_status=0
privileged_run firewall-explode 2>/dev/null || root_status=$?
[[ $root_status == 2 ]]
DRIVER
  set +e
  root_path_output=$(unshare --user --map-root-user env PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" \
    bash -c 'source "$1"; source "$2"' _ "$FUNCTIONS" "$TEST_TMP/root-path-driver.sh" 2>&1)
  root_path_status=$?
  set -e
  (( root_path_status == 0 )) || fail "the root escalation path runs the real functions" "$root_path_output"
  [[ ! -s $PRIVILEGED_LOG ]] || fail "the root path never re-escalates" "$(<"$PRIVILEGED_LOG")"
  pass "the root escalation path calls the mapped functions directly"
else
  skip "no unprivileged user namespace; skipping the root escalation path probe"
fi

extract_function firewall_ensure "$ROOT/bin/omarchy-hotspot" "$TEST_TMP/firewall-ensure.sh"
[[ -s $TEST_TMP/firewall-ensure.sh ]] || fail "hotspot has a firewall_ensure path"
[[ $(<"$TEST_TMP/firewall-ensure.sh") == *"none)"* ]] || fail "firewall_ensure has an explicit none branch" "$(<"$TEST_TMP/firewall-ensure.sh")"
cat >"$TEST_TMP/backend-none-driver.sh" <<'DRIVER'
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
firewall_backend() { echo none; }
firewall_ensure
DRIVER
cat >"$TEST_TMP/backend-unknown-driver.sh" <<'DRIVER'
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
firewall_backend() { echo mystery; }
firewall_ensure
DRIVER
: >"$UFW_LOG"
: >"$PRIVILEGED_LOG"
run_isolated "$TEST_TMP/backend-none-driver.sh"
set +e
unknown_backend_output=$(run_isolated "$TEST_TMP/backend-unknown-driver.sh" 2>&1)
unknown_backend_status=$?
set -e
(( unknown_backend_status != 0 )) || fail "an unrecognized firewall backend is not silently accepted" "$unknown_backend_output"
[[ $unknown_backend_output == *"unrecognized firewall backend"* ]] || fail "an unrecognized firewall backend is named" "$unknown_backend_output"
[[ ! -s $UFW_LOG ]] || fail "a machine without a firewall needs no rules" "$(<"$UFW_LOG")"
[[ ! -s $PRIVILEGED_LOG ]] || fail "a machine without a firewall needs no privileges" "$(<"$PRIVILEGED_LOG")"
pass "firewall_ensure handles a missing firewall and refuses an unknown backend"

cat >"$TEST_TMP/state-type-driver.sh" <<'DRIVER'
require_privileged() { :; }
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
ln -s /dev/null "$FIREWALL_STATE_FILE"
out=$(firewall_state_records 2>&1) && exit 1
[[ $out == *"invalid hotspot firewall state file"* ]] || exit 1
if firewall_state_add_tags wlan2 10.55.0.0/24 dhcp 2>/dev/null; then
  echo "a symlinked ownership file is rewritten" >&2
  exit 1
fi
[[ -L $FIREWALL_STATE_FILE ]]
ln -s /dev/null "$FORWARDING_STATE_FILE"
out=$(forwarding_state_owned 2>&1) && exit 1
[[ $out == *"invalid hotspot forwarding state file"* ]] || exit 1
rm -f "$FIREWALL_STATE_FILE" "$FORWARDING_STATE_FILE"
mkdir -p "$FIREWALL_STATE_FILE"
out=$(firewall_state_records 2>&1) && exit 1
[[ $out == *"invalid hotspot firewall state file"* ]] || exit 1
rmdir "$FIREWALL_STATE_FILE"
DRIVER
reset_firewall_fixture
run_isolated "$TEST_TMP/state-type-driver.sh"
pass "state files are only trusted as regular non-symlink files"

if unshare --user --map-auto --map-root-user true 2>/dev/null; then
  reset_firewall_fixture
  cat >"$TEST_TMP/state-owner-driver.sh" <<'DRIVER'
require_privileged() { :; }
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
printf '%s\n' $'wlan2\t10.55.0.0/24\tdhcp' >"$FIREWALL_STATE_FILE"
[[ $(firewall_state_records) == $'wlan2\t10.55.0.0/24\tdhcp' ]]
other_uid=$(( $(id -u) + 1 ))
chown "$other_uid:$other_uid" "$FIREWALL_STATE_FILE" 2>/dev/null || exit 77
[[ $(stat -c %u "$FIREWALL_STATE_FILE") == "$other_uid" ]] || exit 77
out=$(firewall_state_records 2>&1) && exit 1
[[ $out == *"invalid hotspot firewall state file"* ]] || exit 1
if firewall_state_add_tags wlan2 10.55.0.0/24 forward 2>/dev/null; then
  echo "a state file owned by a normal user is rewritten as root" >&2
  exit 1
fi
chown 0:0 "$FIREWALL_STATE_FILE"
[[ $(firewall_state_records) == $'wlan2\t10.55.0.0/24\tdhcp' ]]
DRIVER
  set +e
  state_owner_output=$(unshare --user --map-auto --map-root-user env PATH="$STUB_BIN:$PATH" OMARCHY_PATH="$ROOT" \
    bash -c 'source "$1"; source "$2"' _ "$FUNCTIONS" "$TEST_TMP/state-owner-driver.sh" 2>&1)
  state_owner_status=$?
  set -e
  if (( state_owner_status == 77 )); then
    skip "the namespace cannot hand a state file to a normal user; skipping the ownership probe"
  elif (( state_owner_status != 0 )); then
    fail "root trusts only root-owned state files" "$state_owner_output"
  else
    pass "a root process trusts only root-owned state files"
  fi
else
  skip "no subordinate-id user namespace; skipping the state file ownership probe"
fi

cat >"$TEST_TMP/state-temp-driver.sh" <<'DRIVER'
require_privileged() { :; }
HOTSPOT_STATE_DIR="$TEST_STATE_DIR"
FIREWALL_STATE_FILE="$TEST_STATE_DIR/firewall.state"
FORWARDING_STATE_FILE="$TEST_STATE_DIR/forwarding.state"
printf '%s\n' $'wlan2\t10.55.0.0/24\tdhcp' >"$FIREWALL_STATE_FILE"
if firewall_state_add_tags wlan2 10.55.0.0/24 dns-udp not-a-tag 2>/dev/null; then
  echo "an invalid ownership tag is accepted" >&2
  exit 1
fi
[[ $(firewall_state_records) == $'wlan2\t10.55.0.0/24\tdhcp' ]]
DRIVER
reset_firewall_fixture
run_isolated "$TEST_TMP/state-temp-driver.sh"
[[ -z $(compgen -G "$STATE_DIR/.firewall.state.*" || true) ]] || fail "a failed ownership rewrite leaves no temp file behind"
pass "a failed ownership rewrite leaves the state directory clean"
