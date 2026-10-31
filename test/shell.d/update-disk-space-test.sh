#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

unset GUM_STATUS
unset OMARCHY_UPDATE_FORCE
unset TEST_AVAILABLE_BYTES
unset TEST_DF_INVALID
unset TEST_ROOT_FSTYPE
unset TEST_ROOT_SOURCE
unset TEST_DEVICE_BYTES
unset TEST_BTRFS_DF_FILE

source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
test_tmp="$boundary_tmp"
stub_bin="$SUDO_TEST_ROOT/bin"
test_home="$SUDO_TEST_HOME"
runtime_dir="$test_tmp/runtime"
snapshot_marker="$test_tmp/snapshot"
gum_marker="$test_tmp/gum"
mkdir -p "$runtime_dir"
for command in omarchy-update omarchy-update-requires-free-space omarchy-update-confirm omarchy-i18n; do
  rm -f "$stub_bin/$command"
  copy_boundary_file "bin/$command"
done
# The confirmation prompt reads its text from the English catalog.
mkdir -p "$SUDO_TEST_ROOT/default/i18n/en"
cp "$ROOT/default/i18n/en/cli.json" "$SUDO_TEST_ROOT/default/i18n/en/cli.json"
cp "$ROOT/default/i18n/plural.jq" "$ROOT/default/i18n/locales.json" "$SUDO_TEST_ROOT/default/i18n/"

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
  GUM_STATUS=${GUM_STATUS:-1} \
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
else
  printf "Avail\n%s\n" "$TEST_AVAILABLE_BYTES"
fi'

# The btrfs branch of the free-space helper reads the root's filesystem type,
# source device, chunk accounting and device size. Stub them all so the cases
# below do not depend on this machine's real root filesystem. The default
# fstype is ext4, which keeps the helper's btrfs branch out of the df cases
# above.
write_stub findmnt '
if [[ $2 == FSTYPE ]]; then
  printf "%s\n" "${TEST_ROOT_FSTYPE:-ext4}"
else
  printf "%s\n" "${TEST_ROOT_SOURCE:-/dev/sda1}"
fi'

write_stub lsblk 'printf "%s\n" "${TEST_DEVICE_BYTES:-0}"'

write_stub btrfs 'cat "${TEST_BTRFS_DF_FILE:-/dev/null}"'

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
  omarchy-update-pkg-prune \
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
pass "non-interactive update stops with low disk space"

rm -f "$snapshot_marker" "$gum_marker"
set +e
output=$(run_update)
status=$?
set -e
(( status == 1 )) || fail "interactive update exits non-zero with low disk space"
[[ $output == *"You need at least 10 GiB free to safely update Omarchy."* ]] || fail "interactive low-space update explains the requirement"
[[ ! -f $gum_marker ]] || fail "interactive update stops before confirmation with low disk space"
[[ ! -f $snapshot_marker ]] || fail "interactive update stops before snapshotting with low disk space"
pass "interactive update stops before confirmation with low disk space"

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
grep -q "confirm --affirmative Yes --negative No Continue with update?" "$gum_marker" ||
  fail "interactive update with enough space uses the normal confirmation prompt"
[[ -f $snapshot_marker ]] || fail "accepting the normal confirmation starts the update"
pass "interactive update keeps the normal confirmation prompt when space is sufficient"

rm -f "$snapshot_marker"
output=$(TEST_DF_INVALID=1 run_update -y)
[[ -z $output ]] || fail "failed disk-space detection remains silent"
[[ -f $snapshot_marker ]] || fail "failed disk-space detection does not block the update"
pass "failed disk-space detection silently continues"

# The btrfs chunk-allocation branch (#15528): df's free space can sit inside
# partly-used data chunks, so a full device with no metadata headroom has to
# stop the update even though df reports gigabytes.
gib=$((1024 * 1024 * 1024))
btrfs_df_file="$test_tmp/btrfs-df"
export TEST_ROOT_FSTYPE=btrfs
export TEST_ROOT_SOURCE=/dev/sda1
export TEST_BTRFS_DF_FILE="$btrfs_df_file"
export TEST_DEVICE_BYTES=$((500 * gib))

# A 500 GiB device fully allocated to chunks: 494 GiB of data, 5 GiB of
# metadata with only 550 MiB headroom, 8 MiB of system groups. Unallocated is
# under 1 GiB, df's answer is not consulted here, so give it a healthy value.
printf '%s\n' \
  "Data, single: total=$((494 * gib)), used=$((480 * gib))" \
  "System, DUP: total=8388608, used=16384" \
  "Metadata, DUP: total=$((5 * gib)), used=$((5 * gib - 550 * 1024 * 1024))" \
  "GlobalReserve, single: total=110968832, used=0" >"$btrfs_df_file"

set +e
output=$(TEST_AVAILABLE_BYTES=$((100 * gib)) \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-update-requires-free-space")
status=$?
set -e
(( status == 1 )) || fail "a fully allocated btrfs root stops the update"
[[ $output == *"no unallocated device space"* ]] || fail "the fully allocated btrfs root explains why"
[[ $output == *"btrfs balance start"* ]] || fail "the fully allocated btrfs root names the remedy"
pass "a fully allocated btrfs root with no metadata headroom stops the update"

rm -f "$snapshot_marker"
output=$(TEST_AVAILABLE_BYTES=$((100 * gib)) run_update -y)
[[ $output == *"no unallocated device space"* ]] || fail "the update surfaces the btrfs allocation failure"
[[ ! -f $snapshot_marker ]] || fail "an update on a fully allocated btrfs root stops before snapshotting"
pass "a whole update stops on a fully allocated btrfs root"

# Space to allocate new chunks from means the state is harmless, whatever df
# says about the space inside the existing chunks.
export TEST_DEVICE_BYTES=$((600 * gib))
set +e
PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-update-requires-free-space" >/dev/null
status=$?
set -e
(( status == 0 )) || fail "unallocated device space keeps the update going"
pass "unallocated device space keeps the update going"

# The metadata headroom condition is half of the pair: one GiB exactly is
# still headroom on the boundary.
export TEST_DEVICE_BYTES=$((500 * gib))
printf '%s\n' \
  "Data, single: total=$((494 * gib)), used=$((480 * gib))" \
  "System, DUP: total=8388608, used=16384" \
  "Metadata, DUP: total=$((5 * gib)), used=$((4 * gib))" \
  "GlobalReserve, single: total=110968832, used=0" >"$btrfs_df_file"
set +e
PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-update-requires-free-space" >/dev/null
status=$?
set -e
(( status == 0 )) || fail "one GiB of metadata headroom is not 'nearly gone'"
pass "metadata headroom at the one-GiB boundary keeps the update going"

# Allocated beyond the one device the check sees is accounting it does not
# model (another device, a misparse); it must not invent a block.
export TEST_DEVICE_BYTES=0
set +e
PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-update-requires-free-space" >/dev/null
status=$?
set -e
(( status == 0 )) || fail "chunk accounting beyond the visible device does not block"
pass "unmodellable chunk accounting keeps the update going"

unset TEST_ROOT_FSTYPE TEST_ROOT_SOURCE TEST_DEVICE_BYTES TEST_BTRFS_DF_FILE
