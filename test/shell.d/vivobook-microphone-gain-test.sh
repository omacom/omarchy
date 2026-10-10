#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command python3
python3 <<'PY'
import os
import pathlib
import subprocess
import tempfile

root = pathlib.Path(os.environ['ROOT'])
source = (root / 'install/user/hardware/asus/fix-vivobook-m5606-mic.sh').read_text()
with tempfile.TemporaryDirectory() as directory:
  stage = pathlib.Path(directory)
  codec = stage / 'proc/asound/card7/codec#0'
  codec.parent.mkdir(parents=True)
  script = stage / 'fix.sh'
  script.write_text(source.replace('/proc/asound/', str(stage / 'proc/asound') + '/'))
  calls = stage / 'calls'
  harness = r'''
cat() {
  if [[ $1 == /sys/class/dmi/id/sys_vendor ]]; then printf '%s\n' "$TEST_VENDOR"; else command cat "$@"; fi
}
omarchy-hw-match() { [[ $TEST_MODEL =~ $1 ]]; }
amixer() { printf 'amixer:%s\n' "$*" >>"$TEST_CALLS"; return "$TEST_MIXER_FAILURE"; }
sudo() { printf 'sudo:%s\n' "$*" >>"$TEST_CALLS"; }
source "$TEST_FIX"
'''
  def run(vendor='ASUSTeK COMPUTER INC.', model='ASUS Vivobook S 16 M5606UA_M5606UA', name='ALC294', subsystem='0x10433be0', failure=0):
    codec.write_text(f'Codec: Realtek {name}\nSubsystem Id: {subsystem}\n')
    calls.write_text('')
    env = dict(os.environ, TEST_VENDOR=vendor, TEST_MODEL=model, TEST_CALLS=str(calls), TEST_FIX=str(script), TEST_MIXER_FAILURE=str(failure))
    subprocess.run(['bash', '-c', harness], env=env, check=True)
    return calls.read_text()
  assert run() == 'amixer:-c 7 set Internal Mic Boost 0\nsudo:alsactl store 7\n'
  assert run(vendor='Other') == ''
  assert run(model='ASUS Vivobook S 16 M5606WA_M5606WA') == ''
  assert run(name='ALC285') == ''
  assert run(subsystem='0x10430000') == ''
  assert 'sudo:' not in run(failure=1)
PY
pass "Vivobook gain fix targets only the verified codec and stores successful changes"
