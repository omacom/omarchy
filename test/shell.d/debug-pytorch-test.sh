#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

python3 - "$ROOT" <<'PY'
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

command = Path(sys.argv[1]) / "bin/omarchy-debug-pytorch"
fixture = tempfile.TemporaryDirectory()
directory = Path(fixture.name)
interpreter = directory / "python3"
interpreter.write_text('#!/bin/bash\nprintf selected >"$OMARCHY_TEST_PYTHON_TRACE"\nexec "$OMARCHY_TEST_PYTHON" "$@"\n')
interpreter.chmod(0o700)
(directory / "torch.py").write_text("""
import contextlib
import json
import os
from pathlib import Path
from types import SimpleNamespace

config = json.loads(os.environ["OMARCHY_TEST_TORCH_CONFIG"])
__version__ = "test-build"
version = SimpleNamespace(cuda="13.0" if config["cuda"] and not config["hip"] else None, hip=config["hip"])
no_grad = contextlib.nullcontext
cuda = SimpleNamespace(
  is_available=lambda: config["cuda"], device_count=lambda: 1, get_device_name=lambda index: "Test GPU"
)
xpu = SimpleNamespace(
  is_available=lambda: config["xpu"], device_count=lambda: 1, get_device_name=lambda index: "Test XPU"
)

class Matrix:
  def __matmul__(self, other):
    if config["failure"]:
      raise RuntimeError("missing GPU kernel")
    return self

  def sum(self):
    return self

  def item(self):
    return 32768

def ones(size, device):
  Path(os.environ["OMARCHY_TEST_TORCH_TRACE"]).write_text(json.dumps([list(size), device]))
  return Matrix()
""")


def run(args, cuda=False, hip=None, xpu=False, failure=False):
  trace = directory / "trace.json"
  trace.unlink(missing_ok=True)
  selected = directory / "interpreter.txt"
  selected.unlink(missing_ok=True)
  env = dict(os.environ, PATH=f"{directory}:{os.environ['PATH']}", PYTHONPATH=str(directory))
  env["OMARCHY_TEST_TORCH_CONFIG"] = json.dumps({"cuda": cuda, "hip": hip, "xpu": xpu, "failure": failure})
  env["OMARCHY_TEST_TORCH_TRACE"] = str(trace)
  env["OMARCHY_TEST_PYTHON"] = sys.executable
  env["OMARCHY_TEST_PYTHON_TRACE"] = str(selected)
  result = subprocess.run(["bash", str(command), *args], env=env, text=True, capture_output=True)
  assert selected.exists(), "the launcher must use python3 from the active PATH"
  calls = []
  if trace.exists():
    size, device = json.loads(trace.read_text())
    calls.append((tuple(size), device))
  return result.returncode, calls, result.stdout + result.stderr


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
print("ok - the real launcher selects the active interpreter and checks CPU, CUDA, ROCm and XPU")

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
fixture.cleanup()
PY
