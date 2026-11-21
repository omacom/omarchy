import contextlib
import ctypes
import errno
import os
from types import SimpleNamespace
import io
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = sys.argv.pop()
COMMAND = ROOT + "/bin/omarchy-transcode-searchable-pdf"
source = Path(COMMAND).read_text()
python_source = source.split("<<'PY'\n", 1)[1].rsplit("\nPY\n", 1)[0]
APP = {"__name__": "searchable_pdf"}
exec(compile(python_source, COMMAND, "exec"), APP)


class SearchablePdfTest(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.source = Path(self.tmp.name) / "scan $(no-command).pdf"
    self.source.write_bytes(b"original PDF")
    self.output = self.source.with_name(self.source.stem + ".searchable.pdf")
    self.calls = []

  def run_app(self, failure=False, race=False, missing=False):
    def run(argv, **kwargs):
      self.calls.append(argv)
      if argv[0] == "omarchy-cmd-missing":
        return subprocess.CompletedProcess(argv, 0 if missing else 1)
      Path(argv[-1]).write_bytes(b"searchable PDF")
      if race:
        self.output.write_bytes(b"another process")
      if failure:
        raise subprocess.CalledProcessError(1, argv)
      return subprocess.CompletedProcess(argv, 0)

    with patch("sys.argv", ["ocr", str(self.source), "--language", "eng+hin"]), patch("subprocess.run", side_effect=run), contextlib.redirect_stdout(io.StringIO()):
      APP["main"]()

  @contextlib.contextmanager
  def without_hardlinks(self):
    # CI exercises the real Linux no-replace syscall. On other hosts emulate
    # that one primitive with an atomic hard link, keeping the full command real.
    real_link = os.link

    def rename(_source_fd, source, _target_fd, target, flags):
      self.assertEqual(flags, 1)  # RENAME_NOREPLACE
      try:
        real_link(source, target)
      except OSError as error:
        ctypes.set_errno(error.errno)
        return -1
      os.unlink(source)
      return 0

    api = (contextlib.nullcontext() if sys.platform == "linux" else
           patch("ctypes.CDLL", return_value=SimpleNamespace(renameat2=rename)))
    with patch("os.link", side_effect=OSError(errno.EOPNOTSUPP, "no hard links")), api:
      yield

  def test_success_on_a_filesystem_without_hardlinks(self):
    with self.without_hardlinks():
      self.run_app()
    self.assertEqual(self.output.read_bytes(), b"searchable PDF")
    self.assertEqual(self.source.read_bytes(), b"original PDF")
    self.assertEqual(list(self.output.parent.glob(".omarchy-ocr-*")), [])

  def test_no_hardlink_publish_keeps_a_racing_destination(self):
    with self.without_hardlinks(), self.assertRaises(FileExistsError):
      self.run_app(race=True)
    self.assertEqual(self.output.read_bytes(), b"another process")
    self.assertEqual(self.source.read_bytes(), b"original PDF")

  def test_permission_failures_do_not_try_an_alternate_publish(self):
    with patch("os.link", side_effect=PermissionError(errno.EACCES, "denied")), \
         patch("ctypes.CDLL") as libc, self.assertRaises(PermissionError):
      self.run_app()
    libc.assert_not_called()
    self.assertFalse(self.output.exists())
    self.assertEqual(self.source.read_bytes(), b"original PDF")

  def test_missing_no_replace_primitive_does_not_publish(self):
    with patch("os.link", side_effect=OSError(errno.EOPNOTSUPP, "no links")), \
         patch("ctypes.CDLL", return_value=SimpleNamespace()), \
         self.assertRaisesRegex(OSError, "Atomic no-replace rename is unavailable"):
      self.run_app()
    self.assertFalse(self.output.exists())
    self.assertEqual(self.source.read_bytes(), b"original PDF")
    self.assertEqual(list(self.output.parent.glob(".omarchy-ocr-*")), [])

  def test_bash_entrypoint_preserves_help_and_argument_errors(self):
    env = dict(os.environ, HOME=self.tmp.name, XDG_CONFIG_HOME=self.tmp.name + "/config")
    help_result = subprocess.run([COMMAND, "--help"], env=env, capture_output=True, text=True)
    self.assertEqual(help_result.returncode, 0, help_result.stderr)
    self.assertIn("omarchy-transcode-searchable-pdf", help_result.stdout)
    invalid = subprocess.run([COMMAND], env=env, capture_output=True, text=True)
    self.assertEqual(invalid.returncode, 2)
    self.assertIn("pdf", invalid.stderr)

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

  def test_missing_dependency_points_to_aur_and_does_not_create_output(self):
    with self.assertRaisesRegex(ValueError, "pkg aur add ocrmypdf"):
      self.run_app(missing=True)
    self.assertFalse(self.output.exists())
    self.assertEqual(len(self.calls), 1)


unittest.main()
