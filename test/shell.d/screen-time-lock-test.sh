#!/bin/bash
#
# The daemon under its own clock, with a fake session: it counts an active
# session down, warns once per threshold, waits out the grace, and locks. A
# grant during the grace cancels the lock. The lock goes through a stand-in
# command, never a real loginctl, so the tester keeps their screen.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command openssl

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

export OMARCHY_SCREEN_TIME_ETC="$tmp_dir/etc"
export OMARCHY_SCREEN_TIME_STATE="$tmp_dir/state"
export OMARCHY_SCREEN_TIME_RUN="$tmp_dir/run"
mkdir -p "$OMARCHY_SCREEN_TIME_ETC" "$OMARCHY_SCREEN_TIME_STATE" "$OMARCHY_SCREEN_TIME_RUN"

# A fake logind and desktop on PATH: the session is always this account,
# active and unlocked, and the notification and the shell lock probe are no-ops.
# logind's LockedHint says "yes" throughout: the session itself sets that hint,
# so the account could set it too, and the daemon has to count regardless.
fake="$tmp_dir/fake"
mkdir -p "$fake"
me=$(id -un)
my_uid=$(id -u)
cat >"$fake/loginctl" <<EOF
#!/bin/bash
case "\$1" in
  show-user) echo "7" ;;
  show-session) printf 'Type=wayland\nClass=user\nActive=yes\nState=active\nLockedHint=yes\n' ;;
esac
EOF
cat >"$fake/omarchy-notification-send" <<EOF
#!/bin/bash
echo "\$*" >>"$tmp_dir/notify.log"
EOF
cat >"$fake/omarchy-shell" <<'EOF'
#!/bin/bash
echo false   # the shell's lock probe: not locked
EOF
# The lock stand-in: record it, and flip the fake session to locked so the
# daemon sees the lock took, the way a real lock would.
lock_log="$tmp_dir/lock.log"
cat >"$fake/lock-stub" <<EOF
#!/bin/bash
echo "locked \$1 \$2" >>"$lock_log"
EOF
# The stand-in for ending the session, so the test never touches a real one.
cat >"$fake/terminate-stub" <<EOF
#!/bin/bash
echo "terminated \$2" >>"$tmp_dir/terminate.log"
EOF
chmod +x "$fake"/loginctl "$fake"/omarchy-notification-send "$fake"/omarchy-shell "$fake"/lock-stub "$fake"/terminate-stub

export PATH="$fake:$ROOT/bin:$PATH"
export OMARCHY_SCREEN_TIME_TICK=1
export OMARCHY_SCREEN_TIME_LOCK_COMMAND="$fake/lock-stub"
export OMARCHY_SCREEN_TIME_TERMINATE_COMMAND="$fake/terminate-stub"
export OMARCHY_SCREEN_TIME_PATH="$fake:/usr/bin:/bin"
source omarchy-screen-time-lib

# A one-minute budget every day, warn at one minute, three-second grace.
st_jq -n --arg me "$me" '
  default_config | .active_profile = "kids" |
  .profiles = {kids: (default_profile
    | .name = "Kids"
    | .budget_minutes = {mon:1,tue:1,wed:1,thu:1,fri:1,sat:1,sun:1}
    | .warn_minutes = [1]
    | .grace_seconds = 3
    | .relock_seconds = 3)} |
  .users = {($me): {profile: "kids"}}' | st_save_config

status_field() { jq -r "$1" "$OMARCHY_SCREEN_TIME_RUN/$my_uid/status.json"; }

# Run the daemon in the background against the fake machine.
bash "$ROOT/bin/omarchy-screen-timed" >"$tmp_dir/daemon.log" 2>&1 &
daemon=$!
cleanup() { kill "$daemon" 2>/dev/null; wait "$daemon" 2>/dev/null; rm -rf "$tmp_dir"; }
trap cleanup EXIT

# Wait for the first publish.
for _ in $(seq 1 20); do
  [[ -f "$OMARCHY_SCREEN_TIME_RUN/$my_uid/status.json" ]] && break
  sleep 0.5
done
[[ -f "$OMARCHY_SCREEN_TIME_RUN/$my_uid/status.json" ]] || fail "the daemon publishes a status for the managed account"
[[ $(status_field .phase) == running ]] || fail "an active session counts down" "phase: $(status_field .phase)"
[[ $(status_field .locked) == false ]] || fail "logind's LockedHint, which the session sets itself, does not count as a lock"
pass "the daemon counts an active session down, whatever LockedHint says"

# Push the day to the edge of empty and let the tick find it.
day_file="$OMARCHY_SCREEN_TIME_STATE/users/$my_uid/$(st_day_key).json"
st_with_lock true   # take and drop the lock so we do not race a tick's write
jq '.spent_seconds = 59' "$day_file" >"$tmp_dir/day.json" && mv "$tmp_dir/day.json" "$day_file"

# Within a couple of ticks it is empty and a lock is pending, not yet fired.
for _ in $(seq 1 6); do
  [[ $(status_field .phase) == empty ]] && break
  sleep 1
done
[[ $(status_field .phase) == empty ]] || fail "a spent budget reads as empty" "phase: $(status_field .phase)"
[[ $(status_field '.lock_in_seconds // "null"') != null ]] || fail "an empty budget starts the lock countdown"
[[ ! -s $lock_log ]] || fail "the lock waits out the grace before it fires"
pass "an empty budget warns and counts down to the lock"

grep -q "1 minute left" "$tmp_dir/notify.log" || fail "the last minute is warned once"
pass "the warning fires at the one-minute threshold"

# A grant during the grace cancels the pending lock: add a minute and the
# countdown clears without the screen ever locking.
printf '\n' >/dev/null   # no PIN yet, so grant through the parent path (root)
st_with_lock bash -c '
  day="'"$day_file"'"
  jq ".granted_seconds += 120 | .spent_seconds = 0" "$day" >"'"$tmp_dir"'/g.json" && mv "'"$tmp_dir"'/g.json" "$day"
  rt="'"$OMARCHY_SCREEN_TIME_RUN"'/'"$my_uid"'/runtime.json"
  [[ -f $rt ]] && jq ".lock_after = null | .blocked_since = null | .lock_count = 0" "$rt" >"'"$tmp_dir"'/rt.json" && mv "'"$tmp_dir"'/rt.json" "$rt"
'
for _ in $(seq 1 5); do
  [[ $(status_field .phase) == running ]] && break
  sleep 1
done
[[ $(status_field .phase) == running ]] || fail "time added during grace puts the day back to running" "phase: $(status_field .phase)"
[[ ! -s $lock_log ]] || fail "the screen never locked once time was added in time"
pass "a grant during the grace cancels the lock"

# Now let it run out with no rescue: the grace passes and the lock fires,
# through the stand-in and recorded.
jq '.granted_seconds = 0 | .spent_seconds = 300' "$day_file" >"$tmp_dir/day.json" && mv "$tmp_dir/day.json" "$day_file"
for _ in $(seq 1 10); do
  [[ -s $lock_log ]] && break
  sleep 1
done
[[ -s $lock_log ]] || fail "a budget that stays empty past the grace locks the screen" "daemon: $(cat "$tmp_dir/daemon.log")"
grep -q "^locked " "$lock_log" || fail "the lock goes through the configured command"
# The daemon runs the lock command first and writes the day after, so the
# ledger can trail the lock log by a moment on a busy machine.
ledger_kind() { jq -r '.ledger[-1].kind' "$day_file" 2>/dev/null; }
for _ in $(seq 1 20); do
  [[ $(ledger_kind) == locked ]] && break
  sleep 0.5
done
[[ $(ledger_kind) == locked ]] || fail "the lock is written to the day's ledger"
pass "an empty budget past the grace locks the screen and records it"

# A shell that will not lock (frozen, killed, replaced) is the one way round
# the lock the account has. The lock stand-in now fails every time; after a
# few retries logind ends the session, through the fake loginctl here.
: >"$lock_log"
cat >"$fake/lock-stub" <<EOF
#!/bin/bash
echo "failed \$1 \$2" >>"$lock_log"
exit 1
EOF
st_with_lock bash -c '
  rt="'"$OMARCHY_SCREEN_TIME_RUN"'/'"$my_uid"'/runtime.json"
  jq ".lock_after = null | .lock_count = 0 | .last_lock_ok = false | .lock_failures = 0 | .blocked_since = null" "$rt" >"'"$tmp_dir"'/rt.json" && mv "'"$tmp_dir"'/rt.json" "$rt"
'
for _ in $(seq 1 30); do
  [[ -s $tmp_dir/terminate.log ]] && break
  sleep 1
done
[[ -s $tmp_dir/terminate.log ]] || fail "a lock that keeps failing ends in the session being terminated" "locks: $(cat "$lock_log"; cat "$tmp_dir/daemon.log")"
(( $(grep -c '^failed ' "$lock_log") >= 3 )) || fail "the session is only ended after several failed locks" "locks: $(cat "$lock_log")"
grep -q '^terminated 7$' "$tmp_dir/terminate.log" || fail "the session that is ended is the account's own"
for _ in $(seq 1 20); do
  [[ $(ledger_kind) == terminated ]] && break
  sleep 0.5
done
[[ $(ledger_kind) == terminated ]] || fail "ending the session is written to the day's ledger"
pass "a shell that keeps failing to lock costs the account its session"
