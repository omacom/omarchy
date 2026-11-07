#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

python3 - "$ROOT" <<'PY'
import contextlib
import io
import json
from pathlib import Path
import sys
import tempfile
from types import ModuleType, SimpleNamespace
from unittest.mock import patch

command = Path(sys.argv[1]) / "bin/omarchy-debug-model-cache"
code = compile(command.read_text().split("<<'PY'\n", 1)[1].rsplit("\nPY", 1)[0], str(command), "exec")


def run(args, directory, unsafe=False):
  calls = []
  module = ModuleType("huggingface_hub")
  constants = ModuleType("huggingface_hub.constants")
  constants.HF_HUB_CACHE = str(directory)

  def scan(path):
    calls.append(path)
    return SimpleNamespace(
      size_on_disk=300,
      warnings=["incomplete\x1b[2J download" if unsafe else "incomplete download"],
      repos=[
        SimpleNamespace(repo_id="org/small\x1b[2J" if unsafe else "org/small", repo_type="model", size_on_disk=100, nb_files=2, revisions={"a"}),
        SimpleNamespace(repo_id="org/large", repo_type="model", size_on_disk=200, nb_files=3, revisions={"a", "b"}),
      ],
    )

  module.scan_cache_dir = scan
  output = io.StringIO()
  with (
    patch.dict(sys.modules, {"huggingface_hub": module, "huggingface_hub.constants": constants}),
    patch.object(sys, "argv", [str(command), *args]),
    contextlib.redirect_stdout(output),
    contextlib.redirect_stderr(output),
  ):
    try:
      exec(code, {"__name__": "__main__"})
      status = 0
    except SystemExit as error:
      status = error.code
  return status, calls, output.getvalue()


with tempfile.TemporaryDirectory() as tmp:
  directory = Path(tmp) / "cache with spaces"
  directory.mkdir()
  sentinel = directory / "weights.bin"
  sentinel.write_bytes(b"valuable weights")
  status, calls, output = run(["--json", "--limit", "1"], directory)
  report = json.loads(output)
  assert status == 0 and calls == [directory], output
  assert report["repositories"] == [{"id": "org/large", "type": "model", "bytes": 200, "files": 3, "revisions": 2}]
  assert report["total_bytes"] == 300 and report["warnings"] == ["incomplete download"]
  assert sentinel.read_bytes() == b"valuable weights" and list(directory.iterdir()) == [sentinel]
  print("ok - sorts repositories by disk use, preserves totals when limiting rows and reports cache warnings")

  missing = Path(tmp) / "not created"
  status, calls, output = run(["--cache", str(missing), "--json"], directory)
  report = json.loads(output)
  assert status == 0 and not calls and not report["exists"] and not missing.exists()
  print("ok - a missing cache is reported without creating directories or scanning elsewhere")

  status, calls, output = run(["--cache", str(sentinel)], directory)
  assert status == 1 and not calls
  status, calls, output = run(["--limit", "0"], directory)
  assert status == 2 and not calls
  print("ok - file paths and invalid limits are refused before scanning")

  controlled = Path(tmp) / "cache\x1b[2J"
  controlled.mkdir()
  status, calls, output = run([], controlled, unsafe=True)
  assert status == 0 and "\x1b" not in output and r"\x1b[2J" in output, output
  status, calls, output = run(["--json"], controlled, unsafe=True)
  report = json.loads(output)
  assert status == 0 and report["cache"] == str(controlled)
  assert report["warnings"] == ["incomplete\x1b[2J download"]
  assert report["repositories"][1]["id"] == "org/small\x1b[2J"
  print("ok - terminal controls in cache paths, repository IDs and warnings are escaped while JSON preserves them")
PY
