#!/usr/bin/env python3
"""Exercise live palette reload through a real mpv process, without desktop changes."""
import json
import os
from pathlib import Path
import shutil
import socket
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[4]
OMARCHY = ROOT
SCRIPTS = Path(os.environ.get('MPV_TEST_SCRIPTS', str(ROOT / 'config/mpv/scripts')))


def generate(home, colors, omarchy=OMARCHY):
  template = omarchy / 'default/themed/mpv-theme.conf.tpl'
  stage = home / '.local/state/omarchy/current/next-theme'
  shutil.rmtree(stage, ignore_errors=True)
  stage.mkdir(parents=True)
  shutil.copyfile(colors, stage / 'colors.toml')
  templates = home / '.config/omarchy/themed'
  templates.mkdir(parents=True, exist_ok=True)
  shutil.copyfile(template, templates / template.name)
  subprocess.run([str(omarchy / 'bin/omarchy-theme-set-templates')], check=True,
         env={**os.environ, 'HOME': str(home), 'OMARCHY_PATH': str(omarchy), 'PATH': str(omarchy / 'bin') + os.pathsep + os.environ['PATH']})
  data = (stage / 'mpv-theme.conf').read_text()
  assert '{{' not in data, 'Unresolved theme token'
  return data


def test():
  with tempfile.TemporaryDirectory(prefix='mpv-theme-') as temp:
    home = Path(temp)
    dark = generate(home, OMARCHY / 'themes/nord/colors.toml')
    light = generate(home, OMARCHY / 'themes/flexoki-light/colors.toml')
    theme = home / 'theme.conf'
    theme.write_text(dark)
    ipc = home / 'ipc.sock'
    config = home / 'config'
    config.mkdir()
    log_path = home / 'mpv.log'
    with log_path.open('w') as log:
      args = [
        'mpv', f'--config-dir={config}', '--vo=null', '--ao=null', '--osc=no',
        '--idle=yes', '--pause=yes', '--audio=no',
        f'--input-ipc-server={ipc}',
        f'--script={SCRIPTS}/omarchy-controls.lua',
        f'--script={SCRIPTS}/omarchy-theme.lua',
        f'--script-opts=omarchy-theme-theme_file={theme},unrelated-value=kept',
        'av://lavfi:testsrc2=size=640x360:rate=24']
      # Hold the first native theme load until the invalid message arrives.
      helpers = home / 'bin'
      helpers.mkdir()
      helper = helpers / 'omarchy-theme-color'
      helper.write_text('#!/bin/bash\n'
          'touch "$MPV_THEME_REQUEST"\n'
          'for ((i=0; i<100; i++)); do\n'
          '  [[ -e $MPV_THEME_RELEASE ]] && break\n'
          '  sleep .05\n'
          'done\n'
          '[[ -e $MPV_THEME_RELEASE ]] || exit 1\n'
          'exec "$OMARCHY_PATH/bin/omarchy-theme-color" "$@"\n')
      helper.chmod(0o755)
      request, release = home / 'request', home / 'release'
      environment = {**os.environ, 'OMARCHY_PATH': str(ROOT),
          'MPV_THEME_REQUEST': str(request), 'MPV_THEME_RELEASE': str(release),
          'PATH': str(helpers) + os.pathsep + str(ROOT / 'bin') + os.pathsep + os.environ['PATH']}
      player = second = second_log = None
      try:
        player = subprocess.Popen(args, stdout=log, stderr=subprocess.STDOUT, env=environment)
        second_ipc = home / 'second.sock'
        override = home / 'input.conf'
        override.write_text('a set volume 51\n')
        second_log = (home / 'second.log').open('w')
        second = subprocess.Popen([args[0], f'--input-conf={override}'] + [f'--input-ipc-server={second_ipc}' if a.startswith('--input-ipc-server=') else a for a in args[1:]], stdout=second_log, stderr=subprocess.STDOUT, env=environment)
        deadline = time.monotonic() + 10
        while not ipc.exists() and time.monotonic() < deadline:
          if player.poll() is not None:
            raise AssertionError(log_path.read_text())
          time.sleep(.05)
        while not second_ipc.exists() and time.monotonic() < deadline:
          assert second.poll() is None
          time.sleep(.05)
        client2 = socket.socket(socket.AF_UNIX)
        client2.settimeout(5)
        client2.connect(str(second_ipc))
        reader2 = client2.makefile('r')
        client = socket.socket(socket.AF_UNIX)
        client.settimeout(5)
        client.connect(str(ipc))
        reader = client.makefile('r')
        counter = 0

        def command(*args):
          nonlocal counter
          counter += 1
          client.sendall((json.dumps({'command': args, 'request_id': counter})+'\n').encode())
          while True:
            reply = json.loads(reader.readline())
            if reply.get('request_id') == counter:
              return reply

        def property(name):
          return command('get_property', name).get('data')

        def second_command(*args):
          client2.sendall((json.dumps({'command': args, 'request_id': 1})+'\n').encode())
          while True:
            reply=json.loads(reader2.readline())
            if reply.get('request_id') == 1:
              return reply.get('data')

        def second_property(name):
          return second_command('get_property', name)

        def wait_palette(expected, second_expected=None):
          if second_expected is None: second_expected = expected
          deadline = time.monotonic() + 5
          while time.monotonic() < deadline:
            if property('user-data/omarchy/theme') == expected and second_property('user-data/omarchy/theme') == second_expected:
              return
            time.sleep(.05)
          raise AssertionError(f'Palette did not reload: {log_path.read_text()}')

        def parsed(data):
          return {k:v for k,v in (line.split('=',1) for line in data.splitlines()
              if line and not line.startswith('#')) if '-' not in k}

        wait_palette(parsed(dark))
        def assert_stats(data):
          colors = dict(line.split('=', 1) for line in data.splitlines()
              if line.startswith('stats-'))
          for key, rgb in colors.items():
            assert property('script-opts')[key].lower() == (rgb[5:7]+rgb[3:5]+rgb[1:3]).lower(), key
        assert_stats(dark)
        # Theme publication can precede the first decoded paused frame.
        deadline=time.monotonic()+10
        while property('time-pos') is None and time.monotonic()<deadline:
          time.sleep(.05)
        assert property('time-pos') is not None, 'Paused playback did not initialize'
        second_command('keypress','a')
        deadline=time.monotonic()+3
        while second_property('volume') != 51 and time.monotonic()<deadline:time.sleep(.05)
        assert second_property('volume') == 51, 'Custom input.conf must override audio picker binding'
        command('set_property','sub-color','#123456')
        assert property('pause') is True
        assert property('script-opts')['unrelated-value'] == 'kept'
        command('set_property', 'volume', 37)
        command('set_property', 'mute', True)
        before_position = property('time-pos')
        pid = player.pid
        command('script-message', 'set-omarchy-theme', 'nord')
        deadline=time.monotonic()+5
        while not request.exists() and time.monotonic()<deadline: time.sleep(.05)
        assert request.exists(), 'Native theme load did not start'
        command('script-message', 'set-omarchy-theme', '../invalid')
        release.touch()
        wait_palette(parsed(dark))
        deadline=time.monotonic()+5
        while property('user-data/omarchy/theme-selection') != 'nord' and time.monotonic()<deadline:time.sleep(.05)
        assert property('user-data/omarchy/theme-selection') == 'nord', 'Invalid slug cancelled a valid theme load'
        # Replace the file atomically, as Omarchy replaces the theme directory.
        replacement = home / 'replacement'
        replacement.write_text(light)
        replacement.replace(theme)
        wait_palette(parsed(dark), parsed(light))
        assert second_property('user-data/omarchy/theme-selection') == 'automatic'
        for invalid in ('missing-theme-for-test', '../nord', f"nord;touch {home / 'sentinel'}"):
          command('script-message', 'set-omarchy-theme', invalid)
          time.sleep(.1)
          assert property('user-data/omarchy/theme') == parsed(dark)
          assert property('user-data/omarchy/theme-selection') == 'nord'
          assert not (home / 'sentinel').exists()
        command('script-message', 'set-omarchy-theme', 'flexoki-light')
        wait_palette(parsed(light))
        assert_stats(light)
        command('script-message', 'set-omarchy-theme', 'nord')
        command('script-message', 'set-omarchy-theme', 'automatic')
        wait_palette(parsed(light))
        time.sleep(.3)
        assert property('user-data/omarchy/theme-selection') == 'automatic'
        assert property('user-data/omarchy/theme') == parsed(light)
        assert property('osd-color').lower().endswith(parsed(light)['foreground'][1:].lower())
        assert property('pause') is True and player.pid == pid
        assert property('volume') == 37 and property('mute') is True
        assert property('sub-color').lower().endswith('123456'), 'Retint changed subtitle styling'
        assert abs(property('time-pos') - before_position) < .1
        assert property('script-opts')['console-focused_back_color'] == parsed(light)['accent']
        assert property('script-opts')['unrelated-value'] == 'kept'
        # Unknown namespaced values must not override behavior options.
        for bad in ('', dark.replace('mode=dark', 'mode=invalid'),
              dark.replace('background=', 'background=invalid'),
              dark + 'console-font_size=#123456\n',
              dark + 'command=quit\n',
              '\n'.join(line for line in dark.splitlines()
                   if not line.startswith('stats-font_color='))):
          theme.write_text(bad)
          command('script-message', 'reload-omarchy-theme')
          time.sleep(.1)
          assert property('user-data/omarchy/theme') == parsed(light), repr(bad)
          assert property('script-opts')['unrelated-value'] == 'kept'
        theme.write_text('background={{ background }}\n')
        time.sleep(1.2)
        assert property('user-data/omarchy/theme') == parsed(light)
        theme.unlink()
        time.sleep(1.2)
        assert property('user-data/omarchy/theme') == parsed(light)
        theme.write_text(dark)
        wait_palette(parsed(dark))
        legacy='\n'.join(line for line in light.splitlines() if not line.startswith('mode='))+'\n'
        theme.write_text(legacy)
        wait_palette(parsed(legacy))
        assert property('user-data/omarchy/theme').get('mode') is None
        client2.sendall((json.dumps({'command':['quit']})+'\n').encode())
        second.wait(timeout=5)
        command('quit')
        player.wait(timeout=5)
        assert 'stack traceback' not in log_path.read_text(), log_path.read_text()
        print('PASS: dark/light palettes reload in paused mpv; invalid/missing files retain colors; unrelated options survive.')
      finally:
        for process in (second, player):
          if process is not None and process.poll() is None:
            process.terminate()
            try:
              process.wait(timeout=5)
            except subprocess.TimeoutExpired:
              process.kill()
              process.wait(timeout=5)
        if second_log is not None:
          second_log.close()


if __name__ == '__main__':
  test()
