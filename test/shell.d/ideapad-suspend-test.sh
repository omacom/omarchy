#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

hardware_script="$ROOT/install/hardware/fix-ideapad-suspend.sh"
migration="$ROOT/migrations/1790227635.sh"
calls="$tmp_dir/calls"

# Stubs log every privileged call so nothing touches the host's logind and
# the assertions can tell "did not run" apart from "ran and failed".
mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALLS_FILE"
exec "$@"
STUB
cat >"$tmp_dir/bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CALLS_FILE"
exit 0
STUB
chmod +x "$tmp_dir/bin/sudo" "$tmp_dir/bin/systemctl"
: >"$calls"

# The affected model: Lenovo 82XQ (IdeaPad Slim 3 15AMN8).
mkdir -p "$tmp_dir/dmi-match" "$tmp_dir/conf-match"
printf 'LENOVO\n' >"$tmp_dir/dmi-match/sys_vendor"
printf '82XQ\n' >"$tmp_dir/dmi-match/product_name"

OMARCHY_DMI_PATH="$tmp_dir/dmi-match" OMARCHY_LOGIND_CONF_DIR="$tmp_dir/conf-match" \
  bash "$hardware_script"

dropin="$tmp_dir/conf-match/50-ideapad-suspend.conf"
[[ -f $dropin ]] || fail "hardware script writes the logind drop-in on an 82XQ"
grep -Fx '[Login]' "$dropin" >/dev/null ||
  fail "drop-in is a logind section"
grep -Fx 'HandleLidSwitch=lock' "$dropin" >/dev/null ||
  fail "drop-in locks instead of suspending on lid close"
grep -Fx 'HandleSuspendKey=lock' "$dropin" >/dev/null ||
  fail "drop-in locks instead of suspending on the suspend key"
grep -Fx 'HandleSuspendKeyLongPress=lock' "$dropin" >/dev/null ||
  fail "drop-in overrides the suspend key long-press default of hibernate"
if grep -F 'HandleLidSwitchDocked' "$dropin" >/dev/null; then
  fail "docked lid close must stay ignored so clamshell displays are not locked" "$(cat "$dropin")"
fi
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

# The migration applies the same drop-in on existing installs, once, and
# reloads logind so it takes effect without tearing down the session.
mkdir -p "$tmp_dir/conf-migration"

OMARCHY_DMI_PATH="$tmp_dir/dmi-match" OMARCHY_LOGIND_CONF_DIR="$tmp_dir/conf-migration" \
  CALLS_FILE="$calls" PATH="$tmp_dir/bin:$PATH" bash "$migration" >/dev/null

migration_dropin="$tmp_dir/conf-migration/50-ideapad-suspend.conf"
grep -Fx 'HandleLidSwitch=lock' "$migration_dropin" >/dev/null ||
  fail "migration writes the lock-on-lid drop-in"
grep -Fx 'systemctl reload systemd-logind' "$calls" >/dev/null ||
  fail "migration reloads logind after writing the drop-in" "$(cat "$calls")"
pass "migration writes the lock-on-lid drop-in and reloads logind"

# A second run must not escalate at all.
: >"$calls"
OMARCHY_DMI_PATH="$tmp_dir/dmi-match" OMARCHY_LOGIND_CONF_DIR="$tmp_dir/conf-migration" \
  CALLS_FILE="$calls" PATH="$tmp_dir/bin:$PATH" bash "$migration" >/dev/null ||
  fail "migration is idempotent once the drop-in exists"
[[ ! -s $calls ]] ||
  fail "migration runs no privileged commands once the drop-in exists" "$(cat "$calls")"
pass "migration is idempotent once the drop-in exists"

# And it must not run at all on other hardware.
rm -f "$tmp_dir/conf-migration/50-ideapad-suspend.conf"
: >"$calls"
OMARCHY_DMI_PATH="$tmp_dir/dmi-other" OMARCHY_LOGIND_CONF_DIR="$tmp_dir/conf-migration" \
  CALLS_FILE="$calls" PATH="$tmp_dir/bin:$PATH" bash "$migration" >/dev/null ||
  fail "migration exits cleanly on unmatched hardware"
[[ ! -s $calls ]] ||
  fail "migration runs no privileged commands on unmatched hardware" "$(cat "$calls")"
[[ ! -e $tmp_dir/conf-migration/50-ideapad-suspend.conf ]] ||
  fail "migration writes nothing on unmatched hardware"
pass "migration no-ops on unmatched hardware"
