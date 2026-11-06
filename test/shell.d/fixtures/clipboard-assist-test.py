import contextlib
import io
import json
import os
from pathlib import Path
import tempfile
import subprocess
import sys
import unittest
from unittest.mock import patch

ROOT = sys.argv.pop()
COMMAND = ROOT + "/bin/omarchy-clipboard-assist"
source = Path(COMMAND).read_text()
python_source = source.split("<<'PY'\n", 1)[1].rsplit("\nPY\n", 1)[0]
APP = {"__name__": "clipboard_assist"}
exec(compile(python_source, COMMAND, "exec"), APP)


class ClipboardAssistTest(unittest.TestCase):
  def run_app(self, extra=(), answer="Edited text", remote=False, text="Original text"):
    requests, copies = [], []

    class Opener:
      def open(self, request, timeout):
        payload = json.loads(request.data)
        requests.append((request.full_url, payload))
        response = {"capabilities": ["completion"]}
        if request.full_url.endswith("generate"):
          response = {"response": answer}
        elif remote:
          response["remote_host"] = "https://ollama.com"
        return contextlib.closing(io.StringIO(json.dumps(response)))

    def run(argv, **kwargs):
      if argv[0] == "wl-copy":
        copies.append(kwargs["input"])
      return subprocess.CompletedProcess(argv, 0, stdout=text)

    with patch("sys.argv", ["assist", *extra, "--model", "test:latest"]), patch("subprocess.run", side_effect=run), patch("urllib.request.build_opener", return_value=Opener()), contextlib.redirect_stdout(io.StringIO()) as output:
      try:
        APP["main"]()
      except ValueError:
        return requests, copies, output.getvalue(), False
    return requests, copies, output.getvalue(), True

  def test_bash_entrypoint_preserves_help_and_argument_errors(self):
    with tempfile.TemporaryDirectory() as home:
      env = dict(os.environ, HOME=home, XDG_CONFIG_HOME=home + "/config")
      help_result = subprocess.run([COMMAND, "--help"], env=env, capture_output=True, text=True)
      self.assertEqual(help_result.returncode, 0, help_result.stderr)
      self.assertIn("omarchy-clipboard-assist", help_result.stdout)
      self.assertIn("--model", help_result.stdout)
      invalid = subprocess.run([COMMAND, "translate", "--model", "test"], env=env,
                               capture_output=True, text=True)
      self.assertEqual(invalid.returncode, 2)
      self.assertIn("translate requires --language", invalid.stderr)

  def test_preview_leaves_clipboard(self):
    requests, copies, output, ok = self.run_app(["summarize"])
    self.assertTrue(ok)
    self.assertEqual(copies, [])
    self.assertEqual(output, "Edited text\n")
    self.assertEqual(requests[-1][1]["prompt"], "Original text")
    self.assertTrue(all(url.startswith("http://127.0.0.1:11434/") for url, _ in requests))

  def test_copy_only_after_success(self):
    _, copies, _, ok = self.run_app(["rewrite", "--copy"])
    self.assertTrue(ok)
    self.assertEqual(copies, ["Edited text"])
    _, copies, _, ok = self.run_app(["rewrite", "--copy"], answer="")
    self.assertFalse(ok)
    self.assertEqual(copies, [])

  def test_cloud_rejected_before_text_is_sent(self):
    requests, copies, _, ok = self.run_app(["explain", "--copy"], remote=True)
    self.assertFalse(ok)
    self.assertEqual(len(requests), 1)
    self.assertNotIn("prompt", requests[0][1])
    self.assertEqual(copies, [])

  def test_empty_and_large_clipboards_do_not_contact_model(self):
    for text in (" ", "x" * 32001):
      requests, _, _, ok = self.run_app(["summarize"], text=text)
      self.assertFalse(ok)
      self.assertEqual(requests, [])

  def test_translation_uses_language(self):
    requests, _, _, ok = self.run_app(["translate", "--language", "Hindi"])
    self.assertTrue(ok)
    self.assertIn("Hindi", requests[-1][1]["system"])

  def test_missing_language_rejected_before_reading_clipboard(self):
    with patch("sys.argv", ["assist", "translate", "--model", "test"]), patch("subprocess.run") as run, contextlib.redirect_stderr(io.StringIO()):
      with self.assertRaises(SystemExit):
        APP["main"]()
      run.assert_not_called()


unittest.main()
