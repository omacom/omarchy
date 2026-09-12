#!/bin/bash
#
# The fingerprint driver migration only repairs a machine an earlier version of
# it left with fprintd and no libfprint; any installed driver is left alone.
# The real package helpers run over a stubbed pacman.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
for command in omarchy-pkg-add omarchy-pkg-missing omarchy-pkg-present; do
  copy_boundary_file "bin/$command"
done
ln -s ../bin/omarchy-pkg-missing "$SUDO_TEST_ROOT/mock/omarchy-pkg-missing"

migration="$ROOT/migrations/1785090473.sh"
scratch="$boundary_tmp"
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export PATH="$scratch/bin:$SUDO_TEST_ROOT/bin:$PATH"
export OMARCHY_SUDO_NO_UPDATE=1

# INSTALLED lists the installed package names, one per line; an install adds
# its packages to INSTALLED_LOG so omarchy-pkg-add's follow-up query sees them.
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Q)
    shift
    [[ ${1:-} != "--" ]] || shift
    grep -qx "$1" <<< "${INSTALLED:-}" || grep -qx "$1" "$INSTALLED_LOG"
    ;;
  -S)
    printf 'pacman %s\n' "$*" >> "$CALL_LOG"
    for arg in "$@"; do
      [[ $arg == -* ]] || printf '%s\n' "$arg" >> "$INSTALLED_LOG"
    done
    ;;
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG" ;;
esac
STUB
chmod +x "$scratch/bin/"*
rm "$SUDO_TEST_ROOT/mock/pacman" "$SUDO_TEST_ROOT/bin/pacman"
ln -s "$scratch/bin/pacman" "$SUDO_TEST_ROOT/mock/pacman"
ln -s "$scratch/bin/pacman" "$SUDO_TEST_ROOT/bin/pacman"
export INSTALLED_LOG="$scratch/installed"

run_migration() {
  : > "$CALL_LOG"
  : > "$INSTALLED_LOG"
  bash -euo pipefail "$migration" > /dev/null
}

INSTALLED='fprintd' run_migration
grep -qx 'pacman -S --noconfirm --needed -- libfprint-git' "$CALL_LOG" || fail "fprintd without a library gets libfprint-git"
pass "fprintd without a library gets libfprint-git"

INSTALLED=$'libfprint-git\nfprintd' run_migration
[[ ! -s $CALL_LOG ]] || fail "an installed libfprint-git is left alone" "$(<"$CALL_LOG")"
pass "an installed libfprint-git is left alone"

INSTALLED=$'libfprint\nfprintd' run_migration
[[ ! -s $CALL_LOG ]] || fail "an installed stock libfprint is left alone" "$(<"$CALL_LOG")"
pass "an installed stock libfprint is left alone"

INSTALLED='' run_migration
[[ ! -s $CALL_LOG ]] || fail "a machine without fprintd is left alone" "$(<"$CALL_LOG")"
pass "a machine without fprintd is left alone"
