import contextlib
import io
import json
import runpy
import subprocess
import sys
import unittest
from unittest.mock import patch

ROOT = sys.argv.pop()
APP = runpy.run_path(ROOT + "/bin/omarchy-launch-ai-chat")


class ChatPickerTest(unittest.TestCase):
  def run_app(self, extra=(), metadata=None, choice="test:latest\n", cancel=False, models=None, picker_status=0):
    requests = []

    class Opener:
      def open(self, request, timeout):
        requests.append(request.full_url)
        response = {"models": [{"name": name} for name in (models if models is not None else ["test:latest", "other:4b"])]}
        if request.full_url.endswith("show"):
          response = metadata if metadata is not None else {"capabilities": ["completion"]}
        return contextlib.closing(io.StringIO(json.dumps(response)))

    def run(argv, **kwargs):
      if argv[0] == "omarchy-cmd-missing":
        return subprocess.CompletedProcess(argv, 1)
      return subprocess.CompletedProcess(argv, 130 if cancel else picker_status, stdout=choice)

    with patch("sys.argv", ["chat", *extra]), patch("sys.stdin.isatty", return_value=True), patch("subprocess.run", side_effect=run), patch("urllib.request.build_opener", return_value=Opener()), patch("os.execvpe") as execute:
      try:
        code = APP["main"]()
        return code, execute.call_args, requests
      except ValueError:
        return 1, execute.call_args, requests

  def test_picker_launches_selected_model_on_loopback(self):
    with patch.dict("os.environ", {"OLLAMA_HOST": "https://another-server.invalid"}):
      code, call, requests = self.run_app()
    self.assertEqual(code, 0)
    self.assertEqual(call.args[:2], ("ollama", ["ollama", "run", "test:latest"]))
    self.assertEqual(call.args[2]["OLLAMA_HOST"], "http://127.0.0.1:11434")
    self.assertTrue(all(url.startswith("http://127.0.0.1:11434/") for url in requests))

  def test_explicit_default_tag_resolves_installed_model(self):
    code, call, _ = self.run_app(["--model", "test"])
    self.assertEqual(code, 0)
    self.assertEqual(call.args[1][-1], "test:latest")

  def test_cancel_does_not_launch_or_check_a_model(self):
    code, call, requests = self.run_app(cancel=True)
    self.assertEqual(code, 0)
    self.assertIsNone(call)
    self.assertEqual(len(requests), 1)

  def test_failed_empty_picker_is_not_treated_as_cancellation(self):
    with self.assertRaises(subprocess.CalledProcessError):
      self.run_app(choice="", picker_status=2)

  def test_picker_display_reaches_the_terminal(self):
    driver = '''
import runpy, subprocess, sys
from unittest.mock import patch
app = runpy.run_path(sys.argv[1] + "/bin/omarchy-launch-ai-chat")
app["main"].__globals__["request"] = lambda *args: {"models": [{"name": "test:latest"}], "capabilities": ["completion"]}
run = subprocess.run
def picker(args, **kwargs):
  if args[0] == "omarchy-cmd-missing":
    return subprocess.CompletedProcess(args, 1)
  return run([sys.executable, "-c", 'import sys; print("MODEL PICKER", file=sys.stderr); print("test:latest")'], **kwargs)
with patch("sys.argv", ["chat"]), patch("sys.stdin.isatty", return_value=True), patch("subprocess.run", side_effect=picker), patch("os.execvpe"):
  sys.exit(app["main"]())
'''
    result = subprocess.run([sys.executable, "-c", driver, ROOT], capture_output=True, text=True)
    self.assertEqual(result.returncode, 0, result.stderr)
    self.assertIn("MODEL PICKER", result.stderr)

  def test_missing_model_does_not_download(self):
    code, call, requests = self.run_app(["--model", "absent"])
    self.assertEqual(code, 1)
    self.assertIsNone(call)
    self.assertEqual(len(requests), 1)

  def test_cloud_and_noncompletion_models_do_not_launch(self):
    for metadata in ({"remote_host": "https://ollama.com", "capabilities": ["completion"]}, {"capabilities": ["embedding"]}):
      code, call, _ = self.run_app(["--model", "test"], metadata=metadata)
      self.assertEqual(code, 1)
      self.assertIsNone(call)

  def test_no_models_has_no_launch(self):
    code, call, _ = self.run_app(models=[])
    self.assertEqual(code, 1)
    self.assertIsNone(call)

  def test_detached_picker_rejected_before_network_or_commands(self):
    with patch("sys.argv", ["chat"]), patch("sys.stdin.isatty", return_value=False), patch("subprocess.run") as run, contextlib.redirect_stderr(io.StringIO()):
      with self.assertRaises(SystemExit):
        APP["main"]()
      run.assert_not_called()


unittest.main()
