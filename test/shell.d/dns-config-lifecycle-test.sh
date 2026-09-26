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
  local uuid property file
  for uuid in wired-uuid wifi-uuid vpn-uuid tun-uuid; do
    for property in ipv4.ignore-auto-dns ipv4.dns ipv6.ignore-auto-dns ipv6.dns; do
      file=$(profile_file "$uuid" "$property")
      if [[ -f $file ]]; then
        printf '%s\t%s\t%s\n' "$uuid" "$property" "$(<"$file")"
      else
        printf '%s\t%s\t\n' "$uuid" "$property"
      fi
    done
  done
}

unrelated_profile_snapshot() {
  local uuid file
  for uuid in wired-uuid wifi-uuid vpn-uuid tun-uuid; do
    file=$(profile_file "$uuid" connection.autoconnect)
    printf '%s\t%s\n' "$uuid" "$(<"$file")"
  done
}

for uuid in wired-uuid wifi-uuid vpn-uuid tun-uuid; do
  set_profile "$uuid" ipv4.ignore-auto-dns no
  set_profile "$uuid" ipv4.dns 198.51.100.10
  set_profile "$uuid" ipv6.ignore-auto-dns no
  set_profile "$uuid" ipv6.dns 2001:db8::10
  set_profile "$uuid" connection.autoconnect yes
done

cat >"$stub_bin/nmcli" <<'STUB'
#!/bin/bash
set -u
printf '%s\n' "$*" >>"${CALL_LOG:?}"
if [[ ${1-} == -t && ${2-} == -f && ${3-} == UUID,TYPE ]]; then
  [[ ${NMCLI_NO_PROFILES:-0} != 1 ]] || exit 0
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
if [[ ${SYSTEMCTL_FAIL_RELOAD:-0} == 1 && ( $* == *"reload systemd-resolved.service"* || $* == *"restart systemd-resolved.service"* ) ]]; then
  exit 1
fi
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

for command in install rm cp mv sed; do
  cat >"$stub_bin/$command" <<'STUB'
#!/bin/bash
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
for argument in "$@"; do
  [[ $argument == /* ]] || continue
  [[ $argument == "${TEST_ROOT:?}"/* ]] || exit 98
 done
if [[ ${0##*/} == mv && ${FAIL_WRITE:-0} == 1 ]]; then
  exit 97
fi
exec "/usr/bin/${0##*/}" "$@"
STUB
  chmod +x "$stub_bin/$command"
done

cat >"$stub_bin/chown" <<'STUB'
#!/bin/bash
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
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

printf '%s\n' '[Resolve]' 'DNS=192.0.2.99' 'FallbackDNS=9.9.9.9#dns.quad9.net' 'DNSSEC=allow-downgrade' 'Domains=~.' >"$resolved_conf"
printf '%s\n' '# external drop-in' >"$config_root/etc/systemd/resolved.conf.d/99-external.conf"
main_before=$(<"$resolved_conf")
external_before=$(<"$config_root/etc/systemd/resolved.conf.d/99-external.conf")
unrelated_profiles_before=$(unrelated_profile_snapshot)

run_dns() {
  local provider="$1" input="${2-}"
  if [[ -n $input ]]; then
    if OUTPUT=$(printf '%s\n' "$input" | PATH="$stub_bin:$PATH" OMARCHY_DNS_CONFIG_ROOT="$config_root" bash "$dns" "$provider" 2>&1); then
      STATUS=0
    else
      STATUS=$?
    fi
  elif OUTPUT=$(PATH="$stub_bin:$PATH" OMARCHY_DNS_CONFIG_ROOT="$config_root" bash "$dns" "$provider" 2>&1); then
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

printf '%s\n' 'unmanaged collision' >"$nm_conf"
nm_conf_before=$(<"$nm_conf")
run_dns Custom "192.0.2.70"
assert_failure "refuses an unmanaged NetworkManager DNS collision"
[[ $OUTPUT == *unmanaged* ]] || fail "reports an unmanaged NetworkManager DNS collision" "$OUTPUT"
[[ $(<"$nm_conf") == "$nm_conf_before" ]] || fail "does not overwrite an unmanaged NetworkManager DNS file"
[[ ! -e $drop_in ]] || fail "checks all managed targets before writing"
rm -f "$nm_conf"

printf '%s\n' 'unmanaged collision' >"$drop_in"
run_dns Custom "192.0.2.70"
assert_failure "refuses an unmanaged resolved drop-in collision"
[[ $OUTPUT == *unmanaged* ]] || fail "reports an unmanaged resolved drop-in collision" "$OUTPUT"
[[ $(<"$drop_in") == "unmanaged collision" ]] || fail "does not overwrite an unmanaged resolved drop-in"
[[ ! -e $nm_conf ]] || fail "does not write NetworkManager DNS after a resolved collision"
rm -f "$drop_in"

lock_target="$test_tmp/lock-target"
printf '%s\n' 'lock target' >"$lock_target"
rm -f "$lock_file"
ln -s "$lock_target" "$lock_file"
run_dns DHCP
assert_failure "refuses an unsafe DNS lock collision"
[[ $(<"$lock_target") == "lock target" ]] || fail "does not follow an unsafe DNS lock symlink"
[[ ! -e $drop_in ]] || fail "does not configure DNS after an unsafe lock collision"
rm -f "$lock_file"

run_dns Custom "192.0.2.70#dot.example"
assert_success "writes custom DoT configuration"
first_drop_in=$(<"$drop_in")
first_mode=$(stat -c '%a' "$drop_in")
[[ $first_mode == 644 ]] || fail "custom DoT publishes mode 0644"
[[ $(stat -c '%a' "$lock_file") == 600 ]] || fail "DNS transaction lock publishes mode 0600"
grep -Eq "chown 0:0 .*${config_root}/etc/systemd/resolved.conf.d/.omarchy-dns\." "$CALL_LOG" ||
  fail "custom DoT sets root ownership before publishing"
grep -Fqx "$stub_bin/chown 0:0 $lock_file" "$CALL_LOG" ||
  fail "DNS transaction lock sets root ownership"
run_dns Custom "192.0.2.70#dot.example"
assert_success "repeats custom DoT configuration"
[[ $(<"$drop_in") == "$first_drop_in" ]] || fail "custom DoT configuration is idempotent"
[[ $(stat -c '%a' "$drop_in") == "$first_mode" ]] || fail "custom DoT configuration keeps its mode"
[[ $(<"$resolved_conf") == "$main_before" ]] || fail "custom DoT preserves resolved.conf"
[[ $(<"$config_root/etc/systemd/resolved.conf.d/99-external.conf") == "$external_before" ]] || fail "custom DoT preserves unrelated drop-ins"
[[ $(unrelated_profile_snapshot) == "$unrelated_profiles_before" ]] || fail "custom DoT preserves unrelated profile settings"

profiles_before_failure=$(profile_snapshot)
drop_in_before_failure=$(<"$drop_in")
FAIL_WRITE=1
export FAIL_WRITE
run_dns Custom "192.0.2.71#dot.example"
unset FAIL_WRITE
assert_failure "rolls back a failed configuration write"
[[ $(<"$resolved_conf") == "$main_before" ]] || fail "write rollback restores resolved.conf"
[[ $(<"$drop_in") == "$drop_in_before_failure" ]] || fail "write rollback restores the owned drop-in"
[[ $(profile_snapshot) == "$profiles_before_failure" ]] || fail "write rollback restores connection profiles"
shopt -s nullglob
temporary_files=("$config_root"/etc/systemd/resolved.conf.d/.omarchy-dns.*)
shopt -u nullglob
((${#temporary_files[@]} == 0)) || fail "write rollback removes temporary files"

SYSTEMCTL_FAIL_RELOAD=1
export SYSTEMCTL_FAIL_RELOAD
run_dns Custom "192.0.2.72#dot.example"
unset SYSTEMCTL_FAIL_RELOAD
assert_failure "rolls back a failed configuration reload"
[[ $(<"$resolved_conf") == "$main_before" ]] || fail "reload rollback restores resolved.conf"
[[ $(<"$drop_in") == "$drop_in_before_failure" ]] || fail "reload rollback restores the owned drop-in"
[[ $(profile_snapshot) == "$profiles_before_failure" ]] || fail "reload rollback restores connection profiles"

exec 8>"$lock_file"
flock -n 8
lock_before=$(<"$drop_in")
run_dns Custom "192.0.2.73#dot.example"
assert_failure "refuses a concurrent DNS configuration transaction"
[[ $(<"$drop_in") == "$lock_before" ]] || fail "concurrent transaction leaves the owned drop-in unchanged"
flock -u 8
exec 8>&-

run_dns DHCP
assert_success "restores DHCP configuration"
dhcp_drop_in=$(<"$drop_in")
dhcp_profiles=$(profile_snapshot)
run_dns Custom "192.0.2.74#dot.example"
assert_success "switches from DHCP to custom DoT"
run_dns Cloudflare
assert_success "switches from custom DoT to a stock provider"
cloudflare_drop_in=$(<"$drop_in")
cloudflare_nm_conf=$(<"$nm_conf")
cloudflare_profiles=$(profile_snapshot)
run_dns Google
assert_success "switches from Cloudflare to Google"
run_dns Cloudflare
assert_success "restores Cloudflare after another provider"
[[ $(<"$drop_in") == "$cloudflare_drop_in" ]] || fail "provider switching restores the exact Cloudflare drop-in"
[[ $(<"$nm_conf") == "$cloudflare_nm_conf" ]] || fail "provider switching restores the exact Cloudflare NetworkManager file"
[[ $(profile_snapshot) == "$cloudflare_profiles" ]] || fail "provider switching restores the exact Cloudflare profiles"
run_dns DHCP
assert_success "switches back to DHCP"
[[ $(<"$drop_in") == "$dhcp_drop_in" ]] || fail "provider switches restore the exact DHCP drop-in"
[[ $(<"$resolved_conf") == "$main_before" ]] || fail "provider switches preserve resolved.conf"
[[ $(profile_snapshot) == "$dhcp_profiles" ]] || fail "provider switches restore the exact connection profiles"
[[ $(unrelated_profile_snapshot) == "$unrelated_profiles_before" ]] || fail "provider switches preserve unrelated profile settings"
[[ ! -e $nm_conf ]] || fail "DHCP removes the Omarchy NetworkManager DNS file"
NMCLI_NO_PROFILES=1
export NMCLI_NO_PROFILES
run_dns DHCP
unset NMCLI_NO_PROFILES
assert_success "configures DHCP without NetworkManager profiles"
[[ $(<"$drop_in") == "$dhcp_drop_in" ]] || fail "profile-free DHCP preserves the exact drop-in"
[[ $(profile_snapshot) == "$dhcp_profiles" ]] || fail "profile-free DHCP preserves existing profile state"

pass "DNS configuration lifecycle is transactional"
