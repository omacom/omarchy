#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/bin" "$tmpdir/state"
STATE_DIR="$tmpdir/state"
printf 'yes\n' >"$STATE_DIR/powered"
printf 'yes\n' >"$STATE_DIR/airpods_connected"
printf 'no\n' >"$STATE_DIR/mouse_connected"
printf 'no\n' >"$STATE_DIR/speaker_paired"
printf 'no\n' >"$STATE_DIR/speaker_connected"
printf 'no\n' >"$STATE_DIR/speaker_trusted"
printf 'yes\n' >"$STATE_DIR/mouse_present"
: >"$STATE_DIR/bt.log"

cat >"$tmpdir/bin/bluetoothctl" <<'PY'
#!/usr/bin/python3
import os
import sys

state = os.environ["TEST_STATE_DIR"]
args = sys.argv[1:]

with open(os.path.join(state, "bt.log"), "a", encoding="utf-8") as log:
    log.write("bluetoothctl " + " ".join(args) + "\n")

def read_s(name, default=""):
    try:
        return open(os.path.join(state, name), encoding="utf-8").read().strip()
    except OSError:
        return default

def write_s(name, value):
    with open(os.path.join(state, name), "w", encoding="utf-8") as fh:
        fh.write(value + "\n")

# Strip leading --timeout N
cmd = []
i = 0
while i < len(args):
    if args[i] == "--timeout":
        i += 2
    else:
        cmd.append(args[i])
        i += 1

if cmd == ["list"]:
    if os.environ.get("TEST_NO_CTRL") != "1":
        print("Controller 50:2E:66:58:2A:60 dhh-bc [default]")
    raise SystemExit(0)

if cmd[:1] == ["show"]:
    powered = read_s("powered", "yes")
    print("Controller 50:2E:66:58:2A:60 (public)")
    print("\tName: dhh-bc")
    print("\tAlias: dhh-bc")
    print(f"\tPowered: {powered}")
    print("\tDiscoverable: no")
    print("\tPairable: yes")
    print("\tDiscovering: no")
    raise SystemExit(0)

if cmd[:1] == ["power"] and len(cmd) >= 2:
    write_s("powered", "yes" if cmd[1] == "on" else "no")
    raise SystemExit(0)

if cmd == ["devices"]:
    print("Device AA:BB:CC:DD:EE:01 AirPods Pro")
    if read_s("mouse_present", "yes") == "yes":
        print("Device AA:BB:CC:DD:EE:02 MX Master 3S")
    print("Device AA:BB:CC:DD:EE:03 JBL Go 3")
    print("Device AA:BB:CC:DD:EE:04 AA-BB-CC-DD-EE-04")
    raise SystemExit(0)

if cmd[:1] == ["info"] and len(cmd) >= 2:
    mac = cmd[1].upper()
    if mac == "AA:BB:CC:DD:EE:01":
        print("Device AA:BB:CC:DD:EE:01 (public)")
        print("\tName: AirPods Pro")
        print("\tAlias: AirPods Pro")
        print("\tIcon: audio-headset")
        print("\tPaired: yes")
        print("\tBonded: yes")
        print("\tTrusted: yes")
        print("\tBlocked: no")
        print(f"\tConnected: {read_s('airpods_connected', 'yes')}")
        print("\tRSSI: 0xffffffc6 (-58)")
        print("\tBattery Percentage: 0x55 (85)")
        print("\tUUID: Audio Sink (0000110b-0000-1000-8000-00805f9b34fb)")
        print("\tUUID: Handsfree (0000111e-0000-1000-8000-00805f9b34fb)")
        raise SystemExit(0)
    if mac == "AA:BB:CC:DD:EE:02" and read_s("mouse_present", "yes") == "yes":
        print("Device AA:BB:CC:DD:EE:02 (random)")
        print("\tName: MX Master 3S")
        print("\tAlias: MX Master 3S")
        print("\tIcon: input-mouse")
        print("\tPaired: yes")
        print("\tTrusted: yes")
        print(f"\tConnected: {read_s('mouse_connected', 'no')}")
        raise SystemExit(0)
    if mac == "AA:BB:CC:DD:EE:03":
        print("Device AA:BB:CC:DD:EE:03 (public)")
        print("\tName: JBL Go 3")
        print("\tAlias: JBL Go 3")
        print("\tIcon: audio-card")
        print(f"\tPaired: {read_s('speaker_paired', 'no')}")
        print(f"\tTrusted: {read_s('speaker_trusted', 'no')}")
        print(f"\tConnected: {read_s('speaker_connected', 'no')}")
        raise SystemExit(0)
    if mac == "AA:BB:CC:DD:EE:04":
        print("Device AA:BB:CC:DD:EE:04 (random)")
        print("\tAlias: AA-BB-CC-DD-EE-04")
        print("\tPaired: no")
        print("\tTrusted: no")
        print("\tConnected: no")
        raise SystemExit(0)
    print(f"Device {mac} not available")
    raise SystemExit(1)

if cmd[:2] == ["scan", "on"]:
    print("Discovery started")
    raise SystemExit(0)

if cmd[:1] == ["pair"] and len(cmd) >= 2:
    if cmd[1].upper() == "AA:BB:CC:DD:EE:03":
        write_s("speaker_paired", "yes")
    raise SystemExit(0)

if cmd[:1] == ["trust"] and len(cmd) >= 2:
    if cmd[1].upper() == "AA:BB:CC:DD:EE:03":
        write_s("speaker_trusted", "yes")
    raise SystemExit(0)

if cmd[:1] == ["untrust"] and len(cmd) >= 2:
    if cmd[1].upper() == "AA:BB:CC:DD:EE:03":
        write_s("speaker_trusted", "no")
    raise SystemExit(0)

if cmd[:1] == ["connect"] and len(cmd) >= 2:
    if os.environ.get("TEST_FAIL_CONNECT") == "1":
        print("Failed to connect: org.bluez.Error.Failed br-connection-page-timeout")
        raise SystemExit(1)
    mac = cmd[1].upper()
    if mac == "AA:BB:CC:DD:EE:01":
        write_s("airpods_connected", "yes")
    elif mac == "AA:BB:CC:DD:EE:02":
        write_s("mouse_connected", "yes")
    elif mac == "AA:BB:CC:DD:EE:03":
        write_s("speaker_connected", "yes")
    raise SystemExit(0)

if cmd[:1] == ["disconnect"] and len(cmd) >= 2:
    mac = cmd[1].upper()
    if mac == "AA:BB:CC:DD:EE:01":
        write_s("airpods_connected", "no")
    elif mac == "AA:BB:CC:DD:EE:02":
        write_s("mouse_connected", "no")
    elif mac == "AA:BB:CC:DD:EE:03":
        write_s("speaker_connected", "no")
    raise SystemExit(0)

if cmd[:1] == ["remove"] and len(cmd) >= 2:
    if cmd[1].upper() == "AA:BB:CC:DD:EE:02":
        write_s("mouse_present", "no")
    raise SystemExit(0)

raise SystemExit(0)
PY

cat >"$tmpdir/bin/rfkill" <<'SH'
#!/bin/bash
printf 'rfkill %s\n' "$*" >>"$TEST_STATE_DIR/bt.log"
[[ $1 == "block" ]] && printf 'no\n' >"$TEST_STATE_DIR/powered"
[[ $1 == "unblock" ]] && printf 'yes\n' >"$TEST_STATE_DIR/powered"
exit 0
SH

chmod +x "$tmpdir/bin/bluetoothctl" "$tmpdir/bin/rfkill"

bt_run() {
  PATH="$tmpdir/bin:$ROOT/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" \
    OMARCHY_BLUETOOTH_POWER_WAIT_SECONDS=0 "$ROOT/bin/omarchy-bluetooth" "$@"
}

# 1. status --json (controller, power, connected devices with battery)
out=$(bt_run status --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["available"] is True and d["powered"] is True and d["power"] == "on", d
assert d["controller"]["address"] == "50:2E:66:58:2A:60", d
assert len(d["connected"]) == 1, d
c = d["connected"][0]
assert c["label"] == "AirPods Pro" and c["battery"] == 85 and c["rssi"] == -58, c
PY
pass "bluetooth status --json reports controller, power, and connected device battery/RSSI"

# 2. list filters unnamed BLE beacons by default, sorts connected -> paired -> discovered, --all includes them
out=$(bt_run list --json)
python3 - "$out" <<'PY'
import json, sys
devs = json.loads(sys.argv[1])
assert [d["label"] for d in devs] == ["AirPods Pro", "MX Master 3S", "JBL Go 3"], devs
PY
out=$(bt_run list --all --json)
python3 - "$out" <<'PY'
import json, sys
devs = json.loads(sys.argv[1])
assert len(devs) == 4 and any(d["address"] == "AA:BB:CC:DD:EE:04" for d in devs), devs
PY
out=$(bt_run list --connected --json)
python3 - "$out" <<'PY'
import json, sys
devs = json.loads(sys.argv[1])
assert [d["label"] for d in devs] == ["AirPods Pro"], devs
PY
out=$(bt_run list --paired --json)
python3 - "$out" <<'PY'
import json, sys
devs = json.loads(sys.argv[1])
assert [d["label"] for d in devs] == ["AirPods Pro", "MX Master 3S"], devs
PY
pass "bluetooth list sorts devices, hides unnamed BLE beacons by default, and supports --connected/--paired/--all"

# 3. info resolves by friendly name (case-insensitive) and MAC (including hyphens)
out=$(bt_run info "airpods pro" --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["address"] == "AA:BB:CC:DD:EE:01" and d["profiles"] == ["Audio Sink", "Handsfree"], d
PY
out=$(bt_run info "aa-bb-cc-dd-ee-01" --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["label"] == "AirPods Pro"
PY
pass "bluetooth info resolves devices by name or hyphen/colon MAC address"

# 4. pair, connect, disconnect, trust/untrust, forget by name
: >"$STATE_DIR/bt.log"
out=$(bt_run pair "JBL Go 3" --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["paired"] is True and d["trusted"] is True and d["connected"] is True, d
PY
grep -q "bluetoothctl --timeout 20 pair AA:BB:CC:DD:EE:03" "$STATE_DIR/bt.log" || fail "pair invokes bluetoothctl pair"
grep -q "bluetoothctl trust AA:BB:CC:DD:EE:03" "$STATE_DIR/bt.log" || fail "pair trusts device"
grep -q "bluetoothctl --timeout 20 connect AA:BB:CC:DD:EE:03" "$STATE_DIR/bt.log" || fail "pair connects device"
pass "bluetooth pair pairs, trusts, and connects a device resolved by name"

out=$(bt_run untrust "JBL Go 3" --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["trusted"] is False
PY
out=$(bt_run disconnect "AirPods Pro" --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["connected"] is False
PY
out=$(bt_run forget "MX Master 3S" --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["forgotten"]["address"] == "AA:BB:CC:DD:EE:02"
PY
pass "bluetooth untrust, disconnect, and forget work by device name"

# 5. failed connect surfaces real error and non-zero exit
status=0
TEST_FAIL_CONNECT=1 bt_run connect "AirPods Pro" >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "failed bluetooth connect should exit 1" "got $status"
pass "bluetooth connect reports failures with non-zero exit status"

# 6. power off/on/toggle delegates to omarchy-bluetooth-power (rfkill) and scan auto-powers on
: >"$STATE_DIR/bt.log"
out=$(bt_run off --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["powered"] is False
PY
grep -qx "rfkill block bluetooth" "$STATE_DIR/bt.log" || fail "bluetooth off uses rfkill via omarchy-bluetooth-power"

: >"$STATE_DIR/bt.log"
out=$(bt_run scan --timeout 1 --json)
grep -qx "rfkill unblock bluetooth" "$STATE_DIR/bt.log" || fail "bluetooth scan powers adapter on via rfkill unblock"
grep -q "bluetoothctl --timeout 1 scan on" "$STATE_DIR/bt.log" || fail "bluetooth scan passes --timeout to bluetoothctl"
pass "bluetooth off/on/toggle uses rfkill persistence and scan auto-powers adapter on"

# 7. invalid --timeout rejected with exit 2
status=0
bt_run scan --timeout 0 >/dev/null 2>&1 || status=$?
(( status == 2 )) || fail "invalid --timeout should exit 2" "got $status"
pass "bluetooth scan rejects out-of-range --timeout with exit 2"
