#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/hardware/huawei/fix-matebook-d15-speakers.sh"
all="$ROOT/install/hardware/all.sh"
migration=$(grep -l "huawei/fix-matebook-d15-speakers.sh" "$ROOT"/migrations/*.sh | head -1)

grep -q 'run_logged .*hardware/huawei/fix-matebook-d15-speakers.sh' "$all" ||
  fail "the MateBook D 15 speaker quirk runs during hardware setup"
pass "the MateBook D 15 speaker quirk runs during hardware setup"

[[ -n $migration ]] || fail "a migration reaches existing MateBook D 15 installs"
pass "a migration reaches existing MateBook D 15 installs"

require_command modprobe
real_modprobe=$(command -v modprobe)

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

# The real modprobe parses the fixture directory, so continued lines and module
# name spellings are its reading, not the test's.
cat >"$test_tmp/bin/modprobe" <<SH
#!/bin/bash
exec "$real_modprobe" -C "\$OMARCHY_MODPROBE_DIR" "\$@"
SH

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${TEST_PRODUCT_NAME:-} == *"$1"* ]]
SH

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

# Stubbed rather than run: the real one would write the running user's state.
cat >"$test_tmp/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >>"$CALL_LOG"
SH

chmod +x "$test_tmp/bin"/*

modprobe_dir="$test_tmp/modprobe.d"
conf="$modprobe_dir/huawei-matebook-d15-speakers.conf"
version_file="$test_tmp/product_version"
call_log="$test_tmp/calls.log"

# Sourced the way run_logged runs it.
run_leaf() {
  printf '%s\n' "${2-M1280}" >"$version_file"
  PATH="$test_tmp/bin:$PATH" \
    TEST_PRODUCT_NAME="${1-BOHB-WAX9}" \
    OMARCHY_DMI_PRODUCT_VERSION="${3-$version_file}" \
    OMARCHY_MODPROBE_DIR="$modprobe_dir" \
    bash -eE -o pipefail -c 'source "$1"' bash "$leaf"
}

rm -rf "$modprobe_dir"
run_leaf
grep -qx 'options snd_soc_sof_es8336 quirk=0x1b0' "$conf" 2>/dev/null ||
  fail "the M1280 gets the speaker GPIO quirk" "$(ls -R "$test_tmp" 2>&1)"
pass "the M1280 gets the speaker GPIO quirk"

# The kernel's own quirk for this board is right on the unit it was written for.
rm -rf "$modprobe_dir"
run_leaf "BOHB-WAX9" "M1200"
[[ ! -e $conf ]] || fail "another version of the model keeps the kernel's quirk"
pass "another version of the model keeps the kernel's quirk"

rm -rf "$modprobe_dir"
run_leaf "BOHB-WAX9" "M12800"
[[ ! -e $conf ]] || fail "a version that merely contains M1280 is left alone"
pass "a version that merely contains M1280 is left alone"

rm -rf "$modprobe_dir"
run_leaf "BOHB-WAX9" "M1280" "$test_tmp/absent"
[[ ! -e $conf ]] || fail "a missing product version fails closed"
pass "a missing product version fails closed"

rm -rf "$modprobe_dir"
run_leaf "NBLB-WAX9N"
[[ ! -e $conf ]] || fail "other hardware is left alone"
pass "other hardware is left alone"

# modprobe treats - and _ alike, so either spelling is someone's own quirk.
for module in snd_soc_sof_es8336 snd-soc-sof-es8336; do
  rm -rf "$modprobe_dir"
  mkdir -p "$modprobe_dir"
  printf 'options %s quirk=0x1b0\n' "$module" >"$modprobe_dir/sof-es8336.conf"
  run_leaf
  [[ ! -e $conf ]] || fail "a quirk already set for the driver is left alone" "$module"
done
pass "a quirk already set for the driver is left alone"

rm -rf "$modprobe_dir"
mkdir -p "$modprobe_dir"
printf 'options snd-soc-sof-es8336 \\\n  quirk=0x1a0\n' >"$modprobe_dir/sof-es8336.conf"
run_leaf
[[ ! -e $conf ]] || fail "a quirk set on a continued line is left alone"
pass "a quirk set on a continued line is left alone"

rm -rf "$modprobe_dir"
mkdir -p "$modprobe_dir"
printf 'options snd_soc_sof_es8336 dyndbg=+p\n' >"$modprobe_dir/sof-es8336.conf"
run_leaf
[[ -f $conf ]] || fail "other options for the driver do not count as a quirk"
pass "other options for the driver do not count as a quirk"

rm -rf "$modprobe_dir"
mkdir -p "$modprobe_dir"
printf '#options snd_soc_sof_es8336 quirk=0x1b0\n' >"$modprobe_dir/sof-es8336.conf"
run_leaf
[[ -f $conf ]] || fail "a commented-out quirk does not count as set"
pass "a commented-out quirk does not count as set"

run_migration() {
  : >"$call_log"
  printf '%s\n' "${2-M1280}" >"$version_file"
  PATH="$test_tmp/bin:$PATH" \
    CALL_LOG="$call_log" \
    OMARCHY_PATH="$ROOT" \
    TEST_PRODUCT_NAME="${1-BOHB-WAX9}" \
    OMARCHY_DMI_PRODUCT_VERSION="$version_file" \
    OMARCHY_MODPROBE_DIR="$modprobe_dir" \
    bash -euo pipefail "$migration" >/dev/null
}

rm -rf "$modprobe_dir"
run_migration || fail "the migration fixes an existing M1280 install"
grep -qx 'options snd_soc_sof_es8336 quirk=0x1b0' "$conf" 2>/dev/null ||
  fail "the migration fixes an existing M1280 install"
grep -q 'state set reboot-required' "$call_log" ||
  fail "the migration asks for the reboot that loads the driver with it" "$(cat "$call_log")"
pass "the migration fixes an existing M1280 install and asks for a reboot"

run_migration || fail "the migration is idempotent"
[[ ! -s $call_log ]] || fail "a fixed install is left untouched" "$(cat "$call_log")"
pass "the migration is idempotent"

rm -rf "$modprobe_dir"
mkdir -p "$modprobe_dir"
printf 'options snd_soc_sof_es8336 quirk=0x1b0\n' >"$modprobe_dir/sof-es8336.conf"
run_migration || fail "the migration leaves an install with its own quirk alone"
[[ ! -e $conf ]] || fail "the migration leaves an install with its own quirk alone"
[[ ! -s $call_log ]] || fail "an install with its own quirk needs no reboot" "$(cat "$call_log")"
pass "the migration leaves an install with its own quirk alone"

rm -rf "$modprobe_dir"
run_migration "BOHB-WAX9" "M1200" || fail "the migration no-ops on another version"
[[ ! -e $conf && ! -s $call_log ]] || fail "the migration no-ops on another version"
pass "the migration no-ops on another version"

rm -rf "$modprobe_dir"
run_migration "ThinkPad X1" || fail "the migration no-ops on other hardware"
[[ ! -e $conf && ! -s $call_log ]] || fail "the migration no-ops on other hardware"
pass "the migration no-ops on other hardware"
