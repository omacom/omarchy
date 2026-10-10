#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

unset GUM_STATUS
unset OMARCHY_UPDATE_FORCE
unset TEST_AVAILABLE_BYTES
unset TEST_DF_INVALID

source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
test_tmp="$boundary_tmp"
stub_bin="$SUDO_TEST_ROOT/bin"
test_home="$SUDO_TEST_HOME"
runtime_dir="$test_tmp/runtime"
snapshot_marker="$test_tmp/snapshot"
gum_marker="$test_tmp/gum"
prune_marker="$test_tmp/prune"
mkdir -p "$runtime_dir"
for command in omarchy-update omarchy-update-requires-free-space omarchy-update-confirm; do
  rm -f "$stub_bin/$command"
  copy_boundary_file "bin/$command"
done

run_update() {
  SUDO_TEST_HOME="$test_home" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  LC_ALL=C \
  OMARCHY_UPDATE_LOGGED=1 \
  TEST_AVAILABLE_BYTES=${TEST_AVAILABLE_BYTES:-$((9 * 1024 * 1024 * 1024))} \
  TEST_DF_INVALID=${TEST_DF_INVALID:-0} \
  SNAPSHOT_MARKER="$snapshot_marker" \
  GUM_MARKER="$gum_marker" \
  PRUNE_MARKER="$prune_marker" \
  TEST_RECOVER_SPACE=${TEST_RECOVER_SPACE:-0} \
  GUM_STATUS=${GUM_STATUS:-0} \
    "$SUDO_TEST_ROOT/bin/omarchy-update" "$@"
}

write_stub() {
  local name="$1"
  local body="$2"

  rm -f "$stub_bin/$name"
  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

write_stub df '
if (( TEST_DF_INVALID )); then
  printf "Avail\nunknown\n"
elif (( TEST_RECOVER_SPACE )) && [[ -e $PRUNE_MARKER ]]; then
  printf "Avail\n10737418240\n"
else
  printf "Avail\n%s\n" "$TEST_AVAILABLE_BYTES"
fi'

write_stub gum '
printf "%s\n" "$*" >>"$GUM_MARKER"
if [[ ${1:-} == "confirm" ]]; then
  exit "$GUM_STATUS"
fi
exit 0'

write_stub omarchy-snapshot '
touch "$SNAPSHOT_MARKER"
exit 0'

for command in \
  omarchy-cmd-present \
  omarchy-toggle-idle \
  pkexec \
  systemd-inhibit \
  omarchy-update-dev \
  omarchy-update-keyring \
  omarchy-update-system-pkgs \
  omarchy-migrate \
  omarchy-update-aur-pkgs \
  omarchy-update-mise \
  omarchy-update-orphan-pkgs \
  omarchy-update-boot \
  omarchy-hook \
  omarchy-update-analyze-logs \
  omarchy-shell \
  omarchy-update-restart; do
  write_stub "$command" 'exit 0'
done
write_stub omarchy-update-available 'exit 1'
write_stub pkexec 'exec "$@"'
write_stub omarchy-update-pkg-prune '
printf "pruned\n" >>"$PRUNE_MARKER"
exit 0'

set +e
TEST_AVAILABLE_BYTES=$((9 * 1024 * 1024 * 1024)) \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-update-requires-free-space" >/dev/null
status=$?
set -e
(( status == 1 )) || fail "free-space helper exits non-zero when disk space is low"
pass "free-space helper reports low disk space through its exit status"

set +e
output=$(run_update -y)
status=$?
set -e
(( status == 1 )) || fail "non-interactive update exits non-zero with low disk space"
[[ $output == *"You need at least 10 GiB free to safely update Omarchy."* ]] || fail "low disk space emits a warning"
[[ ! -f $gum_marker ]] || fail "non-interactive update does not prompt for low disk space"
[[ ! -f $snapshot_marker ]] || fail "non-interactive update stops before snapshotting with low disk space"
[[ $(wc -l <"$prune_marker") == 1 ]] || fail "low-space update prunes the bounded cache once before checking"
assert_boundary_cold "low-space update"
pass "non-interactive update stops with low disk space"

rm -f "$snapshot_marker" "$gum_marker" "$prune_marker"
set +e
output=$(run_update)
status=$?
set -e
(( status == 1 )) || fail "interactive update exits non-zero with low disk space"
[[ $output == *"You need at least 10 GiB free to safely update Omarchy."* ]] || fail "interactive low-space update explains the requirement"
grep -q 'confirm Continue with update?' "$gum_marker" || fail "interactive cleanup requires normal update confirmation"
[[ ! -f $snapshot_marker ]] || fail "interactive update stops before snapshotting with low disk space"
[[ -f $prune_marker ]] || fail "confirmed update attempts bounded cleanup before refusing low space"
assert_boundary_cold "confirmed low-space update"
pass "confirmed update attempts bounded cleanup and retains the space guard"

rm -f "$snapshot_marker" "$gum_marker" "$prune_marker"
reset_boundary
GUM_STATUS=1 run_update >/dev/null
[[ ! -f $prune_marker && ! -f $snapshot_marker ]] || fail "declining an update must not prune or snapshot"
if grep -q '^sudo /usr/bin/true$' "$SUDO_TEST_LOG"; then
  fail "declining an update must not authorize cleanup"
fi
assert_boundary_cold "declined update"
pass "declining an update performs no cleanup and leaves authorization revoked"

rm -f "$snapshot_marker" "$gum_marker" "$prune_marker"
TEST_RECOVER_SPACE=1 run_update -y >/dev/null
[[ -f $snapshot_marker ]] || fail "bounded cleanup can recover enough space to proceed"
[[ $(wc -l <"$prune_marker") == 1 ]] || fail "recovered update prunes only once"
assert_boundary_cold "recovered update"
pass "an update proceeds when bounded cache cleanup recovers sufficient space"

rm -f "$snapshot_marker" "$gum_marker"
output=$(OMARCHY_UPDATE_FORCE=1 run_update -y)
[[ -z $output ]] || fail "forced update does not emit the free-space warning"
[[ ! -f $gum_marker ]] || fail "forced non-interactive update does not prompt"
[[ -f $snapshot_marker ]] || fail "forced update continues with low disk space"
pass "forced update skips the free-space requirement"

rm -f "$snapshot_marker" "$gum_marker"
output=$(TEST_AVAILABLE_BYTES=$((10 * 1024 * 1024 * 1024)) run_update -y)
[[ $output != *"You need at least 10 GiB free"* ]] || fail "space equal to the threshold does not produce a warning"
[[ -f $snapshot_marker ]] || fail "space equal to the threshold allows the update"
pass "disk-space threshold includes the exact boundary"

rm -f "$snapshot_marker" "$gum_marker"
GUM_STATUS=0 TEST_AVAILABLE_BYTES=$((10 * 1024 * 1024 * 1024)) run_update >/dev/null
grep -q "confirm Continue with update?" "$gum_marker" ||
  fail "interactive update with enough space uses the normal confirmation prompt"
[[ -f $snapshot_marker ]] || fail "accepting the normal confirmation starts the update"
pass "interactive update keeps the normal confirmation prompt when space is sufficient"

rm -f "$snapshot_marker"
output=$(TEST_DF_INVALID=1 run_update -y)
[[ -z $output ]] || fail "failed disk-space detection remains silent"
[[ -f $snapshot_marker ]] || fail "failed disk-space detection does not block the update"
pass "failed disk-space detection silently continues"
