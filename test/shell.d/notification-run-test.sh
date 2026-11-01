#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - <<'PYTEST' || fail "command completion notifications"
import importlib.util,json,os,pathlib,signal,subprocess,sys,tempfile,time
from types import SimpleNamespace
from unittest.mock import patch
root=pathlib.Path(os.environ['ROOT'])
with tempfile.TemporaryDirectory(prefix='omarchy-notify-test.') as scratch:
  scratch=pathlib.Path(scratch)
  stub=scratch/'omarchy-notification-send'
  stub.write_text("""#!/usr/bin/python3
import json,os,pathlib,sys
pathlib.Path(os.environ['NOTIFY_TEST_RESULT']).write_text(json.dumps(sys.argv[1:]))
raise SystemExit(int(os.environ.get('NOTIFY_TEST_FAIL','0')))
""")
  stub.chmod(0o755)
  result=scratch/'notification.json'
  env={**os.environ,'PATH':str(scratch)+':'+str(root/'bin')+':'+os.environ['PATH'],'NOTIFY_TEST_RESULT':str(result),'OMARCHY_PATH':str(root)}
  wrapper=[str(root/'bin/omarchy-notification-run')]
  def run(command,**kwargs):
    return subprocess.run(wrapper+command,env=kwargs.pop('env',env),capture_output=True,text=True,timeout=8,**kwargs)
  literal='$(touch '+str(scratch/'should-not-exist')+'); "quoted"'
  proc=run(['--title','Build','--','python3','-c','import sys;print(sys.stdin.read());print(sys.argv[1]);print("stderr",file=sys.stderr)',literal],input='stdin remains available')
  assert proc.returncode==0 and 'stdin remains available' in proc.stdout and literal in proc.stdout,proc
  assert proc.stderr.strip()=='stderr',proc
  assert not (scratch/'should-not-exist').exists()
  notification=json.loads(result.read_text())
  assert notification[0]=='Build' and 'python3' in notification[1] and 'exit 0' in notification[1],notification
  assert literal not in str(notification),'arguments must not appear in automatic notification text'
  proc=run(['--','python3','-c','raise SystemExit(7)'])
  assert proc.returncode==7 and 'exit 7' in json.loads(result.read_text())[1],proc
  proc=run(['--','python3','-c','raise SystemExit(9)'],env={**env,'NOTIFY_TEST_FAIL':'42'})
  assert proc.returncode==9,'notification failure must preserve command status'
  proc=run(['--','python3','-c','pass'],env={**env,'NOTIFY_TEST_FAIL':'42'})
  assert proc.returncode==0,'notification failure must preserve command success'
  proc=run(['--',str(scratch/'missing-command')])
  assert proc.returncode==127,proc
  assert 'exit 127' in json.loads(result.read_text())[1]
  result.unlink()
  marker=scratch/'running'
  proc=subprocess.Popen(wrapper+['--','python3','-c','import pathlib,signal,sys;pathlib.Path(sys.argv[1]).touch();signal.pause()',str(marker)],env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE,text=True,start_new_session=True)
  try:
    deadline=time.monotonic()+5
    while not marker.exists():
      assert time.monotonic()<deadline
      time.sleep(.02)
    # A private process group simulates terminal Ctrl+C without sending input
    # to any real terminal or signalling the user's shell.
    os.killpg(proc.pid,signal.SIGINT)
    output,error=proc.communicate(timeout=5)
    assert proc.returncode==130,(proc.returncode,output,error)
    assert not result.exists(),'Ctrl+C must not emit a completion alert'
  finally:
    if proc.poll() is None:os.killpg(proc.pid,signal.SIGKILL);proc.wait()
spec=importlib.util.spec_from_file_location('notify_run',root/'default/notification-run.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
for sig in (signal.SIGINT,signal.SIGTERM):
  def interrupt_translation(command,*args):
    signal.raise_signal(sig)
    return 'translated'
  with patch.object(sys,'argv',['notify','--','example']), \
       patch.object(module.subprocess,'Popen',return_value=SimpleNamespace(wait=lambda:0)), \
       patch.object(module,'translate',side_effect=interrupt_translation), \
       patch.object(module.subprocess,'run') as deliver:
    assert module.main()==0,'post-command cancellation must preserve the completed status'
    assert not deliver.called,'interruption during localization must suppress delivery'
print('ok - literal argv, inherited streams, command status, notification failure, Ctrl+C and localization cancellation')
PYTEST
pass "command completion notifications"
