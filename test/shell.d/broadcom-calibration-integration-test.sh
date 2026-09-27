#!/bin/bash
# Exercise both existing leaves in one fixture; no radio or regulatory claims.
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
python3 - "$ROOT" <<'PY'
import hashlib
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
leaf13 = (root / 'install/hardware/apple/fix-bcm43602-nvram.sh').read_text()
leaf14 = root / 'install/hardware/apple/fix-brcmfmac-5ghz.sh'
fixture = b'sromrev=11\nmacaddr=xx:xx:xx:xx:xx:xx\naa2g=7\naa5g=7\n'
real_digest = 'b109f3e6663b0e888c2559e36f7e0109f2a3a6b9765786d11f849f16d4b32d06'
assert real_digest in leaf13
all_sh = (root / 'install/hardware/all.sh').read_text()
for path in ['apple/fix-bcm43602-nvram.sh', 'apple/fix-brcmfmac-5ghz.sh', 'apple/fix-brcmfmac-supplicant.sh']:
    assert all_sh.count('run_logged "$OMARCHY_INSTALL/hardware/' + path + '"') == 1
print('ok - combined wiring invokes each selected leaf and the existing supplicant quirk once')

with tempfile.TemporaryDirectory() as td:
    base = Path(td)
    def case(name, model, *, vendor='Apple Inc.', chip='43ba', board='015a', existing=False, fail=False):
        work = base / name
        sysroot = work / 'sys'
        dmi = sysroot / 'class/dmi/id'
        pci = sysroot / 'bus/pci/devices/0000:03:00.0'
        package = work / 'firmware/brcm'
        override = work / 'firmware/updates/brcm'
        stub = work / 'bin'
        for p in (dmi, pci / 'net/wlan0', package, override, stub):
            p.mkdir(parents=True)
        (dmi / 'sys_vendor').write_text(vendor)
        (dmi / 'product_name').write_text(model)
        for key, value in {'vendor':'0x14e4','device':'0x'+chip,'subsystem_vendor':'0x106b','subsystem_device':'0x'+board}.items():
            (pci / key).write_text(value)
        (pci / 'net/wlan0/address').write_text('78:12:34:56:78:90')
        machine_id = work / 'machine-id'
        machine_id.write_text('0123456789abcdef0123456789abcdef\n')
        payload = work / 'payload'
        payload.write_bytes(fixture)
        log = work / 'calls'
        scripts = {
            'curl': 'echo curl >> "$TEST_CALLS"\n' + ('exit 22\n' if fail else 'while [[ $1 != -o ]]; do shift; done\ncp "$TEST_PAYLOAD" "$2"\n'),
            'lspci': 'echo "0000:03:00.0 Network controller [0280]: Broadcom [14e4:$TEST_CHIP]"\n',
            'sudo': '"$@"\n',
            'modprobe': 'echo unexpected-modprobe >> "$TEST_CALLS"; exit 99\n',
            'nmcli': 'echo unexpected-nmcli >> "$TEST_CALLS"; exit 99\n',
        }
        for name_, body in scripts.items():
            p = stub / name_
            p.write_text('#!/bin/bash\n'+body)
            p.chmod(0o755)
        if existing:
            (package / 'brcmfmac43602-pcie.txt.zst').write_text('administrator-owned\n')
        staged13 = work / 'leaf13.sh'
        staged13.write_text(leaf13.replace('/sys/',str(sysroot)+'/').replace('/usr/lib/firmware/brcm',str(package)).replace(real_digest,hashlib.sha256(fixture).hexdigest()))
        env = dict(os.environ, PATH=str(stub)+':'+os.environ['PATH'], OMARCHY_PATH=str(root), OMARCHY_INSTALL=str(root/'install'),
                   OMARCHY_BRCMFMAC_DMI_VENDOR=str(dmi/'sys_vendor'), OMARCHY_BRCMFMAC_DMI_PRODUCT=str(dmi/'product_name'),
                   OMARCHY_BRCMFMAC_PCI_DEVICES=str(sysroot/'bus/pci/devices'), OMARCHY_BRCMFMAC_FWDIR=str(override),
                   OMARCHY_BRCMFMAC_PACKAGED_FWDIR=str(package), OMARCHY_BRCMFMAC_MACHINE_ID=str(machine_id),
                   TEST_CHIP=chip, TEST_PAYLOAD=str(payload), TEST_CALLS=str(log))
        def invoke():
            # Matches run_logged's separate bash -eE invocation per leaf.
            return [subprocess.run(['bash','-eE','-c','source "$1"','bash',str(leaf)],env=env,text=True,capture_output=True) for leaf in (staged13,leaf14)]
        results = invoke()
        assert all(r.returncode == 0 for r in results) != fail, [r.stderr for r in results]
        files = sorted(str(p.relative_to(work/'firmware')) for p in (work/'firmware').rglob('*') if p.is_file())
        assert 'unexpected-' not in (log.read_text() if log.exists() else '')
        return work,files,invoke

    work, files, invoke = case('13-3','MacBookPro13,3')
    assert files == ['brcm/brcmfmac43602-pcie.Apple Inc.-MacBookPro13,3.txt'], files
    installed = work/'firmware'/files[0]
    assert installed.read_bytes() == fixture.replace(b'xx:xx:xx:xx:xx:xx',b'78:12:34:56:78:90')
    previous = installed.read_bytes()
    assert all(r.returncode == 0 for r in invoke()) and installed.read_bytes() == previous
    assert (work/'calls').read_text() == 'curl\n'
    print('ok - 13,3 selects only its board-specific download and preserves it on rerun')

    for model in ('MacBookPro14,2','MacBookPro14,3'):
        work, files, invoke = case(model,model,board='0173')
        assert len(files) == 2 and all(p.startswith('updates/brcm/') for p in files),files
        expected=(root/'default/firmware/apple/brcmfmac43602-pcie.txt').read_text()
        expected=re.sub(r'^macaddr=.*$', 'macaddr=78:12:34:56:78:90', expected, flags=re.M)
        assert all((work/'firmware'/f).read_text()==expected for f in files)
        assert not (work/'calls').exists()
        print('ok - '+model+' selects only the existing 14,x calibration without downloading the 13,3 file')

    for name,model,kwargs in [('wrong-board','MacBookPro13,3',{'board':'0173'}),('other-model','MacBookPro11,5',{}),
                              ('non-apple','MacBookPro14,3',{'vendor':'Dell Inc.'}),('wl-device','MacBookPro14,3',{'chip':'43a0'})]:
        _,files,_=case(name,model,**kwargs)
        assert not files,files
    print('ok - combined leaves preserve their model, board, vendor and chip exclusions')
    for model in ('MacBookPro13,3','MacBookPro14,3'):
        work,files,_=case('existing-'+model,model,existing=True)
        assert files == ['brcm/brcmfmac43602-pcie.txt.zst']
        assert (work/'firmware'/files[0]).read_text() == 'administrator-owned\n'
        assert not (work/'calls').exists()
    print('ok - both leaves preserve an existing compressed generic board file')
    _,files,_=case('failed-download','MacBookPro13,3',fail=True)
    assert not files
    print('ok - a failed 13,3 download cannot fall through to the other model calibration')
PY
