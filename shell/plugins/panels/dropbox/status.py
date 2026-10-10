import argparse
import json
import os
import shutil
import subprocess
import heapq
from pathlib import Path


PLAN_QUOTAS = {
  "basic": 2_000_000_000,
  "plus": 2_000_000_000_000,
  "pro": 3_000_000_000_000,
  "professional": 3_000_000_000_000,
  "essentials": 3_000_000_000_000,
}


def read_info():
  info_path = Path.home() / ".dropbox" / "info.json"
  if not info_path.exists():
    return {}
  try:
    with info_path.open("r", encoding="utf-8") as handle:
      return json.load(handle)
  except (OSError, json.JSONDecodeError):
    return {}


def dropbox_account(info):
  for key in ("personal", "business"):
    account = info.get(key)
    if isinstance(account, dict):
      return account
  return {}


def command_output(command):
  try:
    completed = subprocess.run(command, check=False, capture_output=True, text=True, timeout=4)
  except (OSError, subprocess.TimeoutExpired):
    return 1, ""
  return completed.returncode, (completed.stdout + completed.stderr).strip()


def scan_dropbox(path, limit):
  total = 0
  counter = 0
  recent = []
  def walk_error(error):
    # os.walk otherwise hides unreadable/disappeared directories and returns
    # an incomplete total as if the inventory succeeded.
    raise error

  for root, dirs, files in os.walk(path, onerror=walk_error):
    dirs[:] = [name for name in dirs if not os.path.islink(os.path.join(root, name))]
    for name in files:
      file_path = os.path.join(root, name)
      if os.path.islink(file_path):
        continue
      try:
        stat = os.stat(file_path)
      except FileNotFoundError:
        # Files can be removed normally while Dropbox is syncing.
        continue
      total += stat.st_size
      rel = os.path.relpath(file_path, path)
      folder = os.path.dirname(rel)
      row = {
        "name": name,
        "path": file_path,
        "folder": "/" if folder in ("", ".") else folder,
        "modifiedTs": int(stat.st_mtime),
        "sizeBytes": stat.st_size,
      }
      counter += 1
      entry = (row["modifiedTs"], counter, row)
      if len(recent) < limit:
        heapq.heappush(recent, entry)
      else:
        heapq.heappushpop(recent, entry)
  rows = [entry[2] for entry in sorted(recent, reverse=True)]
  return total, rows


def read_status(limit=25, status_only=False, inventory_only=False):
  info = read_info()
  account = dropbox_account(info)
  account_path = account.get("path") if isinstance(account.get("path"), str) else ""
  plan = account.get("subscription_type") if isinstance(account.get("subscription_type"), str) else ""
  quota = PLAN_QUOTAS.get(plan.lower(), 0)
  authenticated = account_path != "" and Path(account_path).exists()

  running = False
  status_text = "Not installed"
  dropbox_cli = shutil.which("dropbox-cli") if not inventory_only else None
  if dropbox_cli:
    status_exit, status_output = command_output([dropbox_cli, "status"])
    status_text = status_output if status_exit == 0 and status_output else "Stopped"
    lowered = status_text.lower()
    stopped = "not running" in lowered or "isn't running" in lowered or lowered == "stopped"
    running = status_exit == 0 and status_output != "" and not stopped

  result = {
    "ok": True,
    "authenticated": authenticated,
    "accountPath": account_path,
    "plan": plan,
    "quotaBytes": quota,
    "quotaKnown": quota > 0,
    "inventoryLoaded": False,
  }
  if not inventory_only:
    result.update(installed=dropbox_cli is not None, running=running, statusText=status_text)
  if not status_only and authenticated:
    try:
      used, files = scan_dropbox(account_path, limit)
    except OSError:
      result["inventoryError"] = "Could not read Dropbox file inventory"
    else:
      result.update(inventoryLoaded=True, usedBytes=used, files=files, usagePercent=(used / quota * 100) if quota > 0 else 0)
  return result


def main():
  parser = argparse.ArgumentParser(description="Read Dropbox daemon status or on-demand file inventory")
  parser.add_argument("limit", nargs="?", default="25")
  mode = parser.add_mutually_exclusive_group()
  mode.add_argument("--status-only", action="store_true")
  mode.add_argument("--inventory-only", action="store_true")
  args = parser.parse_args()
  try:
    limit = max(1, min(100, int(args.limit)))
  except ValueError:
    limit = 25
  # Keep the original `status.py 25` interface for callers wanting both.
  print(json.dumps(read_status(limit, args.status_only, args.inventory_only)))


if __name__ == "__main__":
  main()
