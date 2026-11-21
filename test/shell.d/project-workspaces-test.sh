#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT" <<'PYTHON'
import json
import os
from pathlib import Path
import shlex
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory(prefix="omarchy projects ") as temporary:
  base = Path(temporary)
  directory = base / "project's $(touch INJECTED); demo"
  directory.mkdir()
  mocks = base / "bin"
  mocks.mkdir()
  log = base / "calls"
  clients = base / "clients"
  clients.write_text("[]")
  (mocks / "hyprctl").write_text('''#!/usr/bin/env python3
import json, os, pathlib, sys
with open(os.environ["TEST_CALLS"], "a") as log:
  log.write(json.dumps(sys.argv[1:]) + "\\n")
if sys.argv[1] == "clients":
  print(pathlib.Path(os.environ["TEST_CLIENTS"]).read_text())
if sys.argv[1:3] == ["dispatch", "exec"] and os.environ.get("TEST_FAIL_EXEC"):
  sys.exit(1)
''')
  (mocks / "omarchy-launch-browser").write_text('''#!/usr/bin/env python3
import json, os, sys
with open(os.environ["TEST_CALLS"], "a") as log:
  log.write(json.dumps(["browser", *sys.argv[1:]]) + "\\n")
''')
  (mocks / "omarchy-menu-select").write_text("#!/bin/sh\nprintf 'demo\\n'\n")
  for file in mocks.iterdir(): file.chmod(0o755)
  env = dict(os.environ, XDG_CONFIG_HOME=str(base / "config"), PATH=str(mocks) + ":" + os.environ["PATH"], TEST_CALLS=str(log), TEST_CLIENTS=str(clients))
  def call(*args, success=True, override=None):
    result = subprocess.run(["bash", str(root / "bin/omarchy-project"), *args], env=env | (override or {}), capture_output=True, text=True)
    assert (result.returncode == 0) == success, result.stderr
    return result
  call("init", "demo", str(directory))
  recipe_path = base / "config/omarchy/projects/demo.json"
  assert recipe_path.stat().st_mode & 0o777 == 0o600
  original = recipe_path.read_bytes()
  call("init", "demo", str(directory), success=False)
  assert recipe_path.read_bytes() == original
  call("init", "../escape", str(directory), success=False)
  assert call("list").stdout == "demo\n"
  recipe = json.loads(original)
  recipe["terminals"] = [[], ["python3", "-c", "print('literal $HOME; $(touch INJECTED)')"]]
  recipe["urls"] = ["https://example.com/?q=$(touch%20INJECTED)"]
  recipe_path.write_text(json.dumps(recipe))
  assert json.loads(call("show", "demo").stdout) == recipe
  call("open", "demo")
  calls = [json.loads(line) for line in log.read_text().splitlines()]
  launches = [argv for argv in calls if argv[:2] == ["dispatch", "exec"]]
  assert len(launches) == 2
  assert ["dispatch", "workspace", "name:project-demo"] in calls
  for launch, argv in zip(launches, recipe["terminals"]):
    command = launch[2]
    prefix = "[workspace name:project-demo silent] "
    assert command.startswith(prefix)
    expected = ["uwsm-app", "--", "xdg-terminal-exec", "--dir=" + str(directory.resolve())] + (["-e", *argv] if argv else [])
    # Have a real shell parse the dispatched command without launching apps.
    parsed = subprocess.run(["bash", "-c", "set -- " + command[len(prefix):] + "; printf '%s\\0' \"$@\""], cwd=base, capture_output=True, check=True)
    assert parsed.stdout.decode().split("\0")[:-1] == expected, (parsed.stdout, expected, command)
  assert not (base / "INJECTED").exists()
  assert ["browser", recipe["urls"][0]] in calls
  clients.write_text('[{"workspace":{"name":"project-demo"}}]')
  log.write_text("")
  call("open", "demo")
  assert not any(json.loads(line)[:2] == ["dispatch", "exec"] for line in log.read_text().splitlines())
  log.write_text("")
  call("open", "demo", "--launch")
  assert sum(json.loads(line)[:2] == ["dispatch", "exec"] for line in log.read_text().splitlines()) == 2
  log.write_text("")
  call() # Picker chooses and focuses the saved project.
  assert 'name:project-demo' in log.read_text()
  for bad in [dict(recipe, urls=["file:///etc/passwd"]), dict(recipe, terminals=["echo oops"]), dict(recipe, version=2), dict(recipe, directory="/does/not/exist"), dict(recipe, terminals=[["missing-omarchy-test-command"]])]:
    recipe_path.write_text(json.dumps(bad))
    log.write_text("")
    call("open", "demo", "--launch", success=False)
    assert not any(json.loads(line)[0] in ("dispatch", "browser") for line in log.read_text().splitlines()), "Invalid recipe must fail before any desktop action"
  relative = directory / "tool"
  relative.write_text("#!/bin/sh\nexit 0\n")
  relative.chmod(0o755)
  recipe_path.write_text(json.dumps(dict(recipe, terminals=[["./tool"]])))
  call("open", "demo", "--launch")
  recipe_path.write_text(json.dumps(dict(recipe, terminals=[["missing-omarchy-test-command"]])))
  call("open", "demo") # Focusing existing windows does not require reinstalling their commands.
  recipe_path.write_text(json.dumps(recipe))
  call("open", "demo", "--launch", success=False, override={"TEST_FAIL_EXEC": "1"})
print("ok - project recipes preserve paths and literal argv, reject invalid input before launch, focus existing workspaces, support the picker, and report dispatch failure")
PYTHON
