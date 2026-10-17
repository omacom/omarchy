#!/bin/bash
#
# The ARM PipeWire migration installs gst-plugin-pipewire, swaps a jack2 that
# came in as a dependency for pipewire-jack, keeps a JACK server the owner
# installed on purpose, and leaves x86_64 alone.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1792274968.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls" INSTALLED="$scratch/installed" EXPLICIT="$scratch/explicit"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat > "$scratch/bin/uname" <<'STUB'
#!/bin/bash
echo "${TEST_ARCH:-aarch64}"
STUB
cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
cat > "$scratch/bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf 'omarchy-pkg-add %s\n' "$*" >> "$CALL_LOG"
STUB
# INSTALLED lists installed packages and EXPLICIT the explicitly installed ones.
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Q)
    shift
    [[ $1 == "--" ]] && shift
    grep -qx "$1" "$INSTALLED"
    ;;
  -Qqe) cat "$EXPLICIT" ;;
  -S) printf 'pacman %s\n' "$*" >> "$CALL_LOG" ;;
  *) exit 99 ;;
esac
STUB
chmod +x "$scratch/bin/"*

run_migration() {
  : > "$CALL_LOG"
  bash -euo pipefail "$migration" > /dev/null
}

swap='pacman -S --noconfirm --needed --ask=4 pipewire-jack'

printf '%s\n' jack2 obs-studio > "$INSTALLED"
printf '%s\n' obs-studio > "$EXPLICIT"

TEST_ARCH=x86_64 run_migration
[[ ! -s $CALL_LOG ]] || fail "x86_64 is left alone" "$(<"$CALL_LOG")"
pass "x86_64 is left alone"

run_migration
grep -Fxq 'omarchy-pkg-add gst-plugin-pipewire' "$CALL_LOG" || fail "ARM gets gst-plugin-pipewire" "$(<"$CALL_LOG")"
pass "ARM gets gst-plugin-pipewire"
grep -Fxq "$swap" "$CALL_LOG" || fail "a dependency jack2 is swapped for pipewire-jack in one transaction" "$(<"$CALL_LOG")"
pass "a dependency jack2 is swapped for pipewire-jack in one transaction"

printf '%s\n' jack2 > "$EXPLICIT"
run_migration
! grep -Fq 'pipewire-jack' "$CALL_LOG" || fail "an explicitly installed jack2 is kept" "$(<"$CALL_LOG")"
pass "an explicitly installed jack2 is kept"

printf '%s\n' jack > "$EXPLICIT"
run_migration
! grep -Fq 'pipewire-jack' "$CALL_LOG" || fail "an explicitly installed jack is kept" "$(<"$CALL_LOG")"
pass "an explicitly installed jack is kept"

printf '%s\n' pipewire-jack > "$INSTALLED"
: > "$EXPLICIT"
run_migration
! grep -Fq "$swap" "$CALL_LOG" || fail "an install that already has pipewire-jack is not touched again" "$(<"$CALL_LOG")"
pass "an install that already has pipewire-jack is not touched again"

: > "$INSTALLED"
run_migration
grep -Fxq "$swap" "$CALL_LOG" || fail "ARM without any JACK gets pipewire-jack" "$(<"$CALL_LOG")"
pass "ARM without any JACK gets pipewire-jack"
