import base64
import contextlib
import io
import json
from pathlib import Path
import runpy
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = sys.argv.pop()
APP = runpy.run_path(ROOT + "/bin/omarchy-capture-describe")


class DescribeTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.image = Path(self.tmp.name) / "a photo $(no-command).png"
    self.data = b"\x89PNG\r\n\x1a\nimage"
    self.image.write_bytes(self.data)
    self.requests = []

  def run_app(self, metadata=None, answer="A landscape", source=None):
    requests = self.requests

    class Opener:
      def open(self, request, timeout):
        requests.append((request.full_url, json.loads(request.data)))
        response = metadata if request.full_url.endswith("show") else {"response": answer}
        return contextlib.closing(io.StringIO(json.dumps(response)))

    argv = ["describe", *(source or [str(self.image)]), "--model", "vision:test"]
    with patch("sys.argv", argv), patch("urllib.request.build_opener", return_value=Opener()), contextlib.redirect_stdout(io.StringIO()) as output:
      result = APP["main"]()
      return result, output.getvalue()

  def test_image_sent_as_base64_with_question(self):
    _, output = self.run_app({"capabilities": ["vision"]})
    self.assertEqual(output, "A landscape\n")
    payload = self.requests[-1][1]
    self.assertEqual(base64.b64decode(payload["images"][0]), self.data)
    self.assertFalse(payload["stream"])
    self.assertTrue(self.requests[-1][0].startswith("http://127.0.0.1:11434/"))

  def test_nonvision_and_cloud_models_rejected_before_upload(self):
    for metadata in ({"capabilities": ["completion"]}, {"capabilities": ["vision"], "remote_model": "cloud-model"}):
      self.requests.clear()
      with self.assertRaises(ValueError):
        self.run_app(metadata)
      self.assertEqual(len(self.requests), 1)
      self.assertNotIn("images", self.requests[0][1])

  def test_invalid_image_never_contacts_model(self):
    self.image.write_text("not an image")
    with self.assertRaises(ValueError):
      self.run_app({"capabilities": ["vision"]})
    self.assertEqual(self.requests, [])

  def test_region_cancel_does_not_capture_or_contact_model(self):
    with patch("subprocess.run", return_value=subprocess.CompletedProcess(["slurp"], 1, stdout="")) as run:
      code, output = self.run_app(source=["--region"])
    self.assertEqual((code, output), (0, ""))
    self.assertEqual(run.call_count, 1)
    self.assertEqual(self.requests, [])

  def test_empty_response_is_failure(self):
    with self.assertRaises(ValueError):
      self.run_app({"capabilities": ["vision"]}, answer="")


unittest.main()
