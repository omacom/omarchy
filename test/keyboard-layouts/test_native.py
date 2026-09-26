"""Native ownership and first-save regressions; all paths are temporary."""
import base64
import os
from pathlib import Path
import subprocess
import unittest

from backend.catalog import SettingsError
from backend.deferred import LOADER, PROMOTER, render_rows
from backend.session import atomic, encoded
import test_backend


class NativeOwnershipTests(unittest.TestCase):
  def setUp(self):
    test_backend.TransactionTests.setUp(self)

  def test_first_save_needs_no_activation_and_does_not_write_packaged_code(self):
    self.paths.active.unlink()
    self.paths.pending.unlink()
    self.paths.override.chmod(0o444)
    self.paths.promoter.chmod(0o444)
    before = {p: p.read_bytes() for p in (self.paths.override, self.paths.promoter, self.input)}
    state = self.session.status()
    self.assertFalse(self.paths.active.exists())
    self.assertFalse(self.paths.pending.exists())
    self.assertFalse(self.paths.profile.exists())
    self.session.save(['us/', 'pl/', 'de/'], 'both-alt', state['revision'])
    self.assertEqual([row['id'] for row in self.session.status()['layouts']], ['us/', 'pl/', 'de/'])
    self.assertEqual({p: p.read_bytes() for p in before}, before)
    self.assertFalse(self.paths.legacy_loader.exists())

  def test_first_save_failure_restores_absent_files(self):
    self.paths.active.unlink()
    self.paths.pending.unlink()
    state = self.session.status()
    original_reload = self.hypr.reload
    calls = 0
    def fail_once():
      nonlocal calls
      calls += 1
      if calls == 1:
        raise OSError('fixture reload failure')
      original_reload()
    self.hypr.reload = fail_once
    with self.assertRaisesRegex(SettingsError, 'previous setup was restored'):
      self.session.save(['us/', 'pl/', 'de/'], 'both-alt', state['revision'])
    self.assertFalse(self.paths.active.exists())
    self.assertFalse(self.paths.pending.exists())
    self.assertFalse(self.paths.profile.exists())
    self.assertFalse(self.paths.transaction.exists())
    self.assertEqual(self.paths.override.read_bytes(), LOADER)
    self.assertEqual(self.paths.promoter.read_bytes(), PROMOTER)

  def test_community_loader_blocks_save_without_adopting_its_state(self):
    atomic(self.paths.legacy_loader, b'-- community loader\n')
    state = self.session.status()
    with self.assertRaisesRegex(SettingsError, 'community Keyboard Layouts'):
      self.session.save(['us/', 'de/'], 'both-alt', state['revision'])
    self.assertFalse(self.paths.profile.exists())
    self.assertEqual(self.hypr.calls, [])
    self.assertEqual(self.paths.legacy_loader.read_bytes(), b'-- community loader\n')

  def test_loader_emits_nothing_when_community_loader_is_present(self):
    atomic(self.paths.legacy_loader, b'-- community loader\n')
    runner = Path(self.temp.name) / 'load.lua'
    runner.write_text('hl = { device = function() error("must not apply native layouts") end }\ndofile(arg[1])\n')
    env = dict(os.environ, OMARCHY_PATH=str(self.paths.omarchy), XDG_STATE_HOME=str(self.paths.state))
    subprocess.run(['lua', str(runner), str(self.paths.override)], env=env, check=True)

  def test_loader_is_a_noop_on_a_fresh_install(self):
    self.paths.active.unlink()
    self.paths.pending.unlink()
    runner = Path(self.temp.name) / 'load.lua'
    runner.write_text('hl = { device = function() error("must not change a fresh install") end }\ndofile(arg[1])\n')
    env = dict(os.environ, OMARCHY_PATH=str(self.paths.omarchy), XDG_STATE_HOME=str(self.paths.state))
    subprocess.run(['lua', str(runner), str(self.paths.override)], env=env, check=True)
    self.assertFalse(self.paths.profile.exists())
    self.assertFalse(self.paths.active.exists())
    self.assertFalse(self.paths.pending.exists())

  def test_legacy_journal_cannot_rewrite_packaged_source(self):
    atomic(self.paths.transaction, encoded({
      'kind': 'deferred-save', 'override': None,
      'writtenOverride': base64.b64encode(LOADER).decode(),
    }))
    with self.assertRaisesRegex(SettingsError, 'manual review'):
      self.session.recover_pending()
    self.assertEqual(self.paths.override.read_bytes(), LOADER)
    self.assertTrue(self.paths.transaction.exists())

  def test_shipped_loader_matches_backend_contract(self):
    shipped = Path(os.environ['OMARCHY_PATH']) / 'default/hypr/keyboard-layouts.lua'
    self.assertEqual(shipped.read_bytes(), LOADER)

  def test_community_loader_blocks_recovery_without_runtime_changes(self):
    atomic(self.paths.legacy_loader, b'-- community loader\n')
    journal = encoded({'kind': 'live-save'})
    atomic(self.paths.transaction, journal)
    with self.assertRaisesRegex(SettingsError, 'community Keyboard Layouts'):
      self.session.recover_pending()
    self.assertEqual(self.paths.transaction.read_bytes(), journal)
    self.assertEqual(self.hypr.calls, [])

  def test_disabled_native_loader_rejects_save_before_mutation(self):
    (self.paths.omarchy / 'default/hypr/toggles.lua').write_text(
      '-- require("default.hypr.keyboard-layouts")\n')
    state = self.session.status()
    with self.assertRaisesRegex(SettingsError, 'does not load saved keyboard layouts'):
      self.session.save(['us/', 'de/'], 'both-alt', state['revision'])
    self.assertFalse(self.paths.profile.exists())
    self.assertEqual(self.hypr.calls, [])
