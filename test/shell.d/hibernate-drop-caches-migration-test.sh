#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

shipped_migration="$ROOT/migrations/1790692395.sh"
[[ -f $shipped_migration ]] || fail "the hibernate drop-caches migration exists at $shipped_migration"
pass "the hibernate drop-caches migration exists"

mapfile -t drop_caches_migrations < <(grep -RIlE 'system-sleep/drop-caches' "$ROOT/migrations")
(( ${#drop_caches_migrations[@]} == 1 )) && [[ ${drop_caches_migrations[0]} == "$shipped_migration" ]] ||
  fail "one migration exclusively owns the drop-caches hook path" "${drop_caches_migrations[*]}"
pass "one migration exclusively owns the drop-caches hook path"

# Installed by setup for new machines, by the migration for machines that were
# configured before it existed, and removed by hibernation removal. One place
# per direction: a fourth would be a lifecycle that drifts out of step, and a
# missing removal leaves the hook behind after hibernation is gone.
mapfile -t hook_owners < <(grep -RIl '/usr/lib/systemd/system-sleep/drop-caches' \
  "$ROOT/bin" "$ROOT/migrations" | sed "s|^$ROOT/||" | sort)
[[ ${hook_owners[*]} == "bin/omarchy-hibernation-remove bin/omarchy-hibernation-setup migrations/1790692395.sh" ]] ||
  fail "setup, the migration and hibernation removal are the hook's only owners" "${hook_owners[*]}"
pass "the hook has one owner per direction"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"

# sudo runs the real command, so the install lands in the redirected hook path.
cat >"$test_dir/bin/sudo" <<'STUB'
#!/bin/bash

printf 'sudo %s\n' "$*" >>"$CALLS"
exec "$@"
STUB

# The migration has to name the privileged installer by absolute path:
# resolving install through PATH would let the caller choose what runs as root.
cat >"$test_dir/bin/install" <<'STUB'
#!/bin/bash

echo "migration resolved install through PATH" >&2
exit 97
STUB

chmod +x "$test_dir/bin/"*

export CALLS="$test_dir/calls"

resume_conf="$test_dir/mkinitcpio.d/omarchy_resume.conf"
hook="$test_dir/system-sleep/drop-caches"
omarchy_path="$test_dir/omarchy"
shipped_hook="$omarchy_path/default/systemd/system-sleep/drop-caches"
migration="$test_dir/migration.sh"

# These paths become operands to a privileged command. Keep them fixed in the
# shipped migration and retarget a scratch copy for the unprivileged test; an
# environment override would let the caller choose what root writes.
grep -Fxq 'resume_conf=/etc/mkinitcpio.conf.d/omarchy_resume.conf' "$shipped_migration" ||
  fail "the production resume marker path is a fixed literal"
grep -Fxq 'hook=/usr/lib/systemd/system-sleep/drop-caches' "$shipped_migration" ||
  fail "the production hook path is a fixed literal"
if grep -q 'OMARCHY_DROP_CACHES' "$shipped_migration"; then
  fail "the migration does not accept caller-controlled privileged paths"
fi

sed \
  -e "s|^resume_conf=/etc/mkinitcpio.conf.d/omarchy_resume.conf$|resume_conf=$resume_conf|" \
  -e "s|^hook=/usr/lib/systemd/system-sleep/drop-caches$|hook=$hook|" \
  "$shipped_migration" >"$migration"
pass "migration keeps privileged production paths caller-independent"

reset_machine() {
  rm -rf "$test_dir/mkinitcpio.d" "$test_dir/system-sleep" "$omarchy_path"
  mkdir -p "$(dirname "$resume_conf")" "$(dirname "$shipped_hook")"
  printf 'HOOKS+=(resume)\n' >"$resume_conf"
  cat >"$shipped_hook" <<'HOOK'
#!/bin/bash

echo 3 > /proc/sys/vm/drop_caches
HOOK
}

run_migration() {
  : >"$CALLS"

  OMARCHY_PATH="$omarchy_path" \
    PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
}

# The machine this migration exists for: set up when the resume marker alone
# meant "already done", so setup returns before installing the hook.
reset_machine
run_migration
[[ -f $hook ]] || fail "migration installs the hook on an already configured machine" "$(cat "$CALLS")"
cmp -s "$shipped_hook" "$hook" || fail "migration installs the shipped hook unchanged"
[[ $(stat -c '%a' "$hook") == "755" ]] || fail "migration installs the hook mode 0755"
grep -q '^sudo /usr/bin/install -Dm0755 ' "$CALLS" ||
  fail "migration installs through the absolute privileged installer" "$(cat "$CALLS")"
pass "migration installs the hook on a machine that already hibernates"

# Running again changes nothing and asks for no privilege.
before=$(sha256sum "$hook")
run_migration
[[ $(sha256sum "$hook") == "$before" ]] || fail "migration rewrites an installed hook"
[[ ! -s $CALLS ]] || fail "migration installs a second time" "$(cat "$CALLS")"
pass "migration is idempotent once the hook is installed"

# A hook somebody else put there is not this migration's to replace.
reset_machine
mkdir -p "$(dirname "$hook")"
printf '#!/bin/bash\n\n# hand edited\n' >"$hook"
before=$(sha256sum "$hook")
run_migration
[[ $(sha256sum "$hook") == "$before" ]] || fail "migration overwrites an existing hook" "$(cat "$CALLS")"
[[ ! -s $CALLS ]] || fail "migration acts when a hook already exists" "$(cat "$CALLS")"
pass "migration leaves an existing hook alone"

# Without the resume marker the hook would never run, so it stays absent.
reset_machine
rm -f "$resume_conf"
run_migration
[[ ! -e $hook ]] || fail "migration installs a hibernate hook without hibernation"
[[ ! -s $CALLS ]] || fail "migration acts on a machine without hibernation" "$(cat "$CALLS")"
pass "migration leaves machines without hibernation alone"

# A resume marker that is present but empty is not a configured machine: the
# same literal check omarchy-hibernation-setup uses decides this.
reset_machine
printf '' >"$resume_conf"
run_migration
[[ ! -e $hook ]] || fail "migration treats an empty resume file as hibernation"
[[ ! -s $CALLS ]] || fail "migration acts on an empty resume file" "$(cat "$CALLS")"
pass "migration requires the resume hook line, not just the file"
