#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

python3 - "$ROOT" <<'PY'
import contextlib
import io
import json
from pathlib import Path
import sys
from types import ModuleType, SimpleNamespace
from unittest.mock import patch

command = Path(sys.argv[1]) / "bin/omarchy-debug-pytorch"
code = compile(command.read_text().split("<<'PY'\n", 1)[1].rsplit("\nPY", 1)[0], str(command), "exec")


def run(args, cuda=False, hip=None, xpu=False, failure=False):
  calls = []
  module = ModuleType("torch")
  module.__version__ = "test-build"
  module.version = SimpleNamespace(cuda="13.0" if cuda and not hip else None, hip=hip)
  module.no_grad = contextlib.nullcontext
  module.cuda = SimpleNamespace(
    is_available=lambda: cuda, device_count=lambda: 1, get_device_name=lambda index: "Test GPU"
  )
  module.xpu = SimpleNamespace(
    is_available=lambda: xpu, device_count=lambda: 1, get_device_name=lambda index: "Test XPU"
  )

  class Matrix:
    def __matmul__(self, other):
      if failure:
        raise RuntimeError("missing GPU kernel")
      return self

    def sum(self):
      return self

    def item(self):
      return 32768

  def ones(size, device):
    calls.append((size, device))
    return Matrix()

  module.ones = ones
  output = io.StringIO()
  with (
    patch.dict(sys.modules, {"torch": module}),
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


for parameters, expected in [
  ({}, "cpu"),
  ({"cuda": True}, "cuda"),
  ({"cuda": True, "hip": "7.0"}, "cuda"),
  ({"xpu": True}, "xpu"),
]:
  status, calls, output = run(["--json"], **parameters)
  report = json.loads(output)
  assert status == 0 and report["device"] == expected and calls == [((32, 32), expected)], output
  assert report["rocm_build"] == parameters.get("hip") and report["matrix_check"] == "passed"
print("ok - selects CPU, CUDA, ROCm and XPU correctly and checks the selected device")

status, calls, output = run(["--require-gpu"])
assert status == 1 and not calls
status, calls, output = run(["--device", "cuda"])
assert status == 1 and not calls
status, calls, output = run(["--device", "cpu", "--json"], cuda=True)
assert status == 0 and json.loads(output)["device"] == "cpu"
print("ok - GPU-required and unavailable-device requests fail before allocation, while explicit CPU stays CPU")

status, calls, output = run(["--json"], cuda=True, failure=True)
assert status == 1 and "missing GPU kernel" in output and "matrix_check" not in output
print("ok - a real operation failure is reported instead of trusting availability alone")
PY
