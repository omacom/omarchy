#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

if (( EUID == 0 )); then
  skip "an unreadable drop-in needs a non-root user"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'chmod -R u+rw "$test_tmp"; rm -rf "$test_tmp"' EXIT
drop_in="$test_tmp/20-omarchy-dns.conf"
printf '[global-dns-domain-*]\nservers=1.1.1.1\n' >"$drop_in"
chmod 000 "$drop_in"

functions="$test_tmp/functions.sh"
sed -n '/^networkmanager_global_dns()/,/^}/p; /^resolved_dns()/,/^}/p; /^current_dns_provider()/,/^}/p' \
  "$ROOT/bin/omarchy-dns" >"$functions"

set +e
output=$(NM_DNS_CONF="$drop_in" bash -c 'set -euo pipefail; source "$1"; current_dns_provider' _ "$functions" 2>"$test_tmp/stderr")
status=$?
set -e

(( status == 0 )) || fail "dns status survives an unreadable NetworkManager drop-in" "exit $status: $(<"$test_tmp/stderr")"
[[ -n $output ]] || fail "dns status prints a provider when the NetworkManager drop-in is unreadable"
pass "dns status falls back when the NetworkManager drop-in is unreadable"
