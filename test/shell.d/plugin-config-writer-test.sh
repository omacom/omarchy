#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
python3 - "$ROOT" <<'PYTEST'
import fcntl, json, os, pathlib, shutil, subprocess, sys, tempfile
root = pathlib.Path(sys.argv[1])
with tempfile.TemporaryDirectory() as tmp:
  home = pathlib.Path(tmp)
  config = home / ".config/omarchy/shell.json"
  plugins = config.parent / "plugins"
  folder = plugins / "acme.old"
  folder.mkdir(parents=True)
  (folder / "manifest.json").write_text(json.dumps({"id":"acme.new", "renamedFrom":["acme.old"]}))
  original = {"version":1,"plugins":[{"id":"acme.old","settings":{"value":42}}],"bar":{"layout":{"left":["acme.old"]}},"disabledPlugins":["acme.old"]}
  config.write_text(json.dumps(original))
  stubs = home / "stubs"
  stubs.mkdir()
  for name in ("ready", "release"):
    os.mkfifo(home / name)
  (stubs / "jq").write_text('#!/bin/bash\n' + shutil.which("jq") + ' "$@" > "$HOME/jq-result" || exit $?\nprintf ready > "$HOME/ready"\nread -r go < "$HOME/release"\ncat "$HOME/jq-result"\n')
  (stubs / "omarchy-shell").write_text("#!/bin/bash\nexit 0\n")
  for file in stubs.iterdir(): file.chmod(0o755)
  env = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(root), PATH=f"{stubs}:{root}/bin:"+os.environ["PATH"])
  writer = subprocess.Popen([str(root/"bin/omarchy-bar"),"position","bottom"], env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  try:
    with (home/"ready").open() as ready: ready.read()
    lockpath = config.parent / ".plugin-id.lock"
    held = False
    if lockpath.exists():
      with lockpath.open("a") as lock:
        try: fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError: held = True
    migration = subprocess.Popen([str(root/"bin/omarchy-plugin-id"),"migrate",str(folder),"acme.old"],env=env,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    # On the old writer the migration can finish while jq holds its stale copy.
    # With coordinated writers, release jq so the migration can take the lock.
    if not held:
      out, err = migration.communicate(timeout=10)
      assert migration.returncode == 0, err
    with (home/"release").open("w") as release: release.write("go\n")
    out, err = writer.communicate(timeout=10)
    assert writer.returncode == 0, err
    if held:
      out, err = migration.communicate(timeout=10)
      assert migration.returncode == 0, err
    saved = json.loads(config.read_text())
    assert saved["plugins"][0]["id"] == "acme.new", "concurrent CLI save restored the old plugin ID"
    assert saved["bar"]["layout"]["left"] == ["acme.new"]
    assert saved["bar"]["position"] == "bottom"
    assert saved["pluginIdAliases"] == {"acme.old":"acme.new"}
    print("ok - CLI configuration transaction and rename serialize without losing either edit")
    # The live shell may already hold an old snapshot when the migration starts.
    # Persist it through the same production writer used by the shell.
    original["bar"]["position"] = "top"
    original["pluginIdAliases"] = {"acme.fake":"acme.new"}
    result = subprocess.run([str(root/"bin/omarchy-plugin-id"),"config-save"],input=json.dumps(original),text=True,env=env,capture_output=True,timeout=10)
    assert result.returncode == 0, result.stderr
    saved = json.loads(config.read_text())
    assert saved["plugins"][0] == {"id":"acme.new","settings":{"value":42}}
    assert saved["bar"]["layout"]["left"] == ["acme.new"]
    assert saved["disabledPlugins"] == ["acme.new"]
    assert saved["pluginIdAliases"] == {"acme.old":"acme.new"}
    assert saved["bar"]["position"] == "top"
    print("ok - an older shell snapshot preserves committed aliases and migrates its references")
  finally:
    if writer.poll() is None: writer.kill(); writer.wait()
    if "migration" in locals() and migration.poll() is None: migration.kill(); migration.wait()
PYTEST
