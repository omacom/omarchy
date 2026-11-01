#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command python3
require_command lua

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
  bind = function(key, _, action) binds[key] = action end,
  shell_quote = function(value) return "'" .. value .. "'" end,
  workspaces = dispatcher,
}
dofile(os.getenv("ROOT") .. "/default/hypr/bindings/tiling.lua")
binds["SUPER + W"]()
assert(dispatched == nil, "an empty workspace does not try to close a window")
active = { address = "0xabc", tags = { "terminal*" } }
binds["SUPER + W"]()
assert(dispatched == "omarchy-hyprland-window-close '0xabc'", "capture the terminal address at keypress time")
binds["SUPER + Q"]()
assert(dispatched == "omarchy-hyprland-window-close '0xabc'", "the other close shortcut uses the same guard")
omarchy_terminal_close_confirmation = false
binds["SUPER + W"]()
assert(dispatched.window == "address:0xabc", "opting out restores the direct close")
omarchy_terminal_close_confirmation = nil
active.tags = {}
binds["SUPER + W"]()
assert(dispatched.window == "address:0xabc", "ordinary GUI apps close directly")
LUA
pass "close shortcuts select the terminal guard"

python3 - <<'PY' || fail "terminal close confirmation"
import importlib.util
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

def attempt(selection, current=window, returncode=0):
  # Fake only the desktop boundary. The decision and exact-target dispatch are
  # the production code, and process identity is read from the real test process.
  with patch.object(guard, "find_window", side_effect=[window, current]), \
       patch.object(guard.os, "readlink", return_value="/usr/bin/foot"), \
       patch.object(guard, "translate", side_effect=lambda command, *args: command.split()[-1]), \
       patch.object(guard.subprocess, "run") as run:
    run.return_value = SimpleNamespace(returncode=returncode, stdout=selection)
    guard.close_window("0xabc")
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
with patch.object(guard, "process_stat", side_effect=[original, reused]):
  assert len(attempt(selection)) == 1, "PID reuse must invalidate confirmation"
with patch.object(guard, "find_window", side_effect=[window, window]), \
     patch.object(guard.os, "readlink", return_value="/usr/bin/ghostty"), \
     patch.object(guard.subprocess, "run") as run:
  guard.close_window("0xabc")
  assert run.call_count == 1 and run.call_args.args[0][0] == "hyprctl", "other terminals keep their native close policy"
print("ok - cancel, failed menus, vanished windows and replaced processes cannot close a window; approval targets the original window")
PY
pass "terminal close confirmation"
