#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Regression test for #11508: stopping screen recording must be single-flight,
# and an empty recording filename must not produce a duplicate toast or a
# broken "-preview.png" thumbnail. The race involves SIGKILL timing between the
# panel's Process teardown and the script's EXIT trap, which cannot be asserted
# meaningfully from a test harness, so this suite pins the mechanics statically
# the way the other capture tests assert source contents: the flock guard, the
# empty-filename bail-out, and the lock release on every exit path.

recording_script="$ROOT/bin/omarchy-capture-screenrecording"

# The stop path takes the flock before signaling the recorder, so a second
# stop launched mid-drain returns instead of racing the first over the
# recording file and its preview.
if ! grep -q 'exec 9>/tmp/omarchy-screenrecord.lock' "$recording_script"; then
  fail "screen recording stop takes the lock before doing anything"
fi
if ! grep -q 'flock -n 9' "$recording_script"; then
  fail "screen recording stop fails to acquire the lock non-blockingly"
fi
pass "screen recording stop is single-flight via flock"

# Skipping is a silent success: the caller that lost the race must not print
# an error or post a notification about a recording another stop is finishing.
if ! grep -q 'if ! flock -n 9; then' "$recording_script"; then
  fail "screen recording stop handles losing the lock race"
fi
lock_block=$(sed -n '/if ! flock -n 9; then/,/^  fi/p' "$recording_script")
if ! grep -q 'return 0' <<<"$lock_block"; then
  fail "screen recording stop returns quietly when the lock is held"
fi
pass "screen recording stop returns quietly when the lock is held"

# The shell teardown can SIGKILL the first stop before its trap runs, so a
# later stop can find the recording file already consumed. An empty read must
# bail out before finalize_recording and before any notification, or the toast
# shows "-preview.png" as its image (the reported broken thumbnail).
if ! grep -q 'If another stop already consumed the recording file' "$recording_script"; then
  fail "screen recording stop documents the consumed-file case"
fi
if ! grep -q 'if \[\[ -z \$filename \]\]; then' "$recording_script"; then
  fail "screen recording stop checks for an empty recording filename"
fi
empty_block=$(sed -n '/If another stop already consumed the recording file/,/fi$/p' "$recording_script")
if ! grep -q 'finalize_recording' <<<"$empty_block"; then
  # The block must skip finalize_recording, so it must not appear inside it.
  :
else
  fail "screen recording stop skips finalize for a consumed recording"
fi
if grep -q 'omarchy-notification-send' <<<"$empty_block"; then
  fail "screen recording stop posts no toast for a consumed recording"
fi
pass "screen recording stop skips finalize and toast for a consumed recording"

# The lock file descriptor must be closed on every exit path, or a leaked
# descriptor keeps the lock held after the script dies mid-stop.
lock_closes=$(grep -c 'exec 9>&-' "$recording_script")
if (( lock_closes < 3 )); then
  fail "screen recording stop releases the lock on every exit path" "found $lock_closes releases, expected at least 3 (lost race, consumed file, normal end)"
fi
pass "screen recording stop releases the lock on every exit path"

# The RETURN trap covers returns the explicit releases do not, keeping a
# stop that bails early (recorder gone before the wait loop) from leaking.
if ! grep -q "trap 'exec 9>&-' RETURN" "$recording_script"; then
  fail "screen recording stop reaps the lock on early return"
fi
pass "screen recording stop reaps the lock on early return"

# Guard the guard: the lock must be taken before the recorder is signaled,
# or the second stop can pass the guard while the first is already draining.
script_text=$(cat "$recording_script")
lock_line=$(grep -n 'exec 9>/tmp/omarchy-screenrecord.lock' "$recording_script" | head -n1 | cut -d: -f1)
signal_line=$(grep -n 'pkill -SIGINT -f "\^gpu-screen-recorder"' "$recording_script" | head -n1 | cut -d: -f1)
if (( lock_line >= signal_line )); then
  fail "screen recording stop takes the lock before signaling the recorder"
fi
pass "screen recording stop takes the lock before signaling the recorder"
