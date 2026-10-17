#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/user/hardware/framework/fix-framework13-ai300-mic.sh"
migration="$ROOT/migrations/1791831134.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

vendor_file="$test_tmp/sys_vendor"
product_file="$test_tmp/product_name"
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
result="$test_tmp/result"
config="$test_tmp/50-framework13-ai300-no-ucm.conf"
ucm_state="$test_tmp/ucm.state"
filler="$test_tmp/wpctl-filler"
migrate_err="$test_tmp/migrate.err"
mkdir -p "$stub_bin"

# Bigger than a pipe buffer, generated once, so the writer only dies if a
# consumer stops reading early.
printf 'filler\n%.0s' {1..20000} >"$filler"

# A restart is modelled as a state file the graph reads: apply turns it "off".
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash

printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

if [[ ${TEST_SYSTEMCTL_STATUS:-0} != 0 ]]; then
  exit "$TEST_SYSTEMCTL_STATUS"
fi

if [[ $* == *"try-restart"* && ${TEST_RESTART_NO_EFFECT:-0} != 1 ]]; then
  printf 'off\n' >"$TEST_UCM_STATE"
fi
SH

# The card's api.alsa.use-ucm property is the live signal, independent of any
# saved profile, so the stub reports it rather than a capture source. The status
# is padded past a pipe buffer: a consumer that stops reading early would kill
# this writer with SIGPIPE, which `pipefail` would surface as a failing migration.
cat >"$stub_bin/wpctl" <<'SH'
#!/bin/bash

if [[ ${1:-} == status ]]; then
  [[ ${TEST_CARD_PRESENT:-1} == 1 ]] &&
    printf '%s\n' ' │      44. Ryzen HD Audio Controller           [alsa]'
  cat "${TEST_FILLER:-/dev/null}"
elif [[ ${1:-} == inspect ]]; then
  if [[ $(cat "$TEST_UCM_STATE" 2>/dev/null) == off ]]; then
    printf '%s\n' '    api.alsa.use-ucm = "false"'
  else
    printf '%s\n' '    api.alsa.use-ucm = "true"'
  fi
fi
SH

chmod +x "$stub_bin"/*

expected_rule='monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "~alsa_card.pci-*"
        device.product.name = "Ryzen HD Audio Controller"
      }
    ]
    actions = {
      update-props = {
        api.alsa.use-ucm = false
      }
    }
  }
]'

run_leaf() {
  local vendor="${1:-Framework}"
  local product="${2:-Laptop 13 (AMD Ryzen AI 300 Series)}"

  printf '%s\n' "$vendor" >"$vendor_file"
  printf '%s\n' "$product" >"$product_file"
  : >"$calls"

  PATH="$stub_bin:$ROOT/bin:$PATH" \
    TEST_LOG="$calls" \
    TEST_RESULT="$result" \
    TEST_FILLER="$filler" \
    OMARCHY_DMI_SYS_VENDOR="$vendor_file" \
    OMARCHY_DMI_PRODUCT_NAME="$product_file" \
    OMARCHY_FRAMEWORK13_AI300_MIC_CONF="$config" \
    bash -euo pipefail -c '
      source "$1"
      printf "%s %s\n" "$omarchy_framework13_ai300_mic_matched" "$omarchy_framework13_ai300_mic_changed" >"$TEST_RESULT"
    ' bash "$leaf"
}

run_leaf 'Not Framework' || fail "the leaf succeeds as a no-op on other systems"
run_leaf 'Framework' 'Laptop 16 (AMD Ryzen AI 300 Series)' ||
  fail "the leaf is a no-op on other Framework models"
run_leaf 'Framework' 'Laptop 13 (AMD Ryzen AI 300 Series) Pro' ||
  fail "the leaf is a no-op on lookalike product names"
[[ ! -e $config ]] || fail "a nonmatching system does not write the WirePlumber rule"
[[ ! -s $calls ]] || fail "a nonmatching system runs no commands" "$(cat "$calls")"
[[ $(<"$result") == "0 0" ]] || fail "a nonmatching system does not match"
pass "the leaf matches only the exact target DMI and fails closed"

env OMARCHY_DMI_SYS_VENDOR="$test_tmp/absent" OMARCHY_DMI_PRODUCT_NAME="$test_tmp/absent" \
  OMARCHY_FRAMEWORK13_AI300_MIC_CONF="$config" TEST_RESULT="$result" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  bash -euo pipefail -c '
    source "$1"
    printf "%s %s\n" "$omarchy_framework13_ai300_mic_matched" "$omarchy_framework13_ai300_mic_changed" >"$TEST_RESULT"
  ' bash "$leaf"
[[ $(<"$result") == "0 0" ]] || fail "missing DMI data is rejected"
pass "missing DMI data is rejected"

run_leaf || fail "the leaf matches the exact target"
[[ $(<"$config") == "$expected_rule" ]] ||
  fail "the WirePlumber rule contains exactly the expected match" "$(<"$config")"
[[ $(stat -c '%a' "$config") == "644" ]] || fail "the WirePlumber rule has mode 0644"
[[ $(<"$result") == "1 1" ]] || fail "matching hardware reports the rule as changed"
pass "matching hardware installs the WirePlumber rule"

run_leaf || fail "an already-applied rule succeeds"
[[ $(<"$result") == "1 0" ]] || fail "an already-applied rule is reported as unchanged"
pass "an already-applied rule is not rewritten"

printf 'monitor.alsa.rules = []\n' >"$config"
run_leaf || fail "a stale rule is reconciled"
[[ $(<"$config") == "$expected_rule" ]] ||
  fail "a stale rule is replaced with the current one" "$(<"$config")"
[[ $(<"$result") == "1 1" ]] || fail "a stale rule is reported as changed"
pass "a stale rule is reconciled to the current one"

# The card lookup reads a `wpctl status` larger than a pipe buffer. A consumer
# that stops reading as soon as it finds the card would kill `wpctl` with
# SIGPIPE, and `pipefail` would turn that into exit 141 after the id was already
# printed -- aborting the migration under `-e` and blocking every later one.
sigpipe_id=$(
  PATH="$stub_bin:$ROOT/bin:$PATH" \
    TEST_CARD_PRESENT=1 \
    TEST_FILLER="$filler" \
    OMARCHY_DMI_SYS_VENDOR="$vendor_file" \
    OMARCHY_DMI_PRODUCT_NAME="$product_file" \
    OMARCHY_FRAMEWORK13_AI300_MIC_CONF="$config" \
    bash -euo pipefail -c '
      source "$1"
      omarchy_framework13_ai300_mic_device_id
    ' bash "$leaf"
) || fail "a large wpctl status does not fail the card lookup with SIGPIPE"
[[ $sigpipe_id == "44" ]] ||
  fail "the card id is parsed from a large wpctl status" "$sigpipe_id"
pass "a large wpctl status still resolves the card without SIGPIPE"

migration_name=$(basename "$migration")
leaf_registration='run_logged "$OMARCHY_INSTALL/user/hardware/framework/fix-framework13-ai300-mic.sh"'
grep -Fxq "$leaf_registration" "$ROOT/install/user/all.sh" ||
  fail "Framework 13 AI 300 microphone fix is registered with user setup"
grep -Fq 'source "$OMARCHY_PATH/install/user/hardware/framework/fix-framework13-ai300-mic.sh"' "$migration" ||
  fail "the migration sources the Framework 13 AI 300 microphone leaf"
[[ $(stat -c '%a' "$migration") == "644" ]] || fail "the migration has mode 0644"
pass "fresh user setup and the migration reuse the microphone fix"

migration_root="$test_tmp/migration-root"
mkdir -p "$migration_root/migrations" "$migration_root/install/user/hardware/framework"
ln -s "$migration" "$migration_root/migrations/$migration_name"
ln -s "$leaf" "$migration_root/install/user/hardware/framework/fix-framework13-ai300-mic.sh"

run_migrator() {
  local state_dir="$1"
  local vendor="${2:-Framework}"
  local product="${3:-Laptop 13 (AMD Ryzen AI 300 Series)}"

  printf '%s\n' "$vendor" >"$vendor_file"
  printf '%s\n' "$product" >"$product_file"
  : >"$calls"

  PATH="$stub_bin:$ROOT/bin:$PATH" \
    TEST_LOG="$calls" \
    TEST_SYSTEMCTL_STATUS="${TEST_SYSTEMCTL_STATUS:-0}" \
    TEST_CARD_PRESENT="${TEST_CARD_PRESENT:-1}" \
    TEST_RESTART_NO_EFFECT="${TEST_RESTART_NO_EFFECT:-0}" \
    TEST_UCM_STATE="$ucm_state" \
    TEST_FILLER="$filler" \
    OMARCHY_FRAMEWORK13_AI300_MIC_RESTART_TRIES=8 \
    OMARCHY_FRAMEWORK13_AI300_MIC_RESTART_INTERVAL=0.05 \
    OMARCHY_PATH="$migration_root" \
    OMARCHY_MIGRATION_STATE="$state_dir" \
    OMARCHY_DMI_SYS_VENDOR="$vendor_file" \
    OMARCHY_DMI_PRODUCT_NAME="$product_file" \
    OMARCHY_FRAMEWORK13_AI300_MIC_CONF="$config" \
    "$ROOT/bin/omarchy-migrate" >/dev/null 2>"$migrate_err"
}

rm -f "$config"
printf 'on\n' >"$ucm_state"
apply_state="$test_tmp/apply-state"
run_migrator "$apply_state" || fail "the migration applies the fix"
[[ -f $apply_state/$migration_name ]] || fail "an applied migration is marked complete"
[[ $(<"$config") == "$expected_rule" ]] || fail "the migration writes the WirePlumber rule"
grep -Fxq $'systemctl\t--user\ttry-restart\twireplumber' "$calls" ||
  fail "the migration restarts WirePlumber to apply the new rule" "$(cat "$calls")"
[[ $(<"$ucm_state") == "off" ]] || fail "the restart turns UCM off"
pass "the migration installs the rule and restarts WirePlumber"

# The rule is live even when the user saved an output-only or disabled profile,
# so this check reads the card's api.alsa.use-ucm property and never needs an
# active capture source that a saved profile might not create.
printf 'off\n' >"$ucm_state"
already_state="$test_tmp/already-state"
run_migrator "$already_state" || fail "an already-applied rule completes the migration"
[[ -f $already_state/$migration_name ]] || fail "the already-applied migration is marked complete"
if grep -Fq $'systemctl\t--user\ttry-restart\twireplumber' "$calls"; then
  fail "an already-applied rule does not restart WirePlumber" "$(cat "$calls")"
fi
if grep -Fq 'but WirePlumber has not applied it' "$migrate_err"; then
  fail "an already-applied rule does not warn" "$(<"$migrate_err")"
fi
pass "an already-applied rule does not disturb audio"

rm -f "$config"
printf 'on\n' >"$ucm_state"
TEST_SYSTEMCTL_STATUS=1
failed_state="$test_tmp/failed-state"
run_migrator "$failed_state" ||
  fail "a failed WirePlumber restart must not fail the migration"
TEST_SYSTEMCTL_STATUS=0
[[ -f $failed_state/$migration_name ]] ||
  fail "a failed restart still leaves the migration complete"
[[ $(<"$config") == "$expected_rule" ]] || fail "the rule is written even when the restart fails"
grep -Fq 'but WirePlumber has not applied it' "$migrate_err" ||
  fail "a failed restart warns instead of blocking later migrations" "$(<"$migrate_err")"
pass "a failed restart warns and completes instead of blocking later migrations"

rm -f "$config"
printf 'on\n' >"$ucm_state"
TEST_RESTART_NO_EFFECT=1
noeffect_state="$test_tmp/noeffect-state"
run_migrator "$noeffect_state" ||
  fail "a restart that does not take must not fail the migration"
TEST_RESTART_NO_EFFECT=0
[[ -f $noeffect_state/$migration_name ]] ||
  fail "an ineffective restart still completes the migration"
[[ $(<"$ucm_state") == "on" ]] || fail "the ineffective restart leaves UCM on in the stub"
grep -Fq 'but WirePlumber has not applied it' "$migrate_err" ||
  fail "an ineffective restart warns instead of blocking later migrations" "$(<"$migrate_err")"
pass "a restart that does not apply the rule warns and completes"

rm -f "$config"
printf 'on\n' >"$ucm_state"
TEST_CARD_PRESENT=0
nosession_state="$test_tmp/nosession-state"
run_migrator "$nosession_state" || fail "a machine with no audio session completes the migration"
[[ -f $nosession_state/$migration_name ]] || fail "the no-session migration is marked complete"
if grep -Fq $'systemctl\t--user\ttry-restart\twireplumber' "$calls"; then
  fail "a machine with no audio session does not restart WirePlumber" "$(cat "$calls")"
fi
TEST_CARD_PRESENT=1
pass "a machine with no audio session completes without restarting"

rm -f "$config"
printf 'on\n' >"$ucm_state"
nonmatching_state="$test_tmp/nonmatching-migration-state"
run_migrator "$nonmatching_state" 'Not Framework' ||
  fail "nonmatching machines complete the migration"
[[ -f $nonmatching_state/$migration_name ]] || fail "the nonmatching migration is marked complete"
[[ ! -e $config ]] || fail "nonmatching machines do not write the rule"
[[ ! -s $calls ]] || fail "nonmatching machines do not restart WirePlumber" "$(cat "$calls")"
pass "nonmatching machines remain no-ops"
