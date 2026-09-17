import fcntl
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

from backend.catalog import SettingsError
from backend.deferred import LOADER, PROMOTER, render_rows
from backend.deferred_runtime import (MAX_DATA_BYTES, MAX_FIELD_BYTES, MAX_ROWS,
                   UnsafeState, promote)
from backend import deferred_runtime
from backend.process_supervisor import MAX_RESPONSE_BYTES, _encode
from backend.session import Paths


ROOT = Path(os.environ["OMARCHY_PATH"]) / "shell/plugins/bar/widgets/keyboard"


def private_write(path, data):
  path.write_bytes(data)
  path.chmod(0o600)


class DeferredSecurityTests(unittest.TestCase):
  def fixture(self, directory, active=None, pending=None):
    root = Path(directory) / "state/omarchy/keyboard-layouts"
    root.mkdir(parents=True)
    root.chmod(0o700)
    active = active or render_rows([
      {"name": "typing", "layout": "us,pl", "variant": ",", "options": ""}], "session-a")
    pending = pending or render_rows([
      {"name": "typing", "layout": "pl,us", "variant": ",", "options": ""}], "session-a")
    private_write(root / "active-v1.conf", active)
    private_write(root / "pending-v1.conf", pending)
    private_write(root / "lock", b"")
    return root, active, pending

  def test_loader_has_only_bounded_helper_transport(self):
    self.assertNotIn(b"io.open", LOADER)
    self.assertNotIn(b'read("*a")', LOADER)
    self.assertNotIn(b".session", LOADER)
    self.assertNotIn(b"chmod", LOADER)
    self.assertNotIn(b"sync -f", LOADER)
    self.assertIn(b"/usr/bin/timeout", LOADER)
    self.assertIn(b"/usr/bin/python3 -I -B", LOADER)
    self.assertIn(b"handle:read(#prefix + maximum)", LOADER)

  def test_codec_limits_are_enforced_before_write(self):
    row = {"name": "typing", "layout": "us", "variant": "", "options": ""}
    with self.assertRaises(ValueError):
      render_rows([{**row, "name": str(index)} for index in range(MAX_ROWS + 1)])
    with self.assertRaises(ValueError):
      render_rows([{**row, "options": "x" * (MAX_FIELD_BYTES + 1)}])
    with self.assertRaises(ValueError):
      deferred_runtime.decode(b"x" * (MAX_DATA_BYTES + 1))
    invalid_hex = (
      deferred_runtime.DATA_HEADER + b"session\t4A\n7573\t7573\t\t\n",
      deferred_runtime.DATA_HEADER + b"session\t\n75 73\t7573\t\t\n",
      deferred_runtime.DATA_HEADER + b"session\t\n6A\t7573\t\t\n",
    )
    for data in invalid_hex:
      with self.subTest(data=data), self.assertRaises(ValueError):
        deferred_runtime.decode(data)

  def test_unpredictable_promotion_ignores_old_session_symlink(self):
    with tempfile.TemporaryDirectory() as directory:
      root, _, pending = self.fixture(directory)
      victim = Path(directory) / "victim"
      victim.write_text("do not touch")
      old_temporary = root / "active-v1.conf.session"
      old_temporary.symlink_to(victim)
      self.assertEqual(promote(str(root), "session-b"), pending)
      self.assertEqual((root / "active-v1.conf").read_bytes(), pending)
      self.assertEqual(victim.read_text(), "do not touch")
      self.assertTrue(old_temporary.is_symlink())
      self.assertFalse(list(root.glob(".active-v1.conf.*")))
      self.assertEqual((root / "active-v1.conf").stat().st_mode & 0o777, 0o600)

  def test_active_symlink_and_hardlink_fail_closed(self):
    for link_type in ("symlink", "hardlink"):
      with self.subTest(link_type=link_type), tempfile.TemporaryDirectory() as directory:
        root, _, _ = self.fixture(directory)
        victim = Path(directory) / "victim"
        victim.write_text("private data")
        victim.chmod(0o600)
        (root / "active-v1.conf").unlink()
        if link_type == "symlink":
          (root / "active-v1.conf").symlink_to(victim)
        else:
          os.link(victim, root / "active-v1.conf")
        with self.assertRaises((UnsafeState, OSError)):
          promote(str(root), "session-b")
        self.assertEqual(victim.read_text(), "private data")

  def test_special_and_oversized_files_are_bounded(self):
    with tempfile.TemporaryDirectory() as directory:
      root, _, _ = self.fixture(directory)
      (root / "pending-v1.conf").unlink()
      os.mkfifo(root / "pending-v1.conf", 0o600)
      started = time.monotonic()
      with self.assertRaises(UnsafeState):
        promote(str(root), "session-b")
      self.assertLess(time.monotonic() - started, 0.5)

    with tempfile.TemporaryDirectory() as directory:
      root, _, pending = self.fixture(directory)
      private_write(root / "active-v1.conf", b"x" * (MAX_DATA_BYTES + 1))
      self.assertEqual(promote(str(root), "session-b"), pending)
      self.assertEqual((root / "active-v1.conf").read_bytes(), pending)

    with self.assertRaises(UnsafeState):
      deferred_runtime.read_path("/dev/null", MAX_DATA_BYTES)

  def test_unsafe_pending_and_lock_paths_emit_no_state(self):
    for name in ("pending-v1.conf", "lock"):
      with self.subTest(name=name), tempfile.TemporaryDirectory() as directory:
        root, _, _ = self.fixture(directory)
        victim = Path(directory) / "victim"
        victim.write_text("leave me alone")
        victim.chmod(0o600)
        (root / name).unlink()
        (root / name).symlink_to(victim)
        with self.assertRaises(UnsafeState):
          promote(str(root), "session-b")
        self.assertEqual(victim.read_text(), "leave me alone")

  def test_directory_state_nodes_fail_closed(self):
    for name in ("active-v1.conf", "pending-v1.conf", "lock"):
      with self.subTest(name=name), tempfile.TemporaryDirectory() as directory:
        root, _, _ = self.fixture(directory)
        (root / name).unlink()
        (root / name).mkdir()
        with self.assertRaises((UnsafeState, OSError)):
          promote(str(root), "session-b")

  def test_malformed_regular_active_can_recover_from_valid_pending(self):
    with tempfile.TemporaryDirectory() as directory:
      root, _, pending = self.fixture(directory)
      private_write(root / "active-v1.conf", b"malformed\n")
      self.assertEqual(promote(str(root), "session-b"), pending)
      self.assertEqual((root / "active-v1.conf").read_bytes(), pending)

  def test_lock_contention_keeps_current_active_data(self):
    with tempfile.TemporaryDirectory() as directory:
      root, active, _ = self.fixture(directory)
      with (root / "lock").open("r+") as held:
        fcntl.flock(held, fcntl.LOCK_EX | fcntl.LOCK_NB)
        self.assertEqual(promote(str(root), "session-b"), active)
      self.assertEqual((root / "active-v1.conf").read_bytes(), active)

  def test_failure_before_replace_preserves_active_and_cleans_temporary(self):
    with tempfile.TemporaryDirectory() as directory:
      root, active, _ = self.fixture(directory)
      with patch.object(deferred_runtime.os, "replace", side_effect=OSError("replace failed")):
        with self.assertRaises(OSError):
          promote(str(root), "session-b")
      self.assertEqual((root / "active-v1.conf").read_bytes(), active)
      self.assertFalse(list(root.glob(".active-v1.conf.*")))

  def test_partial_writes_are_completed_and_file_sync_failure_is_atomic(self):
    with tempfile.TemporaryDirectory() as directory:
      root, _, pending = self.fixture(directory)
      real_write = deferred_runtime.os.write

      def partial_write(fd, data):
        return real_write(fd, data[:3])

      with patch.object(deferred_runtime.os, "write", side_effect=partial_write):
        self.assertEqual(promote(str(root), "session-b"), pending)
      self.assertEqual((root / "active-v1.conf").read_bytes(), pending)

    with tempfile.TemporaryDirectory() as directory:
      root, active, _ = self.fixture(directory)
      with patch.object(deferred_runtime.os, "fsync", side_effect=OSError("file sync failed")):
        with self.assertRaises(OSError):
          promote(str(root), "session-b")
      self.assertEqual((root / "active-v1.conf").read_bytes(), active)
      self.assertFalse(list(root.glob(".active-v1.conf.*")))

  def test_random_temporary_collision_retries_without_touching_collision(self):
    with tempfile.TemporaryDirectory() as directory:
      root, _, pending = self.fixture(directory)
      collision = root / (".active-v1.conf." + "0" * 32)
      private_write(collision, b"collision")
      with patch.object(deferred_runtime.secrets, "token_hex",
               side_effect=["0" * 32, "1" * 32]):
        self.assertEqual(promote(str(root), "session-b"), pending)
      self.assertEqual(collision.read_bytes(), b"collision")
      self.assertFalse((root / (".active-v1.conf." + "1" * 32)).exists())

  def test_readback_and_changed_snapshot_fail_before_replace(self):
    with tempfile.TemporaryDirectory() as directory:
      root, active, _ = self.fixture(directory)
      real_read_fd = deferred_runtime._read_fd
      calls = 0

      def fail_temporary_readback(fd, limit):
        nonlocal calls
        calls += 1
        if calls == 5:
          raise OSError("readback failed")
        return real_read_fd(fd, limit)

      with patch.object(deferred_runtime, "_read_fd", side_effect=fail_temporary_readback):
        with self.assertRaises(OSError):
          promote(str(root), "session-b")
      self.assertEqual((root / "active-v1.conf").read_bytes(), active)
      self.assertFalse(list(root.glob(".active-v1.conf.*")))

    with tempfile.TemporaryDirectory() as directory:
      root, active, _ = self.fixture(directory)
      real_identity = deferred_runtime._current_identity

      def changed_identity(directory_fd, name):
        identity = real_identity(directory_fd, name)
        if name == "active-v1.conf" and identity is not None:
          return (*identity[:-1], identity[-1] + 1)
        return identity

      with patch.object(deferred_runtime, "_current_identity", side_effect=changed_identity):
        with self.assertRaises(UnsafeState):
          promote(str(root), "session-b")
      self.assertEqual((root / "active-v1.conf").read_bytes(), active)
      self.assertFalse(list(root.glob(".active-v1.conf.*")))

  def test_directory_sync_failure_reports_visible_replacement(self):
    with tempfile.TemporaryDirectory() as directory:
      root, _, pending = self.fixture(directory)
      real_fsync = deferred_runtime.os.fsync
      calls = 0

      def fail_directory_sync(fd):
        nonlocal calls
        calls += 1
        if calls == 2:
          raise OSError("directory sync failed")
        return real_fsync(fd)

      with patch.object(deferred_runtime.os, "fsync", side_effect=fail_directory_sync):
        self.assertEqual(promote(str(root), "session-b"), pending)
      self.assertEqual((root / "active-v1.conf").read_bytes(), pending)

  def test_python_state_reads_and_lock_refuse_links_without_touching_victim(self):
    with tempfile.TemporaryDirectory() as directory:
      paths = Paths(Path(directory) / "config", Path(directory) / "state")
      paths.root.mkdir(parents=True)
      paths.root.chmod(0o700)
      victim = Path(directory) / "victim"
      victim.write_text("leave me alone")
      victim.chmod(0o600)
      paths.profile.symlink_to(victim)
      with self.assertRaisesRegex(SettingsError, "Cannot read settings.json"):
        paths.owned_blob(paths.profile)
      paths.lock_file.symlink_to(victim)
      with self.assertRaisesRegex(SettingsError, "lock needs manual review"):
        with paths.lock():
          self.fail("linked lock was acquired")
      self.assertEqual(victim.read_text(), "leave me alone")


class ProcessSupervisorTests(unittest.TestCase):
  def wait_group_gone(self, process_group, timeout=4):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
      try:
        os.killpg(process_group, 0)
      except ProcessLookupError:
        return
      time.sleep(0.02)
    self.fail(f"process group {process_group} survived supervisor teardown")

  def wait_pids_gone(self, pids, timeout=4):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
      if not any((Path("/proc") / str(pid)).exists() for pid in pids):
        return
      time.sleep(0.02)
    self.fail(f"supervisor descendants survived: {sorted(pids)}")

  def supervisor_fixture(self, mode, pid_file):
    ready_file = pid_file.with_suffix(".ready")
    grand_file = pid_file.with_suffix(".grand")
    grandchild = (
      "import signal,time;"
      "signal.signal(signal.SIGTERM, signal.SIG_IGN);"
      "time.sleep(60)"
    )
    child = (
      "import os,signal,time,pathlib,subprocess;"
      "signal.signal(signal.SIGTERM, signal.SIG_IGN);"
      f"grand=subprocess.Popen(['/usr/bin/python3','-c',{grandchild!r}]);"
      f"pathlib.Path({str(grand_file)!r}).write_text(str(grand.pid));"
      f"pathlib.Path({str(ready_file)!r}).write_text(str(os.getpid()));"
      "time.sleep(60)"
    )
    body = [
      "import os,subprocess,sys,time",
      f"sys.path.insert(0, {str(ROOT)!r})",
      "import backend.process_supervisor as supervisor",
      "def fixture(action, request):",
      f"    child = subprocess.Popen(['/usr/bin/python3', '-c', {child!r}])",
      f"    open({str(pid_file)!r}, 'w').write(str(child.pid))",
      f"    deadline = time.monotonic() + 3",
      f"    while not os.path.exists({str(ready_file)!r}) and time.monotonic() < deadline: time.sleep(0.01)",
    ]
    if mode == "return":
      body.append("    time.sleep(0.2)")
      body.append("    return {'ok': True, 'data': {'fixture': True}}")
    elif mode == "noisy":
      body.extend([
        "    time.sleep(0.2)",
        "    os.write(1, b'x' * (300 * 1024))",
        "    os.write(2, b'x' * (300 * 1024))",
        "    return {'ok': True, 'data': {'fixture': True}}",
      ])
    else:
      body.append("    time.sleep(60)")
    body.extend([
      "supervisor.response = fixture",
      "raise SystemExit(supervisor.main(['status', '{}']))",
    ])
    return "\n".join(body)

  def start_fixture(self, mode, pid_file):
    return subprocess.Popen(
      ["/usr/bin/python3", "-I", "-B", "-c", self.supervisor_fixture(mode, pid_file)],
      cwd=ROOT, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

  def wait_pid_file(self, pid_file):
    deadline = time.monotonic() + 3
    while time.monotonic() < deadline:
      if pid_file.exists() and pid_file.read_text():
        return int(pid_file.read_text())
      time.sleep(0.02)
    self.fail("supervised child did not start")

  def test_response_cap_becomes_transport_failure(self):
    encoded = _encode({"ok": True, "data": "x" * (MAX_RESPONSE_BYTES + 1)})
    value = json.loads(encoded)
    self.assertFalse(value["ok"])
    self.assertTrue(value["transportFailure"])
    self.assertLess(len(encoded), 1024)

  def test_dispatch_stdout_and_stderr_cannot_reach_qml(self):
    with tempfile.TemporaryDirectory() as directory:
      pid_file = Path(directory) / "pid"
      process = self.start_fixture("noisy", pid_file)
      self.wait_pid_file(pid_file)
      stdout, stderr = process.communicate(timeout=5)
      self.assertEqual(process.returncode, 0)
      self.assertEqual(stderr, b"")
      self.assertEqual(json.loads(stdout)["data"], {"fixture": True})
      self.assertLess(len(stdout), 1024)
      self.wait_group_gone(process.pid)

  def test_normal_exit_cleans_unexpected_descendant(self):
    with tempfile.TemporaryDirectory() as directory:
      pid_file = Path(directory) / "pid"
      process = self.start_fixture("return", pid_file)
      self.wait_pid_file(pid_file)
      child = self.wait_pid_file(pid_file.with_suffix(".ready"))
      grandchild = self.wait_pid_file(pid_file.with_suffix(".grand"))
      children_file = Path("/proc") / str(process.pid) / "task" / str(process.pid) / "children"
      descendants = {int(value) for value in children_file.read_text().split()}
      descendants.update((child, grandchild))
      stdout, _ = process.communicate(timeout=5)
      self.assertEqual(process.returncode, 0)
      self.assertTrue(json.loads(stdout)["ok"])
      self.wait_group_gone(process.pid)
      self.wait_pids_gone(descendants)

  def test_shell_teardown_cleans_term_resistant_descendants_and_watchdog(self):
    with tempfile.TemporaryDirectory() as directory:
      pid_file = Path(directory) / "pid"
      process = self.start_fixture("hang", pid_file)
      self.wait_pid_file(pid_file)
      child = self.wait_pid_file(pid_file.with_suffix(".ready"))
      grandchild = self.wait_pid_file(pid_file.with_suffix(".grand"))
      children_file = Path("/proc") / str(process.pid) / "task" / str(process.pid) / "children"
      descendants = {int(value) for value in children_file.read_text().split()}
      descendants.update((child, grandchild))
      process.terminate()
      process.communicate(timeout=2)
      self.wait_group_gone(process.pid)
      self.wait_pids_gone(descendants)

  def test_forced_supervisor_kill_cleans_term_resistant_descendant(self):
    with tempfile.TemporaryDirectory() as directory:
      pid_file = Path(directory) / "pid"
      process = self.start_fixture("hang", pid_file)
      self.wait_pid_file(pid_file)
      child = self.wait_pid_file(pid_file.with_suffix(".ready"))
      grandchild = self.wait_pid_file(pid_file.with_suffix(".grand"))
      children_file = Path("/proc") / str(process.pid) / "task" / str(process.pid) / "children"
      child_pids = {int(value) for value in children_file.read_text().split()}
      child_pids.update((child, grandchild))
      self.assertGreaterEqual(len(child_pids), 2, "worker and watchdog must both be present")
      os.kill(process.pid, signal.SIGKILL)
      process.communicate(timeout=2)
      self.wait_group_gone(process.pid)
      self.wait_pids_gone(child_pids)

  def test_runtime_uses_absolute_commands_and_no_collectors(self):
    backend = (ROOT / "Backend.qml").read_text()
    guard = (ROOT / "HelperProcess.qml").read_text()
    session = (ROOT / "backend/session.py").read_text()
    self.assertNotIn("StdioCollector", backend + guard)
    self.assertIn('"/usr/bin/python3"', guard)
    self.assertIn("clearEnvironment: true", guard)
    self.assertNotIn("PYTHONPATH", guard)
    self.assertNotIn("LD_PRELOAD", guard)
    self.assertNotIn('["python3"', backend)
    self.assertNotIn('["hyprctl"', backend + session)
    self.assertIn('"/usr/bin/hyprctl"', session)


if __name__ == "__main__":
  unittest.main()
