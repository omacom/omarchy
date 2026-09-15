#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
run_log="$test_tmp/systemd-run.log"

cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_LOG"
exit "${OMARCHY_TEST_RUN_RC:-0}"
SH
chmod +x "$mock_bin/systemd-run"

hook="$ROOT/default/systemd/system-sleep/unmount-fuse"
PATH="$mock_bin:$PATH" OMARCHY_TEST_LOG="$run_log" bash "$hook" post suspend

grep -Fxq -- '--quiet' "$run_log" || fail "gvfs restore runs quietly outside the sleep hook"
grep -Fxq -- '--collect' "$run_log" || fail "gvfs restore transient unit is collected"
grep -Fxq -- '--property=ExitType=cgroup' "$run_log" || fail "gvfs restore service stays alive for daemonized FUSE children"
grep -Fxq -- '--on-active=5s' "$run_log" || fail "gvfs restore waits for the user slice to thaw"
grep -Fxq -- "$hook" "$run_log" || fail "gvfs restore schedules the installed sleep hook"
grep -Fxq -- 'restore' "$run_log" || fail "gvfs restore schedules the restore action"
pass "gvfs restore escapes the system-sleep cgroup and retains its FUSE child"

if ! PATH="$mock_bin:$PATH" OMARCHY_TEST_LOG="$run_log" OMARCHY_TEST_RUN_RC=1 bash "$hook" post suspend; then
  fail "gvfs restore scheduling failure does not fail system sleep"
fi
pass "gvfs restore scheduling failure does not fail system sleep"

grep -Fq '/usr/lib/gvfsd-fuse "$uid_dir/gvfs"' "$hook" || fail "gvfs recovery restores the FUSE bridge directly"
grep -Fq 'findmnt -rn -t fuse.gvfsd-fuse --target "$uid_dir/gvfs"' "$hook" || fail "gvfs recovery leaves an existing bridge alone"
if grep -Fq 'restart gvfs-daemon.service' "$hook"; then
  fail "gvfs recovery does not restart the master daemon"
fi
pass "gvfs recovery preserves active remote mounts while restoring the FUSE bridge"
