#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

ROOT="$ROOT" python3 <<'PY'
import contextlib
import fcntl
import importlib.machinery
import importlib.util
import io
import json
import os
import struct
import tempfile
from pathlib import Path

root = Path(os.environ["ROOT"])
cli_path = root / "bin/omarchy-audio-mv7plus"

loader = importlib.machinery.SourceFileLoader("omarchy_audio_mv7plus", str(cli_path))
spec = importlib.util.spec_from_loader(loader.name, loader)
ctl = importlib.util.module_from_spec(spec)
loader.exec_module(ctl)

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

# Timed-out HID readback raises TimeoutError instead of returning null silently.
class SilentMic(ctl.MV7Plus):
    def __init__(self):
        self.seq = 1
    def get_feat(self, pfx, feat):
        return None

silent = SilentMic()
for fn in (lambda: silent.read_one("mute"), lambda: silent.read_all(require_complete=True)):
    raised = False
    try:
        fn()
    except TimeoutError:
        raised = True
    assert raised, "timed-out HID read must raise TimeoutError"

# In-memory fake MV7+ device exercises atomic toggle and every CLI path.
initial_values = {
    "auto_level": 1, "gain_db": 20.0, "mute": 0, "hpf": 0, "limiter": 0,
    "compressor": 0, "denoiser": 0, "popper_stopper": 0, "tone_pct": 0,
    "reverb_output": 0, "reverb_type": 0, "reverb_intensity": 0,
    "reverb_monitor": 0, "mic_level": 100, "playback_level": 100,
}
shared_store = {}
for name, pfx, f0, f1, fmt, mn, mx in ctl.FEATURES:
    shared_store[(pfx, (f0, f1))] = ctl.encode_value(fmt, initial_values[name], mn, mx)

class FakeMic(ctl.MV7Plus):
    def __init__(self, path):
        self.seq = 1
        self.path = path
    def close(self):
        pass
    def get_feat(self, pfx, feat):
        return shared_store.get((pfx, feat))
    def set_feat(self, pfx, feat, val):
        shared_store[(pfx, feat)] = val

fake = FakeMic("/dev/hidraw9")
assert fake.toggle_named("mute") == {"mute": 1}
assert fake.toggle_named("mute") == {"mute": 0}
for bad_key in ("gain_db", "hpf", "bogus"):
    rejected = False
    try:
        fake.toggle_named(bad_key)
    except ValueError:
        rejected = True
    assert rejected, f"toggle_named must reject non-boolean {bad_key}"

# Exercise CLI parsing, human & JSON output, presets, and error paths.
orig_find = ctl.find_mv7plus
orig_cls = ctl.MV7Plus
orig_sleep = ctl.time.sleep

def invoke(argv):
    out, err = io.StringIO(), io.StringIO()
    with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
        rc = ctl.run(argv)
    return rc, out.getvalue().strip(), err.getvalue().strip()

with tempfile.TemporaryDirectory() as lock_tmp:
    orig_lock_path = ctl.lock_path
    ctl.lock_path = lambda: os.path.join(lock_tmp, "test.lock")
    ctl.time.sleep = lambda _s: None
    try:
        ctl.find_mv7plus = lambda: "/dev/hidraw9"
        ctl.MV7Plus = FakeMic

        rc, out, _ = invoke(["status"])
        assert rc == 0 and "Manual Gain:     20.0 dB" in out, out
        rc, out, _ = invoke(["status", "--json"])
        assert rc == 0
        payload = json.loads(out)
        assert payload["connected"] is True and payload["state"]["gain_db"] == 20.0

        # Leading --json flag (as used by Panel.qml) works on setters and presets.
        rc, out, _ = invoke(["--json", "gain", "24.5dB"])
        assert rc == 0 and json.loads(out)["state"] == {"gain_db": 24.5}
        rc, out, _ = invoke(["gain", "08"])
        assert rc == 0 and out == "8.0 dB"

        # Tone parsing: negative with and without --, leading zero, percent suffix.
        assert invoke(["tone", "-60"])[:2] == (0, "dark (-60%)")
        assert invoke(["--json", "tone", "--", "-40"])[0] == 0
        assert invoke(["tone"])[:2] == (0, "dark (-40%)")
        assert invoke(["tone", "+08%"])[:2] == (0, "bright (+8%)")

        # Atomic toggle, aliases, enum suffixes, reverb & monitor subcommands.
        assert invoke(["mute", "on"])[:2] == (0, "on")
        assert invoke(["mute", "toggle"])[:2] == (0, "off")
        assert invoke(["popper-stopper", "on"])[:2] == (0, "on")
        assert invoke(["hpf", "150Hz"])[:2] == (0, "150 Hz")
        assert invoke(["compressor", "heavy"])[:2] == (0, "heavy")
        assert invoke(["reverb", "type", "hall"])[:2] == (0, "hall")
        assert invoke(["reverb", "intensity", "08"])[:2] == (0, "8%")
        assert invoke(["reverb", "monitor", "toggle"])[:2] == (0, "on")
        assert invoke(["monitor", "mic", "75%"])[:2] == (0, "75%")
        assert invoke(["monitor", "playback", "40"])[:2] == (0, "40%")
        assert invoke(["monitor"])[:2] == (0, "mic 75%, playback 40%")

        # Presets return full confirmed state.
        rc, out, _ = invoke(["--json", "preset", "neutral"])
        assert rc == 0 and json.loads(out)["state"]["auto_level"] == 0
        rc, out, _ = invoke(["preset", "factory"])
        assert rc == 0 and "Mode:            auto" in out and "mic 100%, playback 100%" in out

        # Usage, range, overflow, and arity errors exit 2.
        for bad_argv in (
            ["bogus"],
            ["gain", "40"],
            ["tone", "150"],
            ["tone", "18446744073709551666"],
            ["hpf", "75", "extra"],
            ["status", "--json", "extra"],
            ["reverb", "type", "hall", "extra"],
            ["preset"],
        ):
            rc, _, _ = invoke(bad_argv)
            assert rc == 2, f"expected exit 2 for {bad_argv}, got {rc}"

        # Disconnected & permission error paths (human and --json).
        ctl.find_mv7plus = lambda: None
        assert invoke(["status"])[0] == 1
        rc, out, err = invoke(["--json", "status"])
        assert rc == 1 and json.loads(out) == {"connected": False} and err == ""

        ctl.find_mv7plus = lambda: "/dev/hidraw9"
        def deny_open(_path):
            raise PermissionError("denied")
        ctl.MV7Plus = deny_open
        rc, _, err = invoke(["status"])
        assert rc == 1 and "62-shure-mv7plus.rules" in err
        rc, out, err = invoke(["--json", "status"])
        assert rc == 1 and json.loads(out)["error"] == "permission" and err == ""

        # Partial read fails human status (exit 1) while --json preserves partial state for UI.
        class PartialMic(FakeMic):
            def get_feat(self, pfx, feat):
                if (pfx, feat) == (0x00, (0x01, 0x04)):
                    return None
                return super().get_feat(pfx, feat)
        ctl.MV7Plus = PartialMic
        rc, _, err = invoke(["status"])
        assert rc == 1 and "mute" in err
        rc, out, _ = invoke(["--json", "status"])
        assert rc == 0 and json.loads(out)["state"]["mute"] is None
    finally:
        ctl.find_mv7plus = orig_find
        ctl.MV7Plus = orig_cls
        ctl.time.sleep = orig_sleep
        ctl.lock_path = orig_lock_path
PY

pass "Shure MV7+ HID protocol, locking, atomic toggle, and CLI controls pass"

# Verify dispatch through the main omarchy router.
help_out="$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy" audio mv7plus --help)"
grep -q 'omarchy audio mv7plus status' <<<"$help_out" || fail "omarchy router serves mv7plus help" "$help_out"
rc=0
OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy" audio mv7plus bogus >/dev/null 2>&1 || rc=$?
(( rc == 2 )) || fail "omarchy router forwards mv7plus usage error (exit $rc, want 2)"
pass "omarchy audio mv7plus dispatches cleanly through bin/omarchy"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')

const src = fs.readFileSync(path.join(root, 'shell/plugins/panels/mv7plus/Store.js'), 'utf8')
  .replace(/^\.pragma library\s*\n/, '')
const sandbox = {}
vm.runInNewContext(src, sandbox)

// Multi-monitor sync: muting on monitor A updates monitor B immediately.
const execLog = []
const makePanel = (id) => ({
  id,
  synced: null,
  syncFromStore(st) { this.synced = Object.assign({}, st) },
  execCli(args) { execLog.push({ id, args }) }
})
const monA = makePanel('A')
const monB = makePanel('B')
sandbox.register(monA)
sandbox.register(monB)

sandbox.setOptimistic('micMuted', true)
assertEqual(monA.synced.micMuted, true, 'monitor A reflects optimistic mute')
assertEqual(monB.synced.micMuted, true, 'monitor B reflects optimistic mute immediately')

// Preset + queued CLI writes: rapid slider drags coalesce per control, sibling
// reverb subcommands do not collide, and preset snapshot merges non-pending keys.
sandbox.enqueue(['preset', 'neutral'], monA)
sandbox.setOptimistic('gainDb', 30.0)
sandbox.enqueue(['gain', '30'], monB)
sandbox.setOptimistic('gainDb', 32.0)
sandbox.enqueue(['gain', '32'], monB)
sandbox.enqueue(['reverb', 'on'], monA)
sandbox.enqueue(['reverb', 'type', 'hall'], monA)
assertEqual(execLog.length, 1, 'only one CLI command executes at a time across monitors')

sandbox.finishExec(JSON.stringify({
  connected: true,
  state: { auto_level: 0, gain_db: 28.0, mute: 0, denoiser: 0, hpf: 0 }
}))
assertEqual(monA.synced.autoLevel, false, 'preset auto_level merges even while gain write is queued')
assertEqual(monB.synced.micMuted, false, 'preset mute merges across monitors')
assertEqual(monA.synced.gainDb, 32.0, 'queued gain write is not reverted by earlier preset snapshot')
assertEqual(execLog.length, 2, 'coalesced gain write executes immediately after preset finishes')
assertDeepEqual(execLog[1].args, ['gain', '32'], 'rapid gain drags coalesce to latest value')

sandbox.finishExec(JSON.stringify({ connected: true, state: { gain_db: 32.0 } }))
assertEqual(monB.synced.gainDb, 32.0, 'confirmed gain updates all monitors')
assertDeepEqual(execLog[2].args, ['reverb', 'on'], 'reverb output write preserved')

sandbox.finishExec(JSON.stringify({ connected: true, state: { reverb_output: 1 } }))
assertDeepEqual(execLog[3].args, ['reverb', 'type', 'hall'], 'reverb type does not collide with reverb output')
sandbox.finishExec(JSON.stringify({ connected: true, state: { reverb_type: 1 } }))

// Unregistering leader hands off cleanly to remaining monitor and restarts
// detection if the MV7+ is present on PipeWire while not yet confirmed.
const makeHotplugPanel = (id, hasMv7) => ({
  id,
  pipewireHasMv7: hasMv7,
  synced: null,
  syncFromStore(st) { this.synced = Object.assign({}, st) },
  execCli(args) { execLog.push({ id, args }) }
})
sandbox.unregister(monA)
assert(sandbox.isLeader(monB), 'monitor B becomes leader when monitor A disconnects')
sandbox.unregister(monB)

sandbox.markDisconnected()
const hotA = makeHotplugPanel('HA', true)
const hotB = makeHotplugPanel('HB', true)
sandbox.register(hotA)
sandbox.register(hotB)
const beforeHandoff = execLog.length
sandbox.unregister(hotA)
assert(sandbox.isLeader(hotB), 'hotB becomes leader when hotA disconnects during hotplug')
assertEqual(execLog.length, beforeHandoff + 1, 'new leader triggers CLI probe when MV7+ is present')
assertDeepEqual(execLog[execLog.length - 1], { id: 'HB', args: ['status'] }, 'new leader runs status probe')
JS
