import json
import os
import time
from datetime import datetime
from pathlib import Path

KEEP = 8
TEXT_LIMIT = 160
DEFAULT_APPS = "chatgpt,grok,muse"


def state_paths():
  home = Path(os.environ["HOME"])
  configured = os.environ.get("XDG_STATE_HOME")
  root = Path(configured) if configured else home / ".local" / "state"
  state = root / "omarchy" / "agent-comms"
  return {
    "state": state,
    "inbox": state / "inbox.jsonl",
    "feed": state / "feed.json",
    "lock": state / ".feed.lock",
    "notes": root / "omarchy" / "notifications" / "history",
  }


def parse_apps(raw):
  apps = []
  for part in str(raw or "").split(","):
    name = part.strip().lower()
    if name and name not in apps:
      apps.append(name)
  return tuple(apps)


def stamp(value):
  if isinstance(value, bool):
    return 0
  if isinstance(value, (int, float)):
    number = float(value)
    if number > 1e12:
      number /= 1000.0
    return number
  if isinstance(value, str) and value:
    try:
      return stamp(float(value))
    except ValueError:
      pass
    try:
      return datetime.fromisoformat(value.replace("Z", "+00:00")).timestamp()
    except ValueError:
      return 0
  return 0


def clip(text):
  flat = " ".join(str(text or "").split())
  if len(flat) <= TEXT_LIMIT:
    return flat
  return flat[: TEXT_LIMIT - 1].rstrip() + "..."


def item(agent, role, text, ts):
  message = clip(text)
  if not message:
    return None
  who = clip(agent) or "agent"
  return {
    "ts": stamp(ts),
    "agent": who[:32],
    "role": "in" if role == "in" else "out",
    "text": message,
  }


def tail_lines(path, limit):
  if not path.is_file():
    return []
  try:
    data = path.read_bytes()
  except OSError:
    return []
  if len(data) > 512_000:
    data = data[-512_000:]
  return data.decode("utf-8", "replace").splitlines()[-limit:]


def agent_app(name, apps):
  app = str(name or "").strip().lower()
  if not app or not apps:
    return False
  return any(app == known or app.startswith(known) for known in apps)


def from_inbox(paths):
  found = []
  state = paths["state"]
  if not state.is_dir():
    return found
  files = [paths["inbox"]]
  files.extend(sorted(state.glob("*.jsonl")))
  seen = set()
  for path in files:
    if path in seen or not path.is_file():
      continue
    seen.add(path)
    for line in tail_lines(path, 40):
      line = line.strip()
      if not line or not line.startswith("{"):
        continue
      try:
        record = json.loads(line)
      except json.JSONDecodeError:
        continue
      if not isinstance(record, dict):
        continue
      found.append(item(
        record.get("agent") or record.get("source") or record.get("from") or "agent",
        record.get("role") or "out",
        record.get("text") or record.get("message") or record.get("body") or "",
        record.get("ts") if record.get("ts") is not None else record.get("timestamp", path.stat().st_mtime),
      ))
  return found


def note_files(paths):
  notes = paths["notes"]
  if not notes.is_dir():
    return []
  try:
    files = [path for path in notes.glob("*.json") if path.is_file()]
  except OSError:
    return []
  files.sort(key=lambda path: path.name)
  return files[-30:]


def from_notes(paths, apps):
  found = []
  for path in note_files(paths):
    try:
      record = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, UnicodeError):
      continue
    if not isinstance(record, dict) or not agent_app(record.get("app"), apps):
      continue
    summary = " ".join(str(record.get("summary") or "").split())
    if 0 < len(summary) <= 32:
      speaker = summary
    else:
      speaker = record.get("app") or "agent"
    found.append(item(
      speaker,
      "out",
      record.get("body") or "",
      record.get("timestamp") if record.get("timestamp") is not None else path.stat().st_mtime,
    ))
  return found


def collect(paths, apps):
  rows = [row for row in (*from_notes(paths, apps), *from_inbox(paths)) if row]
  rows.sort(key=lambda row: row["ts"])
  unique = []
  seen = set()
  for row in rows:
    key = (row["agent"], row["role"], row["text"], row["ts"])
    if key in seen:
      continue
    seen.add(key)
    unique.append(row)
  return unique[-KEEP:]


def signature(rows):
  return json.dumps(rows, ensure_ascii=False, separators=(",", ":"))


def snapshot(paths):
  bits = []
  for path in (paths["state"], paths["notes"], paths["inbox"]):
    try:
      stat = path.stat()
      bits.append((str(path), stat.st_mtime_ns, stat.st_size))
    except OSError:
      bits.append(str(path))
  for path in note_files(paths)[-1:]:
    try:
      stat = path.stat()
      bits.append((path.name, stat.st_mtime_ns, stat.st_size))
    except OSError:
      bits.append(path.name)
  return tuple(bits)


def publish(paths, rows):
  paths["state"].mkdir(parents=True, exist_ok=True)
  payload = json.dumps({"items": rows}, ensure_ascii=False)
  temporary = paths["feed"].with_suffix(".json.tmp")
  temporary.write_text(payload + "\n", encoding="utf-8")
  os.replace(temporary, paths["feed"])
  print(payload, flush=True)


def die_with_parent():
  # The bar starts this process. A shell test kills that bar without a
  # process group, so exit with it instead of keeping a feeder alive.
  try:
    import ctypes
    libc = ctypes.CDLL(None, use_errno=True)
    if libc.prctl(1, 15) != 0:
      return
  except (OSError, AttributeError):
    return
  if os.getppid() == 1:
    raise SystemExit(0)


def main():
  import argparse
  import fcntl

  parser = argparse.ArgumentParser(description="Publish the agent-comms feed.")
  parser.add_argument("--apps", default=DEFAULT_APPS)
  parser.add_argument("--once", action="store_true")
  args = parser.parse_args()
  apps = parse_apps(args.apps)
  paths = state_paths()
  paths["state"].mkdir(parents=True, exist_ok=True)
  paths["inbox"].touch(exist_ok=True)

  die_with_parent()
  lock_file = paths["lock"].open("a")
  fcntl.flock(lock_file, fcntl.LOCK_EX)

  if args.once:
    print(json.dumps({"items": collect(paths, apps)}, ensure_ascii=False), flush=True)
    return

  last_sig = None
  last_snap = None
  while True:
    snap = snapshot(paths)
    if snap != last_snap or last_sig is None:
      rows = collect(paths, apps)
      sig = signature(rows)
      if sig != last_sig:
        publish(paths, rows)
        last_sig = sig
      last_snap = snap
    time.sleep(0.4)


if __name__ == "__main__":
  main()
