#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - "$ROOT" <<'PY'
import importlib.util
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess as sp
import sys
import tempfile
from unittest.mock import patch

root = Path(sys.argv[1]); helper = root / 'default/hypr/monitor-layout.py'
s = importlib.util.spec_from_file_location('layout', helper); m = importlib.util.module_from_spec(s); s.loader.exec_module(m)
monitors = [dict(name='eDP-1', width=1920, height=1080, refreshRate=60, x=0, y=0, scale=1, transform=0)]
desired = m.plan(monitors, 'eDP-1', 2)
with tempfile.TemporaryDirectory() as td:
  d = Path(td); owner = d / 'hypr/monitors.lua'; owner.parent.mkdir(); owner.write_bytes(b'-- owner UTF8 \xe2\x9c\x93\nlocal omarchy_gdk_scale = 2\n')
  with patch.dict(os.environ, dict(XDG_STATE_HOME=td, XDG_RUNTIME_DIR=td)):
    saved = m.state_path(); m.publish_state(saved, m.encode_state(owner.read_bytes(), desired, 'eDP-1'))
    # Run the actual Lua loader without any compositor: data-only decoding,
    # exact baseline invalidation, and no global autoreload mutation.
    lua = shutil.which('lua') or shutil.which('luajit')
    if not lua: raise AssertionError('Lua interpreter required for loader regression')
    code = '''package.path = arg[1] .. '/?.lua;' .. package.path
package.loaded['default.hypr.paths'] = {config_home=arg[2], state_home=arg[2]}
hl = {monitor=function(m) print(m.output .. ':' .. m.scale) end, env=function(k,v) print(k .. ':' .. v) end}
local loader = require('default.hypr.monitor-layout-state')
loader.apply()
'''
    result = sp.run([lua, '-', str(root), td], input=code, text=True, capture_output=True, check=True)
    assert 'eDP-1:2' in result.stdout and 'GDK_SCALE:2' in result.stdout, result
    print('ok - actual Lua loader restores saved geometry/GDK from non-executable UTF8-framed data')
    ordering = code.replace("loader.apply()", """package.loaded['default.hypr.require_all'] = {files=function() hl.monitor({output='eDP-1', scale='disabled-toggle'}) end}
package.loaded['default.hypr.disabled-input-device'] = function() end
package.loaded['default.hypr.workspace-layouts'] = {}
dofile(arg[1] .. '/default/hypr/toggles.lua')""")
    result = sp.run([lua, '-', str(root), td], input=ordering, text=True, capture_output=True, check=True)
    assert result.stdout.index('eDP-1:2') < result.stdout.index('eDP-1:disabled-toggle')
    print('ok - saved geometry loads before explicit disable/mirror/clamshell toggle rules')
    owner.write_bytes(b'-- owner edit after successful publication\n')
    result = sp.run([lua, '-', str(root), td], input=code, text=True, capture_output=True, check=True)
    assert result.stdout == '', result
    print('ok - owner edit after publication invalidates saved layout on next normal config reload')
    owner.write_bytes(b'-- code is not executed from managed state\n')
    m.publish_state(saved, m.encode_state(owner.read_bytes(), desired, 'eDP-1') + b'os.execute("should never execute")\n')
    result = sp.run([lua, '-', str(root), td], input=code, text=True, capture_output=True, check=True)
    assert result.stdout == ''
    print('ok - malformed/code-bearing managed data applies no partial monitor rules')
    # Child process uses production signal contexts and production apply path.
    script = r'''import importlib.util,json,os,signal,subprocess,sys
from pathlib import Path
from unittest.mock import patch
s=importlib.util.spec_from_file_location('layout',sys.argv[1]);m=importlib.util.module_from_spec(s);s.loader.exec_module(m)
p=Path(sys.argv[2]);log=Path(sys.argv[3]);sig=int(sys.argv[4]);where=sys.argv[5]
monitors=[dict(name='eDP-1',width=1920,height=1080,refreshRate=60,x=0,y=0,scale=1,transform=0)]
desired=m.plan(monitors,'eDP-1',2)
def run(args,**kw):
 global queries
 if args[1]=='monitors': queries+=1
 assert kw['timeout']==10
 with log.open('a') as f:f.write(args[1]+'\n')
 if args[1]=='monitors' and queries>1 and where!='publication-cleanup': os.kill(os.getpid(),sig)
 if args[1]=='reload' and where=='cleanup':os.kill(os.getpid(),signal.SIGTERM);os.kill(os.getpid(),signal.SIGHUP)
 out=json.dumps({'bool':False}) if args[1]=='getoption' else json.dumps(monitors if queries==1 else desired) if args[1]=='monitors' else 'ok'
 return subprocess.CompletedProcess(args,0,out,'')
replace=m.os.replace
replacements=0
queries=0
def replaced(src,dst):
 global replacements
 replace(src,dst)
 replacements+=1
 if where=='publication-cleanup':
  os.kill(os.getpid(),sig if replacements==1 else signal.SIGTERM)
  if replacements>1:os.kill(os.getpid(),signal.SIGHUP)
try:
 with patch.object(m.subprocess,'run',run),patch.object(m.os,'replace',replaced):m.apply(monitors,'eDP-1',2,p)
except m.Terminated as e:sys.exit(128+e.signum)
'''
    for sig in (signal.SIGTERM, signal.SIGHUP, signal.SIGINT):
      for where in ('body', 'cleanup', 'publication-cleanup'):
        log = d / 'calls'; log.write_text(''); before = owner.read_bytes(); state = saved.read_bytes()
        result = sp.run([sys.executable, '-c', script, str(helper), str(owner), str(log), str(int(sig)), where], env=dict(os.environ, XDG_STATE_HOME=td, XDG_RUNTIME_DIR=td), timeout=5)
        assert result.returncode in (128+sig, 128+signal.SIGTERM), result
        assert log.read_text().splitlines()[-1] == 'reload'
        assert owner.read_bytes() == before and saved.read_bytes() == state
        print(f'ok - signal {sig}/{where}: current-config recovery completes through repeated signals; owner and saved bytes preserved')
    # Real subprocess deadline, scaled down for a host fixture. No target IPC.
    stub = d / 'hyprctl'; stub.write_text('#!/usr/bin/env python3\nimport time\ntime.sleep(5)\n'); stub.chmod(0o755)
    with patch.dict(os.environ, {'PATH': td + ':' + os.environ['PATH']}), patch.object(m, 'IPC_TIMEOUT', 0.1):
      try: m.ipc('monitors', '-j')
      except sp.TimeoutExpired: pass
      else: raise AssertionError('expected real process timeout')
    print('ok - real hung IPC child is terminated by the common deadline')
PY
