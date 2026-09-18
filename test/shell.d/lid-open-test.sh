#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

lid_open="$ROOT/bin/omarchy-system-lid-open"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"
: >"$call_log"

for command in omarchy-hyprland-monitor-clamshell omarchy-brightness-display; do
  cat >"$mock_bin/$command" <<SH
#!/bin/bash
echo "$command \$*" >>"\$CALL_LOG"
SH
done
chmod +x "$mock_bin"/*

CALL_LOG="$call_log" PATH="$mock_bin:$PATH" "$lid_open"
mapfile -t calls <"$call_log"

# The reconciler settles which outputs exist before anything asks the
# compositor to light them, which is the order the binding has always used.
[[ ${calls[0]:-} == "omarchy-hyprland-monitor-clamshell " ]] ||
  fail "lid open reconciles displays first" "first call was ${calls[0]:-none}"
pass "lid open reconciles displays first"

# Without this the laptop-only case has no path from the lock screen's idle
# blank back to a lit panel: the reconciler dispatches a DPMS enable only when
# it has just cleared a clamshell flag, and no such flag is ever written when
# there is no external monitor to go clamshell with.
[[ ${calls[1]:-} == "omarchy-brightness-display on" ]] ||
  fail "lid open wakes the panel" "second call was ${calls[1]:-none}"
pass "lid open wakes the panel"

(( ${#calls[@]} == 2 )) ||
  fail "lid open does no more than reconcile and wake" "${#calls[@]} calls"
pass "lid open does no more than reconcile and wake"
