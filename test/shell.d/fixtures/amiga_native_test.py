"""Native selection and control regressions; namespace runner required."""
import os
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

for namespace in ('pid', 'user', 'mnt', 'net'):
  assert os.environ.get('OMARCHY_TEST_HOST_' + namespace) != os.readlink('/proc/self/ns/' + namespace)
  assert os.environ.get('OMARCHY_TEST_HOST_' + namespace)
ROOT = Path(os.environ['ROOT'])
sys.path.insert(0, str(ROOT / 'shell/plugins/services/idle'))
import amiga


class NativeTest(unittest.TestCase):
  def test_explicit_default_never_loads_amiga_dependencies(self):
    with tempfile.TemporaryDirectory() as tmp:
      env = dict(os.environ, HOME=tmp, PATH='/usr/bin:/bin')
      command = ['bash', str(ROOT / 'bin/omarchy-setup-screensaver')]
      result = subprocess.run(command + ['default'], env=env, capture_output=True)
      self.assertEqual(result.returncode, 0, result.stderr)
      self.assertEqual((Path(tmp) / '.config/omarchy/screensaver').read_text(), 'default\n')
      self.assertEqual(subprocess.run(command + ['--is-default'], env=env).returncode, 0)

  def test_state_only_native_dispatch(self):
    command = (ROOT / 'bin/omarchy-screensaver-amiga').read_text()
    self.assertIn('/state.py', command)
    self.assertNotIn('/cold.py', command)

  def test_catalog_title_is_not_guessed(self):
    import pack
    self.assertTrue(hasattr(pack, 'production_title'), 'Explicit title validation missing')
    self.assertEqual(pack.production_title({'title': '<b>Demo & title</b>'}), '<b>Demo & title</b>')
    for demo in ({'id': 'folder-name'}, {'title': ''}, {'title': None}, {'title': 'bad\u0000title'}):
      with self.assertRaises(ValueError): pack.production_title(demo)

  def test_navigation_history_retraces_and_wraps(self):
    import importlib.util
    self.assertIsNotNone(importlib.util.find_spec('history'), 'Native history module is missing')
    from history import History
    history = History(3)
    self.assertFalse(history.navigate('previous'))
    for expected in [1, 2, 0]:
      self.assertTrue(history.navigate('next'))
      self.assertEqual(history.current, expected)
    self.assertTrue(history.navigate('previous'))
    self.assertEqual(history.current, 2)
    history.navigate('next')
    self.assertEqual(history.current, 0)

  def test_geometry_requires_observed_float_dimensions(self):
    self.assertFalse(amiga.source_geometry_ready(dict(floating=False, size=[640, 480])))
    self.assertFalse(amiga.source_geometry_ready(dict(floating=True, size=[853, 533])))
    self.assertTrue(amiga.source_geometry_ready(dict(floating=True, size=[640, 480])))

  def test_localized_hints_follow_desktop_locale(self):
    from audio import hint_labels
    self.assertEqual(hint_labels({'LANG': 'es_CL.UTF-8'})[0], 'M = Activar audio')
    self.assertEqual(hint_labels({'LANG': 'es', 'LANGUAGE': 'en'})[0], 'M = Turn On Audio')
    self.assertEqual(hint_labels({'LANG': 'es', 'LC_ALL': 'C'})[1], 'M = Turn Off Audio')
    self.assertEqual(hint_labels({'LANG': 'fr_FR.UTF-8'})[0], 'M = Activer le son')

  def test_audio_only_mutates_owned_stream_and_rejects_unsafe_gain(self):
    from audio import OwnedAudio
    token = 'org.omarchy.amiga-screensaver.' + 'a' * 32
    stream = dict(index=17, mute=True, volume={'left': {'value': 65536}},
                  properties={'application.id': token, 'application.process.binary': 'fs-uae'})
    class Pulse(OwnedAudio):
      def command(self, *args):
        self.calls.append(args)
        return json.dumps(self.streams) if args == ('-f', 'json', 'list', 'sink-inputs') else ''
    audio = Pulse(token, {})
    audio.calls, audio.streams = [], [stream]
    with self.assertRaisesRegex(RuntimeError, 'Unsafe stream gain'):
      audio.apply(False)
    self.assertEqual([c for c in audio.calls if c[0].startswith('set-')], [('set-sink-input-mute', '17', '1')])
    stream['properties']['application.id'] = 'foreign'
    audio.calls = []
    self.assertIsNone(audio.apply(False))
    self.assertFalse(any(c[0].startswith('set-') for c in audio.calls))

  def test_restoration_requires_all_ordered_markers(self):
    import state
    markers = ["STATERESTORE: '/restore/Saved State 1.uss'", 'State restored',
               'savestate_restore_finish', 'on_restore_state_finished path = /restore/Saved State 1.uss']
    self.assertFalse(state.restore_completed('\n'.join(markers)))  # Stock completion is not a frame.
    self.assertFalse(state.restore_completed('\n'.join(reversed(markers))))
    for index in range(len(markers)):
      self.assertFalse(state.restore_completed('\n'.join(markers[:index] + markers[index + 1:])))

  def test_owned_generation_frame_protocol(self):
    import state
    token = 'a' * 32
    def records(*events, owner=token):
      return ''.join(f'OMARCHY_FRAME_V1 {owner} {event}\n' for event in events)
    valid = ('protocol 1', 'restored 1', 'frame 1 5 640 480 0123456789abcdef')
    self.assertTrue(state.restore_completed(records(*valid), token))
    for events in ((), valid[:1], valid[:2]):
      self.assertFalse(state.restore_completed(records(*events), token))
    self.assertFalse(state.restore_completed(records(*valid).rstrip('\n'), token))
    self.assertFalse(state.restore_completed(records(*valid) + f'OMARCHY_FRAME_V1 {token} error', token))
    for events in (valid[::-1], ('protocol 2',), valid + ('restored 1',),
                   valid[:2] + ('frame 0 5 640 480 0123456789abcdef',),
                   valid[:2] + ('frame 1 0 640 480 0123456789abcdef',),
                   valid[:2] + ('frame 1 5 9000 480 0123456789abcdef',),
                   valid + ('error unknown-state-chunk',),
                   ('protocol 1', 'error rejected-state-chunk') + valid[1:]):
      with self.subTest(events=events), self.assertRaises(ValueError):
        state.restore_completed(records(*events), token)
    with self.assertRaises(ValueError):
      state.restore_completed(records(*valid, owner='b' * 32), token)

  def test_play_reveals_only_after_owned_native_frame(self):
    import contextlib
    from unittest.mock import Mock, patch
    import state
    token = 'a' * 32
    completed = "\n".join(["STATERESTORE: '/restore/Saved State 1.uss'", 'State restored',
                            'savestate_restore_finish', 'on_restore_state_finished path = /restore/Saved State 1.uss']) + '\n'
    protocol = ''.join(f'OMARCHY_FRAME_V1 {token} {event}\n' for event in
                       ('protocol 1', 'restored 1', 'frame 1 7 640 480 0123456789abcdef'))
    for evidence, expected in ((completed, False), (protocol, True),
                               (protocol + "unknown chunk 'ZZZZ' size 128 bytes\n", False)):
      with self.subTest(evidence=evidence), tempfile.TemporaryDirectory() as tmp, contextlib.ExitStack() as stack:
        for target in ('os.kill', 'os.killpg', 'signal.pidfd_send_signal'):
          stack.enter_context(patch(target, side_effect=AssertionError('unexpected signal')))
        log = Path(tmp) / 'owned.log'
        log.write_text(evidence)
        calls, polls = [], []
        def ipc(method, *args):
          calls.append(method)
          if method == 'amigaPoll':
            polls.append(1)
            return json.dumps({'state': 'active' if len(polls) == 1 else 'dismissed'})
          return 'ok'
        stack.enter_context(patch.object(amiga, 'ipc', side_effect=ipc))
        stack.enter_context(patch.object(state, 'owned_window', return_value={'floating': True, 'size': [640, 480]}))
        audio = stack.enter_context(patch.object(state, 'OwnedAudio'))
        audio.return_value.find.return_value = None
        stack.enter_context(patch.object(state.time, 'sleep'))
        with self.assertRaises((InterruptedError, ValueError)):
          state.play(Mock(poll=lambda: None), {'title': 'Fixture'}, token, 'TEST',
                     amiga.APP_CLASS + '.' + token, type('Log', (), {'name': str(log)})(), Mock(), 0)
        self.assertEqual('amigaPresent' in calls, expected)

  def test_restore_errors_override_completion_markers(self):
    import state
    markers = "\n".join(["STATERESTORE: '/restore/Saved State 1.uss'", 'State restored',
                         'savestate_restore_finish', 'on_restore_state_finished path = /restore/Saved State 1.uss'])
    for error in ("unknown chunk 'CPUX' size 128 bytes", "Chunk 'CPU ', size 128 bytes was not accepted!",
                  "Chunk 'CPU ' total size 128 bytes but read 100 bytes!", 'Savestate restore failed'):
      for text in (error + '\n' + markers, markers + '\n' + error):
        with self.subTest(error=error, text=text):
          with self.assertRaisesRegex(ValueError, 'restoration'):
            state.restore_completed(text)

  def test_state_session_three_children_cover_cleanup_and_fresh_logs(self):
    import contextlib
    from unittest.mock import patch
    import state
    events, tokens = [], []
    with tempfile.TemporaryDirectory() as tmp, contextlib.ExitStack() as stack:
      stack.enter_context(patch.dict(os.environ, HOME=tmp, XDG_RUNTIME_DIR=tmp))
      # Synthetic controller test: no emulator, IPC, or real signal is permitted.
      for target in ('os.kill', 'os.killpg', 'signal.pidfd_send_signal'):
        stack.enter_context(patch(target, side_effect=AssertionError('unexpected signal')))
      stack.enter_context(patch.object(state, 'runtime_check'))
      stack.enter_context(patch.object(state.pack, 'load', return_value=[{'task_id': 'fixture', 'state_sha256': 'a' * 64}]))
      stack.enter_context(patch.object(amiga, 'hypr', return_value=[{'name': 'TEST', 'focused': True}]))
      def ipc(method, *args):
        events.append(method)
        return '{}' if method == 'amigaLocale' else 'ok'
      stack.enter_context(patch.object(amiga, 'ipc', side_effect=ipc))
      def command(demo, temporary, token):
        tokens.append(token)
        (Path(temporary) / 'renderer.json').write_text('{}')
        return ['synthetic-child']
      stack.enter_context(patch.object(state, 'sandbox_command', side_effect=command))
      class Child:
        pid = 42
      stack.enter_context(patch.object(amiga, 'launch_command', side_effect=lambda *args: Child()))
      stack.enter_context(patch.object(amiga, 'stop', side_effect=lambda child: events.append('stop')))
      def play(process, demo, owner, monitor, appid, log, history, handled):
        self.assertEqual(Path(log.name).read_bytes(), b'')
        log.write('synthetic restore marker\n')
        log.flush()
        if len(tokens) == 3:
          raise InterruptedError('synthetic dismissal')
        return handled + 1
      stack.enter_context(patch.object(state, 'play', side_effect=play))
      with self.assertRaises(InterruptedError):
        state.run()
      self.assertEqual(len(set(tokens)), 3)
      self.assertEqual(events.count('stop'), 3)
      self.assertEqual(events.count('amigaBegin'), 1)
      self.assertEqual(events.count('amigaCover'), 2)
      self.assertLess(events.index('amigaCover'), events.index('stop'))
      self.assertEqual(events[-2:], ['stop', 'amigaEnd'])

  def test_metadata_failure_always_stops_owned_child(self):
    import contextlib
    from unittest.mock import Mock, patch
    import state
    for failure in (OSError('disk full'), InterruptedError('controller interrupted'), KeyboardInterrupt()):
      with self.subTest(failure=type(failure).__name__), tempfile.TemporaryDirectory() as tmp, contextlib.ExitStack() as stack:
        stack.enter_context(patch.dict(os.environ, HOME=tmp, XDG_RUNTIME_DIR=tmp))
        for target in ('os.kill', 'os.killpg', 'signal.pidfd_send_signal'):
          stack.enter_context(patch(target, side_effect=AssertionError('unexpected signal')))
        stack.enter_context(patch.object(state, 'runtime_check'))
        stack.enter_context(patch.object(state.pack, 'load', return_value=[{'task_id': 'fixture', 'state_sha256': 'a' * 64}]))
        stack.enter_context(patch.object(amiga, 'hypr', return_value=[{'name': 'TEST', 'focused': True}]))
        events = []
        def ipc(method, *args):
          events.append(method)
          return '{}' if method == 'amigaLocale' else 'ok'
        stack.enter_context(patch.object(amiga, 'ipc', side_effect=ipc))
        def command(demo, temporary, token):
          (Path(temporary) / 'renderer.json').write_text('{}')
          return ['synthetic-child']
        stack.enter_context(patch.object(state, 'sandbox_command', side_effect=command))
        child = Mock(pid=42)
        stack.enter_context(patch.object(amiga, 'launch_command', return_value=child))
        stop = stack.enter_context(patch.object(amiga, 'stop', side_effect=lambda child: events.append('stop')))
        play = stack.enter_context(patch.object(state, 'play'))
        original_write = Path.write_text
        def write(path, *args, **kwargs):
          if path.name == 'session.json':
            raise failure
          return original_write(path, *args, **kwargs)
        stack.enter_context(patch.object(Path, 'write_text', write))
        with self.assertRaises(type(failure)):
          state.run()
        stop.assert_called_once_with(child)
        play.assert_not_called()
        self.assertEqual(events[-2:], ['stop', 'amigaEnd'])

  def test_guard_dismissal_stops_state_playback_without_navigation(self):
    from unittest.mock import Mock, patch
    import state
    history = Mock()
    with patch.object(amiga, 'ipc', return_value=json.dumps({'state': 'dismissed', 'reason': 'motion'})):
      with self.assertRaises(InterruptedError):
        state.play(Mock(), {}, 'a' * 32, 'TEST', amiga.APP_CLASS + '.' + 'a' * 32, Mock(), history, 0)
    history.navigate.assert_not_called()


if __name__ == '__main__':
  unittest.main()
