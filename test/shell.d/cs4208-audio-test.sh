#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-cs4208-audio.sh"
user_leaf="$ROOT/install/user/hardware/apple/fix-cs4208-audio.sh"
all="$ROOT/install/hardware/all.sh"
user_all="$ROOT/install/user/all.sh"
other_packages="$ROOT/install/omarchy-other.packages"
migration="$ROOT/migrations/1789869577.sh"
soft_mixer="$ROOT/default/wireplumber/wireplumber.conf.d/51-macbook-cs4208-softvol.conf"
mixer_service="$ROOT/install/hardware/apple/omarchy-cs4208-audio.service"
sleep_config="$ROOT/install/hardware/apple/60-cs4208-s2idle.conf"

grep -q 'apple/fix-cs4208-audio.sh' "$all" ||
  fail "the CS4208 audio fix runs during hardware setup"
grep -q 'apple/fix-cs4208-audio.sh' "$user_all" ||
  fail "the CS4208 software mixer runs during user setup"
grep -qx 'macbook12-audio-driver-dkms' "$other_packages" ||
  fail "the ISO caches the CS4208 speaker driver"
if ! grep -Fq 'MacBook9,1' "$leaf" || ! grep -Fq 'MacBook10,1' "$leaf"; then
  fail "the CS4208 leaf matches both 12-inch MacBooks"
fi
grep -Fq 'api.alsa.soft-mixer = true' "$soft_mixer" ||
  fail "the CS4208 speaker path uses software volume"
grep -Fq 'amixer -c0 sset Master 100%% unmute' "$mixer_service" ||
  fail "the boot service pins the CS4208 hardware mixer at full scale"
grep -Fq 'alsactl store 0' "$mixer_service" ||
  fail "the boot service persists the CS4208 hardware mixer"
pass "the complete CS4208 audio fix is wired into setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'omarchy-pkg-add' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

cat >"$stub_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash

(( ${CS4208_PKG_PRESENT:-0} == 0 ))
SH

cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash

printf 'omarchy-state' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

cat >"$stub_bin/dkms" <<'SH'
#!/bin/bash

if [[ ${1:-} == "status" ]]; then
  if (( ${CS4208_DKMS_INSTALLED:-0} == 1 )); then
    echo 'macbook12-audio-driver/0.1, 7.1.8-arch1-3, x86_64: installed (Original modules exist)'
  else
    echo 'macbook12-spi-driver/0+git.315: added'
  fi
  exit 0
fi

printf 'dkms' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash

if [[ ${1:-} == "is-enabled" ]]; then
  (( ${CS4208_SERVICE_ENABLED:-0} == 1 ))
  exit
fi

printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local model="$1"
  local systemd_dir="$test_tmp/leaf-systemd-$model"
  local sleep_config_dir="$test_tmp/leaf-sleep-$model"
  : >"$calls"
  PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_INSTALL="$ROOT/install" \
    OMARCHY_MACBOOK12_AUDIO_MODEL="$model" \
    OMARCHY_SYSTEMD_DIR="$systemd_dir" \
    OMARCHY_SLEEP_CONFIG_DIR="$sleep_config_dir" \
    bash -eE -o pipefail -c 'source "$1"' bash "$leaf"
}

run_leaf "MacBook10,1" >/dev/null
grep -Fq $'omarchy-pkg-add\tmacbook12-audio-driver-dkms' "$calls" ||
  fail "a 2017 12-inch MacBook gets the CS4208 driver" "$(cat "$calls")"
grep -Fq $'systemctl\tenable\tomarchy-cs4208-audio.service' "$calls" ||
  fail "a 2017 12-inch MacBook enables the hardware mixer service" "$(cat "$calls")"
[[ -f $test_tmp/leaf-systemd-MacBook10,1/omarchy-cs4208-audio.service ]] ||
  fail "hardware setup installs the CS4208 mixer service"
[[ ! -e $test_tmp/leaf-sleep-MacBook10,1/60-cs4208-s2idle.conf ]] ||
  fail "audio aggregation leaves hardware sleep policy untouched"
pass "a 2017 12-inch MacBook gets the complete system audio setup"

run_leaf "MacBook9,1" >/dev/null
grep -Fq $'omarchy-pkg-add\tmacbook12-audio-driver-dkms' "$calls" ||
  fail "a 2016 12-inch MacBook gets the CS4208 driver" "$(cat "$calls")"
pass "a 2016 12-inch MacBook gets the CS4208 driver"

for model in "MacBook8,1" "MacBookPro14,1" "XPS 13 9310"; do
  run_leaf "$model" >/dev/null
  [[ ! -s $calls ]] || fail "$model is left alone" "$(cat "$calls")"
  [[ ! -e $test_tmp/leaf-sleep-$model ]] ||
    fail "$model does not get the CS4208 suspend override"
done
pass "unsupported and non-Apple hardware is left alone"

run_user_leaf() {
  local model="$1"
  local home="$test_tmp/user-$model"
  mkdir -p "$home/.local/state/wireplumber/default-routes"
  touch "$home/.local/state/wireplumber/default-routes/old-route"

  HOME="$home" XDG_CONFIG_HOME="$home/.config" XDG_STATE_HOME="$home/.local/state" \
    OMARCHY_PATH="$ROOT" OMARCHY_MACBOOK12_AUDIO_MODEL="$model" \
    bash -eE -o pipefail -c 'source "$1"' bash "$user_leaf"
}

run_user_leaf "MacBook10,1"
user_config="$test_tmp/user-MacBook10,1/.config/wireplumber/wireplumber.conf.d/51-macbook-cs4208-softvol.conf"
[[ -f $user_config ]] || fail "user setup installs the CS4208 software mixer"
[[ ! -e $test_tmp/user-MacBook10,1/.local/state/wireplumber/default-routes ]] ||
  fail "user setup clears stale WirePlumber routes"
pass "user setup installs the CS4208 software mixer"

run_user_leaf "MacBookPro14,1"
[[ ! -e $test_tmp/user-MacBookPro14,1/.config/wireplumber ]] ||
  fail "user setup leaves unsupported MacBooks alone"
pass "user setup leaves unsupported MacBooks alone"

run_migration() {
  local name="$1"
  local model="$2"
  local package_present="${3:-0}"
  local driver_installed="${4:-0}"
  local service_enabled="${5:-0}"
  local run_dir="$test_tmp/migration-$name"

  mkdir -p "$run_dir/home" "$run_dir/systemd" "$run_dir/sleep"
  : >"$calls"
  PATH="$stub_bin:$PATH" TEST_LOG="$calls" HOME="$run_dir/home" \
    XDG_CONFIG_HOME="$run_dir/home/.config" \
    XDG_STATE_HOME="$run_dir/home/.local/state" \
    OMARCHY_PATH="$ROOT" OMARCHY_SYSTEMD_DIR="$run_dir/systemd" \
    OMARCHY_SLEEP_CONFIG_DIR="$run_dir/sleep" \
    OMARCHY_MACBOOK12_AUDIO_MODEL="$model" \
    CS4208_PKG_PRESENT="$package_present" \
    CS4208_DKMS_INSTALLED="$driver_installed" \
    CS4208_SERVICE_ENABLED="$service_enabled" \
    bash -euo pipefail "$migration" >/dev/null

  last_migration_dir="$run_dir"
}

run_migration "macbook10" "MacBook10,1" 0 0 0
grep -Fq $'omarchy-pkg-add\tmacbook12-audio-driver-dkms' "$calls" ||
  fail "the migration installs the CS4208 driver" "$(cat "$calls")"
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the migration asks for the reboot that loads the module" "$(cat "$calls")"
[[ -f $last_migration_dir/home/.config/wireplumber/wireplumber.conf.d/51-macbook-cs4208-softvol.conf ]] ||
  fail "the migration installs the user software mixer"
[[ -f $last_migration_dir/systemd/omarchy-cs4208-audio.service ]] ||
  fail "the migration installs the hardware mixer service"
[[ ! -e $last_migration_dir/sleep/60-cs4208-s2idle.conf ]] ||
  fail "audio aggregation leaves migration sleep policy untouched"
pass "the migration installs the complete CS4208 audio setup"

run_migration "macbook9" "MacBook9,1" 0 0 0
grep -Fq $'omarchy-pkg-add\tmacbook12-audio-driver-dkms' "$calls" ||
  fail "the migration supports the 2016 12-inch MacBook" "$(cat "$calls")"
pass "the migration supports the 2016 12-inch MacBook"

run_migration "manual-driver" "MacBook10,1" 0 1 0
! grep -Fq $'omarchy-pkg-add\tmacbook12-audio-driver-dkms' "$calls" ||
  fail "the migration preserves a hand-installed DKMS driver" "$(cat "$calls")"
pass "the migration preserves a hand-installed DKMS driver"

run_migration "repair-dkms" "MacBook10,1" 1 0 0
grep -Fq $'dkms\tautoinstall\t-k' "$calls" ||
  fail "the migration repairs a package missing its current-kernel module" "$(cat "$calls")"
pass "the migration repairs a missing current-kernel DKMS build"

run_migration "unrelated" "MacBookPro14,1" 0 0 0
[[ ! -s $calls ]] || fail "the migration skips unrelated hardware" "$(cat "$calls")"
pass "the migration skips unrelated hardware"

# A second run with every target already current performs no package, system or
# reboot work. Per-user migration markers normally prevent this, but the script
# remains safe when run directly.
run_migration "idempotent" "MacBook10,1" 1 1 1
: >"$calls"
PATH="$stub_bin:$PATH" TEST_LOG="$calls" HOME="$last_migration_dir/home" \
  XDG_CONFIG_HOME="$last_migration_dir/home/.config" \
  XDG_STATE_HOME="$last_migration_dir/home/.local/state" \
  OMARCHY_PATH="$ROOT" OMARCHY_SYSTEMD_DIR="$last_migration_dir/systemd" \
  OMARCHY_SLEEP_CONFIG_DIR="$last_migration_dir/sleep" \
  OMARCHY_MACBOOK12_AUDIO_MODEL="MacBook10,1" \
  CS4208_PKG_PRESENT=1 CS4208_DKMS_INSTALLED=1 CS4208_SERVICE_ENABLED=1 \
  bash -euo pipefail "$migration" >/dev/null
[[ ! -s $calls ]] || fail "the migration is idempotent" "$(cat "$calls")"
pass "the migration is idempotent"
