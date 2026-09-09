#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - "$ROOT" <<'PYTEST'
import hashlib
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
source = (root / "install/hardware/apple/fix-bcm43602-nvram.sh").read_text()
fixture = b"sromrev=11\nmacaddr=xx:xx:xx:xx:xx:xx\naa2g=7\naa5g=7\n"

with tempfile.TemporaryDirectory() as tmp:
    base = Path(tmp)
    def run_case(name, *, vendor="Apple Inc.", model="MacBookPro13,3", chip="0x43ba",
                 subsystem="0x015a", mac="00:90:4c:0d:f4:3e", existing=None,
                 corrupt=False, download_fail=False):
        case = base / name
        dmi = case / "sys/class/dmi/id"
        pci = case / "sys/bus/pci/devices/0000:03:00.0"
        firmware = case / "firmware"
        stub = case / "bin"
        for path in (dmi, pci, firmware, stub):
            path.mkdir(parents=True)
        (dmi / "sys_vendor").write_text(vendor)
        (dmi / "product_name").write_text(model)
        for key, value in dict(vendor="0x14e4", device=chip,
                               subsystem_vendor="0x106b", subsystem_device=subsystem).items():
            (pci / key).write_text(value)
        if mac is not None:
            (pci / "net/wlan0").mkdir(parents=True)
            (pci / "net/wlan0/address").write_text(mac)
        target = firmware / "brcmfmac43602-pcie.Apple Inc.-MacBookPro13,3.txt"
        if existing:
            (firmware / existing).write_text("keep custom configuration")
        payload = case / "payload"
        payload.write_bytes(b"corrupt" if corrupt else fixture)
        curl = stub / "curl"
        curl.write_text("#!/bin/bash\necho download >> '" + str(case / "calls") + "'\n" +
                        ("exit 22\n" if download_fail else
                         "while [[ $1 != -o ]]; do shift; done\ncp '" + str(payload) + "' \"$2\"\n"))
        curl.chmod(0o755)
        script = case / "leaf.sh"
        script.write_text(source.replace("/sys/", str(case / "sys") + "/")
                          .replace("/usr/lib/firmware/brcm", str(firmware))
                          .replace("b109f3e6663b0e888c2559e36f7e0109f2a3a6b9765786d11f849f16d4b32d06",
                                   hashlib.sha256(fixture).hexdigest()))
        env = dict(os.environ, PATH=str(stub) + os.pathsep + os.environ["PATH"])
        def invoke():
            return subprocess.run(["bash", "-e", "-c", 'source "$1"', "bash", str(script)],
                                  env=env, capture_output=True, text=True)
        result = invoke()
        return case, target, result, invoke

    for name, kwargs in [("non-apple", dict(vendor="Dell Inc.")),
                         ("other-model", dict(model="MacBookPro14,3")),
                         ("other-chip", dict(chip="0x43a0")),
                         ("other-board", dict(subsystem="0x9999"))]:
        case, target, result, _ = run_case(name, **kwargs)
        assert result.returncode == 0 and not target.exists() and not (case / "calls").exists(), name
        print("ok - skips " + name)

    for suffix in (".txt", ".txt.zst", ".txt.xz"):
        for prefix in ("brcmfmac43602-pcie", "brcmfmac43602-pcie.Apple Inc.-MacBookPro13,3"):
            filename = prefix + suffix
            case, target, result, _ = run_case("existing-" + filename, existing=filename)
            assert result.returncode == 0 and not (case / "calls").exists()
            assert (target.parent / filename).read_text() == "keep custom configuration"
    print("ok - preserves generic and model-specific NVRAM, including compressed files")

    case, target, result, invoke = run_case("install")
    assert result.returncode == 0, result.stderr
    installed = target.read_text()
    mac = re.search(r"^macaddr=(.*)$", installed, re.M)[1]
    assert re.fullmatch(r"02(:[0-9a-f]{2}){5}", mac), mac
    assert installed == fixture.decode().replace("xx:xx:xx:xx:xx:xx", mac)
    assert target.stat().st_mode & 0o777 == 0o644
    assert invoke().returncode == 0 and target.read_text() == installed
    assert (case / "calls").read_text().count("download") == 1
    print("ok - installs verified NVRAM with a unique local MAC and preserves it on rerun")

    _, target, result, _ = run_case("real-mac", mac="78:12:34:56:78:90")
    assert result.returncode == 0 and "macaddr=78:12:34:56:78:90" in target.read_text()
    print("ok - preserves the interface address when it is not the Broadcom placeholder")
    _, target, result, _ = run_case("no-interface", mac=None)
    assert result.returncode == 0 and "macaddr=02:" in target.read_text()
    print("ok - handles installation without a bound network interface")
    for name, kwargs in [("bad-digest", dict(corrupt=True)), ("download-failure", dict(download_fail=True))]:
        _, target, result, _ = run_case(name, **kwargs)
        assert result.returncode != 0 and not target.exists(), name
        print("ok - refuses installation on " + name)
PYTEST
