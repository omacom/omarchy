#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Every check here drives the commands through fixtures (a cpuinfo file and a
# fake SMU), and root deliberately ignores both.
if (( EUID == 0 )); then
  skip "cpu-limits fixtures are ignored by root; skipping the CPU power-limit tests"
  exit 0
fi

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

# Any SMU access goes through setpci; record it so the guard can be checked.
cat >"$tmp_dir/bin/setpci" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$SETPCI_LOG"
EOF
chmod +x "$tmp_dir/bin/setpci"

export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"
export SETPCI_LOG="$tmp_dir/setpci.log"

cpuinfo() {
  printf 'processor\t: 0\nvendor_id\t: %s\ncpu family\t: %s\nmodel\t\t: %s\nmodel name\t: Test CPU\n' "$1" "$2" "$3" >"$tmp_dir/cpuinfo"
  # A second processor block with other values must not change the answer.
  printf 'processor\t: 1\nvendor_id\t: GenuineIntel\ncpu family\t: 6\nmodel\t\t: 24\n' >>"$tmp_dir/cpuinfo"
}

raven() {
  OMARCHY_CPUINFO_PATH="$tmp_dir/cpuinfo" "$ROOT/bin/omarchy-hw-amd-raven"
}

for model in 17 24 32; do
  cpuinfo AuthenticAMD 23 "$model"
  raven || fail "family 17h model $model is a Raven-family APU"
done
pass "Raven Ridge, Picasso and Dali are detected"

cpuinfo AuthenticAMD 23 96
raven && fail "Renoir (family 17h model 60h) uses another SMU layout"
cpuinfo AuthenticAMD 25 24
raven && fail "family 19h is not Raven-family"
cpuinfo GenuineIntel 23 24
raven && fail "an Intel CPU is not Raven-family"
pass "other CPUs are not detected as Raven-family"

# Root reads only the live /proc/cpuinfo: as a user namespace's root, a fixture
# claiming the opposite of the real CPU must not change the answer.
if unshare --user --map-root-user true 2>/dev/null; then
  if "$ROOT/bin/omarchy-hw-amd-raven"; then
    live=yes
    cpuinfo GenuineIntel 6 140
  else
    live=no
    cpuinfo AuthenticAMD 23 24
  fi
  if OMARCHY_CPUINFO_PATH="$tmp_dir/cpuinfo" unshare --user --map-root-user "$ROOT/bin/omarchy-hw-amd-raven"; then
    as_root=yes
  else
    as_root=no
  fi
  [[ $as_root == "$live" ]] || fail "root ignores a fixture cpuinfo in its environment"
  pass "root ignores a fixture cpuinfo in its environment"
else
  skip "user namespaces unavailable; skipping the root fixture check"
fi

cpuinfo AuthenticAMD 23 96
for action in apply status; do
  OMARCHY_CPUINFO_PATH="$tmp_dir/cpuinfo" "$ROOT/bin/omarchy-powerprofiles-cpu-limits" "$action" >/dev/null ||
    fail "cpu-limits $action exits cleanly on an unsupported CPU"
done
[[ ! -e $SETPCI_LOG ]] || fail "cpu-limits never touches PCI config space on an unsupported CPU"
pass "cpu-limits is a no-op on unsupported CPUs"

# ---------------------------------------------------------------------------
# The SMU logic, run unprivileged against a fake SMU. The fake setpci models the
# SMN index/data pair at 0xB8/0xBC and the MP1/PSMU mailboxes behind it:
#   $sim/respond-<id>  the response to message <id> (default 1; 0 never answers)
#   $sim/table-fresh   the PM table page a successful transfer copies to memory
#   $sim/writes        each MP1 limit message as "<id> <mW> <response>"
#   $sim/unlocked      any hardware access made without the command's lock held
require_command python3

sim="$tmp_dir/sim"

cat >"$tmp_dir/bin/setpci" <<'EOF'
#!/bin/bash
sim=$OMARCHY_CPU_LIMITS_SIMULATE_DIR
mkdir -p "$sim/smn" "$sim/run"
flock -n "$sim/run/lock" true && printf '%s\n' "$3" >>"$sim/unlocked"

mp1_msg=$((0x3B10528)) mp1_response=$((0x3B10564)) mp1_arg=$((0x3B10998))
psmu_msg=$((0x3B10A20)) psmu_response=$((0x3B10A80)) psmu_arg=$((0x3B10A88))

case $3 in
  0xB8.L=*) echo $(( 16#${3#*=} )) >"$sim/index" ;;
  0xBC.L) printf '%08x\n' "$(cat "$sim/smn/$(<"$sim/index")" 2>/dev/null || echo 0)" ;;
  0xBC.L=*)
    address=$(<"$sim/index") value=$(( 16#${3#*=} ))
    echo "$value" >"$sim/smn/$address"
    if (( address == mp1_msg || address == psmu_msg )); then
      id=$(printf '0x%x' "$value")
      response=$(( $(cat "$sim/respond-$id" 2>/dev/null || echo 1) ))
      if (( address == mp1_msg )); then
        echo "$id $(<"$sim/smn/$mp1_arg") $response" >>"$sim/writes"
        echo "$response" >"$sim/smn/$mp1_response"
      else
        if (( response == 1 )) && [[ $id == "0xb" ]]; then echo 4096 >"$sim/smn/$psmu_arg"; fi
        if (( response == 1 )) && [[ $id == "0x3d" ]]; then
          dd if="$sim/table-fresh" of="$sim/mem" bs=4096 seek=1 count=1 conv=notrunc status=none
        fi
        echo "$response" >"$sim/smn/$psmu_response"
      fi
    fi
    ;;
esac
EOF
chmod +x "$tmp_dir/bin/setpci"

cat >"$tmp_dir/bin/busctl" <<'EOF'
#!/bin/bash
echo "s \"$(<"$OMARCHY_CPU_LIMITS_SIMULATE_DIR/profile")\""
EOF
chmod +x "$tmp_dir/bin/busctl"

cat >"$tmp_dir/bin/logger" <<'EOF'
#!/bin/bash
printf '%s\n' "${@: -1}" >>"$OMARCHY_CPU_LIMITS_SIMULATE_DIR/log"
EOF
chmod +x "$tmp_dir/bin/logger"

# A PM table page opening with stapm, fast and slow limits (and their values), in watts.
pm_table() {
  python3 -c 'import struct, sys; sys.stdout.buffer.write(struct.pack("<6f", *map(float, sys.argv[1:])).ljust(4096, b"\0"))' "$@"
}

# reset_sim <profile> <ac|battery>
reset_sim() {
  rm -rf "$sim"
  mkdir -p "$sim/run" "$sim/state" "$sim/power/AC"
  echo "$1" >"$sim/profile"
  echo Mains >"$sim/power/AC/type"
  if [[ $2 == "ac" ]]; then echo 1 >"$sim/power/AC/online"; else echo 0 >"$sim/power/AC/online"; fi
  head -c 8192 /dev/zero >"$sim/mem"
  pm_table 22 5 25 5 25 5 >"$sim/table-fresh"
}

limits() {
  OMARCHY_CPU_LIMITS_SIMULATE_DIR="$sim" OMARCHY_POWER_SUPPLY_PATH="$sim/power" \
    OMARCHY_CPUINFO_PATH="$tmp_dir/cpuinfo" "$ROOT/bin/omarchy-powerprofiles-cpu-limits" "$@" >/dev/null
}

cpuinfo AuthenticAMD 23 24

reset_sim power-saver ac
limits apply
[[ $(<"$sim/state/stock-ac") == "22000 25000 25000" ]] || fail "apply records the firmware's limits for the current power source"
[[ $(tail -n 3 "$sim/writes") == $'0x1a 12000 1\n0x1b 15000 1\n0x1c 12000 1' ]] || fail "power-saver writes the cap"
echo balanced >"$sim/profile"
limits apply
[[ $(tail -n 3 "$sim/writes") == $'0x1a 22000 1\n0x1b 25000 1\n0x1c 25000 1' ]] || fail "leaving power-saver restores the recorded limits"
[[ ! -e $sim/run/capped ]] || fail "a full restore clears the cap marker"
pass "power-saver caps the limits and leaving it restores the recorded ones"

limits status
[[ ! -e $sim/unlocked ]] || fail "every SMU access, status included, holds the lock: $(head -n 1 "$sim/unlocked")"
pass "apply and status touch the SMU only under the lock"

reset_sim power-saver ac
echo 0 >"$sim/respond-0x1b"
limits apply
grep -q '0x1b=0x0' "$sim/log" || fail "an unanswered limit message is logged as a failure"
pass "a timed-out SMU request counts as a failure"

reset_sim power-saver ac
echo 0xfd >"$sim/respond-0x1b"
limits apply
[[ -e $sim/run/capped ]] || fail "a partly accepted cap is still marked"
rm "$sim/respond-0x1b"
echo balanced >"$sim/profile"
limits apply
[[ $(tail -n 3 "$sim/writes") == $'0x1a 22000 1\n0x1b 25000 1\n0x1c 25000 1' ]] || fail "a partly accepted cap is restored"
pass "a partly accepted cap is restored on leaving power-saver"

reset_sim balanced ac
pm_table 30 5 35 5 35 5 | dd of="$sim/mem" bs=4096 seek=1 conv=notrunc status=none
echo 0xff >"$sim/respond-0x3d"
limits apply
[[ ! -e $sim/state/stock-ac ]] || fail "a table that failed to refresh is not recorded as stock"
reset_sim balanced ac
pm_table 0 0 0 0 0 0 >"$sim/table-fresh"
limits apply
[[ ! -e $sim/state/stock-ac ]] || fail "an empty table is not recorded as stock"
pass "only a refreshed, plausible PM table is recorded as stock"

reset_sim balanced ac
: >"$sim/table-fresh" # nothing to read, so no AC record is made
echo "22000 25000 25000" >"$sim/state/stock-battery"
touch "$sim/run/capped"
limits apply
[[ ! -e $sim/writes ]] || fail "AC never restores from the battery record"
grep -q 'No recorded stock ac limits' "$sim/log" || fail "a missing record for this power source is logged"
pass "restore uses only the current power source's record"
