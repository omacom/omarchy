#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/gb10/cpuidle.sh"

# The rule follows the real GB10 predicate on fixture machines, and root
# reads only the live hardware.
require_platform_fixtures "the GB10 CPU idle rule"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

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

run() {
  local machine=$1 rules_dir=$2
  PATH="$scratch/hw/$machine/bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    OMARCHY_PROC_ROOT="$scratch/hw/$machine/proc" OMARCHY_SYS_ROOT="$scratch/hw/$machine/sys" \
    OMARCHY_UDEV_RULES_DIR="$rules_dir" bash "$setup"
}

run spark "$scratch/spark"
rules="$scratch/spark/71-omarchy-gb10-cpuidle.rules"
[[ -f $rules ]] || fail "a GB10 gets the CPU idle rule"
grep -q 'SUBSYSTEM=="cpu"' "$rules" || fail "the rule matches CPU devices"
grep -q 'ACTION=="add|online"' "$rules" || fail "the rule applies at boot and when a core comes back online"
grep -Fq 'cpuidle/state[1-9]*/disable' "$rules" || fail "the rule disables every idle state past state0"
! grep -v '^#' "$rules" | grep -q 'state0' || fail "the rule leaves state0 (WFI) enabled"
before=$(sha256sum "$rules")
run spark "$scratch/spark"
[[ $(sha256sum "$rules") == "$before" ]] || fail "rerunning the setup leaves the rule unchanged"
for machine in n1x other; do
  run "$machine" "$scratch/$machine"
  [[ ! -e $scratch/$machine ]] || fail "the $machine machine keeps its CPU idle states"
done
pass "the GB10 rule keeps cores in state0 and leaves the N1x and other machines alone"

# The rule's command disables every state past state0 on the CPU it is given.
cpu="$scratch/sysfs/devices/system/cpu/cpu3"
for state in 0 1 2 3; do
  mkdir -p "$cpu/cpuidle/state$state"
  echo 0 >"$cpu/cpuidle/state$state/disable"
done
command=$(sed -nE "s/.*RUN\+=\"\/usr\/bin\/sh -c '(.*)'\"$/\1/p" "$rules")
[[ -n $command ]] || fail "the rule runs a shell command"
command=${command//\$\$/\$}
command=${command//\/sys\$devpath/$scratch/sysfs/devices/system/cpu/cpu3}
sh -c "$command"
[[ $(<"$cpu/cpuidle/state0/disable") == 0 ]] || fail "state0 stays enabled"
for state in 1 2 3; do
  [[ $(<"$cpu/cpuidle/state$state/disable") == 1 ]] || fail "state$state is disabled"
done
pass "the rule's command disables states 1 and up and leaves state0 alone"
