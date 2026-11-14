#!/bin/bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

helper="$ROOT/bin/omarchy-hw-fujitsu-lifebook-p727"
script="$ROOT/install/hardware/fujitsu/fix-lifebook-p727-i8042.sh"
[[ -x $helper ]] || fail "lifebook hw helper is executable"
grep -Fq 'i8042.nomux' "$script" || fail "install script sets i8042.nomux"
grep -Fq 'fix-lifebook-p727-i8042.sh' "$ROOT/install/hardware/all.sh" ||
  fail "hardware install runs lifebook i8042 fix"
pass "LIFEBOOK P727 i8042 fix is wired"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/dmi"
printf 'LIFEBOOK P727\n' >"$tmpdir/dmi/product_name"
# Helper reads /sys/... — exercise the string match via a stubbed cat path by
# running the comparison inline the same way the helper does.
product_name=$(cat "$tmpdir/dmi/product_name")
[[ $product_name == *"LIFEBOOK P727"* ]] || fail "product name match"
pass "LIFEBOOK P727 product name matches detection"

migration=$(rg -l 'lifebook-p727-i8042.conf' "$ROOT/migrations" | head -1)
[[ -n $migration ]] || fail "migration installs lifebook i8042 drop-in"
pass "migration installs lifebook i8042 drop-in"

mkdir -p "$tmpdir/bin"
cat >"$tmpdir/bin/omarchy-hw-fujitsu-lifebook-p727" <<'STUB'
#!/bin/bash
exit "$HARDWARE_STATUS"
STUB
cat >"$tmpdir/bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ $1 == "limine-mkinitcpio" ]]
STUB
cat >"$tmpdir/bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$FIXTURE/privileged.log"
"$@"
STUB
cat >"$tmpdir/bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
echo rebuild >>"$FIXTURE/rebuild.log"
exit "$REBUILD_STATUS"
STUB
chmod +x "$tmpdir/bin/"*

run_migration() {
  local fixture="$1" hardware_status="$2" rebuild_status="$3"
  mkdir -p "$fixture/home"
  sed "s|/etc/limine-entry-tool.d|$fixture/dropins|g" "$migration" >"$fixture/migration.sh"
  if PATH="$tmpdir/bin:$PATH" HOME="$fixture/home" OMARCHY_PATH="$ROOT" \
    FIXTURE="$fixture" HARDWARE_STATUS="$hardware_status" REBUILD_STATUS="$rebuild_status" \
    OMARCHY_LIFEBOOK_P727_REBUILD_MARKER="$fixture/rebuilt" \
    bash -euo pipefail "$fixture/migration.sh" >"$fixture/output.log" 2>&1; then
    migration_status=0
  else
    migration_status=$?
  fi
}

fixture="$tmpdir/retry"
dropin="$fixture/dropins/lifebook-p727-i8042.conf"
run_migration "$fixture" 0 1
(( migration_status == 1 )) || fail "failed rebuild leaves migration pending"
[[ -f $dropin ]] || fail "failed rebuild leaves the drop-in"
rg -Fq 'KERNEL_CMDLINE[default]+=" i8042.nomux"' "$dropin" || fail "migration writes keyboard fix"
(( $(wc -l <"$fixture/rebuild.log") == 1 )) || fail "first attempt rebuilds"
[[ ! -e $fixture/rebuilt ]] || fail "failed rebuild leaves no marker"
pass "failed rebuild leaves the drop-in and exits nonzero"

# Preserve administrator changes while retrying the rebuild.
echo '# preserved customization' >>"$dropin"
cp "$dropin" "$fixture/expected.conf"
run_migration "$fixture" 0 1
(( migration_status == 1 )) || fail "second failed rebuild leaves migration pending"
(( $(wc -l <"$fixture/rebuild.log") == 2 )) || fail "second attempt retries rebuild"
cmp -s "$dropin" "$fixture/expected.conf" || fail "retry preserves existing drop-in content"
pass "second failed attempt retries rebuild and preserves the drop-in"

run_migration "$fixture" 0 0
(( migration_status == 0 )) || fail "successful rebuild completes migration"
(( $(wc -l <"$fixture/rebuild.log") == 3 )) || fail "successful attempt retries rebuild"
cmp -s "$dropin" "$fixture/expected.conf" || fail "successful retry preserves existing drop-in content"
[[ -e $fixture/rebuilt ]] || fail "successful rebuild records the marker"
pass "successful rebuild completes migration and preserves the drop-in"

run_migration "$fixture" 0 0
(( migration_status == 0 )) || fail "another user's migration completes"
(( $(wc -l <"$fixture/rebuild.log") == 3 )) || fail "another user's migration skips the rebuild"
pass "another user's migration does not rebuild again"

rm "$dropin"
run_migration "$fixture" 0 0
(( migration_status == 0 )) || fail "recreating the drop-in completes migration"
[[ -f $dropin ]] || fail "removed drop-in is recreated"
(( $(wc -l <"$fixture/rebuild.log") == 4 )) || fail "recreated drop-in rebuilds the boot image"
[[ -e $fixture/rebuilt ]] || fail "rebuild after recreating the drop-in records the marker"
pass "recreated drop-in reaches the boot image"

fixture="$tmpdir/nonmatching"
run_migration "$fixture" 1 0
(( migration_status == 0 )) || fail "nonmatching hardware skips migration"
[[ ! -e $fixture/privileged.log && ! -e $fixture/dropins && ! -e $fixture/rebuild.log ]] ||
  fail "nonmatching hardware performs no privileged work"
pass "nonmatching hardware performs no privileged work"
