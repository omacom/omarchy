import contextlib
import io
import json
import runpy
import subprocess
import sys
import unittest
from unittest.mock import patch

ROOT = sys.argv.pop()
APP = runpy.run_path(ROOT + "/bin/omarchy-agent-unload-ollama")


class UnloadTest(unittest.TestCase):
  def run_app(self, extra=(), models=None, fail=None, cancel=False):
    requests = []

    class Opener:
      def open(self, request, timeout):
        payload = json.loads(request.data) if request.data else None
        requests.append((request.full_url, payload))
        if request.full_url.endswith("ps"):
          result = {"models": [{"name": name} for name in (models if models is not None else ["a:latest", "b:4b"])]}
        elif payload["model"] == fail:
          result = {"error": "model is busy"}
        else:
          result = {"done": True}
        return contextlib.closing(io.StringIO(json.dumps(result)))

    with patch("sys.argv", ["unload", *extra]), patch("sys.stdin.isatty", return_value=True), patch("urllib.request.build_opener", return_value=Opener()), patch("subprocess.run", return_value=subprocess.CompletedProcess(["gum"], 130 if cancel else 0, stdout="a:latest\n")), contextlib.redirect_stdout(io.StringIO()) as output, contextlib.redirect_stderr(io.StringIO()) as errors:
      try:
        code = APP["main"]()
      except ValueError:
        code = 1
    return code, requests, output.getvalue(), errors.getvalue()

  def test_picker_unloads_only_selected_model(self):
    code, requests, _, _ = self.run_app()
    self.assertEqual(code, 0)
    self.assertEqual(requests[-1][1], {"model": "a:latest", "keep_alive": 0, "stream": False})
    self.assertEqual(len(requests), 2)
    self.assertTrue(all(url.startswith("http://127.0.0.1:11434/") for url, _ in requests))

  def test_picker_display_reaches_the_terminal(self):
    driver = '''
import runpy, subprocess, sys
from unittest.mock import patch
app = runpy.run_path(sys.argv[1] + "/bin/omarchy-agent-unload-ollama")
app["main"].__globals__["request"] = lambda *args: {"models": [{"name": "a:latest"}]}
run = subprocess.run
def picker(args, **kwargs):
  return run([sys.executable, "-c", 'import sys; print("MODEL PICKER", file=sys.stderr); print("a:latest")'], **kwargs)
with patch("sys.argv", ["unload"]), patch("sys.stdin.isatty", return_value=True), patch("subprocess.run", side_effect=picker):
  sys.exit(app["main"]())
'''
    result = subprocess.run([sys.executable, "-c", driver, ROOT], capture_output=True, text=True)
    self.assertEqual(result.returncode, 0, result.stderr)
    self.assertIn("MODEL PICKER", result.stderr)
    self.assertIn("Unloaded a:latest", result.stdout)

  def test_all_unloads_every_resident_model_without_delete_calls(self):
    code, requests, output, _ = self.run_app(["--all"])
    self.assertEqual(code, 0)
    self.assertEqual([payload["model"] for _, payload in requests[1:]], ["a:latest", "b:4b"])
    self.assertTrue(all(url.endswith("generate") for url, _ in requests[1:]))
    self.assertIn("download is kept", output)

  def test_default_tag_resolves_loaded_model(self):
    code, requests, _, _ = self.run_app(["--model", "a"])
    self.assertEqual(code, 0)
    self.assertEqual(requests[-1][1]["model"], "a:latest")

  def test_unloaded_model_is_not_loaded_just_to_unload_it(self):
    code, requests, _, _ = self.run_app(["--model", "absent"])
    self.assertEqual(code, 1)
    self.assertEqual(len(requests), 1)

  def test_empty_list_and_cancellation_make_no_changes(self):
    for options in ({"models": []}, {"cancel": True}):
      code, requests, _, _ = self.run_app(**options)
      self.assertEqual(code, 0)
      self.assertEqual(len(requests), 1)

  def test_partial_failure_is_reported_but_other_models_are_unloaded(self):
    code, requests, output, errors = self.run_app(["--all"], fail="a:latest")
    self.assertEqual(code, 1)
    self.assertEqual(len(requests), 3)
    self.assertIn("model is busy", errors)
    self.assertIn("Unloaded b:4b", output)


unittest.main()
