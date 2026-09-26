#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

default_config="$ROOT/default/limine/limine.conf"
migration="$ROOT/migrations/1789395066.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

active_mouse_pattern='^[[:space:]]*mouse:'

active_mouse_count() {
  sed '/^[[:space:]]*\//,$d' "$1" | grep -Eic "$active_mouse_pattern" || true
}

[[ $(active_mouse_count "$default_config") == 1 ]] ||
  fail "the shipped Limine config has exactly one active mouse directive"
grep -Fxq 'mouse: no' "$default_config" ||
  fail "the shipped Limine config disables mouse input"
pass "the shipped Limine config disables mouse input exactly once"

[[ -f $migration ]] || fail "the Limine mouse migration exists"
[[ $(grep -Fxc 'limine_conf=/boot/limine.conf' "$migration") == 1 ]] ||
  fail "the migration fixes one literal Limine config path"
[[ $(grep -Fxc 'source /usr/lib/limine/limine-mutex' "$migration") == 1 ]] ||
  fail "the migration sources the fixed Limine mutex library"
if grep -q 'OMARCHY_LIMINE_CONF' "$migration"; then
  fail "the migration does not accept a caller-controlled privileged path"
fi

limine_conf="$test_tmp/limine.conf"
migration_copy="$test_tmp/migration.sh"
stub_bin="$test_tmp/bin"
sudo_calls="$test_tmp/sudo.calls"
mutex_log="$test_tmp/mutex.log"
mutex_library="$test_tmp/limine-mutex"
mkdir -p "$stub_bin"

# Keep both privileged production paths fixed in the shipped migration. Retarget
# only a scratch copy so the test cannot touch the host's boot configuration.
sed \
  -e "s|^limine_conf=/boot/limine.conf$|limine_conf=$limine_conf|" \
  -e "s|^source /usr/lib/limine/limine-mutex$|source $mutex_library|" \
  "$migration" >"$migration_copy"

cat >"$mutex_library" <<'MUTEX'
mutex_lock() {
  [[ ${INSIDE_SUDO:-0} == 1 ]] || return 91
  printf 'lock\n' >>"$MUTEX_LOG"
  if [[ ${MUTEX_CREATE_CONF:-0} == 1 ]]; then
    cat >"$LIMINE_TEST_CONF" <<'EOF'
default_entry: 2

/Omarchy
  protocol: efi
EOF
    chmod 0640 "$LIMINE_TEST_CONF"
  fi
  if [[ ${MUTEX_INJECT_UPDATE:-0} == 1 ]]; then
    printf '# concurrent Limine update\n' >>"$LIMINE_TEST_CONF"
  fi
}

mutex_unlock() {
  if [[ ${REQUIRE_MOUSE_BEFORE_UNLOCK:-0} == 1 ]]; then
    grep -Fxq 'mouse: no' "$LIMINE_TEST_CONF" || return 92
    if [[ ${MUTEX_INJECT_UPDATE:-0} == 1 ]]; then
      grep -Fxq '# concurrent Limine update' "$LIMINE_TEST_CONF" || return 93
    fi
  fi
  printf 'unlock\n' >>"$MUTEX_LOG"
}
MUTEX

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash

printf '%s\n' "$*" >>"$SUDO_CALLS"
restore_unreadable=false
if [[ -e $LIMINE_TEST_CONF && $(stat -c '%a' "$LIMINE_TEST_CONF") == 0 ]]; then
  chmod 600 "$LIMINE_TEST_CONF"
  restore_unreadable=true
fi

set +e
INSIDE_SUDO=1 "$@"
status=$?
set -e

if [[ $restore_unreadable == true ]]; then
  chmod 000 "$LIMINE_TEST_CONF"
fi
exit "$status"
STUB
chmod +x "$stub_bin/sudo"

run_migration() {
  SUDO_CALLS="$sudo_calls" MUTEX_LOG="$mutex_log" \
    LIMINE_TEST_CONF="$limine_conf" \
    MUTEX_CREATE_CONF="${MUTEX_CREATE_CONF:-0}" \
    MUTEX_INJECT_UPDATE="${MUTEX_INJECT_UPDATE:-0}" \
    REQUIRE_MOUSE_BEFORE_UNLOCK="${REQUIRE_MOUSE_BEFORE_UNLOCK:-0}" \
    PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$migration_copy" >/dev/null
}

assert_only_mouse_line_added() {
  local original="$1"
  local without_inserted="$test_tmp/without-inserted"

  grep -vxF -e 'mouse: no' -e '# concurrent Limine update' \
    "$limine_conf" >"$without_inserted"
  cmp -s "$original" "$without_inserted" ||
    fail "the migration preserves existing Limine content"
}

assert_mutex_cycle() {
  [[ $(<"$mutex_log") == $'lock\nunlock' ]] ||
    fail "the migration holds the Limine mutex across its update" "$(<"$mutex_log")"
}

cat >"$limine_conf" <<'EOF'
# Keep this heading and spacing
timeout: 3
default_entry: 2

/Omarchy
  protocol: efi
  path: boot():/EFI/Linux/omarchy.efi
EOF
cp "$limine_conf" "$test_tmp/missing.original"
chmod 0640 "$limine_conf"
: >"$sudo_calls"
: >"$mutex_log"
MUTEX_INJECT_UPDATE=1 REQUIRE_MOUSE_BEFORE_UNLOCK=1 run_migration

[[ $(active_mouse_count "$limine_conf") == 1 ]] ||
  fail "the migration adds exactly one active mouse directive"
grep -Fxq 'mouse: no' "$limine_conf" ||
  fail "the migration disables mouse input when no active directive exists"
mouse_line=$(grep -nFx 'mouse: no' "$limine_conf" | cut -d: -f1)
entry_line=$(grep -n '^/' "$limine_conf" | head -n 1 | cut -d: -f1)
(( mouse_line < entry_line )) ||
  fail "the migration inserts the mouse directive before the first boot entry"
assert_only_mouse_line_added "$test_tmp/missing.original"
grep -Fxq '# concurrent Limine update' "$limine_conf" ||
  fail "the migration overwrites a Limine update made after locking"
[[ $(stat -c '%a' "$limine_conf") == 640 ]] ||
  fail "the migration changes the Limine config mode"
[[ -s $sudo_calls ]] || fail "the migration elevates its boot config update"
assert_mutex_cycle
pass "the migration updates Limine under its mutex without losing content or metadata"

cp "$limine_conf" "$test_tmp/after-first-run"
: >"$sudo_calls"
: >"$mutex_log"
run_migration
cmp -s "$test_tmp/after-first-run" "$limine_conf" ||
  fail "the migration changes Limine config on a second run"
[[ $(active_mouse_count "$limine_conf") == 1 ]] ||
  fail "the migration duplicates the mouse directive on a second run"
[[ $(stat -c '%a' "$limine_conf") == 640 ]] ||
  fail "the migration changes the Limine config mode on a second run"
if [[ -s $mutex_log ]]; then
  assert_mutex_cycle
fi
pass "the migration is idempotent"

cat >"$limine_conf" <<'EOF'
# mouse: yes
default_entry: 2

/Omarchy
  protocol: efi
EOF
cp "$limine_conf" "$test_tmp/commented.original"
: >"$sudo_calls"
: >"$mutex_log"
run_migration

grep -Fxq '# mouse: yes' "$limine_conf" ||
  fail "the migration removes a commented mouse example"
[[ $(active_mouse_count "$limine_conf") == 1 ]] ||
  fail "a commented directive prevents the migration from adding mouse: no"
assert_only_mouse_line_added "$test_tmp/commented.original"
assert_mutex_cycle
pass "the migration treats a commented mouse directive as inactive"

for explicit_directive in \
  'mouse: yes' \
  'mouse: no' \
  '   MoUsE:   YeS   # Keep my choice'; do
  cat >"$limine_conf" <<EOF
$explicit_directive
default_entry: 2

/Omarchy
  protocol: efi
EOF
  cp "$limine_conf" "$test_tmp/explicit.original"
  chmod 0620 "$limine_conf"
  : >"$sudo_calls"
  : >"$mutex_log"
  run_migration

  cmp -s "$test_tmp/explicit.original" "$limine_conf" ||
    fail "the migration changes the explicit directive: $explicit_directive"
  [[ $(stat -c '%a' "$limine_conf") == 620 ]] ||
    fail "the migration changes the mode for: $explicit_directive"
  if [[ -s $mutex_log ]]; then
    assert_mutex_cycle
  fi
done
pass "the migration preserves explicit mouse choices with varied case and whitespace"

{
  printf 'mouse: yes\n'
  for ((line = 0; line < 10000; line++)); do
    printf '# enough global content to outlive an early grep match\n'
  done
  printf '/Omarchy\n  protocol: efi\n'
} >"$limine_conf"
cp "$limine_conf" "$test_tmp/large-explicit.original"
: >"$sudo_calls"
: >"$mutex_log"
run_migration

cmp -s "$test_tmp/large-explicit.original" "$limine_conf" ||
  fail "the migration overrides an early explicit mouse choice in a large config"
[[ $(active_mouse_count "$limine_conf") == 1 ]] ||
  fail "the migration duplicates an early explicit mouse choice in a large config"
assert_mutex_cycle
pass "the migration preserves an early explicit mouse choice in a large config"

cat >"$limine_conf" <<'EOF'
mouse   : yes
default_entry: 2

/Omarchy
  protocol: efi
EOF
cp "$limine_conf" "$test_tmp/malformed.original"
: >"$sudo_calls"
: >"$mutex_log"
run_migration

grep -Fxq 'mouse   : yes' "$limine_conf" ||
  fail "the migration removes a malformed mouse directive"
[[ $(active_mouse_count "$limine_conf") == 1 ]] ||
  fail "a malformed mouse directive prevents the migration from adding mouse: no"
grep -Fxq 'mouse: no' "$limine_conf" ||
  fail "the migration leaves a malformed mouse directive as the only mouse setting"
assert_only_mouse_line_added "$test_tmp/malformed.original"
assert_mutex_cycle
pass "the migration repairs a mouse directive with whitespace before the colon"

cat >"$limine_conf" <<'EOF'
default_entry: 2

  /Omarchy
  protocol: efi
  mouse: yes
EOF
cp "$limine_conf" "$test_tmp/entry-local.original"
: >"$sudo_calls"
: >"$mutex_log"
run_migration

grep -Fxq '  mouse: yes' "$limine_conf" ||
  fail "the migration removes an entry-local mouse directive"
[[ $(active_mouse_count "$limine_conf") == 1 ]] ||
  fail "an entry-local mouse directive prevents the migration from adding a global mouse: no"
grep -Fxq 'mouse: no' "$limine_conf" ||
  fail "the migration leaves an entry-local mouse directive as the only mouse setting"
mouse_line=$(grep -nFx 'mouse: no' "$limine_conf" | cut -d: -f1)
entry_line=$(grep -n '^[[:space:]]*/' "$limine_conf" | head -n 1 | cut -d: -f1)
(( mouse_line < entry_line )) ||
  fail "the migration adds mouse: no inside a boot entry"
assert_only_mouse_line_added "$test_tmp/entry-local.original"
assert_mutex_cycle
pass "the migration adds a global setting when mouse is only configured inside an entry"

cat >"$limine_conf" <<'EOF'
default_entry: 2

/Omarchy
  protocol: efi
EOF
chmod 000 "$limine_conf"
: >"$sudo_calls"
: >"$mutex_log"
run_migration
[[ $(stat -c '%a' "$limine_conf") == 0 ]] ||
  fail "the migration changes an unreadable Limine config's mode"
chmod 600 "$limine_conf"
grep -Fxq 'mouse: no' "$limine_conf" ||
  fail "the migration cannot update a Limine config readable only with privilege"
assert_mutex_cycle
pass "the migration reads and updates a tightly permissioned config inside sudo"

rm -f "$limine_conf"
: >"$sudo_calls"
: >"$mutex_log"
MUTEX_CREATE_CONF=1 REQUIRE_MOUSE_BEFORE_UNLOCK=1 run_migration
[[ -f $limine_conf ]] ||
  fail "the migration misses a Limine config created while acquiring the mutex"
grep -Fxq 'mouse: no' "$limine_conf" ||
  fail "the migration leaves a newly appeared Limine config without mouse: no"
grep -Fxq '/Omarchy' "$limine_conf" ||
  fail "the migration overwrites the newly appeared Limine config"
[[ $(stat -c '%a' "$limine_conf") == 640 ]] ||
  fail "the migration changes a newly appeared Limine config's mode"
assert_mutex_cycle
pass "the migration checks for Limine config after acquiring the mutex"

rm -f "$limine_conf"
: >"$sudo_calls"
: >"$mutex_log"
run_migration
[[ ! -e $limine_conf ]] || fail "the migration creates a missing Limine config"
if [[ -s $mutex_log ]]; then
  assert_mutex_cycle
fi
pass "the migration leaves an absent Limine config alone"
