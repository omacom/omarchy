#!/usr/bin/env python3
"""Exercise controller state and input contracts in an isolated real mpv window."""
import json
import os
from pathlib import Path
import runpy
import shutil
import socket
import subprocess
import tempfile
import time

ROOT=Path(__file__).resolve().parents[3]
OMARCHY=Path(os.environ['OMARCHY_PATH'])
CONFIG=OMARCHY/'config/mpv'
GENERATOR=ROOT/'test/shell.d/fixtures/mpv/palette.py'


def test():
  with tempfile.TemporaryDirectory(prefix='mpv-parity-') as temporary:
    home=Path(temporary)
    config=home/'config'
    shutil.copytree(CONFIG,config)
    if os.environ.get('MPV_PARITY_CONTROLLER'):
      shutil.copyfile(os.environ['MPV_PARITY_CONTROLLER'],config/'scripts/omarchy-controls.lua')
    with (config/'mpv.conf').open('a') as stream:
      stream.write('\n[margin-test]\nsub-margin-y=77\n')
    (config/'input.conf').write_text('WHEEL_UP set volume 33\nWHEEL_DOWN set volume 44\n')
    generator=runpy.run_path(str(GENERATOR))
    palette=home/'palette.conf'
    palette.write_text(generator['generate'](home/'render',OMARCHY/'themes/nord/colors.toml', OMARCHY))
    fixture=home/'fixture.mkv'
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','lavfi','-i',
            'testsrc2=size=640x360:rate=12','-f','lavfi','-i','anullsrc=channel_layout=stereo:sample_rate=48000','-map','0:v','-map','1:a','-c:a','aac','-t','60','-c:v','libx264','-preset','ultrafast',
            '-g','120','-crf','30',str(fixture)],check=True)
    subtitle=home/'review.srt'
    subtitle.write_text('1\n00:00:00,000 --> 00:01:00,000\nSubtitle spacing review\n')
    second=home/'second.mkv'
    shutil.copyfile(fixture,second)
    ipc=home/'ipc.sock'
    logpath=home/'mpv.log'
    with logpath.open('w') as log:
      player=subprocess.Popen(['mpv',f'--config-dir={config}',f'--input-ipc-server={ipc}',
        f'--script-opts=omarchy-theme-theme_file={palette},omarchy-controls-debug=yes,omarchy-controls-visibility=never',f'--sub-file={subtitle}',
        '--sub-margin-y=34','--pause=yes','--ao=null','--idle=yes','--keep-open=yes',
        f'--vo={os.environ.get("MPV_ACCEPTANCE_VO", "gpu-next")}',
        '--geometry=800x600','--title=mpv parity verification',str(fixture)],
        stdout=log,stderr=subprocess.STDOUT)
      producer=None
      def stop(process):
        if process and process.poll() is None:
          process.terminate()
          try:process.wait(timeout=5)
          except subprocess.TimeoutExpired:process.kill();process.wait(timeout=5)
      try:
        deadline=time.monotonic()+15
        while not ipc.exists() and time.monotonic()<deadline:
          assert player.poll() is None,logpath.read_text()
          time.sleep(.05)
        client=socket.socket(socket.AF_UNIX)
        client.settimeout(10)
        client.connect(str(ipc))
        reader=client.makefile('r')
        request=0
        def command(*args):
          nonlocal request
          request+=1
          client.sendall((json.dumps({'command':args,'request_id':request})+'\n').encode())
          while True:
            reply=json.loads(reader.readline())
            if reply.get('request_id')==request:
              if args[0]=='get_property' and reply['error'] in ('property unavailable','property not found'):return None
              assert reply['error']=='success',reply
              return reply.get('data')
        def prop(name):return command('get_property',name)
        def wait(name,value,timeout=6):
          deadline=time.monotonic()+timeout
          while time.monotonic()<deadline:
            if prop(name)==value:return
            time.sleep(.05)
          current=prop(name)
          if current==value:return
          raise AssertionError(f'{name}: expected {value!r}, got {current!r}')
        def load(path):
          generation=prop('user-data/omarchy/file-generation') or 0
          command('loadfile',str(path))
          wait('user-data/omarchy/file-generation',generation+1,15)
        def mode(value):
          command('script-message-to','omarchy_controls','osc-visibility',value)
          wait('user-data/omarchy/visibility-mode',value)
        def layout():return prop('user-data/omarchy/layout')
        def region(name):
          return next(r for r in prop('user-data/omarchy/control-regions') if r['id']==name)
        def point(name,fraction=.5):
          r=region(name);scale=layout()['scale']
          return round((r['x']+r['w']*fraction)*scale),round((r['y']+r['h']/2)*scale)
        def move(name,fraction=.5):command('mouse',*point(name,fraction));time.sleep(.08)
        def capture(name):
          out=os.environ.get('OMARCHY_ACCEPTANCE_DIR') or os.environ.get('MPV_TEST_SCREENSHOTS')
          if out:
            Path(out).mkdir(parents=True,exist_ok=True)
            time.sleep(.3)
            command('screenshot-to-file',str(Path(out)/f'parity-{name}.png'),'window')
        for _ in range(60):
          windows=json.loads(subprocess.check_output(['hyprctl','clients','-j']))
          if any(w['pid']==player.pid for w in windows):
            follow='true' if os.environ.get('OMARCHY_ACCEPTANCE_DIR') else 'false'
            subprocess.run(['hyprctl','eval',f'local w=hl.get_window("pid:{player.pid}"); assert(w); hl.dispatch(hl.dsp.window.move({{window=w,workspace="3",follow={follow}}}))'],check=True,stdout=subprocess.DEVNULL)
            break
          time.sleep(.05)
        wait('user-data/omarchy/file-active',True)
        wait('user-data/omarchy/visibility-mode','never')
        wait('user-data/omarchy/controls-visible',False)
        mode('always');wait('user-data/omarchy/controls-visible',True)
        time.sleep(.3)
        mode('never');wait('user-data/omarchy/controls-visible',False)
        command('keypress','RIGHT');command('set_property','volume',42)
        command('mouse',100,prop('osd-dimensions')['h']-20)
        time.sleep(.3)
        assert prop('user-data/omarchy/controls-visible') is False
        load(second)
        wait('user-data/omarchy/file-active',True)
        assert prop('user-data/omarchy/controls-visible') is False
        mode('auto');command('keypress','DEL');wait('user-data/omarchy/visibility-mode','always')
        command('keypress','DEL');wait('user-data/omarchy/visibility-mode','never')
        command('keypress','DEL');wait('user-data/omarchy/visibility-mode','auto')
        command('keybind','DEL','set volume 51')
        command('keypress','DEL');wait('volume',51)
        assert prop('user-data/omarchy/visibility-mode')=='auto'
        mode('always')
        command('keypress','a');wait('user-data/mpv/console/open',True)
        command('keypress','ESC');wait('user-data/mpv/console/open',False)
        assert prop('user-data/omarchy/visibility-mode')=='always'
        wait('user-data/omarchy/controls-visible',True)
        # The native menu and appearance controls have separate hitboxes.
        move('menu');command('keydown','MBTN_LEFT');time.sleep(.1);command('keyup','MBTN_LEFT')
        wait('user-data/mpv/console/open',True)
        capture('native-menu')
        command('keypress','ESC');wait('user-data/mpv/console/open',False)
        wait('user-data/omarchy/controls-visible',True)
        move('appearance');command('keydown','MBTN_LEFT');time.sleep(.1);command('keyup','MBTN_LEFT')
        wait('user-data/mpv/console/open',True)
        capture('appearance-menu')
        command('keypress','ENTER');time.sleep(.2)
        capture('theme-menu')
        for character in 'Flexoki':command('keypress',character)
        command('keypress','ENTER');wait('user-data/omarchy/theme-selection','flexoki-light')
        wait('user-data/mpv/console/open',False)
        command('script-message','set-omarchy-theme','automatic')
        wait('user-data/omarchy/theme-selection','automatic')
        # Appearance > Toolbar background still offers all three modes.
        for expected in ('solid','translucent','gradient'):
          command('script-binding','omarchy_controls/appearance-menu');wait('user-data/mpv/console/open',True)
          command('keypress','DOWN');command('keypress','ENTER');time.sleep(.2)
          capture('transparency-menu')
          search={'solid':'Opaque','translucent':'Translucent','gradient':'Gradient'}[expected]

          for character in search:command('keypress',character)
          time.sleep(.15)
          command('keypress','ENTER');wait('user-data/omarchy/surface-mode',expected)
          wait('user-data/mpv/console/open',False)
          assert prop('user-data/omarchy/visibility-mode')=='always'
        command('keypress','Ctrl+F9');wait('user-data/omarchy/surface-mode','solid')
        command('keypress','Ctrl+F9');wait('user-data/omarchy/surface-mode','translucent')
        command('keypress','Ctrl+F9');wait('user-data/omarchy/surface-mode','gradient')
        mode('never');wait('user-data/omarchy/controls-visible',False)
        command('set_property','sub-margin-y',88);wait('sub-margin-y',88)
        mode('always');wait('user-data/omarchy/subtitle-margin-base',88)
        deadline=time.monotonic()+6
        while (prop('sub-margin-y') or 0)<=88 and time.monotonic()<deadline:time.sleep(.05)
        capture('subtitles-visible')
        assert prop('sub-margin-y')>88, {k:prop(k) for k in ['sub-margin-y','sub-pos','sub-align-y','user-data/omarchy/file-active','user-data/omarchy/controls-visible']}
        command('set_property','sub-margin-y',60);wait('user-data/omarchy/subtitle-margin-base',60)
        mode('never');wait('sub-margin-y',60)
        command('apply-profile','margin-test');wait('sub-margin-y',77)
        mode('always');wait('user-data/omarchy/subtitle-margin-base',77)
        command('set_property','sub-pos',50);wait('sub-margin-y',77)
        command('set_property','sub-pos',100);time.sleep(.2)
        mode('always');time.sleep(.3)
        stable_margin=prop('sub-margin-y');stable_count=prop('user-data/omarchy/render-count')
        time.sleep(1.2)
        assert prop('sub-margin-y')==stable_margin,'Fractional scale compounded the subtitle margin'
        assert prop('user-data/omarchy/render-count')-stable_count<=2,'Visible paused UI entered a property feedback loop'
        mode('never');wait('sub-margin-y',77)
        time.sleep(.3)
        results={'visible_paused_margin':stable_margin,'visible_paused_extra_renders':prop('user-data/omarchy/render-count')-stable_count}
        count=prop('user-data/omarchy/render-count');time.sleep(1.2)
        assert prop('user-data/omarchy/render-count')==count,'Hidden paused UI kept redrawing'
        results['hidden_paused_renders']={'before':count,'after':prop('user-data/omarchy/render-count'),'interval_seconds':1.2}
        mode('always');time.sleep(.2)
        command('mouse',*point('play'),0,'double');time.sleep(.2)
        assert prop('fullscreen') is False,'Double-click on control toggled fullscreen'
        dims=prop('osd-dimensions')
        command('mouse',dims['w']//2,dims['h']//2,0,'double');wait('fullscreen',True)
        command('set_property','fullscreen',False);time.sleep(.3)
        command('set_property','pause',True)
        command('seek',0,'absolute+exact');time.sleep(.2)
        mode('always');wait('user-data/omarchy/seek-enabled',True)
        move('seek',.2);command('keydown','MBTN_LEFT');time.sleep(.1)
        wait('user-data/omarchy/dragging','seek')
        count=prop('user-data/omarchy/seek-requests')
        for _ in range(5):move('seek',.2)
        assert prop('user-data/omarchy/seek-requests')==count,'Repeated seek target was not coalesced'
        move('seek',.55);command('keyup','MBTN_LEFT');wait('user-data/omarchy/dragging',False)
        deadline=time.monotonic()+5
        while abs((prop('time-pos') or 0)-33)>.3 and time.monotonic()<deadline:time.sleep(.05)
        assert abs(prop('time-pos')-33)<.3,'Drag release did not commit exact final position'
        results['seek_drag']={'requests_before_stationary_moves':count,'requests_after_drag_release':prop('user-data/omarchy/seek-requests'),'exact_position':prop('time-pos')}
        move('volume-slider',.2);command('keydown','MBTN_LEFT');wait('user-data/omarchy/dragging','volume-slider')
        load(fixture);wait('user-data/omarchy/dragging',False)
        command('keyup','MBTN_LEFT');time.sleep(.3)
        move('volume-slider',.3);command('keydown','MBTN_LEFT');wait('user-data/omarchy/dragging','volume-slider')
        dims=prop('osd-dimensions');command('mouse',dims['w']+50,dims['h']+50)
        command('keyup','MBTN_LEFT');wait('user-data/omarchy/dragging',False)
        # Find actual empty toolbar space and exercise the user's wheel mapping there.
        info=layout();rs=prop('user-data/omarchy/control-regions');y=info['height']-30
        x=next(x for x in range(10,int(info['width'])-10,5)
           if not any(r['x']<=x<=r['x']+r['w'] and r['y']<=y<=r['y']+r['h'] for r in rs))
        command('mouse',round(x*info['scale']),round(y*info['scale']));command('keypress','WHEEL_UP');wait('volume',33)
        command('mouse',round(info['width']*info['scale']/2),round(info['height']*info['scale']/2))
        command('keypress','WHEEL_DOWN');wait('volume',44)
        capture('state-and-input')
        # Uncached FIFO has a buffered duration estimate, but no valid seek target.
        fifo=home/'live.ts';os.mkfifo(fifo)
        command('set_property','cache','no')
        producer=subprocess.Popen(['ffmpeg','-hide_banner','-loglevel','error','-y','-re','-f','lavfi','-i',
          'testsrc2=size=640x360:rate=12','-c:v','mpeg2video','-f','mpegts',str(fifo)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        load(fifo)
        wait('seekable',False)
        time.sleep(.5)
        wait('user-data/omarchy/seek-enabled',False)
        capture('nonseekable-live')
        results['uncached_live']={'seekable':prop('seekable'),'duration_estimate':prop('duration'),'controller_seek_enabled':prop('user-data/omarchy/seek-enabled')}
        load(fixture);wait('user-data/omarchy/seek-enabled',True)
        producer.wait(timeout=10)
        cached_fifo=home/'cached-live.ts';os.mkfifo(cached_fifo)
        command('set_property','cache','yes')
        producer=subprocess.Popen(['ffmpeg','-hide_banner','-loglevel','error','-y','-re','-f','lavfi','-i',
          'testsrc2=size=640x360:rate=12','-c:v','mpeg2video','-f','mpegts',str(cached_fifo)],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
        load(cached_fifo);wait('seekable',False)
        deadline=time.monotonic()+12
        while not (prop('demuxer-cache-state') or {}).get('seekable-ranges') and time.monotonic()<deadline:time.sleep(.1)
        assert (prop('demuxer-cache-state') or {}).get('seekable-ranges'), 'Live cache did not expose buffered ranges'
        wait('user-data/omarchy/seek-enabled',True)
        deadline=time.monotonic()+6
        while time.monotonic()<deadline:
          try:
            region('seek')
            break
          except StopIteration:
            time.sleep(.05)
        else:
          raise AssertionError('Cached seek was enabled but its seek control region was not published')
        window=prop('user-data/omarchy/seek-window')
        assert window and window.get('ranges'), 'Live source was treated as a fully seekable file'
        results['cached_live_seek_window']=window
        move('seek',.5);command('keydown','MBTN_LEFT');time.sleep(.15);command('keyup','MBTN_LEFT')
        wait('user-data/omarchy/dragging',False)
        target=prop('user-data/omarchy/seek-target')
        deadline=time.monotonic()+6
        while abs((prop('time-pos') or 0)-target)>.3 and time.monotonic()<deadline:time.sleep(.05)
        assert abs(prop('time-pos')-target)<.3,'Cached live stream did not seek to its selected buffered position'
        results['cached_live_position']={'target':target,'actual':prop('time-pos')}
        capture('cached-live')
        load(fixture);wait('user-data/omarchy/seek-enabled',True)
        mode('never');wait('sub-margin-y',77)
        report=os.environ.get('MPV_PARITY_REPORT')
        if report:Path(report).write_text(json.dumps(results,indent=2)+'\n')
        command('quit');player.wait(timeout=10)
        assert 'stack traceback' not in logpath.read_text(),logpath.read_text()
        print('PASS: persistent visibility, native Delete/user override, menu pin, subtitle/profile preservation, hidden idle, double-clicks, exact/coalesced drag, file/release cleanup, wheel passthrough and live seekability.')
      except Exception:
        print(logpath.read_text())
        raise
      finally:
        stop(producer)
        stop(player)

if __name__=='__main__':test()
