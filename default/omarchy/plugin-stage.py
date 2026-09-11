"""Host-owned temporary checkout handoff. No plugin code executes here."""
import fcntl
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys


plugins = Path.home() / ".config/omarchy/plugins"


def run(*args, data=None):
  return subprocess.check_output(args, input=data, text=True).strip()


def valid_id(value):
  return isinstance(value, str) and re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,95}", value) and ".." not in value


def session(token):
  if not re.fullmatch(r"\.add\.[A-Za-z0-9]{8}", token):
    raise ValueError("invalid review checkout")
  directory = plugins / token
  if directory.is_symlink() or not directory.is_dir():
    raise ValueError("review checkout no longer exists; clone the plugin again")
  if directory.stat().st_uid != os.getuid() or directory.stat().st_mode & 0o077:
    raise ValueError("review checkout must be private and owned by this user")
  return directory


def read(directory):
  path = directory / "record.json"
  checkout = directory / "checkout"
  if path.is_symlink() or not path.is_file() or path.stat().st_size > 16384:
    raise ValueError("invalid review checkout record")
  record = json.loads(path.read_text())
  if (not isinstance(record, dict) or record.get("stage") != directory.name
      or record.get("mode") != "ward" or record.get("installed") is not False
      or not valid_id(record.get("id"))
      or not isinstance(record.get("commit"), str)
      or not re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", record["commit"])
      or record.get("sourceKind") not in ("git", "local")
      or not isinstance(record.get("source"), str) or not record["source"]
      or len(record["source"]) > 4096 or any(ord(c) < 32 for c in record["source"])
      or checkout.is_symlink() or not checkout.is_dir()):
    raise ValueError("invalid review checkout record")
  return record, checkout


def review(record, checkout, operation="preview"):
  result = json.loads(run("omarchy-ward-runtime", data=json.dumps({"operation": operation, "path": str(checkout)})))
  if result.get("id") != record["id"]:
    raise ValueError("review checkout identity changed; clone the plugin again")
  return result


try:
  operation, token, *args = sys.argv[1:]
  if operation not in ("review", "publish", "discard") or len(args) != (1 if operation == "publish" else 0):
    raise ValueError("expected review/discard <stage> or publish <stage> <reviewed-revision>")
  directory = session(token)
  if operation == "discard":
    # The validated random session is the only deletion target. In particular,
    # never derive a target from a plugin-authored id or follow checkout links.
    shutil.rmtree(directory)
  else:
    record, checkout = read(directory)
    if operation == "review":
      print(json.dumps(review(record, checkout)))
    else:
      revision = args[0]
      if not re.fullmatch(r"[0-9a-f]{64}", revision):
        raise ValueError("publication requires the reviewed revision")
      with (plugins / ".install.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        target = plugins / record["id"]
        catalog = json.loads(run("omarchy-plugin-catalog"))
        if target.exists() or target.is_symlink() or any(row["id"] == record["id"] and row.get("manifestPath") for row in catalog):
          raise ValueError("plugin is already installed; manage it instead of replacing it")
        if (run("git", "-C", str(checkout), "rev-parse", "HEAD") != record["commit"]
            or run("git", "-C", str(checkout), "config", "--local", "--get", "remote.origin.url") != record["source"]
            or review(record, checkout)["revision"] != revision):
          raise ValueError("review checkout changed; review it again before enabling")
        if review(record, checkout, "import")["revision"] != revision:
          raise ValueError("review checkout changed during publication; review it again")
        run("omarchy-plugin-isolation", "mark", record["id"])
        run("omarchy-plugin-installation", "record", record["id"], "ward", record["sourceKind"], record["source"], record["commit"])
        checkout.rename(target)
        (directory / "record.json").unlink()
        directory.rmdir()
        run("omarchy-shell", "-q", "shell", "rescanPlugins")
        print(json.dumps({**record, "installed": True}))
except (ValueError, OSError, subprocess.SubprocessError) as error:
  print(f"omarchy-plugin-stage: {error}", file=sys.stderr)
  sys.exit(1)
