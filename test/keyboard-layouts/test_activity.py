"""Regression coverage for split-interface layout reporting after shell reloads."""
import copy
import json
import os
import unittest
from unittest.mock import patch

import test_backend
from backend.deferred import LOADER
from backend.session import Session, atomic


class ActivityTests(unittest.TestCase):
  def setUp(self):
    test_backend.TransactionTests.setUp(self)
    env = patch.dict(os.environ, HYPRLAND_INSTANCE_SIGNATURE='layout-activity-test')
    env.start()
    self.addCleanup(env.stop)

  def restarted(self):
    return Session(self.paths, self.hypr, self.session.records)

  def split(self):
    self.hypr.items[0]['active_layout_index'] = 1

  def test_source_survives_new_backend_instance(self):
    self.split()
    before = copy.deepcopy(self.hypr.items)
    self.assertEqual(self.session.status('typing-keyboard')['active'], 1)
    self.assertEqual(self.restarted().status()['active'], 1)
    self.assertEqual(self.hypr.items, before)
    self.assertEqual(self.hypr.calls, [])
    self.assertFalse(self.paths.profile.exists())
    self.assertEqual(self.paths.override.read_bytes(), LOADER)

  def test_cached_source_reads_current_index_not_old_label(self):
    self.split()
    self.session.status('typing-keyboard')
    self.hypr.items[0]['active_layout_index'] = 0
    self.assertEqual(self.restarted().status()['active'], 0)

  def test_one_changed_interface_recovers_a_missed_event(self):
    self.session.status()
    self.split()
    self.assertEqual(self.restarted().status()['active'], 1)
    self.assertEqual(self.restarted().status()['active'], 1)

  def test_multiple_changes_do_not_guess_the_last_interface(self):
    self.split()
    self.session.status('typing-keyboard')
    self.hypr.items[0]['active_layout_index'] = 0
    self.hypr.items[1]['active_layout_index'] = 1
    self.assertEqual(self.restarted().status()['active'], -1)

  def test_cold_split_state_reports_layouts_and_recovery(self):
    self.split()
    state = self.session.status()
    self.assertEqual(state['active'], -1)
    self.assertEqual([r['id'] for r in state['activeLayouts']], ['us/', 'pl/'])
    self.assertIn('Select a layout', state['problem'])
    self.session.switch(1, state['revision'])
    state = self.restarted().status()
    self.assertEqual(state['active'], 1)
    self.assertEqual(state['problem'], '')

  def test_device_replacement_invalidates_source(self):
    self.split()
    self.session.status('typing-keyboard')
    self.hypr.items[0]['address'] = 'replacement'
    self.assertEqual(self.restarted().status()['active'], -1)

  def test_keymap_changes_invalidate_source(self):
    self.split()
    self.session.status('typing-keyboard')
    for device in self.hypr.items[:2]:
      device['layout'] = 'pl,us'
    self.assertEqual(self.restarted().status()['active'], -1)

  def test_new_desktop_session_invalidates_source(self):
    self.split()
    self.session.status('typing-keyboard')
    with patch.dict(os.environ, HYPRLAND_INSTANCE_SIGNATURE='new-desktop'):
      self.assertEqual(self.restarted().status()['active'], -1)

  def test_missing_session_cannot_reuse_source(self):
    self.split()
    with patch.dict(os.environ, HYPRLAND_INSTANCE_SIGNATURE=''):
      self.session.status('typing-keyboard')
      self.assertEqual(self.restarted().status()['active'], -1)

  def test_mouse_event_cannot_replace_verified_typing_source(self):
    self.split()
    self.session.status('typing-keyboard')
    self.assertEqual(self.restarted().status('mouse-keyboard')['active'], 1)

  def test_malformed_cache_does_not_break_reporting(self):
    self.split()
    self.paths.activity.parent.mkdir(parents=True, exist_ok=True)
    for value in ('not json', '[]', 'null'):
      atomic(self.paths.activity, value.encode())
      self.assertEqual(self.restarted().status()['active'], -1)
      self.assertIsInstance(json.loads(self.paths.activity.read_text()), dict)

  def test_unchanged_poll_does_not_rewrite_cache_or_revision(self):
    self.split()
    first = self.session.status('typing-keyboard')
    stamp = self.paths.activity.stat().st_mtime_ns
    second = self.restarted().status()
    self.assertEqual(first['revision'], second['revision'])
    self.assertEqual(self.paths.activity.stat().st_mtime_ns, stamp)
