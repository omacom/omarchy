"""Production WorkerScript/usage/pricing bindings with synthetic, passive IO."""
import os
from pathlib import Path
import re
import resource
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
runner = sys.argv[2]
plugin = root / 'shell/plugins/agents'
fixture = root / 'test/shell.d/fixtures/agents-ui/cache-lifetime.qml.in'
with tempfile.TemporaryDirectory(prefix='agents-cache-lifetime-') as directory:
  target = Path(directory)
  for name in ('Main.qml', 'Agent.qml', 'Pricing.qml', 'ApiCost.js', 'RemoteUsage.js'):
    source = (plugin / name).read_text()
    source = source.replace('import Quickshell\n', '').replace('import Quickshell.Io\n', '')
    source = re.sub(r'Quickshell.env\("[^"]+"\)', '""', source)
    # Align preparation's wall clock with the fixed synthetic usage dates.
    # WorkerScript delivery and Qt's event loop retain their real timing.
    if name == 'Main.qml':
      source = source.replace('Date.now()', 'new Date(2026, 8, 12, 12).getTime()')
      source = source.replace('new Date()', 'new Date(2026, 8, 12, 12)')
    (target / name).write_text(source)
  # Only system IO is substituted. Production WorkerScript delivery, generation
  # guards, provider/scopes bindings and price caches execute unchanged.
  (target / 'Process.qml').write_text('''import QtQuick
Item {
  property bool running: false
  property int fixtureStarts: 0
  onRunningChanged: if (running) fixtureStarts++
  property var command: []
  property var environment: ({})
  property var stdout
  property var stderr
  signal exited(int code)
}
''')
  (target / 'FileView.qml').write_text('''import QtQuick
Item {
  property string path
  property bool watchChanges
  property bool printErrors
  property bool atomicWrites
  signal loaded()
  signal loadFailed()
  signal fileChanged()
  function reload() {}
  function text() { return "" }
  function setText(value) {}
}
''')
  (target / 'StdioCollector.qml').write_text('''import QtQuick
Item { property bool waitForEnd; property string text; signal streamFinished() }
''')
  # Keep the retained ProviderPage price bindings from the actual consumer.
  panel = (plugin / 'Panel.qml').read_text()
  bindings = '\n'.join(line for line in panel.splitlines() if any(
    line.strip().startswith('readonly property var ' + name + ':') for name in ('modelPresentation', 'pricedDailyRows')))
  assert len(bindings.splitlines()) == 2
  (target / 'tst_cache_lifetime.qml').write_text(fixture.read_text().replace('PRICE_BINDINGS', bindings))
  env = {k: v for k, v in os.environ.items() if k not in (
    'DISPLAY', 'WAYLAND_DISPLAY', 'DBUS_SESSION_BUS_ADDRESS', 'QML_IMPORT_PATH', 'QML2_IMPORT_PATH')}
  for name in ('home', 'config', 'cache', 'state', 'runtime'):
    (target / name).mkdir(mode=0o700)
  env.update(HOME=str(target / 'home'), XDG_CONFIG_HOME=str(target / 'config'),
             XDG_CACHE_HOME=str(target / 'cache'), XDG_STATE_HOME=str(target / 'state'),
             XDG_RUNTIME_DIR=str(target / 'runtime'), QT_QPA_PLATFORM='offscreen',
             QT_QUICK_BACKEND='software', QT_QPA_PLATFORMTHEME='basic',
             QT_QUICK_CONTROLS_STYLE='Basic', QML_DISABLE_DISK_CACHE='1')
  def limits():
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    resource.setrlimit(resource.RLIMIT_AS, (1536 * 1024 * 1024, 1536 * 1024 * 1024))
  try:
    result = subprocess.run([runner, '-nocrashhandler', '-platform', 'offscreen', '-input', str(target)],
                            env=env, preexec_fn=limits, timeout=30)
    sys.exit(result.returncode if result.returncode >= 0 else 128 - result.returncode)
  except subprocess.TimeoutExpired:
    sys.exit('Qt cache lifetime test exceeded 30 seconds')
