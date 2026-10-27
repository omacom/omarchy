#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - "$ROOT" <<'PY'
import importlib.util
import fcntl
import signal
import time
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
s = importlib.util.spec_from_file_location('layout', root / 'default/hypr/monitor-layout.py')
m = importlib.util.module_from_spec(s); s.loader.exec_module(m)
with tempfile.TemporaryDirectory() as td:
  home = Path(td); config = home / '.config/hypr/monitors.lua'; config.parent.mkdir(parents=True)
  config.write_text('hl.monitor({ output = "eDP-1", scale = 2 })\n')
  stubs = home / 'bin'; stubs.mkdir()
  def stub(name, code):
    p = stubs / name
    p.write_text('#!' + sys.executable + '\n' + code)
    p.chmod(0o755)
  stub('omarchy-hyprland-monitor-laptop', 'print("eDP-1")\n')
  stub('omarchy-hw-clamshell', 'raise SystemExit(1)\n')
  stub('omarchy-hyprland-monitor-external-active', 'raise SystemExit(0)\n')
  stub('omarchy-hyprland-monitor-internal-mirror', 'raise SystemExit(0)\n')
  stub('omarchy-hyprland-monitor-internal', '''import errno,fcntl,os
from pathlib import Path
lock=Path(os.environ['XDG_RUNTIME_DIR']) / f'omarchy-monitor-layout-{os.getuid()}.lock'
with lock.open('a') as f:
  try: fcntl.flock(f,fcntl.LOCK_EX|fcntl.LOCK_NB)
  except BlockingIOError: Path(os.environ['HOME'],'lock-witness').write_text('held')
  else: raise RuntimeError('clamshell recovery is outside the writer lock')
''')
  stub('hyprctl', '''import json,os,sys
from pathlib import Path
if sys.argv[1]=='monitors': print(json.dumps([dict(name='eDP-1',disabled=False,scale=1)]))
elif sys.argv[1]=='eval': Path(os.environ['HOME'],'eval').write_text(sys.argv[2])
else: raise RuntimeError(sys.argv)
''')
  env = dict(os.environ, HOME=td, OMARCHY_PATH=str(root), XDG_RUNTIME_DIR=td,
             XDG_STATE_HOME=str(home/'.local/state'), PATH=str(stubs)+':'+os.environ['PATH'])
  os.environ.update({k:env[k] for k in ('XDG_RUNTIME_DIR','XDG_STATE_HOME')})
  def saved(scale):
    rows=[dict(name='eDP-1',width=2560,height=1664,refreshRate=60,x=1536,y=1080,scale=scale,transform=0)]
    m.publish_state(m.state_path(),m.encode_state(config.read_bytes(),rows,'eDP-1'))
  saved(1.6)
  with m.layout_transaction():
    child=subprocess.Popen(['/bin/bash',str(root/'bin/omarchy-hyprland-monitor-clamshell')],env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
    # A waiting reconcile must read the state published before lock handoff.
    saved(2)
  out,err=child.communicate(timeout=10)
  assert child.returncode==0,(out,err)
  assert (home/'lock-witness').read_text()=='held'
  assert 'scale = 2,' in (home/'eval').read_text()
  assert 'position = "1536x1080"' in (home/'eval').read_text()
  print('ok - real clamshell recovery and eval hold the managed-writer lock and consume the record published before handoff')
  # Run the production supervisor with a short fixture deadline. The stalled
  # recovery helper spawns another process, so killing only Bash is insufficient.
  stub('omarchy-hyprland-monitor-internal', """import os,subprocess,sys,time
from pathlib import Path
p=subprocess.Popen([sys.executable,'-c',"import time; time.sleep(0.6); open("+repr(os.environ['HOME']+'/late-write')+",'w').write('stale')"])
Path(os.environ['HOME'],'hung-entered').write_text(str(p.pid))
time.sleep(60)
""")
  from unittest.mock import patch
  real_popen = subprocess.Popen
  def ready_spawn(*args, **kwargs):
    child = real_popen(*args, **kwargs)
    deadline = time.monotonic() + 5
    while not (home/'hung-entered').exists() and time.monotonic() < deadline:
      time.sleep(0.01)
    if not (home/'hung-entered').exists():
      os.killpg(child.pid, signal.SIGKILL)
      child.wait(timeout=5)
      raise AssertionError('hung fixture helper did not start')
    return child
  with patch.dict(os.environ, env), patch.object(m, 'CLAMSHELL_TIMEOUT', 0.3), patch.object(m.subprocess, 'Popen', ready_spawn):
    try: m.reconcile_clamshell()
    except subprocess.TimeoutExpired: pass
    else: raise AssertionError('hung reconciliation accepted')
  assert (home/'hung-entered').exists()
  with (home/f'omarchy-monitor-layout-{os.getuid()}.lock').open('a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
  time.sleep(0.7)
  assert not (home/'late-write').exists()
  print('ok - reconciliation timeout kills stalled helper descendants before releasing the lock to another writer')

  (home/'hung-entered').unlink()
  child=subprocess.Popen([sys.executable,str(root/'default/hypr/monitor-layout.py'),'--clamshell'],env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True)
  for _ in range(500):
    if (home/'hung-entered').exists(): break
    time.sleep(0.02)
  assert (home/'hung-entered').exists()
  child.send_signal(signal.SIGTERM)
  out,err=child.communicate(timeout=5)
  assert child.returncode==128+signal.SIGTERM,(child.returncode,out,err)
  with (home/f'omarchy-monitor-layout-{os.getuid()}.lock').open('a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
  time.sleep(0.7)
  assert not (home/'late-write').exists()
  print('ok - catchable supervisor termination kills helper descendants and releases the writer lock')

  popen = subprocess.Popen
  def terminate_during_spawn(*args, **kwargs):
    child = popen(*args, **kwargs)
    os.kill(os.getpid(), signal.SIGTERM)
    return child
  with patch.dict(os.environ, env), patch.object(m.subprocess, 'Popen', terminate_during_spawn):
    try: m.reconcile_clamshell()
    except m.Terminated: pass
    else: raise AssertionError('spawn-boundary signal lost')
  with (home/f'omarchy-monitor-layout-{os.getuid()}.lock').open('a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
  time.sleep(0.7)
  assert not (home/'late-write').exists()
  print('ok - a signal at process creation is deferred until child cleanup ownership is established')

PY
