#!/bin/bash
#
# The power-profiles-daemon migration swaps the stock daemon for Omarchy's build
# in one pacman transaction, restarts it and reapplies the AC/battery profile.
# It leaves machines already on the Omarchy build, or without the daemon, alone.
# The real package helpers run over a stubbed pacman.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791554699.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
# INSTALLED lists what pacman -Q answers for, one name per line; like pacman,
# the Omarchy build also answers for the power-profiles-daemon it provides.
cat > "$scratch/bin/pacman" <<'STUB'
#!/bin/bash
case "$1" in
  -Q)
    if [[ $2 == "--" ]]; then
      shift 2
    else
      shift
    fi
    grep -qx -- "$1" <<< "${INSTALLED:-}"
    ;;
  *) printf 'pacman %s\n' "$*" >> "$CALL_LOG" ;;
esac
STUB
cat > "$scratch/bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >> "$CALL_LOG"
STUB
cat > "$scratch/bin/omarchy-powerprofiles-set" <<'STUB'
#!/bin/bash
printf 'omarchy-powerprofiles-set %s\n' "$*" >> "$CALL_LOG"
STUB
chmod +x "$scratch/bin/"*

run_migration() {
  : > "$CALL_LOG"
  bash -euo pipefail "$migration" > /dev/null
}

INSTALLED='power-profiles-daemon' run_migration
expected=$'pacman -S --noconfirm --ask 4 omarchy-power-profiles-daemon\nsystemctl try-restart power-profiles-daemon.service\nomarchy-powerprofiles-set autodetect'
[[ $(<"$CALL_LOG") == "$expected" ]] || fail "the stock daemon is swapped, restarted and its profile reapplied" "$(<"$CALL_LOG")"
pass "the stock daemon is swapped, restarted and its profile reapplied"

INSTALLED=$'omarchy-power-profiles-daemon\npower-profiles-daemon' run_migration
[[ ! -s $CALL_LOG ]] || fail "the Omarchy build is left alone" "$(<"$CALL_LOG")"
pass "the Omarchy build is left alone"

INSTALLED='' run_migration
[[ ! -s $CALL_LOG ]] || fail "a machine without the daemon is left alone" "$(<"$CALL_LOG")"
pass "a machine without the daemon is left alone"
