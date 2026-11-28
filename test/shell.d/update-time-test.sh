#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
log_file="$test_tmp/time.log"
mkdir -p "$stub_bin"

# TIME_TEST_UNSYNCED_POLLS  NTPSynchronized polls that answer no before yes, or "never"
# TIME_TEST_TIMESYNCD       1 when timesyncd is the running NTP client (default 1)
cat >"$stub_bin/timedatectl" <<'SH'
#!/bin/bash
polls=$(( $(cat "$TIME_TEST_DIR/polls" 2>/dev/null || echo 0) + 1 ))
echo "$polls" >"$TIME_TEST_DIR/polls"
if [[ $TIME_TEST_UNSYNCED_POLLS == "never" ]] || (( polls <= TIME_TEST_UNSYNCED_POLLS )); then
  echo no
else
  echo yes
fi
SH
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
if [[ $1 == "is-active" ]]; then
  [[ ${TIME_TEST_TIMESYNCD:-1} == 1 ]]
else
  echo "systemctl $*" >>"$TIME_TEST_LOG"
fi
SH
printf '#!/bin/bash\n"$@"\n' >"$stub_bin/sudo"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/sleep"
chmod +x "$stub_bin"/*

# The installed keyrings are read at a fixed path; the test runs a copy
# rewritten to read a fixture whose mtime stands for when they were installed.
keyrings="$test_tmp/keyrings"
mkdir -p "$keyrings"
sed "s|/usr/share/pacman/keyrings|$keyrings|" "$ROOT/bin/omarchy-update-time" >"$test_tmp/omarchy-update-time"
chmod +x "$test_tmp/omarchy-update-time"

run_time() {
  : >"$log_file"
  rm -f "$test_tmp/polls"
  TIME_TEST_DIR="$test_tmp" TIME_TEST_LOG="$log_file" PATH="$stub_bin:$PATH" \
    "$test_tmp/omarchy-update-time" --if-behind
}

# A clock older than the installed keyrings, as on an Apple Silicon Mac whose
# RTC reads 1970, gets timesyncd restarted and is waited for.
touch -d "+1 year" "$keyrings"
TIME_TEST_UNSYNCED_POLLS=3 run_time >"$test_tmp/wait.out" ||
  fail "a clock behind the keyrings is waited for until it syncs" "$(cat "$test_tmp/wait.out")"
grep -Fx "systemctl restart systemd-timesyncd" "$log_file" >/dev/null ||
  fail "a clock behind the keyrings restarts timesyncd" "$(cat "$log_file")"
pass "a clock behind the keyrings restarts timesyncd and is waited for until it syncs"

# One that never syncs stops the update with the reason, and another NTP
# client is not displaced by starting timesyncd.
if TIME_TEST_UNSYNCED_POLLS=never TIME_TEST_TIMESYNCD=0 run_time >"$test_tmp/behind.out" 2>&1; then
  fail "a clock that stays behind the keyrings stops the update"
fi
grep -F "earlier than the installed signing keys" "$test_tmp/behind.out" >/dev/null ||
  fail "a clock that stays behind the keyrings says why the update stopped" "$(cat "$test_tmp/behind.out")"
[[ ! -s $log_file ]] || fail "only a running timesyncd is restarted" "$(cat "$log_file")"
pass "a clock that stays behind the keyrings stops the update with the reason, leaving other NTP clients alone"

# An unsynced clock past the keyrings costs nothing, so networks that block NTP
# don't wait on every update.
touch -d "2001-01-01" "$keyrings"
TIME_TEST_UNSYNCED_POLLS=never run_time >"$test_tmp/plausible.out" ||
  fail "an unsynced clock past the keyrings goes on" "$(cat "$test_tmp/plausible.out")"
[[ ! -s $log_file && ! -s $test_tmp/plausible.out ]] ||
  fail "an unsynced clock past the keyrings neither waits nor restarts timesyncd" "$(cat "$log_file" "$test_tmp/plausible.out")"
pass "an unsynced clock past the keyrings goes on without waiting"
