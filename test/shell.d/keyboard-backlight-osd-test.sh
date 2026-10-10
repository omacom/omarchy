#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
python3 - "$ROOT" <<'PY'
import contextlib, importlib.util, io, json, os, pathlib, subprocess, sys, tempfile
root = pathlib.Path(sys.argv[1])
spec = importlib.util.spec_from_file_location('keyboard_monitor', root / 'shell/plugins/keyboard-backlight/monitor.py')
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
for value in range(4):
  payload = m.payload_for(value, 3)
  assert payload['value'] == str(value) and payload['max'] == '3'
  assert payload['progressText'] == f'{value}/3'
assert m.payload_for(256, 512)['progressText'] == '50%'
assert m.payload_for(-1, 3)['value'] == '0'
assert m.payload_for(99, 3)['value'] == '3'
with tempfile.TemporaryDirectory() as tmp:
  t = pathlib.Path(tmp)
  # No supported devices: no startup OSD and no long-running idle process.
  output = io.StringIO()
  with contextlib.redirect_stdout(output): m.monitor(t)
  assert output.getvalue() == ''
  led = t / 'mock::kbd_backlight'; led.mkdir()
  (led / 'max_brightness').write_text('3')
  (led / 'brightness').write_text('2')
  (led / 'brightness_hw_changed').write_text('2')
  class FakePoll:
    def register(self, fd, flags): self.fd = fd; self.sent = False
    def unregister(self, fd): pass
    def poll(self):
      if not self.sent:
        self.sent = True
        return [(self.fd, m.select.POLLPRI)]
      return [(self.fd, m.select.POLLHUP)]
  original = m.select.poll
  m.select.poll = FakePoll
  with contextlib.redirect_stdout(output): m.monitor(t)
  m.select.poll = original
  assert json.loads(output.getvalue()) == m.payload_for(2, 3)
  assert (led / 'brightness').read_text() == '2'
  b = t / 'bin'; b.mkdir()
  shell = b / 'omarchy-shell'
  shell.write_text('#!/bin/bash\nprintf "%s\\n" "${@: -1}"\n'); shell.chmod(0o755)
  env = dict(os.environ, PATH=str(b) + ':' + os.environ['PATH'])
  def osd(args):
    return json.loads(subprocess.check_output(['bash', str(root / 'bin/omarchy-osd'), *args],env=env,text=True))
  assert osd(['-p','67','--progress-text','2/3'])['progressText'] == '2/3'
  assert osd(['--progress-text','2/3','-p','67'])['progressText'] == '2/3'
  assert osd(['-p','67'])['progressText'] == '67%'
print('ok - hardware keyboard events show actual levels without writes or a startup OSD; CLI keeps percentage defaults')
PY
