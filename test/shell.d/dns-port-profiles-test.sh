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
      printf '%s\n' 'wifi:802-11-wireless' 'bridge-port:802-3-ethernet' 'bond-port:802-3-ethernet' 'team-port:802-3-ethernet' 'ethernet:802-3-ethernet' 'bridge:bridge'
      ;;
    '-g connection.controller connection show bridge-port') echo br0 ;;
    '-g connection.controller connection show bond-port') echo bond0 ;;
    '-g connection.controller connection show team-port') echo team0 ;;
    '-g connection.controller connection show wifi'|'-g connection.controller connection show ethernet') ;;
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
