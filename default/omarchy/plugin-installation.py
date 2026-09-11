"""Host-owned installation provenance, separate from Ward's grant store.

These records are not a same-account security boundary. They prevent downloaded
metadata from selecting in-process execution, and retain fail-closed identity
when a managed checkout or its record is damaged. No plugin code runs here.
"""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile


def valid_id(value):
  return isinstance(value, str) and re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,95}", value) and ".." not in value


def git(directory, *args):
  return subprocess.check_output(["git", "-C", str(directory), *args], stderr=subprocess.DEVNULL, text=True).strip()


root = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))) / "omarchy/plugin-installations"
plugins = Path.home() / ".config/omarchy/plugins"
if not root.is_absolute():
  raise SystemExit("installation state must have an absolute path")


def read_record(directory):
  if directory.is_symlink() or not directory.is_dir():
    raise ValueError("invalid installation directory")
  path = directory / "record.json"
  if path.is_symlink() or not path.is_file() or path.stat().st_size > 16384:
    raise ValueError("missing or invalid installation record")
  record = json.loads(path.read_text())
  if (not isinstance(record, dict)
      or set(record) != {"version", "id", "mode", "sourceKind", "source", "commit"}
      or type(record["version"]) is not int or record["version"] != 1 or record["id"] != directory.name
      or record["mode"] not in ("ward", "yolo", "trusted-local")
      or record["sourceKind"] not in ("git", "local")
      or not isinstance(record["source"], str) or not record["source"]
      or len(record["source"]) > 4096 or any(ord(c) < 32 for c in record["source"])
      or (record["sourceKind"] == "local" and not Path(record["source"]).is_absolute())
      or (record["mode"] == "trusted-local" and record["sourceKind"] != "local")
      or not isinstance(record["commit"], str)
      or not re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", record["commit"])):
    raise ValueError("invalid installation record")
  return record


def rows():
  if root.is_symlink() or (root.exists() and not root.is_dir()):
    raise ValueError("invalid installation state directory")
  if not root.exists():
    return []
  result = []
  for directory in sorted(root.iterdir()):
    if not valid_id(directory.name):
      raise ValueError("invalid installation identity")
    try:
      record = read_record(directory)
      checkout = plugins / directory.name
      if checkout.is_symlink() or not checkout.is_dir():
        raise ValueError("managed plugin checkout is missing or linked")
      manifest_path = checkout / "manifest.json"
      if manifest_path.is_symlink() or manifest_path.stat().st_size > 65536:
        raise ValueError("invalid managed plugin manifest")
      manifest = json.loads(manifest_path.read_text())
      if not isinstance(manifest, dict):
        raise ValueError("invalid managed plugin manifest")
      if manifest.get("id") != record["id"]:
        raise ValueError("managed plugin identity changed")
      if git(checkout, "config", "--local", "--get", "remote.origin.url") != record["source"]:
        raise ValueError("plugin source changed; remove and explicitly reinstall to review its trust")
      if record["mode"] != "ward" and "sandbox" in manifest:
        raise ValueError("trusted installation now declares Ward; reinstall in Ward mode")
      if record["mode"] == "ward" and "sandbox" not in manifest:
        raise ValueError("Ward installation lost its sandbox declaration")
      result.append(record)
    except (ValueError, OSError, subprocess.SubprocessError) as error:
      result.append({"id": directory.name, "mode": "blocked", "error": str(error)})
  return result


def save(record):
  if not valid_id(record["id"]):
    raise ValueError("invalid plugin identity")
  if root.is_symlink():
    raise ValueError("invalid installation state directory")
  root.mkdir(mode=0o700, parents=True, exist_ok=True)
  directory = root / record["id"]
  if directory.is_symlink():
    raise ValueError("invalid installation directory")
  if record["mode"] != "ward":
    retained = json.loads(subprocess.check_output(["omarchy-plugin-isolation", "retained"], text=True))
    if record["id"] in retained:
      raise ValueError("retained Ward identity cannot become trusted in-process code")
  directory.mkdir(mode=0o700, exist_ok=True)
  # The directory survives interruption: absent JSON is blocked, not
  # a newly discovered legacy/trusted plugin. Publish the complete record last.
  fd, temporary = tempfile.mkstemp(prefix=".record-", dir=directory)
  try:
    with os.fdopen(fd, "w") as stream:
      json.dump(record, stream)
      stream.write("\n")
      stream.flush()
      os.fsync(stream.fileno())
    os.replace(temporary, directory / "record.json")
    fd = os.open(directory, os.O_DIRECTORY)
    try:
      os.fsync(fd)
    finally:
      os.close(fd)
  finally:
    if os.path.exists(temporary):
      os.unlink(temporary)


try:
  operation, *args = sys.argv[1:]
  if operation == "list" and not args:
    print(json.dumps(rows()))
  elif operation == "forget" and len(args) == 1:
    identity = args[0]
    if not valid_id(identity):
      raise ValueError("invalid plugin identity")
    if root.is_symlink():
      raise ValueError("invalid installation state directory")
    directory = root / identity
    if directory.is_symlink():
      directory.unlink()
    elif directory.exists():
      shutil.rmtree(directory)
  elif operation == "record" and len(args) == 5:
    identity, mode, kind, source, commit = args
    if mode not in ("ward", "yolo", "trusted-local") or kind not in ("git", "local"):
      raise ValueError("invalid installation mode or source")
    if not source or len(source) > 4096 or any(ord(c) < 32 for c in source):
      raise ValueError("invalid installation source")
    if not re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", commit):
      raise ValueError("invalid installed commit")
    save({"version": 1, "id": identity, "mode": mode, "sourceKind": kind, "source": source, "commit": commit})
  else:
    raise ValueError("expected list, forget <id>, or record <id> <mode> <source-kind> <source> <commit>")
except (ValueError, OSError, subprocess.SubprocessError) as error:
  print(f"omarchy-plugin-installation: {error}", file=sys.stderr)
  sys.exit(1)
