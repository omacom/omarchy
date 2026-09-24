#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

hardware_script="$ROOT/install/hardware/fix-ideapad-suspend.sh"
migration="$ROOT/migrations/1790227635.sh"

# The affected model: Lenovo 82XQ (IdeaPad Slim 3 15AMN8).
mkdir -p "$tmp_dir/dmi-match" "$tmp_dir/conf-match"
printf 'LENOVO\n' >"$tmp_dir/dmi-match/sys_vendor"
printf '82XQ\n' >"$tmp_dir/dmi-match/product_name"

OMARCHY_DMI_PATH="$tmp_dir/dmi-match" OMARCHY_LOGIND_CONF_DIR="$tmp_dir/conf-match" \
  bash "$hardware_script"

dropin="$tmp_dir/conf-match/50-ideapad-suspend.conf"
[[ -f $dropin ]] || fail "hardware script writes the logind drop-in on an 82XQ"
grep -Fx 'HandleLidSwitch=lock' "$dropin" >/dev/null ||
  fail "drop-in locks instead of suspending on lid close"
grep -Fx 'HandleLidSwitchDocked=lock' "$dropin" >/dev/null ||
  fail "drop-in locks instead of suspending while docked"
grep -Fx 'HandleSuspendKey=lock' "$dropin" >/dev/null ||
  fail "drop-in locks instead of suspending on the suspend key"
pass "hardware script locks instead of suspending on the IdeaPad Slim 3"

# Any other machine must be left alone.
mkdir -p "$tmp_dir/dmi-other" "$tmp_dir/conf-other"
printf 'LENOVO\n' >"$tmp_dir/dmi-other/sys_vendor"
printf '21H8\n' >"$tmp_dir/dmi-other/product_name"

OMARCHY_DMI_PATH="$tmp_dir/dmi-other" OMARCHY_LOGIND_CONF_DIR="$tmp_dir/conf-other" \
  bash "$hardware_script"

[[ ! -e $tmp_dir/conf-other/50-ideapad-suspend.conf ]] ||
  fail "hardware script must not touch other Lenovo models"
pass "hardware script leaves other models alone"

# The installer registers the quirk.
grep -F 'fix-ideapad-suspend.sh' "$ROOT/install/hardware/all.sh" >/dev/null ||
  fail "install/hardware/all.sh runs the IdeaPad suspend fix"
pass "install registers the IdeaPad suspend fix"

# The migration applies the same drop-in on existing installs, once.
mkdir -p "$tmp_dir/bin" "$tmp_dir/conf-migration"
cat >"$tmp_dir/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
chmod +x "$tmp_dir/bin/sudo"

OMARCHY_DMI_PATH="$tmp_dir/dmi-match" OMARCHY_LOGIND_CONF_DIR="$tmp_dir/conf-migration" \
  PATH="$tmp_dir/bin:$PATH" bash "$migration" >/dev/null

migration_dropin="$tmp_dir/conf-migration/50-ideapad-suspend.conf"
grep -Fx 'HandleLidSwitch=lock' "$migration_dropin" >/dev/null ||
  fail "migration writes the lock-on-lid drop-in"
pass "migration writes the lock-on-lid drop-in"

# A second run must no-op: remove the drop-in's replacement path by making the
# stub fail loudly, then confirm the migration exits cleanly anyway.
cat >"$tmp_dir/bin/sudo" <<'STUB'
#!/bin/bash
echo "sudo must not run when the drop-in exists" >&2
exit 1
STUB

OMARCHY_DMI_PATH="$tmp_dir/dmi-match" OMARCHY_LOGIND_CONF_DIR="$tmp_dir/conf-migration" \
  PATH="$tmp_dir/bin:$PATH" bash "$migration" >/dev/null ||
  fail "migration is idempotent once the drop-in exists"
pass "migration is idempotent once the drop-in exists"

# And it must not run at all on other hardware.
rm -f "$tmp_dir/conf-migration/50-ideapad-suspend.conf"
cat >"$tmp_dir/bin/sudo" <<'STUB'
#!/bin/bash
echo "sudo must not run on unmatched hardware" >&2
exit 1
STUB

OMARCHY_DMI_PATH="$tmp_dir/dmi-other" OMARCHY_LOGIND_CONF_DIR="$tmp_dir/conf-migration" \
  PATH="$tmp_dir/bin:$PATH" bash "$migration" >/dev/null ||
  fail "migration exits cleanly on unmatched hardware"
[[ ! -e $tmp_dir/conf-migration/50-ideapad-suspend.conf ]] ||
  fail "migration writes nothing on unmatched hardware"
pass "migration no-ops on unmatched hardware"
