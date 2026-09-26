#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sleep_monitor="$ROOT/bin/omarchy-system-sleep-monitor"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
mock_omarchy="$tmpdir/omarchy"
lock_log="$tmpdir/lock-log"
layout_log="$tmpdir/layout-log"
wake_log="$tmpdir/wake-log"
resume_ready="$tmpdir/resume-ready"
prepare_seen="$tmpdir/prepare-seen"
mkdir -p "$mock_bin" "$mock_omarchy/bin"

cat >"$mock_bin/systemd-inhibit" <<'SH'
#!/bin/bash
while [[ $1 == --* ]]; do shift; done
exec "$@"
SH

cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash
case "${OMARCHY_SLEEP_EVENT_ROLE:-}" in
  resume)
    # Subscription exists before the inhibited listener. Queue the prepare edge,
    # then keep this exact producer alive until the lock path has handled it.
    touch "$RESUME_READY"
    printf '   boolean true\n'
    for _ in {1..200}; do
      [[ -e $PREPARE_SEEN ]] && break
      sleep 0.01
    done
    printf '   boolean false\n'
    exec sleep 30
    ;;
  prepare)
    for _ in {1..200}; do
      [[ -e $RESUME_READY ]] && break
      sleep 0.01
    done
    printf '   boolean true\n'
    exec sleep 30
    ;;
  *)
    exit 2
    ;;
esac
SH

cat >"$mock_omarchy/bin/omarchy-system-sleep-lock" <<'SH'
#!/bin/bash
echo locked >>"$LOCK_LOG"
touch "$PREPARE_SEEN"
SH

cat >"$mock_omarchy/bin/omarchy-hyprland-keyboard-layout" <<'SH'
#!/bin/bash
echo "$1" >>"$LAYOUT_LOG"
SH

cat >"$mock_omarchy/bin/omarchy-system-wake" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$WAKE_LOG"
SH

chmod +x "$mock_bin/systemd-inhibit" "$mock_bin/dbus-monitor"   "$mock_omarchy/bin/omarchy-system-sleep-lock"   "$mock_omarchy/bin/omarchy-hyprland-keyboard-layout"   "$mock_omarchy/bin/omarchy-system-wake"
ln -s "$sleep_monitor" "$mock_omarchy/bin/omarchy-system-sleep-monitor"

OMARCHY_PATH="$mock_omarchy" PATH="$mock_bin:$PATH"   LOCK_LOG="$lock_log" LAYOUT_LOG="$layout_log" WAKE_LOG="$wake_log"   RESUME_READY="$resume_ready" PREPARE_SEEN="$prepare_seen"   "$sleep_monitor"

[[ $(<"$lock_log") == "locked" ]] ||
  fail "full sleep cycle invokes the lock helper"
mapfile -t layout_calls <"$layout_log"
[[ ${layout_calls[0]:-} == save && ${layout_calls[1]:-} == restore && ${#layout_calls[@]} -eq 2 ]] ||
  fail "one subscription cycle saves before sleep and restores after resume" "$(cat "$layout_log")"
[[ $(<"$wake_log") == "--skip-keyboard" ]] ||
  fail "resume wakes the session without consuming the lock/idle keyboard receipt" "$(cat "$wake_log")"
pass "one prepare/resume subscription cycle owns both keyboard layout edges"

# The key regression: resume listener must have subscribed before the prepare
# listener can release the delay inhibitor.
[[ -e $resume_ready && -e $prepare_seen ]] ||
  fail "resume subscription was not established before prepare completed"
pass "resume subscription exists before the sleep inhibitor is released"

# Unit-mode edges remain independently testable.
: >"$layout_log"
printf '   boolean true\n' |   OMARCHY_PATH="$mock_omarchy" LAYOUT_LOG="$layout_log" LOCK_LOG="$lock_log"   "$sleep_monitor" --consume-prepare
[[ $(<"$layout_log") == save ]] || fail "prepare consumer saves layout"

: >"$layout_log"
: >"$wake_log"
printf '   boolean false\n' |   OMARCHY_PATH="$mock_omarchy" LAYOUT_LOG="$layout_log" WAKE_LOG="$wake_log"   "$sleep_monitor" --consume-resume
[[ $(<"$layout_log") == restore ]] || fail "resume consumer restores layout"
[[ $(<"$wake_log") == "--skip-keyboard" ]] || fail "resume consumer skips duplicate keyboard restore"
pass "prepare and resume consumers preserve their individual edge behavior"
