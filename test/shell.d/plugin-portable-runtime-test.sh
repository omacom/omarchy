#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const vm = require('vm')
const source = fs.readFileSync(path.join(root, 'shell/shell.qml'), 'utf8')
const scope = vm.createContext({_pluginShellApis: {}, _pluginShellApiDescriptors: {},
  _pluginAppLibraryApis: {}, _pluginFirstPartyServiceApis: {}, _pluginBarEntryShellApis: {}})
scope.shell = scope
for (const name of ['cacheWithoutKey', 'cacheWithoutPrefix', 'revokePluginShellApi', 'createScopedPluginShell']) {
  const body = source.match(new RegExp('  function ' + name + '\\([^]*?\\n  \\}'))[0]
  vm.runInContext(body, scope)
}
let destroyed = false
const api = {runtime: {}, destroy() {
  assertEqual(this.runtime, null, 'facade retirement clears runtime bindings before QObject destruction')
  destroyed = true
}}
scope._pluginShellApis['test.portable'] = api
scope._pluginShellApiDescriptors['test.portable'] = {pluginId: 'test.portable', profile: 'same'}
scope.pluginShellCapabilityProfile = () => 'same'
const manifest = {id: 'test.portable', __sourceDir: '/updated', sandbox: {requests: {storage: true}}}
assertEqual(scope.createScopedPluginShell(manifest, 'test.portable', true, false), api, 'unchanged capability profile reuses its facade')
assertEqual(api.runtime.bundlePath, '/updated', 'reused facade refreshes the portable bundle path')
scope.revokePluginShellApi('test.portable')
assert(destroyed && !scope._pluginShellApis['test.portable'], 'retired facade leaves the runtime cache')
const workerView = fs.readFileSync(path.join(root, 'shell/ward-runtime/WidgetView.qml'), 'utf8')
assert(workerView.includes('runtime: root.shell.runtime.scope(widgetLoader)'), 'worker placements give jobs a loader-owned runtime, not a shared facade lifetime')
const worker = fs.readFileSync(path.join(root, 'shell/ward-runtime/worker.qml'), 'utf8')
assert(worker.includes('runtime: shellApi.runtime.scope(serviceLoader)') && worker.includes('runtime: shellApi.runtime.scope(overlayLoader)'), 'service and overlay jobs have separate loader lifetimes')
const spacer = fs.readFileSync(path.join(root, 'shell/services/SandboxedBarWidget.qml'), 'utf8')
const publish = spacer.match(/^  function publish\(\) \{[\s\S]*?^  \}/m)[0]
const retirement = vm.createContext({retired: true})
vm.runInContext(publish + '\npublish()', retirement)
assert(spacer.includes('retired = true\n    if (registeredInstance) registeredInstance.removePlacement(root)'), 'retired spacers reject late queued publication before unregistering their view')
JS

ROOT="$ROOT" python3 -B <<'PY'
import base64
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time

root = Path(os.environ["ROOT"])
with tempfile.TemporaryDirectory() as temporary:
  temp = Path(temporary)
  home, stubs = temp / "home", temp / "stubs"
  stubs.mkdir()
  runtime = temp / "session"
  runtime.mkdir()
  identity = "test.portable"
  bundle = home / ".config/omarchy/plugins" / identity
  bundle.mkdir(parents=True)
  env = dict(os.environ, HOME=str(home), XDG_STATE_HOME=str(home / "state"), XDG_RUNTIME_DIR=str(runtime),
    OMARCHY_PATH=str(root), OMARCHY_WARD_STORE=str(home / "ward"),
    PATH=f"{stubs}:{root / 'bin'}:{os.environ['PATH']}", GIT_CONFIG_GLOBAL="/dev/null")

  def run(*args, ok=True, data=None):
    result = subprocess.run(args, env=env, input=data, capture_output=True, timeout=20)
    assert (result.returncode == 0) == ok, (args, result.stdout, result.stderr)
    return result

  def request(*args, ok=True, data=None):
    return run("omarchy-plugin-runtime", identity, *args, ok=ok, data=data)

  def result(*args, status="completed", **kwargs):
    value = json.loads(request("--json", *args, ok=status == "completed", **kwargs).stdout)
    assert value["version"] == 1 and value["status"] == status, value
    return value

  manifest = dict(schemaVersion=1, id=identity, name="Portable", version="1", kinds=["service"],
    entryPoints={"service": "Service.qml"})
  data_path = home / "state/omarchy/plugins" / identity
  (bundle / "manifest.json").write_text(json.dumps(manifest))
  (bundle / "Service.qml").write_text("import QtQuick\nItem {}\n")
  run("git", "-C", str(bundle), "init", "-q")
  run("git", "-C", str(bundle), "remote", "add", "origin", "https://demo.invalid/portable")
  run("omarchy-plugin-installation", "record", identity, "yolo", "git", "https://demo.invalid/portable", "a" * 40)

  # No native runtime is available or called in this suite.
  (stubs / "omarchy-ward-runtime").write_text("#!/bin/bash\nexit 97\n")
  (stubs / "omarchy-ward-runtime").chmod(0o755)
  code = 'import os,sys; print(os.environ["HOME"]); sys.stderr.buffer.write(b"\\xff"); sys.exit(7)'
  value = result("--local", "/usr/bin/python3", "-c", code)
  assert value["exitCode"] == 7 and value["stdout"].strip() == str(data_path)
  assert value["stderr"] == {"base64": base64.b64encode(b"\xff").decode()}
  raw = request("--local", "/usr/bin/python3", "-c", code, ok=False)
  assert raw.returncode == 7 and raw.stderr == b"\xff"
  print("ok - local commands preserve private HOME, binary output and raw/structured application status")

  child_code = 'import os,json; print(json.dumps({k:os.environ[k] for k in ("HOME","XDG_RUNTIME_DIR","OMARCHY_PLUGIN_DATA")}))'
  value = json.loads(request("--local", "/usr/bin/python3", "-c", child_code).stdout)
  data_path = home / "state/omarchy/plugins" / identity
  assert value["HOME"] == value["OMARCHY_PLUGIN_DATA"] == str(data_path)
  assert value["XDG_RUNTIME_DIR"] == str(runtime / "omarchy/plugins" / identity)
  assert data_path.is_dir() and (data_path.stat().st_mode & 0o777) == 0o700
  # Bare executables stay local; no command basename implicitly crosses a broker.
  value = request("--local", "/bin/bash", "-c", 'python3 -c \'import os; print(os.environ["HOME"])\'')
  assert value.stdout.decode().strip() == str(data_path), value
  assert not list((runtime / "omarchy/plugins" / identity).glob("links-*"))
  print("ok - local processes get private paths and ordinary command lookup")

  grants = json.loads(request("--grants").stdout)
  assert grants["storage"] and grants["desktopGeometry"] and grants["exec"] == {}
  assert grants["filesystem"] == {} and not grants["networkProxy"]
  result("--exec", "missing", status="invalid")
  result("--http", status="invalid", data=b"{}")
  result("--local", "/usr/bin/python3", "-c", 'import sys; sys.stdout.write("x" * 2097153)', status="failed")
  print("ok - in-process runtime exposes no named resources and bounds local output")

  # Descendants cannot keep a completed foreground request's output open.
  value = result("--local", "/usr/bin/python3", "-c", 'import subprocess; subprocess.Popen(["/usr/bin/sleep", "30"]); print("done")')
  assert value["stdout"] == "done\n"
  marker = temp / "child-pid"
  process = subprocess.Popen(["omarchy-plugin-runtime", identity, "--local", "/usr/bin/python3", "-c",
    'import os,time; open(' + repr(str(marker)) + ',"w").write(str(os.getpid())); time.sleep(30)'], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  deadline = time.monotonic() + 5
  while not marker.exists() and time.monotonic() < deadline:
    time.sleep(0.02)
  assert marker.exists()
  pid = int(marker.read_text())
  process.terminate()
  process.communicate(timeout=5)
  assert not Path(f"/proc/{pid}").exists()
  print("ok - foreground completion and caller cancellation clean up owned trusted command processes")

  worker = json.loads(run("/usr/bin/python3", str(root / "shell/plugin-runtime/job.py"),
    "/usr/bin/python3", "-c", code).stdout)
  assert worker["status"] == "completed" and worker["exitCode"] == 7
  assert worker["stderr"] == {"base64": "/w=="}
  print("ok - worker-local jobs use the same owned, bounded, lossless result implementation")

  # QProcess destroys its direct child with SIGKILL, not a catchable signal.
  # The whole local job must still stop, including grandchildren holding pipes.
  hard_marker = temp / "hard-cancel-pids"
  child_code = 'import os,subprocess,time; p=subprocess.Popen(["/usr/bin/sleep","30"]); open(' + repr(str(hard_marker)) + ',"w").write(str(os.getpid())+" "+str(p.pid)); time.sleep(30)'
  process = subprocess.Popen(["/usr/bin/python3", str(root / "shell/plugin-runtime/job.py"),
    "/usr/bin/python3", "-c", child_code], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  deadline = time.monotonic() + 5
  while not hard_marker.exists() and time.monotonic() < deadline:
    time.sleep(0.02)
  assert hard_marker.exists()
  pids = [int(value) for value in hard_marker.read_text().split()]
  process.kill()
  try:
    process.communicate(timeout=5)
    def alive(pid):
      try:
        return Path(f"/proc/{pid}/stat").read_text().split(") ", 1)[1][0] != "Z"
      except FileNotFoundError:
        return False
    deadline = time.monotonic() + 3
    while any(alive(pid) for pid in pids) and time.monotonic() < deadline:
      time.sleep(0.02)
    assert not any(alive(pid) for pid in pids), pids
  finally:
    for pid in pids:
      try:
        os.kill(pid, 9)
      except ProcessLookupError:
        pass
    process.communicate(timeout=5)
  print("ok - killing the outer helper stops its local process group, including grandchildren")

  for name in ("omarchy-notification-send", "omarchy-launch-browser", "omarchy-launch-webapp", "omarchy-shell", "pw-cat"):
    (stubs / name).write_text('#!/usr/bin/python3\nimport json,os,sys\nfrom pathlib import Path\n'
      'Path(os.environ["TEST_OPERATION_LOG"]).write_text(json.dumps(sys.argv))\n'
      'if sys.argv[0].endswith("omarchy-shell"): print("ok")\n'
      'if sys.argv[0].endswith("pw-cat"):\n'
      '  if "--playback" in sys.argv: Path(os.environ["TEST_AUDIO_BYTES"]).write_bytes(sys.stdin.buffer.read())\n'
      '  else: sys.stdout.buffer.write(b"PCM")\n')
    (stubs / name).chmod(0o755)
  env["TEST_OPERATION_LOG"] = str(temp / "operation.json")
  env["TEST_AUDIO_BYTES"] = str(temp / "audio.pcm")
  result("--notify", "--exec", "--image")
  assert json.loads(Path(env["TEST_OPERATION_LOG"]).read_text())[-3:] == ["--", "--exec", "--image"]
  result("--settings", '{"volume": 0.5}')
  assert json.loads(Path(env["TEST_OPERATION_LOG"]).read_text())[-3:] == ["saveTrustedPluginSettings", identity, '{"volume": 0.5}']
  result("--settings", '{"sandbox": false}', status="invalid")
  for mode in ("browser", "webapp"):
    result("--open-url", mode, "https://example.test/a?x=1&y=2")
    assert json.loads(Path(env["TEST_OPERATION_LOG"]).read_text())[-1] == "https://example.test/a?x=1&y=2"
  request("--audio-playback", data=b"\x00\x01\xff\xfe")
  assert Path(env["TEST_AUDIO_BYTES"]).read_bytes() == b"\x00\x01\xff\xfe"
  for operation in ("--microphone", "--audio-capture"):
    raw = request(operation, ok=False)
    assert raw.stdout == b"PCM"
    argv = json.loads(Path(env["TEST_OPERATION_LOG"]).read_text())
    properties = json.loads(argv[argv.index("--properties") + 1])
    assert properties["stream.capture.sink"] == (operation == "--audio-capture")
    result(operation, status="invalid")
  print("ok - notification, settings, links and all PCM directions share the operation contract without touching real devices")

  run("omarchy-plugin-isolation", "mark", identity)
  result("--local", "/usr/bin/python3", "-c", "print('must not run')", status="denied")
  run("omarchy-plugin-isolation", "forget", identity)
  record = home / "state/omarchy/plugin-installations" / identity / "record.json"
  saved = record.read_text()
  record.write_text("null")
  result("--local", "/usr/bin/python3", "-c", "print('must not run')", status="denied")
  record.write_text(saved)
  run("omarchy-plugin-installation", "record", identity, "ward", "git", "https://demo.invalid/portable", "a" * 40)
  result("--local", "/usr/bin/python3", "-c", "print('must not run')", status="denied")
  print("ok - retained isolation, damaged provenance and Ward mode never fall back to trusted execution")

  run("omarchy-plugin-installation", "record", identity, "yolo", "git", "https://demo.invalid/portable", "a" * 40)
  manifest["sandbox"] = {"version": 1, "requests": {}}
  (bundle / "manifest.json").write_text(json.dumps(manifest))
  result("--local", "/usr/bin/true", status="denied")
  print("ok - sandbox declarations never acquire an in-process YOLO path")

PY

qml_runtime=$(mktemp -d)
trap 'rm -r -- "$qml_runtime"' EXIT
mkdir -p "$qml_runtime/config/Services" "$qml_runtime/home"
cp "$ROOT/test/shell.d/fixtures/plugin-portable-runtime/shell.qml" "$qml_runtime/config/"
cp "$ROOT/shell/services/PluginRuntime.qml" "$ROOT/shell/services/PluginRuntime.js" "$ROOT/shell/services/PluginJob.qml" "$qml_runtime/config/Services/"
if ! output=$(env -u DISPLAY -u WAYLAND_DISPLAY HOME="$qml_runtime/home" XDG_RUNTIME_DIR="$qml_runtime" OMARCHY_TEST_LIFETIME_MARKER="$qml_runtime/lifetime-pids" OMARCHY_TEST_LOCAL_RUNNER="$ROOT/shell/plugin-runtime/job.py" QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME=none QT_QUICK_BACKEND=software timeout 6s quickshell -n -p "$qml_runtime/config/shell.qml" 2>&1); then
  fail "portable process QML starts" "$output"
fi
[[ $output == *"portable process QML passed"* ]] || fail "portable process starts after facade injection and preserves argv" "$output"
[[ $output != *"ERROR"* && $output != *"Binding loop"* && $output != *"ReferenceError"* ]] || fail "portable process QML is clean" "$output"
pass "required runtime is ready during initialization; local and named jobs preserve results and cancellation"
