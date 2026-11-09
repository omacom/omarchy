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
APP = runpy.run_path(ROOT + "/bin/omarchy-capture-text-file")


class ImageTextTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.image = Path(self.tmp.name) / "-receipt $(no-command).png"
    self.image.write_bytes(b"image")
    self.calls = []

  def run_app(self, extra=(), text="Recognized words\n", failure=False):
    def run(argv, **kwargs):
      self.calls.append((argv, kwargs))
      if argv[0] == "tesseract" and failure:
        raise subprocess.CalledProcessError(1, argv)
      return subprocess.CompletedProcess(argv, 0, stdout=text)
    with patch("sys.argv", ["ocr", str(self.image), *extra]), patch("subprocess.run", side_effect=run), contextlib.redirect_stdout(io.StringIO()) as output:
      APP["main"]()
      return output.getvalue()

  def test_prints_without_copying_and_preserves_path(self):
    self.assertEqual(self.run_app(), "Recognized words\n")
    self.assertEqual(len(self.calls), 1)
    self.assertEqual(self.calls[0][0][1], str(self.image.resolve()))

  def test_layout_and_multilingual_copy(self):
    self.run_app(["--layout", "sparse", "--language", "eng+hin", "--copy"])
    argv = self.calls[0][0]
    self.assertEqual(argv[argv.index("--psm") + 1], "11")
    self.assertEqual(argv[argv.index("-l") + 1], "eng+hin")
    self.assertEqual(self.calls[1][1]["input"], "Recognized words\n")

  def test_clipboard_failure_preserves_recognized_text(self):
    def run(argv, **kwargs):
      if argv[0] == "wl-copy":
        raise subprocess.CalledProcessError(1, argv)
      return subprocess.CompletedProcess(argv, 0, stdout="Recognized words\n")

    with patch("sys.argv", ["ocr", str(self.image), "--copy"]), patch("subprocess.run", side_effect=run), contextlib.redirect_stdout(io.StringIO()) as output:
      with self.assertRaises(subprocess.CalledProcessError):
        APP["main"]()
      self.assertEqual(output.getvalue(), "Recognized words\n")

  def test_no_copy_when_ocr_empty_or_fails(self):
    for text, failure in ((" ", False), ("ignored", True)):
      self.calls.clear()
      with self.assertRaises((ValueError, subprocess.CalledProcessError)):
        self.run_app(["--copy"], text, failure)
      self.assertEqual(len(self.calls), 1)

  def test_missing_file_is_rejected_before_ocr(self):
    self.image.unlink()
    with self.assertRaises(OSError):
      self.run_app()
    self.assertEqual(self.calls, [])

  def test_environment_language_is_used(self):
    with patch.dict("os.environ", {"OMARCHY_OCR_LANGS": "fra"}):
      self.run_app()
    self.assertEqual(self.calls[0][0][-1], "fra")


unittest.main()
