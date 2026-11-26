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
PY

pass "Shure MV7+ HID protocol, value bounds, discovery, locking, and timeout handling pass"

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
  execHelper(args) { execLog.push({ id, args }) }
})
const monA = makePanel('A')
const monB = makePanel('B')
sandbox.register(monA)
sandbox.register(monB)

sandbox.setOptimistic('micMuted', true)
assertEqual(monA.synced.micMuted, true, 'monitor A reflects optimistic mute')
assertEqual(monB.synced.micMuted, true, 'monitor B reflects optimistic mute immediately')

// Preset + queued set merge: preset result must not be dropped when a set is queued.
sandbox.enqueue(['preset', 'neutral'], monA)
sandbox.setOptimistic('gainDb', 32.0)
sandbox.enqueue(['set', 'gain_db', '32.0'], monB)
assertEqual(execLog.length, 1, 'only one HID command executes at a time across monitors')

sandbox.finishExec(JSON.stringify({
  connected: true,
  state: { auto_level: 0, gain_db: 28.0, mute: 0, denoiser: 0, hpf: 0 }
}))
assertEqual(monA.synced.autoLevel, false, 'preset auto_level merges even while set gain_db is queued')
assertEqual(monB.synced.micMuted, false, 'preset mute merges across monitors')
assertEqual(monA.synced.gainDb, 32.0, 'queued gain_db is not reverted by earlier preset snapshot')
assertEqual(execLog.length, 2, 'queued set executes immediately after preset finishes')
assertDeepEqual(execLog[1].args, ['set', 'gain_db', '32.0'], 'queued set args preserved')

sandbox.finishExec(JSON.stringify({ connected: true, state: { gain_db: 32.0 } }))
assertEqual(monB.synced.gainDb, 32.0, 'confirmed set updates all monitors')

// Unregistering leader hands off cleanly to remaining monitor and restarts
// detection if the MV7+ is present on PipeWire while not yet confirmed.
const makeHotplugPanel = (id, hasMv7) => ({
  id,
  pipewireHasMv7: hasMv7,
  synced: null,
  syncFromStore(st) { this.synced = Object.assign({}, st) },
  execHelper(args) { execLog.push({ id, args }) }
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
assertEqual(execLog.length, beforeHandoff + 1, 'new leader triggers HID detection when MV7+ is present')
assertDeepEqual(execLog[execLog.length - 1], { id: 'HB', args: ['read'] }, 'new leader runs read probe')
JS

require_command jq

(
  cli_tmp="$(mktemp -d)"
  trap 'rm -rf "$cli_tmp"' EXIT

  fake_root="$cli_tmp/omarchy"
  mkdir -p "$fake_root/shell/plugins/panels/mv7plus"
  ln -s "$ROOT/bin" "$fake_root/bin"
  ln -s "$ROOT/default" "$fake_root/default"

  state_file="$cli_tmp/state.json"
  mock_ctl="$fake_root/shell/plugins/panels/mv7plus/mv7plus-ctl.py"

  cat >"$mock_ctl" <<'PY'
import json
import os
import sys

mode = os.environ.get("MOCK_MV7_MODE", "ok")
if mode == "disconnected":
    print(json.dumps({"connected": False}))
    sys.exit(0)
if mode == "permission":
    print(json.dumps({"connected": False, "device": "/dev/hidraw9", "error": "permission"}))
    sys.exit(0)
if mode == "badjson":
    print("not json")
    sys.exit(0)
if mode == "missing_key":
    print(json.dumps({"connected": True, "device": "/dev/hidraw9", "state": {}}))
    sys.exit(0)

state_path = os.environ["MOCK_MV7_STATE"]
with open(state_path) as f:
    st = json.load(f)

action = sys.argv[1] if len(sys.argv) > 1 else "read"
if action == "set":
    key, raw = sys.argv[2], sys.argv[3]
    val = round(float(raw) * 2.0) / 2.0 if key == "gain_db" else int(raw)
    st[key] = val
    with open(state_path, "w") as f:
        json.dump(st, f)
    print(json.dumps({"connected": True, "device": "/dev/hidraw9", "state": {key: val}}))
elif action == "preset":
    preset = sys.argv[2]
    if preset == "neutral":
        st.update(auto_level=0, mute=0, hpf=0, limiter=0, compressor=0, denoiser=0,
                  popper_stopper=0, tone_pct=0, reverb_output=0, reverb_monitor=0)
    elif preset == "factory":
        st.update(auto_level=1, mute=0, hpf=0, limiter=0, compressor=0, denoiser=0,
                  popper_stopper=0, tone_pct=0, reverb_output=0, reverb_type=0,
                  reverb_intensity=0, reverb_monitor=0, mic_level=100, playback_level=100)
    with open(state_path, "w") as f:
        json.dump(st, f)
    print(json.dumps({"connected": True, "device": "/dev/hidraw9", "state": st}))
else:
    print(json.dumps({"connected": True, "device": "/dev/hidraw9", "state": st}))
PY

  cat >"$state_file" <<'JSON'
{
  "auto_level": 1,
  "gain_db": 20,
  "mute": 0,
  "hpf": 0,
  "limiter": 0,
  "compressor": 0,
  "denoiser": 0,
  "popper_stopper": 0,
  "tone_pct": 0,
  "reverb_output": 0,
  "reverb_type": 0,
  "reverb_intensity": 0,
  "reverb_monitor": 0,
  "mic_level": 100,
  "playback_level": 100
}
JSON

  run_cli() {
    OMARCHY_PATH="$fake_root" MOCK_MV7_STATE="$state_file" \
      "$fake_root/bin/omarchy" audio mv7plus "$@"
  }

  expect_eq() {
    local got="$1" want="$2" label="$3"
    [[ $got == "$want" ]] || fail "$label (got: '$got', want: '$want')"
  }

  expect_exit() {
    local want="$1" label="$2"
    shift 2
    local rc=0
    "$@" >/dev/null 2>&1 || rc=$?
    (( rc == want )) || fail "$label (exit $rc, want $want)"
  }

  # Status formatting (normalizes integer gain to 1 decimal) and --json output.
  status_out="$(run_cli status)"
  grep -q 'Manual Gain:.*20\.0 dB' <<<"$status_out" || fail "status formats gain to 1 decimal" "$status_out"
  json_out="$(run_cli status --json)"
  jq -e '.state.gain_db == 20' >/dev/null <<<"$json_out" || fail "status --json returns state" "$json_out"

  # Parsing edge cases: dB/% suffixes, leading-zero base-10, negative tone with/without --, aliases, toggles.
  expect_eq "$(run_cli mode manual)" "manual" "mode setter"
  expect_eq "$(run_cli gain 24.5dB)" "24.5 dB" "gain dB suffix"
  expect_eq "$(run_cli gain 08)" "8.0 dB" "gain leading zero"
  expect_eq "$(run_cli tone -60)" "dark (-60%)" "tone negative without --"
  expect_eq "$(run_cli tone -- -40)" "dark (-40%)" "tone negative with --"
  expect_eq "$(run_cli tone +08%)" "bright (+8%)" "tone leading-zero percent"
  expect_eq "$(run_cli mute on)" "on" "mute on"
  expect_eq "$(run_cli mute toggle)" "off" "mute toggle"
  expect_eq "$(run_cli popper-stopper on)" "on" "popper-stopper alias"
  expect_eq "$(run_cli hpf 150Hz)" "150 Hz" "hpf Hz suffix"
  expect_eq "$(run_cli compressor heavy)" "heavy" "compressor setter"
  expect_eq "$(run_cli reverb type hall)" "hall" "reverb type"
  expect_eq "$(run_cli reverb intensity 08)" "8%" "reverb intensity base-10"
  expect_eq "$(run_cli reverb monitor toggle)" "on" "reverb monitor toggle"
  expect_eq "$(run_cli monitor mic 75%)" "75%" "monitor mic percent suffix"
  expect_eq "$(run_cli monitor playback 40)" "40%" "monitor playback"
  expect_eq "$(run_cli monitor)" "mic 75%, playback 40%" "monitor summary"

  # Presets update hardware state and return full status.
  neutral_out="$(run_cli preset neutral)"
  grep -q 'Mode:.*manual' <<<"$neutral_out" || fail "preset neutral sets manual" "$neutral_out"
  factory_out="$(run_cli preset factory)"
  grep -q 'Mode:.*auto' <<<"$factory_out" || fail "preset factory restores auto" "$factory_out"

  # Validation and arity errors exit 2.
  expect_exit 2 "unknown command" run_cli bogus
  expect_exit 2 "gain out of range" run_cli gain 40
  expect_exit 2 "tone out of range" run_cli tone 150
  expect_exit 2 "extra arg on hpf" run_cli hpf 75 extra
  expect_exit 2 "extra arg on status" run_cli status --json extra
  expect_exit 2 "extra arg on reverb type" run_cli reverb type hall extra
  expect_exit 2 "missing preset name" run_cli preset

  # Error paths exit 1, including permission error even when connected is false and missing keys.
  expect_exit 1 "disconnected exits 1" env MOCK_MV7_MODE=disconnected OMARCHY_PATH="$fake_root" \
    "$fake_root/bin/omarchy" audio mv7plus status
  perm_err="$(MOCK_MV7_MODE=permission run_cli status 2>&1 || true)"
  grep -q '62-shure-mv7plus.rules' <<<"$perm_err" || fail "permission error mentions udev rule" "$perm_err"
  expect_exit 1 "permission exits 1" env MOCK_MV7_MODE=permission OMARCHY_PATH="$fake_root" \
    "$fake_root/bin/omarchy" audio mv7plus status
  expect_exit 1 "missing state key exits 1" env MOCK_MV7_MODE=missing_key OMARCHY_PATH="$fake_root" \
    "$fake_root/bin/omarchy" audio mv7plus mute
  expect_exit 1 "invalid json exits 1" env MOCK_MV7_MODE=badjson OMARCHY_PATH="$fake_root" \
    "$fake_root/bin/omarchy" audio mv7plus status
)

pass "omarchy audio mv7plus CLI covers controls, parsing edge cases, presets, and errors"
