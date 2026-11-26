#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mkdir -p "$tmpdir/bin" "$tmpdir/sys/eth0" "$tmpdir/sys/eth1"
printf '1\n' >"$tmpdir/sys/eth0/carrier"
printf '2500\n' >"$tmpdir/sys/eth0/speed"
printf 'full\n' >"$tmpdir/sys/eth0/duplex"
printf '0\n' >"$tmpdir/sys/eth1/carrier"
printf '%s\n' '-1' >"$tmpdir/sys/eth1/speed"
printf 'unknown\n' >"$tmpdir/sys/eth1/duplex"

STATE_DIR="$tmpdir/state"
mkdir -p "$STATE_DIR"
printf 'enabled\n' >"$STATE_DIR/radio"
printf 'connected\n' >"$STATE_DIR/wifi_state"
printf 'Quattro\n' >"$STATE_DIR/wifi_conn"
printf 'auto\n' >"$STATE_DIR/eth0_method"
printf '10.0.0.10/24\n' >"$STATE_DIR/eth0_ip"
printf '10.0.0.1\n' >"$STATE_DIR/eth0_gw"
printf '1.1.1.1\n' >"$STATE_DIR/eth0_dns"
printf 'connected\n' >"$STATE_DIR/eth0_state"
: >"$STATE_DIR/nmcli.log"
: >"$STATE_DIR/nmcli_stdin.log"

cat >"$tmpdir/bin/nmcli" <<'PY'
#!/usr/bin/python3
import os
import sys

state = os.environ["TEST_STATE_DIR"]
args = sys.argv[1:]

with open(os.path.join(state, "nmcli.log"), "a", encoding="utf-8") as log:
    log.write(" ".join(args) + "\n")

def read_s(name, default=""):
    try:
        return open(os.path.join(state, name), encoding="utf-8").read().strip()
    except OSError:
        return default

def write_s(name, value):
    with open(os.path.join(state, name), "w", encoding="utf-8") as fh:
        fh.write(value + "\n")

# Strip common leading formatting flags to dispatch cleanly.
stripped = []
i = 0
while i < len(args):
    a = args[i]
    if a in ("-t", "--terse", "--show-secrets"):
        i += 1
    elif a in ("-f", "-e", "--escape", "-g", "--get-values"):
        i += 2
    else:
        stripped.append(a)
        i += 1

if stripped[:2] == ["radio", "wifi"]:
    if len(stripped) == 2:
        print(read_s("radio", "enabled"))
        raise SystemExit(0)
    if stripped[2] in ("on", "off"):
        write_s("radio", "enabled" if stripped[2] == "on" else "disabled")
        if stripped[2] == "off":
            write_s("wifi_state", "unavailable")
            write_s("wifi_conn", "--")
        else:
            write_s("wifi_state", "disconnected")
        raise SystemExit(0)

if stripped[:2] == ["device", "status"]:
    wifi_state = read_s("wifi_state", "connected")
    wifi_conn = read_s("wifi_conn", "Quattro")
    eth0_state = read_s("eth0_state", "connected")
    eth0_conn = "Wired Office" if eth0_state == "connected" else "--"
    if os.environ.get("TEST_NO_WIFI") != "1":
        if "-g" in args:
            print(f"wlan0:wifi:{wifi_state}")
        else:
            print(f"wlan0:wifi:{wifi_state}:{wifi_conn}")
    if os.environ.get("TEST_NO_ETH") != "1":
        if "-g" not in args:
            print(f"eth0:ethernet:{eth0_state}:{eth0_conn}")
            print("eth1:ethernet:unavailable:--")
    raise SystemExit(0)

if stripped[:2] == ["device", "show"] and len(stripped) >= 3:
    dev = stripped[2]
    if "--get-values" in args or "-g" in args:
        idx = args.index("--get-values") if "--get-values" in args else args.index("-g")
        field = args[idx + 1]
        if field == "GENERAL.CON-UUID":
            print("11111111-1111-1111-1111-111111111111" if dev == "wlan0" else "22222222-2222-2222-2222-222222222222")
            raise SystemExit(0)
        if field == "GENERAL.CONNECTION":
            print(read_s("wifi_conn", "Quattro"))
            raise SystemExit(0)
    if dev == "wlan0":
        print("GENERAL.HWADDR:AA:BB:CC:DD:EE:FF")
        print("GENERAL.CON-UUID:11111111-1111-1111-1111-111111111111")
        print("IP4.ADDRESS[1]:192.168.1.45/24")
        print("IP4.GATEWAY:192.168.1.1")
        print("IP4.DNS[1]:192.168.1.1")
    elif dev == "eth0":
        print("GENERAL.HWADDR:10:20:30:40:50:60")
        print("GENERAL.CON-UUID:22222222-2222-2222-2222-222222222222")
        print(f"IP4.ADDRESS[1]:{read_s('eth0_ip', '10.0.0.10/24')}")
        print(f"IP4.GATEWAY:{read_s('eth0_gw', '10.0.0.1')}")
        for n, dns in enumerate(read_s("eth0_dns", "1.1.1.1").split(), 1):
            print(f"IP4.DNS[{n}]:{dns}")
        print("WIRED-PROPERTIES.CARRIER:on")
    elif dev == "eth1":
        print("GENERAL.HWADDR:10:20:30:40:50:61")
        print("GENERAL.CON-UUID:--")
        print("WIRED-PROPERTIES.CARRIER:off")
    raise SystemExit(0)

if stripped[:3] in (["device", "wifi", "list"], ["dev", "wifi", "list"]):
    if "-f" in args:
        fields = args[args.index("-f") + 1]
    elif "-g" in args:
        fields = args[args.index("-g") + 1]
    else:
        fields = ""
    if fields == "IN-USE,SIGNAL":
        print("*:74")
        print(" :90")
    elif fields == "FREQ,SSID":
        print("5200 MHz:Quattro")
        print("6135 MHz:Quattro")
    else:
        print("*:Quattro:74:WPA2 WPA3:6135 MHz")
        print(" :Quattro:95:WPA2 WPA3:5200 MHz")
        print(r" :Cafe\:2\\4:65:WPA2:2437 MHz")
        print(" :OpenNet:80:--:2412 MHz")
        print(" :SixOnly:55:WPA3:6455 MHz")
        print(" :-dash-net:40:WPA2:5180 MHz")
    raise SystemExit(0)

if stripped[:2] == ["device", "disconnect"] and len(stripped) >= 3:
    if stripped[2] == "wlan0":
        write_s("wifi_state", "disconnected")
        write_s("wifi_conn", "--")
    elif stripped[2] == "eth0":
        write_s("eth0_state", "disconnected")
    raise SystemExit(0)

if stripped[:2] == ["device", "connect"] and len(stripped) >= 3:
    if stripped[2] == "eth0":
        write_s("eth0_state", "connected")
    raise SystemExit(0)

if stripped[:3] == ["device", "wifi", "connect"]:
    write_s("wifi_state", "connected")
    write_s("wifi_conn", stripped[3])
    raise SystemExit(0)

if stripped[:2] == ["connection", "show"]:
    if "--get-values" in args or "-g" in args:
        idx = args.index("--get-values") if "--get-values" in args else args.index("-g")
        field = args[idx + 1]
        if field == "802-11-wireless.ssid":
            uid = stripped[-1]
            mapping = {
                "11111111-1111-1111-1111-111111111111": "Quattro",
                "33333333-3333-3333-3333-333333333333": "Cafe:2\\4",
            }
            print(mapping.get(uid, ""))
            raise SystemExit(0)
        if field == "802-11-wireless-security.key-mgmt":
            print("wpa-psk")
            raise SystemExit(0)
        if field == "802-11-wireless.band":
            print(read_s("band_pin", ""))
            raise SystemExit(0)
        if field == "ipv4.method":
            print(read_s("eth0_method", "auto"))
            raise SystemExit(0)
        if "802-11-wireless-security.psk" in field:
            print("wpa-psk")
            print("super-secret-pass")
            print("")
            raise SystemExit(0)
    print("Quattro:11111111-1111-1111-1111-111111111111:802-11-wireless:wlan0:yes")
    print(r"Cafe\:2\\4:33333333-3333-3333-3333-333333333333:802-11-wireless:--:yes")
    print("Wired Office:22222222-2222-2222-2222-222222222222:802-3-ethernet:eth0:yes")
    print("Quattro:44444444-4444-4444-4444-444444444444:802-3-ethernet:--:no")
    raise SystemExit(0)

if stripped[:2] == ["connection", "edit"]:
    data = sys.stdin.read()
    with open(os.path.join(state, "nmcli_stdin.log"), "a", encoding="utf-8") as fh:
        fh.write(data)
    raise SystemExit(0)

if stripped[:2] == ["connection", "add"]:
    raise SystemExit(0)

if stripped[:2] == ["connection", "modify"]:
    if "ipv4.method" in args:
        write_s("eth0_method", args[args.index("ipv4.method") + 1])
    if "ipv4.addresses" in args:
        addr = args[args.index("ipv4.addresses") + 1]
        if addr:
            write_s("eth0_ip", addr)
    if "ipv4.gateway" in args:
        gw = args[args.index("ipv4.gateway") + 1]
        if gw:
            write_s("eth0_gw", gw)
    if "ipv4.dns" in args:
        write_s("eth0_dns", args[args.index("ipv4.dns") + 1])
    if "802-11-wireless.band" in args:
        write_s("band_pin", args[args.index("802-11-wireless.band") + 1])
    raise SystemExit(0)

if stripped[:2] == ["connection", "up"]:
    if os.environ.get("TEST_FAIL_UP") == "1":
        sys.stderr.write("Error: Connection activation failed: Secrets were required\n")
        raise SystemExit(4)
    raise SystemExit(0)

if stripped[:2] == ["connection", "delete"]:
    raise SystemExit(0)

raise SystemExit(0)
PY

cat >"$tmpdir/bin/iw" <<'SH'
#!/bin/bash
if [[ $1 == "dev" && $3 == "link" ]]; then
  cat <<'EOF'
Connected to aa:bb:cc:dd:ee:ff (on wlan0)
	SSID: Caf\xc3\xa9
	freq: 6135
	signal: -46 dBm
	tx bitrate: 1441.3 MBit/s
EOF
fi
SH

cat >"$tmpdir/bin/ip" <<'SH'
#!/bin/bash
if [[ $1 == "-j" && $2 == "route" && $3 == "get" ]]; then
  printf '[{"dst":"1.1.1.1","gateway":"10.0.0.1","dev":"eth0"}]\n'
fi
SH

chmod +x "$tmpdir/bin/nmcli" "$tmpdir/bin/iw" "$tmpdir/bin/ip"

run_wifi() {
  PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$@" "$ROOT/bin/omarchy-network-wifi"
}

run_eth() {
  PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" OMARCHY_NET_CLASS_PATH="$tmpdir/sys" "$@" "$ROOT/bin/omarchy-network-ethernet"
}

# 1. Wi-Fi status (JSON + UTF-8 SSID decoding + UUID)
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$ROOT/bin/omarchy-network-wifi" status --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["radio"] == "on", d
assert d["connected"] is True, d
assert d["device"] == "wlan0", d
assert d["ssid"] == "Café", d
assert d["uuid"] == "11111111-1111-1111-1111-111111111111", d
assert d["signal"] == 74 and d["signal_dbm"] == -46, d
assert d["freq_mhz"] == 6135 and d["band"] == "6", d
assert d["ip"] == "192.168.1.45" and d["prefix"] == 24, d
assert d["gateway"] == "192.168.1.1" and d["dns"] == ["192.168.1.1"], d
PY
pass "wifi status --json reports link, decoded UTF-8 SSID, UUID, band, and IPv4"

# 2. Wi-Fi list deduplication, colon/backslash unescaping, sorting, and --known
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$ROOT/bin/omarchy-network-wifi" list --json)
python3 - "$out" <<'PY'
import json, sys
rows = json.loads(sys.argv[1])
ssids = [r["ssid"] for r in rows]
assert ssids[0] == "Quattro", ssids
assert ssids[1] == "Cafe:2\\4", ssids
assert ssids[2] == "OpenNet", ssids
q = rows[0]
assert q["connected"] is True and q["known"] is True and q["signal"] == 95 and q["bands"] == ["5", "6"], q
c = rows[1]
assert c["known"] is True and c["connected"] is False and c["bands"] == ["2.4"], c
assert rows[2]["security"] == "open", rows[2]
PY
pass "wifi list deduplicates bands, unescapes colons/backslashes, and sorts connected -> known -> signal"

out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$ROOT/bin/omarchy-network-wifi" scan --json)
grep -q -- "--rescan yes" "$STATE_DIR/nmcli.log" || fail "wifi scan triggers a rescan"
pass "wifi scan triggers --rescan yes"

out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$ROOT/bin/omarchy-network-wifi" list --known --json)
python3 - "$out" <<'PY'
import json, sys
profs = json.loads(sys.argv[1])
assert len(profs) == 2, profs
assert {p["ssid"] for p in profs} == {"Quattro", "Cafe:2\\4"}, profs
PY
pass "wifi list --known lists only 802-11-wireless saved profiles"

# 3. Wi-Fi PSK connect via --password-stdin: secret stays out of argv, WPA3 selects sae, -- handles leading dash
: >"$STATE_DIR/nmcli.log"
: >"$STATE_DIR/nmcli_stdin.log"
printf 'top-secret-psk\n' | PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" \
  "$ROOT/bin/omarchy-network-wifi" connect SixOnly --password-stdin --json >/dev/null
if grep -q "top-secret-psk" "$STATE_DIR/nmcli.log"; then
  fail "wifi PSK secret leaked into nmcli argv" "$(cat "$STATE_DIR/nmcli.log")"
fi
grep -q "wifi-sec.key-mgmt sae" "$STATE_DIR/nmcli.log" || fail "WPA3-only SSID should use sae" "$(cat "$STATE_DIR/nmcli.log")"
grep -q "set wifi-sec.psk top-secret-psk" "$STATE_DIR/nmcli_stdin.log" || fail "wifi PSK secret written via nmcli edit stdin"
pass "wifi connect --password-stdin keeps secrets out of argv and selects sae for WPA3-only networks"

: >"$STATE_DIR/nmcli.log"
printf 'dash-secret\n' | PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" \
  "$ROOT/bin/omarchy-network-wifi" connect --password-stdin -- -dash-net >/dev/null
grep -q "ssid -dash-net" "$STATE_DIR/nmcli.log" || fail "wifi connect handles SSIDs starting with -" "$(cat "$STATE_DIR/nmcli.log")"
pass "wifi connect supports SSIDs starting with a dash after --"

# 4. Wi-Fi enterprise connect rollback on activation failure
: >"$STATE_DIR/nmcli.log"
: >"$STATE_DIR/nmcli_stdin.log"
status=0
printf 'corp-secret\n' | PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" TEST_FAIL_UP=1 \
  "$ROOT/bin/omarchy-network-wifi" connect CorpWiFi --identity alice --password-stdin >/dev/null 2>&1 || status=$?
(( status == 1 )) || fail "enterprise connect failure should exit 1" "got $status"
if grep -q "corp-secret" "$STATE_DIR/nmcli.log"; then
  fail "enterprise secret leaked into nmcli argv"
fi
grep -q "set 802-1x.password corp-secret" "$STATE_DIR/nmcli_stdin.log" || fail "enterprise secret written via stdin"
grep -q "connection delete uuid" "$STATE_DIR/nmcli.log" || fail "failed enterprise profile should be rolled back"
pass "wifi enterprise connect keeps password off argv and deletes profile on activation failure"

# 5. Wi-Fi forget deletes only 802-11-wireless, never 802-3-ethernet with same name
: >"$STATE_DIR/nmcli.log"
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$ROOT/bin/omarchy-network-wifi" forget Quattro --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert len(d["forgotten"]) == 1, d
assert d["forgotten"][0]["uuid"] == "11111111-1111-1111-1111-111111111111", d
PY
if grep -q "44444444-4444-4444-4444-444444444444" "$STATE_DIR/nmcli.log"; then
  fail "wifi forget touched an Ethernet profile"
fi
pass "wifi forget only deletes Wi-Fi profiles and never touches Ethernet profiles"

# 6. Wi-Fi password and band
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$ROOT/bin/omarchy-network-wifi" password --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["password"] == "super-secret-pass" and d["interface"] == "wlan0", d
PY
pass "wifi password delegates to omarchy-network-password and supports --json"

out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$ROOT/bin/omarchy-network-wifi" band --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["current"] == "6" and d["selected"] == "auto", d
PY
pass "wifi band reports current and selected band as JSON"

# 7. Wi-Fi radio off/on/toggle & no-wifi case
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$ROOT/bin/omarchy-network-wifi" toggle --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["radio"] == "off"
PY
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" "$ROOT/bin/omarchy-network-wifi" on --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["radio"] == "on"
PY
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" TEST_NO_WIFI=1 "$ROOT/bin/omarchy-network-wifi" status --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["available"] is False
PY
pass "wifi radio on/off/toggle and missing-interface status work"

# 8. Ethernet status (carrier, speed, duplex, UUID, default_route)
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" OMARCHY_NET_CLASS_PATH="$tmpdir/sys" \
  "$ROOT/bin/omarchy-network-ethernet" status --json)
python3 - "$out" <<'PY'
import json, sys
ifaces = json.loads(sys.argv[1])["interfaces"]
assert len(ifaces) == 2, ifaces
e0, e1 = ifaces
assert e0["device"] == "eth0" and e0["connected"] is True and e0["carrier"] is True, e0
assert e0["speed_mbps"] == 2500 and e0["duplex"] == "full" and e0["default_route"] is True, e0
assert e0["uuid"] == "22222222-2222-2222-2222-222222222222", e0
assert e0["ip"] == "10.0.0.10" and e0["prefix"] == 24 and e0["gateway"] == "10.0.0.1", e0
assert e1["device"] == "eth1" and e1["carrier"] is False and e1["speed_mbps"] is None, e1
PY
pass "ethernet status --json reports carrier, link speed, duplex, UUID, IPv4, and default route"

# 9. Ethernet list, static IPv4, validation, dhcp, forget
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" OMARCHY_NET_CLASS_PATH="$tmpdir/sys" \
  "$ROOT/bin/omarchy-network-ethernet" list --json)
python3 - "$out" <<'PY'
import json, sys
profs = json.loads(sys.argv[1])
assert len(profs) == 2, profs
assert {p["name"] for p in profs} == {"Wired Office", "Quattro"}, profs
PY
pass "ethernet list --json returns only 802-3-ethernet profiles"

: >"$STATE_DIR/nmcli.log"
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" OMARCHY_NET_CLASS_PATH="$tmpdir/sys" \
  "$ROOT/bin/omarchy-network-ethernet" static 192.168.50.10/24 --gateway 192.168.50.1 --dns 1.1.1.1,9.9.9.9 eth0 --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert d["method"] == "manual" and d["address"] == "192.168.50.10/24", d
assert d["gateway"] == "192.168.50.1" and d["dns"] == ["1.1.1.1", "9.9.9.9"], d
PY
grep -q "ipv4.method manual" "$STATE_DIR/nmcli.log" || fail "ethernet static sets ipv4.method manual"
grep -q "ipv4.ignore-auto-dns yes" "$STATE_DIR/nmcli.log" || fail "ethernet static ignores auto DNS when --dns is set"
pass "ethernet static validates and applies manual IPv4, gateway, and DNS"

for bad in \
  "192.168.50.10 --gateway 192.168.50.1" \
  "999.1.1.1/24 --gateway 192.168.50.1" \
  "192.168.50.10/24 --gateway not-an-ip" \
  "192.168.50.10/24 --gateway 192.168.50.1 --dns bad-dns"; do
  status=0
  # shellcheck disable=SC2086
  PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" OMARCHY_NET_CLASS_PATH="$tmpdir/sys" \
    "$ROOT/bin/omarchy-network-ethernet" static $bad >/dev/null 2>&1 || status=$?
  (( status == 2 )) || fail "ethernet static should reject invalid input ($bad) with exit 2" "got $status"
done
pass "ethernet static rejects invalid CIDR, gateway, and DNS inputs with exit 2"

: >"$STATE_DIR/nmcli.log"
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" OMARCHY_NET_CLASS_PATH="$tmpdir/sys" \
  "$ROOT/bin/omarchy-network-ethernet" dhcp eth0 --json)
python3 - "$out" <<'PY'
import json, sys
assert json.loads(sys.argv[1])["method"] == "auto"
PY
grep -q "ipv4.method auto" "$STATE_DIR/nmcli.log" || fail "ethernet dhcp sets ipv4.method auto"
pass "ethernet dhcp switches profile back to automatic IPv4"

: >"$STATE_DIR/nmcli.log"
out=$(PATH="$tmpdir/bin:$PATH" TEST_STATE_DIR="$STATE_DIR" OMARCHY_NET_CLASS_PATH="$tmpdir/sys" \
  "$ROOT/bin/omarchy-network-ethernet" forget Quattro --json)
python3 - "$out" <<'PY'
import json, sys
d = json.loads(sys.argv[1])
assert len(d["forgotten"]) == 1 and d["forgotten"][0]["uuid"] == "44444444-4444-4444-4444-444444444444", d
PY
if grep -q "11111111-1111-1111-1111-111111111111" "$STATE_DIR/nmcli.log"; then
  fail "ethernet forget touched a Wi-Fi profile"
fi
pass "ethernet forget only deletes Ethernet profiles and never touches Wi-Fi profiles"
