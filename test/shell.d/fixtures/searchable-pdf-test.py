import contextlib
import io
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = sys.argv.pop()
APP = runpy.run_path(ROOT + "/bin/omarchy-transcode-searchable-pdf")


class SearchablePdfTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.source = Path(self.tmp.name) / "scan $(no-command).pdf"
    self.source.write_bytes(b"original PDF")
    self.output = self.source.with_name(self.source.stem + ".searchable.pdf")
    self.calls = []

  def run_app(self, failure=False, race=False):
    def run(argv, **kwargs):
      self.calls.append(argv)
      if argv[0] == "omarchy-cmd-missing":
        return subprocess.CompletedProcess(argv, 1)
      Path(argv[-1]).write_bytes(b"searchable PDF")
      if race:
        self.output.write_bytes(b"another process")
      if failure:
        raise subprocess.CalledProcessError(1, argv)
      return subprocess.CompletedProcess(argv, 0)

    with patch("sys.argv", ["ocr", str(self.source), "--language", "eng+hin"]), patch("subprocess.run", side_effect=run), contextlib.redirect_stdout(io.StringIO()):
      APP["main"]()

  def test_success_preserves_source_and_selects_languages(self):
    self.run_app()
    self.assertEqual(self.source.read_bytes(), b"original PDF")
    self.assertEqual(self.output.read_bytes(), b"searchable PDF")
    self.assertEqual(self.output.stat().st_mode & 0o777, 0o600)
    self.assertIn("eng+hin", self.calls[-1])
    self.assertEqual(list(self.output.parent.glob(".omarchy-ocr-*")), [])

  def test_failed_ocr_does_not_publish_partial_output(self):
    with self.assertRaises(subprocess.CalledProcessError):
      self.run_app(failure=True)
    self.assertFalse(self.output.exists())
    self.assertEqual(self.source.read_bytes(), b"original PDF")
    self.assertEqual(list(self.source.parent.glob(".omarchy-ocr-*")), [])

  def test_existing_destination_is_preserved(self):
    self.output.write_bytes(b"precious")
    with self.assertRaises(FileExistsError):
      self.run_app()
    self.assertEqual(self.output.read_bytes(), b"precious")
    self.assertEqual(self.calls, [])

  def test_racing_destination_is_preserved(self):
    with self.assertRaises(FileExistsError):
      self.run_app(race=True)
    self.assertEqual(self.output.read_bytes(), b"another process")

  def test_broken_destination_symlink_is_not_followed(self):
    target = self.output.parent / "absent"
    self.output.symlink_to(target)
    with self.assertRaises(FileExistsError):
      self.run_app()
    self.assertFalse(target.exists())


unittest.main()
