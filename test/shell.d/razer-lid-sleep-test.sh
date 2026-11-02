#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/fix-razer-lid-sleep.sh"
all="$ROOT/install/hardware/all.sh"
migration="$ROOT/migrations/1792160540.sh"

# The quirk runs during hardware setup, so a fresh install carries it before
# the machine is ever used.
grep -q 'fix-razer-lid-sleep.sh' "$all" ||
  fail "the Razer lid quirk runs during hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
conf="$test_tmp/etc/systemd/logind.conf.d/30-razer-lid-ignore.conf"
dmi="$test_tmp/dmi"
mkdir -p "$stub_bin" "$dmi"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
SH

# Stubbed rather than run: the real one would write the running user's state.
cat >"$stub_bin/omarchy-state" <<'SH'
#!/bin/bash

printf 'omarchy-state' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

# The leaf reads the DMI strings from absolute paths, so point them at a
# fixture by rewriting the script.
run_leaf() {
  local vendor="$1" product="$2"
  rm -rf "$test_tmp/etc"
  mkdir -p "$test_tmp/etc"
  printf '%s' "$vendor" >"$dmi/sys_vendor"
  printf '%s' "$product" >"$dmi/product_name"

  local script="$test_tmp/leaf.sh"
  sed -e "s|/sys/class/dmi/id/sys_vendor|$dmi/sys_vendor|g" \
      -e "s|/sys/class/dmi/id/product_name|$dmi/product_name|g" \
      -e "s|/etc/systemd/logind.conf.d|$test_tmp/etc/systemd/logind.conf.d|g" \
      "$leaf" >"$script"

  PATH="$stub_bin:$PATH" bash -eE -o pipefail -c 'source "$1"' bash "$script" </dev/null
}

# The machine this was written for.
run_leaf "Razer" "Blade 15 Base Model (Late 2020)" >/dev/null
grep -q '^HandleLidSwitch=ignore$' "$conf" 2>/dev/null &&
  grep -q '^HandleLidSwitchExternalPower=ignore$' "$conf" &&
  grep -q '^HandleLidSwitchDocked=ignore$' "$conf" ||
  fail "a Razer Blade gets the quirk" "$(ls -R "$test_tmp/etc" 2>&1)"
pass "a Razer Blade gets the quirk"

# The defect is documented across the Blade line, not the Book line: a Book
# with working sleep firmware should keep lid-close sleep.
run_leaf "Razer" "Razer Book 14" >/dev/null
[[ ! -f $conf ]] || fail "a Razer Book keeps the default lid behavior"
pass "a Razer Book keeps the default lid behavior"

# The vendor gate alone is not enough: other vendors' hardware named "Blade"
# must not be touched.
run_leaf "Dell Inc." "Blade 15 Base Model (Late 2020)" >/dev/null
[[ ! -f $conf ]] || fail "non-Razer hardware is left alone"
pass "non-Razer hardware is left alone"

# Installs that predate the quirk never ran the leaf, so the migration has
# to reach them. It runs as the user under pipefail.
run_migration() {
  local vendor="$1" product="$2"
  printf '%s' "$vendor" >"$dmi/sys_vendor"
  printf '%s' "$product" >"$dmi/product_name"
  : >"$calls"

  PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_RAZER_LID_SYS_VENDOR="$dmi/sys_vendor" \
    OMARCHY_RAZER_LID_PRODUCT_NAME="$dmi/product_name" \
    OMARCHY_RAZER_LID_CONF="$conf" \
    bash -euo pipefail "$migration" >/dev/null
}

# A fresh install already carries the quirk, so the migration's work on a
# fresh machine is a no-op the state check must prove: reset first, then the
# two runs below share one sandbox.
rm -rf "$test_tmp/etc"
mkdir -p "$test_tmp/etc"
run_migration "Razer" "Blade 15 Base Model (Late 2020)"
grep -q '^HandleLidSwitch=ignore$' "$conf" 2>/dev/null ||
  fail "the migration fixes a pre-quirk Razer Blade install" "$(ls -R "$test_tmp/etc" 2>&1)"
# logind only reads the drop-in at service start, so the fix needs a reboot.
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the migration asks for the reboot that applies it" "$(cat "$calls")"
pass "the migration fixes a pre-quirk Razer Blade install"

run_migration "Razer" "Blade 15 Base Model (Late 2020)"
[[ ! -s $calls ]] || fail "a repaired install is left untouched" "$(cat "$calls")"
pass "the migration is idempotent"

rm -rf "$test_tmp/etc"
mkdir -p "$test_tmp/etc"
run_migration "Razer" "Razer Book 14"
[[ ! -f $conf ]] || fail "the migration leaves Razer Books alone"
[[ ! -s $calls ]] || fail "the migration escalates nothing on a Razer Book" "$(cat "$calls")"
pass "the migration leaves Razer Books alone"

rm -rf "$test_tmp/etc"
mkdir -p "$test_tmp/etc"
run_migration "Dell Inc." "Blade 15 Base Model (Late 2020)"
[[ ! -f $conf ]] || fail "the migration leaves non-Razer hardware alone"
[[ ! -s $calls ]] || fail "the migration escalates nothing on non-Razer hardware" "$(cat "$calls")"
pass "the migration leaves non-Razer hardware alone"
