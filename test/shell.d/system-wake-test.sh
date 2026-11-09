#!/bin/bash

# omarchy-system-wake runs on every wake path (unlock and idle-wake). The bar
# clock ticks on a monotonic timer that does not advance during suspend, so
# after resume its label can stay stale for up to a minute (issue #7608). The
# wake script must nudge the clock over shell IPC to recompute immediately.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin" "$TMPDIR/home"
SHELL_LOG="$TMPDIR/omarchy-shell.log"
BRIGHTNESS_LOG="$TMPDIR/brightness.log"
CLAMSHELL_LOG="$TMPDIR/clamshell.log"
HYPRCTL_LOG="$TMPDIR/hyprctl.log"

cat >"$TMPDIR/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_SHELL_LOG"
SH

# The wake script restores display and keyboard brightness and re-applies the
# clamshell monitor layout. Stub those so the test only checks the clock nudge
# and never changes real displays or writes clamshell state under $HOME.
cat >"$TMPDIR/bin/omarchy-brightness-display" <<'SH'
#!/bin/bash
printf 'display %s\n' "$*" >>"$BRIGHTNESS_LOG"
SH

cat >"$TMPDIR/bin/omarchy-brightness-keyboard" <<'SH'
#!/bin/bash
printf 'keyboard %s\n' "$*" >>"$BRIGHTNESS_LOG"
SH

cat >"$TMPDIR/bin/omarchy-hyprland-monitor-clamshell" <<'SH'
#!/bin/bash
printf 'clamshell %s\n' "$*" >>"$CLAMSHELL_LOG"
SH

# Anything that still reaches hyprctl is a leak onto the real compositor.
# Record it and refuse, so a missing stub fails the test instead of moving
# the desktop's monitors.
cat >"$TMPDIR/bin/hyprctl" <<'SH'
#!/bin/bash
printf 'hyprctl %s\n' "$*" >>"$HYPRCTL_LOG"
exit 99
SH

chmod +x \
  "$TMPDIR/bin/omarchy-shell" \
  "$TMPDIR/bin/omarchy-brightness-display" \
  "$TMPDIR/bin/omarchy-brightness-keyboard" \
  "$TMPDIR/bin/omarchy-hyprland-monitor-clamshell" \
  "$TMPDIR/bin/hyprctl"

PATH="$TMPDIR/bin:$PATH" \
HOME="$TMPDIR/home" \
OMARCHY_SHELL_LOG="$SHELL_LOG" \
BRIGHTNESS_LOG="$BRIGHTNESS_LOG" \
CLAMSHELL_LOG="$CLAMSHELL_LOG" \
HYPRCTL_LOG="$HYPRCTL_LOG" \
  "$ROOT/bin/omarchy-system-wake" >/dev/null 2>&1 || true

grep -Fqx -- '-q omarchy.clock refresh' "$SHELL_LOG" \
  || fail "system wake refreshes the bar clock over shell IPC"
pass "system wake refreshes the bar clock over shell IPC"

grep -Fq -- 'display on' "$BRIGHTNESS_LOG" \
  || fail "system wake still restores the display"
pass "system wake still restores the display"

grep -Fqx -- 'clamshell ' "$CLAMSHELL_LOG" \
  || fail "system wake re-applies the clamshell layout through the stub"
pass "system wake re-applies the clamshell layout through the stub"

[[ ! -s $HYPRCTL_LOG ]] \
  || fail "system wake does not call hyprctl" "$(<"$HYPRCTL_LOG")"
pass "system wake does not call hyprctl"
