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
main = (plugin / 'Main.qml').read_text()


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


def block_body(source, marker):
  value = block(source, marker)
  return value[value.index('{') + 1:-1]


def source_line(source, marker):
  start = source.index(marker)
  start = source.rfind('\n', 0, start) + 1
  end = source.find('\n', start)
  return source[start:] if end < 0 else source[start:end]


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
keyboard_panel = (root / 'shell/Ui/KeyboardPanel.qml').read_text()
remote_refresh = block(main, '  Process {\n    id: remoteRefresh')
machine_command = block(main, '  Process {\n    id: machineCommand')
machine_choices = source_line(main, 'readonly property var machineChoices:')
if '.concat(remoteActive ? remoteMachines : [])' in main:
  machine_choices += '\n' + source_line(main, '.concat(remoteActive ? remoteMachines : [])')
scope_state = '\n'.join([
  source_line(main, 'property string selectedMachineId:'),
  source_line(main, 'property var remoteSnapshot:'),
  source_line(main, 'readonly property var remoteMachines:'),
  source_line(main, 'readonly property bool remoteActive:'),
  source_line(main, 'property string scopeDate:'),
  block(main, '  readonly property var machineScopes:'),
  block(main, '  readonly property var enabledProviders:'),
  block(main, '  readonly property var preparedProviderViews:'),
  source_line(main, 'readonly property var allProviders:'),
  machine_choices,
  block(main, '  function machineStatus(nowMs, providerId)')
])
if '  function normalizeSelectedMachine()' in main:
  scope_state += '\n' + block(main, '  function normalizeSelectedMachine()')
if '  onRemoteActiveChanged:' in main:
  scope_state += '\n' + source_line(main, 'onRemoteActiveChanged:')
replacements = {
  'machines': {'MACHINE_COMPONENT': themed(machine).replace('Color.', 'testColor.'),
               'KEY_COMPONENT': key_component, 'KEY_CATCHER': key_catcher, 'BUTTON_KEYS': button_keys,
               'SCROLL_FUNCTION': block(panel, '  function ensureUsageCursorVisible()'),
               'CONTENT_ITEM_FUNCTION': block(panel, '  function ensureContentItemVisible(item)'),
               'TOP_FUNCTION': block(panel, '  function ensureTopControlsVisible()'),
               'ACTIVE_FUNCTION': block(panel, '  function activeProviderPage()'),
               'MANAGE_FUNCTION': block(main, '  function manageMachine(args)').replace('root.', 'usage.'),
               'SCHEDULE_FUNCTION': block(main, '  function scheduleRemoteRefresh()').replace('root.', 'usage.'),
               'REFRESH_FUNCTION': block(main, '  function refreshMachines()').replace('root.', 'usage.'),
               'BACKGROUND_EXIT': block_body(remote_refresh, '    onExited:').replace('root.', 'usage.'),
               'COMMAND_EXIT': block_body(machine_command, '    onExited:').replace('root.', 'usage.')},
  'alignment': {
    'COMPONENTS': themed(block(panel, '  component UsageValue:') + '\n'
      + panel[panel.index('  component DayRow:'):panel.rfind('\n}')])
  },
  'tabs': {'ROW': themed(block(panel, '    Row {\n      id: providerSwitch'))},
  'pages': {
    'MACHINE_COMPONENT': themed(machine).replace('Color.', 'testColor.'),
    'LEAVE_FUNCTION': block(panel, '  function leaveMachines()'),
    'KEY_COMPONENT': key_component,
    'KEY_CATCHER': key_catcher,
    'SCROLL_FUNCTION': block(panel, '  function ensureUsageCursorVisible()'),
    'CONTENT_ITEM_FUNCTION': block(panel, '  function ensureContentItemVisible(item)'),
    'TOP_FUNCTION': block(panel, '  function ensureTopControlsVisible()'),
    'ACTIVE_FUNCTION': block(panel, '  function activeProviderPage()'),
    'FITTED_FUNCTION': block(keyboard_panel, '  function fittedContentHeight(implicitHeight, cap)'),
    'COVERAGE_FUNCTION': block(panel, '  function coverageText(provider)'),
    'FOOTER_FUNCTION': block(panel, '  function footerText(provider)'),
    'SCOPE_STATE': scope_state,
    'STACK': themed(block(panel, '        Item {\n          id: contentStack')),
    'COMPONENTS': themed(panel[panel.index('  component ProviderPage:'):panel.rfind('\n}')])
  },
  'worker': {'COMPONENT': agent}
}

env = os.environ | {'QT_QUICK_BACKEND': 'software', 'QT_QPA_PLATFORMTHEME': 'basic', 'QT_QUICK_CONTROLS_STYLE': 'Basic'}
with tempfile.TemporaryDirectory(prefix='agents-ui-') as scratch:
  target = Path(scratch)
  (target / 'ApiCost.js').write_bytes((plugin / 'ApiCost.js').read_bytes())
  (target / 'RemoteUsage.js').write_bytes((plugin / 'RemoteUsage.js').read_bytes())
  for name, values in replacements.items():
    source = (fixtures / (name + '.qml.in')).read_text()
    for key, value in values.items():
      source = source.replace(key, value)
    (target / ('tst_' + name + '.qml')).write_text(source)
  result = subprocess.run([runner, '-platform', 'offscreen', '-input', str(target)], env=env)
  sys.exit(result.returncode)
