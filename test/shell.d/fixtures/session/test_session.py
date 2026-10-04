import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("session", Path(os.environ["ROOT"]) / "default/session/session.py")
session = importlib.util.module_from_spec(spec)
spec.loader.exec_module(session)


class SessionTest(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory()
    self.addCleanup(self.temp.cleanup)
    self.root = Path(self.temp.name)
    session.STATE = self.root / "state"
    session.RUNTIME = self.root / "runtime"
    session.STATE.mkdir()
    session.RUNTIME.mkdir()
    self.data = self.root / "data"
    self.apps = self.data / "applications"
    self.apps.mkdir(parents=True)
    self.env = patch.dict(os.environ, {"XDG_DATA_HOME": str(self.data), "XDG_DATA_DIRS": str(self.root / 'system')})
    self.env.start()
    self.addCleanup(self.env.stop)
    (self.apps / "example.desktop").write_text('[Desktop Entry]\nType=Application\nExec=example %U\nStartupWMClass=Example\n')
    self.window = {"initialClass": "Example", "class": "Example", "workspace": {"id": 3}, "title": "private document", "pid": 42, "address": "0xabc"}

  def saved(self):
    return json.loads((session.STATE / 'last.json').read_text())

  def save(self, windows=None, automatic=False):
    with patch.object(session, 'clients', return_value=[self.window] if windows is None else windows):
      session.save(automatic)

  def test_snapshot_is_minimal_private_and_complete(self):
    self.save()
    self.assertEqual(self.saved()['clients'], [{'class': 'Example', 'desktop_id': 'example.desktop', 'workspace': 3}])
    self.assertEqual((session.STATE / 'last.json').stat().st_mode & 0o777, 0o600)
    self.assertEqual(list(session.STATE.iterdir()), [session.STATE / 'last.json'])

  def test_empty_automatic_snapshot_preserves_last_session(self):
    self.save()
    self.save([], automatic=True)
    self.assertEqual(len(self.saved()['clients']), 1)
    self.save([])
    self.assertEqual(self.saved()['clients'], [])

  def test_shutdown_freeze_blocks_late_partial_saves(self):
    self.save()
    (session.RUNTIME / 'exiting').touch()
    self.window['workspace']['id'] = 5
    self.save(automatic=True)
    self.assertEqual(self.saved()['clients'][0]['workspace'], 3)

  def test_failing_compositor_preserves_snapshot(self):
    self.save()
    original = (session.STATE / 'last.json').read_bytes()
    with patch.object(session, 'clients', side_effect=ValueError('offline')):
      with self.assertRaises(ValueError):
        session.save()
    self.assertEqual(original, (session.STATE / 'last.json').read_bytes())

  def test_class_matching_is_literal_and_supports_app_id(self):
    (self.apps / 'org.example.App.desktop').write_text('[Desktop Entry]\nType=Application\nExec=example\n')
    self.assertEqual(session.desktop_entries()['org.example.App'], 'org.example.App.desktop')
    self.window['initialClass'] = '.*'
    self.save()
    self.assertEqual(self.saved()['clients'], [])

  def test_user_hidden_entry_masks_system_application(self):
    system = self.root / 'system/applications'
    system.mkdir(parents=True)
    (system / 'example.desktop').write_text((self.apps / 'example.desktop').read_text())
    (self.apps / 'example.desktop').write_text('[Desktop Entry]\nHidden=true\n')
    self.assertNotIn('Example', session.desktop_entries())

  def test_restore_launches_once_and_moves_using_lua(self):
    self.save([self.window, self.window])
    with patch.object(session, 'clients', side_effect=[[], [self.window]]), patch.object(session, 'command') as command, patch.object(session.subprocess, 'run') as launch:
      session.restore()
    self.assertEqual(launch.call_args.args[0], ['uwsm-app', '--', 'gtk-launch', 'example.desktop'])
    self.assertIn('workspace = "3"', command.call_args.args[2])
    self.assertEqual(command.call_count, 1)
    self.assertEqual(launch.call_count, 1)

  def test_existing_application_is_untouched(self):
    self.save()
    with patch.object(session, 'clients', return_value=[self.window]), patch.object(session, 'command') as command:
      session.restore()
    command.assert_not_called()

  def test_removed_application_is_skipped(self):
    self.save()
    (self.apps / 'example.desktop').unlink()
    with patch.object(session, 'clients', return_value=[]), patch.object(session, 'command') as command:
      session.restore()
    command.assert_not_called()

  def test_corrupt_snapshot_never_launches(self):
    (session.STATE / 'last.json').write_text('{"schema":2,"clients":[{"workspace":"1;evil"}]}')
    with self.assertRaises(ValueError), patch.object(session, 'command') as command:
      session.restore()
    command.assert_not_called()

  def test_shell_and_special_workspaces_are_not_saved(self):
    windows = [dict(self.window, initialClass='org.quickshell'), dict(self.window, workspace={'id': -99})]
    self.save(windows)
    self.assertEqual(self.saved()['clients'], [])

  def test_service_restart_does_not_restore_twice(self):
    with patch.object(session, 'restore') as restore:
      session.startup('first-login')
      session.startup('first-login')
      self.assertEqual(restore.call_count, 1)
      (session.RUNTIME / 'exiting').touch()
      session.startup('second-login')
      self.assertEqual(restore.call_count, 2)
      self.assertFalse((session.RUNTIME / 'exiting').exists())

  def test_shutdown_stops_restore_before_launching_more_apps(self):
    self.save()
    (session.RUNTIME / 'exiting').touch()
    with patch.object(session, 'clients', return_value=[]), patch.object(session.subprocess, 'run') as launch:
      session.restore()
    launch.assert_not_called()


unittest.main()
