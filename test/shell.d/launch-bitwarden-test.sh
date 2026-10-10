#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_INSTALLED:-false} == "true" ]]
SH

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
shift
printf 'launch:%s\n' "$*" >"$OMARCHY_TEST_LOG"
SH

cat >"$mock_bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf 'install:%s\n' "$*" >"$OMARCHY_TEST_LOG"
SH

chmod +x "$mock_bin"/*

# The app launch is detached, so the log lands a moment after the script exits.
wait_for_log() {
  for _ in $(seq 100); do
    [[ -s $1 ]] && return 0
    sleep 0.05
  done
  return 1
}

launch_log="$test_tmp/launch-log"
PATH="$mock_bin:$PATH" OMARCHY_TEST_INSTALLED=true OMARCHY_TEST_LOG="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-bitwarden"
wait_for_log "$launch_log" ||
  fail "Bitwarden launcher starts the installed app at a fixed scale factor"
grep -Fxq 'launch:-- bitwarden-desktop --force-device-scale-factor=1' "$launch_log" ||
  fail "Bitwarden launcher starts the installed app at a fixed scale factor"
pass "Bitwarden launcher starts the installed app at a fixed scale factor"

PATH="$mock_bin:$PATH" OMARCHY_TEST_INSTALLED=false OMARCHY_TEST_LOG="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-bitwarden"
grep -Fxq 'install:omarchy-install-service-bitwarden' "$launch_log" ||
  fail "Bitwarden launcher starts the installer when missing"
pass "Bitwarden launcher starts the installer when missing"

# Script callers must not sit in the app's foreground: setsid only forks for
# process-group leaders, so an exec'd launcher blocks until the app quits and
# the default password manager setup would save its choice only then. Real
# setsid and a slow app; the launcher has to hand the prompt back immediately.
slow_bin="$test_tmp/slow-bin"
mkdir -p "$slow_bin"

cat >"$slow_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$slow_bin/uwsm-app" <<'SH'
#!/bin/bash
printf 'launch:%s\n' "$*" >"$OMARCHY_TEST_LOG"
sleep 10
SH

chmod +x "$slow_bin"/*

launch_log="$test_tmp/slow-launch-log"
rc=0
timeout 2 env PATH="$slow_bin:$PATH" OMARCHY_TEST_LOG="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-bitwarden" || rc=$?
((rc == 0)) ||
  fail "Bitwarden launcher returns to a script caller while the app is running" "exit: $rc"
wait_for_log "$launch_log" ||
  fail "Bitwarden launcher returns to a script caller while the app is running" "log: $(cat "$launch_log" 2>/dev/null)"
grep -Fxq 'launch:-- bitwarden-desktop --force-device-scale-factor=1' "$launch_log" ||
  fail "Bitwarden launcher still passes the scale factor when detaching"
pass "Bitwarden launcher returns to a script caller while the app is running"
