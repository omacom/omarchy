#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home" "$test_tmp/omarchy/migrations"
migration=1786894219.sh
cp "$ROOT/migrations/$migration" "$test_tmp/omarchy/migrations/"
export CALL_LOG="$test_tmp/calls"
export HOME="$test_tmp/home" OMARCHY_PATH="$test_tmp/omarchy"
export OMARCHY_MIGRATION_STATE="$test_tmp/markers"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
exec "$@"
SH

cat >"$test_tmp/bin/systemd-tmpfiles" <<'SH'
#!/bin/bash
exit "${TMPFILES_STATUS:-0}"
SH

cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CALL_LOG"
case "$*" in
  daemon-reload) exit "${RELOAD_STATUS:-0}" ;;
  '--user is-active --quiet omarchy-crash-watch.service') exit "${ACTIVE_STATUS:-0}" ;;
  '--user restart omarchy-crash-watch.service') exit "${RESTART_STATUS:-0}" ;;
  *) exit 1 ;;
esac
SH

cat >"$test_tmp/bin/omarchy-notification-dismiss" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$test_tmp/bin"/*

run_migration() {
  : >"$CALL_LOG"
  bash -euo pipefail "$ROOT/migrations/$migration" >"$test_tmp/output" 2>&1
}

run_migration
grep -Fxq 'sudo systemd-tmpfiles --create /etc/tmpfiles.d/omarchy-crash-events.conf' "$CALL_LOG" ||
  fail "the migration does not create the directory before restarting the watcher"
grep -Fxq 'sudo systemctl daemon-reload' "$CALL_LOG" ||
  fail "the migration does not load the coredump completion hook"
grep -Fxq 'systemctl --user restart omarchy-crash-watch.service' "$CALL_LOG" ||
  fail "an active watcher is not restarted"
pass "migration creates the event directory, reloads system units, and restarts an active watcher"

ACTIVE_STATUS=3 run_migration
! grep -Fq -- '--user restart' "$CALL_LOG" || fail "an inactive watcher is started"
pass "migration leaves an inactive watcher stopped"

flag="$HOME/.local/state/omarchy/toggles/crash-capture-off"
mkdir -p "${flag%/*}"
touch "$flag"
run_migration
! grep -Fq -- 'systemctl --user' "$CALL_LOG" || fail "a disabled watcher is touched"
rm "$flag"
pass "migration honors the user's crash capture toggle"

for failing_step in TMPFILES_STATUS RELOAD_STATUS; do
  status=0
  env "$failing_step=1" bash -euo pipefail "$ROOT/migrations/$migration" \
    >"$test_tmp/output" 2>&1 || status=$?
  (( status != 0 )) || fail "a failed $failing_step is hidden"
done
pass "migration propagates event setup failures"

# Use the real runner: failure must leave no marker, and a successful retry
# must finish the same migration rather than treating the first run as done.
status=0
RESTART_STATUS=1 timeout 5 "$ROOT/bin/omarchy-migrate" \
  >"$test_tmp/output" 2>&1 || status=$?
(( status != 0 && status != 124 )) || fail "a failed restart does not fail the migration runner"
[[ ! -e $OMARCHY_MIGRATION_STATE/$migration ]] || fail "a failed restart is marked complete"
pass "a failed restart leaves the migration pending"

timeout 5 "$ROOT/bin/omarchy-migrate" >"$test_tmp/output" 2>&1
[[ -f $OMARCHY_MIGRATION_STATE/$migration ]] || fail "a successful retry is not marked complete"
pass "the pending migration succeeds on retry"
