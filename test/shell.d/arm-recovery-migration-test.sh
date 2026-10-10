#!/bin/bash
#
# The ARM recovery migration marks installed Limine recovery packages explicit
# so orphan cleanup keeps them, and leaves every other package alone.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789928586.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls" DEPS="$scratch/deps"
export OMARCHY_LIMINE_CONF="$scratch/limine"
export PATH="$scratch/bin:$PATH"

cat > "$scratch/bin/uname" <<'STUB'
#!/bin/bash
echo "${TEST_ARCH:-aarch64}"
STUB
cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
[[ -z ${FAIL_WRITE:-} ]] || exit 42
exec "$@"
STUB
# DEPS lists the packages installed as dependencies, one per line.
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Qqd)
    shift
    status=0
    for pkg in "$@"; do grep -qx "$pkg" "$DEPS" && echo "$pkg" || status=1; done
    exit $status
    ;;
  -D)
    printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    for pkg in "${@:3}"; do sed -i "/^$pkg\$/d" "$DEPS"; done
    ;;
  *) exit 99 ;;
esac
STUB
chmod +x "$scratch/bin/"*

run_migration() {
  : > "$CALL_LOG"
  bash -euo pipefail "$migration" > /dev/null
}

printf '%s\n' limine limine-mkinitcpio-hook limine-snapper-sync snapper unrelated > "$DEPS"

run_migration
[[ ! -s $CALL_LOG ]] || fail "ARM without a Limine configuration is left alone" "$(<"$CALL_LOG")"
pass "ARM without a Limine configuration is left alone"

touch "$OMARCHY_LIMINE_CONF"
TEST_ARCH=x86_64 run_migration
[[ ! -s $CALL_LOG ]] || fail "x86 keeps its package dependency policy" "$(<"$CALL_LOG")"
pass "x86 keeps its package dependency policy"

if FAIL_WRITE=1 run_migration; then fail "a failed package database write keeps the migration pending"; fi
grep -qx snapper "$DEPS" || fail "a failed package database write keeps the migration pending"
pass "a failed package database write keeps the migration pending"

run_migration
grep -qx 'pacman -D --asexplicit limine limine-mkinitcpio-hook limine-snapper-sync snapper' "$CALL_LOG" || fail "the recovery stack is marked explicit" "$(<"$CALL_LOG")"
[[ $(<"$DEPS") == unrelated ]] || fail "unrelated dependencies are untouched" "$(<"$DEPS")"
pass "the recovery stack is marked explicit and unrelated dependencies are untouched"

run_migration
[[ ! -s $CALL_LOG ]] || fail "explicit and absent packages are left alone on a repeat run" "$(<"$CALL_LOG")"
pass "explicit and absent packages are left alone on a repeat run"
