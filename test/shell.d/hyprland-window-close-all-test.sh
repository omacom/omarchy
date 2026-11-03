#!/bin/bash

source "$(dirname "$0")/base-test.sh"
require_command python3
require_command lua

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
import importlib.util, json, os, tempfile
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
    with patch.object(guard,'hypr_json',side_effect=lambda *args:[dict(window) for window in current.values()]), \
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
       patch.object(guard,'hypr_json',return_value=[]), \
       patch.object(guard.subprocess,'Popen') as waiter, \
       patch.object(guard.subprocess,'run',return_value=SimpleNamespace(returncode=0)):
    assert guard.close_all('never',wait=True)==0
    assert not waiter.called,'changed or vanished targets must never start a PID waiter'
  # Exercise the real snapshot and client-list parsing across the prompt.
  current = [dict(window) for window in windows]
  started = {101: '123', 102: '123', 103: '123'}
  def confirm(snapshot, policy):
    current[0]['pid'] = 201
    started[102] = '456'
    return True
  with patch.object(guard.subprocess,'check_output',side_effect=lambda *args,**kwargs:json.dumps(current)) as clients, \
       patch.object(guard,'confirm_exit',side_effect=confirm), \
       patch.object(guard,'process_identity',side_effect=lambda pid:(started[pid],'foot')), \
       patch.object(guard.subprocess,'Popen') as waiter, \
       patch.object(guard.subprocess,'run',return_value=SimpleNamespace(returncode=0)) as run:
    waiter.return_value.wait.return_value = 0
    waiter.return_value.poll.return_value = 0
    assert guard.close_all('always',wait=True)==0
    assert clients.call_count==2+1,'snapshot + post-prompt batch + one surviving-window dispatch check'
    assert all(call.args[0]==['hyprctl','clients','-j'] for call in clients.call_args_list)
    closes=[call.args[0] for call in run.call_args_list if 'window.close' in call.args[0][-1]]
    assert len(closes)==1 and 'address:0xc' in closes[0][-1],'reused address and changed process start must not close'
    assert waiter.call_count==1 and waiter.call_args.args[0][-1]=='103','dropped owners must not be waited on'
  # Closing A reuses B's address while B's original process still survives.
  current = [dict(window) for window in windows]
  def close_and_replace(address):
    if address == '0xa':
      current[1]['pid'] = 202
  with patch.object(guard,'hypr_json',side_effect=lambda *args:[dict(window) for window in current]) as clients, \
       patch.object(guard,'confirm_exit',return_value=True), \
       patch.object(guard,'process_identity',return_value=('123','foot')), \
       patch.object(guard,'dispatch_close',side_effect=close_and_replace) as close, \
       patch.object(guard.subprocess,'run',return_value=SimpleNamespace(returncode=0)):
    assert guard.close_all('always')==0
    assert clients.call_count==2+len(windows),'snapshot + post-prompt batch + one fresh dispatch check per surviving window (N+2)'
    assert [call.args[0] for call in close.call_args_list]==['0xa','0xc'],'B replacement during A dispatch must not close even while B original process survives'
  # A later duplicate must not override the first owner in the prompt batch.
  # A missing address must not prevent the remaining clients from closing.
  replacement = dict(windows[0], pid=201)
  for duplicates in ([], [replacement]):
    batch = [*windows, *duplicates, {'pid':999}]
    with patch.object(guard,'hypr_json',side_effect=[windows, batch, *([windows]*len(windows))]), \
         patch.object(guard,'confirm_exit',return_value=True), \
         patch.object(guard,'process_identity',return_value=('123','foot')), \
         patch.object(guard,'dispatch_close') as close, \
         patch.object(guard.subprocess,'run',return_value=SimpleNamespace(returncode=0)):
      assert guard.close_all('always')==0
      assert [call.args[0] for call in close.call_args_list]==['0xa','0xb','0xc'],'batch lookup must ignore missing addresses and keep the first duplicate'
print('ok - per-window dispatch checks exclude between-dispatch replacements while original owners survive')
print('ok - close-all batches client fetches and excludes replaced owners from closes and waits')
print('ok - aggregate cancellation/timeout have no effects; acceptance closes only unchanged captured windows')
PYTEST

# Checks moved from hyprland-window-close-test.sh.

lua - <<'LUA' || fail "close shortcuts select the terminal guard"
local binds, active, dispatched = {}, nil, nil
local dispatcher = {}
setmetatable(dispatcher, {
  __index = function() return dispatcher end,
  __call = function(_, value) return value end,
})
hl = {
  dsp = dispatcher,
  get_active_window = function() return active end,
  dispatch = function(value) dispatched = value end,
}
o = {
  bind_expressions = {},
  bind = function(key, _, action) binds[key] = action end,
  shell_quote = function(value) return "'" .. value .. "'" end,
  workspaces = dispatcher,
}
dofile(os.getenv("ROOT") .. "/default/hypr/bindings/tiling.lua")
local replay = assert(load("return " .. o.bind_expressions[binds["SUPER + W"]]))()
assert(dispatched == nil, "evaluating the menu expression does not dispatch")
assert(replay == binds["SUPER + W"], "menu factory returns the same dispatcher")
assert(o.bind_expressions[binds["SUPER + W"]] == "o.close_window()", "menu can replay the close callback")
assert(binds["SUPER + W"] == binds["SUPER + Q"], "alternative chords share a dispatcher")
binds["SUPER + W"]()
assert(dispatched == nil, "an empty workspace does not try to close a window")
active = { address = "0xabc", tags = { "terminal*" } }
binds["SUPER + W"]()
assert(dispatched == "omarchy-hyprland-window-close --policy 'conditional' '0xabc'", "capture the terminal address at keypress time")
binds["SUPER + Q"]()
assert(dispatched == "omarchy-hyprland-window-close --policy 'conditional' '0xabc'", "the other close shortcut uses the same guard")
omarchy_terminal_close_confirmation = "always"
assert(load("return " .. o.bind_expressions[binds["SUPER + W"]]))()()
assert(dispatched == "omarchy-hyprland-window-close --policy 'always' '0xabc'", "always policy reaches the guard")
omarchy_terminal_close_confirmation = false
binds["SUPER + W"]()
assert(dispatched.window == "address:0xabc", "opting out restores the direct close")
local before = dispatched
local replay_all = assert(load("return " .. o.bind_expressions[binds["CTRL + ALT + DELETE"]]))()
assert(dispatched == before, "evaluating close-all menu expression does not dispatch")
assert(replay_all == binds["CTRL + ALT + DELETE"], "close-all menu returns the same dispatcher")
omarchy_terminal_close_confirmation = "always"
replay_all()
assert(dispatched == "omarchy-hyprland-window-close-all --policy 'always'", "close-all replay uses current policy")
omarchy_terminal_close_confirmation = nil
active.tags = {}
binds["SUPER + W"]()
assert(dispatched == "omarchy-hyprland-window-close --policy 'conditional' '0xabc'", "custom app IDs reach executable classification")
omarchy_terminal_close_confirmation = "never"
binds["SUPER + W"]()
assert(dispatched.window == "address:0xabc", "never policy closes directly")
LUA
pass "close shortcuts select the terminal guard"

python3 - <<'PY' || fail "terminal close confirmation"
import importlib.util
import atexit
import json
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time
from types import SimpleNamespace
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("terminal_close", Path(os.environ["ROOT"]) / "default/hypr/terminal-close.py")
guard = importlib.util.module_from_spec(spec)
spec.loader.exec_module(guard)
runtime_dir = tempfile.TemporaryDirectory(prefix="omarchy-close-test.")
atexit.register(runtime_dir.cleanup)
os.environ["XDG_RUNTIME_DIR"] = runtime_dir.name

for args in [["foot", "-s/tmp/socket"], ["foot", "-Ls"], ["foot", "--server=/tmp/socket"], ["foot", "-s"], ["foot", "--unknown-option"]]:
  assert guard.server_arguments(args), args
for args in [["foot", "--", "--server"], ["foot", "-e", "bash", "--server"], ["foot", "-a", "--server", "bash"], ["foot", "-a--server", "bash"], ["foot", "--title=--server", "bash"], ["foot", "-lnever", "bash"]]:
  assert not guard.server_arguments(args), args
print("ok - Foot server parsing respects compact options, option values and the command boundary")

# Use an actual shell in a controlling PTY: a child count alone would wrongly
# exempt a directly launched command, a background job, or a noninteractive shell.
terminal = r'''
import json, os, pty, select, signal, sys
pid, master = pty.fork()
if pid == 0:
  args = json.loads(sys.argv[2]) if len(sys.argv) > 2 else ["bash", "-i"]
  os.execve("/bin/bash", args, {"HOME": sys.argv[1], "PATH": "/usr/bin:/bin", "PS1": "READY> ", "TERM": "xterm"})
try:
  output = b""
  while b"READY> " not in output:
    if not select.select([master], [], [], 5)[0]: raise RuntimeError("shell did not start")
    output += os.read(master, 65536)
  print(json.dumps([os.getpid(), pid]), flush=True)
  for line in sys.stdin:
    os.write(master, line.encode())
finally:
  os.killpg(pid, signal.SIGKILL)
  os.waitpid(pid, 0)
  os.close(master)
'''

def eventually(predicate):
  deadline = time.monotonic() + 5
  while time.monotonic() < deadline:
    if predicate(): return
    time.sleep(0.02)
  raise AssertionError("process state did not settle")

with tempfile.TemporaryDirectory() as home:
  proc = subprocess.Popen(["python3", "-c", terminal, home], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
  try:
    parent, shell = json.loads(proc.stdout.readline())
    eventually(lambda: guard.idle_shell(parent))
    proc.stdin.write("read -r answer\n")
    proc.stdin.flush()
    time.sleep(.1)
    assert guard.idle_shell(parent), "conditional mode cannot distinguish an interactive read builtin from a prompt"
    proc.stdin.write("answer\n")
    proc.stdin.flush()
    proc.stdin.write("sleep 60\n")
    proc.stdin.flush()
    eventually(lambda: bool(guard.children(shell)))
    assert not guard.idle_shell(parent), "foreground command needs confirmation"
    assert "sleep" in guard.program_names(parent), "show the running executable"
    assert "60" not in guard.program_names(parent), "do not show command arguments"
    for pid in guard.children(shell): os.kill(pid, signal.SIGTERM)
    eventually(lambda: guard.idle_shell(parent))
    proc.stdin.write("sleep 60 &\n")
    proc.stdin.flush()
    eventually(lambda: bool(guard.children(shell)))
    assert not guard.idle_shell(parent), "background job needs confirmation"
    for pid in guard.children(shell): os.kill(pid, signal.SIGTERM)
    eventually(lambda: guard.idle_shell(parent))
    proc.stdin.write("exec sleep 60\n")
    proc.stdin.flush()
    eventually(lambda: Path(os.readlink(f"/proc/{shell}/exe")).name == "sleep")
    assert not guard.idle_shell(parent), "directly executed command needs confirmation"
  finally:
    proc.stdin.close()
    proc.wait(timeout=5)
  proc = subprocess.Popen(["python3", "-c", terminal, home, json.dumps(["bash", "-c", "printf 'READY> '; read -r line"])], stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
  try:
    parent, shell = json.loads(proc.stdout.readline())
    assert not guard.children(shell), "noninteractive shell is running a builtin, with no child processes"
    assert not guard.idle_shell(parent), "a shell script is not an idle prompt"
  finally:
    proc.stdin.close()
    proc.wait(timeout=5)
assert not guard.idle_shell(999999999), "unknown process state needs confirmation"
print("ok - real PTY distinguishes idle shells, foreground commands, background jobs, and direct commands")

window = {"address": "0xabc", "pid": os.getpid()}

def attempt(selection, current=window, returncode=0, policy="conditional", idle=False):
  # Fake only the desktop boundary. The decision and exact-target dispatch are
  # the production code, and process identity is read from the real test process.
  with patch.object(guard, "find_window", side_effect=[window, window, current]), \
       patch.object(guard.os, "readlink", return_value="/usr/bin/foot"), \
       patch.object(guard, "idle_shell", return_value=idle), \
       patch.object(guard, "translate", side_effect=lambda command, *args: command.split()[-1]), \
       patch.object(guard.subprocess, "run") as run:
    run.return_value = SimpleNamespace(returncode=returncode, stdout=selection)
    guard.close_window("0xabc", policy)
    return run.call_args_list

assert len(attempt("window.keepTerminal")) == 1, "cancel must not dispatch close"
selection = "window.closeTerminal\twindow.terminalProgramsUnknown"
assert len(attempt(selection, returncode=1)) == 1, "menu failure must not close"
assert len(attempt(selection, current=None)) == 1, "vanished window must not close"
assert len(attempt(selection, current={"address":"0xabc", "pid":1})) == 1, "reused address must not close a different process"
calls = attempt(selection)
assert len(calls) == 2 and calls[1].args[0] == ["hyprctl", "dispatch", 'hl.dsp.window.close({ window = "address:0xabc" })'], "confirmation closes the captured window, not the currently focused window"
original = guard.process_stat(os.getpid())
reused = original.copy()
reused[19] = str(int(original[19]) + 1)
with patch.object(guard, "process_stat", side_effect=[original, original, reused]):
  assert len(attempt(selection)) == 1, "PID reuse must invalidate confirmation"
assert len(attempt(selection, policy="always", idle=True)) == 2, "always policy confirms even a shell with no child jobs"
assert len(attempt(selection, policy="never")) == 1, "never policy dispatches without a menu"
assert len(attempt(selection, idle=True)) == 1, "conditional policy exempts the recognizable shell"
with patch.object(guard, "find_window", side_effect=[window, window]), \
     patch.object(guard.os, "readlink", return_value="/usr/bin/ghostty"), \
     patch.object(guard.subprocess, "run") as run:
  guard.close_window("0xabc")
  assert run.call_count == 1 and run.call_args.args[0][0] == "hyprctl", "other terminals keep their native close policy"
with patch.object(guard, "find_window", side_effect=[window, window]), \
     patch.object(guard, "process_identity", return_value=(None, None)), \
     patch.object(guard.subprocess, "run") as run:
  guard.close_window("0xabc")
  assert run.call_count == 1 and run.call_args.args[0][0] == "hyprctl", "unreadable native application process state does not disable closing"
print("ok - cancel, failed menus, vanished windows and replaced processes cannot close a window; approval targets the original window")

# An open prompt suppresses repeats for its own target, while a different window
# can request a prompt and cancel the first through the menu lifecycle contract.
windows = {address: {"address": address, "pid": os.getpid()} for address in ("0xabc", "0xdef")}
menus = []
def pending_menu(args, **kwargs):
  assert args[0] == "omarchy-menu-select"
  menus.append(args)
  if len(menus) == 1:
    guard.close_window("0xabc", "always")
    guard.close_window("0xdef", "always")
  return SimpleNamespace(returncode=124, stdout="")
with patch.object(guard, "find_window", side_effect=lambda address: windows.get(address)), \
     patch.object(guard, "process_identity", return_value=("123", "foot")), \
     patch.object(guard, "program_names", return_value=""), \
     patch.object(guard, "translate", side_effect=lambda command, *args: command.split()[-1]), \
     patch.object(guard.subprocess, "run", side_effect=pending_menu):
  guard.close_window("0xabc", "always")
  assert len(menus) == 2, "repeats are suppressed but other targets are not globally blocked"
  guard.close_window("0xabc", "always")
  assert len(menus) == 3, "a timed-out prompt releases its target lock"
print("ok - pending prompts suppress same-target repeats, permit other targets, and release locks on timeout")
PY
pass "terminal close confirmation"
