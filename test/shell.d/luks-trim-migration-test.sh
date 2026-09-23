#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1790190839.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/state"

export PATH="$scratch/bin:$ROOT/bin:$PATH"
export CALL_LOG="$scratch/calls"
export OMARCHY_PATH="$ROOT"
export OMARCHY_LUKS_TRIM_LIMINE_CONF="$scratch/limine"
export OMARCHY_LUKS_TRIM_MARKER="$scratch/state/1790190839"
trim_options="allow-discards"

cat > "$scratch/bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo %s\n' "$*" >> "$CALL_LOG"
exec "$@"
SH

cat > "$scratch/bin/omarchy-state" <<'SH'
#!/bin/bash

[[ $* == "set reboot-required" ]] || exit 99
printf 'state %s\n' "$*" >> "$CALL_LOG"
SH

# The real helper resolves limine-mkinitcpio on PATH, and this repo's test host
# packages it for real; the stub is what the migration must reach.
cat > "$scratch/bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash

[[ ${BOOT_TOOLS_MISSING:-0} == "1" ]] || exit 1
exit 0
SH

cat > "$scratch/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash

printf 'limine-mkinitcpio\n' >> "$CALL_LOG"
[[ ${REBUILD_FAIL:-0} == "0" ]]
SH

# Answers with the cmdline the boot entry would carry, which is the parameter as
# the central config now reads it. ENTRY_WITHOUT_OPTIONS stands for a build that
# silently skipped the UKI rebuild.
cat > "$scratch/bin/limine-entry-tool" <<'SH'
#!/bin/bash

[[ $* == "--get-cmdline default" ]] || exit 99
if [[ ${ENTRY_WITHOUT_OPTIONS:-0} == "1" ]]; then
  printf '%s\n' 'root=UUID=keep-me rw cryptdevice=UUID=keep-me:omarchy_root'
  exit 0
fi
grep -o 'KERNEL_CMDLINE\[default\]+=.*' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" || exit 1
SH

cat > "$scratch/bin/cryptsetup" <<'SH'
#!/bin/bash

printf 'cryptsetup %s\n' "$*" >> "$CALL_LOG"
[[ ${REFRESH_FAIL:-0} == "0" ]]
SH

chmod +x "$scratch/bin/"*

reset_fixture() {
  : > "$CALL_LOG"
  rm -f "$OMARCHY_LUKS_TRIM_MARKER"
  cat > "$OMARCHY_LUKS_TRIM_LIMINE_CONF" <<'CONF'
KERNEL_CMDLINE[default]+=" root=UUID=keep-me rw cryptdevice=UUID=keep-me:omarchy_root rootflags=subvol=@"
BOOT_ORDER="linux-omarchy, *, *fallback, Snapshots"
ENABLE_UKI=yes
CONF
  cp "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/original-limine"
}

# No terminal unless a test provides one, which is how omarchy-migrate runs from
# a non-interactive context: the migration must not wait on the passphrase
# prompt cryptsetup cannot read from.
run_migration() {
  bash -euo pipefail "$migration" < /dev/null > "$scratch/output" 2>&1
}

assert_settings_preserved() {
  grep -Fq 'root=UUID=keep-me rw' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" || fail "the root parameters survive" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
  grep -Fq 'rootflags=subvol=@' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" || fail "the btrfs subvolume survives"
  grep -Fq 'BOOT_ORDER="linux-omarchy, *, *fallback, Snapshots"' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" || fail "unrelated boot settings survive"
  grep -Fq 'ENABLE_UKI=yes' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" || fail "unrelated boot settings survive"
}

reset_fixture
sed -i 's# cryptdevice=UUID=keep-me:omarchy_root##' "$OMARCHY_LUKS_TRIM_LIMINE_CONF"
cp "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/original-limine"
run_migration
cmp -s "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/original-limine" ||
  fail "unencrypted installs keep their boot settings byte for byte" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
[[ ! -s $CALL_LOG ]] || fail "unencrypted installs change nothing" "$(<"$CALL_LOG")"
[[ ! -e $OMARCHY_LUKS_TRIM_MARKER ]] || fail "unencrypted installs are not marked repaired"
pass "an unencrypted install is left byte for byte unchanged"

reset_fixture
rm "$OMARCHY_LUKS_TRIM_LIMINE_CONF"
run_migration
[[ ! -e $OMARCHY_LUKS_TRIM_LIMINE_CONF ]] || fail "a machine without a boot cmdline file is left alone"
[[ ! -s $CALL_LOG ]] || fail "a machine without a boot cmdline file changes nothing" "$(<"$CALL_LOG")"
pass "a machine with no boot cmdline file is left alone"

reset_fixture
run_migration
grep -Fq "cryptdevice=UUID=keep-me:omarchy_root:$trim_options" "$OMARCHY_LUKS_TRIM_LIMINE_CONF" ||
  fail "the cmdline lets TRIM and the workqueue bypass through" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
[[ $(grep -o 'allow-discards' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" | wc -l) == 1 ]] ||
  fail "allow-discards is added exactly once" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
assert_settings_preserved
grep -Fxq 'sudo limine-mkinitcpio' "$CALL_LOG" || fail "the boot entry is rebuilt" "$(<"$CALL_LOG")"
[[ -f $OMARCHY_LUKS_TRIM_MARKER ]] || fail "completion is recorded machine-wide"
grep -Fxq 'state set reboot-required' "$CALL_LOG" ||
  fail "a mapping that was not refreshed needs a reboot" "$(<"$CALL_LOG")"
! grep -q '^cryptsetup' "$CALL_LOG" ||
  fail "the passphrase prompt is not attempted without a terminal" "$(<"$CALL_LOG")"
pass "an encrypted install gains the options once, its boot entry is rebuilt, and the reboot is requested"

reset_fixture
sed -i 's#:omarchy_root#:omarchy_root:allow-discards#' "$OMARCHY_LUKS_TRIM_LIMINE_CONF"
run_migration
grep -Fq "cryptdevice=UUID=keep-me:omarchy_root:$trim_options" "$OMARCHY_LUKS_TRIM_LIMINE_CONF" ||
  fail "an existing option list is extended with the missing options" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
[[ $(grep -o 'allow-discards' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" | wc -l) == 1 ]] ||
  fail "an option that is already there is not repeated" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
pass "a parameter that already carries an option gains only the missing ones"

reset_fixture
run_migration
cp "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/repaired-limine"
: > "$CALL_LOG"
run_migration
cmp -s "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/repaired-limine" ||
  fail "a second run changes nothing" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
[[ ! -s $CALL_LOG ]] || fail "a completed migration runs no work for the next user" "$(<"$CALL_LOG")"
pass "a second run changes nothing and does no work"

reset_fixture
if REBUILD_FAIL=1 run_migration; then
  fail "a failed boot image build must fail the migration"
fi
[[ ! -e $OMARCHY_LUKS_TRIM_MARKER ]] || fail "a failed boot image build stays pending"
! grep -q '^state ' "$CALL_LOG" || fail "a failed build must not request a reboot"
: > "$CALL_LOG"
run_migration
grep -Fxq 'sudo limine-mkinitcpio' "$CALL_LOG" ||
  fail "the retry rebuilds even though the cmdline was already repaired" "$(<"$CALL_LOG")"
[[ -f $OMARCHY_LUKS_TRIM_MARKER ]] || fail "the retry records completion"
pass "a failed build is retried and stays pending until the entries carry the options"

reset_fixture
if ENTRY_WITHOUT_OPTIONS=1 run_migration; then
  fail "a boot entry without the options must fail the migration"
fi
[[ ! -e $OMARCHY_LUKS_TRIM_MARKER ]] || fail "a boot entry without the options stays pending"
pass "a boot entry that still refuses TRIM cannot be reported as repaired"

reset_fixture
BOOT_TOOLS_MISSING=1 run_migration
cmp -s "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/original-limine" ||
  fail "a machine that manages its own boot keeps its boot settings" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
[[ ! -e $OMARCHY_LUKS_TRIM_MARKER ]] || fail "a machine without limine-mkinitcpio is not marked repaired"
pass "a machine without Limine boot management is left alone"

require_command script
reset_fixture
script -qec "bash -euo pipefail $(printf '%q' "$migration")" /dev/null > "$scratch/output" 2>&1 ||
  fail "the migration applies the options to the running mapping in a terminal" "$(<"$scratch/output")"
grep -Fxq 'cryptsetup refresh --allow-discards --persistent omarchy_root' "$CALL_LOG" ||
  fail "the running mapping is refreshed with the persistent flags" "$(<"$CALL_LOG")"
! grep -q '^state ' "$CALL_LOG" || fail "a refreshed mapping does not need a reboot" "$(<"$CALL_LOG")"
pass "a terminal refreshes the running mapping with the persistent flags instead of deferring to the next boot"
