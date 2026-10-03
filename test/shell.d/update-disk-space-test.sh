#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

unset GUM_STATUS
unset OMARCHY_UPDATE_FORCE
unset OMARCHY_TEST_LIMINE_DEFAULT
unset TEST_AVAILABLE_BYTES
unset TEST_ESP_AVAILABLE_BYTES
unset TEST_DF_INVALID
unset TEST_ESP_DF_INVALID

source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
test_tmp="$boundary_tmp"
stub_bin="$SUDO_TEST_ROOT/bin"
test_home="$SUDO_TEST_HOME"
runtime_dir="$test_tmp/runtime"
snapshot_marker="$test_tmp/snapshot"
gum_marker="$test_tmp/gum"
esp_root="$test_tmp/esp"
limine_default="$test_tmp/limine-default"
mkdir -p "$runtime_dir" "$esp_root/EFI/Linux"
for command in omarchy-update omarchy-update-requires-free-space omarchy-update-confirm; do
  rm -f "$stub_bin/$command"
  copy_boundary_file "bin/$command"
done

printf 'ESP_PATH="%s"\n' "$esp_root" >"$limine_default"

# 280 MiB UKI — matches the failure mode reported in the issue
truncate -s 280M "$esp_root/EFI/Linux/omarchy_linux.efi"
truncate -s 100M "$esp_root/EFI/Linux/smaller.efi"

run_update() {
  SUDO_TEST_HOME="$test_home" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  LC_ALL=C \
  OMARCHY_UPDATE_LOGGED=1 \
  OMARCHY_TEST_LIMINE_DEFAULT=${OMARCHY_TEST_LIMINE_DEFAULT:-} \
  TEST_AVAILABLE_BYTES=${TEST_AVAILABLE_BYTES:-$((9 * 1024 * 1024 * 1024))} \
  TEST_ESP_AVAILABLE_BYTES=${TEST_ESP_AVAILABLE_BYTES:-} \
  TEST_DF_INVALID=${TEST_DF_INVALID:-0} \
  TEST_ESP_DF_INVALID=${TEST_ESP_DF_INVALID:-0} \
  SNAPSHOT_MARKER="$snapshot_marker" \
  GUM_MARKER="$gum_marker" \
  GUM_STATUS=${GUM_STATUS:-1} \
    "$SUDO_TEST_ROOT/bin/omarchy-update" "$@"
}

run_requires_free_space() {
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  LC_ALL=C \
  OMARCHY_TEST_LIMINE_DEFAULT=${OMARCHY_TEST_LIMINE_DEFAULT:-} \
  TEST_AVAILABLE_BYTES=${TEST_AVAILABLE_BYTES:-$((20 * 1024 * 1024 * 1024))} \
  TEST_ESP_AVAILABLE_BYTES=${TEST_ESP_AVAILABLE_BYTES:-} \
  TEST_DF_INVALID=${TEST_DF_INVALID:-0} \
  TEST_ESP_DF_INVALID=${TEST_ESP_DF_INVALID:-0} \
    "$ROOT/bin/omarchy-update-requires-free-space" "$@"
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
target=/
for arg in "$@"; do
  case $arg in
    -*|Avail) ;;
    *) target=$arg ;;
  esac
done

if [[ $target == / ]]; then
  if (( TEST_DF_INVALID )); then
    printf "Avail\nunknown\n"
  else
    printf "Avail\n%s\n" "$TEST_AVAILABLE_BYTES"
  fi
elif [[ -n ${TEST_ESP_AVAILABLE_BYTES:-} ]]; then
  if (( TEST_ESP_DF_INVALID )); then
    printf "Avail\nunknown\n"
  else
    printf "Avail\n%s\n" "$TEST_ESP_AVAILABLE_BYTES"
  fi
else
  # No ESP stub configured: mirror root availability so path-agnostic callers stay quiet.
  if (( TEST_DF_INVALID )); then
    printf "Avail\nunknown\n"
  else
    printf "Avail\n%s\n" "$TEST_AVAILABLE_BYTES"
  fi
fi'

write_stub mountpoint '
# Succeed only for the fake ESP used by ESP free-space coverage.
[[ ${1:-} == "-q" ]] && shift
[[ ${1:-} == "--" ]] && shift
[[ ${1:-} == "'"$esp_root"'" ]]
'

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
  output=$(run_requires_free_space 2>&1)
status=$?
set -e
(( status == 1 )) || fail "free-space helper exits non-zero when disk space is low"
[[ $output == *"You need at least 10 GiB free to safely update Omarchy."* ]] ||
  fail "low root space emits the root warning" "$output"
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
grep -q "confirm Continue with update?" "$gum_marker" ||
  fail "interactive update with enough space uses the normal confirmation prompt"
[[ -f $snapshot_marker ]] || fail "accepting the normal confirmation starts the update"
pass "interactive update keeps the normal confirmation prompt when space is sufficient"

rm -f "$snapshot_marker"
output=$(TEST_DF_INVALID=1 run_update -y)
[[ -z $output ]] || fail "failed disk-space detection remains silent"
[[ -f $snapshot_marker ]] || fail "failed disk-space detection does not block the update"
pass "failed disk-space detection silently continues"

# --- ESP free-space coverage -------------------------------------------------

uki_bytes=$(stat -c %s -- "$esp_root/EFI/Linux/omarchy_linux.efi")
esp_short_bytes=$((uki_bytes - 50 * 1024 * 1024))
required_mib=$(((uki_bytes + 1024 * 1024 - 1) / (1024 * 1024)))
shortfall_mib=$(((uki_bytes - esp_short_bytes + 1024 * 1024 - 1) / (1024 * 1024)))

set +e
output=$(
  OMARCHY_TEST_LIMINE_DEFAULT="$limine_default" \
  TEST_AVAILABLE_BYTES=$((20 * 1024 * 1024 * 1024)) \
  TEST_ESP_AVAILABLE_BYTES=$esp_short_bytes \
  run_requires_free_space 2>&1
)
status=$?
set -e
(( status == 1 )) || fail "free-space helper exits non-zero when ESP space is low" "$output"
[[ $output == *"You need at least ${required_mib} MiB free on ${esp_root} to safely update Omarchy (${shortfall_mib} MiB short)."* ]] ||
  fail "low ESP space names the path and shortfall" "$output"
pass "free-space helper reports low ESP space with path and shortfall"

rm -f "$snapshot_marker" "$gum_marker"
set +e
output=$(
  OMARCHY_TEST_LIMINE_DEFAULT="$limine_default" \
  TEST_AVAILABLE_BYTES=$((20 * 1024 * 1024 * 1024)) \
  TEST_ESP_AVAILABLE_BYTES=$esp_short_bytes \
  run_update -y
)
status=$?
set -e
(( status == 1 )) || fail "non-interactive update exits non-zero with low ESP space"
[[ $output == *"free on ${esp_root}"* ]] || fail "update surfaces the ESP path in the warning" "$output"
[[ ! -f $snapshot_marker ]] || fail "non-interactive update stops before snapshotting with low ESP space"
pass "non-interactive update stops with low ESP space"

rm -f "$snapshot_marker" "$gum_marker"
output=$(
  OMARCHY_TEST_LIMINE_DEFAULT="$limine_default" \
  OMARCHY_UPDATE_FORCE=1 \
  TEST_AVAILABLE_BYTES=$((20 * 1024 * 1024 * 1024)) \
  TEST_ESP_AVAILABLE_BYTES=$esp_short_bytes \
  run_update -y
)
[[ -z $output ]] || fail "forced update does not emit the ESP free-space warning"
[[ -f $snapshot_marker ]] || fail "forced update continues with low ESP space"
pass "forced update skips the ESP free-space requirement"

rm -f "$snapshot_marker" "$gum_marker"
output=$(
  OMARCHY_TEST_LIMINE_DEFAULT="$limine_default" \
  TEST_AVAILABLE_BYTES=$((20 * 1024 * 1024 * 1024)) \
  TEST_ESP_AVAILABLE_BYTES=$uki_bytes \
  run_update -y
)
[[ $output != *"free on ${esp_root}"* ]] || fail "ESP space equal to the largest UKI does not produce a warning"
[[ -f $snapshot_marker ]] || fail "ESP space equal to the largest UKI allows the update"
pass "ESP free-space threshold includes the exact UKI boundary"

# No UKIs: require the 400 MiB floor
rm -rf "$esp_root/EFI/Linux"
mkdir -p "$esp_root/EFI/Linux"
floor_bytes=$((400 * 1024 * 1024))
floor_short_bytes=$((floor_bytes - 100 * 1024 * 1024))

set +e
output=$(
  OMARCHY_TEST_LIMINE_DEFAULT="$limine_default" \
  TEST_AVAILABLE_BYTES=$((20 * 1024 * 1024 * 1024)) \
  TEST_ESP_AVAILABLE_BYTES=$floor_short_bytes \
  run_requires_free_space 2>&1
)
status=$?
set -e
(( status == 1 )) || fail "free-space helper exits non-zero when ESP is below the no-UKI floor" "$output"
[[ $output == *"You need at least 400 MiB free on ${esp_root} to safely update Omarchy (100 MiB short)."* ]] ||
  fail "no-UKI ESP check uses the 400 MiB floor" "$output"
pass "ESP free-space check uses a 400 MiB floor when no UKI is present"

rm -f "$snapshot_marker"
output=$(
  OMARCHY_TEST_LIMINE_DEFAULT="$limine_default" \
  TEST_AVAILABLE_BYTES=$((20 * 1024 * 1024 * 1024)) \
  TEST_ESP_DF_INVALID=1 \
  TEST_ESP_AVAILABLE_BYTES=0 \
  run_update -y
)
[[ -z $output ]] || fail "failed ESP free-space detection remains silent"
[[ -f $snapshot_marker ]] || fail "failed ESP free-space detection does not block the update"
pass "failed ESP free-space detection silently continues"
