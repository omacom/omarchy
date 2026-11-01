#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
hyprctl_log="$test_tmp/hyprctl.log"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "clients" ]]; then
  default_clients='[{"address":"0xabc"},{"address":"0xdef"}]'
  printf '%s\n' "${TEST_CLIENTS:-$default_clients}"
else
  printf '%s\n' "$*" >>"$HYPRCTL_LOG"
fi
SH
chmod +x "$mock_bin/hyprctl"

PATH="$mock_bin:$PATH" HYPRCTL_LOG="$hyprctl_log" "$ROOT/bin/omarchy-hyprland-window-close-all"

expected_log="$test_tmp/expected.log"
cat >"$expected_log" <<'EOF'
dispatch hl.dsp.window.close({ window = "address:0xabc" })
dispatch hl.dsp.window.close({ window = "address:0xdef" })
dispatch o.workspaces.focus(1)
EOF

diff -u "$expected_log" "$hyprctl_log" || fail "close-all targets each window with the Lua dispatcher"
pass "close-all targets each window with the Lua dispatcher"

export PATH="$mock_bin:$PATH" HYPRCTL_LOG="$hyprctl_log"
sleep 0.2 &
first_pid=$!
sleep 0.4 &
second_pid=$!
export TEST_CLIENTS="[{\"address\":\"0xabc\",\"pid\":$first_pid},{\"address\":\"0xdef\",\"pid\":$second_pid},{\"address\":\"0x123\",\"pid\":$first_pid}]"
timeout 1s "$ROOT/bin/omarchy-hyprland-window-close-all" --wait || fail "waiting succeeds"
! kill -0 "$first_pid" 2>/dev/null || fail "wait includes first application"
! kill -0 "$second_pid" 2>/dev/null || fail "wait includes last application"
pass "wait follows application exits, including multiple windows from one process"

# A desktop without clients must not start an unfiltered process wait.
TEST_CLIENTS='[]' timeout 1s "$ROOT/bin/omarchy-hyprland-window-close-all" --wait || fail "empty desktop exits immediately"
pass "empty desktop exits immediately"

TEST_CLIENTS="[{\"address\":\"0xabc\",\"pid\":$first_pid},{\"address\":\"0xdef\",\"pid\":0},{\"address\":\"0x123\"}]" timeout 1s "$ROOT/bin/omarchy-hyprland-window-close-all" --wait || fail "already exited and missing PIDs succeed"
pass "already exited and missing PIDs succeed"

python3 - <<'PYTEST' || fail "aggregate confirmation and snapshot safety"
import importlib.util, os, tempfile
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch
spec=importlib.util.spec_from_file_location('guard',Path(os.environ['ROOT'])/'default/hypr/terminal-close.py')
guard=importlib.util.module_from_spec(spec);spec.loader.exec_module(guard)
windows=[{'address':address,'pid':pid,'title':'Terminal '+address} for address,pid in [('0xa',101),('0xb',102),('0xc',103)]]
with tempfile.TemporaryDirectory() as runtime, patch.dict(os.environ,{'XDG_RUNTIME_DIR':runtime}):
  def exercise(accept,returncode=0):
    current={w['address']:dict(w) for w in windows}
    calls=[]
    def run(args,**kwargs):
      calls.append(args)
      if args[0]=='omarchy-menu-select':
        if accept:
          del current['0xa']
          current['0xb']['pid']=202
          current['0xd']={'address':'0xd','pid':104}
        return SimpleNamespace(returncode=returncode,stdout=args[3].lstrip('\t') if accept else '')
      return SimpleNamespace(returncode=0)
    with patch.object(guard,'hypr_json',return_value=windows), \
         patch.object(guard,'find_window',side_effect=lambda address:current.get(address)), \
         patch.object(guard,'process_identity',return_value=('123','foot')), \
         patch.object(guard,'program_names',return_value='codex'), \
         patch.object(guard,'translate',side_effect=lambda command,*args:command.split()[-1]), \
         patch.object(guard.subprocess,'run',side_effect=run), \
         patch.object(guard.subprocess,'Popen') as waiter:
      status=guard.close_all('always')
      assert not waiter.called
      return status,calls
  status,calls=exercise(False)
  assert status==1 and len(calls)==1,'cancellation must not close, focus or start a waiter'
  status,calls=exercise(True,124)
  assert status==1 and len(calls)==1,'a timeout must not authorize any action'
  status,calls=exercise(True)
  assert status==0
  assert sum(args[0]=='omarchy-menu-select' for args in calls)==1,'warn once for all protected terminals'
  closes=[args for args in calls if args[0]=='hyprctl' and 'window.close' in args[-1]]
  assert len(closes)==1 and 'address:0xc' in closes[0][-1],closes
  assert not any('address:0xd' in str(args) for args in calls),'new windows are outside the approved snapshot'
  with patch.object(guard,'window_snapshot',return_value=[(windows[0],'123','foot')]), \
       patch.object(guard,'same_window',return_value=False), \
       patch.object(guard.subprocess,'Popen') as waiter, \
       patch.object(guard.subprocess,'run',return_value=SimpleNamespace(returncode=0)):
    assert guard.close_all('never',wait=True)==0
    assert not waiter.called,'changed or vanished targets must never start a PID waiter'
print('ok - aggregate cancellation/timeout have no effects; acceptance closes only unchanged captured windows')
PYTEST
