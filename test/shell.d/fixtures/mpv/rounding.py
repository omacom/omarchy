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
SCRIPTS = Path(os.environ.get("MPV_TEST_SCRIPTS", str(ROOT / "config/mpv/scripts")))
TEMPLATE = ROOT / 'default/themed/mpv-theme.conf.tpl'


def generate(home, colors):
  stage = home / '.local/state/omarchy/current/next-theme'
  shutil.rmtree(stage, ignore_errors=True)
  stage.mkdir(parents=True)
  shutil.copyfile(colors, stage / 'colors.toml')
  templates = home / '.config/omarchy/themed'
  templates.mkdir(parents=True, exist_ok=True)
  shutil.copyfile(TEMPLATE, templates / TEMPLATE.name)
  subprocess.run([str(ROOT / 'bin/omarchy-theme-set-templates')], check=True,
         env={**os.environ, 'HOME': str(home), 'OMARCHY_PATH': str(OMARCHY), 'PATH': str(ROOT / 'bin') + os.pathsep + os.environ['PATH']})
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
    # A fake read-only hyprctl lets us change geometry without touching the desktop.
    bin_dir = home / 'bin'
    bin_dir.mkdir()
    rounding = home / 'rounding.json'
    rounding.write_text('{"int": 0}')
    hyprctl = bin_dir / 'hyprctl'
    hyprctl.write_text('#!/bin/sh\ncat "$MPV_TEST_ROUNDING"\n')
    hyprctl.chmod(0o755)
    ipc = home / 'ipc.sock'
    config = home / 'config'
    config.mkdir()
    # Exercise the ASS renderer in headless mpv, with a virtual OSD only.
    # Use mpv's real assdraw helpers and reject oversized rounded paths.
    controller = SCRIPTS / 'omarchy-controls.lua'
    wrapper = home / 'controls-test.lua'
    wrapper.write_text("""
local assdraw = require 'mp.assdraw'
for _, name in ipairs({'round_rect_cw', 'round_rect_ccw'}) do
  local original = assdraw[name]
  assdraw[name] = function(self, x1, y1, x2, y2, radius, ...)
    assert(radius >= 0 and radius <= (x2-x1)/2 and radius <= (y2-y1)/2)
    return original(self, x1, y1, x2, y2, radius, ...)
  end
end
mp.get_osd_size = function() return 960, 720 end
mp.create_osd_overlay = function()
  return {update=function(self)
    mp.set_property_native('user-data/mpv-test/overlay', self.data)
  end, remove=function() end}
end
dofile(""" + json.dumps(str(controller)) + ")\n" + """
if os.getenv('MPV_TEST_FIXED_RADIUS') then
  mp.set_property_native('user-data/omarchy/corner-radius', 1000)
  mp.add_timeout(.1, function()
    assert(mp.get_property_native('user-data/omarchy/control-corner-radius') == 3)
    print('PASS: fixed radius survives desktop rounding')
    mp.commandv('quit')
  end)
end
""")
    log_path = home / 'mpv.log'
    with log_path.open('w') as log:
      player = subprocess.Popen([
        'mpv', f'--config-dir={config}', '--vo=null', '--ao=null', '--osc=no',
        '--idle=yes', '--pause=yes', '--audio=no',
        f'--input-ipc-server={ipc}',
        f'--script={wrapper}',
        f'--script={SCRIPTS}/omarchy-theme.lua',
        f'--script-opts=omarchy-theme-theme_file={theme},unrelated-value=kept,omarchy-controls-debug=yes,omarchy-controls-visibility=always',
        'av://lavfi:testsrc2=size=640x360:rate=24'], stdout=log, stderr=subprocess.STDOUT,
        env={**os.environ, 'PATH': str(bin_dir)+os.pathsep+os.environ['PATH'],
          'MPV_TEST_ROUNDING': str(rounding)})
      try:
        deadline = time.monotonic() + 10
        while not ipc.exists() and time.monotonic() < deadline:
          if player.poll() is not None:
            raise AssertionError(log_path.read_text())
          time.sleep(.05)
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

        def wait_palette(expected):
          deadline = time.monotonic() + 5
          while time.monotonic() < deadline:
            if property('user-data/omarchy/theme') == expected:
              return
            time.sleep(.05)
          raise AssertionError(f'Palette did not reload: {log_path.read_text()}')

        def parsed(data):
          return {k:v for k,v in (line.split('=',1) for line in data.splitlines()
              if line and not line.startswith('#')) if '-' not in k}

        def wait_radius(expected):
          deadline = time.monotonic() + 5
          while time.monotonic() < deadline:
            if property('user-data/omarchy/control-corner-radius') == expected:
              return
            time.sleep(.05)
          raise AssertionError(f'Rounding did not reload: {log_path.read_text()}')

        wait_radius(0)
        rounding.write_text('{"int": 8}')
        wait_radius(8)
        assert property('pause') is True
        for bad in ('invalid', '{}', '{"int": -2}', '{"int": "12"}'):
          rounding.write_text(bad)
          command('script-message', 'reload-omarchy-rounding')
          time.sleep(.15)
          assert property('user-data/omarchy/control-corner-radius') == 8
        # Large radii exercise clamps on buttons, tooltips, and the volume thumb.
        rounding.write_text('{"int": 1000}')
        wait_radius(1000)
        rounded_ass = property('user-data/mpv-test/overlay')
        assert '\\clip(' in rounded_ass and ' b ' in rounded_ass
        rounding.write_text('{"int": 0}')
        wait_radius(0)
        deadline = time.monotonic() + 5
        while property('user-data/mpv-test/overlay') == rounded_ass and time.monotonic() < deadline:
          time.sleep(.05)
        assert property('user-data/mpv-test/overlay') != rounded_ass
        wait_palette(parsed(dark))
        assert property('pause') is True
        assert property('script-opts')['unrelated-value'] == 'kept'
        pid = player.pid
        # Replace the file atomically, as Omarchy replaces the theme directory.
        replacement = home / 'replacement'
        replacement.write_text(light)
        replacement.replace(theme)
        wait_palette(parsed(light))
        assert property('osd-color').lower().endswith(parsed(light)['foreground'][1:].lower())
        assert property('pause') is True and player.pid == pid
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
        command('quit')
        player.wait(timeout=5)
        assert 'stack traceback' not in log_path.read_text(), log_path.read_text()
        fixed = subprocess.run(['mpv', f'--config-dir={config}', '--vo=null',
          '--ao=null', '--idle=yes', '--osc=no', f'--script={wrapper}',
          '--script-opts=omarchy-controls-debug=yes,omarchy-controls-corner_radius=3'],
          env={**os.environ, 'MPV_TEST_FIXED_RADIUS': '1'},
          capture_output=True, text=True, timeout=10)
        assert fixed.returncode == 0 and 'PASS: fixed radius' in fixed.stdout, fixed.stdout+fixed.stderr
        assert 'stack traceback' not in fixed.stdout+fixed.stderr
        print('PASS: paused palette/rounding reloads, invalid-data recovery, rounded ASS gradients/clamps, and unrelated options.')
      finally:
        if player.poll() is None:
          player.terminate()
          player.wait(timeout=5)


if __name__ == '__main__':
  test()
