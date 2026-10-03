"""Exercise the actual reservation protocol and client in isolated QML processes.

Offscreen Qt has no layer shell. Only the host's surface type and Wayland
properties are replaced; ownership, sockets, state and visibility stay intact.
Compositor geometry is covered by the disposable-VM acceptance test.
"""
import json
import os
from pathlib import Path
import re
import resource
import shutil
import signal
import socket
import subprocess
import sys
import tempfile
import time

ROOT = Path(sys.argv[1]).resolve()
resource.setrlimit(resource.RLIMIT_CORE, (0, 0))


def check(condition, description):
  assert condition, description
  print('ok - ' + description, flush=True)


class Lab:
  def __enter__(self):
    self.directory = tempfile.TemporaryDirectory(prefix='bar-lifecycle-')
    self.work = Path(self.directory.name)
    (self.work / 'run').mkdir(mode=0o700)
    (self.work / 'home/.local/state/omarchy/toggles').mkdir(parents=True)
    self.path = str(self.work / 'bar.sock')
    self.env = dict(PATH=os.environ['PATH'], HOME=str(self.work / 'home'),
      XDG_RUNTIME_DIR=str(self.work / 'run'), QT_QPA_PLATFORM='offscreen',
      QT_QUICK_BACKEND='software', QS_DISABLE_CRASH_HANDLER='1',
      QS_DISABLE_FILE_WATCHER='1', QS_NO_RELOAD_POPUP='1', LANG='C.UTF-8',
      OMARCHY_BAR_SOCKET=self.path)
    self.processes = []
    self.connections = []
    return self

  def __exit__(self, kind, error, traceback):
    for connection in self.connections:
      connection.close()
    for process, log in self.processes:
      if process.poll() is None:
        process.terminate()
        try:
          process.wait(5)
        except subprocess.TimeoutExpired:
          process.kill()
          process.wait(5)
      log.close()
    if error:
      for log in self.work.glob('*.log'):
        print(log.name + ':\n' + log.read_text(), file=sys.stderr)
    self.directory.cleanup()

  def wait(self, description, predicate, timeout=8):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
      if predicate():
        return
      time.sleep(.05)
    raise AssertionError(description)

  def ipc(self, directory, target, function, *args, env=None):
    result = subprocess.run(['quickshell', 'ipc', '-p', str(directory), 'call',
      target, function, *map(str, args)], env=self.env if env is None else env, capture_output=True, text=True, timeout=2)
    return result.stdout.strip() if result.returncode == 0 else ''

  def launch(self, directory, env=None):
    log = (self.work / (directory.name + '.log')).open('w')
    process = subprocess.Popen(['quickshell', '-p', str(directory), '--no-color'],
      env=self.env if env is None else env, stdout=log, stderr=log)
    self.processes.append((process, log))
    return process

  def host(self, name='host', watch=True):
    directory = self.work / name
    directory.mkdir()
    qml = (ROOT / 'shell/bar-reservation/shell.qml').read_text()
    if not watch:
      qml = qml.replace('watchChanges: true', 'watchChanges: false')
    qml = qml.replace('import Quickshell.Wayland\n', '')
    qml = qml.replace('    model: Quickshell.screens\n    delegate: PanelWindow {',
      '    id: surfaces\n    model: Quickshell.screens\n    delegate: FloatingWindow {')
    qml, count = re.subn(r'      anchors \{.*?\n      }\n', '', qml, count=1, flags=re.S)
    assert count == 1
    for line in ['      exclusiveZone: root.snapshot.size\n',
      '      WlrLayershell.layer: WlrLayer.Bottom\n',
      '      WlrLayershell.namespace: "omarchy-bar-reservation"\n']:
      assert line in qml
      qml = qml.replace(line, '')
    qml = qml.rstrip()[:-1] + '''
  IpcHandler {
    target: "test"
    function mapped(): bool { return surfaces.instances[0].visible }
  }
}
'''
    (directory / 'shell.qml').write_text(qml)
    shutil.copy(ROOT / 'shell/bar-reservation/State.js', directory)
    process = self.launch(directory)
    self.wait('host answers', lambda: self.ipc(directory, 'reservation', 'ping') == 'ok')
    return directory, process

  def client(self, name='client', size=26, socket_value=True):
    directory = self.work / name
    directory.mkdir()
    shutil.copy(ROOT / 'shell/services/BarReservation.qml', directory)
    bar = (ROOT / 'shell/plugins/bar/Bar.qml').read_text()
    visible = re.search(r'    visible: (!remapGuard\.remapping && [^\n]+)', bar).group(1)
    visible = visible.replace('remapGuard.remapping', 'false').replace('root.', 'test.barRoot.')
    (directory / 'shell.qml').write_text('''import QtQuick
import Quickshell
import Quickshell.Io
ShellRoot {
  id: test
  property QtObject bar: QtObject {
    property string position: "top"
    property int barSize: %d
    property bool barHidden: false
    property bool hiddenStateKnown: true
    property color background: "#202020"
    property color foreground: "#ffffff"
  }
  property BarReservation barReservation: BarReservation {
    bar: test.bar; supported: true; contentReady: true
  }
  property QtObject barRoot: QtObject { property var shell: test }
  readonly property bool barVisible: %s
  IpcHandler {
    target: "test"
    function state(): string {
      var r = test.barReservation
      return JSON.stringify({ configured: r.configured, managed: r.managed,
        acknowledged: r.acknowledged, waiting: r.waiting, visible: test.barVisible,
        retryDelay: r.retryDelay })
    }
    function resize(size: int): void { test.bar.barSize = size }
  }
}
''' % (size, visible))
    env = dict(self.env)
    if socket_value is None:
      env.pop('OMARCHY_BAR_SOCKET')
    elif socket_value is not True:
      env['OMARCHY_BAR_SOCKET'] = socket_value
    process = self.launch(directory, env)
    self.wait('client answers', lambda: bool(self.ipc(directory, 'test', 'state')))
    return directory, process

  def state(self, client):
    return json.loads(self.ipc(client, 'test', 'state'))

  def status(self, host):
    return json.loads(self.ipc(host, 'reservation', 'status'))

  def connect(self):
    connection = socket.socket(socket.AF_UNIX)
    connection.settimeout(2)
    connection.connect(self.path)
    self.connections.append(connection)
    return connection

  def send(self, connection, **changes):
    value = dict(version=1, screens=[''], position='top', size=26,
      hidden=False, ready=True, background='#111111', foreground='#eeeeee')
    value.update(changes)
    connection.sendall((json.dumps(value) + '\n').encode())
    return connection.recv(32)


with Lab() as lab:
  for index, value in enumerate([None, '']):
    client, _ = lab.client('unconfigured-' + str(index), socket_value=value)
    state = lab.state(client)
    check(not state['configured'] and not state['waiting'] and state['visible'],
      'an unset or empty socket maps the bar immediately')

with Lab() as lab:
  lab.env['WAYLAND_DISPLAY'] = 'wayland-selected'
  host, process = lab.host()
  other_env = dict(lab.env, WAYLAND_DISPLAY='wayland-other', OMARCHY_BAR_SOCKET=lab.path + '-other')
  other = lab.launch(host, other_env)
  lab.wait('second display host answers', lambda: lab.ipc(host, 'reservation', 'ping', env=other_env) == 'ok')
  lab.ipc(host, 'reservation', 'restarting')
  check(lab.status(host)['message'] == 'Shell restarting…' and
    json.loads(lab.ipc(host, 'reservation', 'status', env=other_env))['message'] == 'Shell starting…',
    'display-scoped restart IPC leaves the newer other-session host untouched')
  subprocess.run(['quickshell', 'kill', '-p', str(host)], env=lab.env, capture_output=True, check=True, timeout=5)
  process.wait(5)
  check(other.poll() is None and lab.ipc(host, 'reservation', 'ping', env=other_env) == 'ok',
    'display-scoped shutdown leaves another session using the same configuration alive')

with Lab() as lab:
  client, _ = lab.client()
  lab.wait('fallback is visible', lambda: lab.state(client)['visible'])
  with socket.socket(socket.AF_UNIX) as server:
    server.bind(lab.path)
    server.listen()
    server.settimeout(5)
    connection, _ = server.accept()
    with connection:
      connection.settimeout(2)
      connection.recv(16384)
      state = lab.state(client)
      check(not state['managed'] and not state['acknowledged'] and state['visible'],
        'a transport connection alone never relinquishes the fallback reservation')
      connection.sendall(b'ok\n')
      lab.wait('acknowledgement transfers ownership', lambda: lab.state(client)['managed'])

for initially_hidden in [False, True]:
  with Lab() as lab:
    flag = lab.work / 'home/.local/state/omarchy/toggles/bar-off'
    if initially_hidden:
      flag.touch()
    host, _ = lab.host(watch=False)
    owner = lab.connect()
    assert lab.send(owner, hidden=initially_hidden) == b'ok\n'
    # Fault injection: the host's directory watch misses a real toggle, while
    # the live bar has re-probed it through syncHidden and publishes its state.
    if initially_hidden:
      flag.unlink()
    else:
      flag.touch()
    assert lab.send(owner, hidden=not initially_hidden) == b'ok\n'
    lab.wait('live hidden state takes precedence',
      lambda: lab.ipc(host, 'test', 'mapped') == str(initially_hidden).lower())
    check(True, 'live snapshots override missed hidden-flag events in both directions')
    owner.close()
    lab.wait('disconnected host rechecks the flag', lambda: not lab.status(host)['ready'])
    flag.unlink(missing_ok=True)
    lab.wait('outage polling still sees later flag changes', lambda: lab.ipc(host, 'test', 'mapped') == 'true')

with Lab() as lab:
  host, _ = lab.host()
  old_owner = lab.connect()
  token = '12345678-1234-1234-1234-123456789abc'
  assert lab.send(old_owner, client=token) == b'ok\n'
  replacement = lab.connect()
  check(lab.send(replacement, client=token, background='#123456') == b'ok\n',
    'a re-exec adopts its launcher reservation while a core child holds the old socket')
  old_owner.close()
  check(lab.status(host)['ready'] and lab.status(host)['snapshot']['background'] == '#123456',
    'closing the inherited old socket never disconnects the replacement owner')
  duplicate = lab.connect()
  check(lab.send(duplicate, client='87654321-1234-1234-1234-123456789abc') == b'',
    'a different launcher cannot supersede a live owner')

with Lab() as lab:
  host, _ = lab.host()
  client, process = lab.client(size=300)
  lab.wait('large bar is acknowledged', lambda: lab.state(client)['acknowledged'])
  check(lab.status(host)['snapshot']['size'] == 300 and lab.ipc(host, 'test', 'mapped') == 'true',
    'a 300-pixel bar receives a live reservation')
  process.terminate()
  process.wait(5)
  lab.wait('large bar disconnects', lambda: not lab.status(host)['ready'])
  check(lab.ipc(host, 'test', 'mapped') == 'true', 'a large bar retains its reservation through shell loss')

with Lab() as lab:
  host, _ = lab.host()
  owner = lab.connect()
  check(lab.send(owner) == b'ok\n', 'a valid owner is acknowledged')
  for patch in [{}, {'version': 2}]:
    duplicate = lab.connect()
    check(lab.send(duplicate, **patch) == b'', 'a duplicate owner is rejected')
    check(lab.status(host)['ready'] and lab.status(host)['snapshot']['screens'] == [''],
      'rejecting a duplicate preserves the live owner')
  check(lab.send(owner, size=-1) == b'', 'an invalid live owner is rejected')
  check(lab.status(host)['snapshot']['screens'] == [], 'rejecting the live owner releases its old zone')
  for patch in [{'size': -1}, {'version': 2}]:
    owner = lab.connect()
    assert lab.send(owner) == b'ok\n'
    lab.ipc(host, 'reservation', 'restarting')
    owner.close()
    lab.wait('owner disconnects', lambda: not lab.status(host)['ready'])
    check(lab.ipc(host, 'test', 'mapped') == 'true', 'a normal restart retains its reservation')
    rejected = lab.connect()
    check(lab.send(rejected, **patch) == b'', 'an unsupported replacement is rejected')
    check(lab.status(host)['snapshot']['screens'] == [] and lab.ipc(host, 'test', 'mapped') == 'false',
      'rejecting an ownerless replacement releases the stale reservation')

with Lab() as lab:
  host, _ = lab.host()
  owner = lab.connect()
  assert lab.send(owner) == b'ok\n'
  owner.close()
  lab.wait('owner disconnects', lambda: not lab.status(host)['ready'])
  client, _ = lab.client(size=-1)
  lab.wait('rejected client backs off', lambda: lab.state(client)['retryDelay'] >= 4000)
  state = lab.state(client)
  check(not state['managed'] and state['visible'] and lab.status(host)['snapshot']['screens'] == [],
    'a rejected real client falls back without retaining the old strip and backs off')
  lab.ipc(client, 'test', 'resize', 26)
  lab.wait('corrected snapshot is accepted', lambda: lab.state(client)['acknowledged'])
  check(lab.status(host)['ready'] and lab.state(client)['retryDelay'] == 1000,
    'a corrected snapshot reconnects and resets the retry delay')

with Lab() as lab:
  client, process = lab.client()
  lab.wait('initial connection fails', lambda: lab.state(client)['retryDelay'] >= 2000)
  host, host_process = lab.host()
  lab.wait('late first host connects', lambda: lab.state(client)['acknowledged'])
  check(lab.status(host)['ready'], 'a host that starts after a failed connect is adopted')
  host_process.kill()
  host_process.wait(5)
  lab.wait('reconnection fails', lambda: lab.state(client)['retryDelay'] >= 2000)
  host, _ = lab.host('replacement-host')
  lab.wait('late replacement connects', lambda: lab.state(client)['acknowledged'])
  check(lab.status(host)['ready'], 'a host returning after a failed retry is adopted')
  process.terminate()
  process.wait(5)
  lab.wait('client disconnects', lambda: not lab.status(host)['ready'])
  check(lab.ipc(host, 'test', 'mapped') == 'true', 'the recovered host preserves space at the next shell restart')
