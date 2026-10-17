#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

script="$ROOT/install/hardware/apple/fix-intel-kms.sh"
[[ -f $script ]] || fail "apple intel kms install script exists"
grep -Fq 'MODULES+=(i915)' "$script" || fail "apple intel kms loads i915 early"
grep -Fq 'video=eDP-1:e' "$script" || fail "apple intel kms keeps eDP enabled"
grep -Fq 'fix-intel-kms.sh' "$ROOT/install/hardware/all.sh" ||
  fail "hardware install runs apple intel kms"
pass "apple intel early KMS install is wired"

migration="$ROOT/migrations/1790599768.sh"
[[ -f $migration ]] || fail "migration enables apple intel kms on existing installs"

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
export FIXTURE="$fixture"
export PATH="$fixture/bin:$PATH"
mkdir -p "$fixture/bin" "$fixture/repo/migrations"

# Redirect only system paths; the migration runner and migration logic stay real.
sed -e "s|/etc/|$fixture/etc/|g" \
  -e "s|/var/lib/omarchy/|$fixture/var/lib/omarchy/|g" \
  -e "s|/sys/class/dmi/id/sys_vendor|$fixture/sys_vendor|g" \
  "$migration" > "$fixture/repo/migrations/1790599768.sh"

cat > "$fixture/bin/sudo" <<'STUB'
#!/bin/bash
set -euo pipefail
printf '%s\n' "$*" >> "$FIXTURE/privileged.log"
"$@"
STUB
cat > "$fixture/bin/lspci" <<'STUB'
#!/bin/bash
cat "$FIXTURE/pci"
STUB
cat > "$fixture/bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
printf 'rebuild\n' >> "$FIXTURE/rebuild.log"
[[ ! -f $FIXTURE/fail_rebuild ]]
STUB
cat > "$fixture/bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ ! -f $FIXTURE/command_missing ]]
STUB
cat > "$fixture/bin/omarchy-notification-dismiss" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$fixture/bin/"*

machine_marker="$fixture/var/lib/omarchy/migrations/1790599768"
user_marker="$fixture/state/1790599768.sh"
mkinit_dropin="$fixture/etc/mkinitcpio.conf.d/apple-intel-kms.conf"
limine_dropin="$fixture/etc/limine-entry-tool.d/apple-intel-edp.conf"

reset_fixture() {
  rm -rf "$fixture/etc" "$fixture/var" "$fixture/state"
  rm -f "$fixture/privileged.log" "$fixture/rebuild.log" "$fixture/fail_rebuild" "$fixture/command_missing"
  printf 'Apple Inc.\n' > "$fixture/sys_vendor"
  printf '00:02.0 VGA compatible controller [0300]: Intel [8086:1234]\n' > "$fixture/pci"
}

run_migrate() {
  HOME="$fixture/home" OMARCHY_PATH="$fixture/repo" OMARCHY_MIGRATION_STATE="$fixture/state" \
    bash "$ROOT/bin/omarchy-migrate" > "$fixture/migrate.log" 2>&1
}

assert_rebuilds() {
  local count
  count=$(wc -l < "$fixture/rebuild.log")
  (( count == $1 )) || fail "$2" "$(cat "$fixture/migrate.log")"
  pass "$2"
}

reset_fixture
touch "$fixture/fail_rebuild"
if run_migrate; then
  fail "failed rebuild keeps migration pending"
fi
[[ -f $mkinit_dropin && -f $limine_dropin ]] || fail "failed rebuild leaves both drop-ins"
[[ ! -e $machine_marker && ! -e $user_marker ]] || fail "failed rebuild leaves both completion markers absent"
assert_rebuilds 1 "first migration attempts rebuild and fails"
rm "$fixture/fail_rebuild"
run_migrate
assert_rebuilds 2 "retry rebuilds with both drop-ins already present"
[[ -f $machine_marker && -f $user_marker ]] || fail "successful retry creates both completion markers"
pass "successful retry creates both completion markers"
run_migrate
assert_rebuilds 2 "completed migration skips rebuilding"
rm "$user_marker"
run_migrate
assert_rebuilds 2 "machine success marker skips rebuilding for another user"

for missing_dropin in "$mkinit_dropin" "$limine_dropin"; do
  reset_fixture
  run_migrate
  rm "$user_marker" "$missing_dropin"
  touch "$fixture/fail_rebuild"
  if run_migrate; then
    fail "recreating $missing_dropin requires a successful rebuild"
  fi
  [[ -f $mkinit_dropin && -f $limine_dropin ]] || fail "missing drop-in is recreated before rebuilding"
  [[ ! -e $machine_marker && ! -e $user_marker ]] || fail "recreated drop-in invalidates completion markers"
  assert_rebuilds 2 "recreated drop-in triggers rebuild despite previous success"
  rm "$fixture/fail_rebuild"
  run_migrate
  assert_rebuilds 3 "failed rebuild after recreating a drop-in is retried"
  [[ -f $machine_marker && -f $user_marker ]] || fail "successful retry after recreating a drop-in records completion"
done

reset_fixture
mkdir -p "$(dirname "$mkinit_dropin")" "$(dirname "$limine_dropin")"
printf 'custom mkinitcpio settings\n' > "$mkinit_dropin"
printf 'custom limine settings\n' > "$limine_dropin"
cp "$mkinit_dropin" "$fixture/expected-mkinit"
cp "$limine_dropin" "$fixture/expected-limine"
run_migrate
assert_rebuilds 1 "existing drop-ins without success marker still rebuild"
cmp -s "$mkinit_dropin" "$fixture/expected-mkinit" || fail "existing mkinitcpio drop-in is preserved"
cmp -s "$limine_dropin" "$fixture/expected-limine" || fail "existing limine drop-in is preserved"
pass "existing drop-ins remain unchanged"

reset_fixture
touch "$fixture/command_missing"
run_migrate
[[ ! -e $machine_marker && ! -e $fixture/rebuild.log ]] || fail "unavailable rebuild command records no machine success"
pass "unavailable rebuild command records no machine success"

for hardware in non-apple non-intel; do
  reset_fixture
  if [[ $hardware == "non-apple" ]]; then
    printf 'Other vendor\n' > "$fixture/sys_vendor"
  else
    printf '00:02.0 VGA compatible controller [0300]: AMD [1002:1234]\n' > "$fixture/pci"
  fi
  run_migrate
  [[ ! -e $fixture/privileged.log && ! -e $machine_marker ]] || fail "$hardware performs no privileged work"
  pass "$hardware performs no privileged work"
done
