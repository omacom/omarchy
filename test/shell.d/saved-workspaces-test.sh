#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
python3 - "$ROOT" <<'PY'
import copy, importlib.util, json, os, stat, sys, tempfile, struct
from pathlib import Path
from unittest.mock import patch
spec = importlib.util.spec_from_file_location('saved_workspaces', Path(sys.argv[1]) / 'shell/plugins/saved-workspaces/backend.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
def check(value, description):
  assert value, description
  print('ok - ' + description)

# Gaps belong to the leaves; split positions are the midpoints between them.
windows = [
  {'key': 'left', 'at': [12, 36], 'size': [901, 912]},
  {'key': 'top', 'at': [927, 36], 'size': [597, 312]},
  {'key': 'bottom', 'at': [927, 362], 'size': [597, 586]},
]
tree = m.split_tree(windows, [0, 24, 1536, 936])
check(tree['axis'] == 0 and tree['first'] == {'leaf': 'left'}, 'saved tiling preserves a full-height left pane')
check(abs(tree['ratio'] * 1536 / 2 - 920) < .01, 'unequal tiling splits retain their exact boundary')
right = tree['second']
check(right['axis'] == 1 and right['first'] == {'leaf': 'top'} and right['second'] == {'leaf': 'bottom'}, 'nested horizontal panes preserve their order')
check(abs(24 + right['ratio'] * 936 / 2 - 355) < .01, 'nested tiling retains its unequal vertical boundary')
try:
  m.split_tree([{'key': 'a', 'at': [0, 0], 'size': [100, 100]}, {'key': 'b', 'at': [10, 10], 'size': [100, 100]}], [0, 0, 200, 200])
except m.WorkspaceError:
  print('ok - overlapping grouped tiles fail clearly instead of saving an incorrect layout')
else:
  raise AssertionError('overlapping tiles accepted')

# Session replay retains current navigations, tab order and each window's own tabs.
def record(kind, payload):
  return struct.pack('<H',len(payload)+1)+bytes([kind])+payload
def pair(kind,a,b):
  return record(kind,struct.pack('<ii',a,b))
def navigation(tab,index,url,title):
  u=url.encode();t=title.encode('utf-16-le')
  payload=struct.pack('<iii',tab,index,len(u))+u+b'\0'*((-len(u))%4)+struct.pack('<i',len(t)//2)+t
  return record(6,struct.pack('<i',len(payload))+payload)
raw=b'SNSS'+struct.pack('<I',3)+pair(0,1,10)+pair(0,1,11)+pair(0,2,20)+pair(2,10,1)+pair(2,11,0)+pair(8,1,1)+navigation(10,0,'https://example.org/old','Old')+navigation(10,1,'https://example.org/current','Current')+pair(7,10,1)+navigation(11,0,'https://example.org/first','First')+navigation(20,0,'https://example.org/other','Other')
records=m.chromium_sessions(raw)
check(records[0]['urls']==['https://example.org/first','https://example.org/current'] and records[0]['title']=='Current', 'browser tabs keep their order and current navigation')
check(records[1]['urls']==['https://example.org/other'], 'browser windows retain separate tab sets')
closed=m.chromium_sessions(raw+record(16,struct.pack('<i',11))+record(17,struct.pack('<i',2)))
check(len(closed)==1 and closed[0]['urls']==['https://example.org/current'], 'closed tabs and windows are excluded from saved browser state')
check(m.chromium_sessions(b'invalid')==[] and m.chromium_sessions(raw+b'\xff')==records, 'truncated or invalid session records are handled safely')
args=m.state_command({'appState':{'kind':'browser','urls':['https://example.org/first','https://example.org/current']}},['chromium','--new-window','about:blank'])
check(args==['chromium','--new-window','https://example.org/first','https://example.org/current'], 'opening browser state replaces launch URLs with saved tabs')
uri='spotify:playlist:'+'a'*22
check(m.state_command({'appState':{'kind':'spotify','uri':uri}},['spotify'])==['spotify',uri], 'Spotify reopens the saved playlist link')

# Chromium's launch wrapper collapses /proc/cmdline into a single display title.
argv = m.recover_argv(b'/usr/lib/chromium/chromium --class=SavedBrowser --user-data-dir=/tmp/browser-demo --new-window about:blank\0', '/usr/lib/chromium/chromium')
check('--class=SavedBrowser' in argv and '--user-data-dir=/tmp/browser-demo' in argv and argv[-1] == 'about:blank', 'browser process titles retain their window class and profile when reopened')
check(m.recover_argv(b'/usr/bin/alacritty\0--title\0A title with spaces\0', '/usr/bin/alacritty')[-1] == 'A title with spaces', 'normal argument vectors preserve spaces inside an argument')

original_run = m.run
for response, expected in [({'bool': True}, True), ({'bool': False}, False), ({'int': 1}, True), ({'int': 0}, False)]:
  m.run = lambda *args, response=response: json.dumps(response)
  check(m.boolean_option('dwindle:preserve_split') is expected, 'tiling options accept compositor boolean and integer formats: ' + str(response))
m.run = original_run

clients = [{'workspace': {'id': 3}}, {'workspace': {'id': 4}}, {'workspace': {'id': 6}}]
check(m.restore_destination(2, clients) == 2, 'an empty current workspace is used directly')
check(m.restore_destination(3, clients) == 5, 'occupied workspaces are skipped to the next empty workspace')
check(m.restore_destination(3, clients + [{'workspace': {'id': -99}, 'tags': ['omarchy-minimized-from-5']}]) == 7, 'minimized apps reserve their original workspace')
check(m.restore_destination(3, [{'workspace': {'id': 3}, 'mapped': False}]) == 3, 'unmapped windows do not occupy a workspace')

check(m.restore_destination(10, [{'workspace': {'id': 10}}]) == 1, 'the last workspace wraps within the same monitor block')
check(m.restore_destination(20, [{'workspace': {'id': 20}}]) == 11, 'the second monitor wraps inside its own block')
try:
  m.restore_destination(10, [{'workspace': {'id': i}} for i in range(1, 11)])
except m.WorkspaceError:
  print('ok - a full monitor block never steals another monitor workspace')
else:
  raise AssertionError('a full block crossed a monitor boundary')

# A class match alone never authorizes moving an unrelated window.
from types import SimpleNamespace
from unittest.mock import MagicMock
unrelated = {'address': '0xother', 'class': 'Terminal', 'workspace': {'id': 2}, 'tags': []}
launched = {'address': '0xours', 'class': 'Terminal', 'workspace': {'id': 8}, 'tags': ['omarchy-scene-proof*']}
with patch.object(m.uuid, 'uuid4', return_value=SimpleNamespace(hex='proof')), patch.object(m, 'query', side_effect=[[], [unrelated], [unrelated, launched]]), patch.object(m, 'execute') as launch, patch.object(m, 'dispatch') as dispatch, patch.object(m.socket, 'socket', return_value=MagicMock()):
  check(m.launch_window({'argv': ['/bin/true'], 'class': 'Terminal'}, set(), 8)['address'] == '0xours', 'only the per-launch tagged window is claimed, even if another app window appears first')
  dispatch.assert_called_once_with('window.tag', {'window': 'address:0xours', 'tag': '-omarchy-scene-proof'})

browser_other = {'address': '0xother', 'class': 'chromium', 'title': 'Unrelated browser', 'tags': []}
browser_ours = {'address': '0xours', 'class': 'chromium', 'title': 'Focused work', 'tags': []}
with patch.object(m, 'query', side_effect=[[], [browser_other], [browser_other, browser_ours]]), patch.object(m, 'execute') as launch, patch.object(m.socket, 'socket', return_value=MagicMock()):
  check(m.launch_window({'argv': ['chromium', '--new-window', 'about:blank'], 'class': 'chromium', 'sceneName': 'Focused work'}, set(), 8)['address'] == '0xours', 'single-instance browsers match the launch-specific window name instead of their shared process/class')
  check('--window-name=Focused work' in launch.call_args.args[0], 'the named browser window is explicitly requested by this launch')

name = b'Focused work'
user_title = struct.pack('<ii', 1, len(name)) + name + b'\0' * ((-len(name)) % 4)
named = m.chromium_sessions(raw + record(31, struct.pack('<i', len(user_title)) + user_title))
check(named[0]['title'] == 'Focused work' and named[0]['urls'] == records[0]['urls'], 'named browser windows retain their own current tabs when a scene is updated')

for ending in [' - Chromium', ' - Google Chrome', ' - Brave']:
  title = 'Focused work' + ending
  cache = {'/unused/Default/Sessions': [{'title': title, 'urls': ['https://example.org/exact']}, {'title': 'Focused work', 'urls': ['https://example.org/other']}]}
  state = m.capture_app_state({'title': title, 'class': 'chromium', 'pid': 42}, {'argv': ['chromium', '--user-data-dir=/unused']}, cache)
  check(state['urls'] == ['https://example.org/exact'], 'an exact saved window name wins over a browser-suffix fallback: ' + ending)

firefox_other = {'address': '0xother', 'class': 'firefox', 'title': 'Unrelated — Mozilla Firefox', 'tags': []}
firefox_ours = {'address': '0xours', 'class': 'firefox', 'title': 'Focused work — Mozilla Firefox', 'tags': []}
with patch.object(m, 'query', side_effect=[[], [firefox_other], [firefox_other, firefox_ours]]), patch.object(m, 'execute') as launch, patch.object(m.socket, 'socket', return_value=MagicMock()):
  check(m.launch_window({'argv': ['firefox', '--new-window', 'about:blank'], 'class': 'firefox', 'sceneName': 'Focused work'}, set(), 8)['address'] == '0xours', 'forwarded Firefox requests identify their own launch page instead of claiming another window')
  check('file://' in launch.call_args.args[0] and '--new-window' in launch.call_args.args[0], 'forwarded Firefox requests explicitly open their own launch page')

# A missing app must launch only after the current workspace has its saved mode.
events = []
class LaunchObserved(Exception):
  pass
def observe_launch(*args):
  check(events == [(9, 'dwindle', 'right')], 'a saved arrangement launches fresh windows even with its original open, after applying tiling')
  raise LaunchObserved()
responses = {'activeworkspace': {'id': 9, 'monitorID': 0}, 'monitors': [{'id': 0, 'name': 'screen'}], 'clients': [{'address': '0xold', 'pid': 42, 'workspace': {'id': 2}}]}
with patch.object(m, 'dispatch'), patch.object(m, 'query', side_effect=lambda request: responses[request]), patch.object(m, 'layout_metadata', return_value={}), patch.object(m, 'set_mode', side_effect=lambda *args: events.append(args)), patch.object(m, 'launch_window', side_effect=observe_launch):
  try:
    m.restore({'mode': 'dwindle', 'direction': 'right', 'windows': [{'address': '0xold', 'pid': 42}]}, {})
  except LaunchObserved:
    pass
  else:
    raise AssertionError('missing app launch was not reached')

snapshot = {'workspace': 2, 'mode': 'floating', 'windows': [], 'area': [0, 24, 1920, 1056]}
data = {'version': 1, 'items': [], 'active': {}}
p = m.put_profile(data, snapshot, 'Writing')
identity, created = p['id'], p['created']
try:
  m.put_profile(data, snapshot, ' writing ')
except m.WorkspaceError:
  print('ok - saving a duplicate name never silently replaces a workspace')
else:
  raise AssertionError('duplicate name accepted')
updated = m.put_profile(data, {**snapshot, 'mode': 'scrolling'}, identifier=identity)
check(updated['id'] == identity and updated['created'] == created and len(data['items']) == 1 and updated['mode'] == 'scrolling', 'update replaces the snapshot while preserving its name and identity')
check(data['active'] == {'id': identity, 'workspace': 2}, 'the updated save keeps its workspace association')
m.record_opened(data, identity, 4, ['0xcopy1'])
m.record_opened(data, identity, 5, ['0xcopy2'])
check(data['opened']['4']['windows'] == ['0xcopy1'] and data['opened']['5']['windows'] == ['0xcopy2'], 'active copies retain separate workspace associations')

original_profile = copy.deepcopy(updated)
m.rename_profile(data, identity, 'Focused work')
check(updated['name'] == 'Focused work' and updated['id'] == identity and updated['windows'] == original_profile['windows'] and updated['mode'] == original_profile['mode'], 'rename preserves the saved apps, layout and identity')
m.put_profile(data, snapshot, 'Another setup')
try:
  m.rename_profile(data, identity, ' another SETUP ')
except m.WorkspaceError:
  print('ok - rename rejects duplicate names without replacing another save')
else:
  raise AssertionError('duplicate rename accepted')
check(updated['name'] == 'Focused work', 'a rejected rename keeps the previous name')

with tempfile.TemporaryDirectory() as directory:
  old_config, old_state = m.CONFIG, m.STATE
  m.CONFIG = Path(directory) / 'shell.json'
  m.STATE = Path(directory) / 'saved-workspaces'
  m.atomic_json(m.CONFIG, {'bar': {'layout': {'centerBegin': [{'id': 'omarchy.clock'}]}}})
  with patch.object(m.subprocess, 'run'):
    m.configure(True)
    m.configure(True)
    config = json.loads(m.CONFIG.read_text())
    check(m.enabled() and [w['id'] for w in config['bar']['layout']['centerBegin']] == ['omarchy.clock', m.WIDGET], 'enabling the bar control twice preserves existing widgets without duplicating it')
    m.atomic_json(m.STATE / 'workspaces.json', data)
    m.configure(False)
    check(not m.enabled() and json.loads(m.CONFIG.read_text())['bar']['layout']['centerBegin'] == [{'id': 'omarchy.clock'}] and json.loads((m.STATE / 'workspaces.json').read_text()) == data, 'turning the feature off hides its button and preserves saved layouts')
  with patch.object(m.subprocess, 'run'):
    current = json.loads(m.CONFIG.read_text())
    current['bar']['layout']['right'] = [{'id': m.WIDGET}]
    current['savedWorkspaces'] = {'enabled': False}
    m.atomic_json(m.CONFIG, current)
    check(m.enabled(), 'placing the widget through other controls determines the enabled state')
    m.CONFIG.unlink()
    defaults = json.loads((Path(sys.argv[1]) / 'config/omarchy/shell.json').read_text())
    m.configure(True)
    fresh = json.loads(m.CONFIG.read_text())
    check(fresh['bar']['layout']['left'] == defaults['bar']['layout']['left'] and fresh['bar']['layout']['center'] == defaults['bar']['layout']['center'], 'first enable preserves the default menu, workspaces and clock')
  from subprocess import CompletedProcess
  effective = {'version': 1, 'bar': {'layout': {'center': [{'id': 'omarchy.clock'}]}}}
  with patch.object(m.subprocess, 'run', side_effect=[CompletedProcess([], 0, json.dumps(effective), ''), CompletedProcess([], 0, 'ok', '')]) as rpc:
    m.configure(True)
    check(rpc.call_args.args[0][3] == 'putBarWidget', 'a running shell owns configuration changes through its existing placement API')
  m.CONFIG, m.STATE = old_config, old_state

with tempfile.TemporaryDirectory() as directory:
  path = Path(directory) / 'workspaces.json'
  m.atomic_json(path, data)
  loaded = json.loads(path.read_text())
  check(loaded == data and stat.S_IMODE(path.stat().st_mode) == 0o600, 'saved launch commands and workspace data are stored privately and atomically')
  m.atomic_json(path, {'version': 1, 'items': [], 'active': {}})
  check(json.loads(path.read_text())['items'] == [] and len(list(Path(directory).iterdir())) == 1, 'updating saved data leaves no partial files behind')
PY
