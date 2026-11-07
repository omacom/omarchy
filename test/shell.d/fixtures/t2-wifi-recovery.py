"""Exercise recovery limits without opening a socket or downloading a blob."""

import contextlib
import importlib.util
import io
import os
from pathlib import Path
import signal
import shutil
import subprocess
import sys
import time
from types import SimpleNamespace

root = Path(os.environ['ROOT'])
scratch = Path(sys.argv[1])
spec = importlib.util.spec_from_file_location('recovery', root / 'install/hardware/apple/macrecovery.py')
recovery = importlib.util.module_from_spec(spec)
spec.loader.exec_module(recovery)


class Response:
  def __init__(self, data=b'', headers=None, mode=None):
    self.data = data
    self.headers = headers or {}
    self.mode = mode
    self.closed = False
    self.reads = 0

  def info(self):
    return self.headers

  def read(self, size=-1):
    self.reads += 1
    if self.mode == 'stream':
      # The guard makes the original unbounded code fail safely too.
      assert self.reads < 30, 'unbounded stream reached the fixture guard'
      time.sleep(0.01)
      return b'x'
    if self.mode == 'blocked':
      time.sleep(0.3)
      return b''
    if size < 0:
      size = len(self.data)
    chunk, self.data = self.data[:size], self.data[size:]
    return chunk

  def close(self):
    self.closed = True


def must_reject(action, message):
  try:
    with contextlib.redirect_stdout(io.StringIO()):
      action()
  except (RuntimeError, TimeoutError) as error:
    assert message in str(error), str(error)
  else:
    raise AssertionError(f'expected rejection: {message}')


original_query = recovery.run_query
recovery.MAX_IMAGE_BYTES = 8
for headers in ({}, {'Content-Length': '1'}, {'Content-Length': '100'}):
  response = Response(b'0123456789abcdef', headers)
  recovery.run_query = lambda *args, **kwargs: response
  target = scratch / 'bounded.dmg'
  must_reject(lambda: recovery.save_image('http://fixture/image', '', target.name, str(scratch)), 'size limit')
  assert target.stat().st_size <= 8
  assert response.closed
print('ok - recovery rejects oversized bodies with absent, dishonest, or excessive Content-Length')

response = Response(b'01234567', {'Content-Length': '1'})
recovery.run_query = lambda *args, **kwargs: response
terminal_size = recovery.shutil.get_terminal_size
recovery.shutil.get_terminal_size = lambda: os.terminal_size((62, 24))
output = io.StringIO()
with contextlib.redirect_stdout(output):
  recovery.save_image('http://fixture/image', '', 'progress.dmg', str(scratch))
assert output.getvalue().count('=') <= 20, 'dishonest length inflated the progress bar'
recovery.shutil.get_terminal_size = terminal_size
print('ok - dishonest Content-Length cannot grow progress output beyond the terminal width')

recovery.run_query = original_query
recovery.MAX_METADATA_BYTES = 8
response = Response(b'0123456789abcdef')
recovery.urlopen = lambda *args, **kwargs: response
must_reject(lambda: recovery.run_query('http://fixture/catalog', {}), 'size limit')
assert response.closed
print('ok - recovery bounds and closes unauthenticated metadata responses')

recovery.get_session = lambda args: 'fixture-session'
recovery.get_image_info = lambda *args, **kwargs: {
  recovery.INFO_PRODUCT: 'fixture',
  recovery.INFO_SIGN_LINK: 'http://fixture/chunklist',
  recovery.INFO_SIGN_SESS: '',
  recovery.INFO_IMAGE_LINK: 'http://fixture/image',
  recovery.INFO_IMAGE_SESS: '',
}
args = SimpleNamespace(board_id='fixture', mlb='', diagnostics=False, os_type='default', verbose=False, basename='deadline', outdir=str(scratch))
recovery.verify_image = lambda *args: None
recovery.MAX_CHUNKLIST_BYTES = 4
response = Response(b'01234567')
recovery.run_query = lambda *args, **kwargs: response
must_reject(lambda: recovery.action_download(args), 'size limit')
assert (scratch / 'deadline.chunklist').stat().st_size <= 4
assert response.closed
print('ok - chunklist downloads have their own smaller byte limit')
recovery.MAX_CHUNKLIST_BYTES = 1024
recovery.DOWNLOAD_SECONDS = 0.05
for mode in ('stream', 'blocked'):
  response = Response(mode=mode)
  recovery.run_query = lambda *args, **kwargs: response
  must_reject(lambda: recovery.action_download(args), 'total time limit')
  assert response.closed
  assert signal.getitimer(signal.ITIMER_REAL) == (0.0, 0.0)
print('ok - one recovery deadline interrupts steady streaming and a blocking read')

# Re-enter as sudo's env_reset would, using the real shared bootstrap with its
# fixed installed paths redirected to a disposable installation.
linked = scratch / 'linked'
linked.mkdir()
conf = scratch / 'omarchy.conf'
conf.write_text(f'export OMARCHY_PATH="{linked}"\n')
bootstrap = scratch / 'env-bootstrap'
bootstrap.write_text((root / 'default/bash/env-bootstrap').read_text().replace('/etc/omarchy.conf', str(conf)))
command = scratch / 'root-wifi'
command.write_text((root / 'bin/omarchy-hw-t2-wifi').read_text().replace('/usr/share/omarchy/default/bash/env-bootstrap', str(bootstrap)))
helper = linked / 'install/hardware/apple/t2-wifi-rename.py'
helper.parent.mkdir(parents=True)
helper.write_text('from pathlib import Path\nPath(__file__).with_suffix(".called").touch()\n')
bin_dir = scratch / 'root-bin'
bin_dir.mkdir()
for name in ('cat', 'dirname', 'mktemp', 'mkdir', 'rm', 'setsid'):
  (bin_dir / name).symlink_to(shutil.which(name))
for name, body in {
  'lspci': "echo '[106b:1801]'",
  'omarchy-cmd-present': 'exit 1',
  'modprobe': 'exit 99',
  'sudo': 'exit 99',
  'tar': 'exit 1',
  'python3': f'[[ $1 == "{helper}" ]] || exit 99\nexec /usr/bin/python3 "$@"',
}.items():
  path = bin_dir / name
  path.write_text('#!/bin/bash\n' + body + '\n')
  path.chmod(0o755)
tree = scratch / 'root-tree'
(tree / 'wifi').mkdir(parents=True)
firmware = scratch / 'root-firmware'
firmware.mkdir()
(scratch / 'root-product').write_text('MacBookPro15,2\n')
(scratch / 'root-vendor').write_text('Apple Inc.\n')
env = {key: value for key, value in os.environ.items() if key in ('HOME', 'TMPDIR', 'XDG_RUNTIME_DIR') or key.startswith('XDG_')}
env.update(PATH=str(bin_dir), OMARCHY_DMI_PRODUCT_NAME=str(scratch / 'root-product'), OMARCHY_DMI_SYS_VENDOR=str(scratch / 'root-vendor'), OMARCHY_T2_WIFI_FIRMWARE_DIR=str(firmware), OMARCHY_T2_WIFI_FIRMWARE_TREE=str(tree))
result = subprocess.run(['/bin/bash', str(command)], env=env, capture_output=True, text=True, timeout=5)
assert result.returncode == 1, result.stderr
assert helper.with_suffix('.called').exists(), result.stderr
print('ok - an env-reset root entry uses the dev-linked helper selected by shared setup')
