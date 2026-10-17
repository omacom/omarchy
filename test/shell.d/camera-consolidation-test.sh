#!/bin/bash
set -euo pipefail
# Apple vendor cases derive from @rand0mdud3's #11381 test. Delivery stays #12067.
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
camera_tmp=$(mktemp -d)
trap 'rm -rf "$camera_tmp"' EXIT
mkdir -p "$camera_tmp/bin"
export CAMERA_TEST_ROOT="$camera_tmp"
export OMARCHY_DMI_VENDOR="$camera_tmp/vendor"
export PATH="$camera_tmp/bin:$PATH"
cp "$ROOT/bin/omarchy-hw-facetimehd" "$camera_tmp/bin/"
cat > "$camera_tmp/bin/lspci" <<'STUB'
#!/bin/bash
printf '%s\n' "05:00.0 Multimedia controller [0480]: fixture [${CAMERA_TEST_PCI:-14e4:1570}]"
STUB
cat > "$camera_tmp/bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$CAMERA_TEST_ROOT/calls"
exit "${CAMERA_TEST_PACKAGE_EXIT:-0}"
STUB
for helper in omarchy-pkg-aur-add modprobe sudo; do
  cat > "$camera_tmp/bin/$helper" <<'STUB'
#!/bin/bash
echo 'unexpected delivery or live-module operation' >> "$CAMERA_TEST_ROOT/unexpected"
exit 99
STUB
done
cat > "$camera_tmp/bin/omarchy-notification-dismiss" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$camera_tmp/bin/"*
run_entry() {
  : > "$camera_tmp/calls"
  if [[ $1 == install ]]; then
    bash -euo pipefail -c 'source "$1"' _ "$ROOT/install/hardware/apple/fix-facetimehd.sh" > "$camera_tmp/output" 2>&1
  else
    OMARCHY_PATH="$ROOT" bash -euo pipefail "$ROOT/migrations/1789542390.sh" > "$camera_tmp/output" 2>&1
  fi
}
for entry in install migration; do
  for vendor in 'Apple Inc.' 'Apple Computer, Inc.' 'Appleish' 'apple inc.' 'LENOVO' ''; do
    printf '%s\n' "$vendor" > "$OMARCHY_DMI_VENDOR"
    export CAMERA_TEST_PCI=14e4:1570
    run_entry "$entry"
    if [[ $vendor == Apple* ]]; then
      [[ $(cat "$camera_tmp/calls") == 'facetimehd-firmware facetimehd-data facetimehd-dkms' ]] || fail "$entry delivery for '$vendor'"
    else
      [[ ! -s $camera_tmp/calls ]] || fail "$entry must exclude '$vendor'"
    fi
    pass "$entry retains source Apple-prefix gate for '$vendor'"
  done
  rm "$OMARCHY_DMI_VENDOR"
  run_entry "$entry"
  [[ ! -s $camera_tmp/calls ]] || fail "$entry must skip unavailable DMI"
  pass "$entry skips unavailable DMI"
  printf 'Apple Inc.\n' > "$OMARCHY_DMI_VENDOR"
  export CAMERA_TEST_PCI=14e4:1571
  run_entry "$entry"
  [[ ! -s $camera_tmp/calls ]] || fail "$entry must skip adjacent PCI ID"
  pass "$entry skips adjacent PCI ID"
done
[[ ! -e $camera_tmp/unexpected ]] || fail "no AUR, sudo or live-module operations expected"
pass "selected delivery has no alternate package manager or live module loading"

# Exercise the real migrator with one pending source migration. Relocate only
# its pacman-lock path so host package activity cannot affect the fixture.
mkdir -p "$camera_tmp/tree/migrations" "$camera_tmp/tree/install/hardware/apple"
cp "$ROOT/migrations/1789542390.sh" "$camera_tmp/tree/migrations/"
cp "$ROOT/install/hardware/apple/fix-facetimehd.sh" "$camera_tmp/tree/install/hardware/apple/"
sed "s|local lock_file=/var/lib/pacman/db.lck|local lock_file=$camera_tmp/pacman.lock|" "$ROOT/bin/omarchy-migrate" > "$camera_tmp/migrate"
export OMARCHY_PATH="$camera_tmp/tree"
export OMARCHY_MIGRATION_STATE="$camera_tmp/state"
export CAMERA_TEST_PCI=14e4:1570 CAMERA_TEST_PACKAGE_EXIT=23
: > "$camera_tmp/calls"
set +e
bash "$camera_tmp/migrate" > "$camera_tmp/output" 2>&1
result=$?
set -e
(( result == 23 )) || fail "failed package delivery must propagate through the real queue" "$result"
[[ ! -e $OMARCHY_MIGRATION_STATE/1789542390.sh ]] || fail "failed delivery must remain pending"
pass "failed package delivery leaves the real migration pending"
export CAMERA_TEST_PACKAGE_EXIT=0
: > "$camera_tmp/calls"
bash "$camera_tmp/migrate" > "$camera_tmp/output" 2>&1
[[ -f $OMARCHY_MIGRATION_STATE/1789542390.sh && -s $camera_tmp/calls ]] || fail "successful retry must complete the migration"
pass "successful retry completes the pending migration"
: > "$camera_tmp/calls"
bash "$camera_tmp/migrate" > "$camera_tmp/output" 2>&1
[[ ! -s $camera_tmp/calls ]] || fail "completed migration must not repeat package delivery"
pass "completed migration is skipped on rerun"
