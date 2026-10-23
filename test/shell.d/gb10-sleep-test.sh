#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/gb10/sleep.sh"
all="$ROOT/install/hardware/all.sh"
menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
migration=$(grep -l "hardware/gb10/sleep.sh" "$ROOT"/migrations/*.sh | head -1 || true)

# The setting follows the real GB10 predicate on fixture machines, and root
# reads only the live hardware.
require_platform_fixtures "the GB10 sleep setting"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

bash -n "$setup" || fail "GB10 sleep script has valid syntax"

grep -q 'run_logged .*hardware/gb10/sleep.sh' "$all" ||
  fail "the GB10 sleep setting runs during hardware setup"
[[ -n $migration ]] || fail "a migration applies the GB10 sleep setting to existing installs"
pass "the GB10 sleep setting runs at install and through a migration"

# An aarch64 machine, with an NVIDIA GPU of the given PCI device ID or none.
machine() {
  local dir="$scratch/hw/$1"
  mkdir -p "$dir/proc" "$dir/sys/bus/pci/devices" "$dir/bin"
  if [[ -n ${2:-} ]]; then
    mkdir -p "$dir/sys/bus/pci/devices/000f:01:00.0"
    printf '0x10de\n' >"$dir/sys/bus/pci/devices/000f:01:00.0/vendor"
    printf '%s\n' "$2" >"$dir/sys/bus/pci/devices/000f:01:00.0/device"
  fi
  printf '#!/bin/bash\n[[ ${1:-} == -m ]] && { echo aarch64; exit 0; }\nexec /usr/bin/uname "$@"\n' >"$dir/bin/uname"
  chmod +x "$dir/bin/uname"
}
machine spark 0x2e12
machine n1x 0x2e06
machine other

cat >"$scratch/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
[[ ${TEST_SUDO_STATUS:-0} == 0 ]] || exit "$TEST_SUDO_STATUS"
exec "$@"
SH
cat >"$scratch/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify %s\n' "$*" >>"$CALL_LOG"
SH
cat >"$scratch/bin/omarchy-toggle" <<'SH'
#!/bin/bash
printf 'toggle %s\n' "$*" >>"$CALL_LOG"
SH
for command in gum btrfs swapon limine-mkinitcpio; do
  printf '#!/bin/bash\nprintf "%s %%s\\n" "$*" >>"$CALL_LOG"\n' "$command" >"$scratch/bin/$command"
done
chmod +x "$scratch/bin"/*

export CALL_LOG="$scratch/calls.log"
run() {
  local machine=$1 config_dir=$2
  shift 2
  : >"$CALL_LOG"
  PATH="$scratch/hw/$machine/bin:$scratch/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    OMARCHY_PROC_ROOT="$scratch/hw/$machine/proc" OMARCHY_SYS_ROOT="$scratch/hw/$machine/sys" \
    OMARCHY_SLEEP_CONFIG_DIR="$config_dir" "$@"
}

run spark "$scratch/spark" bash "$setup"
config="$scratch/spark/omarchy-sleep-disabled.conf"
[[ $(head -n 1 "$config") == "[Sleep]" ]] || fail "GB10 sleep settings are in the [Sleep] section"
for setting in AllowSuspend AllowHibernation AllowSuspendThenHibernate AllowHybridSleep; do
  grep -Fxq "$setting=no" "$config" || fail "a GB10 disallows $setting"
done
before=$(sha256sum "$config")
run spark "$scratch/spark" bash "$setup"
[[ $(sha256sum "$config") == "$before" ]] || fail "rerunning the setting leaves it unchanged"
for machine in n1x other; do
  run "$machine" "$scratch/$machine" bash "$setup"
  [[ ! -e $scratch/$machine ]] || fail "the $machine machine keeps system sleep"
done
pass "the GB10 setting disallows every sleep operation and leaves the N1x and other machines alone"

run spark "$scratch/spark" omarchy-sleep-disabled || fail "sleep reads as disabled with the setting in place"
run spark "$scratch/none" omarchy-sleep-disabled && fail "sleep reads as enabled without the setting"
pass "omarchy-sleep-disabled follows the sleep setting"

run spark "$scratch/migrated" bash "$migration" >/dev/null
[[ -f $scratch/migrated/omarchy-sleep-disabled.conf ]] || fail "the migration applies the setting on a GB10"
run spark "$scratch/migrated" bash "$migration" >/dev/null
! grep -q '^sudo ' "$CALL_LOG" || fail "the migration skips a GB10 that already has the setting"
run other "$scratch/migrated-other" bash "$migration" >/dev/null
! grep -q '^sudo ' "$CALL_LOG" || fail "the migration leaves other machines alone"
TEST_SUDO_STATUS=1 run spark "$scratch/failed" bash "$migration" >/dev/null &&
  fail "a failed migration stays pending"
pass "the migration applies the setting once, only on a GB10"

run spark "$scratch/spark" bash "$ROOT/bin/omarchy-toggle-suspend"
! grep -q '^toggle ' "$CALL_LOG" || fail "the suspend toggle does nothing while sleep is disabled"
grep -q '^notify .*Suspend is turned off on this machine' "$CALL_LOG" ||
  fail "the suspend toggle says suspend is turned off"
# Refuse sudo so a missing check cannot reach this machine's swap or boot files.
hibernation=$(TEST_SUDO_STATUS=1 run spark "$scratch/spark" bash "$ROOT/bin/omarchy-hibernation-setup" 2>&1) ||
  fail "hibernation setup exits cleanly while sleep is disabled"
[[ $hibernation == *"Hibernation is turned off on this machine"* ]] ||
  fail "hibernation setup says hibernation is turned off" "$hibernation"
! grep -qE '^(gum|btrfs|swapon|sudo) ' "$CALL_LOG" ||
  fail "hibernation setup creates no swap while sleep is disabled"
pass "the suspend toggle and hibernation setup respect the disabled setting"

guard() {
  grep -F "\"$1\"" "$menu" | sed -E 's/.*"when":"([^"]*)".*/\1/'
}
cat >"$scratch/bin/omarchy-toggle-enabled" <<'SH'
#!/bin/bash
[[ ${TEST_SUSPEND_OFF:-0} == 1 ]]
SH
cat >"$scratch/bin/omarchy-hibernation-available" <<'SH'
#!/bin/bash
[[ ${TEST_HIBERNATION_OFF:-0} != 1 ]]
SH
chmod +x "$scratch/bin"/*
for item in system.suspend system.hibernate; do
  when=$(guard "$item")
  [[ $when == *"omarchy-sleep-disabled"* && $when != *"omarchy-hw-"* ]] ||
    fail "the $item row follows the sleep setting, not the hardware"
  run spark "$scratch/spark" bash -c "$when" && fail "the $item row is hidden while sleep is disabled"
  run spark "$scratch/none" bash -c "$when" || fail "the $item row returns when the setting is removed"
done
TEST_SUSPEND_OFF=1 run other "$scratch/none" bash -c "$(guard system.suspend)" &&
  fail "the suspend toggle still hides Suspend"
TEST_HIBERNATION_OFF=1 run other "$scratch/none" bash -c "$(guard system.hibernate)" &&
  fail "Hibernate stays hidden until hibernation is set up"
pass "the menu hides Suspend and Hibernate only while sleep is disabled"
