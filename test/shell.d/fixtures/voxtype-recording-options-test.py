import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = sys.argv.pop()


class RecordingOptionsTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.directory = Path(self.tmp.name)
    self.log = self.directory / "calls"
    stub = self.directory / "voxtype"
    stub.write_text('''#!/bin/bash
if [[ $1 == "status" ]]; then
  printf '%s' "${VOXTYPE_STATE:-idle}"
else
  printf '%s\\0' "$@" > "$TEST_LOG"
  exit "${VOXTYPE_EXIT:-0}"
fi
''')
    stub.chmod(0o755)
    self.env = dict(os.environ, PATH=str(self.directory) + ":" + ROOT + "/bin:" + os.environ["PATH"], TEST_LOG=str(self.log))

  def run_app(self, *args):
    return subprocess.run(["bash", ROOT + "/bin/omarchy-dictation-voxtype", *args], env=self.env, capture_output=True, text=True)

  def recorded(self):
    return self.log.read_bytes().decode().rstrip("\0").split("\0")

  def test_start_keeps_model_profile_and_output_overrides(self):
    args = ["start", "--model", "/Models/a model.bin", "--profile", "email $(no-command)", "--clipboard"]
    self.assertEqual(self.run_app(*args).returncode, 0)
    self.assertEqual(self.recorded(), ["record", *args])

  def test_toggle_forwards_file_output(self):
    args = ["toggle", "--file=/Notes/a note.txt"]
    self.assertEqual(self.run_app(*args).returncode, 0)
    self.assertEqual(self.recorded(), ["record", *args])

  def test_plain_stop_unchanged(self):
    self.assertEqual(self.run_app("stop").returncode, 0)
    self.assertEqual(self.recorded(), ["record", "stop"])

  def test_stopped_backend_is_left_alone(self):
    self.env["VOXTYPE_STATE"] = "stopped"
    self.assertEqual(self.run_app("stop").returncode, 0)
    self.assertFalse(self.log.exists())

  def test_options_on_stop_are_not_silently_discarded(self):
    result = self.run_app("stop", "--model", "other")
    self.assertNotEqual(result.returncode, 0)
    self.assertIn("only to start or toggle", result.stderr)
    self.assertFalse(self.log.exists())

  def test_backend_failure_propagates(self):
    self.env["VOXTYPE_EXIT"] = "7"
    self.assertEqual(self.run_app("start", "--clipboard").returncode, 7)


unittest.main()
