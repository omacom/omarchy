#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/dell/fix-latitude-9440-display.sh"
all="$ROOT/install/hardware/all.sh"
helper="$ROOT/bin/omarchy-hw-dell-latitude-9440"
migration="$ROOT/migrations/1789420388.sh"

grep -q 'dell/fix-latitude-9440-display.sh' "$all" ||
  fail "the Latitude 9440 display fix runs during hardware setup"
pass "the Latitude 9440 display fix runs during hardware setup"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
drop_in_dir="$test_tmp/etc/limine-entry-tool.d"
drop_in="$drop_in_dir/dell-latitude-9440-display.conf"
limine_conf="$test_tmp/etc/default/limine"
mkdir -p "$stub_bin" "$test_tmp/dmi"

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
"$@"
STUB

cat >"$stub_bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash

printf 'limine-mkinitcpio\n' >>"$TEST_LOG"
STUB

# Stubbed rather than run: the real one would write the running user's state.
cat >"$stub_bin/omarchy-state" <<'STUB'
#!/bin/bash

printf 'omarchy-state' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
STUB

cat >"$stub_bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash

command -v "$1" >/dev/null
STUB

cat >"$stub_bin/omarchy-hw-dell-latitude-9440" <<'STUB'
#!/bin/bash

(( ${LATITUDE_9440:-0} == 1 ))
STUB

# The real matcher reads absolute DMI paths, so run a copy pointed at fixtures.
sed "s|/sys/class/dmi/id|$test_tmp/dmi|g" "$ROOT/bin/omarchy-hw-match" \
  >"$stub_bin/omarchy-hw-match"

chmod +x "$stub_bin"/*

# The Dell XPS 13 9440 shares the model number with this Latitude and is a
# different machine on a different GPU, so the match has to carry the line.
run_helper() {
  printf '%s' "$1" >"$test_tmp/dmi/product_name"
  printf '%s' "${2:-}" >"$test_tmp/dmi/product_family"

  PATH="$stub_bin:$PATH" bash "$helper"
}

run_helper "Latitude 9440 2-in-1" "Latitude" ||
  fail "the Latitude 9440 2-in-1 is detected"
pass "the Latitude 9440 2-in-1 is detected"

! run_helper "XPS 9440" "XPS" ||
  fail "the XPS 13 9440 is not mistaken for the Latitude"
pass "the XPS 13 9440 is not mistaken for the Latitude"

! run_helper "Latitude 7440" "Latitude" ||
  fail "other Latitudes are left alone"
pass "other Latitudes are left alone"

# The leaf writes an absolute path, so redirect it into the sandbox.
run_leaf() {
  rm -rf "$test_tmp/etc"

  local script="$test_tmp/leaf.sh"
  sed "s|/etc/limine-entry-tool.d|$drop_in_dir|g" "$leaf" >"$script"

  LATITUDE_9440="$1" PATH="$stub_bin:$PATH" \
    bash -eE -o pipefail -c 'source "$1"' bash "$script" </dev/null
}

run_leaf 1 >/dev/null
grep -Fq 'KERNEL_CMDLINE[default]+=" i915.enable_psr2_sel_fetch=0"' "$drop_in" 2>/dev/null ||
  fail "installing on a Latitude 9440 disables PSR2 selective fetch" "$(ls -R "$test_tmp/etc" 2>&1)"
pass "installing on a Latitude 9440 disables PSR2 selective fetch"

run_leaf 0 >/dev/null
[[ ! -e $drop_in ]] || fail "other hardware is left alone" "$(cat "$drop_in")"
pass "other hardware is left alone"

# Installs that predate the leaf never ran it, so the migration has to reach
# them. It runs as the user and escalates on its own.
run_migration() {
  : >"$calls"

  LATITUDE_9440="$1" PATH="$stub_bin:$PATH" TEST_LOG="$calls" \
    OMARCHY_LATITUDE_9440_DROP_IN_DIR="$drop_in_dir" \
    OMARCHY_LATITUDE_9440_LIMINE_CONF="$limine_conf" \
    bash -euo pipefail "$migration" >/dev/null
}

rm -rf "$test_tmp/etc"
run_migration 1
grep -Fq 'KERNEL_CMDLINE[default]+=" i915.enable_psr2_sel_fetch=0"' "$drop_in" 2>/dev/null ||
  fail "the migration fixes an install that never got the workaround" "$(ls -R "$test_tmp/etc" 2>&1)"
# The parameter only reaches the kernel once it is baked into the boot image.
grep -Fqx 'limine-mkinitcpio' "$calls" ||
  fail "the migration rebuilds the boot image" "$(cat "$calls")"
grep -Fq $'omarchy-state\tset\treboot-required' "$calls" ||
  fail "the migration asks for the reboot that applies it" "$(cat "$calls")"
pass "the migration fixes an install that never got the workaround"

run_migration 1
[[ ! -s $calls ]] || fail "the migration is idempotent" "$(cat "$calls")"
pass "the migration is idempotent"

# Someone who hit this before the fix shipped and reached for the blunter knob
# keeps it, rather than gaining a second drop-in that contradicts it.
rm -rf "$test_tmp/etc"
mkdir -p "$(dirname "$limine_conf")"
printf '%s\n' 'KERNEL_CMDLINE[default]+=" i915.enable_psr=0"' >"$limine_conf"
run_migration 1
[[ ! -e $drop_in ]] || fail "a hand-applied PSR setting is left in place" "$(cat "$drop_in")"
[[ ! -s $calls ]] || fail "a hand-applied PSR setting rebuilds nothing" "$(cat "$calls")"
pass "a hand-applied PSR setting is left in place"

rm -rf "$test_tmp/etc"
run_migration 0
[[ ! -e $drop_in ]] || fail "the migration skips other hardware" "$(cat "$drop_in")"
[[ ! -s $calls ]] || fail "the migration escalates nothing on other hardware" "$(cat "$calls")"
pass "the migration skips other hardware"
