#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The pacman stub models the transaction shape, not the resolver: the test
# pins that both generations are removed together, that the dry run comes
# first, and that the guards decide what is touched. Real dependency behavior
# is pacman's own dry run.
migration="$ROOT/migrations/1792478700.sh"
[[ -f $migration ]] || fail "the NVIDIA userspace cleanup migration exists"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls"
pci="$test_tmp/pci"
present="$test_tmp/present"
explicit="$test_tmp/explicit"
mkdir -p "$stub_bin" "$pci"

cat >"$stub_bin/omarchy-hw-nvidia" <<'SH'
#!/bin/bash
printf 'omarchy-hw-nvidia\n' >>"$CALLS"
[[ $TEST_NVIDIA == "yes" ]]
SH

cat >"$stub_bin/omarchy-hw-x86" <<'SH'
#!/bin/bash
printf 'omarchy-hw-x86\n' >>"$CALLS"
[[ $TEST_ARCH == "x86_64" ]]
SH

cat >"$stub_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
grep -Fxq "$1" "$TEST_PRESENT"
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'omarchy-pkg-add %s\n' "$*" >>"$CALLS"
[[ $TEST_ADD_FAIL != "yes" ]] || exit 1
if [[ $TEST_ADD_FAIL_LIB32 == "yes" ]]; then
  for package in "$@"; do
    [[ $package != lib32-* ]] || exit 1
  done
fi
printf '%s\n' "$@" >>"$TEST_PRESENT"
SH

cat >"$stub_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf 'omarchy-pkg-drop %s\n' "$*" >>"$CALLS"
[[ $TEST_DROP_FAIL != "yes" ]] || exit 1
for package in "$@"; do
  sed -i "/^$package$/d" "$TEST_PRESENT"
done
SH

cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash
printf 'pacman %s\n' "$*" >>"$CALLS"
case $1 in
  -Qq)
    [[ $TEST_QQ_FAIL != "yes" ]] || { printf 'error: could not open database\n' >&2; exit 1; }
    cat "$TEST_PRESENT"
    ;;
  -Qi)
    grep -Fxq "$2" "$TEST_PRESENT" || exit 1
    reason="Installed as a dependency for another package"
    grep -Fxq "$2" "$TEST_EXPLICIT" && reason="Explicitly installed"
    printf 'Name            : %s\nInstall Reason  : %s\n' "$2" "$reason"
    ;;
  -Rs)
    if [[ -n ${TEST_PREFLIGHT_ERROR:-} ]]; then
      printf 'error: %s\n' "$TEST_PREFLIGHT_ERROR" >&2
      exit 1
    fi
    for package in "${@:3}"; do
      if [[ $package == "${TEST_PREFLIGHT_FAIL:-}" ]]; then
        printf 'error: failed to prepare transaction (could not satisfy dependencies)\n' >&2
        exit 1
      fi
    done
    ;;
esac
SH
chmod +x "$stub_bin"/*

write_pci() {
  rm -rf "$pci"
  mkdir -p "$pci"
  local slot=0
  for vendor in "$@"; do
    mkdir -p "$pci/0000:00:0$slot.0"
    printf '0x030000\n' >"$pci/0000:00:0$slot.0/class"
    printf '%s\n' "$vendor" >"$pci/0000:00:0$slot.0/vendor"
    slot=$((slot + 1))
  done
}

run_migration() {
  local architecture=${1:-x86_64} nvidia=${2:-no} add_fail=${3:-no} preflight_fail=${4:-} drop_fail=${5:-no}
  local add_fail_lib32=${6:-no} preflight_error=${7:-} qq_fail=${8:-no}
  : >"$calls"
  HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" CALLS="$calls" \
    OMARCHY_PCI_DEVICES_PATH="$pci" TEST_PRESENT="$present" TEST_EXPLICIT="$explicit" \
    TEST_ARCH="$architecture" TEST_NVIDIA="$nvidia" TEST_ADD_FAIL="$add_fail" \
    TEST_ADD_FAIL_LIB32="$add_fail_lib32" TEST_PREFLIGHT_FAIL="$preflight_fail" \
    TEST_PREFLIGHT_ERROR="$preflight_error" TEST_DROP_FAIL="$drop_fail" TEST_QQ_FAIL="$qq_fail" \
    PATH="$stub_bin:$PATH" bash -euo pipefail "$migration" >"$test_tmp/output" 2>&1
}

run_ok() {
  run_migration "$@" || fail "the migration runs on $description" "$(<"$test_tmp/output")"
}

logged() {
  grep -Fxq "$1" "$calls"
}

ordered() {
  local first last
  first=$(grep -Fn "$1" "$calls" | head -n 1 | cut -d: -f1)
  last=$(grep -Fn "$2" "$calls" | head -n 1 | cut -d: -f1)
  [[ -n $first && -n $last ]] && (( first < last ))
}

# Intel: install both drivers, then remove both NVIDIA packages together.
description="an Intel machine with NVIDIA dependencies"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
run_ok
logged "omarchy-pkg-add vulkan-intel" ||
  fail "$description installs the 64-bit driver" "$(<"$calls")"
logged "omarchy-pkg-add lib32-vulkan-intel" ||
  fail "$description installs the 32-bit driver" "$(<"$calls")"
logged "pacman -Rs --print nvidia-utils lib32-nvidia-utils" ||
  fail "$description checks both removals in one transaction" "$(<"$calls")"
logged "omarchy-pkg-drop nvidia-utils lib32-nvidia-utils" ||
  fail "$description removes both NVIDIA packages together" "$(<"$calls")"
ordered "omarchy-pkg-add lib32-vulkan-intel" "pacman -Rs --print nvidia-utils lib32-nvidia-utils" ||
  fail "$description claims the virtuals before checking the removal" "$(<"$calls")"
ordered "pacman -Rs --print nvidia-utils lib32-nvidia-utils" "omarchy-pkg-drop nvidia-utils lib32-nvidia-utils" ||
  fail "$description checks the removal before making it" "$(<"$calls")"
! grep -q '^nvidia-utils$\|^lib32-nvidia-utils$' "$present" ||
  fail "$description leaves no NVIDIA package installed" "$(<"$present")"
pass "$description installs the matching drivers and removes both NVIDIA packages"

# Run again against the state the migration leaves behind.
: >"$calls"
run_ok
! grep -q '^omarchy-pkg-add' "$calls" || fail "a cleaned machine installs nothing on the next run" "$(<"$calls")"
! grep -q '^pacman -Rs' "$calls" || fail "a cleaned machine checks no removal on the next run" "$(<"$calls")"
! grep -q '^omarchy-pkg-drop' "$calls" || fail "a cleaned machine removes nothing on the next run" "$(<"$calls")"
pass "the migration is a no-op once the NVIDIA packages are gone"

# AMD.
description="an AMD machine with NVIDIA dependencies"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x1002
run_ok
logged "omarchy-pkg-add vulkan-radeon" ||
  fail "$description installs the 64-bit driver" "$(<"$calls")"
logged "omarchy-pkg-add lib32-vulkan-radeon" ||
  fail "$description installs the 32-bit driver" "$(<"$calls")"
logged "omarchy-pkg-drop nvidia-utils lib32-nvidia-utils" ||
  fail "$description removes both NVIDIA packages" "$(<"$calls")"
pass "$description installs the matching drivers and removes both NVIDIA packages"

# A 4.0.5 machine gets the 580xx names from Omarchy's repository.
description="a machine with the 580xx NVIDIA packages"
printf 'nvidia-580xx-utils\nlib32-nvidia-580xx-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
run_ok
logged "omarchy-pkg-drop nvidia-580xx-utils lib32-nvidia-580xx-utils" ||
  fail "$description removes the exact 580xx names" "$(<"$calls")"
! grep -q '^pacman -Rs --print.*nvidia-utils$' "$calls" ||
  fail "$description does not treat a Provides alias as a package" "$(<"$calls")"
pass "$description removes both exact 580xx packages"

# OpenCL userspace comes from the same stack and is just as unusable. It goes
# in a second transaction so a consumer of opencl-driver cannot veto the
# Vulkan cleanup.
description="a machine with NVIDIA OpenCL userspace"
printf 'nvidia-utils\nlib32-nvidia-utils\nopencl-nvidia\nlib32-opencl-nvidia\n' >"$present"
: >"$explicit"
write_pci 0x1002
run_ok
logged "omarchy-pkg-drop nvidia-utils lib32-nvidia-utils" ||
  fail "$description removes the Vulkan stack" "$(<"$calls")"
logged "omarchy-pkg-drop opencl-nvidia lib32-opencl-nvidia" ||
  fail "$description removes the OpenCL userspace separately" "$(<"$calls")"
ordered "omarchy-pkg-drop nvidia-utils lib32-nvidia-utils" "omarchy-pkg-drop opencl-nvidia lib32-opencl-nvidia" ||
  fail "$description finishes the Vulkan cleanup first" "$(<"$calls")"
pass "$description removes the whole NVIDIA userspace stack"

description="a machine with the 580xx OpenCL packages"
printf 'nvidia-580xx-utils\nlib32-nvidia-580xx-utils\nopencl-nvidia-580xx\nlib32-opencl-nvidia-580xx\n' >"$present"
: >"$explicit"
write_pci 0x8086
run_ok
logged "omarchy-pkg-drop nvidia-580xx-utils lib32-nvidia-580xx-utils" ||
  fail "$description removes the 580xx Vulkan stack" "$(<"$calls")"
logged "omarchy-pkg-drop opencl-nvidia-580xx lib32-opencl-nvidia-580xx" ||
  fail "$description removes the 580xx OpenCL userspace" "$(<"$calls")"
pass "$description removes the whole 580xx stack"

# A consumer of opencl-driver blocks only the OpenCL transaction.
description="a blocked OpenCL removal"
printf 'nvidia-utils\nlib32-nvidia-utils\nopencl-nvidia\nlib32-opencl-nvidia\n' >"$present"
: >"$explicit"
write_pci 0x8086
run_ok x86_64 no no opencl-nvidia
logged "omarchy-pkg-drop nvidia-utils lib32-nvidia-utils" ||
  fail "$description still removes the Vulkan stack" "$(<"$calls")"
! grep -q '^omarchy-pkg-drop.*opencl-' "$calls" ||
  fail "$description leaves the OpenCL userspace installed" "$(<"$calls")"
grep -q 'Something still depends on the NVIDIA OpenCL userspace' "$test_tmp/output" ||
  fail "$description says why it left OpenCL alone"
pass "$description removes the Vulkan stack and leaves OpenCL alone"

# An explicit NVIDIA install is a user decision, not a stale dependency.
description="an explicitly installed NVIDIA userspace"
printf 'nvidia-utils\n' >"$present"
printf 'nvidia-utils\n' >"$explicit"
write_pci 0x8086
run_ok
! grep -q '^omarchy-pkg-add' "$calls" || fail "$description is left alone" "$(<"$calls")"
! grep -q '^omarchy-pkg-drop' "$calls" || fail "$description is not removed" "$(<"$calls")"
pass "$description is left alone"

# A dependency-installed package goes, but an explicitly installed one in the
# same stack stays out of the transaction.
description="a mixed explicit and dependency install"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
printf 'lib32-nvidia-utils\n' >"$explicit"
write_pci 0x8086
run_ok x86_64 no no nvidia-utils
logged "pacman -Rs --print nvidia-utils" ||
  fail "$description checks only the dependency-installed package" "$(<"$calls")"
! grep -q '^pacman -Rs --print.*lib32-nvidia-utils' "$calls" ||
  fail "$description leaves the explicit package out" "$(<"$calls")"
pass "$description leaves the explicit package out"

# An NVIDIA GPU or a kernel driver means the userspace has a purpose.
description="an NVIDIA GPU"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x10de
run_ok x86_64 yes
! grep -q '^omarchy-pkg-add\|^omarchy-pkg-drop' "$calls" || fail "$description is left alone" "$(<"$calls")"
pass "$description is left alone"

for driver in nvidia nvidia-open nvidia-lts nvidia-open-lts nvidia-dkms nvidia-open-dkms nvidia-580xx-dkms; do
  description="an NVIDIA kernel driver ($driver)"
  printf 'nvidia-utils\nlib32-nvidia-utils\n%s\n' "$driver" >"$present"
  : >"$explicit"
  write_pci 0x8086
  run_ok
  ! grep -q '^omarchy-pkg-add\|^omarchy-pkg-drop' "$calls" || fail "$description is left alone" "$(<"$calls")"
  pass "$description is left alone"
done

# A dependency blocks the combined transaction, so nothing is removed.
description="a blocked removal"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
run_ok x86_64 no no lib32-nvidia-utils
! grep -q '^omarchy-pkg-drop' "$calls" || fail "$description removes nothing" "$(<"$calls")"
grep -q 'Something still depends on the NVIDIA userspace' "$test_tmp/output" ||
  fail "$description says why it left the packages alone"
pass "$description leaves both packages installed"

# A failed removal keeps the migration pending for the next run.
description="a failed removal"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
if run_migration x86_64 no no "" yes; then
  fail "$description fails the migration"
fi
grep -q 'Could not remove the NVIDIA userspace' "$test_tmp/output" ||
  fail "$description says why it left the packages alone"
pass "$description leaves the NVIDIA packages alone and stays pending"

# A failed driver install keeps the migration pending for the next run.
description="a failed driver install"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
if run_migration x86_64 no yes; then
  fail "$description fails the migration"
fi
! grep -q '^pacman -Rs\|^omarchy-pkg-drop' "$calls" || fail "$description removes nothing" "$(<"$calls")"
grep -q 'Could not install the matching Vulkan drivers' "$test_tmp/output" ||
  fail "$description says why it left the NVIDIA packages alone"
pass "$description leaves the NVIDIA packages alone and stays pending"

# The 64-bit driver still installs when only the 32-bit one is unavailable.
# With the 32-bit package still installed, its dependency keeps the Vulkan
# removal from splitting the pair, so the migration must stay pending instead
# of recording a repair it could not finish.
description="a failed 32-bit driver install"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
if run_migration x86_64 no no nvidia-utils no yes; then
  fail "$description fails the migration"
fi
logged "omarchy-pkg-add vulkan-intel" || fail "$description installs the 64-bit driver" "$(<"$calls")"
grep -q 'could not install the 32-bit Vulkan drivers' "$test_tmp/output" ||
  fail "$description reports the missing 32-bit driver"
grep -q 'leaving the cleanup pending for the next run' "$test_tmp/output" ||
  fail "$description stays pending while the NVIDIA packages remain"
! grep -q '^omarchy-pkg-drop' "$calls" || fail "$description leaves the pair installed" "$(<"$calls")"
pass "$description keeps the 64-bit driver, leaves the pair, and stays pending"

description="a failed 32-bit driver install without the 32-bit package"
printf 'nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
run_ok x86_64 no no "" no yes
logged "omarchy-pkg-add vulkan-intel" || fail "$description installs the 64-bit driver" "$(<"$calls")"
logged "omarchy-pkg-drop nvidia-utils" ||
  fail "$description still removes the 64-bit package" "$(<"$calls")"
pass "$description removes the 64-bit package"

# Without the 32-bit package there is no unfinished pair to retry: a 64-bit
# package that something else depends on is a real dependency block, left
# alone like any other.
description="a failed 32-bit driver install and a blocked 64-bit removal"
printf 'nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
run_ok x86_64 no no nvidia-utils no yes
! grep -q '^omarchy-pkg-drop' "$calls" || fail "$description removes nothing" "$(<"$calls")"
grep -q 'Something still depends on the NVIDIA userspace' "$test_tmp/output" ||
  fail "$description reports the dependency block"
pass "$description is left alone"

# A preflight failure that is not a dependency block keeps the migration pending.
description="a preflight error"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
if run_migration x86_64 no no "" no no "database is locked"; then
  fail "$description fails the migration"
fi
grep -q 'database is locked' "$test_tmp/output" || fail "$description reports the real error"
! grep -q 'Something still depends on the NVIDIA userspace' "$test_tmp/output" ||
  fail "$description does not blame a dependency"
pass "$description reports the real error and stays pending"

# A database query failure also stays pending.
description="a package database query failure"
printf 'nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
if run_migration x86_64 no no "" no no "" yes; then
  fail "$description fails the migration"
fi
grep -q 'Could not query installed packages' "$test_tmp/output" ||
  fail "$description reports the query failure"
pass "$description reports the query failure and stays pending"

# A machine with another provider does not need an Intel or AMD driver first;
# pacman's dry run still decides whether the removal is safe.
description="a machine with another Vulkan provider"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x1af4
run_ok
! grep -q '^omarchy-pkg-add' "$calls" || fail "$description installs no vendor driver" "$(<"$calls")"
logged "omarchy-pkg-drop nvidia-utils lib32-nvidia-utils" ||
  fail "$description removes what pacman does not need" "$(<"$calls")"
pass "$description lets pacman decide the removal"

# Multilib only exists on x86_64.
description="an aarch64 machine"
printf 'nvidia-utils\nlib32-nvidia-utils\n' >"$present"
: >"$explicit"
write_pci 0x8086
run_ok aarch64
logged "omarchy-pkg-add vulkan-intel" || fail "$description installs the 64-bit driver" "$(<"$calls")"
! grep -q '^omarchy-pkg-add.*lib32-' "$calls" || fail "$description installs no 32-bit driver" "$(<"$calls")"
pass "$description installs only the 64-bit driver"
