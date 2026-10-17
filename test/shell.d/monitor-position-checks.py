"""Geometry, Lua preservation and transaction regressions for monitor positioning."""

import copy
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('position', ROOT / 'default/hypr/monitor-position.py')
position = importlib.util.module_from_spec(spec)
spec.loader.exec_module(position)


def monitor(name, x=0, y=0, width=1920, height=1080, scale=1, transform=0, **extra):
  return dict(name=name, x=x, y=y, width=width, height=height, scale=scale, transform=transform, **extra)


def evaluate(contents):
  # Execute the actual Lua with a rule-merging stub matching hl.monitor. Comparing
  # evaluated rules catches lost expressions, options, and malformed generated Lua.
  script = '''local rules = {}
  hl = { env = function() end, monitor = function(rule)
    local previous = rules[rule.output] or {}
    for key, value in pairs(rule) do previous[key] = value end
    rules[rule.output] = previous
  end }
  ''' + contents + '''
  for name, rule in pairs(rules) do
    for key, value in pairs(rule) do
      if type(value) ~= "table" then print(name .. "\\t" .. key .. "\\t" .. tostring(value)) end
    end
  end
  '''
  result = subprocess.run(['lua5.1', '-'], input=script, capture_output=True, text=True, check=True)
  return dict((tuple(line.split('\t')[:2]), line.split('\t')[2]) for line in result.stdout.splitlines())


class GeometryTests(unittest.TestCase):
  def test_multiple_desktop_screens_and_nonzero_anchor(self):
    screens = [monitor('DP-1', 100, 200), monitor('DP-2', 2020, 200), monitor('DP-3', 3940, 200)]
    result = position.arrange(screens, 'DP-3', 'DP-2', 'below')
    self.assertEqual(result, {'DP-1': (100, 200), 'DP-2': (2020, 200), 'DP-3': (2020, 1280)})

  def test_scaled_rotated_screen_and_negative_positions(self):
    anchor = monitor('eDP-1', -100, -200, 3840, 2160, 2)
    moving = monitor('DP-1', 1820, -200, 2560, 1440, 1.25, 1)
    expected = {'left': (-1252, -200), 'right': (1820, -200),
                'above': (-100, -2248), 'below': (-100, 880)}
    for side, coordinates in expected.items():
      with self.subTest(side=side):
        self.assertEqual(position.arrange([anchor, moving], 'DP-1', 'eDP-1', side)['DP-1'], coordinates)

  def test_overlap_with_third_screen_rejected(self):
    screens = [monitor('DP-1'), monitor('DP-2', 1920), monitor('DP-3', 3840)]
    with self.assertRaisesRegex(RuntimeError, 'overlap DP-2 and DP-3'):
      position.arrange(screens, 'DP-3', 'DP-1', 'right')

  def test_missing_or_same_screen_rejected(self):
    for output, reference in [('DP-1', 'DP-1'), ('DP-2', 'DP-1')]:
      with self.assertRaises(RuntimeError):
        position.arrange([monitor('DP-1')], output, reference, 'left')

  def test_invalid_scale_rejected(self):
    for scale in (0, -1, float('nan'), float('inf')):
      with self.assertRaises(RuntimeError):
        position.logical_size(monitor('DP-1', scale=scale))

  def test_horizontal_alignment_with_scaled_rotated_screens(self):
    screens = [monitor('eDP-1', -100, 200, 3840, 2160, 2),
               monitor('DP-1', 1820, 200, 2560, 1440, 1.25, 1)]
    for side, x in [('left', -1252), ('right', 1820)]:
      for alignment, y in [('top', 200), ('center', -284), ('bottom', -768)]:
        with self.subTest(side=side, alignment=alignment):
          self.assertEqual(position.arrange(screens, 'DP-1', 'eDP-1', side, alignment)['DP-1'], (x, y))

  def test_vertical_alignment_with_scaled_rotated_screens(self):
    screens = [monitor('eDP-1', -100, 200, 3840, 2160, 2),
               monitor('DP-1', 1820, 200, 2560, 1440, 1.25, 1)]
    for side, y in [('above', -1848), ('below', 1280)]:
      for alignment, x in [('left', -100), ('center', 284), ('right', 668)]:
        with self.subTest(side=side, alignment=alignment):
          self.assertEqual(position.arrange(screens, 'DP-1', 'eDP-1', side, alignment)['DP-1'], (x, y))

  def test_alignment_rejects_wrong_axis_and_rounds_odd_centers(self):
    screens = [monitor('DP-1', height=1081), monitor('DP-2', 1920, height=720)]
    self.assertEqual(position.arrange(screens, 'DP-2', 'DP-1', 'right', 'center')['DP-2'], (1920, 180))
    for side, alignment in [('left', 'right'), ('above', 'bottom'), ('below', 'invalid')]:
      with self.subTest(side=side, alignment=alignment), self.assertRaisesRegex(RuntimeError, 'alignment'):
        position.arrange(screens, 'DP-2', 'DP-1', side, alignment)

  def test_bottom_alignment_rejects_overlap_with_a_third_screen(self):
    screens = [monitor('DP-1'), monitor('DP-2', 1920, width=1280, height=720), monitor('DP-3', 1920, 720)]
    self.assertEqual(position.arrange(screens, 'DP-2', 'DP-1', 'right', 'top')['DP-2'], (1920, 0))
    with self.assertRaisesRegex(RuntimeError, 'overlap'):
      position.arrange(screens, 'DP-2', 'DP-1', 'right', 'bottom')

  def test_middle_screen_move_cannot_isolate_a_third_screen(self):
    screens = [monitor('DP-1'), monitor('DP-2', 1920), monitor('DP-3', 3840)]
    with self.assertRaisesRegex(position.LayoutError, 'Every screen must touch'):
      position.arrange(screens, 'DP-2', 'DP-1', 'below')

  def test_contact_requires_a_shared_edge_not_a_corner(self):
    screens = [monitor('DP-1'), monitor('DP-2', 1920)]
    with self.assertRaisesRegex(position.LayoutError, 'touch'):
      position.validate_positions(screens, {'DP-1': (0, 0), 'DP-2': (1920, 1080)})
    self.assertEqual(position.validate_positions(screens, {'DP-1': (-1920, -123), 'DP-2': (0, 0)})['DP-2'], (0, 0))

  def test_connectivity_follows_scaled_rotated_edges(self):
    screens = [monitor('DP-1', width=3840, height=2160, scale=2),
               monitor('DP-2', width=2560, height=1440, scale=1.25, transform=1),
               monitor('DP-3', width=1280, height=720)]
    layout = {'DP-1': (0, 0), 'DP-2': (1920, 123), 'DP-3': (3072, 900)}
    self.assertEqual(position.validate_positions(screens, layout), layout)


class ConfigTests(unittest.TestCase):
  def test_multiline_rules_comments_nested_fields_and_missing_position(self):
    original = '''-- hl.monitor({output="DP-1", scale=99})
local example = "hl.monitor({output='DP-1'})"
hl.monitor({
  output = 'DP-1', mode = '2560x1440@144', scale = 1.25,
  transform = 1, vrr = 2, reserved_area = {top=12, bottom=3}
  -- preserve this comment
})
hl.monitor({output='DP-2', scale=2, position='auto'})
'''
    screens = [monitor('DP-1'), monitor('DP-2', 1920)]
    updated = position.update_config(original, screens, {'DP-1': (-1920, 0), 'DP-2': (0, 0)})
    before, after = evaluate(original), evaluate(updated)
    for key, value in before.items():
      if key[1] != 'position':
        self.assertEqual(after[key], value)
    self.assertEqual(after['DP-1', 'position'], '-1920x0')
    self.assertIn('-- preserve this comment', updated)
    self.assertEqual(position.update_config(updated, screens, {'DP-1': (-1920, 0), 'DP-2': (0, 0)}), updated)

  def test_generic_rules_preserve_expressions_and_merged_options(self):
    original = '''local omarchy_monitor_scale = 1.6
hl.monitor({output="", mode="preferred", scale=omarchy_monitor_scale, transform=3, vrr=2})
hl.monitor({output="", bitdepth=10})
'''
    screens = [monitor('DP-1'), monitor('DP-2', 1920)]
    locations = {'DP-1': (0, 0), 'DP-2': (1920, 0)}
    updated = position.update_config(original, screens, locations)
    values = evaluate(updated)
    for name in locations:
      for field in ('mode', 'scale', 'transform', 'vrr', 'bitdepth'):
        self.assertEqual(values[name, field], values['', field])
    self.assertIn('scale=omarchy_monitor_scale', updated)
    self.assertEqual(position.update_config(updated, screens, locations), updated)

  def test_fallback_copies_keep_the_value_at_the_original_declaration(self):
    original = 'local value=1\nhl.monitor({output="",scale=value,vrr=value})\nvalue=2\nlocal value=3\n'
    updated = position.update_config(original, [monitor('DP-1')], {'DP-1': (0, 0)})
    values = evaluate(updated)
    self.assertEqual(values['DP-1', 'scale'], '1')
    self.assertEqual(values['DP-1', 'vrr'], '1')

  def test_fallback_computed_settings_are_not_evaluated_again(self):
    for expression in ('choose_scale()', 'settings.scale', 'value - 1', 'value + 1', 'next_vrr "argument"', 'next_vrr {}', 'value % 2', 'value or 1'):
      original = 'hl.monitor({output="",scale=' + expression + '})\n'
      with self.subTest(expression=expression), self.assertRaisesRegex(RuntimeError, 'computed scale'):
        position.update_config(original, [monitor('DP-1')], {'DP-1': (0, 0)})

  def test_description_rule_gets_independent_connector_rule(self):
    original = 'hl.monitor({output="desc:Acme", scale=2, transform=1})\n'
    screens = [monitor('DP-1', description='Acme screen')]
    updated = position.update_config(original, screens, {'DP-1': (-1080, 0)})
    values = evaluate(updated)
    self.assertEqual(values['DP-1', 'scale'], '2')
    self.assertEqual(values['DP-1', 'position'], '-1080x0')
    self.assertIn(original.strip(), updated)

  def test_repeated_explicit_rules_keep_merged_settings(self):
    original = 'hl.monitor({output="DP-1", scale=2, position="auto"})\nhl.monitor({output="DP-1", vrr=1})\n'
    updated = position.update_config(original, [monitor('DP-1')], {'DP-1': (100, -900)})
    self.assertEqual(evaluate(updated)['DP-1', 'position'], '100x-900')
    self.assertEqual(evaluate(updated)['DP-1', 'scale'], '2')

  def test_long_comments_and_strings_do_not_become_rules(self):
    original = '''--[=[ hl.monitor(dynamic) ]=]
local text = [==[ hl.monitor(dynamic) ]==]
hl.monitor({output="",scale=1})
'''
    self.assertEqual(len(position.monitor_rules(original)), 1)

  def test_expression_context_calls_are_rejected(self):
    for original in ('local unused = hl.monitor({output="",scale=1}) or true',
                     'local unused =\n hl.monitor({output="",scale=1})',
                     'consume(\n hl.monitor({output="",scale=1}))'):
      with self.subTest(original=original), self.assertRaisesRegex(RuntimeError, 'standalone'):
        position.monitor_rules(original)

  def test_dynamic_and_ambiguous_rules_rejected(self):
    for contents in ('hl.monitor(rule)', 'if true then hl.monitor({output="DP-1"}) end',
                     'hl.monitor({output=connector})', 'hl.monitor({["output"]="DP-1"})'):
      with self.subTest(contents=contents), self.assertRaises(RuntimeError):
        position.monitor_rules(contents)
    with self.assertRaisesRegex(RuntimeError, 'Ambiguous'):
      position.update_config('hl.monitor({output="desc:A"})\nhl.monitor({output="desc:Acme"})',
                             [monitor('DP-1', description='Acme')], {'DP-1': (0, 0)})


class TransactionTests(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory()
    self.addCleanup(self.temp.cleanup)
    self.config_home = Path(self.temp.name)
    self.config = self.config_home / 'hypr/monitors.lua'
    self.config.parent.mkdir()
    self.original = 'hl.monitor({output="",scale=1})\n'
    self.config.write_text(self.original)
    self.config.chmod(0o640)
    self.screens = [monitor('DP-1'), monitor('DP-2', 1920)]
    self.environment = patch.dict(os.environ, {'XDG_CONFIG_HOME': str(self.config_home), 'XDG_STATE_HOME': str(self.config_home / 'state')})
    self.environment.start()
    self.addCleanup(self.environment.stop)

  def run_apply(self, **kwargs):
    return position.apply('DP-2', 'DP-1', 'left', **kwargs)


  def test_external_edit_at_publication_is_retained(self):
    exchange = position.exchange_config
    edited = self.original + '-- editor saved at publication\n'
    def racing_exchange(replacement, path):
      if path == self.config and self.config.read_text() == self.original:
        self.config.write_text(edited)
      exchange(replacement, path)
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'exchange_config', side_effect=racing_exchange):
      with self.assertRaisesRegex(RuntimeError, 'Concurrent monitors.lua edit'):
        self.run_apply()
    self.assertEqual(self.config.read_text(), edited)
    retained = list(self.config.parent.glob('.monitor-position-conflict-*'))
    self.assertEqual(len(retained), 1)
    self.assertIn('Position saved', retained[0].read_text())

  def test_interrupted_exchange_retains_the_displaced_file(self):
    exchange = position.exchange_config
    edited = self.original + '-- editor saved at interrupted publication\n'
    def interrupted_exchange(replacement, path):
      self.config.write_text(edited)
      exchange(replacement, path)
      raise subprocess.TimeoutExpired(['mv'], 12)
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'exchange_config', side_effect=interrupted_exchange):
      with self.assertRaisesRegex(RuntimeError, 'Versions were retained'):
        self.run_apply()
    retained = list(self.config.parent.glob('.monitor-position-conflict-*'))
    self.assertEqual(len(retained), 1)
    self.assertEqual(retained[0].read_text(), edited)

  def test_external_edit_at_rollback_is_retained(self):
    exchange = position.exchange_config
    calls = 0
    edited = '-- editor saved at rollback\n'
    def racing_exchange(replacement, path):
      nonlocal calls
      calls += 1
      if calls == 2:
        self.config.write_text(edited)
      exchange(replacement, path)
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'wait_layout', side_effect=RuntimeError('ignored apply')), patch.object(position, 'exchange_config', side_effect=racing_exchange):
      with self.assertRaisesRegex(RuntimeError, 'Concurrent monitors.lua edit'):
        self.run_apply()
    self.assertEqual(self.config.read_text(), edited)
    self.assertTrue(list(self.config.parent.glob('.monitor-position-conflict-*')))

  def test_symlink_racing_publication_does_not_overwrite_its_target(self):
    target = self.config_home / 'personal.lua'
    target.write_text('-- unrelated file\n')
    exchange = position.exchange_config
    raced = False
    def racing_exchange(replacement, path):
      nonlocal raced
      if not raced:
        raced = True
        path.unlink()
        path.symlink_to(target)
      exchange(replacement, path)
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'exchange_config', side_effect=racing_exchange):
      with self.assertRaisesRegex(RuntimeError, 'Concurrent monitors.lua edit'):
        self.run_apply()
    self.assertTrue(self.config.is_symlink())
    self.assertEqual(target.read_text(), '-- unrelated file\n')

  def test_apply_respects_the_scaling_config_lock(self):
    state = self.config_home / 'state/omarchy'
    state.mkdir(parents=True)
    with (state / 'monitor-config.lock').open('a') as lock:
      fcntl.flock(lock, fcntl.LOCK_EX)
      with self.assertRaisesRegex(RuntimeError, 'in progress'):
        self.run_apply()
    self.assertEqual(self.config.read_text(), self.original)

  def test_disconnected_preview_can_be_repaired_before_apply(self):
    screens = [monitor('DP-1'), monitor('DP-2', 1920), monitor('DP-3', 3840)]
    draft = {'DP-1': [0, 0], 'DP-2': [0, 1080], 'DP-3': [3840, 0]}
    request = dict(action='preview', positions=draft, snapshot=position.snapshot(screens))
    with patch.object(position, 'displays', return_value=screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'wait_layout'):
      self.assertFalse(position.panel_request(request)['connected'])
      with self.assertRaisesRegex(position.LayoutError, 'touch'):
        position.panel_request(dict(request, action='apply'))
      self.assertEqual(self.config.read_text(), self.original)
      draft['DP-3'] = [1920, 1080]
      self.assertTrue(position.panel_request(request)['connected'])
      position.panel_request(dict(request, action='apply'))
    self.assertEqual(evaluate(self.config.read_text())['DP-3', 'position'], '1920x1080')

  def test_panel_preview_is_read_only_and_returns_logical_geometry(self):
    screens = [monitor('DP-1', width=3840, height=2160, scale=2),
               monitor('DP-2', 1920, width=2560, height=1440, scale=1.25, transform=1)]
    with patch.object(position, 'displays', return_value=screens):
      state = position.panel_request({'action': 'state'})
      result = position.panel_request({'action': 'preview', 'output': 'DP-2', 'reference': 'DP-1',
                                       'side': 'left', 'snapshot': state['snapshot']})
    self.assertEqual(result['monitors'][1]['x'], -1152)
    self.assertEqual(result['monitors'][1]['logicalHeight'], 2048)
    self.assertEqual(self.config.read_text(), self.original)
    self.assertFalse(self.config.with_name('monitors.lua.bak.monitor-position').exists())

  def test_panel_apply_accepts_json_snapshot_and_saves_layout(self):
    self.screens[1]['height'] = 720
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'wait_layout'):
      state = json.loads(json.dumps(position.panel_request({'action': 'state'})))
      result = position.panel_request({'action': 'apply', 'output': 'DP-2', 'reference': 'DP-1',
                                       'side': 'left', 'alignment': 'bottom', 'snapshot': state['snapshot']})
    self.assertIn('Saved', result['message'])
    self.assertIn('aligned bottom', result['message'])
    self.assertEqual(evaluate(self.config.read_text())['DP-2', 'position'], '-1920x360')

  def test_panel_apply_requires_snapshot_and_rejects_stale_preview(self):
    request = {'action': 'apply', 'output': 'DP-2', 'reference': 'DP-1', 'side': 'left'}
    with self.assertRaisesRegex(RuntimeError, 'snapshot'):
      position.panel_request(request)
    request['snapshot'] = json.loads(json.dumps(position.snapshot(self.screens)))
    changed = [monitor('DP-1'), monitor('DP-2', 2000)]
    with patch.object(position, 'displays', return_value=changed), self.assertRaisesRegex(RuntimeError, 'changed since'):
      position.panel_request(request)
    self.assertEqual(self.config.read_text(), self.original)

  def test_panel_saves_multiple_moves_and_arbitrary_offsets_together(self):
    screens = [monitor('DP-1'), monitor('DP-2', 1920), monitor('DP-3', 3840)]
    layout = {'DP-1': [100, 200], 'DP-2': [2020, 323], 'DP-3': [2020, 1403]}
    request = dict(action='preview', positions=layout, snapshot=position.snapshot(screens))
    with patch.object(position, 'displays', return_value=screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'wait_layout'):
      preview = position.panel_request(request)
      self.assertEqual(preview['monitors'][1]['y'], 323)
      self.assertEqual(self.config.read_text(), self.original)
      position.panel_request(dict(request, action='apply'))
    rules = evaluate(self.config.read_text())
    self.assertEqual(rules['DP-1', 'position'], '100x200')
    self.assertEqual(rules['DP-2', 'position'], '2020x323')
    self.assertEqual(rules['DP-3', 'position'], '2020x1403')

  def test_full_layout_rejects_overlap_missing_outputs_and_invalid_coordinates(self):
    for layout in ({'DP-1': [0, 0]}, {'DP-1': [0, 0], 'DP-2': [100, 100]},
                   {'DP-1': [0, 0], 'DP-2': [True, 0]}, {'DP-1': [0, 0], 'DP-2': [float('nan'), 0]},
                   {'DP-1': [0, 0], 'DP-2': [1000001, 0]}):
      with self.subTest(layout=layout), patch.object(position, 'displays', return_value=self.screens), self.assertRaises(RuntimeError):
        position.panel_request(dict(action='apply', positions=layout, snapshot=position.snapshot(self.screens)))
      self.assertEqual(self.config.read_text(), self.original)

  def test_readable_labels_have_stable_numbers_after_query_reordering(self):
    screens = [monitor('eDP-1'), monitor('DP-2', 1920, model='Acme Display')]
    first = position.layout_state(screens)['monitors']
    second = position.layout_state(screens[::-1])['monitors']
    self.assertEqual(first[0]['label'], 'Built-in display')
    self.assertEqual(first[1]['label'], 'Acme Display')
    self.assertEqual({m['name']: m['number'] for m in first}, {m['name']: m['number'] for m in second})

  def test_success_backup_and_permissions(self):
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'wait_layout'):
      self.run_apply()
    self.assertEqual(self.config.with_name('monitors.lua.bak.monitor-position').read_text(), self.original)
    self.assertEqual(self.config.stat().st_mode & 0o777, 0o640)
    self.assertEqual(evaluate(self.config.read_text())['DP-2', 'position'], '-1920x0')

  def test_reload_failure_rolls_back_and_checks_layout(self):
    calls = []
    def fake_hypr(*args):
      calls.append(args)
      if args == ('reload',) and calls.count(args) == 1:
        raise RuntimeError('reload failed')
      return ''
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', side_effect=fake_hypr), patch.object(position, 'wait_layout') as wait:
      with self.assertRaisesRegex(RuntimeError, 'previous configuration and layout were restored'):
        self.run_apply()
      wait.assert_called_once_with(self.screens, {'DP-1': (0, 0), 'DP-2': (1920, 0)})
    self.assertEqual(self.config.read_text(), self.original)

  def test_config_errors_and_hotplug_leave_config_untouched(self):
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value='existing error'):
      with self.assertRaisesRegex(RuntimeError, 'existing'):
        self.run_apply()
    with patch.object(position, 'displays', side_effect=[self.screens, self.screens[:1]]), patch.object(position, 'hypr', return_value=''):
      with self.assertRaisesRegex(RuntimeError, 'changed'):
        self.run_apply()
    self.assertEqual(self.config.read_text(), self.original)

  def test_stale_gui_preview_does_not_change_configuration(self):
    changed = copy.deepcopy(self.screens)
    changed[0]['x'] = 100
    with patch.object(position, 'displays', return_value=changed), patch.object(position, 'hypr') as hypr:
      with self.assertRaisesRegex(RuntimeError, 'changed since the preview'):
        self.run_apply(expected_snapshot=position.snapshot(self.screens))
      hypr.assert_not_called()
    self.assertEqual(self.config.read_text(), self.original)
    self.assertFalse(self.config.with_name('monitors.lua.bak.monitor-position').exists())

  def test_external_edit_during_backup_is_not_overwritten(self):
    original_write = position.atomic_write
    def edit_during_backup(path, contents):
      original_write(path, contents)
      if path.name == 'monitors.lua.bak.monitor-position':
        self.config.write_text('-- user edit during backup\n')
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'atomic_write', side_effect=edit_during_backup):
      with self.assertRaisesRegex(RuntimeError, 'changed while creating'):
        self.run_apply()
    self.assertEqual(self.config.read_text(), '-- user edit during backup\n')

  def test_external_edit_during_apply_is_not_overwritten(self):
    def external_edit(*args):
      self.config.write_text('-- user edit\n')
      raise RuntimeError('apply failed')
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'wait_layout', side_effect=external_edit):
      with self.assertRaisesRegex(RuntimeError, 'restore .* manually'):
        self.run_apply()
    self.assertEqual(self.config.read_text(), '-- user edit\n')

  def test_dry_run_leaves_config_and_backup_untouched(self):
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr') as hypr, patch('builtins.print'):
      self.run_apply(dry_run=True)
      hypr.assert_not_called()
    self.assertEqual(self.config.read_text(), self.original)
    self.assertFalse(self.config.with_name('monitors.lua.bak.monitor-position').exists())

  def test_symlink_preserved(self):
    target = self.config_home / 'actual.lua'
    self.config.rename(target)
    self.config.symlink_to(target)
    with patch.object(position, 'displays', return_value=self.screens), patch.object(position, 'hypr', return_value=''), patch.object(position, 'wait_layout'):
      self.run_apply()
    self.assertTrue(self.config.is_symlink())
    self.assertEqual(evaluate(target.read_text())['DP-2', 'position'], '-1920x0')

  def test_wait_checks_all_outputs_modes_and_config_errors(self):
    moved = copy.deepcopy(self.screens)
    moved[1]['x'] = -1920
    with patch.object(position, 'hypr', return_value=''), patch.object(position, 'displays', side_effect=[self.screens, moved]), patch.object(position.time, 'sleep'):
      position.wait_layout(self.screens, {'DP-1': (0, 0), 'DP-2': (-1920, 0)})
    with patch.object(position, 'hypr', return_value='config error'):
      with self.assertRaisesRegex(RuntimeError, 'config error'):
        position.wait_layout(self.screens, {'DP-1': (0, 0), 'DP-2': (-1920, 0)})


class PanelProcessTests(unittest.TestCase):
  def test_apply_finishes_when_the_panel_waiter_disappears(self):
    with tempfile.TemporaryDirectory() as directory:
      scratch = Path(directory)
      executable = scratch / 'bin/hyprctl'
      executable.parent.mkdir()
      fake = ROOT / 'test/shell.d/monitor-arrangement/fake-hyprctl.py'
      executable.write_text(f'#!/bin/bash\nexec "{sys.executable}" "{fake}" "$@"\n')
      executable.chmod(0o700)
      environment = dict(os.environ, XDG_CONFIG_HOME=str(scratch / 'config'),
                         ARRANGEMENT_TEST_STATE=str(scratch / 'state.json'),
                         PATH=str(executable.parent) + os.pathsep + os.environ['PATH'])
      subprocess.run([sys.executable, str(fake), '--control', '{"reset":true,"reloadDelay":0.5}'], env=environment, check=True)
      helper = str(ROOT / 'default/hypr/monitor-position.py')
      result = subprocess.run([sys.executable, helper, '--request', '{"action":"state"}'], env=environment, capture_output=True, text=True, check=True)
      request = dict(action='apply', output='DP-3', reference='eDP-1', side='left', snapshot=json.loads(result.stdout)['snapshot'])
      waiter = subprocess.Popen([sys.executable, helper, '--request', json.dumps(request)], env=environment,
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
      self.addCleanup(lambda: waiter.poll() is not None or waiter.kill())
      deadline = time.monotonic() + 5
      while time.monotonic() < deadline:
        state = json.loads((scratch / 'state.json').read_text())
        if state.get('reloadStarted'):
          break
        time.sleep(0.02)
      else:
        self.fail('Apply did not reach the simulated reload')
      waiter.kill()
      waiter.wait(timeout=2)
      while time.monotonic() < deadline:
        state = json.loads((scratch / 'state.json').read_text())
        if state['monitors'][2]['x'] == -1280:
          break
        time.sleep(0.02)
      else:
        self.fail('The transaction died with its panel waiter')
      self.assertEqual(evaluate((scratch / 'config/hypr/monitors.lua').read_text())['DP-3', 'position'], '-1280x0')


class ConfirmationProcessTests(unittest.TestCase):
  def setUp(self):
    self.temp = tempfile.TemporaryDirectory()
    self.addCleanup(self.temp.cleanup)
    self.scratch = Path(self.temp.name)
    executable = self.scratch / 'bin/hyprctl'
    executable.parent.mkdir()
    self.fake = ROOT / 'test/shell.d/monitor-arrangement/fake-hyprctl.py'
    executable.write_text(f'#!/bin/bash\nexec "{sys.executable}" "{self.fake}" "$@"\n')
    executable.chmod(0o700)
    self.env = dict(os.environ, XDG_CONFIG_HOME=str(self.scratch / 'config'), XDG_STATE_HOME=str(self.scratch / 'state'),
                    ARRANGEMENT_TEST_STATE=str(self.scratch / 'compositor.json'),
                    PATH=str(executable.parent) + os.pathsep + os.environ['PATH'])
    subprocess.run([sys.executable, str(self.fake), '--control', '{"reset":true}'], env=self.env, check=True)
    self.config = self.scratch / 'config/hypr/monitors.lua'
    self.original = self.config.read_text()
    self.initial = self.call({'action': 'state'})
    self.request = dict(action='trial', positions={'eDP-1': [0, 0], 'DP-2': [1920, 123], 'DP-3': [0, 1080]}, snapshot=self.initial['snapshot'])

  def call(self, request):
    result = subprocess.run([sys.executable, str(ROOT / 'default/hypr/monitor-position.py'), '--request', json.dumps(request)],
                            env=self.env, capture_output=True, text=True, check=True)
    return json.loads(result.stdout)

  def await_status(self, trial, wanted, seconds=5):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
      state = json.loads(Path(trial['statePath']).read_text())
      if state['status'] in wanted:
        return state
      time.sleep(0.03)
    self.fail('Did not reach ' + repr(wanted) + ': ' + repr(state))

  def test_keep_commits_the_whole_draft_after_confirmation(self):
    trial = self.call(self.request)
    self.await_status(trial, ('confirming',))
    self.call(dict(action='keep', token=trial['token']))
    self.assertEqual(self.await_status(trial, ('kept',))['status'], 'kept')
    rules = evaluate(self.config.read_text())
    self.assertEqual(rules['DP-2', 'position'], '1920x123')
    self.assertEqual(rules['DP-3', 'position'], '0x1080')
    self.call(dict(action='dismiss', token=trial['token']))
    self.assertFalse(Path(trial['statePath']).exists())

  def test_revert_restores_configuration_and_live_geometry(self):
    trial = self.call(self.request)
    self.await_status(trial, ('confirming',))
    self.call(dict(action='revert', token=trial['token']))
    self.await_status(trial, ('reverted',))
    self.assertEqual(self.config.read_text(), self.original)
    self.assertEqual(self.call({'action': 'state'})['snapshot'], self.initial['snapshot'])

  def test_unconfirmed_trial_reverts_after_panel_process_has_exited(self):
    # call() has already waited for the panel's request process to exit.
    trial = self.call(self.request)
    state = self.await_status(trial, ('confirming',))
    self.assertGreater(state['deadline'], time.time() + 18)
    self.await_status(trial, ('reverted',), seconds=24)
    self.assertEqual(self.config.read_text(), self.original)
    self.assertEqual(self.call({'action': 'state'})['snapshot'], self.initial['snapshot'])

  def use_different_saved_and_live_positions(self):
    self.original = 'hl.monitor({output="", scale=1})\nhl.monitor({output="DP-2", position="2500x100", scale=1})\n'
    self.config.write_text(self.original)
    subprocess.run([sys.executable, str(self.fake), '--control', '{"move":true}'], env=self.env, check=True)
    self.initial = self.call({'action': 'state'})
    self.request['snapshot'] = self.initial['snapshot']

  def test_revert_restores_live_positions_when_saved_config_differs(self):
    self.use_different_saved_and_live_positions()
    trial = self.call(self.request)
    self.await_status(trial, ('confirming',))
    self.call(dict(action='revert', token=trial['token']))
    state = self.await_status(trial, ('reverted', 'error'), seconds=15)
    self.assertEqual(state['status'], 'reverted', state)
    self.assertEqual(self.config.read_text(), self.original)
    self.assertEqual(self.call({'action': 'state'})['snapshot'], self.initial['snapshot'])

  def test_timeout_restores_live_positions_when_saved_config_differs(self):
    self.use_different_saved_and_live_positions()
    trial = self.call(self.request)
    self.await_status(trial, ('confirming',))
    state = self.await_status(trial, ('reverted', 'error'), seconds=36)
    self.assertEqual(state['status'], 'reverted', state)
    self.assertEqual(self.config.read_text(), self.original)
    self.assertEqual(self.call({'action': 'state'})['snapshot'], self.initial['snapshot'])

  def test_trial_applies_when_positions_already_match_saved_file(self):
    monitors = json.loads((self.scratch / 'compositor.json').read_text())['monitors']
    self.original = position.update_config(self.original, monitors, {name: tuple(point) for name, point in self.request['positions'].items()})
    self.config.write_text(self.original)
    trial = self.call(self.request)
    state = self.await_status(trial, ('confirming', 'kept', 'error'))
    self.assertEqual(state['status'], 'confirming', state)
    self.assertEqual(self.call({'action': 'state'})['monitors'][1]['y'], 123)
    self.call(dict(action='revert', token=trial['token']))
    self.await_status(trial, ('reverted',))
    self.assertEqual(self.config.read_text(), self.original)
    self.assertEqual(self.call({'action': 'state'})['snapshot'], self.initial['snapshot'])

  def test_failed_apply_restores_live_positions_when_saved_config_differs(self):
    self.use_different_saved_and_live_positions()
    subprocess.run([sys.executable, str(self.fake), '--control', '{"reloadError":true}'], env=self.env, check=True)
    trial = self.call(self.request)
    state = self.await_status(trial, ('error',))
    self.assertIn('previous configuration and layout were restored', state['message'])
    self.assertEqual(self.config.read_text(), self.original)
    self.assertEqual(self.call({'action': 'state'})['snapshot'], self.initial['snapshot'])

  def test_competing_trial_cannot_save_while_confirmation_is_pending(self):
    first = self.call(self.request)
    self.await_status(first, ('confirming',))
    second = self.call(self.request)
    rejected = self.await_status(second, ('error',))
    self.assertIn('in progress', rejected['message'])
    self.call(dict(action='revert', token=first['token']))
    self.await_status(first, ('reverted',))
    self.assertEqual(self.config.read_text(), self.original)

  def test_external_config_edit_during_confirmation_is_preserved(self):
    trial = self.call(self.request)
    self.await_status(trial, ('confirming',))
    self.config.write_text('-- user changed configuration\n')
    self.call(dict(action='keep', token=trial['token']))
    self.assertIn('manually', self.await_status(trial, ('error',))['message'])
    self.assertEqual(self.config.read_text(), '-- user changed configuration\n')


if __name__ == '__main__':
  unittest.main()
