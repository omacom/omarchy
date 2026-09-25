#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

dns="$ROOT/bin/omarchy-dns"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
config_root="$test_tmp/root"
nmcli_state="$test_tmp/nmcli"
stub_bin="$test_tmp/bin"
mkdir -p "$config_root/etc/systemd/resolved.conf.d" "$config_root/etc/NetworkManager/conf.d" "$config_root/var/lock" "$nmcli_state" "$stub_bin"
resolved_conf="$config_root/etc/systemd/resolved.conf"
external_drop_in="$config_root/etc/systemd/resolved.conf.d/99-external.conf"
drop_in="$config_root/etc/systemd/resolved.conf.d/90-omarchy-dns.conf"
nm_conf="$config_root/etc/NetworkManager/conf.d/20-omarchy-dns.conf"
lock_file="$config_root/var/lock/omarchy-dns.lock"
export TEST_ROOT="$config_root" NMCLI_STATE="$nmcli_state" CALL_LOG="$test_tmp/calls.log"

profile_file() {
  local uuid="$1" property="$2"
  printf '%s/profile-%s.%s\n' "$NMCLI_STATE" "$uuid" "${property//./-}"
}

set_profile() {
  local uuid="$1" property="$2" value="$3"
  printf '%s\n' "$value" >"$(profile_file "$uuid" "$property")"
}

profile_snapshot() {
  local uuid property value
  for uuid in wired-uuid wifi-uuid vpn-uuid tun-uuid; do
    for property in ipv4.ignore-auto-dns ipv4.dns ipv6.ignore-auto-dns ipv6.dns; do
      value=$(<"$(profile_file "$uuid" "$property")")
      printf '%s\t%s\t%s\n' "$uuid" "$property" "$value"
    done
  done
}

for uuid in wired-uuid wifi-uuid vpn-uuid tun-uuid; do
  set_profile "$uuid" ipv4.ignore-auto-dns no
  set_profile "$uuid" ipv4.dns 198.51.100.10
  set_profile "$uuid" ipv6.ignore-auto-dns no
  set_profile "$uuid" ipv6.dns 2001:db8::10
done

cat >"$stub_bin/nmcli" <<'STUB'
#!/bin/bash
set -u
printf '%s\n' "$*" >>"${CALL_LOG:?}"
if [[ ${1-} == -t && ${2-} == -f && ${3-} == UUID,TYPE ]]; then
  printf '%s\n' 'wired-uuid:802-3-ethernet' 'wifi-uuid:802-11-wireless' 'vpn-uuid:vpn' 'tun-uuid:tun'
  exit 0
fi
if [[ ${1-} == -g ]]; then
  property=${2-}
  uuid=${@: -1}
  file="${NMCLI_STATE}/profile-${uuid}.${property//./-}"
  [[ -f $file ]] && printf '%s\n' "$(<"$file")"
  exit 0
fi
if [[ ${1-} == connection && ${2-} == modify ]]; then
  uuid=$3
  shift 3
  while (($# >= 2)); do
    property=$1
    value=${2-}
    printf '%s\n' "$value" >"${NMCLI_STATE}/profile-${uuid}.${property//./-}"
    shift 2
  done
  exit 0
fi
if [[ ${1-} == device && ${2-} == status ]]; then
  printf '%s\n' 'eth0:ethernet:connected'
  exit 0
fi
exit 0
STUB
chmod +x "$stub_bin/nmcli"

cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${CALL_LOG:?}"
if [[ ${1-} == is-active ]]; then
  exit 1
fi
exit 0
STUB
chmod +x "$stub_bin/systemctl"

cat >"$stub_bin/getent" <<'STUB'
#!/bin/bash
case "${1-}:${2-}" in
  ahostsv4:dot.example)
    printf '%s\n' '192.0.2.70 dot.example'
    ;;
  ahostsv6:dot.example)
    printf '%s\n' '2001:db8::70 dot.example'
    ;;
  *)
    exit 2
    ;;
esac
STUB
chmod +x "$stub_bin/getent"

for command in tee sudo pkexec; do
  cat >"$stub_bin/$command" <<'STUB'
#!/bin/bash
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
exit 97
STUB
  chmod +x "$stub_bin/$command"
done

for command in install rm cp mv; do
  cat >"$stub_bin/$command" <<'STUB'
#!/bin/bash
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
for argument in "$@"; do
  [[ $argument == /* ]] || continue
  [[ $argument == "${TEST_ROOT:?}"/* ]] || exit 98
 done
exec "/usr/bin/${0##*/}" "$@"
STUB
  chmod +x "$stub_bin/$command"
done

cat >"$stub_bin/chown" <<'STUB'
#!/bin/bash
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
for argument in "$@"; do
  [[ $argument == /* ]] || continue
  [[ $argument == "${TEST_ROOT:?}"/* ]] || exit 98
 done
exit 0
STUB
chmod +x "$stub_bin/chown"

for command in chmod mktemp flock; do
  cat >"$stub_bin/$command" <<'STUB'
#!/bin/bash
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
for argument in "$@"; do
  [[ $argument == /* ]] || continue
  [[ $argument == "${TEST_ROOT:?}"/* ]] || exit 98
 done
exec "/usr/bin/${0##*/}" "$@"
STUB
  chmod +x "$stub_bin/$command"
done

printf '%s\n' '[Resolve]' 'DNS=192.0.2.99' 'DNSSEC=allow-downgrade' 'Domains=~.' >"$resolved_conf"
printf '%s\n' '# external drop-in' >"$external_drop_in"
resolved_before=$(<"$resolved_conf")
external_before=$(<"$external_drop_in")
profiles_before=$(profile_snapshot)

run_dns() {
  local input="$1"
  if OUTPUT=$(printf '%s\n' "$input" | PATH="$stub_bin:$PATH" OMARCHY_DNS_CONFIG_ROOT="$config_root" bash "$dns" Custom 2>&1); then
    STATUS=0
  else
    STATUS=$?
  fi
}

assert_success() {
  ((STATUS == 0)) || fail "$1" "$OUTPUT"
}

assert_failure() {
  ((STATUS != 0)) || fail "$1" "$OUTPUT"
}

run_dns "192.0.2.70 dot.example"
assert_failure "rejects mixed plain and custom DoT input"
[[ $OUTPUT == *"invalid custom DNS input"* ]] || fail "reports mixed custom DNS input as invalid" "$OUTPUT"
[[ ! -e $drop_in && ! -e $nm_conf && ! -e $lock_file ]] || fail "invalid custom DNS input writes no configuration or lock"
[[ $(<"$resolved_conf") == "$resolved_before" ]] || fail "invalid custom DNS input preserves resolved.conf"
[[ $(<"$external_drop_in") == "$external_before" ]] || fail "invalid custom DNS input preserves unrelated drop-ins"
[[ $(profile_snapshot) == "$profiles_before" ]] || fail "invalid custom DNS input preserves connection profiles"

run_dns "dot.example"
assert_success "applies hostname custom DoT"
grep -Fxq 'DNSOverTLS=yes' "$drop_in" || fail "hostname custom DoT requires authenticated DNSOverTLS=yes" "$(<"$drop_in")"
! grep -Fxq 'DNSOverTLS=opportunistic' "$drop_in" || fail "hostname custom DoT never falls back to opportunistic TLS"
resolved_dns_line=$(grep -E '^DNS=.+$' "$drop_in")
for server in $resolved_dns_line; do
  [[ $server == *#dot.example ]] || fail "hostname custom DoT retains SNI for every server" "$server"
done
[[ ! -e $nm_conf ]] || fail "hostname custom DoT does not also write plain NetworkManager DNS"
for uuid in wired-uuid wifi-uuid; do
  [[ $(<"$(profile_file "$uuid" ipv4.ignore-auto-dns)") == yes ]] || fail "hostname custom DoT suppresses automatic IPv4 DNS on $uuid"
  [[ -z $(<"$(profile_file "$uuid" ipv4.dns)") ]] || fail "hostname custom DoT clears plain IPv4 DNS on $uuid"
  [[ $(<"$(profile_file "$uuid" ipv6.ignore-auto-dns)") == yes ]] || fail "hostname custom DoT suppresses automatic IPv6 DNS on $uuid"
  [[ -z $(<"$(profile_file "$uuid" ipv6.dns)") ]] || fail "hostname custom DoT clears plain IPv6 DNS on $uuid"
done

run_dns "192.0.2.80 2001:db8::80"
assert_success "applies plain custom DNS"
grep -Fxq 'DNSOverTLS=no' "$drop_in" || fail "plain custom DNS remains unencrypted" "$(<"$drop_in")"
! grep -Fxq 'DNSOverTLS=yes' "$drop_in" || fail "plain custom DNS does not retain strict DoT"
grep -Fxq 'DNS=192.0.2.80 2001:db8::80' "$drop_in" || fail "plain custom DNS writes only plain servers" "$(<"$drop_in")"
[[ -f $nm_conf ]] || fail "plain custom DNS configures NetworkManager"
grep -Fxq 'servers=192.0.2.80,2001:db8::80' "$nm_conf" || fail "plain custom DNS keeps NetworkManager servers plain" "$(<"$nm_conf")"

run_dns "[192.0.2.60]:5353 [2001:db8::60]:5353"
assert_success "applies custom DNS ports"
grep -Fxq 'servers=dns+udp://192.0.2.60:5353,dns+udp://[2001:db8::60]:5353' "$nm_conf" ||
  fail "NetworkManager receives URI-form custom DNS ports" "$(<"$nm_conf")"
grep -Fxq 'DNS=192.0.2.60:5353 [2001:db8::60]:5353' "$drop_in" ||
  fail "systemd-resolved receives address-port custom DNS" "$(<"$drop_in")"
! grep -Fq '[192.0.2.60]:5353' "$nm_conf" "$drop_in" ||
  fail "custom DNS never emits an invalid bracketed IPv4 port" "$(<"$nm_conf")"$'\n'"$(<"$drop_in")"

run_dns "192.0.2.90#sni.example"
assert_success "applies explicit SNI custom DoT"
grep -Fxq 'DNSOverTLS=yes' "$drop_in" || fail "SNI custom DoT requires authenticated DNSOverTLS=yes" "$(<"$drop_in")"
grep -Fxq 'DNS=192.0.2.90#sni.example' "$drop_in" || fail "SNI custom DoT retains the hostname" "$(<"$drop_in")"
[[ ! -e $nm_conf ]] || fail "SNI custom DoT removes prior plain NetworkManager DNS"

sni_drop_in=$(<"$drop_in")
sni_profiles=$(profile_snapshot)

run_dns "192.0.2.70 dot.example"
assert_failure "rejects mixed transport after valid custom state"
[[ $(<"$drop_in") == "$sni_drop_in" ]] || fail "invalid mixed transport preserves the DoT drop-in"
[[ $(<"$resolved_conf") == "$resolved_before" ]] || fail "invalid mixed transport preserves resolved.conf"
[[ $(<"$external_drop_in") == "$external_before" ]] || fail "invalid mixed transport preserves unrelated drop-ins"
[[ $(profile_snapshot) == "$sni_profiles" ]] || fail "invalid mixed transport preserves DoT profiles"
[[ ! -e $nm_conf ]] || fail "invalid mixed transport does not create plain NetworkManager state"

pass "custom DNS transport is strict and internally consistent"
