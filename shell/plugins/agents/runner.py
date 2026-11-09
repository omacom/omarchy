"""Run the agent usage collectors for omarchy-agent-usage-update.

Every collector used to start as its own Python process, and each one paid
for starting Python and importing collectors.py, about 0.15 CPU-seconds,
before it read anything: 23 times per refresh, on every machine, whether
or not it runs any agent. This process imports the shared module and the
standard library the collectors use once, then forks a child per collector.
The child runs the collector script unchanged, as __main__, with its own
argv, stdout and exit status, so its record is the one it always printed.
A collector that isn't a /usr/bin/python3 script is executed as before.
With more than one collector and without --limits-only, the parent also
calls collectors.preload_shared() first, so what they all read the same
way is read once.

  runner.py USAGE_DIR [--force] [--limits-only] -- AGENT=COLLECTOR ...

The records are handled as omarchy-agent-usage-update always handled them:
a collector that fails, prints nothing, or prints something that isn't JSON
(as `jq -e .` judges it, which also refuses a last value of null or false)
is reported on stderr and its record is left alone. Otherwise the output,
taken as $(...) takes it (NUL bytes and trailing newlines dropped) with one
newline added, replaces USAGE_DIR/AGENT.json through a
temporary file and a rename. The exit status is 1 when any collector failed.
"""

import atexit
import builtins
import importlib
import importlib.machinery
import os
import selectors
import signal
import subprocess
import sys
import tempfile
import threading
import traceback
import types

# What the collectors import, so each child finds it loaded. A module this
# Python lacks is simply left for the collector to import (and fail on) as
# it would have on its own. Nothing here may register an exit handler
# (concurrent.futures does), since each child runs the handlers it inherits.
PRELOAD = (
  "argparse", "base64", "calendar", "collections",
  "configparser", "contextlib", "datetime", "decimal", "fcntl", "hashlib",
  "http.client", "importlib.machinery", "importlib.util", "ipaddress", "math",
  "pathlib", "re", "select", "shutil", "sqlite3", "stat", "subprocess",
  "tempfile", "threading", "time", "tomllib", "typing", "urllib.error",
  "urllib.parse", "urllib.request",
)

PYTHON_SHEBANG = b"#!/usr/bin/python3"


def preload(shared: bool) -> None:
  # The collectors never write bytecode next to their sources; neither does
  # this, so a checkout or a fake OMARCHY_PATH stays as it was.
  sys.dont_write_bytecode = True
  for name in PRELOAD:
    try:
      importlib.import_module(name)
    except Exception:
      pass
  agents = os.path.join(os.environ.get("OMARCHY_PATH", ""), "shell", "plugins", "agents")
  if os.path.isfile(os.path.join(agents, "collectors.py")):
    sys.path.insert(0, agents)
    try:
      collectors = importlib.import_module("collectors")
    except Exception:
      # A collector importing it would fail the same way, in its own child.
      sys.modules.pop("collectors", None)
    else:
      preload_shared = getattr(collectors, "preload_shared", None)
      if shared and callable(preload_shared):
        preload_shared()
    sys.path.remove(agents)


def python_script(path: str) -> bool:
  try:
    with open(path, "rb") as f:
      return f.readline(256).rstrip(b"\r\n") == PYTHON_SHEBANG
  except OSError:
    return False


def exit_status(stop: SystemExit) -> int:
  # The status Python itself gives a script that raised SystemExit.
  code = stop.code
  if code is None:
    return 0
  if isinstance(code, int):
    # Past a C long long CPython exits with -1.
    return code & 0xFF if -2**63 <= code < 2**63 else 255
  print(code, file=sys.stderr)
  return 1


def run_child(path: str, flags: list[str], python: bool) -> None:
  if not python:
    # Python ignores these two signals, and an exec keeps what is ignored;
    # the collector gets them as a shell would have started it.
    for name in ("SIGPIPE", "SIGXFSZ"):
      if hasattr(signal, name):
        signal.signal(getattr(signal, name), signal.SIG_DFL)
    try:
      os.execv(path, [path, *flags])
    except OSError as error:
      print(f"{path}: {error.strerror}", file=sys.stderr)
      os._exit(126)
  sys.argv = [path, *flags]
  sys.path[0] = os.path.dirname(path)
  # The script becomes __main__ as `python3 path` makes it, and stays so
  # while its threads finish and its exit handlers run.
  main = types.ModuleType("__main__")
  main.__file__ = path
  main.__cached__ = None
  main.__loader__ = importlib.machinery.SourceFileLoader("__main__", path)
  main.__builtins__ = builtins
  sys.modules["__main__"] = main
  status = 0
  try:
    with open(path, "rb") as f:
      code = compile(f.read(), path, "exec", dont_inherit=True)
    exec(code, main.__dict__)
  except SystemExit as stop:
    status = exit_status(stop)
  except BaseException as error:
    # The script's own frames, as Python prints them.
    traceback.print_exception(error.with_traceback(error.__traceback__.tb_next))
    status = 1
  # What the interpreter does on the way out before it tears itself down:
  # wait for the script's non-daemon threads, then run its exit handlers.
  # The child then leaves without tearing down what it shares with the
  # runner, which no collector's record depends on.
  try:
    threading._shutdown()
  except Exception:
    traceback.print_exc()
  atexit._run_exitfuncs()
  try:
    sys.stdout.flush()
  except Exception:
    status = status or 120
  try:
    sys.stderr.flush()
  except Exception:
    pass
  os._exit(status)


def valid_json(record: bytes) -> bool:
  # The check omarchy-agent-usage-update always made, by the same program:
  # jq's idea of JSON (it takes NaN, refuses a lone surrogate) is the rule.
  try:
    return subprocess.run(["jq", "-e", "."], input=record, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
  except OSError:
    return False


def store(usage_dir: str, agent: str, record: bytes) -> bool:
  try:
    fd, tmp = tempfile.mkstemp(prefix=f".{agent}.", dir=usage_dir)
  except OSError:
    return False
  try:
    with os.fdopen(fd, "wb") as f:
      f.write(record + b"\n")
    os.replace(tmp, os.path.join(usage_dir, f"{agent}.json"))
  except OSError:
    try:
      os.unlink(tmp)
    except OSError:
      pass
    return False
  return True


def finish(usage_dir: str, agent: str, status: int, output: bytes) -> bool:
  # As $(...) takes it: NUL bytes dropped, then every trailing newline.
  record = output.replace(b"\0", b"").rstrip(b"\n")
  if os.waitstatus_to_exitcode(status) != 0 or not record or not valid_json(record) or not store(usage_dir, agent, record):
    print(f"omarchy-agent-usage-update: {agent} collector failed", file=sys.stderr, flush=True)
    return False
  return True


def main() -> int:
  args = sys.argv[1:]
  if "--" not in args or not args:
    print("usage: runner.py USAGE_DIR [flag...] -- AGENT=COLLECTOR ...", file=sys.stderr)
    return 2
  split = args.index("--")
  usage_dir, flags, jobs = args[0], args[1:split], args[split + 1:]

  # What every collector would read the same way is read here once, when
  # more than one collector will rescan. A --limits-only refresh mostly
  # reuses its scans, and one collector shares with nobody.
  preload("--limits-only" not in flags and len(jobs) > 1)
  sys.stdout.flush()
  sys.stderr.flush()

  # A collector is done once its stdout reached EOF and it exited, in either
  # order: one may close stdout and keep running, or leave a child holding
  # it. Each waits on its own, as each backgrounded collect() did.
  selector = selectors.DefaultSelector()
  inherited: list[int] = []
  polled: list[dict] = []
  for job in jobs:
    agent, _, path = job.partition("=")
    python = python_script(path)
    read_end, write_end = os.pipe()
    pid = os.fork()
    if pid == 0:
      selector.close()
      for fd in inherited:
        os.close(fd)
      os.close(read_end)
      os.dup2(write_end, 1)
      os.close(write_end)
      run_child(path, flags, python)
    os.close(write_end)
    state = {"agent": agent, "pid": pid, "chunks": [], "open": 2, "status": None}
    inherited.append(read_end)
    selector.register(read_end, selectors.EVENT_READ, ("output", state))
    try:
      pidfd = os.pidfd_open(pid)
    except (AttributeError, OSError):
      # Without pidfds (an old kernel, a syscall filter) its exit is polled.
      polled.append(state)
    else:
      inherited.append(pidfd)
      selector.register(pidfd, selectors.EVENT_READ, ("exit", state))

  failed = False

  def done(state: dict) -> None:
    nonlocal failed
    state["open"] -= 1
    if state["open"] == 0 and not finish(usage_dir, state["agent"], state["status"], b"".join(state["chunks"])):
      failed = True

  def close(fd: int, state: dict) -> None:
    selector.unregister(fd)
    os.close(fd)
    inherited.remove(fd)
    done(state)

  while selector.get_map() or polled:
    for key, _ in selector.select(0.05 if polled else None):
      kind, state = key.data
      if kind == "exit":
        state["status"] = os.waitpid(state["pid"], 0)[1]
        close(key.fd, state)
        continue
      chunk = os.read(key.fd, 65536)
      if chunk:
        state["chunks"].append(chunk)
      else:
        close(key.fd, state)
    for state in list(polled):
      pid, status = os.waitpid(state["pid"], os.WNOHANG)
      if pid:
        state["status"] = status
        polled.remove(state)
        done(state)
  return 1 if failed else 0


if __name__ == "__main__":
  raise SystemExit(main())
