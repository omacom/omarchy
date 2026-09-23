#!/bin/bash
#
# The amdgpu HDMI HPD debounce migration rebuilds the initramfs once so a
# packaged /etc/modprobe.d/amdgpu.conf reaches the early amdgpu load. It must
# only rebuild on machines with an AMD display controller (else the option is
# inert), skip before the packaged config lands, flag a reboot so the fix is
# actually applied, stay idempotent via a machine-wide marker, and leave a
# failed rebuild pending for retry.
#
# The real omarchy-cmd-present runs here (from the repo bin); only the
# privileged/system calls are stubbed, so the whole chain — including the
# reboot flag and the PCI scan — is exercised.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1790200214.sh"
[[ -f $migration ]] || fail "the amdgpu HPD debounce migration exists at $migration"

# The shipped migration keeps fixed privileged/state paths as literals with
# env overrides only for read-only fixture targeting (same seam the mkinitcpio
# drop-ins already use for the PCI tree).
grep -Fq 'rebuild_marker="${OMARCHY_AMDGPU_HPD_REBUILD_MARKER:-/var/lib/omarchy/migrations/1790200214}"' "$migration" ||
  fail "the shipped migration keeps its fixed production marker default"
grep -Fq 'rebuild_marker' "$migration" && [[ $(grep -c 'sudo install -Dm644' "$migration") == 1 ]] ||
  fail "the shipped migration records completion exactly once"
pass "the shipped migration pins its production marker default"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/pci" "$scratch/conf"

export PATH="$scratch/bin:$ROOT/bin:$PATH"
export CALL_LOG="$scratch/calls"
export OMARCHY_PCI_DEVICES_PATH="$scratch/pci"
export OMARCHY_AMDGPU_HPD_REBUILD_MARKER="$scratch/state/1790200214"
export OMARCHY_AMDGPU_HPD_CONF="$scratch/conf/amdgpu.conf"
conf="$OMARCHY_AMDGPU_HPD_CONF"

cat > "$scratch/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >> "$CALL_LOG"
exec "$@"
SH

cat > "$scratch/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'limine-mkinitcpio\n' >> "$CALL_LOG"
[[ ${REBUILD_FAIL:-0} == "0" ]]
SH

cat > "$scratch/bin/omarchy-state" <<'SH'
#!/bin/bash
[[ $* == "set reboot-required" ]] || exit 99
printf '%s\n' "$*" >> "$CALL_LOG"
SH
chmod +x "$scratch/bin/"*

system_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

mkdir -p "$scratch/pci/0000:0b:00.0"
printf '%s\n' '0x1002' > "$scratch/pci/0000:0b:00.0/vendor"
printf '%s\n' '0x030000' > "$scratch/pci/0000:0b:00.0/class"

reset_machine() {
  : > "$CALL_LOG"
  rm -f "$OMARCHY_AMDGPU_HPD_REBUILD_MARKER" "$scratch/pci/0000:0b:00.0"/vendor "$scratch/pci/0000:0b:00.0"/class
  rm -f "$scratch/pci/0000:10:00.0"/vendor "$scratch/pci/0000:10:00.0"/class
  : > "$conf"
}

run_migration() {
  bash -euo pipefail "$migration" > "$scratch/output" 2>&1
}

add_amd_device() {
  mkdir -p "$scratch/pci/0000:0b:00.0"
  printf '%s\n' '0x1002' > "$scratch/pci/0000:0b:00.0/vendor"
  printf '%s\n' '0x030000' > "$scratch/pci/0000:0b:00.0/class"
}

reset_machine
add_amd_device
printf '%s\n' 'options amdgpu hdmi_hpd_debounce_delay_ms=1500' > "$conf"
run_migration
grep -Fxq 'limine-mkinitcpio' "$CALL_LOG" || fail "AMD machines rebuild the initramfs"
grep -Fxq 'sudo limine-mkinitcpio' "$CALL_LOG" || fail "the rebuild runs through sudo"
[[ -f $OMARCHY_AMDGPU_HPD_REBUILD_MARKER ]] || fail "successful completion is recorded"
grep -Fxq 'set reboot-required' "$CALL_LOG" || fail "the updater must offer a reboot so the param applies at load"
pass "AMD machines rebuild the initramfs, record completion, and flag a reboot"

: > "$CALL_LOG"
run_migration
[[ ! -s $CALL_LOG ]] || fail "another user's run does not repeat the machine-wide rebuild"
pass "repeat runs are a no-op after successful completion"

# The packaged conf has not landed yet (partial update): nothing to bake.
reset_machine
add_amd_device
rm -f "$conf"
run_migration
[[ ! -s $CALL_LOG ]] || fail "a machine without the packaged conf does not rebuild"
[[ ! -e $OMARCHY_AMDGPU_HPD_REBUILD_MARKER ]] || fail "a machine without the packaged conf stays pending"
pass "the migration waits for the packaged amdgpu.conf to land"

# No AMD display controller: the option is inert, so no rebuild or reboot nag.
reset_machine
rm -rf "$scratch/pci/0000:0b:00.0"
mkdir -p "$scratch/pci/0000:10:00.0"
printf '%s\n' '0x8086' > "$scratch/pci/0000:10:00.0/vendor"
printf '%s\n' '0x030000' > "$scratch/pci/0000:10:00.0/class"
printf '%s\n' 'options amdgpu hdmi_hpd_debounce_delay_ms=1500' > "$conf"
run_migration
[[ ! -s $CALL_LOG ]] || fail "Intel-only machines do not change" "$(<"$CALL_LOG")"
[[ ! -e $OMARCHY_AMDGPU_HPD_REBUILD_MARKER ]] || fail "Intel-only machines do not get a completion marker"
pass "Intel-only machines are skipped without a rebuild or reboot flag"

reset_machine
rm -rf "$scratch/pci"
mkdir -p "$scratch/pci"
printf '%s\n' 'options amdgpu hdmi_hpd_debounce_delay_ms=1500' > "$conf"
run_migration
[[ ! -s $CALL_LOG ]] || fail "a machine with no PCI devices does not change" "$(<"$CALL_LOG")"
pass "a machine with no readable PCI display devices is skipped"

# A failed rebuild stays pending and retries; the reboot flag only comes after
# a successful rebuild, in the same order the fix needs.
reset_machine
add_amd_device
printf '%s\n' 'options amdgpu hdmi_hpd_debounce_delay_ms=1500' > "$conf"
if REBUILD_FAIL=1 run_migration; then
  fail "a failed initramfs rebuild must fail the migration"
fi
[[ ! -e $OMARCHY_AMDGPU_HPD_REBUILD_MARKER ]] || fail "a failed rebuild stays pending"
! grep -q '^set reboot-required$' "$CALL_LOG" || fail "a failed rebuild must not request a reboot"
run_migration
grep -Fxq 'limine-mkinitcpio' "$CALL_LOG" || fail "retry rebuilds after a failure"
[[ -f $OMARCHY_AMDGPU_HPD_REBUILD_MARKER ]] || fail "retry records successful completion"
grep -Fxq 'set reboot-required' "$CALL_LOG" || fail "retry flags the reboot after the rebuild succeeds"
pass "a failed rebuild is retried and only completes with its reboot flag"

# No limine-mkinitcpio (non-Limine boot, unsupported boot setup): no-op.
reset_machine
add_amd_device
printf '%s\n' 'options amdgpu hdmi_hpd_debounce_delay_ms=1500' > "$conf"
mkdir -p "$scratch/no-limine-bin"
cat > "$scratch/no-limine-bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$scratch/no-limine-bin/omarchy-cmd-present"
PATH="$scratch/no-limine-bin:$system_path" run_migration
[[ ! -s $CALL_LOG ]] || fail "a system without limine-mkinitcpio does not rebuild" "$(<"$CALL_LOG")"
[[ ! -e $OMARCHY_AMDGPU_HPD_REBUILD_MARKER ]] || fail "a system without limine-mkinitcpio stays pending"
pass "a system without limine-mkinitcpio is skipped"