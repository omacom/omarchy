#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home"

cat >"$mock_bin/omarchy-done" <<'SH'
#!/bin/bash
[[ $1 == "check" && $2 == "first-run-user" ]]
SH
cat >"$mock_bin/omarchy-provision-user" <<'SH'
#!/bin/bash
touch "$OMARCHY_TEST_FINALIZE_CALLED"
SH
chmod +x "$mock_bin/omarchy-done" "$mock_bin/omarchy-provision-user"

finalize_called="$test_tmp/finalize-called"
HOME="$test_tmp/home" PATH="$mock_bin:$PATH" OMARCHY_TEST_FINALIZE_CALLED="$finalize_called" \
  bash "$ROOT/bin/omarchy-provision-first-run" >"$test_tmp/output"

[[ ! -e $finalize_called ]] || fail "completed first-run exits before any setup step"
grep -F 'First-run already complete' "$test_tmp/output" >/dev/null || fail "completed first-run reports its lifecycle gate"

if grep -F 'user-migration-notify-watch-enabled' "$ROOT/bin/omarchy-provision-first-run" >/dev/null; then
  fail "first-run does not track the migration watcher separately"
fi
if grep -F 'skip-first-run-update-notification' "$ROOT/install/user/first-run/wifi.sh" >/dev/null; then
  fail "first-run does not track update notifications separately"
fi

pass "first-run uses one lifecycle completion marker"

# A failed finalization must keep first-run retryable. The old driver discarded
# that status with "|| true" and then marked first-run complete when its later
# steps happened to succeed, so a transient finalization failure permanently
# skipped the user's required setup.
retry_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp" "$retry_tmp"' EXIT
retry_bin="$retry_tmp/bin"
retry_root="$retry_tmp/omarchy"
mkdir -p "$retry_bin" "$retry_root/install/user/first-run" "$retry_tmp/home"

cat >"$retry_bin/omarchy-done" <<'SH'
#!/bin/bash
case "$1:$2" in
  check:first-run-user) exit 1 ;;
  mark:first-run-user) touch "$OMARCHY_TEST_FIRST_RUN_MARKER" ;;
esac
SH
cat >"$retry_bin/omarchy-provision-user" <<'SH'
#!/bin/bash
touch "$OMARCHY_TEST_FINALIZE_CALLED"
exit 42
SH
for helper in omarchy-hook-install omarchy-notification-wait; do
  printf '#!/bin/bash\nexit 0\n' >"$retry_bin/$helper"
done
chmod +x "$retry_bin"/*

for leaf in welcome.sh timezone.sh wifi.sh enable-user-units.sh gnome-theme.sh \
  gtk-primary-paste.sh audio-tuning.sh; do
  printf 'exit 0\n' >"$retry_root/install/user/first-run/$leaf"
done

retry_marker="$retry_tmp/first-run-marker"
retry_finalize="$retry_tmp/finalize-called"
HOME="$retry_tmp/home" PATH="$retry_bin:$PATH" OMARCHY_PATH="$retry_root" \
  OMARCHY_TEST_FIRST_RUN_MARKER="$retry_marker" \
  OMARCHY_TEST_FINALIZE_CALLED="$retry_finalize" \
  bash "$ROOT/bin/omarchy-provision-first-run" >"$retry_tmp/output"

[[ -e $retry_finalize ]] || fail "first-run attempts user finalization"
[[ ! -e $retry_marker ]] || fail "failed user finalization keeps first-run retryable"
grep -F 'Failed: finalize user (exit code: 42)' \
  "$retry_tmp/home/.local/state/omarchy/first-run.log" >/dev/null ||
  fail "first-run records a finalization failure"
pass "failed user finalization keeps first-run retryable"
