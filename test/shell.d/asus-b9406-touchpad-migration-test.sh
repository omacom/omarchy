#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/etc" "$test_dir/share"
stale="$test_dir/etc/asus-expertbook-b9406.quirks"
dropin="$test_dir/share/99-omarchy-asus-b9406-touchpad.quirks"
migration="$test_dir/migration.sh"
sed -e "s|^stale_quirks=.*|stale_quirks=$stale|" -e "s|^dropin_quirks=.*|dropin_quirks=$dropin|" \
  "$ROOT/migrations/1785114924.sh" >"$migration"
grep -Fq "stale_quirks=$stale" "$migration" || fail "b9406 migration test redirects the stale quirks path"
grep -Fq "dropin_quirks=$dropin" "$migration" || fail "b9406 migration test redirects the drop-in path"

cat >"$test_dir/bin/sudo" <<'EOF_SUDO'
#!/bin/bash

echo "$*" >>"$B9406_SUDO_LOG"
EOF_SUDO
chmod +x "$test_dir/bin/sudo"
export B9406_SUDO_LOG="$test_dir/sudo.log"

run_migration() {
  local matches=$1

  printf '#!/bin/bash\nexit %s\n' "$matches" >"$test_dir/bin/omarchy-hw-asus-expertbook-b9406"
  chmod +x "$test_dir/bin/omarchy-hw-asus-expertbook-b9406"
  rm -f "$B9406_SUDO_LOG"
  PATH="$test_dir/bin:$PATH" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null
}

touch "$stale"
run_migration 0
grep -Fq "rm -f $stale" "$B9406_SUDO_LOG" || fail "b9406 migration removes the quirks file libinput never read"
grep -Fq "fix-asus-ptl-b9406-touchpad.sh" "$B9406_SUDO_LOG" || fail "b9406 migration writes the drop-in"
pass "b9406 migration repairs a machine still carrying the ignored quirks file"

rm -f "$stale"
touch "$dropin"
run_migration 0
grep -Fq "fix-asus-ptl-b9406-touchpad.sh" "$B9406_SUDO_LOG" || fail "b9406 migration rewrites a drop-in whose write was cut short"
pass "b9406 migration rewrites a drop-in whose write was cut short"

sed -n "/^\[ASUS ExpertBook B9406 Touchpad\]$/,/^EOF$/p" "$ROOT/install/hardware/asus/fix-asus-ptl-b9406-touchpad.sh" | sed '$d' >"$dropin"
run_migration 0
[[ ! -e $B9406_SUDO_LOG ]] || fail "b9406 migration needs no sudo once the machine is repaired"
pass "b9406 migration is a no-op for a second user on a repaired machine"

rm -f "$dropin"
run_migration 1
[[ ! -e $B9406_SUDO_LOG ]] || fail "b9406 migration leaves other hardware alone"
pass "b9406 migration leaves other hardware alone"
