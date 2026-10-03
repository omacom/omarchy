import http.client
import json
import os
from pathlib import Path
import tempfile
import threading
import unittest
from unittest.mock import patch

from app import Server, Wizard


class WizardTests(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory()
    self.addCleanup(self.temp.cleanup)
    self.root = Path(self.temp.name)
    self.env = patch.dict(os.environ, {'XDG_DATA_HOME': str(self.root / 'data')})
    self.env.start()
    self.addCleanup(self.env.stop)
    self.wizard = Wizard(self.root / 'state')

  def test_progress_survives_restart(self):
    state = {'step':'email', 'tasks':['email','photos'], 'completed':['welcome','icloud'], 'finished':False}
    self.wizard.save(state)
    self.assertEqual(Wizard(self.root / 'state').state, state)
    self.assertEqual((self.root / 'state/state.json').stat().st_mode & 0o777, 0o600)

  def test_rejects_invalid_state_without_changing_saved_progress(self):
    original = dict(self.wizard.state)
    for change in ({'step':'bad'}, {'tasks':['unknown']}, {'finished':'yes'}, {'completed':['welcome','welcome']}, {'tasks':[{}]}):
      with self.subTest(change=change), self.assertRaises(ValueError):
        self.wizard.save({**original, **change})
      self.assertEqual(self.wizard.state, original)

  def test_corrupt_progress_is_reported(self):
    self.wizard.state_dir.mkdir()
    (self.wizard.state_dir / 'state.json').write_text('{')
    restored = Wizard(self.wizard.state_dir)
    self.assertIsNotNone(restored.warning)
    self.assertEqual(restored.state['step'], 'welcome')

  @patch('app.shutil.which', return_value='/usr/bin/fake')
  def test_shortcuts_are_idempotent_and_removable(self, _):
    self.wizard.action('install','photos')
    path = self.wizard.shortcut_path('photos')
    text = path.read_text()
    self.assertIn('https://www.icloud.com/photos/', text)
    self.wizard.action('install','photos')
    self.assertEqual(path.read_text(), text)
    self.wizard.action('remove','photos')
    self.assertFalse(path.exists())
    self.wizard.action('remove','photos')

  def test_user_modified_shortcut_is_preserved(self):
    self.wizard.install_shortcut('drive')
    path = self.wizard.shortcut_path('drive')
    path.write_text('user owned')
    for action in (self.wizard.install_shortcut, self.wizard.remove_shortcut):
      with self.assertRaises(ValueError):
        action('drive')
      self.assertEqual(path.read_text(),'user owned')

  def test_shortcut_symlink_is_preserved(self):
    self.wizard.applications.mkdir(parents=True)
    target = self.root / 'keep'
    target.write_text('keep me')
    self.wizard.shortcut_path('mail').symlink_to(target)
    with self.assertRaises(ValueError):
      self.wizard.remove_shortcut('mail')
    self.assertEqual(target.read_text(),'keep me')

  def test_action_validation(self):
    with self.assertRaises(ValueError):
      self.wizard.action('unknown')
    with self.assertRaises(ValueError):
      self.wizard.action('open','unknown')

  @patch('app.Wizard.run')
  def test_settings_always_opens_menu(self, run):
    self.wizard.action('settings')
    run.assert_called_once_with(['omarchy-menu', 'summon', 'setup'])

  @patch('app.Wizard.run')
  def test_email_client_action(self, run):
    self.wizard.action('email-client')
    run.assert_called_once_with(['thunderbird'])



class ServerTests(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory()
    self.server = Server(('127.0.0.1',0),Wizard(Path(self.temp.name)))
    self.thread = threading.Thread(target=self.server.serve_forever,daemon=True)
    self.thread.start()

  def tearDown(self):
    self.server.shutdown()
    self.server.server_close()
    self.thread.join()
    self.temp.cleanup()

  def request(self, method, path, data=None, headers=None):
    connection = http.client.HTTPConnection('127.0.0.1',self.server.server_port)
    defaults = {'X-Wizard-Token':self.server.token,'Origin':self.server.origin,'Content-Type':'application/json'}
    defaults.update(headers or {})
    connection.request(method,path,None if data is None else json.dumps(data),defaults)
    response = connection.getresponse()
    body = response.read()
    result = response.status, dict(response.getheaders()), body
    connection.close()
    return result

  def test_static_and_state(self):
    status, headers, body = self.request('GET','/')
    self.assertEqual(status,200)
    self.assertIn('frame-ancestors',headers['Content-Security-Policy'])
    self.assertNotIn(self.server.token.encode(),body)
    self.assertEqual(self.request('GET','/api/state')[0],200)
    self.assertEqual(self.request('GET','/not-a-file')[0],404)

  def test_state_requires_session(self):
    self.assertEqual(self.request('GET','/api/state',headers={'X-Wizard-Token':''})[0],403)

  def test_saves_valid_progress(self):
    progress = {**self.server.wizard.state, 'step':'email','tasks':['email']}
    self.assertEqual(self.request('POST','/api/state',progress)[0],200)
    self.assertEqual(json.loads(self.request('GET','/api/state')[2])['state'],progress)

  def test_untrusted_origin_and_host_are_rejected(self):
    for headers in ({'Origin':'https://example.com'},{'Host':'example.com'}):
      self.assertEqual(self.request('POST','/api/state',self.server.wizard.state,headers)[0],403)

  def test_invalid_actions_return_errors(self):
    for data in ({'action':'unknown'}, {'action':[]}, {'action':'open','service':[]}):
      self.assertEqual(self.request('POST','/api/action',data)[0],400)
    self.assertEqual(self.request('POST','/api/state',{'step':'missing-fields'})[0],400)


if __name__ == '__main__':
  unittest.main()
