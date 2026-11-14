import contextlib
import io
import os
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = sys.argv.pop()
APP = runpy.run_path(ROOT + "/bin/omarchy-clipboard-speak")


class SpeakTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.model = Path(self.tmp.name) / "voice $(no-command).onnx"
    self.model.write_bytes(b"model")
    Path(str(self.model) + ".json").write_text("{}")
    self.calls = []

  def run_app(self, extra=(), text="Read these words", failure=False, fallback=False):
    def run(argv, **kwargs):
      self.calls.append((argv, kwargs))
      if argv[0] == "omarchy-cmd-present":
        return subprocess.CompletedProcess(argv, int(fallback and argv[1] == "piper-tts"))
      if argv[0] in ("piper-tts", "piper"):
        if failure:
          raise subprocess.CalledProcessError(1, argv)
        Path(argv[argv.index("-f") + 1]).write_bytes(b"audio")
      if argv[0] == "pw-play":
        self.assertTrue(Path(argv[1]).is_file())
      return subprocess.CompletedProcess(argv, 0, stdout=text)

    with patch("sys.argv", ["speak", "--model", str(self.model), *extra]), patch("subprocess.run", side_effect=run), patch.dict(APP["main"].__globals__, read_clipboard=lambda: text), contextlib.redirect_stdout(io.StringIO()):
      APP["main"]()

  def test_synthesis_before_playback_without_copying(self):
    self.run_app(["--rate", "1.25", "--speaker", "2"])
    programs = [call[0][0] for call in self.calls]
    self.assertEqual(programs, ["omarchy-cmd-present", "piper-tts", "pw-play"])
    argv, kwargs = self.calls[1]
    self.assertEqual(kwargs["input"], "Read these words")
    self.assertEqual(argv[argv.index("--length_scale") + 1], "0.8")
    self.assertEqual(argv[-1], "2")
    self.assertFalse(Path(self.calls[-1][0][1]).exists())

  def test_legacy_piper_command_supported(self):
    self.run_app(fallback=True)
    self.assertIn("piper", [call[0][0] for call in self.calls])

  def test_failed_synthesis_does_not_play(self):
    with self.assertRaises(subprocess.CalledProcessError):
      self.run_app(failure=True)
    self.assertNotIn("pw-play", [call[0][0] for call in self.calls])
    argv = self.calls[-1][0]
    self.assertFalse(Path(argv[argv.index("-f") + 1]).parent.exists())

  def test_empty_and_large_clipboards_do_not_synthesize(self):
    for text in (" ", "x" * 16001):
      self.calls.clear()
      with self.assertRaises(ValueError):
        self.run_app(text=text)
      self.assertNotIn("piper-tts", [call[0][0] for call in self.calls])

  def test_stalled_selection_is_rejected(self):
    self.make_selection('import time\nprint("partial", flush=True)\ntime.sleep(5)\n')
    with patch.dict(os.environ, PATH=self.tmp.name + os.pathsep + os.environ["PATH"]), \
         patch.dict(APP["read_clipboard"].__globals__, CLIPBOARD_READ_TIMEOUT=0.2):
      with self.assertRaisesRegex(TimeoutError, "Clipboard read timed out"):
        APP["read_clipboard"]()

  def test_selection_is_bounded_before_it_can_finish(self):
    self.make_selection('import sys\nfrom pathlib import Path\n'
                        'for _ in range(64):\n  sys.stdout.buffer.write(b"x" * 65536)\n'
                        'Path(sys.argv[0]).with_name("finished").touch()\n')
    with patch.dict(os.environ, PATH=self.tmp.name + os.pathsep + os.environ["PATH"]):
      with self.assertRaisesRegex(ValueError, "16,000 characters"):
        APP["read_clipboard"]()
    self.assertFalse((Path(self.tmp.name) / "finished").exists())

  def make_selection(self, script):
    paste = Path(self.tmp.name) / "wl-paste"
    paste.write_text(f"#!{sys.executable}\n" + script)
    paste.chmod(0o755)

  def test_missing_voice_config_rejected(self):
    Path(str(self.model) + ".json").unlink()
    with self.assertRaises(ValueError):
      self.run_app()
    self.assertEqual(self.calls, [])

  def test_invalid_rate_rejected_before_clipboard_read(self):
    with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
      self.run_app(["--rate", "0"])
    self.assertEqual(self.calls, [])


unittest.main()
