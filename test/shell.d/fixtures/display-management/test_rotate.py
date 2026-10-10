import copy
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import rotate
import monitor_state

SOURCE = '''local omarchy_monitor_scale = 2
-- hl.monitor({ output = "DP-1", transform = 0 })
hl.monitor({ output = "desc:FlipGo A1", mode = "2560x1600@60", position = "0x0", scale = omarchy_monitor_scale, transform = 1 })
hl.monitor({ output = "desc:FlipGo A2", mode = "2560x1600@60", position = "800x0", scale = omarchy_monitor_scale, transform = 1 })
'''
MONITORS = [dict(name=f'DP-{i + 1}', description=f'FlipGo A{i + 1}', width=2560,
        height=1600, scale=2, x=i * 800, y=0, transform=1, focused=i==0) for i in range(2)]


class RotationTests(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.root = Path(self.tmp.name)
    self.env = patch.dict(os.environ, {'XDG_STATE_HOME': str(self.root/'state'), 'XDG_RUNTIME_DIR': str(self.root)})
    self.env.start()
    self.addCleanup(self.env.stop)

  def test_landscape_keeps_adjacent_screen_touching(self):
    updated, expected = rotate.plan(SOURCE, MONITORS, 'DP-1', 0)
    self.assertIn('position = "1280x0"', updated)
    self.assertEqual(expected['DP-2'], {'x': 1280, 'y': 0})
    self.assertEqual(updated.count('scale = omarchy_monitor_scale'), 2)
    self.assertIn('-- hl.monitor({ output = "DP-1", transform = 0 })', updated)

  def test_portrait_restores_layout(self):
    landscape, _ = rotate.plan(SOURCE, MONITORS, 'DP-1', 0)
    monitors = copy.deepcopy(MONITORS)
    monitors[0]['transform'] = 0
    monitors[1]['x'] = 1280
    self.assertEqual(rotate.plan(landscape, monitors, 'DP-1', 1)[0], SOURCE)

  def test_other_panel_and_same_direction(self):
    updated, expected = rotate.plan(SOURCE, MONITORS, 'DP-2', 3)
    self.assertEqual(len(expected), 1)
    self.assertIn('position = "800x0"', updated)
    self.assertEqual(rotate.plan(SOURCE, MONITORS, 'DP-1', 1)[0], SOURCE)

  def test_scale_changes_only_selected_screen(self):
    updated, expected = rotate.plan(SOURCE, MONITORS, 'DP-2', 1, 1.25)
    self.assertEqual(expected, {'DP-2': {'transform': 1, 'scale': 1.25}})
    self.assertEqual(updated.splitlines()[2], SOURCE.splitlines()[2])
    self.assertIn('scale = 1.25', updated.splitlines()[3])
    self.assertIn('local omarchy_monitor_scale = 2', updated)

  def test_scale_repositions_neighbor_in_same_transaction(self):
    _, expected = rotate.plan(SOURCE, MONITORS, 'DP-1', 0, 1)
    self.assertEqual(expected['DP-2']['x'], 2560)

  def test_missing_display_and_complex_rule_fail_without_edit(self):
    for name, source in [('missing', SOURCE), ('DP-1', 'hl.monitor(custom_table)')]:
      with self.assertRaises(ValueError):
        rotate.plan(source, MONITORS, name, 0)

  def test_add_transform_and_preserve_options(self):
    source = 'hl.monitor({ output = "DP-1", scale = 2, vrr = 1 }) -- test\n'
    updated = rotate.update_rule(source, MONITORS[0], {'transform': '3'})
    self.assertIn('vrr = 1, transform = 3', updated)
    self.assertTrue(updated.endswith(' -- test\n'))

  def fake_hypr(self, path, fail=False, autoreload=0):
    def call(*args, **kwargs):
      if args == ('configerrors',):
        return 'Simulated config error' if fail and path.read_text() != SOURCE else ''
      if args == ('getoption', 'misc:disable_autoreload', '-j'):
        return json.dumps({'bool': bool(autoreload)})
      if args == ('monitors', '-j'):
        monitors = copy.deepcopy(MONITORS)
        if path.read_text() != SOURCE:
          monitors[0]['transform'] = 0
          monitors[1]['x'] = 1280
        return json.dumps(monitors)
      self.fail('Unexpected compositor command: ' + repr(args))
    return call

  def test_config_error_restores_without_forced_reload(self):
    path = self.root / 'monitors.lua'
    path.write_text(SOURCE)
    with patch.object(rotate, 'hypr', side_effect=self.fake_hypr(path, fail=True)):
      with self.assertRaisesRegex(ValueError, 'Simulated'):
        rotate.apply(path, 'DP-1', 0)
    self.assertEqual(path.read_text(), SOURCE)
    self.assertEqual(len(list(rotate.state_dir().glob('monitors-*.lua'))), 1)

  def test_apply_verifies_result_and_saves_without_forced_reload(self):
    path = self.root / 'monitors.lua'
    path.write_text(SOURCE)
    with patch.object(rotate, 'hypr', side_effect=self.fake_hypr(path)):
      rotate.apply(path, 'DP-1', 0)
    self.assertIn('position = "1280x0"', path.read_text())
    self.assertEqual(list(self.root.glob('monitors.lua.*')), [])

  def test_disabled_autoreload_does_not_write(self):
    path = self.root / 'monitors.lua'
    path.write_text(SOURCE)
    with patch.object(rotate, 'hypr', side_effect=self.fake_hypr(path, autoreload=1)):
      with self.assertRaisesRegex(ValueError, 'disabled'):
        rotate.apply(path, 'DP-1', 0)
    self.assertEqual(path.read_text(), SOURCE)

  def test_lock_is_external_and_rejects_concurrent_process(self):
    with rotate.operation_lock():
      result = subprocess.run([sys.executable, '-c', 'import rotate;\nwith rotate.operation_lock(): pass'],
                  capture_output=True, text=True, cwd=Path(rotate.__file__).parent)
    self.assertNotEqual(result.returncode, 0)
    self.assertIn('still running', result.stderr)
    self.assertTrue((self.root/'omarchy-display-orientation.lock').is_file())

  def test_cooldown_rejects_repeat_write(self):
    path = self.root / 'monitors.lua'
    path.write_text(SOURCE)
    with rotate.operation_lock() as lock:
      lock.write(str(rotate.time.monotonic()))
      lock.flush()
      with patch.object(rotate, 'hypr', side_effect=self.fake_hypr(path)):
        with self.assertRaisesRegex(ValueError, 'wait a few seconds'):
          rotate.apply(path, 'DP-1', 0, lock=lock)
    self.assertEqual(path.read_text(), SOURCE)

  def test_metadata_reads_do_not_probe_brightness(self):
    with patch.object(monitor_state, 'hypr', return_value=json.dumps(MONITORS)) as query:
      state = monitor_state.read_state('DP-2')
    self.assertEqual(state['selected'], 'DP-2')
    self.assertNotIn('brightness', state)
    query.assert_called_once_with('monitors', 'all', '-j')

  def test_reused_connector_rejects_modeset_before_write(self):
    path = self.root / 'monitors.lua'
    path.write_text(SOURCE)
    with patch.object(rotate, 'hypr', side_effect=self.fake_hypr(path)):
      with self.assertRaisesRegex(ValueError, 'connection changed'):
        rotate.apply(path, 'DP-2', 0, expected_description='Different panel')
    self.assertEqual(path.read_text(), SOURCE)

  def test_stale_draft_is_rejected(self):
    path = self.root / 'monitors.lua'
    path.write_text(SOURCE)
    with patch.object(rotate, 'hypr', side_effect=self.fake_hypr(path)):
      with self.assertRaisesRegex(ValueError, 'changed elsewhere'):
        rotate.apply(path, 'DP-2', 0, expected_state={'scale': 1})
    self.assertEqual(path.read_text(), SOURCE)

  def test_quoted_field_names_are_not_edited(self):
    monitor = dict(MONITORS[0], description='transform = 9, scale = 7')
    source = 'hl.monitor({ output = "desc:transform = 9, scale = 7", transform = 1, scale = 2 })'
    updated = rotate.update_rule(source, monitor, {'transform': '0'})
    self.assertIn('output = "desc:transform = 9, scale = 7"', updated)
    self.assertIn('transform = 0, scale = 2', updated)

  def test_duplicate_rules_and_nested_lua_are_rejected(self):
    for source in [SOURCE + SOURCE, 'hl.monitor({ output = "DP-1", scale = fn(1, 2) })']:
      with self.assertRaises(ValueError):
        rotate.update_rule(source, MONITORS[0], {'transform': '0'})

  def test_float_rounding_does_not_trigger_rollback(self):
    self.assertTrue(rotate.matches([{'name': 'DP-1', 'scale': 1.666667}], {'DP-1': {'scale': 5/3}}))
    self.assertFalse(rotate.matches([{'name': 'DP-1', 'scale': 1.67}], {'DP-1': {'scale': 5/3}}))

  def test_new_overlap_in_offset_layout_is_rejected(self):
    monitors = copy.deepcopy(MONITORS)
    monitors[1]['y'] = 50
    with self.assertRaisesRegex(ValueError, 'overlap'):
      rotate.plan(SOURCE, monitors, 'DP-1', 0)

  def test_external_edit_is_not_overwritten_during_rollback(self):
    path = self.root / 'monitors.lua'
    path.write_text(SOURCE)
    external = SOURCE + '-- User edit during application\n'
    def failed_wait(expected):
      path.write_text(external)
      raise ValueError('Simulated concurrent edit')
    with patch.object(rotate, 'hypr', side_effect=self.fake_hypr(path)), \
      patch.object(rotate, 'wait_for', side_effect=failed_wait):
      with self.assertRaisesRegex(ValueError, 'concurrent edit'):
        rotate.apply(path, 'DP-1', 0)
    self.assertEqual(path.read_text(), external)

  def test_diagnostic_failure_does_not_throw(self):
    import display_runtime
    with patch.object(display_runtime, 'state_dir', side_effect=OSError('Disk full')):
      display_runtime.record('saved')

  def test_closed_stdout_does_not_rollback_a_successful_change(self):
    path = self.root / 'monitors.lua'
    path.write_text(SOURCE)
    with patch.object(rotate, 'hypr', side_effect=self.fake_hypr(path)), \
      patch('builtins.print', side_effect=BrokenPipeError):
      with self.assertRaises(BrokenPipeError):
        rotate.apply(path, 'DP-1', 0)
    self.assertIn('position = "1280x0"', path.read_text())


if __name__ == '__main__':
  unittest.main()
