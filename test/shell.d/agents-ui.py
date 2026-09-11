"""Run actual Agents QML components with fixture-only host/theme dependencies."""
from pathlib import Path
import os
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
runner = sys.argv[2]
plugin = root / 'shell/plugins/agents'
fixtures = root / 'test/shell.d/fixtures/agents-ui'
panel = (plugin / 'Panel.qml').read_text()


def block(source, marker):
  start = source.index(marker)
  depth = 0
  for index in range(source.index('{', start), len(source)):
    if source[index] == '{':
      depth += 1
    elif source[index] == '}':
      depth -= 1
      if depth == 0:
        return source[start:index + 1]
  raise ValueError('Unclosed component: ' + marker)


def themed(source):
  return source.replace('Style.', 'testStyle.').replace('Border.', 'testBorder.')


agent = (plugin / 'Agent.qml').read_text()
file_view = block(agent, '  FileView {')
# Model the file reader's signals; keep the production signal handlers intact.
reader_stub = '''  Item {
    id: usageFile
    property string path
    property bool watchChanges
    property bool printErrors
    signal fileChanged()
    signal loaded()
    signal loadFailed()
    function reload() {}
    function text() { return "" }
'''
agent = agent.replace(file_view, file_view.replace('  FileView {\n', reader_stub, 1))
agent = agent[agent.index('Item {'):].replace('Item {', 'component AgentUnderTest: Item {', 1)
# Expose only the simulated file-removal event to the fixture.
agent = agent.replace('id: root', 'id: root\n  function removeFile() { usageFile.loadFailed() }', 1)
replacements = {
  'alignment': {
    'COMPONENTS': themed(block(panel, '  component UsageValue:') + '\n'
      + panel[panel.index('  component DayRow:'):panel.rfind('\n}')])
  },
  'tabs': {'ROW': themed(block(panel, '    Row {\n      id: providerSwitch'))},
  'pages': {
    'STACK': themed(block(panel, '        Item {\n          id: contentStack')).replace('width: panelFlick.width', 'width: root.width'),
    'COMPONENTS': themed(panel[panel.index('  component ProviderPage:'):panel.rfind('\n}')])
  },
  'worker': {'COMPONENT': agent}
}

env = os.environ | {'QT_QUICK_BACKEND': 'software', 'QT_QPA_PLATFORMTHEME': 'basic', 'QT_QUICK_CONTROLS_STYLE': 'Basic'}
with tempfile.TemporaryDirectory(prefix='agents-ui-') as scratch:
  target = Path(scratch)
  (target / 'ApiCost.js').write_bytes((plugin / 'ApiCost.js').read_bytes())
  for name, values in replacements.items():
    source = (fixtures / (name + '.qml.in')).read_text()
    for key, value in values.items():
      source = source.replace(key, value)
    (target / ('tst_' + name + '.qml')).write_text(source)
  result = subprocess.run([runner, '-platform', 'offscreen', '-input', str(target)], env=env)
  sys.exit(result.returncode)
