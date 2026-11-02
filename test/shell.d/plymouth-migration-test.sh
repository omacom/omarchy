#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

shipped="$ROOT/migrations/1789203771.sh"
[[ -f $shipped ]] || fail "the plymouth clamp migration exists at $shipped"

# The marker is an operand to a privileged install. Keep it a fixed literal in
# the shipped migration and retarget a scratch copy for the unprivileged test;
# an environment override would let the caller choose where root writes.
grep -Fxq 'rebuild_marker=/var/lib/omarchy/migrations/1789203771' "$shipped" ||
  fail "the production rebuild marker is a fixed literal"
if grep -q 'OMARCHY_PLYMOUTH_CLAMP_REBUILD_MARKER' "$shipped"; then
  fail "the migration does not accept a caller-controlled marker path"
fi
pass "migration keeps the rebuild marker caller-independent"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/state"

marker="$scratch/state/1789203771"
migration="$scratch/migration.sh"

sed "s|^rebuild_marker=/var/lib/omarchy/migrations/1789203771$|rebuild_marker=$marker|" \
  "$shipped" >"$migration"

# sudo runs the real command, so the marker lands beside the scratch state.
cat >"$scratch/bin/sudo" <<'STUB'
#!/bin/bash

printf 'sudo %s\n' "$*" >>"$CALLS"
case "${1:-}" in
  limine-mkinitcpio | mkinitcpio | install) exec "$@" ;;
  *) exit 99 ;;
esac
STUB

cat >"$scratch/bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash

[[ ${REBUILD_FAIL:-0} == "0" ]]
STUB

cat >"$scratch/bin/mkinitcpio" <<'STUB'
#!/bin/bash

[[ ${REBUILD_FAIL:-0} == "0" ]]
STUB

# The migration only asks about limine-mkinitcpio; the test decides the answer
# so the fallback case does not depend on the host's boot tooling.
cat >"$scratch/bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash

[[ $1 == "limine-mkinitcpio" && -n ${HAVE_LIMINE:-} ]]
STUB

chmod +x "$scratch/bin/"*

export CALLS="$scratch/calls"
export HAVE_LIMINE=1

run_migration() {
  : >"$CALLS"
  PATH="$scratch/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
}

run_migration
grep -qx 'sudo limine-mkinitcpio' "$CALLS" || fail "first run rebuilds the boot image" "$(cat "$CALLS")"
grep -qx "sudo install -Dm644 /dev/null $marker" "$CALLS" ||
  fail "first run records the machine-wide marker" "$(cat "$CALLS")"
[[ -f $marker ]] || fail "first run leaves the completion marker"
pass "first run rebuilds the boot image and records the marker"

run_migration
[[ ! -s $CALLS ]] || fail "a second user's run touches nothing" "$(cat "$CALLS")"
pass "a second user's run is a no-op"

rm -f "$marker"

set +e
REBUILD_FAIL=1 run_migration
status=$?
set -e

(( status != 0 )) || fail "migration fails when the rebuild fails"
[[ ! -e $marker ]] || fail "a failed rebuild stays pending"
pass "a failed rebuild stays pending"

run_migration
[[ -f $marker ]] || fail "a retry records completion"
pass "a retry completes after a failed rebuild"

rm -f "$marker"
unset HAVE_LIMINE
mkdir -p "$scratch/bin-nolimine"
cp "$scratch/bin/sudo" "$scratch/bin/mkinitcpio" "$scratch/bin/omarchy-cmd-present" "$scratch/bin-nolimine/"
chmod +x "$scratch/bin-nolimine/"*

: >"$CALLS"
PATH="$scratch/bin-nolimine:$PATH" bash -euo pipefail "$migration" >/dev/null
grep -qx 'sudo mkinitcpio -P' "$CALLS" || fail "without limine the migration falls back to mkinitcpio" "$(cat "$CALLS")"
[[ -f $marker ]] || fail "the fallback records completion"
pass "without limine the migration rebuilds with mkinitcpio -P"
