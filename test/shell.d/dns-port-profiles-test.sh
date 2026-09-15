#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
# Load the production functions without entering its privileged command path.
source <(sed '/^if (( $# == 0 )); then/,$d' "$ROOT/bin/omarchy-dns")

nmcli() {
  case "$*" in
    '-t -f UUID,TYPE connection show')
      if [[ ${reject_profiles:-no} == "yes" ]]; then
        printf '%s\n' 'link-local:802-3-ethernet' 'disabled:802-3-ethernet' 'ignore:802-3-ethernet'
      fi
      printf '%s\n' 'wifi:802-11-wireless' 'bridge-port:802-3-ethernet' 'bond-port:802-3-ethernet' 'team-port:802-3-ethernet' 'ethernet:802-3-ethernet' 'bridge:bridge'
      if [[ ${reject_profiles:-no} == "yes" ]]; then
        echo 'rejected-last:802-3-ethernet'
      fi
      ;;
    '-g connection.controller connection show bridge-port') echo br0 ;;
    '-g connection.controller connection show bond-port') echo bond0 ;;
    '-g connection.controller connection show team-port') echo team0 ;;
    '-g connection.controller connection show wifi'|'-g connection.controller connection show ethernet') ;;
    '-g connection.controller connection show link-local'|'-g connection.controller connection show disabled'|'-g connection.controller connection show ignore'|'-g connection.controller connection show rejected-last') ;;
    'connection modify link-local '*|'connection modify disabled '*|'connection modify ignore '*)
      if [[ $4 == "ipv4.ignore-auto-dns" && $5 == "yes" ]]; then
        echo "ipv6.dns: this property is not allowed for method=$3" >&2
        return 1
      fi
      printf '%s\n' "$*" >>"$test_tmp/modified"
      ;;
    'connection modify rejected-last '*) echo 'profile modification failed' >&2; return 1 ;;
    'general reload conf'|'general reload dns-full') printf '%s\n' "$*" >>"$test_tmp/reloaded" ;;
    '-t -f DEVICE,TYPE,STATE device status') ;;
    'connection modify bridge-port '*|'connection modify bond-port '*|'connection modify team-port '*) return 2 ;;
    'connection modify '*) printf '%s\n' "$*" >>"$test_tmp/modified" ;;
    *) fail "unexpected nmcli command" "$*" ;;
  esac
}

set_connection_dns '1.1.1.1' '2606:4700:4700::1111'
[[ $(wc -l <"$test_tmp/modified") == 2 ]] || fail "only standalone DNS profiles are modified"
grep -q 'connection modify ethernet ipv4.ignore-auto-dns yes' "$test_tmp/modified" || fail "profiles after ports still receive DNS"
pass "DNS configuration skips bridge, bond and team ports"

: >"$test_tmp/modified"
clear_connection_dns
[[ $(wc -l <"$test_tmp/modified") == 2 ]] || fail "only standalone profiles return to DHCP"
grep -q 'connection modify ethernet ipv4.ignore-auto-dns no' "$test_tmp/modified" || fail "profiles after ports return to DHCP"
pass "DHCP reset skips port profiles without aborting"

# Exercise the command dispatch with failed modifications. Redirect every system
# write and service operation so the test cannot change the host's network.
require_root() { :; }
tee() {
  [[ $1 == "/etc/systemd/resolved.conf" ]] || fail "unexpected config write" "$*"
  command tee "$test_tmp/resolved.conf"
}
systemctl() {
  printf '%s\n' "$*" >>"$test_tmp/reloaded"
}
NM_DNS_CONF="$test_tmp/networkmanager.conf"
reject_profiles=yes

for provider in Cloudflare Google Custom DHCP; do
  : >"$test_tmp/modified"
  : >"$test_tmp/reloaded"
  rm -f "$test_tmp/resolved.conf"
  # Do not put this subshell in a conditional: errexit must remain active.
  (
    source <(sed -n '/^if (( $# == 0 )); then/,$p' "$ROOT/bin/omarchy-dns") "$provider"
  ) <<<"9.9.9.9 2620:fe::fe" >"$test_tmp/output" 2>"$test_tmp/errors"

  grep -q 'connection modify ethernet ' "$test_tmp/modified" || fail "$provider reaches later profiles"
  grep -q 'omarchy-dns: skipped rejected-last' "$test_tmp/errors" || fail "$provider reports the failed profile"
  grep -q '^general reload dns-full$' "$test_tmp/reloaded" || fail "$provider completes the DNS reload"
  grep -q '^reload systemd-resolved.service$' "$test_tmp/reloaded" || fail "$provider reloads resolved"
  if [[ $provider == "DHCP" ]]; then
    [[ ! -e $NM_DNS_CONF ]] || fail "DHCP removes global DNS"
    grep -q '^DNSOverTLS=no$' "$test_tmp/resolved.conf" || fail "DHCP resets resolved"
    grep -q 'connection modify ethernet ipv4.ignore-auto-dns no' "$test_tmp/modified" || fail "DHCP clears later profiles"
  else
    [[ -s $NM_DNS_CONF ]] || fail "$provider writes global DNS"
    grep -q '^DNS=' "$test_tmp/resolved.conf" || fail "$provider writes resolved DNS"
    for method in link-local disabled ignore; do
      grep -q "omarchy-dns: skipped $method" "$test_tmp/errors" || fail "$provider reports rejected $method DNS"
    done
  fi
  pass "$provider continues after rejected profiles and completes resolver setup"
done
