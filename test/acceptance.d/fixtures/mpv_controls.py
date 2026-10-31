#!/usr/bin/env python3
"""Render and exercise the controller in a separate mpv window on workspace 3."""
import json
import http.server
import functools
import threading
import os
import runpy
from pathlib import Path
import shutil
import socket
import subprocess
import tempfile
import time

ROOT = Path(__file__).resolve().parents[3]
OMARCHY = Path(os.environ['OMARCHY_PATH'])


def test():
  with tempfile.TemporaryDirectory(prefix='mpv-controls-') as temp:
    home = Path(temp)
    config = home / 'config'
    shutil.copytree(OMARCHY / 'config/mpv', config)
    generator=runpy.run_path(str(ROOT/'test/shell.d/fixtures/mpv/palette.py'))
    palettes={name:generator['generate'](home/'render',OMARCHY/f'themes/{name}/colors.toml', OMARCHY)
         for name in ('nord','flexoki-light','catppuccin-latte')}
    theme=home/'theme.conf'
    theme.write_text(palettes['nord'])
    media=home/'fixture.mkv'
    chapters=home/'chapters.ffmeta'
    chapters.write_text(';FFMETADATA1\n[CHAPTER]\nTIMEBASE=1/1000\nSTART=0\nEND=7000\ntitle=First chapter\n[CHAPTER]\nTIMEBASE=1/1000\nSTART=7000\nEND=15000\ntitle=Second chapter\n')
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y',
      '-f','lavfi','-i','testsrc2=size=640x360:rate=12',
      '-f','lavfi','-i','anullsrc=channel_layout=stereo:sample_rate=48000',
      '-i',str(chapters),'-map','0:v','-map','1:a','-map','1:a','-map_chapters','2','-t','15',
      '-metadata:s:a:0','language=eng','-metadata:s:a:0','title=English test track',
      '-metadata:s:a:1','language=spa','-metadata:s:a:1','title=Alternate test track',
      '-c:v','libx264','-preset','ultrafast','-crf','30','-c:a','aac',str(media)],check=True)
    ipc = home / 'ipc.sock'
    log_path = home / 'mpv.log'
    producer=None
    with log_path.open('w') as log:
      player = subprocess.Popen([
        'mpv', f'--config-dir={config}', '--player-operation-mode=pseudo-gui', '--keep-open=yes', '--idle=yes', f'--geometry={os.environ.get("MPV_ACCEPTANCE_GEOMETRY", "800x600")}',
        '--title=mpv controls verification', '--pause=yes', '--audio=no', '--ao=null', '--hwdec=no', f'--vo={os.environ.get("MPV_ACCEPTANCE_VO", "gpu")}',
        f'--input-ipc-server={ipc}',f'--script-opts=omarchy-theme-theme_file={theme},omarchy-controls-debug=yes', str(media)],
        stdout=log, stderr=subprocess.STDOUT)
      try:
        deadline = time.monotonic()+10
        while not ipc.exists() and time.monotonic() < deadline:
          assert player.poll() is None, log_path.read_text()
          time.sleep(.05)
        client = socket.socket(socket.AF_UNIX)
        client.settimeout(15)
        client.connect(str(ipc))
        reader = client.makefile('r')
        request = 0

        def command(*args):
          nonlocal request
          request += 1
          client.sendall((json.dumps({'command': args, 'request_id': request})+'\n').encode())
          while True:
            line=reader.readline()
            if not line:
              raise AssertionError(f'mpv closed its IPC connection; exit={player.poll()}')
            reply = json.loads(line)
            if reply.get('request_id') == request:
              if args[0] == 'get_property' and reply['error'] == 'property unavailable':
                return None
              assert reply['error'] == 'success', reply
              return reply.get('data')

        def prop(name):
          return command('get_property', name)

        if shutil.which('hyprctl'):
          for _ in range(40):
            clients=json.loads(subprocess.check_output(['hyprctl','clients','-j']))
            if any(c['pid']==player.pid for c in clients):
              subprocess.run(['hyprctl','eval',f'local w=hl.get_window("pid:{player.pid}"); assert(w); hl.dispatch(hl.dsp.window.move({{window=w,workspace="3",follow=true}}))'],check=True,stdout=subprocess.DEVNULL)
              break
            time.sleep(.05)
        time.sleep(.5)
        def capture(path):
          artifact=Path(os.environ.get('OMARCHY_ACCEPTANCE_DIR', str(home)))
          artifact.mkdir(parents=True,exist_ok=True)
          # Property events can precede the compositor's next presented frame.
          time.sleep(.25)
          subprocess.run(['grim',str(path)],check=True,timeout=10)
          shutil.copyfile(path,artifact / ('success-mpv-' + Path(path).name))
        assert prop('osd-dimensions')['w'] > 0
        dims=prop('osd-dimensions')
        command('mouse',dims['w']//2,dims['h']//2)
        deadline=time.monotonic()+8
        while prop('user-data/omarchy/controls-visible') and time.monotonic()<deadline:
          time.sleep(.1)
        assert prop('user-data/omarchy/controls-visible') is False, f'Auto-hide failed while paused: idle={prop("idle-active")}, mouse={prop("mouse-pos")}'
        assert prop('osd-bar') is False, 'Duplicate native seek/volume bar was not disabled'
        command('keypress','RIGHT')
        deadline=time.monotonic()+3
        while not prop('user-data/omarchy/controls-visible') and time.monotonic()<deadline:
          time.sleep(.02)
        assert prop('user-data/omarchy/controls-visible') is True, 'Keyboard seek did not reveal themed timeline'
        capture(str(home/'keyboard-seek.png'))
        command('script-binding', 'omarchy_controls/toggle-controls')
        time.sleep(.2)
        assert prop('user-data/omarchy/controls-visible') is True, 'Pin did not reveal controls'
        capture( str(home / 'visible.png'))
        assert (home / 'visible.png').stat().st_size > 1000
        assert prop('user-data/omarchy/surface-mode') == 'gradient'
        for mode in ('solid','translucent','gradient'):
          command('keypress','Ctrl+F9')
          deadline=time.monotonic()+3
          while prop('user-data/omarchy/surface-mode') != mode and time.monotonic()<deadline:
            time.sleep(.05)
          assert prop('user-data/omarchy/surface-mode') == mode
          capture(str(home / f'{mode}.png'))
        assert (home/'translucent.png').read_bytes() != (home/'gradient.png').read_bytes()
        for name in ('flexoki-light','catppuccin-latte','nord'):
          theme.write_text(palettes[name])
          expected=dict(line.split('=',1) for line in palettes[name].splitlines()
                 if line.startswith('background='))['background']
          deadline=time.monotonic()+5
          while prop('user-data/omarchy/theme')['background'] != expected and time.monotonic()<deadline:
            time.sleep(.05)
          assert prop('user-data/omarchy/theme')['background'] == expected
          command('show-text','',0)
          time.sleep(.2)
          image=home/f'{name}.png'
          capture(str(image))
          output=os.environ.get('MPV_TEST_SCREENSHOTS')
          if output:
            Path(output).mkdir(parents=True,exist_ok=True)
            shutil.copyfile(image,Path(output)/image.name)
        # A real pointer hold must keep adjusting volume as it moves.
        dims=prop('osd-dimensions')
        scale=max(.75,min(1.6,dims['h']/720))
        if dims['w']/scale >= 850:
          layout=prop('user-data/omarchy/layout')
          slider=next(r for r in prop('user-data/omarchy/control-regions') if r['id']=='volume-slider')
          scale=layout['scale']
          start=slider['x']*scale
          y=(slider['y']+slider['h']/2)*scale
          command('mouse',round(start+slider['w']*.12*scale),round(y))
          time.sleep(.1)
          command('keydown','MBTN_LEFT');time.sleep(.1)
          before=prop('volume')
          command('mouse',round(start+slider['w']*.70*scale),round(y))
          deadline=time.monotonic()+3
          after=prop('volume')
          while after <= before+20 and time.monotonic()<deadline:
            time.sleep(.02)
            after=prop('volume')
          command('keyup','MBTN_LEFT')
          assert after > before+20, f'Continuous volume drag failed: {before} -> {after}'
          command('set_property','volume',100)
        assert len([t for t in prop('track-list') if t['type']=='audio']) == 2
        assert len(prop('chapter-list')) == 2
        for name in ('English', 'Español'):
          subtitle=home/f'{name} fixture.srt'
          subtitle.write_text('1\n00:00:00,000 --> 00:00:15,000\nSubtitle test fixture\n')
          command('sub-add',str(subtitle),'auto',name)
        assert len([t for t in prop('track-list') if t['type']=='sub']) == 2
        command('script-binding','select/select-sid');time.sleep(.2)
        assert prop('user-data/mpv/console/open') is True
        capture(str(home/'subtitles.png'))
        command('keypress','ESC');time.sleep(.2)
        command('set_property','sid','no')
        command('keypress','j');time.sleep(.2)
        assert prop('sid') != 'no', 'Native subtitle cycling failed'
        command('set_property','sid','no')
        command('set_property','aid',1)
        command('keypress','#');time.sleep(.2)
        assert prop('aid') == 2, 'Native audio cycling failed'
        command('script-binding','select/select-chapter');time.sleep(.2)
        assert prop('user-data/mpv/console/open') is True
        capture(str(home/'chapters.png'))
        command('keypress','ESC');time.sleep(.2)
        subprocess.run(['wtype','-k','a'],check=True);time.sleep(.2)
        assert prop('user-data/mpv/console/open') is True, 'Audio shortcut did not open track picker'
        command('keypress','ESC')
        deadline=time.monotonic()+3
        while prop('user-data/mpv/console/open') and time.monotonic()<deadline:
          time.sleep(.02)
        assert prop('user-data/mpv/console/open') is False
        bindings=prop('input-bindings')
        assert any(b['key']=='A' and 'video-aspect-override' in b['cmd'] for b in bindings)
        command('set_property','pause',True)
        command('seek',0,'absolute+exact')
        command('script-binding', 'omarchy_controls/focus-controls')
        deadline=time.monotonic()+5
        while time.monotonic()<deadline:
          if prop('user-data/omarchy/focused-control') == 'play' and any(b['section']=='omarchy-keyboard' and b['priority']>=0 for b in prop('input-bindings')):
            break
          time.sleep(.05)
        command('keypress','ENTER')
        deadline=time.monotonic()+3
        while prop('pause') and time.monotonic()<deadline:time.sleep(.02)
        assert prop('pause') is False, 'Keyboard playback failed'
        command('keypress','ENTER')
        deadline=time.monotonic()+3
        while not prop('pause') and time.monotonic()<deadline:time.sleep(.02)
        assert prop('pause') is True
        def focus_control(name):
          for _ in range(25):
            current=prop('user-data/omarchy/focused-control')
            if current == name: return
            command('keypress','TAB')
            deadline=time.monotonic()+2
            while prop('user-data/omarchy/focused-control') == current and time.monotonic()<deadline:
              time.sleep(.02)
          raise AssertionError(f'Control not reachable: {name}')
        focus_control('speed')
        command('keypress','ENTER')
        time.sleep(.1)
        assert prop('speed') > 1, 'Keyboard speed control failed'
        command('set_property','speed',1)
        focus_control('volume')
        command('keypress','ENTER')
        time.sleep(.1)
        assert prop('mute') is True, 'Keyboard mute failed'
        command('set_property','mute',False)
        focus_control('volume-slider')
        before=prop('volume')
        command('keypress','RIGHT')
        time.sleep(.1)
        assert prop('volume') > before, 'Volume slider keyboard adjustment failed'
        command('keypress','LEFT')
        command('keypress','ESC')
        command('script-binding','select/menu')
        time.sleep(.2)
        assert prop('user-data/mpv/console/open') is True
        assert prop('user-data/omarchy/controls-visible') is False
        capture(str(home / 'menu.png'))
        command('keypress','ESC')
        time.sleep(.2)
        command('script-binding','select/select-binding')
        time.sleep(.2)
        assert prop('user-data/mpv/console/open') is True
        command('keypress','ESC')
        command('keypress','LEFT')
        time.sleep(.1)
        assert prop('user-data/omarchy/controls-visible') is True
        command('cycle','fullscreen')
        time.sleep(.2)
        assert prop('fullscreen') is True
        command('cycle','fullscreen')
        time.sleep(.5)
        assert prop('fullscreen') is False
        # Local HTTP media exercises loading and seeking without a network dependency.
        class QuietHandler(http.server.SimpleHTTPRequestHandler):
          def log_message(self, *args):
            pass
        server=http.server.ThreadingHTTPServer(('127.0.0.1',0),functools.partial(QuietHandler,directory=str(home)))
        thread=threading.Thread(target=server.serve_forever,daemon=True)
        thread.start()
        try:
          command('loadfile',f'http://127.0.0.1:{server.server_port}/fixture.mkv')
          deadline=time.monotonic()+10
          while not prop('duration') and time.monotonic()<deadline:time.sleep(.1)
          assert prop('duration') >= 14, 'HTTP fixture did not load'
          command('set_property','pause',True)
          command('seek',5,'absolute+exact')
          deadline=time.monotonic()+5
          while abs((prop('time-pos') or 0)-5)>1 and time.monotonic()<deadline:time.sleep(.1)
          assert abs(prop('time-pos')-5)<1, 'HTTP seek failed'
          capture(str(home/'http-media.png'))
        finally:
          server.shutdown();server.server_close();thread.join(timeout=5)
        audio=home/'audio.wav'
        subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','lavfi','-i','sine=frequency=440','-t','5',str(audio)],check=True)
        command('loadfile',str(audio))
        deadline=time.monotonic()+5
        while not any(t['type']=='audio' for t in (prop('track-list') or [])) and time.monotonic()<deadline:time.sleep(.1)
        assert not any(t['type']=='video' for t in prop('track-list')), 'Audio fixture has video'
        command('script-message-to','omarchy_controls','osc-visibility','always');time.sleep(.3)
        capture(str(home/'audio-only.png'))
        fifo=home/'live.ts'
        os.mkfifo(fifo)
        producer=subprocess.Popen(['ffmpeg','-hide_banner','-loglevel','error','-y','-re','-f','lavfi','-i','testsrc2=size=640x360:rate=12','-c:v','mpeg2video','-f','mpegts',str(fifo)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        command('loadfile',str(fifo))
        deadline=time.monotonic()+5
        while not any(t['type']=='video' for t in (prop('track-list') or [])) and time.monotonic()<deadline:time.sleep(.1)
        # mpv may expose the buffered span as an estimated duration even
        # for a live pipe. Test the live source instead of asserting None.
        assert producer.poll() is None, 'Live FIFO producer exited'
        command('set_property','pause',False);time.sleep(1)
        assert prop('idle-active') is False, 'Live stream did not stay active'
        capture(str(home/'live-fifo.png'))
        command('loadfile',str(home/'missing-video.mkv'))
        deadline=time.monotonic()+5
        while prop('idle-active') is not True and time.monotonic()<deadline:time.sleep(.1)
        assert prop('idle-active') is True, 'Missing-file error did not leave idle player'
        capture(str(home/'missing-file.png'))
        command('quit')
        player.wait(timeout=15)
        assert 'stack traceback' not in log_path.read_text(), log_path.read_text()
        print('PASS: rendered controls, paused auto-hide, pin/focus, keyboard playback, continuous volume dragging, audio shortcut, themed keyboard seeks, speed, mute, full native menu, keybinding browser, fullscreen, three transparency modes.')
      except Exception:
        print(log_path.read_text())
        raise
      finally:
        if producer is not None and producer.poll() is None:
          producer.terminate();producer.wait(timeout=5)
        if player.poll() is None:
          player.terminate()
          player.wait(timeout=5)


if __name__ == '__main__':
  test()
