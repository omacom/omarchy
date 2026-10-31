#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_root="$test_tmp/omarchy"
test_home="$test_tmp/home"
stub_bin="$test_tmp/bin"
mkdir -p "$test_root/migrations" "$test_home" "$stub_bin"

cat >"$stub_bin/omarchy-notification-dismiss" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >>"$TEST_DISMISSALS"
SH
# omarchy-migrate takes the update lock; here it runs as if it already held it,
# and never touches the machine's real one.
cat >"$stub_bin/omarchy-update-lock" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$stub_bin/omarchy-notification-dismiss" "$stub_bin/omarchy-update-lock"
export OMARCHY_MIGRATION_RECORD="$test_tmp/no-record"

cat >"$test_root/migrations/100-first.sh" <<'SH'
[[ $OMARCHY_PATH == "$TEST_EXPECTED_OMARCHY_PATH" ]]
echo first >>"$TEST_CALLS"
SH
cat >"$test_root/migrations/200-second.sh" <<'SH'
[[ $OMARCHY_PATH == "$TEST_EXPECTED_OMARCHY_PATH" ]]
echo second >>"$TEST_CALLS"
SH

calls="$test_tmp/calls"
dismissals="$test_tmp/dismissals"

# $1 is HOME, $2 is OMARCHY_PATH; the rest are omarchy-migrate's arguments.
run_migrate() {
  local home="$1" root="$2"
  shift 2
  HOME="$home" \
  OMARCHY_PATH="$root" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  TEST_EXPECTED_OMARCHY_PATH="$root" \
  TEST_CALLS="${TEST_CALLS:-$calls}" \
  TEST_DISMISSALS="$dismissals" \
    "$ROOT/bin/omarchy-migrate" "$@"
}

if ! run_migrate "$test_home" "$test_root" --pending >"$test_tmp/pending.out"; then
  fail "migration runner reports pending migrations before state exists"
fi
grep -q '^100-first\.sh$' "$test_tmp/pending.out" || fail "migration runner lists first pending migration filename"
grep -q '^200-second\.sh$' "$test_tmp/pending.out" || fail "migration runner lists second pending migration filename"
pass "migration runner detects pending migrations"

run_migrate "$test_home" "$test_root" >"$test_tmp/first-run.out"
[[ $(sed -n '1p' "$calls") == "first" ]] || fail "migration runner runs first migration"
[[ $(sed -n '2p' "$calls") == "second" ]] || fail "migration runner runs second migration"
[[ -f $test_home/.local/state/omarchy/migrations/100-first.sh ]] || fail "migration runner records first migration marker"
[[ -f $test_home/.local/state/omarchy/migrations/200-second.sh ]] || fail "migration runner records second migration marker"
pass "migration runner runs all migrations"

grep -Fx 'Omarchy Migrations' "$dismissals" >/dev/null || fail "migration runner dismisses migration notifications"
pass "migration runner clears completed migration notifications"

run_migrate "$test_home" "$test_root" >"$test_tmp/second-run.out"
(( $(wc -l <"$calls") == 2 )) || fail "migration runner skips completed migrations"
pass "migration runner skips completed migrations"

if run_migrate "$test_home" "$test_root" --pending >"$test_tmp/not-pending.out"; then
  fail "migration runner reports no pending migrations after state exists"
fi
[[ ! -s $test_tmp/not-pending.out ]] || fail "migration runner --pending stays quiet without pending migrations"
pass "migration runner detects no pending migrations"

failure_root="$test_tmp/failure-omarchy"
failure_home="$test_tmp/failure-home"
mkdir -p "$failure_root/migrations" "$failure_home"

cat >"$failure_root/migrations/500-fail.sh" <<'SH'
echo before-fail >>"$TEST_CALLS"
false
echo after-fail >>"$TEST_CALLS"
SH

set +e
run_migrate "$failure_home" "$failure_root" >"$test_tmp/failure.out" 2>"$test_tmp/failure.err"
failure_status=$?
set -e
(( failure_status != 0 )) || fail "migration runner exits non-zero when a migration fails"
[[ ! -f $failure_home/.local/state/omarchy/migrations/500-fail.sh ]] || fail "migration runner does not mark failed migration complete"
grep -q '^before-fail$' "$calls" || fail "migration runner started failing migration"
! grep -q '^after-fail$' "$calls" || fail "migration runner stops failing migration under strict mode"
pass "migration runner does not mark failed migrations complete"

stdin_root="$test_tmp/stdin-omarchy"
stdin_home="$test_tmp/stdin-home"
stdin_calls="$test_tmp/stdin-calls"
mkdir -p "$stdin_root/migrations" "$stdin_home"

cat >"$stdin_root/migrations/100-reader.sh" <<'SH'
IFS= read -r value
printf 'reader:%s\n' "$value" >>"$TEST_CALLS"
SH
cat >"$stdin_root/migrations/200-after.sh" <<'SH'
echo after-reader >>"$TEST_CALLS"
SH

printf 'migration input\n' |
  TEST_CALLS="$stdin_calls" run_migrate "$stdin_home" "$stdin_root" >"$test_tmp/stdin.out"

grep -q '^reader:migration input$' "$stdin_calls" ||
  fail "migration runner preserves the caller's stdin for a migration" "$(cat "$stdin_calls")"
grep -q '^after-reader$' "$stdin_calls" ||
  fail "a migration reading stdin does not swallow later queue entries" "$(cat "$stdin_calls")"
[[ -f $stdin_home/.local/state/omarchy/migrations/100-reader.sh &&
  -f $stdin_home/.local/state/omarchy/migrations/200-after.sh ]] ||
  fail "migration runner marks both stdin-isolated migrations complete"
pass "migration queue uses a private file descriptor instead of migration stdin"

# A limited account's migrations apply only its own part: sudo and pkexec run
# nothing and report success, since an administrator's run of the same
# migration does the machine-wide steps. An administrator's run uses them.
# An Omarchy root with the runner's stand-ins and three migrations: one that
# pipes into sudo, one that asks pkexec, one that fails for another reason.
limited_root="$test_tmp/limited-omarchy"
mkdir -p "$limited_root/migrations" "$limited_root/default/omarchy"
cp -a "$ROOT/default/omarchy/migrate-limited" "$limited_root/default/omarchy/"
cat >"$limited_root/migrations/100-machine-and-user.sh" <<'SH'
printf 'setting\n' | sudo tee "$TEST_TMP/machine-setting" >/dev/null
sudo systemctl reload systemd-logind
echo "user step 100" >>"$TEST_CALLS"
SH
cat >"$limited_root/migrations/200-pkexec.sh" <<'SH'
pkexec true
echo "user step 200" >>"$TEST_CALLS"
SH

# The real sudo and pkexec: every call that reaches them is recorded.
limited_bin="$test_tmp/limited-bin"
mkdir -p "$limited_bin"
for command in sudo pkexec; do
  printf '#!/bin/bash\necho "%s $*" >>"$TEST_ESCALATIONS"\n[[ $1 != "tee" ]] || cat >"$2"\n' "$command" >"$limited_bin/$command"
done
cat >"$limited_bin/omarchy-sudo-allowed" <<'SH'
#!/bin/bash
[[ $TEST_ADMIN == "yes" ]]
SH
# omarchy-migrate takes the update lock; here it runs as if it already held it,
# and never touches the machine's real one.
cat >"$limited_bin/omarchy-update-lock" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$limited_bin"/*

run_limited_migrate() { # ADMIN
  local home="$test_tmp/home-$1"
  rm -rf "$home" "$test_tmp/machine-setting"
  mkdir -p "$home"
  : >"$test_tmp/calls"
  : >"$test_tmp/escalations"
  HOME="$home" PATH="$limited_bin:$PATH" OMARCHY_PATH="$limited_root" OMARCHY_MIGRATION_RECORD="$test_tmp/no-record" \
    TEST_ADMIN="$1" TEST_TMP="$test_tmp" \
    TEST_CALLS="$test_tmp/calls" TEST_ESCALATIONS="$test_tmp/escalations" \
    "$ROOT/bin/omarchy-migrate" >"$test_tmp/out" 2>"$test_tmp/err"
}

run_limited_migrate no || fail "a limited account's migrations finish" "$(cat "$test_tmp/err")"
[[ ! -s $test_tmp/escalations && ! -e $test_tmp/machine-setting ]] ||
  fail "a limited account's migrations never reach sudo or pkexec" "$(cat "$test_tmp/escalations")"
[[ $(cat "$test_tmp/calls") == $'user step 100\nuser step 200' ]] ||
  fail "a limited account's migrations apply its own part" "$(cat "$test_tmp/calls")"
[[ -f $test_tmp/home-no/.local/state/omarchy/migrations/100-machine-and-user.sh && -f $test_tmp/home-no/.local/state/omarchy/migrations/200-pkexec.sh ]] ||
  fail "a limited account's migrations are recorded as done"
grep -qx "Left to an administrator: sudo systemctl reload systemd-logind" "$test_tmp/err" &&
  grep -qx "Left to an administrator: pkexec true" "$test_tmp/err" ||
  fail "a limited account's run says what it left to an administrator" "$(cat "$test_tmp/err")"
pass "a limited account's migrations apply its own part and leave sudo and pkexec to an administrator"

run_limited_migrate yes || fail "an administrator's migrations finish" "$(cat "$test_tmp/err")"
[[ $(cat "$test_tmp/machine-setting" 2>/dev/null) == "setting" ]] &&
  grep -qx "sudo systemctl reload systemd-logind" "$test_tmp/escalations" &&
  grep -qx "pkexec true" "$test_tmp/escalations" ||
  fail "an administrator's migrations use sudo and pkexec" "$(cat "$test_tmp/escalations")"
pass "an administrator's migrations use sudo and pkexec"

# Anything else that fails still fails, and stays pending.
cat >"$limited_root/migrations/300-broken.sh" <<'SH'
false
SH
if run_limited_migrate no; then fail "a migration that fails for a limited account fails the run"; fi
[[ ! -f $test_tmp/home-no/.local/state/omarchy/migrations/300-broken.sh ]] ||
  fail "a migration that fails for a limited account stays pending"
pass "a migration that fails for another reason stays pending for a limited account"

# A step about the account itself is no administrator's run's to do: it fails,
# says so, and stays pending, while the machine-wide ones before it are left.
rm -f "$limited_root/migrations/300-broken.sh"
cat >"$limited_root/migrations/400-this-account.sh" <<'SH'
sudo gpasswd -d "$USER" input
echo "user step 400" >>"$TEST_CALLS"
SH
cat >"$limited_root/migrations/500-this-home.sh" <<'SH'
sudo chown root "$HOME/.config/thing"
SH
if run_limited_migrate no; then fail "a step about a limited account itself fails its migration"; fi
grep -qx "Needs an administrator, for this account: sudo gpasswd -d $(id -un) input" "$test_tmp/err" &&
  [[ ! -s $test_tmp/escalations && $(cat "$test_tmp/calls") == $'user step 100\nuser step 200' ]] &&
  [[ ! -f $test_tmp/home-no/.local/state/omarchy/migrations/400-this-account.sh ]] ||
  fail "a step about a limited account itself says so and stays pending" "$(cat "$test_tmp/err"; cat "$test_tmp/calls")"
rm -f "$limited_root/migrations/400-this-account.sh"
cat >"$limited_root/migrations/450-this-owner.sh" <<'SH'
sudo chown "$USER:$USER" /var/lib/example
SH
if run_limited_migrate no; then fail "a step naming a limited account as user:group fails its migration"; fi
grep -qx "Needs an administrator, for this account: sudo chown $(id -un):$(id -un) /var/lib/example" "$test_tmp/err" ||
  fail "a step naming a limited account as user:group says so" "$(cat "$test_tmp/err")"
rm -f "$limited_root/migrations/450-this-owner.sh"
# A program that shares the account's name is still a machine-wide step.
cat >"$limited_root/migrations/460-program-named-like-the-account.sh" <<'SH'
sudo -n "$USER" --check /etc/example
SH
if ! run_limited_migrate no 2>/dev/null; then :; fi
grep -qx "Left to an administrator: sudo -n $(id -un) --check /etc/example" "$test_tmp/err" ||
  fail "a program that shares the account's name is left to an administrator" "$(cat "$test_tmp/err")"
rm -f "$limited_root/migrations/460-program-named-like-the-account.sh"
if run_limited_migrate no; then fail "a step about a limited account's home fails its migration"; fi
grep -q "Needs an administrator, for this account: sudo chown root .*/.config/thing" "$test_tmp/err" ||
  fail "a step about a limited account's home says so" "$(cat "$test_tmp/err")"
pass "a step about the limited account itself fails and stays pending, saying it needs an administrator"

# With the record of administrators' runs, a limited account runs a migration
# only once an administrator's run has, and stops at the first one that hasn't.
# Migrations from before the record run as before.
record="$test_tmp/admin-migrations"
record_root="$test_tmp/record-omarchy"
mkdir -p "$record" "$record_root/migrations" "$test_tmp/record-yes" "$test_tmp/record-no"
for name in 1700000000 1800000000 1800000001; do
  printf 'echo %s >>"$TEST_CALLS"\n' "$name" >"$record_root/migrations/$name.sh"
done
record_migrate() { # ADMIN [ARGS...]
  local admin=$1
  shift
  : >"$test_tmp/calls"
  HOME="$test_tmp/record-$admin" PATH="$limited_bin:$PATH" OMARCHY_PATH="$record_root" OMARCHY_MIGRATION_RECORD="$record" \
    TEST_ADMIN="$admin" TEST_TMP="$test_tmp" TEST_CALLS="$test_tmp/calls" TEST_ESCALATIONS="$test_tmp/escalations" \
    "$ROOT/bin/omarchy-migrate" "$@"
}

record_migrate no >"$test_tmp/out" || fail "a limited account's run finishes while it waits for an administrator"
[[ $(cat "$test_tmp/calls") == "1700000000" ]] && grep -q "wait for an administrator" "$test_tmp/out" ||
  fail "a limited account runs only what predates the record or an administrator has run, and says so" "$(cat "$test_tmp/calls" "$test_tmp/out")"
if record_migrate no --pending >/dev/null; then fail "a limited account isn't prompted for what waits for an administrator"; fi
record_migrate yes >/dev/null || fail "an administrator's run finishes"
[[ -e $record/1800000000.sh && -e $record/1800000001.sh ]] || fail "an administrator's run records what it runs" "$(ls "$record")"
# One the record lost while the administrator's marker stayed runs again for
# them and is recorded again.
rm "$record/1800000001.sh"
record_migrate yes >/dev/null && [[ $(cat "$test_tmp/calls") == "1800000001" && -e $record/1800000001.sh ]] ||
  fail "an administrator's run reruns a migration the record lost, and records it again" "$(cat "$test_tmp/calls")"
# One it couldn't record stays pending for the administrator, to run again.
printf 'echo 1800000002 >>"$TEST_CALLS"\n' >"$record_root/migrations/1800000002.sh"
if (( EUID != 0 )); then
  chmod 555 "$record"
  if record_migrate yes >/dev/null 2>&1; then fail "an administrator's run that can't record a migration fails"; fi
  chmod 755 "$record"
  [[ ! -e $test_tmp/record-yes/.local/state/omarchy/migrations/1800000002.sh ]] ||
    fail "a migration an administrator's run couldn't record stays pending for it"
fi
record_migrate yes >/dev/null && [[ -e $record/1800000002.sh ]] || fail "the administrator's next run runs and records it"
record_migrate no >/dev/null || fail "a limited account's run finishes once an administrator's has"
[[ $(cat "$test_tmp/calls") == $'1800000000\n1800000001\n1800000002' ]] ||
  fail "a limited account runs the migrations an administrator's run has" "$(cat "$test_tmp/calls")"
pass "a limited account's migrations wait for an administrator's run"
