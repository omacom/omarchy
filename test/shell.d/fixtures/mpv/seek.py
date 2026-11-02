#!/usr/bin/env python3
"""Check precise pointer seeking and stable timeline feedback in headless mpv."""
import json
import os
from pathlib import Path
import socket
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[4]


def test():
  with tempfile.TemporaryDirectory(prefix='mpv-seek-') as temporary:
    directory = Path(temporary)
    video = directory / 'two-seconds.mp4'
    subprocess.run([
      'ffmpeg', '-v', 'error', '-f', 'lavfi', '-i',
      'testsrc2=size=160x90:rate=60', '-t', '2', '-c:v', 'libx264',
      '-preset', 'ultrafast', '-g', '120', '-keyint_min', '120',
      '-sc_threshold', '0', str(video),
    ], check=True, timeout=15)
    ipc = directory / 'ipc.sock'
    environment = dict(os.environ, MPV_SEEK_CONTROLLER=os.environ.get(
      'MPV_SEEK_CONTROLLER', str(ROOT / 'config/mpv/scripts/omarchy-controls.lua')))
    with (directory / 'mpv.log').open('w+') as log:
      player = subprocess.Popen([
        'mpv', '--no-config', '--load-scripts=no', '--osc=no',
        '--vo=null', '--ao=null', '--pause', '--keep-open=yes', '--idle=yes',
        f'--input-ipc-server={ipc}',
        f'--script={ROOT / "test/shell.d/fixtures/mpv/seek.lua"}',
        '--script-opts=omarchy-controls-debug=yes,omarchy-controls-visibility=always',
        str(video),
      ], env=environment, stdout=log, stderr=subprocess.STDOUT)
      client = None
      try:
        deadline = time.monotonic() + 10
        while not ipc.exists():
          assert player.poll() is None, 'mpv exited during startup'
          assert time.monotonic() < deadline, 'IPC startup timed out'
          time.sleep(.02)
        client = socket.socket(socket.AF_UNIX)
        client.settimeout(5)
        client.connect(str(ipc))
        reader = client.makefile('r')
        request = 0

        def command(*args):
          nonlocal request
          request += 1
          client.sendall((json.dumps({'command': args, 'request_id': request}) + '\n').encode())
          while True:
            reply = json.loads(reader.readline())
            if reply.get('request_id') == request:
              if reply['error'] in ('property unavailable', 'property not found'):
                return None
              assert reply['error'] == 'success', reply
              return reply.get('data')

        def prop(name):
          return command('get_property', name)

        def wait(predicate, description):
          deadline = time.monotonic() + 5
          while time.monotonic() < deadline:
            if predicate():
              return
            time.sleep(.01)
          raise AssertionError(description)

        def decoded(target):
          completions = prop('user-data/test/completions') or []
          return bool(completions) and abs(completions[-1] - target) < 1 / 60

        wait(lambda: prop('user-data/omarchy/file-active'), 'File did not load')
        wait(lambda: any(r['id'] == 'seek' and r.get('enabled')
                for r in prop('user-data/omarchy/control-regions') or []),
          'Seekbar did not become available')
        regions = prop('user-data/omarchy/control-regions')
        region = next(r for r in regions if r['id'] == 'seek')
        scale = prop('user-data/omarchy/layout')['scale']
        step = 0

        def pointer(action, fraction):
          nonlocal step
          x = round((region['x'] + region['w'] * fraction) * scale)
          y = round((region['y'] + region['h'] / 2) * scale)
          target = (x / scale - region['x']) / region['w'] * 2
          step += 1
          command('script-message-to', 'seek', 'pointer', action, str(x), str(y))
          wait(lambda: prop('user-data/test/step') == step, 'Pointer delivery timed out')
          return target

        target = pointer('down', .7)
        wait(lambda: len(prop('user-data/test/seeks') or []) == 1, 'Press did not seek')
        pointer('move', .7)
        pointer('up', .7)
        assert len(prop('user-data/test/seeks')) == 1, 'Stationary click sent duplicate seeks'
        wait(lambda: decoded(target),
          'Click snapped to a keyframe instead of the selected frame')

        pointer('down', .3)
        for fraction in (.31, .32, .33):
          target = pointer('move', fraction)
          assert abs(prop('user-data/omarchy/timeline-time') - target) < 1e-6
        pointer('up', .33)
        seeks = prop('user-data/test/seeks')
        assert len(seeks) == 5, f'Small movements were dropped or release was duplicated: {seeks}'
        assert all(s['flags'] == 'absolute+exact' for s in seeks), seeks
        wait(lambda: decoded(target),
          'Drag did not decode the selected frame')

        command('set_property', 'pause', False)
        target = pointer('down', .25)
        pointer('up', .25)
        wait(lambda: (prop('time-pos') or 0) > target + .15,
          'Playback did not resume after seeking')
        pointer('move', .25)
        shown, actual = prop('user-data/omarchy/timeline-time'), prop('time-pos')
        assert abs(shown - actual) < .05, \
          f'Thumb stayed pinned: shown={shown}, actual={actual}, completions={prop("user-data/test/completions")}'
        command('set_property', 'pause', True)

        # Model a stale playback clock during an in-flight seek. The
        # actual decoder still runs, and IPC time-pos stays unmodified.
        command('script-message-to', 'seek', 'stale-time', '0')
        target = pointer('down', .8)
        pointer('up', .8)
        time.sleep(.1)
        pointer('move', .8)
        assert abs(prop('user-data/omarchy/timeline-time') - target) < 1e-6, \
          'Thumb returned to a stale playback position before seek completion'
        command('script-message-to', 'seek', 'stale-time', '')
        command('loadfile', str(video))
        wait(lambda: prop('user-data/omarchy/file-generation') == 2, 'Reload did not complete')
        wait(lambda: prop('user-data/omarchy/timeline-time') is not None and
          prop('user-data/omarchy/timeline-time') < .1,
          'Seek target leaked into the next file')
        print('PASS: exact clicks and drags on a two-second sparse-keyframe clip, '
            'small pointer movements, stationary deduplication, playback feedback, '
            'stable thumb and file reset.')
      except Exception:
        log.flush()
        log.seek(0)
        print(log.read())
        raise
      finally:
        if client:
          client.close()
        player.terminate()
        try:
          player.wait(timeout=5)
        except subprocess.TimeoutExpired:
          player.kill()
          player.wait(timeout=5)
        log.seek(0)
        output = log.read()
        assert 'stack traceback' not in output, output


if __name__ == '__main__':
  test()
