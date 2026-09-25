#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1790165000.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
conf="$test_tmp/etc/modprobe.d/brcmfmac.conf"
mkdir -p "$stub_bin" "$(dirname "$conf")"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
fi
if [[ -n ${WIFI_ID:-} ]]; then
  echo "03:00.0 Network controller [0280]: Broadcom Inc. Wireless [14e4:$WIFI_ID]"
fi
for _ in {1..4096}; do
  echo '02:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash

printf 'omarchy-state' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

run_cleanup() {
  local wifi_id="${1:-}" t2="${2:-0}"
  : >"$calls"

  WIFI_ID="$wifi_id" T2_HARDWARE="$t2" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_BRCMFMAC_CONF="$conf" \
    bash -euo pipefail "$migration" >/dev/null
}

legacy_block='# Fix for T2 MacBook WiFi connectivity issues
options brcmfmac feature_disable=0x82000'

current_block="# Broadcom's firmware supplicant and authenticator fail the WPA four-way
# handshake on Apple hardware, which surfaces as a rejected password. Disable
# both so wpa_supplicant performs the handshake instead.
options brcmfmac feature_disable=0x82000"

# Cleanup on a T2 Mac removes legacy block
printf '%s\n' "$legacy_block" >"$conf"
run_cleanup "4464" 1
[[ ! -e $conf ]] || fail "the cleanup removes the legacy T2-owned quirk on T2 Mac"
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the legacy cleanup requests the reboot that applies it" "$(cat "$calls")"
state_line=$(grep -Fn $'omarchy-state\tset\treboot-required' "$calls" | cut -d: -f1 | head -1)
edit_line=$(grep -En $'^sudo\t(rm|tee)' "$calls" | cut -d: -f1 | head -1)
(( state_line < edit_line )) ||
  fail "the reboot request lands before the config edit" "$(cat "$calls")"
pass "the cleanup removes the legacy T2-owned quirk on T2 Mac"

# Cleanup on a BCM4364 Mac (non-T2) removes current block
printf '%s\n' "$current_block" >"$conf"
run_cleanup "4464" 0
[[ ! -e $conf ]] || fail "the cleanup removes the current Omarchy quirk on BCM4364 Mac"
pass "the cleanup removes the current Omarchy quirk on BCM4364 Mac"

# Cleanup on an Apple Silicon Mac removes quirk
printf '%s\n' "$current_block" >"$conf"
run_cleanup "4433" 0
[[ ! -e $conf ]] || fail "the cleanup removes the quirk on Apple Silicon" "$(cat "$conf")"
pass "the cleanup removes the quirk on Apple Silicon"

# T2 Macs are excluded as a group, so the cleanup must also reach the T2-only
# parts that never carried BCM4364. 43dc is BCM4355 and 4488 is BCM4377; the
# kernel commits that added them list T2 boards only, so the T2 ID is what
# carries them here.
for wifi_id in 43dc 4488; do
  printf '%s\n' "$current_block" >"$conf"
  run_cleanup "$wifi_id" 1
  [[ ! -e $conf ]] || fail "the cleanup removes the quirk on a T2 Mac with 14e4:$wifi_id" "$(cat "$conf")"
done
pass "the cleanup reaches the T2-only Broadcom parts"

# Cleanup preserves unrelated brcmfmac options
printf 'options brcmfmac roamoff=1\n\n%s\n' "$current_block" >"$conf"
run_cleanup "4464" 1
grep -qx 'options brcmfmac roamoff=1' "$conf" ||
  fail "the cleanup preserves unrelated brcmfmac options" "$(cat "$conf")"
! grep -q 'feature_disable=0x82000' "$conf" ||
  fail "the cleanup removes only its owned block" "$(cat "$conf")"
pass "the cleanup preserves unrelated brcmfmac options"

# A user line after the Omarchy block is the common shape on a T2 Mac, where
# the installer appended the block at install time and any customization came
# later. Matching only whole-file or trailing blocks silently skipped these, so
# the quirk survived while the migration reported itself done.
printf '%s\n\noptions brcmfmac roamoff=1\n' "$current_block" >"$conf"
run_cleanup "4464" 1
! grep -q 'feature_disable=0x82000' "$conf" ||
  fail "the cleanup removes the Omarchy block ahead of a user line" "$(cat "$conf")"
grep -qx 'options brcmfmac roamoff=1' "$conf" ||
  fail "the cleanup keeps the user line after the block" "$(cat "$conf")"
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the mid-file removal requests the reboot" "$(cat "$calls")"
pass "the cleanup removes an Omarchy block that has a user line after it"

# The same shape with the legacy block, including a user line on both sides.
printf 'options brcmfmac roamoff=1\n\n%s\n\n# tail note\n' "$legacy_block" >"$conf"
run_cleanup "4464" 1
! grep -q 'feature_disable=0x82000' "$conf" ||
  fail "the cleanup removes the legacy block between user lines" "$(cat "$conf")"
grep -qx 'options brcmfmac roamoff=1' "$conf" ||
  fail "the cleanup keeps the line before the legacy block" "$(cat "$conf")"
grep -qx '# tail note' "$conf" ||
  fail "the cleanup keeps the line after the legacy block" "$(cat "$conf")"
pass "the cleanup removes a legacy block surrounded by user lines"

# A reworded comment is not the owned block, so it is left alone and the reboot
# marker is not set.
printf '# My own note about the handshake\noptions brcmfmac feature_disable=0x82000\n' >"$conf"
run_cleanup "4464" 1
grep -qx 'options brcmfmac feature_disable=0x82000' "$conf" ||
  fail "the cleanup leaves a reworded block alone" "$(cat "$conf")"
! grep -Eq $'^(sudo\t(rm|tee)|omarchy-state\t)' "$calls" ||
  fail "a reworded block triggers no privileged write" "$(cat "$calls")"
pass "the cleanup leaves a reworded block alone"

# Cleanup handles symlinked config
rm -rf "$test_tmp/etc"
mkdir -p "$(dirname "$conf")" "$test_tmp/real"
printf '%s\n' "$legacy_block" >"$test_tmp/real/brcmfmac.conf"
ln -s "$test_tmp/real/brcmfmac.conf" "$conf"
run_cleanup "4464" 1
[[ -L $conf ]] || fail "the cleanup preserves a symlinked config"
[[ ! -s $test_tmp/real/brcmfmac.conf ]] ||
  fail "the cleanup empties a symlink through its target" "$(cat "$test_tmp/real/brcmfmac.conf")"
pass "the cleanup writes through a symlinked config"

rm -f "$conf"

# Cleanup leaves administrator-customized options alone
printf '# Local override\noptions brcmfmac feature_disable=0x82000 roamoff=1\n' >"$conf"
run_cleanup "4464" 1
grep -qx 'options brcmfmac feature_disable=0x82000 roamoff=1' "$conf" ||
  fail "the cleanup leaves an administrator-customized option alone" "$(cat "$conf")"
! grep -Eq $'^(sudo\t(rm|tee)|omarchy-state\t)' "$calls" ||
  fail "the customized config triggers no privileged write" "$(cat "$calls")"
pass "the cleanup leaves administrator-customized options alone"

# Cleanup leaves legacy pre-T2 Mac alone
printf '%s\n' "$current_block" >"$conf"
run_cleanup "43ba" 0
grep -qx 'options brcmfmac feature_disable=0x82000' "$conf" ||
  fail "the cleanup leaves legacy pre-T2 models alone" "$(cat "$conf")"
[[ ! -s $calls ]] || fail "a legacy model triggers no privileged write" "$(cat "$calls")"
pass "the cleanup leaves legacy pre-T2 models alone"

# Cleanup is idempotent
run_cleanup "4464" 1
run_cleanup "4464" 1
[[ ! -e $conf ]] || fail "the cleanup remains idempotent"
pass "the cleanup remains idempotent"
