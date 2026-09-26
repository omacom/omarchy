#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - "$ROOT" <<'PY'
from pathlib import Path
import json
import subprocess
import sys
import tempfile

source = Path(sys.argv[1]) / 'etc/NetworkManager/dispatcher.d/90-omarchy-bcm4350-coexistence'
assert source.stat().st_mode & 0o111, 'dispatcher must ship executable'

with tempfile.TemporaryDirectory() as directory:
  root = Path(directory)
  device = root / 'net/wlan0/device'
  device.mkdir(parents=True)
  for name, value in [('vendor', '0x14e4'), ('device', '0x43a3'), ('revision', '0x05')]:
    (device / name).write_text(value)
  (device / 'driver').symlink_to(root / 'drivers/brcmfmac')
  (root / 'model').write_text('MacBookPro14,1\n')

  # Run the actual entrypoint with only its external paths redirected. No root,
  # network, host /run writes, or hardware commands are involved.
  script = source.read_text()
  for original, replacement in [('/sys/class/dmi/id/product_name', root / 'model'),
                                ('/sys/class/net', root / 'net'),
                                ('/run/omarchy-bcm4350-coexistence', root / 'state'),
                                ('/usr/bin/iw', root / 'iw')]:
    script = script.replace(original, str(replacement))
  dispatcher = root / 'dispatcher'
  dispatcher.write_text(script)
  dispatcher.chmod(0o755)
  iw = root / 'iw'
  iw.write_text('''#!/usr/bin/python3
from pathlib import Path
import json
import struct
import sys

root = Path(__file__).parent
config = json.loads((root / 'config').read_text())
args = sys.argv[1:]
assert args[:2] == ['dev', 'wlan0']
if args[2:] == ['link']:
  print('freq: ' + str(config['frequency']) if config['frequency'] else 'Not connected.')
else:
  assert args[2:] == ['vendor', 'recvbin', '0x001018', '0x1', '-']
  request = sys.stdin.buffer.read()
  cmd, length, offset, setting, magic = struct.unpack_from('=IiIII', request)
  assert offset == 20 and magic == 0
  name, value = request[20:].split(b'\\0', 1)
  with (root / 'calls').open('a') as log:
    log.write(name.decode() + ('=' + str(struct.unpack('<I', value)[0]) if setting else '') + '\\n')
  assert cmd == (263 if setting else 262)
  assert length == (len(request) - 20 if setting else 256)
  if config.get('fail'):
    sys.exit(1)
  if setting:
    assert name == b'btc_mode' and len(value) == 4
    mode = struct.unpack('<I', value)[0]
    assert mode in (4, 5)
    if not config.get('ignore_write'):
      config['mode'] = mode
      (root / 'config').write_text(json.dumps(config))
    sys.exit(0)
  assert value == b'' and name in (b'ver', b'btc_mode')
  payload = config['version'].encode() + b'\\0' if name == b'ver' else struct.pack('<I', config['mode'])
  if config.get('malformed'):
    sys.stdout.buffer.write(b'\\x02\\x00\\x02\\x00')
  else:
    # LEN is padded to four bytes; DATA carries the nested-attribute flag.
    prefix = struct.pack('=HHH', 6, 1, len(payload)) + b'\\0\\0'
    data = struct.pack('=HH', len(payload) + 4, 0x8002) + payload
    sys.stdout.buffer.write(prefix + data + b'\\0' * (-len(data) % 4))
''')
  iw.chmod(0o755)
  defaults = {'mode': 5, 'frequency': 2437,
              'version': 'wl0: Nov 26 2015 version 7.35.180.133 (r602372) FWID 01-c45b39d6'}
  state = root / 'state/wlan0'

  def reset(**changes):
    state.unlink(missing_ok=True)
    (root / 'calls').write_text('')
    configure(**(defaults | changes))

  def configure(**changes):
    config = json.loads((root / 'config').read_text()) if (root / 'config').exists() else {}
    config.update(changes)
    (root / 'config').write_text(json.dumps(config))

  def invoke(action='up', iface='wlan0'):
    result = subprocess.run([str(dispatcher), iface, action], capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
    return json.loads((root / 'config').read_text())['mode']

  def writes():
    return [line for line in (root / 'calls').read_text().splitlines() if '=' in line]

  reset()
  assert invoke() == 4 and state.exists()
  assert invoke('reapply') == 4 and writes() == ['btc_mode=4']
  configure(frequency=5180)
  assert invoke() == 5 and not state.exists()
  print('ok - 2.4 GHz applies once and a 5 GHz activation restores the owned policy')

  reset()
  invoke()
  configure(frequency=None)
  assert invoke('down') == 5 and not state.exists()
  assert invoke() == 5 and writes() == ['btc_mode=4', 'btc_mode=5']
  reset()
  assert invoke('down') == 4
  print('ok - disconnect restores; queued events use the current link, not stale actions')

  for action in ['up', 'reapply', 'dhcp4-change', 'dhcp6-change']:
    reset()
    assert invoke(action) == 4
  for policy in [0, 1, 2, 3, 4, 6]:
    reset(mode=policy)
    assert invoke() == policy and not writes() and not state.exists()
    configure(frequency=5180)
    assert invoke() == policy and not writes()
  reset()
  invoke()
  configure(mode=2)
  invoke('reapply')
  configure(mode=4, frequency=5180)
  assert invoke() == 4 and not state.exists()
  print('ok - network events reapply the quirk; independent policies are never adopted or restored')

  for name, value in [('vendor', '0x8086'), ('device', '0x43ba'), ('revision', '0x06')]:
    original = (device / name).read_text()
    (device / name).write_text(value)
    reset()
    invoke()
    assert not (root / 'calls').read_text()
    (device / name).write_text(original)
  (device / 'driver').unlink()
  (device / 'driver').symlink_to(root / 'drivers/wl')
  reset()
  invoke()
  assert not (root / 'calls').read_text()
  (device / 'driver').unlink()
  (device / 'driver').symlink_to(root / 'drivers/brcmfmac')
  (root / 'model').write_text('MacBookPro11,4\n')
  invoke()
  assert not (root / 'calls').read_text()
  (root / 'model').unlink()
  invoke()
  assert not (root / 'calls').read_text()
  (root / 'model').write_text('MacBookPro14,1\n')
  print('ok - unrelated models, chip revisions, drivers, and missing DMI never receive vendor commands')

  for version in ['version 7.35.180.134 FWID 01-c45b39d6',
                  'version 7.35.180.133 FWID 01-newfirmware']:
    reset(version=version)
    assert invoke() == 5 and not writes()
  reset(frequency=5180)
  assert invoke() == 5 and not writes()
  for action, iface in [('vpn-up', 'wlan0'), ('up', '../wlan0'), ('up', 'wlan0;id')]:
    reset()
    invoke(action, iface)
    assert not (root / 'calls').read_text()
  print('ok - changed firmware, 5 GHz, unrelated events, and invalid interfaces are left alone')

  for failure in ['fail', 'malformed', 'ignore_write']:
    reset(**{failure: True})
    assert invoke() == 5
    assert writes() == (['btc_mode=4'] if failure == 'ignore_write' else [])
    # A lost acknowledgement remains recoverable at the next network event.
    if failure == 'ignore_write':
      assert state.exists()
    configure(**{failure: False})
  reset()
  invoke()
  configure(frequency=5180, ignore_write=True)
  assert invoke() == 4 and state.exists()
  configure(ignore_write=False)
  assert invoke() == 5 and not state.exists()
  print('ok - firmware errors do not fail activation; failed restoration retains ownership for retry')
PY
