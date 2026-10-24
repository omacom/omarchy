#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export CALL_LOG="$tmp_dir/calls" OMARCHY_HID_ASUS_CONF="$tmp_dir/modprobe.d/hid_asus.conf"
export OMARCHY_LIMINE_REBUILD_MARKER="$tmp_dir/marker" HW_MATCH=yes
export PATH="$tmp_dir/bin:$PATH"

cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
cat > "$tmp_dir/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
echo limine-mkinitcpio >> "$CALL_LOG"
SH
cat > "$tmp_dir/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ $HW_MATCH == yes && $1 == H7407BA ]]
SH
chmod +x "$tmp_dir/bin/"*

migration="$ROOT/migrations/1791408113.sh"
run() { : > "$CALL_LOG"; bash -euo pipefail "$migration" >/dev/null; }

run
grep -Fxq 'options hid_asus fnlock_default=0' "$OMARCHY_HID_ASUS_CONF" ||
  fail "the P14 boots its keyboard with media keys" "$(cat "$OMARCHY_HID_ASUS_CONF" 2>/dev/null)"
grep -Fxq limine-mkinitcpio "$CALL_LOG" || fail "the initramfs is rebuilt"
pass "a ProArt P14 gets media keys by default"

run
[[ ! -s $CALL_LOG ]] || fail "the migration does nothing once applied"
pass "the migration is idempotent"

rm -f "$OMARCHY_LIMINE_REBUILD_MARKER"
printf 'options hid_asus fnlock_default=1\n' > "$OMARCHY_HID_ASUS_CONF"
run
grep -Fxq 'options hid_asus fnlock_default=1' "$OMARCHY_HID_ASUS_CONF" && [[ ! -s $CALL_LOG ]] ||
  fail "an administrator's hid_asus.conf is left alone"
pass "an administrator's hid_asus.conf is left alone"

rm -rf "$tmp_dir/modprobe.d" "$OMARCHY_LIMINE_REBUILD_MARKER"
HW_MATCH=no run
[[ ! -e $OMARCHY_HID_ASUS_CONF && ! -s $CALL_LOG ]] || fail "other machines are left alone"
pass "other machines are left alone"
