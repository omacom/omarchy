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
grep -q "confirm Continue with update?" "$gum_marker" ||
  fail "interactive update with enough space uses the normal confirmation prompt"
[[ -f $snapshot_marker ]] || fail "accepting the normal confirmation starts the update"
pass "interactive update keeps the normal confirmation prompt when space is sufficient"

rm -f "$snapshot_marker"
output=$(TEST_DF_INVALID=1 run_update -y)
[[ -z $output ]] || fail "failed disk-space detection remains silent"
[[ -f $snapshot_marker ]] || fail "failed disk-space detection does not block the update"
pass "failed disk-space detection silently continues"

# The ESP guard sizes its ask against the largest UKI already on disk, so it
# needs a fake ESP tree, an arg-aware df, and a sed that points ESP_PATH at
# the fake tree without touching the real /etc/default/limine.
esp_tree="$test_tmp/esp"
mkdir -p "$esp_tree/EFI/Linux"
truncate -s 300M "$esp_tree/EFI/Linux/omarchy_linux.efi"

real_sed=$(command -v sed)

write_stub sed '
if [[ ${1:-} == "-n" && ${3:-} == "/etc/default/limine" ]]; then
  printf "%s\n" "$TEST_ESP_PATH"
else
  exec "$REAL_SED" "$@"
fi'
export REAL_SED="$real_sed"

write_stub findmnt '
[[ $# == 4 && $1 == "-nro" && $2 == "SOURCE" && $3 == "-T" ]] || exit 1
if [[ $4 == "$TEST_ESP_PATH" && ${TEST_ESP_ON_ROOT:-0} == "0" ]]; then
  echo /dev/esp
else
  echo /dev/root
fi'

write_stub df '
last="${*: -1}"
if [[ $last == "/" ]]; then
  if (( TEST_DF_INVALID )); then
    printf "Avail\nunknown\n"
  else
    printf "Avail\n%s\n" "$TEST_AVAILABLE_BYTES"
  fi
else
  printf "Avail\n%s\n" "$TEST_ESP_AVAILABLE_BYTES"
fi'

write_stub pacman '
[[ $* == "-Qq" ]] || exit 1
printf "%s\n" "${TEST_KERNEL_PACKAGES-linux}"
exit "${TEST_PACMAN_STATUS:-0}"'

real_find=$(command -v find)
export REAL_FIND="$real_find"
write_stub find '
if [[ ${TEST_FIND_DENIED:-0} == "1" ]]; then
  printf "123\n"
  echo "Permission denied" >&2
  exit 1
else
  exec "$REAL_FIND" "$@"
fi'

run_free_space() {
  TEST_ESP_ON_ROOT=${TEST_ESP_ON_ROOT:-0} \
  TEST_FIND_DENIED=${TEST_FIND_DENIED:-0} \
  TEST_KERNEL_PACKAGES=${TEST_KERNEL_PACKAGES-linux} \
  TEST_PACMAN_STATUS=${TEST_PACMAN_STATUS:-0} \
  TEST_ESP_PATH="$esp_tree" \
  TEST_ESP_AVAILABLE_BYTES=${TEST_ESP_AVAILABLE_BYTES:-$((600 * 1024 * 1024))} \
  TEST_AVAILABLE_BYTES=$((20 * 1024 * 1024 * 1024)) \
  TEST_DF_INVALID=0 \
  PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-update-requires-free-space"
}

set +e
output=$(TEST_ESP_AVAILABLE_BYTES=$((100 * 1024 * 1024)) run_free_space)
status=$?
set -e
(( status == 1 )) || fail "ESP with less than 2x the largest UKI free blocks the update"
[[ $output == *"free in $esp_tree"* ]] || fail "ESP guard names the ESP path in its message"
pass "full ESP blocks the update and names the ESP path"

set +e
output=$(TEST_ESP_AVAILABLE_BYTES=$((600 * 1024 * 1024)) run_free_space)
status=$?
set -e
(( status == 0 )) || fail "ESP headroom at exactly 2x the largest UKI lets the update proceed"
pass "ESP with room for one more UKI plus churn does not block"

set +e
output=$(TEST_ESP_AVAILABLE_BYTES=$((1024)) run_free_space)
status=$?
set -e
(( status == 1 )) || fail "ESP guard blocks from the measured shortfall, not a fixed floor"
[[ $output == *"600M"* ]] || fail "ESP guard reports the human-sized requirement"
pass "ESP requirement scales with the largest UKI on disk"

set +e
rm -rf "$esp_tree/EFI/Linux"
output=$(TEST_ESP_AVAILABLE_BYTES=$((1024)) run_free_space)
status=$?
set -e
(( status == 0 )) || fail "ESP without UKIs does not block the update"
[[ -z $output ]] || fail "ESP without UKIs skips silently"
pass "ESP guard skips when there is no UKI to size against"

set +e
mkdir -p "$esp_tree/EFI/Linux"
truncate -s 300M "$esp_tree/EFI/Linux/omarchy_linux.efi"
output=$(TEST_ESP_ON_ROOT=1 TEST_ESP_AVAILABLE_BYTES=1 run_free_space)
status=$?
set -e
(( status == 0 )) || fail "root-backed ESP defers to the root check"
pass "ESP on the root filesystem is covered by the root check"

[[ -z $output ]] || fail "plain ESP directory on root skips silently"

output=$(TEST_FIND_DENIED=1 run_free_space 2>&1)
[[ $output == *"$esp_tree"* && $output == *"permissions"* && $output == *"UKI headroom"* ]] ||
  fail "failed UKI scan warns about permissions and names the ESP"
pass "unreadable ESP warns without blocking, even with partial find output"

check_headroom() {
  local copies="$1" status output
  output=$(TEST_ESP_AVAILABLE_BYTES=$((copies * 300 * 1024 * 1024)) run_free_space)
  [[ -z $output ]] || fail "exact UKI headroom boundary succeeds silently"
  set +e
  output=$(TEST_ESP_AVAILABLE_BYTES=$((copies * 300 * 1024 * 1024 - 1)) run_free_space)
  status=$?
  set -e
  (( status == 1 )) || fail "one byte below UKI headroom blocks"
  [[ $output == *"$(numfmt --to=iec -- "$((copies * 300 * 1024 * 1024))") free in $esp_tree"* ]] || fail "warning uses calculated kernel headroom"
}

TEST_KERNEL_PACKAGES=$'linux\nlinux-headers' check_headroom 2
pass "one installed kernel requires two copies and excludes headers"
TEST_KERNEL_PACKAGES=$'linux\nlinux-lts\nlinux-zen\nlinux-ptl\nlinux-t2\nlinux-omarchy\nlinux-omarchy-custom\nlinux-headers\nlinux-omarchy-headers\nlinux-omarchy-custom-headers\nunrelated' check_headroom 8
pass "installed kernel families plus one determine UKI headroom"
TEST_KERNEL_PACKAGES= check_headroom 2
pass "empty kernel query retains two-copy headroom"
TEST_PACMAN_STATUS=1 TEST_KERNEL_PACKAGES=$'linux\nlinux-lts' check_headroom 2
pass "failed kernel query falls back to two copies"

# Isolate PATH so this case also works on hosts with pacman installed.
missing_pacman_bin="$test_tmp/no-pacman"
mkdir -p "$missing_pacman_bin"
for command in sed findmnt find df tail sort head numfmt; do
  ln -s "$(command -v "$command")" "$missing_pacman_bin/$command"
done
for command in sed findmnt find df; do
  ln -sf "$stub_bin/$command" "$missing_pacman_bin/$command"
done
rm -f "$stub_bin/pacman"
# run_free_space prepends the stubs and repo commands to this isolated PATH.
PATH="$missing_pacman_bin" check_headroom 2
pass "unavailable pacman falls back to two copies"
