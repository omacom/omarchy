#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"
STATE="$TMPDIR/rfkill-blocked"
SHELL_LOG="$TMPDIR/omarchy-shell-log"

cat >"$TMPDIR/bin/rfkill" <<'SH'
#!/bin/bash

case "${1:-}" in
  list)
    if [[ $(<"$RFKILL_STATE") == "blocked" ]]; then
      echo "0: wifi: Wireless LAN"
      echo "	Soft blocked: yes"
      echo "	Hard blocked: no"
      echo "1: bluetooth: Bluetooth"
      echo "	Soft blocked: yes"
      echo "	Hard blocked: no"
    else
      echo "0: wifi: Wireless LAN"
      echo "	Soft blocked: no"
      echo "	Hard blocked: no"
      echo "1: bluetooth: Bluetooth"
      echo "	Soft blocked: no"
      echo "	Hard blocked: no"
    fi
    ;;
  block)
    printf 'blocked' >"$RFKILL_STATE"
    ;;
  unblock)
    printf 'unblocked' >"$RFKILL_STATE"
    ;;
esac
SH

cat >"$TMPDIR/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_SHELL_LOG"
SH

chmod +x "$TMPDIR/bin/rfkill" "$TMPDIR/bin/omarchy-shell"

flight_mode_cli() {
  PATH="$TMPDIR/bin:$PATH" \
  RFKILL_STATE="$STATE" \
  OMARCHY_SHELL_LOG="$SHELL_LOG" \
    "$ROOT/bin/omarchy-toggle-flight-mode" "$@"
}

flight_mode_status() {
  printf '%s\n' "$1" >"$STATE"
  flight_mode_cli --status
}

[[ $(flight_mode_status unblocked | jq -r .enabled) == "false" ]] || fail "flight mode status reports unblocked radios as disabled"
pass "flight mode status reports unblocked radios as disabled"

[[ $(flight_mode_status blocked | jq -r .enabled) == "true" ]] || fail "flight mode status reports blocked radios as enabled"
pass "flight mode status reports blocked radios as enabled"

printf 'unblocked' >"$STATE"
: >"$SHELL_LOG"
flight_mode_cli >/dev/null
[[ $(<"$STATE") == "blocked" ]] || fail "flight mode toggle blocks all radios from off"
pass "flight mode toggle blocks all radios from off"

grep -Fqx -- '-q omarchy.flight-mode refresh' "$SHELL_LOG" || fail "flight mode toggle nudges the bar widget"
pass "flight mode toggle nudges the bar widget"

flight_mode_cli >/dev/null
[[ $(<"$STATE") == "unblocked" ]] || fail "flight mode toggle unblocks all radios from on"
pass "flight mode toggle unblocks all radios from on"
