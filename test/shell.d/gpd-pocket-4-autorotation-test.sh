#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
rotate="$ROOT/bin/omarchy-hw-gpd-pocket-4-rotate"
unit="$ROOT/default/systemd/user/omarchy-gpd-pocket-4-rotate.service"

grep -Fx 'ExecCondition=/usr/bin/omarchy-hw-gpd-pocket-4' "$unit" >/dev/null ||
  fail "the rotate unit starts on machines without the hardware"
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
grep -q 'lua_escape' "$rotate" ||
  fail "device names reach hyprctl eval unescaped, so a crafted name runs Lua"
grep -q 'wait_for_sensor' "$rotate" ||
  fail "a late sensor proxy leaves autorotation dead for the session"
grep -q 'timeout_add_seconds' "$rotate" ||
  fail "a Hyprland reload wipes the applied transform with nothing restoring it"
grep -q 'orientation.unpack()' "$rotate" &&
  fail "properties-changed treats unpacked dbus strings as Variants, so rotation dies"
pass "the rotate daemon finds Hyprland, claims the sensor, and prefers the GPD digitizer"

python3 - "$rotate" <<'PY'
import importlib.machinery
import importlib.util
import sys

loader = importlib.machinery.SourceFileLoader("gpd_rotate", sys.argv[1])
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)

class Variant:
    def __init__(self, value):
        self._value = value

    def unpack(self):
        return self._value

if mod.dbus_unpack("right-up") != "right-up":
    raise SystemExit("dbus_unpack must accept an already-unpacked string")
if mod.dbus_unpack(Variant("left-up")) != "left-up":
    raise SystemExit("dbus_unpack must unpack a Variant")
if mod.dbus_unpack(None) is not None:
    raise SystemExit("dbus_unpack must pass None through")
if mod.dbus_unpack(Variant({"AccelerometerOrientation": "bottom-up"})) != {
    "AccelerometerOrientation": "bottom-up"
}:
    raise SystemExit("dbus_unpack must unpack a properties dict Variant")

if mod.lua_escape('nvtk0603:00-0603:f001') != 'nvtk0603:00-0603:f001':
    raise SystemExit("lua_escape must leave plain device names alone")
if mod.lua_escape('evil"}, os.execute("id"), x("') != 'evil\\"}, os.execute(\\"id\\"), x(\\"':
    raise SystemExit("lua_escape must neutralize quotes in device names")
if mod.lua_escape('a\\b') != 'a\\\\b':
    raise SystemExit("lua_escape must escape backslashes before quotes")
if mod.lua_escape('a\x01b\x7fc') != 'abc':
    raise SystemExit("lua_escape must strip control characters")
PY
pass "properties-changed accepts both Variant and unpacked dbus values"


! grep -q "gpd-pocket-4-rotate" "$ROOT/install/user/first-run/enable-user-units.sh" || fail "autorotation must remain opt-in"
pass "autorotation is not enabled by first-run"
python3 -m py_compile "$rotate"
pass "autorotation daemon compiles"
python3 "$ROOT/test/shell.d/fixtures/gpd-autorotation-recovery.py" "$rotate"
pass "production startup, reload, sensor restart and compositor fallback recovery pass"
