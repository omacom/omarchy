"""Read Claude's session registry without credentials, transcripts or network IO.

Registry fields are documented by vinzdg/codenotch's ClaudeSessionRecord.swift.
Linux process identity is checked independently through procfs. Unknown states
remain unknown; file age alone never implies that a tool is working or done.
"""

import datetime
import json
import math
import os
from pathlib import Path
import stat


def text(value, limit=160):
  if not isinstance(value, str):
    return ""
  return "".join(c for c in value if c.isprintable())[:limit]


def started_at(record):
  value = record.get("startedAt")
  if isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value):
    return value / 1000
  try:
    return datetime.datetime.strptime(record.get("procStart", ""), "%a %b %d %H:%M:%S %Y").replace(tzinfo=datetime.timezone.utc).timestamp()
  except (TypeError, ValueError, OverflowError):
    return None


def process_matches(record, proc=Path("/proc"), uid=None):
  pid = record.get("pid")
  expected = started_at(record)
  if type(pid) is not int or pid <= 0 or expected is None:
    return False
  try:
    folder = proc / str(pid)
    if folder.stat().st_uid != (os.getuid() if uid is None else uid):
      return False
    # The comm field can contain spaces and parentheses; fields after its last
    # closing parenthesis begin at field 3. starttime is field 22.
    raw = (folder / "stat").read_text()
    fields = raw[raw.rfind(")") + 2:].split()
    if fields[0] in ("Z", "X"):
      return False
    boot = next(int(line.split()[1]) for line in (proc / "stat").read_text().splitlines() if line.startswith("btime "))
    actual = boot + int(fields[19]) / os.sysconf("SC_CLK_TCK")
    if abs(actual - expected) > 300:
      return False
    arguments = [a.decode("utf-8", errors="replace") for a in (folder / "cmdline").read_bytes().split(b"\0")[:2] if a]
    if not arguments:
      return False
    executable = Path(arguments[0]).name
    if executable in ("claude", "claude-code"):
      return True
    return (executable in ("node", "nodejs") and len(arguments) > 1
      and arguments[1].endswith("/@anthropic-ai/claude-code/cli.js"))
  except (OSError, ValueError, IndexError, StopIteration):
    return False


def session(record):
  tempo, status = record.get("tempo"), record.get("status")
  if tempo == "blocked" or status == "waiting":
    state = "waiting"
  elif tempo == "active" or status == "busy":
    state = "working"
  elif tempo == "idle" or status == "idle":
    state = "idle"
  else:
    state = "unknown"
  return {
    "id": "claude." + str(record["pid"]),
    "providerId": "claude",
    "name": text(record.get("name")) or text(Path(record["cwd"]).name) or "Claude Code",
    "state": state,
    "waitingFor": text(record.get("waitingFor") or record.get("needs")) if state == "waiting" else "",
  }


def collect(directory, proc=Path("/proc")):
  found = {}
  try:
    # Bound work even if another tool leaves thousands of old registry files.
    with os.scandir(directory) as entries:
      paths = []
      for index, entry in enumerate(entries):
        if len(paths) >= 256 or index >= 1024:
          break
        if entry.name.endswith(".json") and entry.is_file(follow_symlinks=False):
          paths.append(Path(entry.path))
  except OSError:
    return {"available": False, "sessions": []}
  for path in paths:
    try:
      # O_NOFOLLOW also closes the symlink-swap race after discovery.
      fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
      with os.fdopen(fd, "r") as stream:
        info = os.fstat(stream.fileno())
        if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or info.st_size > 65536:
          continue
        record = json.loads(stream.read(65537))
      if not isinstance(record, dict) or not isinstance(record.get("cwd"), str):
        continue
      if process_matches(record, proc):
        item = session(record)
        found[item["id"]] = item
    except (OSError, ValueError, TypeError, OverflowError):
      continue
  priority = {"waiting": 0, "working": 1, "idle": 2, "unknown": 3}
  return {"available": True, "sessions": sorted(found.values(), key=lambda s: (priority[s["state"]], s["name"], s["id"]))}


if __name__ == "__main__":
  directory = Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude") / "sessions"
  print(json.dumps(collect(directory)))
