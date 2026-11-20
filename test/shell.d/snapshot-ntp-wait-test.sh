#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

snapshot="$ROOT/bin/omarchy-snapshot"

grep -Fq 'NTPSynchronized' "$snapshot" ||
  fail "snapshot waits for NTPSynchronized before creating"
grep -Fq 'wait_for_clock_sync' "$snapshot" ||
  fail "snapshot defines a bounded clock-sync wait"

# Exercise the wait with a stub timedatectl that flips to yes on the second poll.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
polls="$test_tmp/polls"

cat >"$stub_bin/timedatectl" <<'SH'
#!/bin/bash
count_file="$OMARCHY_TEST_NTP_POLLS"
count=$(<"$count_file")
count=$((count + 1))
printf '%s\n' "$count" >"$count_file"
if ((count >= 2)); then
  printf 'yes\n'
else
  printf 'no\n'
fi
SH
chmod +x "$stub_bin/timedatectl"

# Source just the wait function by extracting and running it.
printf '0\n' >"$polls"
export OMARCHY_TEST_NTP_POLLS="$polls"
PATH="$stub_bin:$PATH" bash -c '
  SECONDS=0
  wait_for_clock_sync() {
    local deadline=$((SECONDS + 15))
    while ((SECONDS < deadline)); do
      [[ $(timedatectl show -p NTPSynchronized --value 2>/dev/null) == "yes" ]] && return 0
      sleep 0.01
    done
    return 1
  }
  wait_for_clock_sync
' || fail "wait_for_clock_sync succeeds once NTPSynchronized is yes"

(( $(<"$polls") >= 2 )) || fail "wait polls timedatectl until synchronised"
pass "snapshot creation waits for NTP before stamping a snapshot"

grep -Fq 'RealTimeIsUniversal' "$ROOT/manual/50-dual-boot-install.md" ||
  fail "dual-boot manual documents the Windows UTC registry value"
grep -Fq 'set-local-rtc' "$ROOT/manual/50-dual-boot-install.md" ||
  fail "dual-boot manual documents timedatectl set-local-rtc"
pass "dual-boot manual documents the hardware clock convention"
