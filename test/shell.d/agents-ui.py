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
agent = agent.replace(file_view, file_view.replace('    id: recordFile\n', '').replace('  FileView {\n', reader_stub, 1))
agent = agent.replace('recordFile.reload()', 'usageFile.reload()')
agent = agent[agent.index('Item {'):].replace('Item {', 'component AgentUnderTest: Item {', 1)
# Expose only the simulated file-removal event to the fixture.
agent = agent.replace('id: root', 'id: root\n  function removeFile() { usageFile.loadFailed() }', 1)
machine = (plugin / 'MachineSettings.qml').read_text()
machine = machine[machine.index('Item {'):].replace('Item {', 'component MachineSettings: Item {', 1)
# Test-only observation seam: exercise the production ListView and its real
# delegate layout without adding a public property to the shipped component.
machine = machine.replace('  required property var usage\n',
  '  required property var usage\n  property alias machineListForTest: machineList\n', 1)
key_component = (root / 'shell/Ui/PanelKeyCatcher.qml').read_text()
key_component = key_component[key_component.index('Item {'):].replace('Item {', 'component PanelKeyCatcher: Item {', 1)
button = (root / 'shell/Ui/Button.qml').read_text()
button_keys = button[button.index('  activeFocusOnTab:'):button.index('  // Reserve the largest')]
key_catcher = panel[panel.index('    PanelKeyCatcher {'):panel.index('      Flickable {')]
replacements = {
  'machines': {'MACHINE_COMPONENT': themed(machine).replace('Color.', 'testColor.'),
               'KEY_COMPONENT': key_component, 'KEY_CATCHER': key_catcher, 'BUTTON_KEYS': button_keys,
               'SCROLL_FUNCTION': block(panel, '  function ensureUsageCursorVisible()'),
               'TOP_FUNCTION': block(panel, '  function ensureTopControlsVisible()')},
  'alignment': {
    'COMPONENTS': themed(block(panel, '  component UsageValue:') + '\n'
      + panel[panel.index('  component DayRow:'):panel.rfind('\n}')])
  },
  'tabs': {'ROW': themed(block(panel, '    Row {\n      id: providerSwitch'))},
  'pages': {
    'KEY_COMPONENT': key_component,
    'KEY_CATCHER': key_catcher,
    'SCROLL_FUNCTION': block(panel, '  function ensureUsageCursorVisible()'),
    'TOP_FUNCTION': block(panel, '  function ensureTopControlsVisible()'),
    'COVERAGE_FUNCTION': block(panel, '  function coverageText(provider)'),
    'STACK': themed(block(panel, '        Item {\n          id: contentStack')),
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
