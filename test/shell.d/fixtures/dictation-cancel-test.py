import fcntl
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = sys.argv.pop()


class CancelTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.directory = Path(self.tmp.name)
    self.defaults = self.directory / "config/omarchy/defaults"
    self.defaults.mkdir(parents=True)
    (self.defaults / "dictation").write_text("voxtype\n")
    self.log = self.directory / "calls"
    stub = self.directory / "voxtype"
    stub.write_text('''#!/bin/bash
if [[ $1 == "status" ]]; then
  printf '%s' "${VOXTYPE_STATE:-recording}"
else
  printf '%s\\n' "$*" >> "$TEST_LOG"
  exit "${VOXTYPE_EXIT:-0}"
fi
''')
    stub.chmod(0o755)
    self.env = dict(os.environ, PATH=str(self.directory) + ":" + ROOT + "/bin:" + os.environ["PATH"], TEST_LOG=str(self.log), XDG_CONFIG_HOME=str(self.directory / "config"))

  def run_app(self, *args):
    return subprocess.run([sys.executable, ROOT + "/bin/omarchy-dictation-cancel", *args], env=self.env, capture_output=True, text=True, timeout=10)

  def test_recording_and_transcribing_are_cancelled_without_stop(self):
    for state in ("recording", "transcribing"):
      self.env["VOXTYPE_STATE"] = state
      result = self.run_app()
      self.assertEqual(result.returncode, 0, result.stderr)
    self.assertEqual(self.log.read_text().splitlines(), ["record cancel", "record cancel"])

  def test_stopped_backend_is_left_alone(self):
    self.env["VOXTYPE_STATE"] = "stopped"
    self.assertEqual(self.run_app().returncode, 0)
    self.assertFalse(self.log.exists())

  def test_other_selected_backend_is_not_changed(self):
    (self.defaults / "dictation").write_text("superwhisper\n")
    result = self.run_app()
    self.assertNotEqual(result.returncode, 0)
    self.assertIn("Selected backend: superwhisper", result.stderr)
    self.assertFalse(self.log.exists())

  def test_backend_failure_is_reported(self):
    self.env["VOXTYPE_EXIT"] = "7"
    self.assertNotEqual(self.run_app().returncode, 0)

  def test_backend_selection_lock_blocks_cancellation(self):
    with (self.defaults / "dictation.lock").open("a") as lock:
      fcntl.flock(lock, fcntl.LOCK_EX)
      result = self.run_app()
    self.assertNotEqual(result.returncode, 0)
    self.assertIn("Dictation is busy", result.stderr)
    self.assertFalse(self.log.exists())


unittest.main()
