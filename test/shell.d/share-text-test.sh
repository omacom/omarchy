#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command jq

python3 - <<'PY'
import json
import os
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import time
import unittest

root = Path(os.environ['ROOT'])


class ShareTextTests(unittest.TestCase):
  def setUp(self):
    self.scratch = tempfile.TemporaryDirectory()
    self.addCleanup(self.scratch.cleanup)
    self.directory = Path(self.scratch.name)
    self.calls = self.directory / 'calls.json'
    self.localsend_calls = self.directory / 'localsend.json'
    self.completed = self.directory / 'completed'
    self.environment = dict(os.environ, OMARCHY_PATH=str(self.directory),
                            HOME=str(self.directory), SHARE_TEST_CALLS=str(self.calls),
                            SHARE_TEST_NOTIFICATION=str(self.directory / 'notification'),
                            SHARE_TEST_LOCALSEND_CALLS=str(self.localsend_calls),
                            SHARE_TEST_COMPLETED=str(self.completed))
    self.environment['PATH'] = str(self.directory) + os.pathsep + os.environ['PATH']
    self.stub('systemd-run', f'''#!{sys.executable}
import json, os, subprocess, sys
from pathlib import Path
Path(os.environ['SHARE_TEST_CALLS']).write_text(json.dumps(sys.argv[1:]))
status = int(os.environ.get('SHARE_TEST_LAUNCH_STATUS', '0'))
if status:
  sys.exit(status)
# The service runs independently; successful scheduling does not mean that
# its command succeeds. A worker records completion for the test to await.
worker = """
import os, subprocess, sys
from pathlib import Path
result = subprocess.run(sys.argv[1:])
completed = Path(os.environ['SHARE_TEST_COMPLETED'])
pending = completed.with_suffix('.tmp')
pending.write_text(str(result.returncode))
pending.replace(completed)
"""
arguments = sys.argv[1:]
while arguments[0].startswith('--'):
  arguments = arguments[1:]
subprocess.Popen([sys.executable, '-c', worker, *arguments],
                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
''')
    self.stub('localsend', f"""#!{sys.executable}
import json, os, sys
from pathlib import Path
Path(os.environ['SHARE_TEST_LOCALSEND_CALLS']).write_text(json.dumps(sys.argv[1:]))
if len(sys.argv) == 4 and sys.argv[1:3] == ['--headless', 'send'] and Path(sys.argv[3]).is_file():
  p = Path(sys.argv[3])
  (Path(os.environ['HOME']) / 'shared-file.json').write_text(json.dumps({{
    'text': p.read_text(), 'file_mode': p.stat().st_mode & 0o777,
    'directory_mode': p.parent.stat().st_mode & 0o777}}))
sys.exit(int(os.environ.get('SHARE_TEST_LOCALSEND_STATUS', '0')))
""")
    composer = self.directory / 'default/localsend/share-text.py'
    composer.parent.mkdir(parents=True)
    composer.write_text("import os, sys\nprint(os.environ.get('SHARE_TEST_MESSAGE', ''), end='')\nsys.exit(int(os.environ.get('SHARE_TEST_COMPOSER_STATUS', '0')))\n")
    # A PATH-selected Python must never replace Arch's GI-enabled interpreter.
    self.stub('python3', '#!/bin/bash\nexit 99\n')
    self.stub('omarchy-notification-send', '#!/bin/bash\nprintf "%s\\n" "$@" > "$SHARE_TEST_NOTIFICATION"\n')
    self.stub('omarchy-i18n', f'#!/bin/bash\nexec "{root}/bin/omarchy-i18n" "$@"\n')
    i18n = self.directory / 'default/i18n'
    (i18n / 'en').mkdir(parents=True)
    for path in ('en/cli.json', 'plural.jq', 'locales.json'):
      (i18n / path).write_bytes((root / 'default/i18n' / path).read_bytes())
    self.stub('wl-paste', f'''#!{sys.executable}
import os, sys
sys.stdout.write('x' * int(os.environ.get('SHARE_TEST_CLIPBOARD_SIZE', '0')) + os.environ.get('SHARE_TEST_CLIPBOARD', ''))
sys.exit(int(os.environ.get('SHARE_TEST_CLIPBOARD_STATUS', '0')))
''')
    self.stub('mktemp', '#!/bin/bash\nexit 99\n')
    self.stub('omarchy-file-select', f'''#!{sys.executable}
import os, sys
sys.stdout.write(os.environ.get('SHARE_TEST_PICKED', ''))
sys.exit(int(os.environ.get('SHARE_TEST_PICKER_STATUS', '0')))
''')

  def stub(self, name, text):
    path = self.directory / name
    path.write_text(text)
    path.chmod(0o755)

  def share(self, *arguments):
    self.completed.unlink(missing_ok=True)
    result = subprocess.run(['bash', str(root / 'bin/omarchy-menu-share'), *arguments],
                            env=self.environment, cwd=self.directory, capture_output=True, text=True)
    if result.returncode == 0 and self.calls.exists():
      deadline = time.monotonic() + 5
      while not self.completed.exists() and time.monotonic() < deadline:
        time.sleep(0.01)
      self.assertTrue(self.completed.exists(), 'Detached command did not complete')
    return result

  def test_composed_message_is_native_text_and_literal(self):
    message = 'café 🌎\n$(touch unwanted); "quoted" ${HOME}'
    self.environment['SHARE_TEST_MESSAGE'] = message
    result = self.share('text')
    self.assertEqual(result.returncode, 0, result.stderr)
    self.assertIn('--expand-environment=no', json.loads(self.calls.read_text()))
    self.assertEqual(json.loads(self.localsend_calls.read_text()), ['--text', ' ' + message])
    self.assertFalse((self.directory / 'unwanted').exists())

  def test_cancel_and_blank_do_not_launch(self):
    for message, status in [('', '1'), ('', '0'), (' \t\n', '0')]:
      self.environment.update(SHARE_TEST_MESSAGE=message, SHARE_TEST_COMPOSER_STATUS=status)
      self.assertEqual(self.share('text').returncode, 0)
      self.assertFalse(self.calls.exists())

  def test_composer_error_does_not_launch(self):
    self.environment.update(SHARE_TEST_MESSAGE='partial', SHARE_TEST_COMPOSER_STATUS='2')
    self.assertNotEqual(self.share('text').returncode, 0)
    self.assertFalse(self.calls.exists())
    self.assertIn('The text composer did not open', (self.directory / 'notification').read_text())

  def test_flag_like_direct_text_is_not_an_option(self):
    self.assertEqual(self.share('text', '--share').returncode, 0)
    self.assertEqual(json.loads(self.localsend_calls.read_text()), ['--text', ' --share'])

  def test_service_description_does_not_disclose_direct_or_composed_text(self):
    direct = 'synthetic Wi-Fi password: café\n${HOME}'
    composed = 'synthetic OTP: 123456\n$(touch unwanted)'
    self.environment['SHARE_TEST_MESSAGE'] = composed
    observed_descriptions = []
    for arguments, message in [(('text', direct), direct), (('text',), composed)]:
      with self.subTest(arguments=arguments):
        result = self.share(*arguments)
        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads(self.calls.read_text())
        descriptions = [arg.split('=', 1)[1] for arg in args[:args.index('/bin/bash')]
                        if arg.startswith('--description=')]
        self.assertEqual(len(descriptions), 1, 'systemd would log the full command without a description')
        self.assertTrue(descriptions[0].strip())
        self.assertNotIn(message, descriptions[0])
        self.assertEqual(json.loads(self.localsend_calls.read_text()), ['--text', ' ' + message])
        observed_descriptions.append(descriptions[0])
    self.assertEqual(observed_descriptions[0], observed_descriptions[1],
                     'Service description must not vary with message contents')

  def test_launch_failure_propagates(self):
    self.environment['SHARE_TEST_LAUNCH_STATUS'] = '1'
    self.assertNotEqual(self.share('text', 'hello').returncode, 0)
    self.assertIn('LocalSend did not open', (self.directory / 'notification').read_text())

  def test_detached_localsend_failure_notifies_after_successful_scheduling(self):
    self.environment['SHARE_TEST_LOCALSEND_STATUS'] = '1'
    self.assertEqual(self.share('text', 'hello').returncode, 0)
    self.assertTrue(self.localsend_calls.exists())
    self.assertTrue((self.directory / 'notification').exists(),
                    'LocalSend failure after service scheduling was silent')
    self.assertIn('LocalSend exited with an error', (self.directory / 'notification').read_text())
    self.assertEqual(self.completed.read_text(), '1')

  def test_successful_detached_localsend_does_not_notify(self):
    self.assertEqual(self.share('text', 'hello').returncode, 0)
    self.assertFalse((self.directory / 'notification').exists())
    self.assertEqual(self.completed.read_text(), '0')

  def test_existing_file_and_folder_paths_remain_files(self):
    for mode in ('file', 'folder'):
      self.assertEqual(self.share(mode, '/a path').returncode, 0)
      self.assertEqual(json.loads(self.localsend_calls.read_text()), ['--headless', 'send', '/a path'])

  def test_clipboard_is_native_literal_text_without_temporary_file(self):
    message = '--share café\n$(touch unwanted); "quoted" ${HOME}'
    self.environment['SHARE_TEST_CLIPBOARD'] = message + '\n\n'
    result = self.share('clipboard')
    self.assertEqual(result.returncode, 0, result.stderr)
    self.assertEqual(json.loads(self.localsend_calls.read_text()), ['--text', ' ' + message])
    arguments = json.loads(self.calls.read_text())
    self.assertIn('--expand-environment=no', arguments)
    self.assertIn('--description=Share text with LocalSend', arguments)
    self.assertFalse((self.directory / 'unwanted').exists())
    self.assertFalse((self.directory / 'notification').exists())

  def test_clipboard_read_failure_does_not_share_partial_text(self):
    self.environment.update(SHARE_TEST_CLIPBOARD='partial', SHARE_TEST_CLIPBOARD_STATUS='1')
    self.assertNotEqual(self.share('clipboard').returncode, 0)
    self.assertFalse(self.calls.exists())
    self.assertIn('Could not read the clipboard', (self.directory / 'notification').read_text())

  def test_clipboard_notification_uses_language_catalog(self):
    i18n = self.directory / 'default/i18n'
    (i18n / 'da').mkdir()
    (i18n / 'da/cli.json').write_text(json.dumps({'share.clipboardReadFailed': 'Synthetic translated clipboard failure'}))
    language = self.directory / 'language'
    language.write_text('da\n')
    self.environment.update(OMARCHY_LANGUAGE_FILE=str(language), SHARE_TEST_CLIPBOARD_STATUS='1')
    self.assertNotEqual(self.share('clipboard').returncode, 0)
    self.assertIn('Synthetic translated clipboard failure', (self.directory / 'notification').read_text())

  def allow_private_temp(self):
    self.stub('mktemp', f'''#!/bin/bash
path=$(/usr/bin/mktemp "$@") || exit
printf '%s' "$path" > '{self.directory}/temporary-path'
printf '%s\\n' "$path"
''')

  def assert_file_fallback(self, message, *arguments):
    self.allow_private_temp()
    result = self.share(*arguments)
    self.assertEqual(result.returncode, 0, result.stderr)
    args = json.loads(self.localsend_calls.read_text())
    self.assertEqual(args[:2], ['--headless', 'send'])
    staged = json.loads((self.directory / 'shared-file.json').read_text())
    self.assertEqual(staged, {'text': message, 'file_mode': 0o600, 'directory_mode': 0o700})
    self.assertFalse(Path(args[2]).exists(), 'Text file survived service completion')
    self.assertFalse(Path(args[2]).parent.exists(), 'Private directory survived service completion')
    service = json.loads(self.calls.read_text())
    self.assertIn('--description=Share text with LocalSend', service)
    self.assertNotIn(message, service)

  def test_oversized_clipboard_uses_private_file_and_cleans_up(self):
    message = 'x' * (140 * 1024) + '\ncafé ${HOME} $(touch unwanted)'
    self.environment['SHARE_TEST_CLIPBOARD_SIZE'] = str(140 * 1024)
    self.environment['SHARE_TEST_CLIPBOARD'] = '\ncafé ${HOME} $(touch unwanted)'
    self.assert_file_fallback(message, 'clipboard')
    self.assertFalse((self.directory / 'unwanted').exists())
    self.assertFalse((self.directory / 'notification').exists())

  def test_fallback_threshold_counts_utf8_bytes(self):
    self.assert_file_fallback('é' * (32 * 1024), 'text', 'é' * (32 * 1024))

  def test_ordinary_text_below_threshold_stays_native(self):
    message = 'x' * (64 * 1024 - 1)
    self.assertEqual(self.share('text', message).returncode, 0)
    self.assertEqual(json.loads(self.localsend_calls.read_text()), ['--text', ' ' + message])

  def test_oversized_composer_uses_file_fallback(self):
    message = 'x' * (64 * 1024)
    self.environment['SHARE_TEST_MESSAGE'] = message
    self.assert_file_fallback(message, 'text')

  def test_file_fallback_launch_failure_cleans_up_and_notifies(self):
    self.allow_private_temp()
    self.environment.update(SHARE_TEST_CLIPBOARD_SIZE=str(140 * 1024), SHARE_TEST_LAUNCH_STATUS='1')
    self.assertNotEqual(self.share('clipboard').returncode, 0)
    self.assertTrue((self.directory / 'temporary-path').exists(), 'Fallback did not prepare a file')
    self.assertFalse(Path((self.directory / 'temporary-path').read_text()).exists())
    self.assertIn('LocalSend did not open', (self.directory / 'notification').read_text())

  def test_file_fallback_child_failure_cleans_up_and_notifies(self):
    message = 'x' * (64 * 1024)
    self.environment.update(SHARE_TEST_MESSAGE=message, SHARE_TEST_LOCALSEND_STATUS='7')
    self.assert_file_fallback(message, 'text')
    self.assertEqual(self.completed.read_text(), '7')
    self.assertIn('LocalSend exited with an error', (self.directory / 'notification').read_text())

  def test_file_fallback_temp_creation_failure_notifies(self):
    self.environment['SHARE_TEST_CLIPBOARD_SIZE'] = str(140 * 1024)
    self.assertNotEqual(self.share('clipboard').returncode, 0)
    self.assertFalse(self.calls.exists())
    self.assertIn('Could not share text', (self.directory / 'notification').read_text())

  def test_empty_clipboard_retains_native_text_route(self):
    self.assertEqual(self.share('clipboard').returncode, 0)
    self.assertEqual(json.loads(self.localsend_calls.read_text()), ['--text', ' '])

  def test_clipboard_launch_failure_notifies(self):
    self.environment.update(SHARE_TEST_CLIPBOARD='hello', SHARE_TEST_LAUNCH_STATUS='1')
    self.assertNotEqual(self.share('clipboard').returncode, 0)
    self.assertIn('LocalSend did not open', (self.directory / 'notification').read_text())

  def test_clipboard_detached_failure_notifies(self):
    self.environment.update(SHARE_TEST_CLIPBOARD='hello', SHARE_TEST_LOCALSEND_STATUS='7')
    self.assertEqual(self.share('clipboard').returncode, 0)
    self.assertIn('LocalSend exited with an error', (self.directory / 'notification').read_text())
    self.assertEqual(self.completed.read_text(), '7')

  def test_file_and_folder_launch_failures_notify(self):
    self.environment['SHARE_TEST_LAUNCH_STATUS'] = '1'
    for mode in ('file', 'folder'):
      with self.subTest(mode=mode):
        self.assertNotEqual(self.share(mode, '/a path').returncode, 0)
        self.assertIn('LocalSend failed to start', (self.directory / 'notification').read_text())

  def test_selected_files_and_folder_remain_headless_shares(self):
    for mode, picked in [('file', '/a path\n/another file'), ('folder', '/a directory')]:
      with self.subTest(mode=mode):
        self.environment['SHARE_TEST_PICKED'] = picked
        self.assertEqual(self.share(mode).returncode, 0)
        self.assertEqual(json.loads(self.localsend_calls.read_text()), ['--headless', 'send', *picked.splitlines()])

  def test_picker_cancel_does_not_launch(self):
    self.environment['SHARE_TEST_PICKER_STATUS'] = '1'
    self.assertEqual(self.share('file').returncode, 0)
    self.assertFalse(self.calls.exists())

  def test_picker_failure_notifies(self):
    self.environment['SHARE_TEST_PICKER_STATUS'] = '2'
    self.assertNotEqual(self.share('file').returncode, 0)
    self.assertFalse(self.calls.exists())
    self.assertIn('The file chooser did not open', (self.directory / 'notification').read_text())

  def test_real_composer_imports_matching_toolkits(self):
    try:
      import gi
      gi.require_version('Gtk', '3.0')
      gi.require_version('Gdk', '3.0')
    except (ImportError, ValueError):
      self.skipTest('GTK/GDK 3 introspection unavailable')
    probe = '''
import runpy, sys
module = runpy.run_path(sys.argv[1])
class ImportsVerified(Exception): pass
def trace(frame, event, arg):
  if frame.f_code.co_name == 'compose_text' and event == 'line' and 'Gtk' in frame.f_locals:
    assert frame.f_locals['Gtk']._version == '3.0'
    assert frame.f_locals['Gdk']._version == '3.0'
    raise ImportsVerified()
  return trace
sys.settrace(trace)
try:
  module['compose_text']()
except ImportsVerified:
  sys.settrace(None)
  print('GTK/GDK 3 imports verified')
'''
    result = subprocess.run([sys.executable, '-c', probe, str(root / 'default/localsend/share-text.py')],
                            text=True, capture_output=True)
    self.assertEqual(result.returncode, 0, result.stderr)
    self.assertIn('GTK/GDK 3 imports verified', result.stdout)


unittest.main()
PY

pass "text sharing handles cancellation, errors, literal messages, and toolkit versions"

run_node_test <<'JS'
const fs = require('fs')
const model = requireFromRoot('shell/plugins/menu/MenuModel.js')
const entries = model.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const text = entries.find(entry => entry.id === 'trigger.share.text')
assert(text && text.parent === 'trigger.share' && text.action === 'omarchy-menu-share text', 'Share menu routes Text to text sharing')
JS
