#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

ROOT="$ROOT" python3 <<'PY'
import fcntl
import importlib.util
import os
import struct
import tempfile
from pathlib import Path

root = Path(os.environ["ROOT"])
ctl_path = root / "shell/plugins/panels/mv7plus/mv7plus-ctl.py"

spec = importlib.util.spec_from_file_location("mv7plus_ctl", ctl_path)
ctl = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ctl)

# Exact MV7+ GET request framing (gain_db: prefix 0x00, feat 0x01 0x02, seq 1).
req = ctl.build_packet(seq=1, hdr=0x03, cmd=ctl.CMD_GET_FEAT, payload=bytes([0x00, 0x01, 0x02]))
assert len(req) == 64
assert req[:18] == bytes.fromhex("01101122010308087008010202000102820a")

# Captured real MV7+ firmware response for gain_db = 20.0 dB (0x07d0 = 2000).
real_res = bytes.fromhex("011211221a03080a700a03020200010207d0770d").ljust(64, b"\x00")
parsed = ctl.parse_response(real_res)
assert parsed == (0x00, (0x01, 0x02), bytes([0x07, 0xD0])), f"unexpected parse: {parsed}"
assert ctl.decode_value("u16x100", parsed[2]) == 20.0

# Corrupted CRC must be rejected.
bad = bytearray(real_res)
bad[real_res[1]] ^= 0xFF
assert ctl.parse_response(bytes(bad)) is None

# Non-GET response command must be rejected.
set_pkt = ctl.build_packet(seq=8, hdr=0x00, cmd=ctl.CMD_SET_FEAT, payload=bytes([0x00, 0x01, 0x02, 0x07, 0xD0]))
assert ctl.parse_response(set_pkt) is None

# Value encoding clamps and snaps cleanly.
assert ctl.encode_value("u8", 150, 0, 100) == bytes([100])
assert ctl.encode_value("u8", -5, 0, 100) == bytes([0])
assert ctl.encode_value("u16x100", 28.3, 0.0, 36.0) == struct.pack(">H", 2850)
assert ctl.encode_value("u16x100", 50.0, 0.0, 36.0) == struct.pack(">H", 3600)
assert ctl.encode_value("i16", -150, -100, 100) == struct.pack(">h", -100)
assert ctl.encode_value("i16", 40, -100, 100) == struct.pack(">h", 40)
assert ctl.decode_value("i16", struct.pack(">h", -60)) == -60

# Sysfs hidraw discovery matches only Shure MV7+ (14ed:1019), not original MV7 (14ed:1012).
with tempfile.TemporaryDirectory() as tmp:
    orig_mv7 = Path(tmp) / "hidraw0/device"
    orig_mv7.mkdir(parents=True)
    (orig_mv7 / "uevent").write_text("HID_ID=0003:000014ED:00001012\n")
    assert ctl.find_mv7plus(str(Path(tmp) / "hidraw*/device/uevent")) is None

    mv7_plus = Path(tmp) / "hidraw2/device"
    mv7_plus.mkdir(parents=True)
    (mv7_plus / "uevent").write_text("HID_ID=0003:000014ED:00001019\n")
    assert ctl.find_mv7plus(str(Path(tmp) / "hidraw*/device/uevent")) == "/dev/hidraw2"

    # Non-blocking lock times out cleanly instead of hanging forever.
    lock_file = str(Path(tmp) / "hid.lock")
    held = ctl.acquire_lock(lock_file, timeout_s=0.5)
    try:
        timed_out = False
        try:
            ctl.acquire_lock(lock_file, timeout_s=0.1)
        except TimeoutError:
            timed_out = True
        assert timed_out, "second lock acquisition should time out"
    finally:
        fcntl.flock(held, fcntl.LOCK_UN)
        os.close(held)
PY

pass "Shure MV7+ HID protocol, value bounds, discovery, and locking pass"
