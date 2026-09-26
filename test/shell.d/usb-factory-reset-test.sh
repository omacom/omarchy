#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

# Exercise reset staging in a temporary root with the real offline systemctl.
# Never invoke the reset command's main function or any actual disk operations.
python - "$ROOT" <<'PY'
from pathlib import Path
import os
import re
import shutil
import subprocess
import sys
import tempfile

repo = Path(sys.argv[1])
source = (repo / 'bin/omarchy-system-factory-reset').read_text()
functions = []
for name in ['install_provisioning_units', 'scrub_factory_accounts', 'sanitize_factory_baseline', 'stage_full_reset']:
  match = re.search(r'^' + name + r'\(\) \{\n.*?^\}', source, re.M | re.S)
  assert match, name
  functions.append(match.group())

with tempfile.TemporaryDirectory(prefix='omarchy-usb-reset-') as tmp:
  scratch = Path(tmp)
  for scenario in ['enabled', 'disabled', 'absent', 'disable-failure']:
    root = scratch / scenario
    top = root / 'top'
    factory = top / '@factory'
    for rel in ['etc/systemd/system/basic.target.wants', 'usr/lib/systemd/system',
          'etc/usbguard', 'usr/bin', 'usr/share/omarchy/install/provisioning']:
      (factory / rel).mkdir(parents=True, exist_ok=True)
    (top / '@').mkdir()
    (top / '@' / 'original-root').touch()
    (factory / 'etc/passwd').write_text('root:x:0:0:root:/root:/bin/bash\n')
    (factory / 'etc/machine-id').write_text('old-machine-id\n')
    policy = 'allow id 1234:0001 name "Original owner keyboard" hash "old-owner"\n'
    (factory / 'etc/usbguard/rules.conf').write_text(policy)
    unit = factory / 'usr/lib/systemd/system/usbguard.service'
    enabled_path = Path('etc/systemd/system/basic.target.wants/usbguard.service')
    if scenario != 'absent':
      unit.write_text('[Unit]\nDescription=Fixture USBGuard\n[Service]\nExecStart=/bin/true\n[Install]\nWantedBy=basic.target\n')
    if scenario in ['enabled', 'disable-failure']:
      (factory / enabled_path).symlink_to('/usr/lib/systemd/system/usbguard.service')
    owner = factory / 'usr/bin/omarchy-provision-owner'
    owner.touch()
    owner.chmod(0o755)
    for name in ['omarchy-provision-owner.service', 'omarchy-system-factory-reset-finish.service']:
      shutil.copyfile(repo / 'install/provisioning' / name,
              factory / 'usr/share/omarchy/install/provisioning' / name)
    harness = '''#!/bin/bash
set -euo pipefail
TOP_MNT="$1/top"
NEXT_NAME=@next
PROVISIONING_DIR=/var/lib/omarchy/provisioning
LOG_FILE="$1/log"
log() { :; }
fail() { echo "$*" >&2; exit 1; }
btrfs() {
  if [[ $1 == subvolume && $2 == snapshot ]]; then
    cp -a "$3" "$4"
  elif [[ $1 == property ]]; then
    :
  else
    return 90
  fi
}
# Account cleanup has its own real-tool suite; keep this fixture focused on USB.
usermod() {
  [[ $1 == --root && ( $2 == "$TOP_MNT/$NEXT_NAME" || $2 == "$TOP_MNT/@factory" ) &&
    $3 == --password && $4 == '!' && $5 == root ]]
}
systemd-id128() { echo new-machine-id; }
encrypted_install() { return 1; }
rebuild_next_boot() { :; }
sync() { :; }
systemctl() {
  # All service changes must address the staged root, never the live machine.
  [[ $1 == "--root=$TOP_MNT/$NEXT_NAME" && $2 == disable && $3 == usbguard.service ]] || return 91
  [[ $2 != "${FAIL_OPERATION:-}" ]] || return 92
  command systemctl "$@"
}
''' + '\n\n'.join(functions) + '\nstage_full_reset\n'
    runner = root / 'run'
    runner.write_text(harness)
    env = os.environ.copy()
    env['FAIL_OPERATION'] = 'disable' if scenario == 'disable-failure' else ''
    result = subprocess.run(['bash', str(runner), str(root)], env=env, capture_output=True, text=True)
    if scenario == 'disable-failure':
      assert result.returncode != 0, 'failed disable must abort reset staging'
      assert (top / '@' / 'original-root').exists(), 'failure must not activate the reset root'
      assert 'could not disable USBGuard' in result.stderr
    else:
      assert result.returncode == 0, result.stderr
      staged = top / '@'
      assert not (staged / enabled_path).is_symlink(), 'reset must not start USBGuard before enrollment'
      assert (staged / 'var/lib/omarchy/provisioning/pending').exists()
      assert (staged / 'etc/usbguard/rules.conf').read_text() == policy
      if scenario == 'enabled':
        assert (factory / enabled_path).is_symlink(), 'only the staged clone is disabled'
        # The owner-enrollment helper enables the daemon after policy and
        # ACL setup. Confirm an ordinary enable can reverse this disable.
        subprocess.run(['systemctl', '--root=' + str(staged), 'enable', 'usbguard.service'],
               check=True, capture_output=True, text=True)
        assert (staged / enabled_path).is_symlink()
    print('ok - factory USB enrollment staging: ' + scenario)
PY
