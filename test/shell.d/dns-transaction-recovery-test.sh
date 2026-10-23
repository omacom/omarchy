#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

dns="$ROOT/bin/omarchy-dns"
test_tmp=$(mktemp -d)
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
export CALL_LOG="$test_tmp/calls.log"

cleanup() {
  chmod -R u+w "$test_tmp" 2>/dev/null || true
  rm -rf "$test_tmp"
}
trap cleanup EXIT

cat >"$stub_bin/nmcli" <<'STUB'
#!/bin/bash
set -u
printf '%s\n' "$*" >>"${CALL_LOG:?}"
if [[ ${1-} == -t && ${2-} == -f && ${3-} == UUID,TYPE ]]; then
  [[ ${NMCLI_ENUMERATION_FAIL:-0} != 1 ]] || exit 1
  count_file="$TEST_ROOT/nmcli-enumeration-count"
  count=0
  [[ ! -f $count_file ]] || count=$(<"$count_file")
  count=$((count + 1))
  printf '%s\n' "$count" >"$count_file"
  printf '%s\n' 'wired-uuid:802-3-ethernet' 'wifi-uuid:802-11-wireless' 'vpn-uuid:vpn'
  [[ ${NMCLI_LATE_PROFILE:-0} != 1 ]] || printf '%s\n' 'late-uuid:802-3-ethernet'
  if [[ ${NMCLI_CHANGE_PROFILE_LIST:-0} == 1 && $count -gt 1 ]]; then
    printf '%s\n' 'extra-uuid:802-3-ethernet'
  fi
  exit 0
fi
# Like nmcli, escape ':' and '\' in -g output unless --escape no is given.
escape=yes
if [[ ${1-} == --escape && ${2-} == no ]]; then
  escape=no
  shift 2
fi
nmcli_escape() {
  if [[ $escape == yes ]]; then
    sed -e 's/\\/\\\\/g' -e 's/:/\\:/g'
  else
    cat
  fi
}
if [[ ${1-} == -g ]]; then
  property=${2-}
  uuid=${@: -1}
  [[ ${NMCLI_READ_FAIL_PROPERTY:-} != "$property" ]] || exit 1
  file="${NMCLI_STATE}/profile-${uuid}.${property//./-}"
  if [[ ${NMCLI_MULTILINE_PROPERTY:-0} == 1 && $property == ipv4.dns ]]; then
    printf '%s\n' '192.0.2.10' 'unexpected-record'
  elif [[ -f $file ]]; then
    nmcli_escape <"$file"
  fi
  exit 0
fi
if [[ ${1-} == connection && ${2-} == modify ]]; then
  uuid=$3
  [[ ${NMCLI_MODIFY_FAIL_UUID:-} != "$uuid" ]] || exit 1
  shift 3
  while (($# >= 2)); do
    property=$1
    value=${2-}
    printf '%s\n' "$value" >"${NMCLI_STATE}/profile-${uuid}.${property//./-}"
    shift 2
  done
  exit 0
fi
if [[ ${1-} == -t && ${2-} == -f && ${3-} == DEVICE,TYPE,STATE ]]; then
  printf '%s\n' 'eth0:ethernet:connected'
  exit 0
fi
if [[ ${1-} == device && ${2-} == status ]]; then
  printf '%s\n' 'eth0:ethernet:connected'
  exit 0
fi
if [[ ${1-} == device && ${2-} == reapply ]]; then
  printf '%s\n' "$3" >>"${REAPPLY_LOG:?}"
  [[ ${NMCLI_REAPPLY_FAIL:-0} != 1 ]] || exit 1
  exit 0
fi
if [[ ${1-} == general && ${2-} == reload ]]; then
  [[ ${NMCLI_RELOAD_FAIL:-0} != 1 ]] || exit 1
  exit 0
fi
exit 0
STUB
chmod +x "$stub_bin/nmcli"

cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${CALL_LOG:?}"
if [[ ${1-} == is-active && ${2-} == --quiet && ${3-} == NetworkManager.service ]]; then
  [[ ${NM_ACTIVE:-0} == 1 ]] && exit 0
  exit 1
fi
if [[ ${1-} == reload && ${2-} == NetworkManager.service ]]; then
  [[ ${NM_RELOAD_FAIL:-0} != 1 ]] || exit 1
  exit 0
fi
if [[ ${1-} == reload && ${2-} == systemd-resolved.service ]]; then
  if [[ ${SYSTEMCTL_KILL_RUN:-0} == 1 ]]; then
    # Simulate SIGKILL of the whole omarchy-dns run mid-transaction.
    victims=()
    pid=$PPID
    while ((pid > 1)) && grep -qa 'omarchy-dns' "/proc/$pid/cmdline" 2>/dev/null; do
      victims+=("$pid")
      pid=$(awk '{print $4}' "/proc/$pid/stat")
    done
    kill -KILL "${victims[@]}"
    exit 1
  fi
  if [[ ${SYSTEMCTL_FAIL_RESOLVED_ONCE:-0} == 1 ]]; then
    count_file="$TEST_ROOT/resolved-failure-count"
    count=0
    [[ ! -f $count_file ]] || count=$(<"$count_file")
    count=$((count + 1))
    printf '%s\n' "$count" >"$count_file"
    ((count < 3)) && exit 1
  fi
  [[ ${SYSTEMCTL_FAIL_RESOLVED:-0} != 1 ]] || exit 1
  exit 0
fi
if [[ ${1-} == restart && ${2-} == systemd-resolved.service ]]; then
  if [[ ${SYSTEMCTL_FAIL_RESOLVED_ONCE:-0} == 1 ]]; then
    count_file="$TEST_ROOT/resolved-failure-count"
    count=0
    [[ ! -f $count_file ]] || count=$(<"$count_file")
    count=$((count + 1))
    printf '%s\n' "$count" >"$count_file"
    ((count < 3)) && exit 1
  fi
  [[ ${SYSTEMCTL_FAIL_RESOLVED:-0} != 1 ]] || exit 1
  exit 0
fi
exit 0
STUB
chmod +x "$stub_bin/systemctl"

cat >"$stub_bin/install" <<'STUB'
#!/bin/bash
set -u
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
for argument in "$@"; do
  [[ $argument == /* ]] || continue
  [[ $argument == "${TEST_ROOT:?}"/* ]] || exit 98
done
exec "/usr/bin/install" "$@"
STUB
chmod +x "$stub_bin/install"

for command in cp mv rm; do
  cat >"$stub_bin/$command" <<'STUB'
#!/bin/bash
set -u
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
for argument in "$@"; do
  [[ $argument == /* ]] || continue
  [[ $argument == "${TEST_ROOT:?}"/* ]] || exit 98
done
if [[ ${0##*/} == mv && ${FAIL_ROLLBACK_STAGE:-0} == 1 ]]; then
  for argument in "$@"; do
    [[ $argument == *omarchy-dns-restore* ]] && exit 97
  done
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
set -u
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
for argument in "$@"; do
  [[ $argument == /* ]] || continue
  [[ $argument == "${TEST_ROOT:?}"/* ]] || exit 98
done
if [[ ${0##*/} == mktemp && ${1-} == -d ]]; then
  directory=$(/usr/bin/mktemp "$@") || exit $?
  if [[ ${FAIL_PROFILE_SNAPSHOT:-0} == 1 ]]; then
    ln -s /dev/full "$directory/profile-0"
  fi
  printf '%s\n' "$directory"
  exit 0
fi
if [[ ${0##*/} == flock ]]; then
  stat -c '%a' "$LOCK_FILE" >>"${LOCK_MODE_LOG:?}"
fi
exec "/usr/bin/${0##*/}" "$@"
STUB
  chmod +x "$stub_bin/$command"
done

cat >"$stub_bin/getent" <<'STUB'
#!/bin/bash
exit 2
STUB
chmod +x "$stub_bin/getent"

for command in sudo pkexec tee; do
  cat >"$stub_bin/$command" <<'STUB'
#!/bin/bash
printf '%s\n' "$0 $*" >>"${CALL_LOG:?}"
exit 97
STUB
  chmod +x "$stub_bin/$command"
done

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

  for uuid in "${PROFILE_IDS[@]}"; do
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

init_case() {
  local name="$1" uuid property

  config_root="$test_tmp/$name/root"
  nmcli_state="$test_tmp/$name/nmcli"
  resolved_conf="$config_root/etc/systemd/resolved.conf"
  drop_in="$config_root/etc/systemd/resolved.conf.d/90-omarchy-dns.conf"
  legacy_drop_in="$config_root/etc/systemd/resolved.conf.d/90-dot.conf"
  nm_conf="$config_root/etc/NetworkManager/conf.d/20-omarchy-dns.conf"
  lock_file="$config_root/var/lock/omarchy-dns.lock"
  mkdir -p "$config_root/etc/systemd/resolved.conf.d" "$config_root/etc/NetworkManager/conf.d" "$config_root/var/lock" "$nmcli_state"
  export TEST_ROOT="$config_root" NMCLI_STATE="$nmcli_state" LOCK_FILE="$lock_file"
  export REAPPLY_LOG="$test_tmp/$name/reapply.log" LOCK_MODE_LOG="$test_tmp/$name/lock-mode.log"
  : >"$CALL_LOG"
  : >"$REAPPLY_LOG"
  : >"$LOCK_MODE_LOG"
  printf '%s\n' '[Resolve]' 'DNS=192.0.2.99' >"$resolved_conf"
  PROFILE_IDS=(wired-uuid wifi-uuid extra-uuid)
  for uuid in "${PROFILE_IDS[@]}"; do
    for property in ipv4.ignore-auto-dns ipv4.dns ipv6.ignore-auto-dns ipv6.dns; do
      set_profile "$uuid" "$property" "initial-$uuid-$property"
    done
  done
}

run_dns() {
  local provider="$1" input="${2-}"

  if (($# >= 2)); then
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

init_case runtime
NM_ACTIVE=1
SYSTEMCTL_FAIL_RESOLVED_ONCE=1
export NM_ACTIVE SYSTEMCTL_FAIL_RESOLVED_ONCE
before=$(profile_snapshot)
run_dns Custom "192.0.2.70#dot.example"
unset NM_ACTIVE SYSTEMCTL_FAIL_RESOLVED_ONCE
assert_failure "fails when resolved reload fails after NetworkManager applies"
[[ ! -e $nm_conf && ! -e $drop_in ]] || fail "reload rollback restores the NetworkManager file" "$(<"$nm_conf" 2>/dev/null || true)"
[[ $(<"$resolved_conf") == $'[Resolve]\nDNS=192.0.2.99' ]] || fail "reload rollback restores resolved.conf" "$(<"$resolved_conf")"
[[ $(profile_snapshot) == "$before" ]] || fail "reload rollback restores profile runtime settings" "$(profile_snapshot)"
reapply_count=$(wc -l <"$REAPPLY_LOG")
((reapply_count >= 2)) || fail "reload rollback reapplies the restored NetworkManager state" "$reapply_count reapply calls"

init_case profile-set
NMCLI_CHANGE_PROFILE_LIST=1
export NMCLI_CHANGE_PROFILE_LIST
run_dns Cloudflare
unset NMCLI_CHANGE_PROFILE_LIST
assert_success "applies DNS to the live profile set"
[[ $(<"$(profile_file extra-uuid ipv4.ignore-auto-dns)") == yes ]] || fail "a profile created after the snapshot keeps forced DNS" "$(<"$(profile_file extra-uuid ipv4.ignore-auto-dns)")"
[[ $(<"$(profile_file extra-uuid ipv4.dns)") == "1.1.1.1 1.0.0.1" ]] || fail "a profile created after the snapshot does not get the provider servers" "$(<"$(profile_file extra-uuid ipv4.dns)")"
grep -Fq 'modify extra-uuid' "$CALL_LOG" || fail "profile application re-enumerates before modifying" "$(<"$CALL_LOG")"
! grep -Fq 'modify vpn-uuid' "$CALL_LOG" || fail "profile application leaves non-DNS connection types alone" "$(<"$CALL_LOG")"

init_case profile-set-reset
NMCLI_CHANGE_PROFILE_LIST=1
export NMCLI_CHANGE_PROFILE_LIST
run_dns Cloudflare
assert_success "applies DNS to the live profile set"
run_dns DHCP
unset NMCLI_CHANGE_PROFILE_LIST
assert_success "resets to DHCP DNS"
[[ $(<"$(profile_file extra-uuid ipv4.ignore-auto-dns)") == no ]] || fail "a profile created after the snapshot keeps suppressed DHCP DNS" "$(<"$(profile_file extra-uuid ipv4.ignore-auto-dns)")"
[[ $(<"$(profile_file extra-uuid ipv4.dns)") == "" ]] || fail "a profile created after the snapshot keeps forced provider DNS" "$(<"$(profile_file extra-uuid ipv4.dns)")"
[[ $(<"$(profile_file wired-uuid ipv4.ignore-auto-dns)") == no ]] || fail "a reset leaves a snapshotted profile suppressed" "$(<"$(profile_file wired-uuid ipv4.ignore-auto-dns)")"

init_case profile-set-rollback
NMCLI_CHANGE_PROFILE_LIST=1
NM_ACTIVE=1
SYSTEMCTL_FAIL_RESOLVED_ONCE=1
export NMCLI_CHANGE_PROFILE_LIST NM_ACTIVE SYSTEMCTL_FAIL_RESOLVED_ONCE
run_dns Cloudflare
unset NMCLI_CHANGE_PROFILE_LIST NM_ACTIVE SYSTEMCTL_FAIL_RESOLVED_ONCE
assert_failure "fails when a profile set is rolled back"
[[ $(<"$(profile_file extra-uuid ipv4.ignore-auto-dns)") == initial-extra-uuid-ipv4.ignore-auto-dns ]] || fail "a rolled-back run does not restore a late profile's own settings" "$(<"$(profile_file extra-uuid ipv4.ignore-auto-dns)")"
[[ $(<"$(profile_file extra-uuid ipv4.dns)") == initial-extra-uuid-ipv4.dns ]] || fail "a rolled-back run leaves a late profile with provider DNS" "$(<"$(profile_file extra-uuid ipv4.dns)")"
[[ $(<"$(profile_file wired-uuid ipv4.ignore-auto-dns)") == initial-wired-uuid-ipv4.ignore-auto-dns ]] || fail "a rolled-back run does not restore snapshotted profiles" "$(<"$(profile_file wired-uuid ipv4.ignore-auto-dns)")"

init_case ipv6-rollback
set_profile wired-uuid ipv6.dns "2001:db8::53 2001:db8::54"
NM_ACTIVE=1
SYSTEMCTL_FAIL_RESOLVED_ONCE=1
export NM_ACTIVE SYSTEMCTL_FAIL_RESOLVED_ONCE
run_dns Cloudflare
unset NM_ACTIVE SYSTEMCTL_FAIL_RESOLVED_ONCE
assert_failure "fails when resolved reload fails"
[[ $(<"$(profile_file wired-uuid ipv6.dns)") == "2001:db8::53 2001:db8::54" ]] || fail "rollback restores IPv6 servers without nmcli escapes" "$(<"$(profile_file wired-uuid ipv6.dns)")"

init_case untouched-profile-after-kill
NM_ACTIVE=1
SYSTEMCTL_KILL_RUN=1
export NM_ACTIVE SYSTEMCTL_KILL_RUN
run_dns Cloudflare
unset SYSTEMCTL_KILL_RUN
assert_failure "the simulated SIGKILL stops the run"
# A connection created with manual DNS after the killed run is not the killed
# run's to undo.
set_profile late-uuid ipv4.ignore-auto-dns yes
set_profile late-uuid ipv4.dns 192.0.2.200
NMCLI_LATE_PROFILE=1
export NMCLI_LATE_PROFILE
: >"$CALL_LOG"
run_dns Cloudflare
unset NM_ACTIVE NMCLI_LATE_PROFILE
assert_success "the next run recovers and applies"
[[ $OUTPUT == *'interrupted run'* ]] || fail "recovers from the interrupted run" "$OUTPUT"
! grep -Fq 'modify late-uuid ipv4.ignore-auto-dns no' "$CALL_LOG" || fail "recovery clears DNS on a connection the killed run never touched" "$(<"$CALL_LOG")"

init_case enumeration-failure
NMCLI_ENUMERATION_FAIL=1
export NMCLI_ENUMERATION_FAIL
run_dns Cloudflare
unset NMCLI_ENUMERATION_FAIL
assert_failure "propagates profile enumeration failure"
[[ ! -e $nm_conf && ! -e $drop_in ]] || fail "profile enumeration failure prevents configuration writes"

init_case profile-write-failure
FAIL_PROFILE_SNAPSHOT=1
export FAIL_PROFILE_SNAPSHOT
run_dns Cloudflare
unset FAIL_PROFILE_SNAPSHOT
assert_failure "propagates a profile snapshot write error"
[[ ! -e $nm_conf && ! -e $drop_in ]] || fail "profile snapshot write error prevents configuration writes"

init_case profile-record
NMCLI_MULTILINE_PROPERTY=1
export NMCLI_MULTILINE_PROPERTY
run_dns Cloudflare
unset NMCLI_MULTILINE_PROPERTY
assert_failure "rejects an incomplete profile snapshot record"
[[ ! -e $nm_conf && ! -e $drop_in ]] || fail "incomplete profile records prevent configuration writes"

init_case rollback-failure
SYSTEMCTL_FAIL_RESOLVED=1
FAIL_ROLLBACK_STAGE=1
export SYSTEMCTL_FAIL_RESOLVED FAIL_ROLLBACK_STAGE
run_dns Cloudflare
unset SYSTEMCTL_FAIL_RESOLVED FAIL_ROLLBACK_STAGE
assert_failure "reports a failed transaction rollback"
[[ $OUTPUT == *'rollback did not complete'* ]] || fail "reports rollback failure" "$OUTPUT"
shopt -s nullglob
retired=("$config_root"/var/lock/.omarchy-dns-failed.*)
snapshots=("$config_root"/var/lock/.omarchy-dns-snapshot.*)
shopt -u nullglob
((${#retired[@]} > 0)) || fail "retains a recovery snapshot after rollback failure"
((${#snapshots[@]} == 0)) || fail "a failed rollback leaves its snapshot where recovery would retry it"
run_dns DHCP
assert_success "a retained snapshot does not block later DNS changes"
[[ -d ${retired[0]} ]] || fail "later runs keep the retained snapshot for manual recovery"

init_case killed-mid-transaction
NM_ACTIVE=1
SYSTEMCTL_KILL_RUN=1
export NM_ACTIVE SYSTEMCTL_KILL_RUN
before=$(profile_snapshot)
run_dns Cloudflare
unset SYSTEMCTL_KILL_RUN
assert_failure "the simulated SIGKILL stops the run"
[[ -f $nm_conf ]] || fail "the killed run leaves its changes applied" "$OUTPUT"
[[ $(profile_snapshot) != "$before" ]] || fail "the killed run leaves profile changes applied"
shopt -s nullglob
snapshots=("$config_root"/var/lock/.omarchy-dns-snapshot.*)
shopt -u nullglob
((${#snapshots[@]} == 1)) || fail "the killed run leaves its snapshot behind" "${#snapshots[@]} snapshots"
: >"$CALL_LOG"
run_dns DHCP
unset NM_ACTIVE
assert_success "the next run recovers and applies"
[[ $OUTPUT == *'interrupted run'* ]] || fail "reports recovery from an interrupted run" "$OUTPUT"
grep -Fxq 'connection modify wired-uuid ipv4.dns initial-wired-uuid-ipv4.dns' "$CALL_LOG" || fail "recovery restores the snapshotted profile settings" "$(<"$CALL_LOG")"
recovered=$(grep -n 'modify wired-uuid ipv4.dns initial-wired-uuid-ipv4.dns' "$CALL_LOG" | head -1 | cut -d: -f1)
reset=$(grep -n 'modify wired-uuid ipv4.ignore-auto-dns no' "$CALL_LOG" | tail -1 | cut -d: -f1)
((recovered < reset)) || fail "recovery runs before the new transaction" "$(<"$CALL_LOG")"
[[ ! -e $nm_conf ]] || fail "the follow-up DHCP run removes the NetworkManager file" "$(<"$nm_conf")"
[[ ! -e ${snapshots[0]} ]] || fail "recovery removes the recovered snapshot"

init_case incomplete-snapshot
mkdir "$config_root/var/lock/.omarchy-dns-snapshot.partial"
printf '%s\n' 'stale' >"$config_root/var/lock/.omarchy-dns-snapshot.partial/file-0"
run_dns DHCP
assert_success "discards a snapshot cut short before any change"
[[ ! -e $config_root/var/lock/.omarchy-dns-snapshot.partial ]] || fail "removes the incomplete snapshot"
[[ $OUTPUT != *'interrupted run'* ]] || fail "does not restore from an incomplete snapshot" "$OUTPUT"

init_case unsafe-snapshot
mkdir "$test_tmp/unsafe-target"
ln -s "$test_tmp/unsafe-target" "$config_root/var/lock/.omarchy-dns-snapshot.link"
run_dns DHCP
assert_success "configures DNS next to an unsafe snapshot entry"
[[ $OUTPUT == *'unsafe DNS snapshot'* ]] || fail "reports the unsafe snapshot entry" "$OUTPUT"
[[ -L $config_root/var/lock/.omarchy-dns-snapshot.link && -d $test_tmp/unsafe-target ]] || fail "leaves an unsafe snapshot entry untouched"

init_case legacy-managed
printf '%s\n' '# Managed by omarchy-dns. Custom DNS-over-TLS endpoint; remove with `omarchy dns DHCP`.' '[Resolve]' 'DNS=192.0.2.70#dot.example' 'DNSOverTLS=opportunistic' >"$legacy_drop_in"
run_dns Custom "192.0.2.71"
assert_success "migrates the managed legacy resolved drop-in"
[[ ! -e $legacy_drop_in ]] || fail "removes the managed legacy resolved drop-in after migration"
[[ -f $drop_in ]] || fail "writes the new resolved drop-in while migrating"

init_case legacy-unmanaged
printf '%s\n' 'unmanaged legacy configuration' >"$legacy_drop_in"
before=$(<"$legacy_drop_in")
run_dns Custom "192.0.2.72"
assert_success "configures DNS alongside an unmanaged legacy drop-in"
[[ $OUTPUT == *unmanaged* ]] || fail "reports the unmanaged legacy collision" "$OUTPUT"
[[ $(<"$legacy_drop_in") == "$before" ]] || fail "does not overwrite an unmanaged legacy collision"
[[ -f $drop_in ]] || fail "still configures DNS when a foreign legacy drop-in exists"
grep -Fxq 'DNS=192.0.2.72' "$drop_in" || fail "the managed drop-in carries the requested server" "$(<"$drop_in")"

init_case lock-umask
old_umask=$(umask)
umask 022
run_dns DHCP
umask "$old_umask"
assert_success "configures DNS with a permissive caller umask"
! grep -Fq '644' "$LOCK_MODE_LOG" || fail "creates the lock before applying the caller umask" "$(<"$LOCK_MODE_LOG")"
grep -Fxq '600' "$LOCK_MODE_LOG" || fail "creates a mode-0600 lock before flock" "$(<"$LOCK_MODE_LOG")"

pass "DNS transaction recovery and lifecycle edge cases are safe"
