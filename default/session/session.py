"""Desktop launch identities only; never replay process arguments or window titles."""
import argparse
import configparser
import fcntl
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import time

STATE = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))) / "omarchy/session"
RUNTIME = Path(os.environ.get("XDG_RUNTIME_DIR", str(STATE))) / "omarchy-session"


def command(*args, **kwargs):
  return subprocess.run(args, check=True, text=True, stdout=subprocess.PIPE,
             stderr=subprocess.PIPE, timeout=15, **kwargs).stdout


def clients():
  result = json.loads(command("hyprctl", "-j", "clients"))
  if not isinstance(result, list):
    raise ValueError("Hyprland did not return a window list")
  return result


def atomic(path, data):
  fd, name = tempfile.mkstemp(dir=path.parent)
  try:
    with os.fdopen(fd, "w") as out:
      json.dump(data, out)
      out.flush()
      os.fsync(out.fileno())
    os.replace(name, path)
  finally:
    Path(name).unlink(missing_ok=True)


def desktop_entries():
  roots = [os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share"))]
  roots += os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":")
  seen, entries = set(), {}
  for root in roots:
    directory = Path(root) / "applications"
    for path in sorted(directory.rglob("*.desktop")):
      desktop_id = str(path.relative_to(directory)).replace("/", "-")
      if desktop_id in seen:
        continue
      seen.add(desktop_id)
      parser = configparser.ConfigParser(interpolation=None, strict=False)
      try:
        parser.read(path)
        item = parser["Desktop Entry"]
        if item.get("Type") != "Application" or item.getboolean("Hidden", False):
          continue
        if not item.get("Exec") and not item.getboolean("DBusActivatable", False):
          continue
        for identity in (item.get("StartupWMClass", ""), desktop_id[:-8]):
          if identity:
            entries.setdefault(identity, desktop_id)
      except (configparser.Error, ValueError, OSError, UnicodeError):
        continue
  return entries


def identity(client):
  return client.get("initialClass") or client.get("class", "")


def save(automatic=False):
  if automatic and (RUNTIME / "exiting").exists():
    return
  entries = desktop_entries()
  records = []
  for client in clients():
    if not isinstance(client, dict):
      continue
    name = identity(client)
    if not isinstance(name, str):
      continue
    workspace = client.get("workspace", {}).get("id", 0)
    if name in {"quickshell", "org.quickshell", "org.omarchy.terminal"}:
      continue
    if name not in entries or not isinstance(workspace, int) or workspace <= 0:
      continue
    records.append({"desktop_id": entries[name], "class": name, "workspace": workspace})
  # Teardown outside Omarchy's power menu can empty the compositor before the
  # service stops. Only explicit Save/Forget is allowed to erase the last session.
  if automatic and not records:
    return
  atomic(STATE / "last.json", {"schema": 2, "saved_at": time.strftime("%Y-%m-%d %H:%M:%S"), "clients": records})


def read_state():
  path = STATE / "last.json"
  if not path.exists():
    return {"schema": 2, "clients": []}
  state = json.loads(path.read_text())
  # Preserve snapshots from the original experimental fork while discarding
  # its process/window metadata as soon as the next save writes schema 2.
  if isinstance(state, dict) and state.get("schema") == 1 and isinstance(state.get("clients"), list):
    state = {"schema": 2, "saved_at": state.get("saved_at", "legacy snapshot"), "clients": [
      {"desktop_id": item.get("desktop_id"), "class": item.get("initialClass") or item.get("class", ""),
       "workspace": item.get("workspace", {}).get("id", 0)}
      for item in state["clients"] if isinstance(item, dict) and item.get("desktop_id")
      and isinstance(item.get("workspace"), dict) and isinstance(item["workspace"].get("id"), int)
      and item["workspace"]["id"] > 0]}
  if not isinstance(state, dict) or state.get("schema") != 2 or not isinstance(state.get("clients"), list):
    raise ValueError("Unsupported saved session; choose Save Session to replace it")
  for record in state["clients"]:
    if (not isinstance(record, dict) or not isinstance(record.get("class"), str)
        or not isinstance(record.get("desktop_id"), str)
        or not isinstance(record.get("workspace"), int) or record["workspace"] <= 0):
      raise ValueError("Invalid saved session; choose Save Session to replace it")
  return state


def restore():
  records = read_state()["clients"]
  if not records:
    print("No saved applications. Choose Save Session first.")
    return
  entries = desktop_entries()
  existing = {identity(c) for c in clients()}
  launched = set()
  for record in records:
    if (RUNTIME / "exiting").exists():
      break
    name, desktop = record["class"], record["desktop_id"]
    # One launch per application. Browsers may restore their own windows;
    # never multiply those windows by replaying one launch for each old window.
    if desktop in launched:
      continue
    if name in existing:
      print(f"Already running: {desktop}")
      continue
    if entries.get(name) != desktop:
      print(f"Skipped unavailable application: {desktop}")
      continue
    launched.add(desktop)
    try:
      subprocess.run(["uwsm-app", "--", "gtk-launch", desktop], check=True,
             stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=15, start_new_session=True)
      for _ in range(40):
        if (RUNTIME / "exiting").exists():
          return
        window = next((c for c in clients() if identity(c) == name), None)
        if window:
          address = window.get("address", "")
          if re.fullmatch(r"0x[0-9a-fA-F]+", address):
            command("hyprctl", "dispatch", 'hl.dsp.window.move({ window = "address:' + address
                + '", workspace = "' + str(record["workspace"]) + '", follow = false })')
          print(f"Reopened {desktop} on workspace {record['workspace']}")
          break
        time.sleep(0.25)
      else:
        print(f"Launched {desktop}, but its window did not appear in time to place it.")
    except (subprocess.SubprocessError, OSError, ValueError) as error:
      print(f"Could not restore {desktop}: {error}", file=sys.stderr)


def startup(signature):
  if not signature:
    raise ValueError("No Hyprland session; start this service from the graphical session")
  marker = RUNTIME / "restored"
  if not marker.exists() or marker.read_text() != signature:
    (RUNTIME / "exiting").unlink(missing_ok=True)
    # Claim before launching so a crash/restart cannot launch twice.
    marker.write_text(signature)
    restore()


def main():
  parser = argparse.ArgumentParser(description="Reopen applications on their saved workspaces; application contents are not saved.")
  parser.add_argument("action", choices=["save", "restore", "status", "forget", "watch", "prepare-exit", "cancel-exit"])
  parser.add_argument("--yes", action="store_true", help="confirm forgetting the saved session")
  args = parser.parse_args()
  os.umask(0o077)
  STATE.mkdir(parents=True, exist_ok=True)
  RUNTIME.mkdir(parents=True, exist_ok=True)
  if args.action == "status":
    result = subprocess.run(["systemctl", "--user", "is-enabled", "--quiet", "omarchy-session.service"], capture_output=True)
    print("Reopen at login: " + ("enabled" if result.returncode == 0 else "disabled"))
    state = read_state()
    print("Saved: " + str(state.get("saved_at", "no saved session")))
    for record in state["clients"]:
      print(f"  {record['desktop_id']} — workspace {record['workspace']}")
    return
  if args.action == "forget" and not args.yes:
    if subprocess.run(["gum", "confirm", "Forget the saved desktop? Disable session restore first to stop automatic saves."]).returncode:
      return
  if args.action == "prepare-exit":
    if subprocess.run(["systemctl", "--user", "is-active", "--quiet", "omarchy-session.service"]).returncode:
      return
  # A short-lived lock serializes saves, manual restores and shutdown. The
  # watcher releases it while sleeping so prepare-exit can freeze the snapshot.
  def locked(action):
    with (STATE / "lock").open("w") as lock:
      fcntl.flock(lock, fcntl.LOCK_EX)
      action()
  def prepare():
    save()
  if args.action == "watch":
    signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    locked(lambda: startup(signature))
    while True:
      time.sleep(30)
      try:
        locked(lambda: save(automatic=True))
      except (subprocess.SubprocessError, OSError, ValueError) as error:
        print(f"Session snapshot skipped: {error}", file=sys.stderr, flush=True)
  elif args.action == "save":
    locked(save)
    count = len({record["desktop_id"] for record in read_state()["clients"]})
    print(f"Saved {count} supported application(s). Documents and terminal jobs are not saved.")
  elif args.action == "restore":
    locked(restore)
  elif args.action == "prepare-exit":
    (RUNTIME / "exiting").touch()
    locked(prepare)
  elif args.action == "cancel-exit":
    (RUNTIME / "exiting").unlink(missing_ok=True)
  elif args.action == "forget":
    locked(lambda: (STATE / "last.json").unlink(missing_ok=True))
    print("Saved session forgotten.")


if __name__ == "__main__":
  try:
    main()
  except (OSError, ValueError, subprocess.SubprocessError) as error:
    print(f"omarchy-session: {error}", file=sys.stderr)
    sys.exit(1)
