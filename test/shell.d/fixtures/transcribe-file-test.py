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
APP = runpy.run_path(ROOT + "/bin/omarchy-transcode-transcribe")


class TranscribeTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.directory = Path(self.tmp.name)
    self.media = self.directory / "meeting $(no-command).m4a"
    self.model = self.directory / "model.bin"
    self.output = self.directory / "meeting.txt"
    self.media.write_bytes(b"recording")
    self.model.write_bytes(b"model")
    self.calls = []

  def run_app(self, extra=(), failure=None, text="Spoken words\n"):
    def run(argv, **kwargs):
      self.calls.append(argv)
      if argv[0] == "omarchy-cmd-missing":
        return subprocess.CompletedProcess(argv, 1)
      if argv[0] == failure:
        raise subprocess.CalledProcessError(1, argv)
      if argv[0] == "ffmpeg":
        Path(argv[-1]).write_bytes(b"converted WAV")
      elif argv[0] == "whisper-cli":
        self.assertTrue(Path(argv[argv.index("-f") + 1]).exists())
        extension = next(arg[2:] for arg in argv if arg in ("-otxt", "-osrt", "-ovtt"))
        Path(argv[-1] + "." + extension).write_text(text)
      return subprocess.CompletedProcess(argv, 0)

    with patch("sys.argv", ["transcribe", str(self.media), "--model", str(self.model), *extra]), patch("subprocess.run", side_effect=run), contextlib.redirect_stdout(io.StringIO()) as output:
      APP["main"]()
      return output.getvalue()

  def test_audio_conversion_precedes_inference(self):
    self.assertEqual(self.run_app(), "Spoken words\n")
    self.assertEqual([argv[0] for argv in self.calls], ["omarchy-cmd-missing", "ffmpeg", "whisper-cli"])
    self.assertEqual(self.calls[1][self.calls[1].index("-i") + 1], str(self.media.resolve()))
    self.assertEqual(self.media.read_bytes(), b"recording")
    self.assertFalse(Path(self.calls[-1][-1]).parent.exists())

  def test_subtitle_format_and_language(self):
    self.run_app(["--format", "srt", "--language", "hi", "--output", str(self.output)], text="1\n00:00:00,000 --> 00:00:01,000\nHello\n")
    self.assertIn("-osrt", self.calls[-1])
    self.assertIn("hi", self.calls[-1])
    self.assertIn("00:00:01,000", self.output.read_text())
    self.assertEqual(self.output.stat().st_mode & 0o777, 0o600)

  def test_conversion_failure_does_not_start_inference(self):
    with self.assertRaises(subprocess.CalledProcessError):
      self.run_app(failure="ffmpeg")
    self.assertNotIn("whisper-cli", [argv[0] for argv in self.calls])

  def test_inference_failure_does_not_publish_output(self):
    with self.assertRaises(subprocess.CalledProcessError):
      self.run_app(["--output", str(self.output)], failure="whisper-cli")
    self.assertFalse(self.output.exists())
    self.assertEqual(list(self.directory.glob(".omarchy-transcribe-*")), [])

  def test_existing_output_preserved_before_inference(self):
    self.output.write_text("precious")
    with self.assertRaises(FileExistsError):
      self.run_app(["--output", str(self.output)])
    self.assertEqual(self.output.read_text(), "precious")
    self.assertEqual(self.calls, [])

  def test_empty_transcript_does_not_publish(self):
    with self.assertRaises(ValueError):
      self.run_app(["--output", str(self.output)], text=" ")
    self.assertFalse(self.output.exists())


unittest.main()
