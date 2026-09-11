#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

ROOT="$ROOT" python3 <<'PY'
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(os.environ["ROOT"])
with tempfile.TemporaryDirectory() as temporary:
  temp = Path(temporary)
  home = temp / "home"
  stubs = temp / "stubs"
  stubs.mkdir()
  git = shutil.which("git")
  env = dict(os.environ, HOME=str(home), XDG_STATE_HOME=str(home / "state"),
    OMARCHY_PATH=str(root), OMARCHY_WARD_STORE=str(home / "ward"),
    PATH=f"{stubs}:{root / 'bin'}:{os.environ['PATH']}", GIT_CONFIG_GLOBAL="/dev/null")
  (stubs / "omarchy-shell").write_text('#!/bin/bash\nif [[ $* == *listPlugins* ]]; then echo "[]"; else echo ok; fi\n')
  (stubs / "omarchy-shell").chmod(0o755)
  # Simulate remote transport only. All repository metadata, install decisions,
  # source matching and updates use the real Git binary and production helpers.
  (stubs / "git").write_text(f'''#!/bin/bash
if [[ $1 == "clone" && $3 == https://demo.invalid/* ]]; then
  "{git}" clone -- "$DEMO_SOURCE" "$4" >&2 || exit
  "{git}" -C "$4" config remote.origin.url "$3"
else
  "{git}" "$@"
fi
''')
  (stubs / "git").chmod(0o755)

  def run(*args, ok=True):
    result = subprocess.run(args, env=env, text=True, capture_output=True)
    assert (result.returncode == 0) == ok, (args, result.stdout, result.stderr)
    return result.stdout if ok else result.stdout + result.stderr

  def fixture(identity, sandbox=False):
    source = temp / identity
    source.mkdir()
    manifest = dict(schemaVersion=1, id=identity, name="Demo", version="1", kinds=["bar-widget"], entryPoints={"barWidget": "Widget.qml"})
    if sandbox:
      manifest["sandbox"] = dict(version=1, requests={})
    (source / "manifest.json").write_text(json.dumps(manifest))
    (source / "Widget.qml").write_text("import QtQuick\nItem {}\n")
    run(git, "-C", str(source), "init", "-q")
    run(git, "-C", str(source), "add", ".")
    run(git, "-C", str(source), "-c", "commit.gpgsign=false", "-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "fixture")
    env["DEMO_SOURCE"] = str(source)
    return source

  def records():
    return json.loads(run("omarchy-plugin-installation", "list"))

  def catalog():
    return {row["id"]: row for row in json.loads(run("omarchy-plugin-catalog"))}

  plugins = home / ".config/omarchy/plugins"
  source = fixture("test.yolo")
  assert "--yolo explicitly" in run("omarchy-plugin-add", "https://demo.invalid/yolo", "--yes", ok=False)
  assert not (plugins / "test.yolo").exists()
  assert records() == []
  print("ok - remote non-sandbox installs never infer YOLO from --yes or metadata")
  inspected = json.loads(run("omarchy-plugin-add", "https://demo.invalid/yolo", "--yolo", "--inspect", "--json"))
  assert inspected["mode"] == "yolo" and not inspected["installed"]
  assert records() == [] and not (plugins / "test.yolo").exists()
  assert "changed since validation" in run("omarchy-plugin-add", "https://demo.invalid/yolo", "--yolo", "--yes", "--commit", "0" * 40, ok=False)
  assert records() == [] and not (plugins / "test.yolo").exists()
  print("ok - inspection validates without installing, approving, or enabling")
  added = json.loads(run("omarchy-plugin-add", "https://demo.invalid/yolo", "--yolo", "--yes", "--json"))
  assert added["installed"] and added["mode"] == "yolo"
  assert records()[0]["source"] == "https://demo.invalid/yolo"
  assert catalog()["test.yolo"]["executionMode"] == "yolo"
  assert not catalog()["test.yolo"]["sandboxed"]
  assert "test.yolo" not in json.loads(run("omarchy-plugin-isolation"))
  print("ok - explicit YOLO records host-owned source, commit and visible execution mode")

  checkout = plugins / "test.yolo"
  run(git, "-C", str(checkout), "config", "remote.origin.url", "https://demo.invalid/replaced")
  assert records()[0]["mode"] == "blocked"
  assert catalog()["test.yolo"]["sandboxed"]
  assert "source changed" in run("omarchy-plugin-enable", "test.yolo", ok=False)
  assert "source changed" in run("omarchy-plugin-update", "test.yolo", "--yes", ok=False)
  print("ok - changed source blocks in-process loading, enable and update")
  run(git, "-C", str(checkout), "config", "remote.origin.url", "https://demo.invalid/yolo")
  record_path = home / "state/omarchy/plugin-installations/test.yolo/record.json"
  saved = record_path.read_text()
  record_path.unlink()
  assert records()[0]["mode"] == "blocked" and catalog()["test.yolo"]["sandboxed"]
  record_path.write_text('{"version":1}')
  assert records()[0]["mode"] == "blocked"
  record_path.write_text('[{}]')
  assert records()[0]["mode"] == "blocked"
  record_path.write_text('null')
  assert records()[0]["mode"] == "blocked"
  record_path.write_text(saved)
  manifest = json.loads((checkout / "manifest.json").read_text())
  manifest["id"] = "test.changed"
  (checkout / "manifest.json").write_text(json.dumps(manifest))
  assert catalog()["test.changed"]["sandboxed"]
  print("ok - missing/corrupt records and changed checkout identity fail closed")
  manifest["id"] = "test.yolo"
  (checkout / "manifest.json").write_text(json.dumps(manifest))
  record_path.write_text('null')
  (stubs / "omarchy-ward-runtime").write_text('#!/bin/bash\necho "native must not be needed" >&2\nexit 1\n')
  (stubs / "omarchy-ward-runtime").chmod(0o755)
  run("omarchy-plugin-disable", "test.yolo")
  run("omarchy-plugin-remove", "test.yolo", "--yes")
  assert not checkout.exists() and not record_path.parent.exists()
  run("omarchy-plugin-add", "https://demo.invalid/yolo", "--yolo", "--yes")
  assert catalog()["test.yolo"]["executionMode"] == "yolo"
  print("ok - damaged YOLO can be disabled, removed and explicitly reinstalled without native Ward")

  source = fixture("test.ward", sandbox=True)
  assert "cannot be overridden" in run("omarchy-plugin-add", str(source), "--yolo", "--yes", ok=False)
  added = json.loads(run("omarchy-plugin-add", str(source), "--yes", "--json"))
  assert added["mode"] == "ward"
  assert "test.ward" in json.loads(run("omarchy-plugin-isolation", "retained"))
  shutil.rmtree(plugins / "test.ward")
  manifest = json.loads((source / "manifest.json").read_text())
  manifest.pop("sandbox")
  (source / "manifest.json").write_text(json.dumps(manifest))
  run(git, "-C", str(source), "add", ".")
  run(git, "-C", str(source), "-c", "commit.gpgsign=false", "-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "remove declaration")
  assert "retained Ward identity" in run("omarchy-plugin-add", str(source), "--yolo", "--yes", ok=False)
  print("ok - deleting checkout files or changing a manifest is not explicit full removal")

  source = fixture("test.local")
  assert "requires an existing local" in run("omarchy-plugin-add", "https://demo.invalid/local", "--trusted-local", "--yes", ok=False)
  added = json.loads(run("omarchy-plugin-add", str(source), "--trusted-local", "--yes", "--json"))
  assert added["mode"] == "trusted-local"
  assert catalog()["test.local"]["executionMode"] == "trusted-local"
  print("ok - trusted-local mode is explicit and limited to local Git folders")

  # An invalid incoming revision never touches the installed checkout.
  original = run(git, "-C", str(plugins / "test.local"), "rev-parse", "HEAD")
  (source / "Widget.qml").unlink()
  run(git, "-C", str(source), "add", "-A")
  run(git, "-C", str(source), "-c", "commit.gpgsign=false", "-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "broken revision")
  assert "candidate failed validation" in run("omarchy-plugin-update", "test.local", "--yes", ok=False)
  assert run(git, "-C", str(plugins / "test.local"), "rev-parse", "HEAD") == original
  assert (plugins / "test.local/Widget.qml").exists()
  print("ok - update validates candidate before mutating the live checkout")
PY
