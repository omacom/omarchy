#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command git
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch" OMARCHY_PATH="$ROOT" PYTHONDONTWRITEBYTECODE=1
export XDG_CONFIG_HOME="$HOME/.config"
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null

python3 -I <<'PY'
import copy
import hashlib
import json
import os
import re
from pathlib import Path
import shlex
import subprocess
import sys
import tomllib
from types import SimpleNamespace
from unittest.mock import patch

sys.path.insert(0, os.path.join(os.environ["OMARCHY_PATH"], "shell", "plugins", "agents"))
import agent_local as a


def check(name, condition, detail=""):
  if not condition:
    print(f"not ok - {name}", file=sys.stderr)
    if detail:
      print(detail, file=sys.stderr)
    raise SystemExit(1)
  print(f"ok - {name}", flush=True)


def skip(name):
  print(f"ok - {name} # SKIP", flush=True)


def raises(name, fn, message=""):
  try:
    fn()
  except a.LocalError as error:
    check(name, message in str(error), str(error))
    return
  check(name, False, "expected LocalError")


runtime = {
  "image": "registry.example/test/server@sha256:" + "a" * 64,
  "tier": "third-party", "review": "reviews/server.toml", "port": 8080,
  "health": {"path": "/health", "probe": ["curl", "http://localhost:8080/health"]},
  "command": ["server"], "reserved": ["--host", "API_KEY"],
  "inputs": {"model": {"arg": "--model"}, "draft": {"arg": "--draft"},
             "ctx": {"arg": "--ctx"}, "alias": {"arg": "--alias"}, "key": {"env": "API_KEY"}},
}
variant = {"ctx": 4096, "peak_ram_gib": 16, "peak_gpu_gib": 16}
artifact = {"repo": "test/model", "revision": "b" * 40, "license": "mit",
            "files": ["model.gguf", "tokenizer/*.json"], "model": "model.gguf"}
recipe = {"name": "Test model", "summary": "Fixture", "runtime": "server",
          "hardware": [{"gpu": "amd-strix-halo", "ram_class": 64, "measured": "measurements/model.toml"}],
          "artifacts": [artifact], "variant": [variant]}
gpu = {"vendor": "amd", "family": "amd-strix-halo", "memory_gib": 48}
profile = {"platform": "x86", "ram_class": 64, "ram_gib": 64, "gpus": [gpu]}
entry = {"gpu": gpu["family"], "ram_class": 64, "recipes": ["model"]}
check("valid recipe and runtime fixtures are accepted", not a.validate_runtime("server", runtime) and not a.validate_recipe("model", recipe, {"server": runtime}))

for rid in ("..", "a..b", "-a", "a-", ".a", "a."):
  check(f"recipe and runtime reject unsafe id {rid}", bool(a.validate_runtime(rid, runtime)) and bool(a.validate_recipe(rid, recipe, {"server": runtime})))
for name, mutate, fragment in (
  ("reserved input target", lambda r: r["inputs"].update(model={"arg": "--host"}), "targets reserved"),
  ("duplicate input target", lambda r: r["inputs"].update(alias={"arg": "--model"}), "same target"),
  ("host IPC", lambda r: r.update(run={"ipc": "host"}), "not an allowed"),
  ("privileged container", lambda r: r.update(run={"privileged": True}), "not an allowed"),
  ("command line key without opt-in", lambda r: r["inputs"].update(key={"arg": "--key"}), "key_on_cmdline = true"),
  ("command line key without shell", lambda r: (r.update(key_on_cmdline=True), r["inputs"].update(key={"arg": "--key"})), "needs shell"),
):
  changed = copy.deepcopy(runtime)
  mutate(changed)
  check(f"runtime rejects {name}", any(fragment in e for e in a.validate_runtime("server", changed)))
# A key may use its own reserved environment variable, as in the valid fixture.
changed = copy.deepcopy(runtime)
changed.update(key_on_cmdline=True, shell="/bin/bash")
changed["inputs"]["key"] = {"arg": "--host"}
check("key cannot commandeer a reserved argument", any("reserved" in e for e in a.validate_runtime("server", changed)))

for flag in ("--host", "--host=0.0.0.0", "--model", "--model=other"):
  changed = copy.deepcopy(recipe)
  changed["server"] = {"args": [flag]}
  check(f"server args cannot override {flag}", any("server.args" in e for e in a.validate_recipe("model", changed, {"server": runtime})))
for field, value in (("files", ["../weights"]), ("files", ["/weights"]), ("dest", "../outside"), ("dest", "/outside")):
  changed = copy.deepcopy(recipe)
  changed["artifacts"][0][field] = value
  check(f"artifact rejects escaping {field} {value}", any("relative path" in e for e in a.validate_recipe("model", changed, {"server": runtime})))
for role in ("model", "draft"):
  changed = copy.deepcopy(recipe)
  changed["artifacts"][0][role] = "model.gguf"
  changed["artifacts"].append(copy.deepcopy(changed["artifacts"][0]))
  check(f"duplicate {role} role is rejected", any(f".{role}: already named" in e for e in a.validate_recipe("model", changed, {"server": runtime})))
check("identical best selectors are rejected", any("same selectors" in e for e in a.validate_best({"class": [entry, entry]}, {"model": recipe})))
check("best cannot recommend an unmeasured class", any("no measured" in e for e in a.validate_best({"class": [dict(entry, ram_class=128)]}, {"model": recipe})))

catalog = SimpleNamespace(recipes={"model": copy.deepcopy(recipe)}, runtimes={"server": runtime}, best={"class": [entry]})
platform_entry = {"platform": "x86", "ram_class": 64, "recipes": ["other"]}
check("GPU class takes precedence over platform-only class", a.match_class({"class": [platform_entry, entry]}, profile, gpu) == entry)
raises("equally specific best classes raise", lambda: a.match_class({"class": [entry, dict(entry, recipes=["other"])]}, profile, gpu), "equally specific")
catalog.recipes["model"]["variant"] = [variant, dict(variant, ctx=8192), dict(variant, ctx=16384, peak_ram_gib=60)]
check("largest fitting context wins", a.resolve_best(catalog, profile, gpu)[1]["ctx"] == 8192)
for reason, bad in (("non-fitting variants", dict(recipe, variant=[dict(variant, peak_gpu_gib=100)])),
                    ("unmeasured hardware", dict(recipe, hardware=[dict(recipe["hardware"][0], ram_class=128)]))):
  catalog.recipes["first"] = bad
  catalog.best = {"class": [dict(entry, recipes=["first", "model"])]}
  result = a.resolve_best(catalog, profile, gpu)
  check(f"best falls through {reason}", result[0] == "model" and result[2][0][0] == "first")
catalog.best = {"class": []}
try:
  a.resolve_best(catalog, profile, gpu)
except a.LocalError as error:
  check("missing recommendation reports the profile", all(str(v) in str(error) for v in (gpu["family"], 64, "x86")))
else:
  check("missing recommendation raises", False)
rival = dict(gpu, family="amd-other")
tied = dict(profile, gpus=[gpu, rival])
raises("different GPU families tied for memory require selection", lambda: a.choose_gpu(tied), "--gpu")
check("explicit GPU resolves a memory tie", a.choose_gpu(tied, "amd-other") == rival)
check("GPU peak exceeding capacity does not fit", not a.fits(dict(variant, peak_gpu_gib=49), profile, gpu)[0])
check("RAM fit preserves desktop reserve", not a.fits(dict(variant, peak_ram_gib=57), profile, gpu)[0])
with patch.object(a, "free_memory", return_value=(1, 1)), patch.object(a, "top_memory_users", return_value="browser (12 GiB), editor (4 GiB)"), patch.object(a.time, "sleep"):
  raises("headroom failure lists largest memory users", lambda: a.check_headroom(variant, gpu), "browser (12 GiB), editor (4 GiB)")

payload = b'{"ok":true}'
oid = hashlib.sha1(f"blob {len(payload)}\0".encode() + payload).hexdigest()
tree = [{"type": "file", "path": "model.gguf", "size": 2, "lfs": {"oid": "c" * 64, "size": 3}},
        {"type": "file", "path": "tokenizer/x.json", "size": len(payload), "oid": oid}]
with patch.object(a, "hf_tree", return_value=tree):
  changed = copy.deepcopy(recipe)
  changed["artifacts"][0]["dest"] = "UD"
  files, roles = a.build_artifacts(changed)
  check("LFS expansion uses published SHA256 and LFS size", files[0].get("sha256") == "c" * 64 and files[0]["size"] == 3)
  check("small files retain git blob identity", files[1].get("git_oid") == oid)
  check("dest prefixes the full repository path", files[1]["dest"] == "UD/tokenizer/x.json" and roles["model"] == "UD/model.gguf")
  changed["artifacts"][0]["files"] = ["missing*"]
  raises("unmatched artifact pattern raises", lambda: a.build_artifacts(changed), "no file matching")
  changed = copy.deepcopy(recipe)
  changed["artifacts"].append(dict(artifact, repo="other/model"))
  raises("different artifacts cannot overwrite a destination", lambda: a.build_artifacts(changed), "Two artifacts land")
path = Path(os.environ["HOME"]) / "blob"
path.write_bytes(payload)
check("git blob hash verifies intact file", a.verify_file(path, files[1]))
path.write_bytes(payload[:-1] + b"!")
check("git blob hash rejects same-size one-byte corruption", not a.verify_file(path, files[1]))
record = {"recipe": "model", "method": 'say "hello"\nnext\\line', "ctx": 4096,
          "machine": {"platform": "x86", "flags": ["a", "b"]}, "memory": {"peak": 16.5},
          "artifacts": [{"path": "one", "sha256": "a" * 64}, {"path": "two", "git_oid": oid}],
          "short": {"ttft": 1.5, "ok": True}}
check("bench-shaped TOML round-trips tables, arrays and escaped strings", tomllib.loads(a.toml_dumps(record)) == record)

# Models run side by side, each on its own port; an agent pointed at one must
# never land on another, so ports are distinct, stable, and freed on removal.
first, second = a.port_for("model-a"), a.port_for("model-b")
check("each model gets its own loopback port", first == a.BASE_PORT and second == a.BASE_PORT + 1)
check("a model keeps its port across lookups", a.port_for("model-a") == first)
ports = a.load_ports()
ports.pop("model-a")
a.write_atomic(a.ports_path(), json.dumps(ports))
check("a removed model's port is reused before a new one", a.port_for("model-c") == first and a.port_for("model-b") == second)

# Run manifests are matched to their recipe whole: removing "bar" must not
# take "foo-bar"'s history with it.
check("a run file name yields its whole recipe id", a.run_recipe_id("20261101T120000-foo-bar.json") == "foo-bar")
check("a run of foo-bar is not a run of bar", a.run_recipe_id("20261101T120000-foo-bar.json") != "bar")

# A replayed manifest is user-editable, so its file list is validated before
# anything is written: no escaping destinations, only real hashes.
good = {"dest": "w/model.gguf", "size": 3, "sha256": "a" * 64}
for name, record, roles in (
  ("an escaping destination", {**good, "dest": "../../.bashrc"}, {}),
  ("a malformed hash", {**good, "sha256": "../x"}, {}),
  ("a role naming no file", good, {"model": "other.gguf"}),
):
  try:
    a.validate_files([record], roles)
  except a.LocalError:
    check(f"a manifest with {name} is refused", True)
  else:
    check(f"a manifest with {name} is refused", False)

# A new file set never touches the one a running or previous unit mounts.
def plant(record, body):
  path = a.blob_path(record)
  os.makedirs(os.path.dirname(path), exist_ok=True)
  Path(path).write_bytes(body)
old = {"dest": "w/model.gguf", "size": 3, "sha256": hashlib.sha256(b"old").hexdigest()}
new = {"dest": "w/model.gguf", "size": 3, "sha256": hashlib.sha256(b"new").hexdigest()}
plant(old, b"old")
plant(new, b"new")
first_set = a.materialize("swap", [old], {"model": "w/model.gguf"})
second_set = a.materialize("swap", [new], {"model": "w/model.gguf"})
check("each file set gets its own directory", first_set != second_set)
check("setting up a new file set leaves the previous one intact", Path(a.fileset_dir("swap", first_set), "w/model.gguf").read_bytes() == b"old")

# Exercise typed unit generation, then the real Quadlet parser without starting services.
hostile = '50% $HOME "quoted space" \\tail'
changed = copy.deepcopy(recipe)
changed["server"] = {"args": ["--extra", hostile]}
rt = copy.deepcopy(runtime)
rt["inputs"]["alias"] = {"env": "MODEL_ALIAS"}
rt["health"]["probe"] = ["probe", hostile]
roles = {"model": hostile}
text = a.render_container("model", changed, rt, variant, roles, gpu)
check("server args escape systemd substitutions, quotes and backslashes", '"50%% $$HOME \\"quoted space\\" \\\\tail"' in text)
check("probe escapes substitutions while retaining JSON argv", "HealthCmd=" + json.dumps(["probe", hostile]).replace("%", "%%").replace("$", "$$") in text)
# Map model through env to pass the same hostile value through Environment=.
env_rt = copy.deepcopy(rt)
env_rt["inputs"]["model"] = {"env": "MODEL_PATH"}
env_text = a.render_container("model", changed, env_rt, variant, roles, gpu)
check("environment values are quoted and escaped", 'Environment="MODEL_PATH=/models/50%% $$HOME \\"quoted space\\" \\\\tail"' in env_text)
for location in ("name", "args", "env", "command"):
  r, t = copy.deepcopy(changed), copy.deepcopy(env_rt)
  role_values = dict(roles)
  if location == "name":
    r["name"] = "bad\nname"
  elif location == "args":
    r["server"]["args"] = ["bad\narg"]
  elif location == "env":
    role_values["model"] = "bad\npath"
  else:
    t["command"] = ["bad\ncommand"]
  raises(f"renderer rejects newline in {location}", lambda: a.render_container("model", r, t, variant, role_values, gpu), "control characters")
bad_probe = copy.deepcopy(rt)
bad_probe["health"]["probe"] = ["bad\nprobe"]
try:
  a.render_container("model", changed, bad_probe, variant, roles, gpu)
except a.LocalError:
  check("renderer rejects probe newline", True)
else:
  check("renderer rejects probe newline", False)
generator = next((p for p in ("/usr/lib/systemd/user-generators/podman-user-generator", "/usr/lib/systemd/system-generators/podman-system-generator") if Path(p).exists()), None)
if generator:
  quadlets = Path(a.quadlet_dir())
  quadlets.mkdir(parents=True)
  (quadlets / "omarchy-agent-local.container").write_text(text)
  (quadlets / "omarchy-agent-local.network").write_text(a.render_network())
  env = dict(os.environ, QUADLET_UNIT_DIRS=str(quadlets))
  result = subprocess.run([generator, "--user", "--dryrun"], env=env, capture_output=True, text=True)
  check("Quadlet accepts generated units", result.returncode == 0, result.stdout + result.stderr)
  exec_line = next((line.split("=", 1)[1] for line in result.stdout.splitlines() if line.startswith("ExecStart=") and " run " in line), "")
  # systemd doubles literal percent and dollars; shlex handles its emitted quoting here.
  argv = [re.sub(r"\\x([0-9a-fA-F]{2})", lambda m: chr(int(m[1], 16)), arg)
          for arg in shlex.split(exec_line.replace("%%", "%").replace("$$", "$"))]
  def option(flag, value):
    return f"{flag}={value}" in argv or any(argv[i:i+2] == [flag, value] for i in range(len(argv)))
  check("Quadlet keeps internal network and container restrictions", option("--network", "omarchy-agent-local") and "--read-only" in argv and option("--cap-drop", "all") and option("--security-opt", "no-new-privileges"), exec_line)
  check("Quadlet publishes only the loopback endpoint", option("--publish", f"127.0.0.1:{a.port_for('model')}:8080"), exec_line)
  check("hostile server argument survives Quadlet as one argument", hostile in argv, repr(argv))
else:
  skip("Quadlet parser unavailable: Podman generator is not installed")

# Local repositories exercise fetch, export and validation; who may change
# the catalog is the repository's own access control.
root = Path(os.environ["HOME"])
repo = root / "catalog-source"
repo.mkdir()
def git(*args):
  result = subprocess.run(["git", "-c", "core.hooksPath=/dev/null", "-c", "user.name=Fixture", "-c", "user.email=fixture@example.test", "-c", "commit.gpgsign=false", "-C", str(repo), *args], capture_output=True, text=True)
  if result.returncode:
    raise RuntimeError(result.stderr)
  return result.stdout.strip()

git("init", "-q", "-b", "schema-1")
for directory in ("runtimes", "recipes", "reviews", "measurements"):
  (repo / directory).mkdir()
def write_toml(path, value):
  path.parent.mkdir(parents=True, exist_ok=True)
  path.write_text(a.toml_dumps(value))
write_toml(repo / "catalog.toml", {"schema": 1})
write_toml(repo / "best.toml", {"class": [entry]})
write_toml(repo / "runtimes/server.toml", runtime)
write_toml(repo / "recipes/model.toml", recipe)
write_toml(repo / "reviews/server.toml", {"image": runtime["image"], "publisher": "Fixture", "reviewer": "Tester", "date": "2026-01-01", "license_url": "https://example.test/license", "license_sha256": "a" * 64, "checked": ["key", "network"]})
write_toml(repo / "measurements/model.toml", {"ctx": 4096})
def commit(message):
  git("add", ".")
  git("commit", "--allow-empty", "-qm", message)
  return git("rev-parse", "HEAD")
write_toml(Path(a.config_dir()) / "catalog.toml", {"url": str(repo), "ref": "schema-1"})

accepted = commit("valid catalog")
catalog, note = a.refresh_catalog(force=True)
check("a valid catalog is accepted and recorded", catalog.commit == accepted and a.catalog_state()["current"] == accepted and not note)
write_toml(repo / "catalog.toml", {"schema": 999})
commit("invalid schema")
catalog, note = a.refresh_catalog(force=True)
check("an invalid catalog never replaces the accepted one", catalog.commit == accepted and a.catalog_state()["current"] == accepted and "failed validation" in note, note)

# Removing a recipe drops the blobs only it used, even one still linked from
# the seed copy it was set up from, and keeps those another recipe links.
store = Path(a.data_dir())
for name in ("kept", "seeded"):
  (store / "blobs/sha256").mkdir(parents=True, exist_ok=True)
  (store / "blobs/sha256" / name).write_text(name)
for rid, name in (("gone", "kept"), ("gone", "seeded"), ("other", "kept")):
  (store / "models" / rid).mkdir(parents=True, exist_ok=True)
  os.link(store / "blobs/sha256" / name, store / "models" / rid / name)
seed = Path(os.environ["HOME"]) / "seed"
seed.mkdir()
os.link(store / "blobs/sha256/seeded", seed / "seeded")
with patch.object(a, "write_unit_files"):
  a._remove_files("gone")
check("removal drops a blob only a seed copy still links", not (store / "blobs/sha256/seeded").exists() and (seed / "seeded").read_text() == "seeded")
check("removal keeps a blob another recipe links", (store / "blobs/sha256/kept").exists())

# An interrupted removal leaves the model listed, so remove can finish it.
Path(a.model_manifest_path("halfway")).parent.mkdir(parents=True, exist_ok=True)
Path(a.model_manifest_path("halfway")).write_text(json.dumps({"files": []}))
with patch.object(a, "unit_active", return_value=False), patch.object(a, "write_status"), patch.object(a, "_remove_files", side_effect=KeyboardInterrupt):
  try:
    a.cmd_remove(["halfway"])
  except KeyboardInterrupt:
    pass
check("an interrupted removal keeps the model's manifest", Path(a.model_manifest_path("halfway")).exists() and not Path(a.removing_path("halfway")).exists())
PY
