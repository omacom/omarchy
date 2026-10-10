#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
python3 - <<'PY'
import contextlib
import importlib.util
import io
import json
import os
import re
import signal
import subprocess
import tempfile
import time
from pathlib import Path
from unittest import mock

source = Path(os.environ["ROOT"]) / "shell/plugins/panels/dropbox/status.py"
service = source.with_name("Service.qml").read_text()
panel = source.with_name("Panel.qml").read_text()
assert "inventoryRequested: root.opened" in panel
spec = importlib.util.spec_from_file_location("dropbox_status", source)
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)

with tempfile.TemporaryDirectory() as temporary:
  folder = Path(temporary)
  (folder / "one.txt").write_bytes(b"123")
  (folder / "two.txt").write_bytes(b"4567")
  (folder / "link.txt").symlink_to(folder / "one.txt")
  info = {"personal": {"path": str(folder), "subscription_type": "basic"}}
  with mock.patch.object(helper, "read_info", return_value=info):
    with mock.patch.object(helper.shutil, "which", return_value="dropbox-cli"), mock.patch.object(helper, "command_output", return_value=(0, "Dropbox isn't running!")):
      with mock.patch.object(helper, "scan_dropbox", side_effect=AssertionError("background status traversed files")):
        status = helper.read_status(status_only=True)
        assert status["authenticated"] and not status["running"]
        assert not status["inventoryLoaded"] and "usedBytes" not in status and "files" not in status
        output = io.StringIO()
        with mock.patch("sys.argv", [str(source), "--status-only"]), contextlib.redirect_stdout(output):
          helper.main()
        assert not json.loads(output.getvalue())["inventoryLoaded"]
      print("ok - authenticated, stopped Dropbox status never walks the sync tree")
      output = io.StringIO()
      with mock.patch("sys.argv", [str(source), "1"]), contextlib.redirect_stdout(output):
        helper.main()
      full = json.loads(output.getvalue())
      assert full["inventoryLoaded"] and full["usedBytes"] == 7 and len(full["files"]) == 1
      assert "installed" in full and "running" in full and "statusText" in full
      print("ok - original positional helper interface retains daemon status and inventory")
    with mock.patch.object(helper.shutil, "which", side_effect=AssertionError("inventory queried daemon")):
      inventory = helper.read_status(limit=25, inventory_only=True)
      assert inventory["inventoryLoaded"] and inventory["usedBytes"] == 7
      assert {row["name"] for row in inventory["files"]} == {"one.txt", "two.txt"}
      assert "running" not in inventory and "statusText" not in inventory
      print("ok - on-demand inventory lists regular files without another daemon probe")

    real_scandir = helper.os.scandir
    nested = folder / "unreadable"
    nested.mkdir()
    for denied in (folder, nested):
      def scandir(path):
        if Path(path) == denied:
          raise PermissionError("fixture directory is unreadable")
        return real_scandir(path)
      with mock.patch.object(helper.os, "scandir", side_effect=scandir):
        failed = helper.read_status(inventory_only=True)
      assert failed["authenticated"] and not failed["inventoryLoaded"]
      assert "usedBytes" not in failed and "files" not in failed
    print("ok - unreadable root or nested directory rejects a partial inventory")

    real_stat = helper.os.stat
    for failure in (FileNotFoundError, PermissionError):
      def stat(path, *args, **kwargs):
        if Path(path) == folder / "one.txt":
          raise failure("fixture file changed during collection")
        return real_stat(path, *args, **kwargs)
      with mock.patch.object(helper.os, "stat", side_effect=stat):
        result = helper.read_status(inventory_only=True)
      if failure is FileNotFoundError:
        assert result["inventoryLoaded"] and result["usedBytes"] == 4
      else:
        assert not result["inventoryLoaded"] and "usedBytes" not in result
    print("ok - vanished files are skipped but file access failures reject the inventory")

  with mock.patch.object(helper, "read_info", return_value={"personal": {"path": str(folder / "missing")}}):
    missing = helper.read_status(inventory_only=True)
  assert not missing["authenticated"] and not missing["inventoryLoaded"]
  assert "usedBytes" not in missing and "files" not in missing
  print("ok - an unavailable account root cannot report a successful zero-byte inventory")

  # Exercise the actual command prefix from QML against a hung fake helper.
  # Shorten only the durations so both normal TERM and escalation are covered
  # without a fifteen-second delay in every test run.
  expression = re.search(r'inventoryProcess.command = (\[[^\n]+\])', service).group(1)
  fixture = folder / "hung.py"
  fixture.write_text("import signal, time\nsignal.signal(signal.SIGTERM, signal.SIG_IGN)\nprint('ready', flush=True)\ntime.sleep(30)\n")
  command = json.loads(expression.replace("helperPath", json.dumps(str(fixture))))
  command[1:3] = ["--kill-after=0.2s", "0.5s"]
  started = time.monotonic()
  completed = subprocess.run(command, capture_output=True, text=True, timeout=4)
  assert completed.returncode != 0 and "ready" in completed.stdout
  assert time.monotonic() - started < 3
  print("ok - whole-inventory deadline kills a helper that ignores termination")

  fixture.write_text("import sys, time\nprint('ready', flush=True)\ntime.sleep(30)\n")
  command[2] = "30s"
  process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
  try:
    assert process.stdout.readline().strip() == "ready"
    process.send_signal(signal.SIGTERM)
    process.communicate(timeout=3)
    assert process.returncode != 0
  finally:
    if process.poll() is None:
      os.killpg(process.pid, signal.SIGKILL)
      process.communicate()
  print("ok - cancelling timeout forwards termination to the inventory helper")
PY
