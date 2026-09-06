import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile

spec = importlib.util.spec_from_file_location("sessions", Path(sys.argv[1]) / "shell/plugins/agents/sessions.py")
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

with tempfile.TemporaryDirectory() as tmp:
  root = Path(tmp)
  proc = root / "proc"
  process = proc / "42"
  process.mkdir(parents=True)
  (proc / "stat").write_text("btime 1000\n")
  fields = ["S"] + ["0"] * 18 + [str(os.sysconf("SC_CLK_TCK") * 10)]
  (process / "stat").write_text("42 (claude (worker)) " + " ".join(fields))
  (process / "cmdline").write_bytes(b"/usr/bin/claude\0")
  record = {"pid":42, "cwd":"/work/project", "startedAt":1010000, "status":"waiting", "waitingFor":"Approval"}
  assert module.process_matches(record, proc)
  assert not module.process_matches({**record, "startedAt":2000000}, proc), "reused pid"
  assert not module.process_matches({**record, "pid":True}, proc), "boolean pid"
  assert not module.process_matches({**record, "startedAt":None}, proc), "identity without start time"
  assert not module.process_matches(record, proc, os.getuid() + 1), "other user"
  assert module.session(record)["state"] == "waiting"
  assert module.session({**record, "status":"future-state"})["state"] == "unknown"
  assert module.session({**record, "status":"busy"})["state"] == "working"
  assert module.session({**record, "status":"idle"})["state"] == "idle"
  directory = root / "sessions"
  directory.mkdir()
  (directory / "42.json").write_text(json.dumps(record))
  (directory / "broken.json").write_text("{")
  (directory / "oversized.json").write_text(" " * 65537)
  (directory / "link.json").symlink_to(directory / "42.json")
  result = module.collect(directory, proc)
  assert result["available"] and len(result["sessions"]) == 1
  assert result["sessions"][0]["name"] == "project"
  assert "cwd" not in result["sessions"][0], "full working directory is not exported"
  (process / "cmdline").write_bytes(b"/usr/bin/unrelated\0")
  assert not module.collect(directory, proc)["sessions"], "unrelated live pid must not resurrect session"
  (process / "cmdline").write_bytes(b"/usr/bin/echo\0claude\0")
  assert not module.process_matches(record, proc), "a command argument is not the agent executable"
  (process / "cmdline").write_bytes(b"/usr/bin/node\0/opt/node_modules/@anthropic-ai/claude-code/cli.js\0")
  assert module.process_matches(record, proc), "npm CLI entrypoint"
  (process / "cmdline").write_bytes(b"/usr/bin/claude\0")
  fields[0] = "Z"
  (process / "stat").write_text("42 (claude) " + " ".join(fields))
  assert not module.collect(directory, proc)["sessions"], "zombie is not working"
  assert not module.collect(root / "missing", proc)["available"]

print("ok - session registry handles identity, unknown states, malformed files and dead processes")
