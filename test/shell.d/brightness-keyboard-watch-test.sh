#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

python3 - "$ROOT/bin/omarchy-brightness-keyboard-watch" <<'PY'
import runpy
import sys

follow = runpy.run_path(sys.argv[1])["follow"]
g = follow.__globals__

class Seq:
    def __init__(self, values):
        self.values = list(values)
        self.applied = []

    def read_level(self):
        return self.values.pop(0) if self.values else self.applied[-1][0]

    def apply(self, cmd):
        self.applied.append((cmd.level, cmd.osd))

seq = Seq([1, 3, 3])
g["read_level"] = seq.read_level
g["apply"] = seq.apply
g["read_rgb"] = lambda: (1, 2, 3)

last = follow(0, osd=True)
if last != 3 or seq.applied != [(1, True), (3, True)]:
    raise SystemExit(f"catch-up last={last} applies={seq.applied}")

seq = Seq([2])
g["read_level"] = seq.read_level
g["apply"] = seq.apply
last = follow(2, osd=True)
if last != 2 or seq.applied != []:
    raise SystemExit(f"stable last={last} applies={seq.applied}")
PY

pass "follow applies every sysfs change that happens during a slow apply"
pass "follow is a no-op when the level did not change"

python3 - "$ROOT/bin/omarchy-brightness-keyboard-watch" <<'PY'
import errno
import os
import runpy
import sys

open_hw = runpy.run_path(sys.argv[1])["open_hw"]
g = open_hw.__globals__


class FakeOS:
    O_RDONLY = os.O_RDONLY

    def __init__(self, err):
        self.err = err
        self.closed = False

    def open(self, path, flags):
        return 7

    def read(self, fd, n):
        raise OSError(self.err, "x")

    def close(self, fd):
        self.closed = True


nodata = FakeOS(errno.ENODATA)
g["os"] = nodata
fd = open_hw()
if fd != 7 or nodata.closed:
    raise SystemExit(f"ENODATA fd={fd} closed={nodata.closed}")

io = FakeOS(errno.EIO)
g["os"] = io
try:
    open_hw()
except OSError as e:
    if e.errno != errno.EIO or not io.closed:
        raise SystemExit(f"EIO errno={e.errno} closed={io.closed}")
else:
    raise SystemExit("EIO was swallowed")
PY

pass "open_hw keeps the fd when brightness_hw_changed has never fired"
pass "open_hw still raises other read errors"

python3 - "$ROOT/bin/omarchy-brightness-keyboard-watch" <<'PY'
import runpy
import sys

g = runpy.run_path(sys.argv[1])
packets = g["chassis_packets"]

def starts(seq, sig):
    return any(pkt[: len(sig)] == bytes(sig) for pkt in seq)

off = packets(0, (9, 8, 7))
if not starts(off, (0x5D, 0xC0, 0x03, 0x00)) or starts(off, (0x5D, 0xC0, 0x03, 0x01)):
    raise SystemExit(f"off packets lost the leave-mode byte: {[pkt[:4].hex() for pkt in off]}")

lit = packets(2, (9, 8, 7))
if starts(lit, (0x5D, 0xC0, 0x03, 0x01)) or starts(lit, (0x5D, 0xC0, 0x03, 0x00)):
    raise SystemExit("a lit level still enters host dynamic-lighting")
if not starts(lit, (0x5D, 0xBA, 0xC5, 0xC4, 2)):
    raise SystemExit("lit level did not reach the brightness packet")
zones = [pkt for pkt in lit if pkt[1] == 0xB3]
if [pkt[2] for pkt in zones] != [0, 1] or any(pkt[4:7] != bytes((9, 8, 7)) for pkt in zones):
    raise SystemExit(f"zones={[pkt[:8].hex() for pkt in zones]}")
PY

pass "off leaves host dynamic-lighting and a lit level never enters it"

python3 - "$ROOT/bin/omarchy-brightness-keyboard-watch" <<'PY'
import runpy
import sys

ns = runpy.run_path(sys.argv[1])["chassis_packets"].__globals__
if ns["Gio"] is None:
    ns["Gio"] = object()

led = ns["ChassisLed"]()
led._path = "/xyz/ljones/aura/18c6_stale"
seen = []

def send_one(packet):
    seen.append((led._path, packet[1]))
    if led._path == "/xyz/ljones/aura/18c6_stale":
        raise RuntimeError("stale path")

led._send_one = send_one
led.apply(ns["Apply"](level=1, rgb=(1, 2, 3), osd=False))
if not seen or seen[0] != ("/xyz/ljones/aura/18c6_stale", 0xB9):
    raise SystemExit(f"first send did not use the cached path: {seen[:1]}")
if not any(path is None and kind == 0xBA for path, kind in seen[1:]):
    raise SystemExit(f"retry did not resend after the cache clear: {seen[:4]}")
PY

pass "a stale Aura path is dropped and the same level is sent again"

python3 - "$ROOT/bin/omarchy-brightness-keyboard-watch" <<'PY'
import runpy
import sys

ns = runpy.run_path(sys.argv[1])["apply"].__globals__
order = []

class Dummy:
    def wait(self, timeout=2):
        order.append("wait")

    def kill(self):
        order.append("kill")

def show_osd(cmd):
    order.append(("osd", cmd.osd))
    return Dummy()

def chassis_apply(cmd):
    order.append(("chassis", cmd.level))

ns["show_osd"] = show_osd
ns["CHASSIS"].apply = chassis_apply
ns["apply"](ns["Apply"](level=1, rgb=(4, 5, 6), osd=True))
ns["apply"](ns["Apply"](level=1, rgb=(4, 5, 6), osd=False))
if order != [("osd", True), ("chassis", 1), "wait", ("chassis", 1)]:
    raise SystemExit(f"order={order}")
PY

pass "the OSD opens before the chassis writes"
pass "sync does not open the OSD"

python3 - "$ROOT/bin/omarchy-brightness-keyboard-watch" <<'PY'
import os
import runpy
import sys
import tempfile

ns = runpy.run_path(sys.argv[1])["apply"].__globals__
if ns["Gio"] is None:
    ns["Gio"] = object()

runtime = tempfile.mkdtemp()
ns["os"].environ["XDG_RUNTIME_DIR"] = runtime
order = []
real_flock = ns["fcntl"].flock

def flock(fd, op):
    order.append("lock")
    return real_flock(fd, op)

ns["fcntl"].flock = flock
led = ns["ChassisLed"]()
led._path = "/xyz/ljones/aura/18c6_4_5"

def send_one(packet):
    order.append("send")

led._send_one = send_one
led.apply(ns["Apply"](level=1, rgb=(1, 2, 3), osd=False))
led.apply(ns["Apply"](level=1, rgb=(1, 2, 3), osd=False))
if order[0] != "lock" or "send" not in order:
    raise SystemExit(f"order={order[:4]}")
if not os.path.exists(os.path.join(runtime, "omarchy-brightness-keyboard-watch.lock")):
    raise SystemExit("lock file was not created")
PY

pass "a theme sync cannot interleave chassis packets with the waiter"

python3 - "$ROOT/bin/omarchy-brightness-keyboard-watch" <<'PY'
import os
import runpy
import sys

ns = runpy.run_path(sys.argv[1])["watch"].__globals__
calls = []
real_isfile = os.path.isfile

def follow(last, *, osd):
    calls.append((last, osd))
    return 1 if last is None else last

class Poller:
    def __init__(self):
        self.n = 0

    def register(self, *args):
        return None

    def unregister(self, *args):
        return None

    def poll(self, timeout=None):
        self.n += 1
        if self.n == 1:
            if timeout != ns["SOFTWARE_MS"]:
                raise SystemExit(f"timeout={timeout}")
            return []
        if self.n == 2:
            if timeout != 0:
                raise SystemExit(f"recheck timeout={timeout}")
            return []
        raise SystemExit(0)

def open_hw():
    calls.append("open")
    return 3

os.path.isfile = lambda path: True
ns["follow"] = follow
ns["open_hw"] = open_hw
ns["select"].poll = lambda: Poller()
try:
    ns["watch"]()
except SystemExit as exc:
    if exc.code not in (0, None):
        raise
finally:
    os.path.isfile = real_isfile

if calls[:4] != [(None, False), "open", (1, False), (1, False)]:
    raise SystemExit(f"calls={calls[:4]}")
PY

pass "startup rechecks the level after the sysfs drain"
pass "a brightnessctl write is applied without an OSD"

python3 - "$ROOT/bin/omarchy-brightness-keyboard-watch" <<'PY'
import os
import runpy
import select
import sys

ns = runpy.run_path(sys.argv[1])["watch"].__globals__
calls = []
real_isfile = os.path.isfile
real_lseek = os.lseek
real_read = os.read
real_close = os.close

def follow(last, *, osd):
    calls.append((last, osd))
    return 1 if last is None else last

class Poller:
    def __init__(self):
        self.n = 0

    def register(self, *args):
        return None

    def unregister(self, *args):
        return None

    def poll(self, timeout=None):
        self.n += 1
        if self.n == 1:
            return []
        if self.n == 2:
            return [(3, select.POLLPRI)]
        raise SystemExit(0)

def open_hw():
    calls.append("open")
    return 3

os.path.isfile = lambda path: True
os.lseek = lambda fd, off, whence: 0
os.read = lambda fd, n: b""
os.close = lambda fd: None
ns["follow"] = follow
ns["open_hw"] = open_hw
ns["select"].poll = lambda: Poller()
try:
    ns["watch"]()
except SystemExit as exc:
    if exc.code not in (0, None):
        raise
finally:
    os.path.isfile = real_isfile
    os.lseek = real_lseek
    os.read = real_read
    os.close = real_close

if (1, False) in calls[3:]:
    raise SystemExit(f"silent apply ate the key: {calls}")
if (1, True) not in calls:
    raise SystemExit(f"hardware path did not show the OSD: {calls}")
PY

pass "a key that arrives as the re-read wakes still shows the OSD"

python3 - "$ROOT/bin/omarchy-brightness-keyboard-watch" <<'PY'
import runpy
import sys

ns = runpy.run_path(sys.argv[1])["apply"].__globals__
if ns["Gio"] is None:
    ns["Gio"] = object()
ns["os"].environ["XDG_RUNTIME_DIR"] = "/dev/null/omarchy-brightness-lock"
sent = []
led = ns["ChassisLed"]()
led._path = "/xyz/ljones/aura/18c6_4_5"
led._send_one = lambda packet: sent.append(packet[1])
led.apply(ns["Apply"](level=2, rgb=(1, 2, 3), osd=False))
if 0xBA not in sent:
    raise SystemExit(f"chassis writes did not run without a lock dir: {sent}")
PY

pass "theme sync still sends chassis packets when the lock directory cannot be created"
