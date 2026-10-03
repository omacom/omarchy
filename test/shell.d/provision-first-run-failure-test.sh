#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mock_bin="$test_tmp/bin"
mkdir -p "$test_home" "$mock_bin"

cat >"$mock_bin/omarchy-done" <<'SH'
#!/bin/bash
done_dir="$TEST_HOME/.local/state/omarchy/done"
case "$1" in
  check) [[ -f $done_dir/$2 ]] ;;
  mark) mkdir -p "$done_dir"; touch "$done_dir/$2" ;;
  ensure) mkdir -p "$done_dir"; (set -o noclobber; : >"$done_dir/$2") 2>/dev/null ;;
esac
SH
cat >"$mock_bin/omarchy-provision-user" <<'SH'
#!/bin/bash
exit "${STUB_PROVISION_EXIT:-0}"
SH
for stub in omarchy-hook-install omarchy-notification-wait omarchy-notification-send \
  systemctl gsettings omarchy-audio-tuning nm-online; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$stub"
done
chmod +x "$mock_bin"/*

run_first_run() {
  HOME="$test_home" PATH="$mock_bin:$PATH" TEST_HOME="$test_home" \
    OMARCHY_PATH="$ROOT" STUB_PROVISION_EXIT="${1:-0}" \
    bash "$ROOT/bin/omarchy-provision-first-run"
}

marker="$test_home/.local/state/omarchy/done/first-run-user"
log="$test_home/.local/state/omarchy/first-run.log"

# A failed provision-user fails first-run: no completion marker, retry next login.
run_first_run 1
[[ ! -f $marker ]] \
  || fail "failed provision-user does not mark first-run complete"
grep -q "Failed: finalize user setup" "$log" \
  || fail "failed provision-user is logged as a failed step"
pass "failed provision-user does not mark first-run complete"

# A successful provision-user still marks first-run complete.
rm -rf "$test_home/.local"
run_first_run 0
[[ -f $marker ]] \
  || fail "successful provision-user marks first-run complete"
grep -q "Completed: finalize user setup" "$log" \
  || fail "successful provision-user is logged as completed"
pass "successful provision-user marks first-run complete"

# Settle the detached Wi-Fi announcer before the trap cleans up.
sleep 2
