#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

write_plugin() {
  local dir="$1"
  local id="$2"
  local name="$3"

  mkdir -p "$dir"
  cat >"$dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$id",
  "name": "$name",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "$name",
    "category": "Test",
    "allowMultiple": false
  }
}
JSON
  printf 'import QtQuick\nItem {}\n' >"$dir/Widget.qml"
}

stub_dir="$TMPDIR/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stub_dir/omarchy-shell"

test_home="$TMPDIR/home"
write_plugin "$test_home/.config/omarchy/plugins/different-folder" "acme.same" "Installed"

incoming="$TMPDIR/incoming"
write_plugin "$incoming" "acme.same" "Incoming"
git -C "$incoming" init -q
git -C "$incoming" add .
git -C "$incoming" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"

output=$(HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
  omarchy-plugin-add "$incoming" --yes 2>&1) &&
  fail "plugin add accepts an id already installed under another directory" "$output"
grep -qF "plugin id 'acme.same' is already used by" <<<"$output" ||
  fail "plugin add explains the installed id collision" "$output"
[[ ! -e $test_home/.config/omarchy/plugins/acme.same ]] ||
  fail "plugin add leaves a target behind after refusing a duplicate id"
pass "plugin add refuses an installed manifest id regardless of directory name"

# --- URL transport-helper guard -------------------------------------------
#
# The guard refuses git transport helpers (`<name>::…`) and option-shaped URLs
# before `git clone` runs, matching omarchy-theme-install. A git stub records
# whether clone was reached, so the guard is exercised with no network: reaching
# the stub proves a URL passed the guard; not reaching it proves the guard
# rejected the URL first.

guard_stubs="$TMPDIR/guard-stubs"
mkdir -p "$guard_stubs"
cat >"$guard_stubs/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$guard_stubs/omarchy-shell"

clone_marker="$TMPDIR/git-clone-reached"
cat >"$guard_stubs/git" <<STUB
#!/bin/bash
if [[ \$1 == "clone" ]]; then
  touch "$clone_marker"
  exit 1
fi
exit 0
STUB
chmod +x "$guard_stubs/git"

# A gum stub that answers `gum input` with a caller-chosen value, so a test can
# drive any URL through the interactive prompt path.
cat >"$guard_stubs/gum" <<'STUB'
#!/bin/bash
if [[ $1 == "input" ]]; then
  printf '%s\n' "$GUM_INPUT_VALUE"
fi
STUB
chmod +x "$guard_stubs/gum"

add_url() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$guard_stubs:$ROOT/bin:$PATH" \
    omarchy-plugin-add "$1" --yes 2>&1
}

# Transport helpers reach the guard, are named as such, and never reach clone.
for bad in "ext::sh -c touch /tmp/omarchy-guard-test" "fd::17"; do
  rm -f "$clone_marker"
  output=$(add_url "$bad") &&
    fail "plugin add rejects a transport-helper URL: $bad" "$output"
  grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "plugin add names the transport-helper rejection: $bad" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for a transport-helper URL: $bad"
done
pass "plugin add rejects transport-helper URLs before cloning"

# The `://` spelling of the same thing: git resolves git-remote-<scheme> for any
# scheme it does not implement itself, so `ext::` and `ext://` reach the same
# helper and both have to be refused.
for bad in "ext://sh -c id" "gcrypt://example.com/x"; do
  rm -f "$clone_marker"
  output=$(add_url "$bad") &&
    fail "plugin add rejects a transport-scheme URL: $bad" "$output"
  grep -qF "which Omarchy does not clone from" <<<"$output" ||
    fail "plugin add names the transport-scheme rejection: $bad" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for a transport-scheme URL: $bad"
done
pass "plugin add rejects transport-scheme URLs before cloning"

# Option-shaped URLs on argv are refused before clone — by the option parser
# (`-*` falls to "unknown add option"), not the guard. The guard's own
# leading-dash arm is only reachable through the interactive gum prompt and is
# exercised separately below.
for bad in "-oProxyCommand=x" "--upload-pack=x"; do
  rm -f "$clone_marker"
  output=$(add_url "$bad") &&
    fail "plugin add rejects an option-shaped URL: $bad" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for an option-shaped URL: $bad"
done
pass "plugin add rejects option-shaped URLs before cloning"

# The guard's leading-dash arm is only reachable through `gum input`: argv
# dashes die in the option parser first. interactive() requires a TTY on stdin
# and stdout, so run this one case on a pty via util-linux `script -qec` (the
# suite's existing pty idiom); gum itself is stubbed, so no rendering happens.
# Probe script's util-linux syntax first and skip cleanly where it is missing.
if script -qec true /dev/null >/dev/null 2>&1; then
  rm -f "$clone_marker"
  status=0
  raw=$(GUM_INPUT_VALUE="-oProxyCommand=x" HOME="$test_home" OMARCHY_PATH="$ROOT" \
    PATH="$guard_stubs:$ROOT/bin:$PATH" \
    script -qec "omarchy-plugin-add --yes" /dev/null) || status=$?
  output=$(tr -d '\r' <<<"$raw")
  (( status != 0 )) ||
    fail "plugin add rejects an option-shaped URL from the gum prompt" "$output"
  grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "plugin add names the guard rejection for the gum-prompt URL" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for an option-shaped gum-prompt URL"
  pass "plugin add guard rejects an option-shaped URL from the interactive prompt"
else
  skip "script -qec unavailable; skipping the interactive gum-prompt guard case"
fi

# Legitimate URL forms pass the guard and reach git clone (stubbed, no network).
for good in \
  "https://github.com/acme/omarchy-weather.git" \
  "git@github.com:acme/repo.git" \
  "ssh://git@github.com/acme/repo.git" \
  "git@[2001:db8::1]:org/repo.git"; do
  rm -f "$clone_marker"
  output=$(add_url "$good") || true
  ! grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "plugin add wrongly rejected a legitimate URL: $good" "$output"
  [[ -e $clone_marker ]] ||
    fail "plugin add did not reach git clone for a legitimate URL: $good" "$output"
done
pass "plugin add lets legitimate git URLs reach git clone"

# Exercise real Git updates and configuration migration, including interruption
# between the durable config commit and the directory move. Only shell IPC is
# stubbed; all identity, validation, Git and filesystem operations are real.
ROOT="$ROOT" MIGRATION_TMP="$TMPDIR/migrations" python3 - <<'PY'
import json
import os
from pathlib import Path
import signal
import subprocess
import time

root = Path(os.environ["ROOT"])
base = Path(os.environ["MIGRATION_TMP"])
base.mkdir()
old, new = "acme.old-name", "acme.new-name"

def run(args, env=None, ok=True):
  result = subprocess.run(args, env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  if ok and result.returncode:
    raise AssertionError(result.stdout)
  if not ok and not result.returncode:
    raise AssertionError("unexpected success: " + result.stdout)
  return result

def fixture(name, declaration=True):
  case = base / name
  upstream = case / "upstream"
  upstream.mkdir(parents=True)
  manifest = {"schemaVersion": 1, "id": old, "name": "Rename test", "version": "1.0",
              "kinds": ["bar-widget"], "entryPoints": {"barWidget": "Widget.qml"}}
  (upstream / "manifest.json").write_text(json.dumps(manifest))
  (upstream / "Widget.qml").write_text("import QtQuick\nItem {}\n")
  run(["git", "-C", str(upstream), "init", "-q"])
  def commit():
    run(["git", "-C", str(upstream), "add", "."])
    run(["git", "-C", str(upstream), "-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "Plugin version"])
  commit()
  home = case / "home"
  plugins = home / ".config/omarchy/plugins"
  plugins.mkdir(parents=True)
  run(["git", "clone", "-q", str(upstream), str(plugins / old)])
  config = plugins.parent / "shell.json"
  original = {"plugins": [{"id": old, "custom": {"text": old}}], "disabledPlugins": [old],
              "cloneSourceRestores": [old], "bar": {"id": old, "layout": {
                "left": [{"id": "omarchy.menu"}], "right": [{"id": old, "value": 42}, {"id": "omarchy.clock"}]}}}
  config.write_text(json.dumps(original))
  manifest["id"] = new
  if declaration:
    manifest["renamedFrom"] = [old]
  (upstream / "manifest.json").write_text(json.dumps(manifest))
  commit()
  stubs = case / "stubs"
  stubs.mkdir()
  shell = stubs / "omarchy-shell"
  shell.write_text('#!/bin/bash\nprintf "%s\\n" "$*" >> "$HOME/ipc.log"\nif [[ $2 == "listPlugins" ]]; then echo "[]"; else echo ok; fi\n')
  shell.chmod(0o755)
  env = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(root), PATH=str(stubs)+":"+str(root / "bin")+":"+os.environ["PATH"])
  return case, plugins, config, original, env

def update(env, key=old, ok=True):
  return run([str(root / "bin/omarchy-plugin-update"), key, "--yes"], env, ok)

def unchanged(plugins, config, original):
  assert json.loads(config.read_text()) == original
  assert json.loads((plugins / old / "manifest.json").read_text())["id"] == old
  assert not (plugins / new).exists()

case, plugins, config, original, env = fixture("success")
update(env)
value = json.loads(config.read_text())
assert value["plugins"] == [{"id": new, "custom": {"text": old}}]
assert value["disabledPlugins"] == value["cloneSourceRestores"] == [new]
assert value["bar"]["id"] == new
assert value["bar"]["layout"]["right"] == [{"id": new, "value": 42}, {"id": "omarchy.clock"}]
assert value["pluginIdAliases"] == {old: new}
assert (plugins / new).is_dir() and not (plugins / old).exists()
update(env, new)
update(env, old)
for command in ("omarchy-plugin-enable", "omarchy-plugin-disable"):
  run([str(root / "bin" / command), old], env)
assert "enablePlugin " + new in (case / "home/ipc.log").read_text()
assert "setPluginEnabled " + new in (case / "home/ipc.log").read_text()
assert run([str(root / "bin/omarchy-bar"), "get", old, "value"], env).stdout.strip() == "42"
value["bar"]["layout"]["right"].append({"id": "custom module", "type": "command", "value": 7})
config.write_text(json.dumps(value))
assert run([str(root / "bin/omarchy-bar"), "get", "custom module", "value"], env).stdout.strip() == "7"
run([str(root / "bin/omarchy-plugin-id"), "directory", "../outside"], env, ok=False)
# A second rename flattens older aliases without changing settings.
latest = "acme.latest-name"
upstream = case / "upstream"
manifest = json.loads((upstream / "manifest.json").read_text())
manifest.update(id=latest, renamedFrom=[old, new])
(upstream / "manifest.json").write_text(json.dumps(manifest))
run(["git", "-C", str(upstream), "add", "."])
run(["git", "-C", str(upstream), "-c", "user.name=Test", "-c", "user.email=test@example.com", "commit", "-qm", "Rename again"])
update(env, old)
assert json.loads(config.read_text())["pluginIdAliases"] == {old: latest, new: latest}
assert run([str(root / "bin/omarchy-plugin-id"), "resolve", old], env).stdout.strip() == latest
run([str(root / "bin/omarchy-plugin-remove"), old, "--yes"], env)
assert not (plugins / latest).exists()
print("PASS: declared renames preserve settings, placement and state; old IDs support update, enable, disable, bar get and removal", flush=True)

for kind in ("undeclared", "target-directory", "target-symlink", "duplicate-id", "saved-target", "dirty", "read-only", "move-failure"):
  case, plugins, config, original, env = fixture(kind, kind != "undeclared")
  if kind == "target-directory":
    (plugins / new).mkdir()
  elif kind == "target-symlink":
    (plugins / new).symlink_to(case / "missing")
  elif kind == "duplicate-id":
    other = plugins / "different-folder"
    other.mkdir()
    (other / "manifest.json").write_text(json.dumps({"id": new}))
  elif kind == "saved-target":
    original["plugins"].append({"id": new, "setting": "keep"})
    config.write_text(json.dumps(original))
  elif kind == "dirty":
    (plugins / old / "local.txt").write_text("keep my edits")
  elif kind == "read-only":
    config.chmod(0o400)
  elif kind == "move-failure":
    stub = case / "stubs/mv"
    stub.write_text("#!/bin/bash\nexit 1\n")
    stub.chmod(0o755)
  result = update(env, ok=False)
  assert json.loads(config.read_text()) == original, result.stdout
  assert json.loads((plugins / old / "manifest.json").read_text())["id"] == old, result.stdout
  if kind == "dirty":
    assert (plugins / old / "local.txt").read_text() == "keep my edits"
  print("PASS: rename safely refuses " + kind, flush=True)

case, plugins, config, original, env = fixture("interruption")
marker = case / "moving"
stub = case / "stubs/mv"
stub.write_text('#!/bin/bash\ntouch "'+str(marker)+'"\nexec sleep 30\n')
stub.chmod(0o755)
with (case / "interrupted.log").open("w") as log:
  process = subprocess.Popen([str(root / "bin/omarchy-plugin-update"), old, "--yes"], env=env, stdout=log, stderr=log, start_new_session=True)
  try:
    deadline = time.monotonic() + 10
    while not marker.exists() and process.poll() is None and time.monotonic() < deadline:
      time.sleep(0.02)
    assert marker.exists(), (case / "interrupted.log").read_text()
    assert os.getpgid(process.pid) == process.pid
  finally:
    if process.poll() is None:
      os.killpg(process.pid, signal.SIGKILL)
    process.wait()
assert json.loads(config.read_text())["plugins"][0]["id"] == new
assert (plugins / old).is_dir()
assert run([str(root / "bin/omarchy-plugin-id"), "directory", new], env).stdout.strip() == str(plugins / old)
stub.unlink()
update(env, new)
assert (plugins / new).is_dir() and not (plugins / old).exists()
assert json.loads(config.read_text())["plugins"][0]["custom"] == {"text": old}
print("PASS: interrupted config-first migration resolves the manifest and resumes its directory move", flush=True)
# These paths must still produce shell-usable defaults and removable links.
errors = []
for state in ("missing", "blank"):
  case, plugins, config, original, env = fixture("config-" + state)
  if state == "missing":
    config.unlink()
  else:
    config.write_text(" \n")
  result = subprocess.run([str(root / "bin/omarchy-plugin-update"), old, "--yes"], env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  expected = json.loads((root / "config/omarchy/shell.json").read_text())
  expected["pluginIdAliases"] = {old: new}
  try:
    actual = json.loads(config.read_text())
  except ValueError:
    actual = None
  if result.returncode or actual != expected:
    errors.append(state + " config did not preserve effective defaults")
case, plugins, config, original, env = fixture("dangling-remove")
link = plugins / "acme.broken"
link.symlink_to(case / "removed-source")
result = subprocess.run([str(root / "bin/omarchy-plugin-remove"), "acme.broken", "--yes"], env=env, text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
if result.returncode or link.is_symlink():
  errors.append("dangling plugin link cannot be removed")
assert not errors, errors
print("PASS: missing/blank config starts from complete defaults and dangling links remain removable", flush=True)

PY
