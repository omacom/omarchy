#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/apple/fix-brcmfmac-suspend.sh"
source_hook="$ROOT/default/systemd/system-sleep/rebind-brcmfmac"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1789668939.sh"

grep -q 'apple/fix-brcmfmac-suspend.sh' "$all" ||
  fail "the brcmfmac suspend fix runs during hardware setup"
pass "the brcmfmac suspend fix runs during hardware setup"

# systemd-sleep runs every executable in system-sleep and silently skips
# anything without the bit.
[[ -x $source_hook ]] ||
  fail "the hook source is executable"
pass "the hook source is executable"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
hook="$test_tmp/usr/lib/systemd/system-sleep/rebind-brcmfmac"
mkdir -p "$stub_bin" "$test_tmp/dmi" "$test_tmp/usr/lib/systemd/system-sleep"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

if (( ${T2_HARDWARE:-0} == 1 )); then
  echo '01:00.0 Bridge [0680]: Apple Inc. T2 Security Chip [106b:1801]'
fi
if [[ -n ${WIFI_ID:-} ]]; then
  echo "03:00.0 Network controller [0280]: Broadcom Inc. Wireless [14e4:$WIFI_ID]"
fi
for _ in {1..4096}; do
  echo '02:00.0 Host bridge [0600]: Filler Device [ffff:0000]'
done
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

# install -o root -g root fails as the test user; ownership is already right
# in the sandbox, so drop those flags before executing.
args=()
skip=0
for arg in "$@"; do
  if (( skip )); then
    skip=0
    continue
  fi
  case "$arg" in
    -o|-g) skip=1 ;;
    *) args+=("$arg") ;;
  esac
done
"${args[@]}"
SH

chmod +x "$stub_bin"/*

run_leaf() {
  local vendor="$1" wifi_id="${2:-}" t2="${3:-0}"
  rm -rf "$test_tmp/usr/lib/systemd/system-sleep"
  mkdir -p "$test_tmp/usr/lib/systemd/system-sleep"
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"

  local script="$test_tmp/leaf.sh"
  sed -e "s|/sys/class/dmi/id/sys_vendor|$test_tmp/dmi/sys_vendor|g" \
      -e "s|/usr/lib/systemd/system-sleep|$test_tmp/usr/lib/systemd/system-sleep|g" \
      -e "s|\$OMARCHY_PATH|$ROOT|g" \
      "$leaf" >"$script"

  WIFI_ID="$wifi_id" T2_HARDWARE="$t2" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    bash -eE -o pipefail -c 'source "$1"' bash "$script" </dev/null
}

run_leaf "Apple Inc." 43a3 0 >/dev/null
[[ -x $hook ]] ||
  fail "a Mac with a BCM4350 gets the sleep hook" "$(ls -R "$test_tmp/usr" 2>&1)"
cmp -s "$source_hook" "$hook" ||
  fail "the installed hook matches the source"
pass "a Mac with a BCM4350 gets the sleep hook"

run_leaf "Apple Inc." 4488 1 >/dev/null
[[ -x $hook ]] ||
  fail "a T2 Mac gets the sleep hook"
pass "a T2 Mac gets the sleep hook"

run_leaf "Apple Inc." 43a0 0 >/dev/null
[[ ! -e $hook ]] || fail "a Mac whose Wi-Fi brcmfmac does not drive is left alone"
pass "a Mac whose Wi-Fi brcmfmac does not drive is left alone"

run_leaf "LENOVO" 43a3 0 >/dev/null
[[ ! -e $hook ]] || fail "non-Apple hardware is left alone"
pass "non-Apple hardware is left alone"

run_migration() {
  local vendor="$1" wifi_id="${2:-}" t2="${3:-0}"
  printf '%s' "$vendor" >"$test_tmp/dmi/sys_vendor"
  : >"$calls"

  WIFI_ID="$wifi_id" T2_HARDWARE="$t2" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_BRCMFMAC_DMI_VENDOR="$test_tmp/dmi/sys_vendor" \
    OMARCHY_BRCMFMAC_SLEEP_HOOK="$hook" \
    bash -euo pipefail "$migration" >/dev/null
}

rm -f "$hook"
run_migration "Apple Inc." 43a3 0
[[ -x $hook ]] ||
  fail "the migration installs the hook on a Mac that predates it"
pass "the migration installs the hook on a Mac that predates it"

run_migration "Apple Inc." 43a3 0
[[ ! -s $calls ]] || fail "a repaired install is left untouched" "$(cat "$calls")"
pass "the migration is idempotent"

printf '# local tweak\n' >> "$hook"
run_migration "Apple Inc." 43a3 0
cmp -s "$source_hook" "$hook" ||
  fail "the migration refreshes a modified hook"
pass "the migration refreshes a modified hook"

rm -f "$hook"
run_migration "LENOVO" 43a3 0
[[ ! -e $hook ]] || fail "the migration skips non-Apple hardware"
pass "the migration skips non-Apple hardware"

# The hook itself: run it against a stub sysfs where unbind and bind are real
# files, so the writes land and can be checked. /run is writable in tests.
driver="$test_tmp/sys/bus/pci/drivers/brcmfmac"
mkdir -p "$driver"
ln -s "/sys/devices/pci0000:00/0000:02:00.0" "$driver/0000:02:00.0"
touch "$driver/unbind" "$driver/bind"

hook_script="$test_tmp/rebind-brcmfmac"
sed "s|/sys/bus/pci/drivers/brcmfmac|$driver|g" "$source_hook" > "$hook_script"
chmod +x "$hook_script"
state_file="$test_tmp/state"
export OMARCHY_BRCMFMAC_SLEEP_STATE="$state_file"

"$hook_script" pre
grep -qx '0000:02:00.0' "$driver/unbind" ||
  fail "pre-sleep unbinds the bound device" "$(cat "$driver/unbind")"
[[ -f $state_file ]] || fail "pre-sleep records the unbound device"
pass "pre-sleep unbinds the bound device"

"$hook_script" post
grep -qx '0000:02:00.0' "$driver/bind" ||
  fail "post-sleep rebinds the same device" "$(cat "$driver/bind")"
[[ ! -f $state_file ]] ||
  fail "post-sleep clears the state file"
pass "post-sleep rebinds the same device and clears state"

# A post with no matching pre is a no-op, the case after a fresh boot.
rm -f "$state_file"
: > "$driver/bind"
"$hook_script" post
[[ ! -s $driver/bind ]] || fail "post without pre writes nothing"
pass "post without pre is a no-op"
