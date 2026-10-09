#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# The backend talks to the display with HID feature-report ioctls on a hidraw
# node. Load the command as a module, point it at a fake hidraw sysfs tree, and
# stand a fake display in for the ioctl so the report layout, the percent
# conversion and the stepping are exercised without the hardware.
cat >"$test_tmp/driver.py" <<'PY'
import contextlib
import importlib.machinery
import importlib.util
import io
import os
import struct
import sys

root, sysfs, scenario = sys.argv[1:4]

loader = importlib.machinery.SourceFileLoader("lg", os.path.join(root, "bin/omarchy-brightness-display-lg"))
spec = importlib.util.spec_from_loader("lg", loader)
lg = importlib.util.module_from_spec(spec)
loader.exec_module(lg)

MONITOR_CONTROL = bytes.fromhex("05800901a101")
VENDOR_DEFINED = bytes.fromhex("0600ff0901a101")


def add_hidraw(name, vendor, descriptor):
    device = os.path.join(sysfs, name, "device")
    os.makedirs(device)
    with open(os.path.join(device, "uevent"), "w") as uevent_file:
        uevent_file.write(f"DRIVER=hid-generic\nHID_ID=0003:{vendor}:00009A40\n")
    with open(os.path.join(device, "report_descriptor"), "wb") as descriptor_file:
        descriptor_file.write(descriptor)


class FakeDisplay:
    def __init__(self, raw):
        self.raw = raw
        self.opened = []
        self.written = []

    def open(self, path, flags):
        self.opened.append(path)
        return 99

    def close(self, fd):
        pass

    def ioctl(self, fd, request, report):
        direction, size, kind, number = request >> 30, (request >> 16) & 0x3FFF, (request >> 8) & 0xFF, request & 0xFF
        assert (direction, kind, size) == (3, ord("H"), 7), hex(request)
        assert len(report) == 7 and report[0] == 0, bytes(report)
        if number == 0x07:
            struct.pack_into("<IH", report, 1, self.raw, 0)
        elif number == 0x06:
            self.raw = struct.unpack_from("<I", report, 1)[0]
            self.written.append(bytes(report))
        else:
            raise AssertionError(hex(request))


def run(display, *args):
    lg.HIDRAW_SYSFS = sysfs
    lg.os.open, lg.os.close, lg.fcntl.ioctl = display.open, display.close, display.ioctl
    out, err = io.StringIO(), io.StringIO()
    with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
        status = lg.main(list(args))
    return status, out.getvalue().strip(), err.getvalue().strip()


def check(condition, detail):
    if not condition:
        print(detail)
        sys.exit(1)


if scenario == "conversion":
    check(lg.to_percent(400) == 0 and lg.to_percent(54000) == 100, "range ends")
    check(lg.to_percent(34168) == 63 and lg.to_raw(63) == 34168, "63% round trip")
    check(lg.to_percent(0) == 0 and lg.to_percent(60000) == 100, "out-of-range raw values are clamped")
    check(all(lg.to_percent(lg.to_raw(p)) == p for p in range(101)), "every percent survives a round trip")

elif scenario == "steps":
    cases = [
        ("50%", 63, 50), ("+5%", 63, 68), ("5%-", 63, 58), ("+1%", 63, 64), ("1%-", 63, 62),
        ("+5%", 98, 100), ("5%-", 8, 3), ("+5%", 4, 5), ("5%-", 5, 4), ("5%-", 1, 1),
        ("0%", 63, 1), ("150%", 63, 100),
    ]
    for step, current, expected in cases:
        actual = lg.target_percent(step, current)
        check(actual == expected, f"{step} from {current}: expected {expected}, got {actual}")
    for step in ["", "5", "up", "-5%", "+5", "5%+"]:
        check(lg.target_percent(step, 63) is None, f"{step!r} should be rejected")

elif scenario == "discovery":
    add_hidraw("hidraw0", "000005AC", MONITOR_CONTROL)
    add_hidraw("hidraw2", "0000043E", VENDOR_DEFINED)
    add_hidraw("hidraw3", "0000043E", MONITOR_CONTROL)
    os.makedirs(os.path.join(sysfs, "hidraw9"))
    lg.HIDRAW_SYSFS = sysfs
    check(lg.find_devices() == ["/dev/hidraw3"], f"found {lg.find_devices()}")

elif scenario == "read":
    add_hidraw("hidraw3", "0000043E", MONITOR_CONTROL)
    display = FakeDisplay(34168)
    status, out, err = run(display)
    check((status, out) == (0, "63"), f"status {status} out {out!r} err {err!r}")
    check(display.opened == ["/dev/hidraw3"] and not display.written, "a read opens the device and writes nothing")

elif scenario == "write":
    add_hidraw("hidraw3", "0000043E", MONITOR_CONTROL)
    display = FakeDisplay(34168)
    status, out, err = run(display, "5%-")
    check((status, out) == (0, "58"), f"status {status} out {out!r} err {err!r}")
    expected = b"\x00" + struct.pack("<IH", lg.to_raw(58), 0)
    check(display.written == [expected], f"wrote {display.written}, expected {expected}")
    status, out, err = run(display, "bogus")
    check(status == 1 and len(display.written) == 1, "an invalid step writes nothing")

elif scenario == "missing":
    add_hidraw("hidraw2", "0000043E", VENDOR_DEFINED)
    display = FakeDisplay(34168)
    status, out, err = run(display, "+5%")
    check(status == 1 and not display.opened, f"status {status} opened {display.opened}")

elif scenario == "ambiguous":
    add_hidraw("hidraw3", "0000043E", MONITOR_CONTROL)
    add_hidraw("hidraw7", "0000043E", MONITOR_CONTROL)
    display = FakeDisplay(34168)
    status, out, err = run(display, "+5%")
    check(status == 1 and not display.opened and not display.written, f"status {status} opened {display.opened}")
    check("cannot be told apart" in err, err)

else:
    raise SystemExit(f"unknown scenario {scenario}")
PY

run_scenario() {
  local scenario="$1"
  local sysfs="$test_tmp/sysfs-$scenario"

  mkdir -p "$sysfs"
  python3 "$test_tmp/driver.py" "$ROOT" "$sysfs" "$scenario" 2>&1
}

check_scenario() {
  local scenario="$1"
  local description="$2"
  local output=""

  output=$(run_scenario "$scenario") || fail "$description" "$output"
  pass "$description"
}

check_scenario conversion "LG raw brightness converts to and from percent"
check_scenario steps "LG brightness steps match the other display backends"
check_scenario discovery "only the LG monitor-control hidraw device is selected"
check_scenario read "LG brightness is read from the feature report"
check_scenario write "LG brightness is written as a six-byte feature report"
check_scenario missing "a missing LG controls device is an error"
check_scenario ambiguous "several LG controls devices are refused instead of guessed"
