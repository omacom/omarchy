#!/bin/bash

set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

require_command python3

python3 - "$ROOT" <<'PYTHON'
import colorsys
import contextlib
import importlib.util
import io
import os
import subprocess
import sys
import tempfile
from unittest.mock import patch

root = sys.argv[1]
module_path = os.path.join(root, "lib/omarchy/keychron_rgb.py")
spec = importlib.util.spec_from_file_location("keychron_rgb", module_path)
rgb = importlib.util.module_from_spec(spec)
spec.loader.exec_module(rgb)

red, green, blue = 0x66, 0x33, 0x99
h, s, v = colorsys.rgb_to_hsv(red / 255, green / 255, blue / 255)
expected_hsv = [round(h * 255), round(s * 255), round(v * 255)]

with patch.object(rgb, "transact", side_effect=[b"\x07", b"\x07", b"\x09"]) as transact:
  with patch.object(rgb.time, "sleep"):
    with contextlib.redirect_stdout(io.StringIO()) as output:
      rgb.set_color(1, "663399")

assert transact.call_args_list[0].args == (1, [rgb.CMD_BACKLIGHT_SET, rgb.CH_LIGHTING, rgb.LID_EFFECT, 1])
assert transact.call_args_list[1].args == (1, [rgb.CMD_BACKLIGHT_SET, rgb.CH_LIGHTING, rgb.LID_COLOR, *expected_hsv])
assert transact.call_args_list[2].args == (1, [rgb.CMD_BACKLIGHT_SAVE, rgb.CH_LIGHTING])
assert "v=" in output.getvalue()
print("ok - set sends HSV including brightness and persists it")

with patch.object(rgb, "transact", side_effect=[b"\x07", b"\x07", None]):
  try:
    with contextlib.redirect_stdout(io.StringIO()) as output:
      rgb.set_color(1, "663399")
  except SystemExit as error:
    assert error.code == 3
  else:
    raise AssertionError("failed save must return an error")
assert "saved" not in output.getvalue()
print("ok - failed save does not report success")

reply = bytes([rgb.CMD_BACKLIGHT_GET, rgb.CH_LIGHTING, rgb.LID_COLOR, 32, 180, 64])
with patch.object(rgb, "transact", return_value=reply):
  with contextlib.redirect_stdout(io.StringIO()) as output:
    rgb.get_color(1)
expected_rgb = tuple(round(channel * 255) for channel in colorsys.hsv_to_rgb(32 / 255, 180 / 255, 64 / 255))
expected_color = "color #{:02x}{:02x}{:02x}".format(*expected_rgb)
assert output.getvalue().startswith(expected_color), output.getvalue()
print("ok - get converts the reported brightness")

with tempfile.TemporaryDirectory() as sysfs:
  for name, descriptor in (("hidraw0", b"prefix" + rgb.MAGIC + b"suffix"), ("hidraw1", b"not config")):
    path = os.path.join(sysfs, name, "device")
    os.makedirs(path)
    with open(os.path.join(path, "report_descriptor"), "wb") as file:
      file.write(descriptor)
  assert rgb.is_config_interface("hidraw0", sysfs)
  assert not rgb.is_config_interface("hidraw1", sysfs)
  assert not rgb.is_config_interface("hidraw2", sysfs)
  helper = os.path.join(root, "default/udev/keychron-config-check")
  matched = subprocess.run([sys.executable, helper, "--sysfs-root", sysfs, "hidraw0"], capture_output=True, text=True)
  rejected = subprocess.run([sys.executable, helper, "--sysfs-root", sysfs, "hidraw1"], capture_output=True, text=True)
  assert matched.returncode == 0 and matched.stdout.strip() == "keychron-config"
  assert rejected.returncode != 0 and not rejected.stdout
print("ok - config-interface check matches only the config descriptor")
PYTHON

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin" "$tmpdir/home/.local/state/omarchy/current/theme"
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/omarchy-hw-keychron"
printf '#!/bin/bash\ntouch "$KEYCHRON_CALLED"\n' >"$tmpdir/bin/omarchy-keychron-rgb"
chmod +x "$tmpdir/bin/omarchy-hw-keychron" "$tmpdir/bin/omarchy-keychron-rgb"
printf '#ffffff\n' >"$tmpdir/home/.local/state/omarchy/current/theme/keyboard.rgb"

if HOME="$tmpdir/home" PATH="$tmpdir/bin:$PATH" KEYCHRON_CALLED="$tmpdir/called" \
  "$ROOT/bin/omarchy-theme-set-keyboard-keychron"; then
  :
else
  fail "theme handler skips absent Keychron hardware"
fi
[[ ! -e $tmpdir/called ]] || fail "theme handler does not probe transport without Keychron hardware"
pass "theme handler skips the transport when Keychron hardware is absent"

grep -Fxq 'omarchy-theme-set-keyboard-keychron' "$ROOT/bin/omarchy-theme-set-keyboard" || fail "theme dispatcher invokes the Keychron handler"
pass "theme dispatcher invokes the Keychron handler"

grep -Fq 'PROGRAM=="/usr/lib/udev/omarchy-keychron-config-check %k"' "$ROOT/default/udev/keychron-rgb.rules" || fail "udev invokes the config-channel descriptor matcher"
pass "udev grants access through the config-channel descriptor matcher"

mkdir -p "$tmpdir/transport-bin"
printf '#!/bin/bash\nprintf "%%s\\n" "$@" >"$KEYCHRON_ARGS"\n' >"$tmpdir/transport-bin/python3"
chmod +x "$tmpdir/transport-bin/python3"

KEYCHRON_ARGS="$tmpdir/default-path-args" env -u OMARCHY_PATH PATH="$tmpdir/transport-bin:$PATH" \
  "$ROOT/bin/omarchy-keychron-rgb" get
mapfile -t rgb_args <"$tmpdir/default-path-args"
[[ ${rgb_args[0]} == "/usr/share/omarchy/lib/omarchy/keychron_rgb.py" && ${rgb_args[1]} == "get" ]] || fail "RGB command uses the packaged path without OMARCHY_PATH"
pass "RGB command resolves the packaged module path without OMARCHY_PATH"

OMARCHY_PATH=/tmp/omarchy-test KEYCHRON_ARGS="$tmpdir/configured-path-args" PATH="$tmpdir/transport-bin:$PATH" \
  "$ROOT/bin/omarchy-keychron-rgb" set 123456
mapfile -t rgb_args <"$tmpdir/configured-path-args"
[[ ${rgb_args[0]} == "/tmp/omarchy-test/lib/omarchy/keychron_rgb.py" && ${rgb_args[1]} == "set" && ${rgb_args[2]} == "123456" ]] || fail "RGB command honors OMARCHY_PATH when set"
pass "RGB command continues to honor OMARCHY_PATH when set"
