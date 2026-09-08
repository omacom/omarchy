#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-gpd-pocket-4"
rotate="$ROOT/bin/omarchy-hw-gpd-pocket-4-rotate"
leaf="$ROOT/install/hardware/gpd-pocket-4.sh"
all="$ROOT/install/hardware/all.sh"
unit="$ROOT/default/systemd/user/omarchy-gpd-pocket-4-rotate.service"
first_run_units="$ROOT/install/user/first-run/enable-user-units.sh"
migration=$(grep -l "gpd-pocket-4" "$ROOT"/migrations/*.sh | head -1)

grep -q 'run_logged .*hardware/gpd-pocket-4.sh' "$all" ||
  fail "GPD Pocket 4 setup runs during hardware install"
pass "GPD Pocket 4 setup runs during hardware install"

[[ -n $migration ]] || fail "a migration enables GPD Pocket 4 setup on existing installs"
grep -q 'source "$OMARCHY_PATH/install/hardware/gpd-pocket-4.sh"' "$migration" ||
  fail "the migration reuses the install leaf"
grep -q 'systemctl --user enable --now omarchy-gpd-pocket-4-rotate.service' "$migration" &&
  fail "the GPD migration enable --now fails when systemd has not seen the unit yet"
grep -q 'ln -sfn "$unit_source" "$user_unit"' "$migration" ||
  fail "the GPD migration does not publish the unit from OMARCHY_PATH"
pass "a migration enables GPD Pocket 4 setup on existing installs"

grep -q 'omarchy-gpd-pocket-4-rotate.service' "$first_run_units" ||
  fail "first-run does not enable the GPD Pocket 4 rotate unit"
pass "first-run enables the GPD Pocket 4 rotate unit"

grep -Fx 'ExecCondition=${OMARCHY_PATH}/bin/omarchy-hw-gpd-pocket-4' "$unit" >/dev/null ||
  fail "the rotate unit starts on machines without the hardware"
grep -Fx 'ExecStart=${OMARCHY_PATH}/bin/omarchy-hw-gpd-pocket-4-rotate' "$unit" >/dev/null ||
  fail "the rotate unit runs the packaged /usr/bin copy that a linked checkout does not have"
grep -Fx 'ConditionEnvironment=OMARCHY_PATH' "$unit" >/dev/null ||
  fail "the rotate unit can start before OMARCHY_PATH is imported"
grep -Fx 'ConditionEnvironment=WAYLAND_DISPLAY' "$unit" >/dev/null ||
  fail "the rotate unit can start without a Wayland display"
grep -F 'wayland-session-waitenv.service' "$unit" >/dev/null ||
  fail "the rotate unit starts before UWSM imports the graphical session environment"
pass "the rotate unit stays inert off-hardware and waits for the session environment"

grep -q 'XDG_RUNTIME_DIR' "$rotate" ||
  fail "the rotate daemon looks for Hyprland under the obsolete /tmp/hypr path"
! grep -q '/tmp/hypr' "$rotate" ||
  fail "the rotate daemon still probes /tmp/hypr for the compositor socket"
grep -q 'gi.require_version("Gio", "2.0")' "$rotate" ||
  fail "the rotate daemon imports Gio without pinning the GI version"
grep -q 'nvtk0603' "$rotate" ||
  fail "the rotate daemon does not prefer the GPD digitizer over other tablets"
grep -q 'ClaimAccelerometer failed' "$rotate" ||
  fail "a failed accelerometer claim would crash-loop the user unit"
pass "the rotate daemon finds Hyprland, claims the sensor, and prefers the GPD digitizer"

grep -q 'sudo tee /etc/limine-entry-tool.d/gpd-pocket4-orientation.conf' "$leaf" ||
  fail "the install leaf writes kernel cmdline as root"
grep -q 'sudo tee /etc/udev/rules.d/99-gpd-pocket4-touchscreen.rules' "$leaf" ||
  fail "the install leaf writes the digitizer matrix as root"
grep -q 'udevadm trigger' "$leaf" ||
  fail "the digitizer matrix is not applied until the next replug"
pass "the install leaf is sudo-safe and reloads the digitizer rule"

python3 -m py_compile "$rotate"
pass "the rotate daemon is valid Python"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/dmi"

printf 'G1628-04\n' >"$test_tmp/dmi/product_name"
printf 'GPD Pocket 4\n' >"$test_tmp/dmi/product_family"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
grep -qi "$1" "${OMARCHY_TEST_DMI}/product_name" 2>/dev/null ||
  grep -qi "$1" "${OMARCHY_TEST_DMI}/product_family" 2>/dev/null
SH
chmod +x "$test_tmp/bin/omarchy-hw-match"

# The real detector calls omarchy-hw-match; stub the matcher and keep the
# detector's G1628-04 / Pocket 4 patterns.
PATH="$test_tmp/bin:$PATH" OMARCHY_TEST_DMI="$test_tmp/dmi" "$detector"
pass "the detector matches a GPD Pocket 4 product name"

printf 'ThinkPad X1\n' >"$test_tmp/dmi/product_name"
printf 'ThinkPad\n' >"$test_tmp/dmi/product_family"
if PATH="$test_tmp/bin:$PATH" OMARCHY_TEST_DMI="$test_tmp/dmi" "$detector"; then
  fail "the detector matches unrelated hardware"
fi
pass "the detector rejects unrelated hardware"
