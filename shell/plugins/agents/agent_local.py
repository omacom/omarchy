"""Local models for Omarchy agents: recipes from a signed catalog, run as Podman Quadlet units.

The catalog (omacom/omarchy-local-ai) chooses what runs: recipes, runtime definitions and the
per-machine recommendation in best.toml. This module owns the boundary every choice runs inside:
an internal network with no egress, a read-only root, dropped capabilities, allowlisted devices
and limits, the key as a Podman secret, typed unit generation, and post-start checks that the
server answers only with the key. See plans/local-models.md.
"""

import argparse
import concurrent.futures
import fcntl
import fnmatch
import hashlib
import json
import os
import pty
import re
import shlex
import shutil
import struct
import subprocess
import sys
import tarfile
import tempfile
import termios
import threading
import time
import tomllib
import urllib.error
import urllib.request

SCHEMA = 1
BASE_PORT = 11435
UNIT_PREFIX = "omarchy-agent-local-model-"
NETWORK_UNIT = "omarchy-agent-local.network"
NETWORK_NAME = "omarchy-agent-local"
SECRET = "omarchy-agent-local-key"
KEY_ENV = "OMARCHY_LOCAL_KEY"
KEY_PLACEHOLDER = "@OMARCHY_LOCAL_KEY@"
DEFAULT_CATALOG_URL = "https://github.com/omacom/omarchy-local-ai"
CATALOG_MAX_AGE = 4 * 3600
RESERVE_GIB = 8
NOT_ENOUGH_MEMORY = "Not enough memory to start model"
RAM_CLASSES = (32, 64, 96, 128, 192, 256, 512)
STANDARD_INPUTS = ("model", "draft", "ctx", "alias", "key", "temperature", "top_p", "top_k")
GFX_FAMILIES = {"gfx1151": "amd-strix-halo", "gfx1150": "amd-strix-point"}

ID_RE = re.compile(r"^[a-z0-9]+([.-][a-z0-9]+)*$")
SHA_RE = re.compile(r"^[0-9a-f]{40}$")
IMAGE_RE = re.compile(r"^[a-z0-9.-]+(:[0-9]+)?(/[a-z0-9._-]+)+@sha256:[0-9a-f]{64}$")
ENV_RE = re.compile(r"^[A-Z_][A-Z0-9_]*$")
ARG_RE = re.compile(r"^-{1,2}[A-Za-z0-9][A-Za-z0-9-]*$")
CONTROL_RE = re.compile(r"[\x00-\x1f\x7f]")

# Run options a runtime may ask for, each mapped to exactly one Quadlet line. Network mode,
# read-only root, capabilities and privileges are not options: every container gets the same.
RUN_OPTIONS = {
  "devices": ("render", "kfd", "cdi-nvidia"),
  "group_add": ("keep-groups",),
  "memlock": ("unlimited",),
}
MAX_SHM_GIB = 16


class LocalError(Exception):
  """A failure with its full explanation, and optionally a one-line reason
  short enough for the agents panel to show where a model's progress bar was."""

  def __init__(self, message, short=None):
    super().__init__(message)
    self.short = short or str(message).splitlines()[0]


# ---------------------------------------------------------------- paths


def home():
  return os.path.expanduser("~")


def state_dir():
  return os.path.join(home(), ".local", "state", "omarchy", "agent-local")


def data_dir():
  return os.path.join(home(), ".local", "share", "omarchy", "agent-local")


def config_dir():
  return os.path.join(home(), ".config", "omarchy", "agent-local")


def quadlet_dir():
  return os.path.join(home(), ".config", "containers", "systemd")


def key_path():
  return os.path.join(config_dir(), "key")


def omarchy_path():
  return os.environ.get("OMARCHY_PATH", "")


def ensure_dir(path, mode=0o755):
  os.makedirs(path, mode=mode, exist_ok=True)
  return path


def write_atomic(path, text, mode=0o644):
  ensure_dir(os.path.dirname(path))
  fd, tmp = tempfile.mkstemp(dir=os.path.dirname(path), prefix=".tmp-")
  try:
    with os.fdopen(fd, "w") as handle:
      handle.write(text)
    os.chmod(tmp, mode)
    os.replace(tmp, path)
  except BaseException:
    if os.path.exists(tmp):
      os.unlink(tmp)
    raise


def gib(value):
  return value / 2**30


def say(message):
  print(message, flush=True)


# ---------------------------------------------------------------- TOML out


def _toml_value(value):
  if isinstance(value, bool):
    return "true" if value else "false"
  if isinstance(value, (int, float)):
    return repr(value)
  if isinstance(value, str):
    return json.dumps(value, ensure_ascii=False)
  if isinstance(value, list):
    return "[" + ", ".join(_toml_value(item) for item in value) + "]"
  if isinstance(value, dict):
    return "{ " + ", ".join(f"{_toml_key(k)} = {_toml_value(v)}" for k, v in value.items() if v is not None) + " }"
  raise TypeError(f"cannot write {type(value).__name__} to TOML")


def _toml_key(key):
  return key if re.match(r"^[A-Za-z0-9_-]+$", key) else json.dumps(key)


def toml_dumps(data, prefix=""):
  scalars, tables, arrays = [], [], []
  for key, value in data.items():
    if value is None:
      continue
    if isinstance(value, dict):
      tables.append((key, value))
    elif isinstance(value, list) and value and all(isinstance(item, dict) for item in value):
      arrays.append((key, value))
    else:
      scalars.append(f"{_toml_key(key)} = {_toml_value(value)}")
  out = "\n".join(scalars)
  for key, value in tables:
    name = f"{prefix}{_toml_key(key)}"
    out += f"\n\n[{name}]\n" + toml_dumps(value, name + ".")
  for key, items in arrays:
    name = f"{prefix}{_toml_key(key)}"
    for item in items:
      out += f"\n\n[[{name}]]\n" + toml_dumps(item, name + ".")
  return out.strip("\n") + ("\n" if prefix == "" else "")


# ---------------------------------------------------------------- machine profile


def _read(path, default=""):
  try:
    with open(path) as handle:
      return handle.read().strip()
  except OSError:
    return default


def _kv_file(path):
  values = {}
  for line in _read(path).splitlines():
    parts = line.split()
    if len(parts) == 2:
      values[parts[0]] = parts[1]
  return values


def meminfo():
  values = {}
  for line in _read("/proc/meminfo").splitlines():
    name, _, rest = line.partition(":")
    number = rest.strip().split()
    if number:
      values[name] = int(number[0]) * 1024
  return values


def platform_name():
  try:
    return subprocess.run(["omarchy-hw-platform"], capture_output=True, text=True, timeout=10).stdout.strip() or "x86"
  except (OSError, subprocess.SubprocessError):
    return "x86"


def gfx_name(version):
  version = int(version)
  return f"gfx{version // 10000}{(version // 100) % 100:x}{version % 100:x}"


def amd_gpus(kfd_root="/sys/class/kfd/kfd/topology/nodes", drm_root="/sys/class/drm"):
  gpus = []
  try:
    nodes = sorted(os.listdir(kfd_root))
  except OSError:
    return gpus
  for node in nodes:
    props = _kv_file(os.path.join(kfd_root, node, "properties"))
    version = int(props.get("gfx_target_version", "0") or 0)
    if not version:
      continue
    minor = props.get("drm_render_minor", "")
    render = f"renderD{minor}"
    device = os.path.join(drm_root, render, "device")
    vram = int(_read(os.path.join(device, "mem_info_vram_total"), "0") or 0)
    gtt = int(_read(os.path.join(device, "mem_info_gtt_total"), "0") or 0)
    gfx = gfx_name(version)
    gpus.append({
      "vendor": "amd",
      "family": GFX_FAMILIES.get(gfx, f"amd-{gfx}"),
      "gfx": gfx,
      "render_node": f"/dev/dri/{render}",
      "vram_gib": round(gib(vram), 2),
      "gtt_gib": round(gib(gtt), 2),
      "unified": vram < 4 * 2**30,
      "memory_gib": round(gib(vram + gtt), 2),
      "sysfs": device,
    })
  return gpus


def ram_class(ram_gib):
  for size in RAM_CLASSES:
    if ram_gib <= size:
      return size
  return RAM_CLASSES[-1]


def machine_profile():
  mem = meminfo()
  ram = gib(mem.get("MemTotal", 0))
  platform = platform_name()
  gpus = amd_gpus()
  if platform == "aarch64-gb10":
    gpus.append({"vendor": "nvidia", "family": "nvidia-gb10", "render_node": "", "vram_gib": 0, "gtt_gib": 0, "unified": True, "memory_gib": round(ram, 2), "sysfs": ""})
  return {"platform": platform, "ram_gib": round(ram, 2), "ram_class": ram_class(ram), "gpus": gpus}


def choose_gpu(profile, family=None):
  gpus = profile["gpus"]
  if family:
    matches = [gpu for gpu in gpus if gpu["family"] == family]
    if not matches:
      raise LocalError(f"No {family} GPU on this machine (found: {', '.join(g['family'] for g in gpus) or 'none'})")
    return max(matches, key=lambda gpu: gpu["memory_gib"])
  if not gpus:
    raise LocalError("No supported GPU found on this machine")
  best = max(gpus, key=lambda gpu: gpu["memory_gib"])
  rivals = {gpu["family"] for gpu in gpus if gpu["memory_gib"] == best["memory_gib"]}
  if len(rivals) > 1:
    raise LocalError(f"Several GPU families tie for the most memory ({', '.join(sorted(rivals))}); choose one with --gpu")
  return best


def write_profile_cache(profile):
  write_atomic(os.path.join(state_dir(), "profile.json"), json.dumps(profile, indent=2) + "\n")


# ---------------------------------------------------------------- validation


def _safe_string(value, where, errors):
  if not isinstance(value, str) or not value:
    errors.append(f"{where}: must be a non-empty string")
    return False
  if CONTROL_RE.search(value):
    errors.append(f"{where}: contains control characters")
    return False
  return True


def _safe_relpath(value, where, errors, glob=False):
  if not _safe_string(value, where, errors):
    return False
  parts = value.split("/")
  if value.startswith("/") or any(part in ("", ".", "..") for part in parts):
    errors.append(f"{where}: must be a relative path without '.', '..' or empty parts")
    return False
  if not glob and any(ch in value for ch in "*?["):
    errors.append(f"{where}: must not contain glob characters")
    return False
  return True


def validate_runtime(rid, runtime, root=None):
  errors = []
  where = f"runtimes/{rid}"
  if not ID_RE.match(rid):
    errors.append(f"{where}: id must match {ID_RE.pattern}")
  image = runtime.get("image", "")
  if not isinstance(image, str) or not IMAGE_RE.match(image):
    errors.append(f"{where}: image must be <registry>/<path>@sha256:<64 hex>")
  tier = runtime.get("tier")
  if tier not in ("omarchy", "third-party"):
    errors.append(f"{where}: tier must be 'omarchy' or 'third-party'")
  if tier == "third-party":
    review = runtime.get("review", "")
    if _safe_relpath(review, f"{where}.review", errors) and root:
      path = os.path.join(root, review)
      if not os.path.isfile(path):
        errors.append(f"{where}.review: {review} is missing")
      else:
        try:
          with open(path, "rb") as handle:
            data = tomllib.load(handle)
          if data.get("image") != image:
            errors.append(f"{where}.review: reviews a different image digest")
          for field in ("publisher", "reviewer", "date", "license_url", "license_sha256", "checked"):
            if not data.get(field):
              errors.append(f"{where}.review: missing {field}")
        except tomllib.TOMLDecodeError as error:
          errors.append(f"{where}.review: {error}")
  port = runtime.get("port")
  if not isinstance(port, int) or not 1 <= port <= 65535:
    errors.append(f"{where}.port: must be 1-65535")
  health = runtime.get("health", {})
  if not isinstance(health, dict) or not isinstance(health.get("path"), str) or not health.get("path", "").startswith("/"):
    errors.append(f"{where}.health.path: must start with /")
  probe = health.get("probe") if isinstance(health, dict) else None
  if not isinstance(probe, list) or not probe:
    errors.append(f"{where}.health.probe: must be a non-empty list")
  else:
    for index, part in enumerate(probe):
      _safe_string(part, f"{where}.health.probe[{index}]", errors)
  command = runtime.get("command", [])
  if not isinstance(command, list):
    errors.append(f"{where}.command: must be a list")
  else:
    for index, part in enumerate(command):
      _safe_string(part, f"{where}.command[{index}]", errors)
  run = runtime.get("run", {})
  if not isinstance(run, dict):
    errors.append(f"{where}.run: must be a table")
    run = {}
  for option, value in run.items():
    if option == "shm_size_gib":
      if not isinstance(value, (int, float)) or not 0 < value <= MAX_SHM_GIB:
        errors.append(f"{where}.run.shm_size_gib: must be between 0 and {MAX_SHM_GIB}")
      continue
    if option not in RUN_OPTIONS:
      errors.append(f"{where}.run.{option}: not an allowed run option ({', '.join(sorted(list(RUN_OPTIONS) + ['shm_size_gib']))})")
      continue
    values = value if isinstance(value, list) else [value]
    for item in values:
      if item not in RUN_OPTIONS[option]:
        errors.append(f"{where}.run.{option}: '{item}' is not allowed ({', '.join(RUN_OPTIONS[option])})")
  reserved = runtime.get("reserved", [])
  if not isinstance(reserved, list) or not all(isinstance(item, str) for item in reserved):
    errors.append(f"{where}.reserved: must be a list of strings")
    reserved = []
  inputs = runtime.get("inputs", {})
  if not isinstance(inputs, dict):
    errors.append(f"{where}.inputs: must be a table")
    inputs = {}
  targets = {}
  for name, mapping in inputs.items():
    if name not in STANDARD_INPUTS:
      errors.append(f"{where}.inputs.{name}: not a standard input ({', '.join(STANDARD_INPUTS)})")
      continue
    if not isinstance(mapping, dict) or len([k for k in ("arg", "env") if k in mapping]) != 1 or set(mapping) - {"arg", "env"}:
      errors.append(f"{where}.inputs.{name}: must be exactly one of {{ arg = ... }} or {{ env = ... }}")
      continue
    kind, target = next(iter(mapping.items()))
    if kind == "env" and not ENV_RE.match(str(target)):
      errors.append(f"{where}.inputs.{name}: bad environment variable name")
    if kind == "arg" and not ARG_RE.match(str(target)):
      errors.append(f"{where}.inputs.{name}: bad argument name")
    if (kind, target) in targets:
      errors.append(f"{where}.inputs.{name}: same target as {targets[(kind, target)]}")
    targets[(kind, target)] = name
    # The key is the one input that belongs in a reserved switch, and only in one
    # that names a key: never a bind address, port or download source.
    if target in reserved and not (name == "key" and "key" in target.lower()):
      errors.append(f"{where}.inputs.{name}: targets reserved {target}")
    if name == "key" and "key" not in str(target).lower():
      errors.append(f"{where}.inputs.key: {target} doesn't name a key")
    if kind == "env" and target == KEY_ENV:
      errors.append(f"{where}.inputs.{name}: {KEY_ENV} belongs to Omarchy")
  for required in ("model", "alias", "key"):
    if required not in inputs:
      errors.append(f"{where}.inputs: must map '{required}'")
  key = inputs.get("key", {})
  if isinstance(key, dict) and "arg" in key:
    if runtime.get("key_on_cmdline") is not True:
      errors.append(f"{where}.inputs.key: an argument key needs key_on_cmdline = true, shown as a warning")
    if not runtime.get("shell"):
      errors.append(f"{where}: key_on_cmdline needs shell = '/bin/bash' to substitute the key inside the container")
  if runtime.get("shell") and runtime.get("shell") != "/bin/bash":
    errors.append(f"{where}.shell: only /bin/bash is supported")
  return errors


ARCHITECTURES = ("dense", "moe")


def validate_recipe(rid, recipe, runtimes, root=None):
  errors = []
  where = f"recipes/{rid}"
  if not ID_RE.match(rid):
    errors.append(f"{where}: id must match {ID_RE.pattern}")
  for field in ("name", "summary"):
    _safe_string(recipe.get(field), f"{where}.{field}", errors)
  # The model maker, naming the logo the agents panel shows (assets/<vendor>.svg).
  if "vendor" in recipe and not (isinstance(recipe["vendor"], str) and ID_RE.match(recipe["vendor"])):
    errors.append(f"{where}.vendor: must match {ID_RE.pattern}")
  # Dense or mixture of experts, shown on the recipe's card.
  if "architecture" in recipe and recipe["architecture"] not in ARCHITECTURES:
    errors.append(f"{where}.architecture: must be one of {', '.join(ARCHITECTURES)}")
  runtime_id = recipe.get("runtime")
  runtime = runtimes.get(runtime_id)
  if runtime is None:
    errors.append(f"{where}.runtime: unknown runtime '{runtime_id}'")
    runtime = {}
  inputs = runtime.get("inputs", {})
  hardware = recipe.get("hardware", [])
  if not isinstance(hardware, list) or not hardware:
    errors.append(f"{where}.hardware: needs at least one [[hardware]] entry")
    hardware = []
  for index, entry in enumerate(hardware):
    if not isinstance(entry, dict) or not isinstance(entry.get("gpu"), str) or entry.get("ram_class") not in RAM_CLASSES:
      errors.append(f"{where}.hardware[{index}]: needs gpu and ram_class (one of {RAM_CLASSES})")
      continue
    measured = entry.get("measured")
    if _safe_relpath(measured, f"{where}.hardware[{index}].measured", errors) and root and not os.path.isfile(os.path.join(root, measured)):
      errors.append(f"{where}.hardware[{index}].measured: {measured} is missing")
  artifacts = recipe.get("artifacts", [])
  if not isinstance(artifacts, list) or not artifacts:
    errors.append(f"{where}.artifacts: needs at least one [[artifacts]] entry")
    artifacts = []
  roles = {}
  for index, artifact in enumerate(artifacts):
    at = f"{where}.artifacts[{index}]"
    if not isinstance(artifact, dict):
      errors.append(f"{at}: must be a table")
      continue
    if not isinstance(artifact.get("repo"), str) or not re.match(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", artifact.get("repo", "")):
      errors.append(f"{at}.repo: must be <owner>/<name>")
    if not SHA_RE.match(str(artifact.get("revision", ""))):
      errors.append(f"{at}.revision: must be a 40-hex commit")
    _safe_string(artifact.get("license"), f"{at}.license", errors)
    files = artifact.get("files", [])
    if not isinstance(files, list) or not files:
      errors.append(f"{at}.files: must be a non-empty list")
      files = []
    for findex, pattern in enumerate(files):
      _safe_relpath(pattern, f"{at}.files[{findex}]", errors, glob=True)
    if "dest" in artifact:
      _safe_relpath(artifact["dest"], f"{at}.dest", errors)
    for role in ("model", "draft"):
      if role in artifact:
        if _safe_relpath(artifact[role], f"{at}.{role}", errors):
          if role in roles:
            errors.append(f"{at}.{role}: already named by artifacts[{roles[role]}]")
          roles[role] = index
          if not any(fnmatch.fnmatchcase(artifact[role], pattern) for pattern in files):
            errors.append(f"{at}.{role}: not matched by this artifact's files")
  if "model" not in roles:
    errors.append(f"{where}.artifacts: one artifact must name the model file")
  if "draft" in roles and runtime and "draft" not in inputs:
    errors.append(f"{where}.artifacts: names a draft but runtime '{runtime_id}' has no draft input")
  variants = recipe.get("variant", [])
  if not isinstance(variants, list) or not variants:
    errors.append(f"{where}.variant: needs at least one [[variant]]")
    variants = []
  for index, variant in enumerate(variants):
    at = f"{where}.variant[{index}]"
    if not isinstance(variant, dict) or not isinstance(variant.get("ctx"), int) or variant["ctx"] <= 0:
      errors.append(f"{at}.ctx: must be a positive integer")
      continue
    for field in ("peak_ram_gib", "peak_gpu_gib"):
      if not isinstance(variant.get(field), (int, float)) or variant[field] <= 0:
        errors.append(f"{at}.{field}: must be a positive number")
    if variant.get("ctx") and runtime and "ctx" not in inputs:
      errors.append(f"{at}: runtime '{runtime_id}' has no ctx input")
  sampling = recipe.get("sampling", {})
  if not isinstance(sampling, dict):
    errors.append(f"{where}.sampling: must be a table")
    sampling = {}
  for name, value in sampling.items():
    if name not in ("temperature", "top_p", "top_k") or not isinstance(value, (int, float)):
      errors.append(f"{where}.sampling.{name}: unknown or not a number")
  args = recipe.get("server", {}).get("args", []) if isinstance(recipe.get("server", {}), dict) else None
  if not isinstance(args, list):
    errors.append(f"{where}.server.args: must be a list")
    args = []
  reserved = set(runtime.get("reserved", []))
  mapped = {mapping.get("arg") for mapping in inputs.values() if isinstance(mapping, dict)}
  for index, arg in enumerate(args):
    if not _safe_string(arg, f"{where}.server.args[{index}]", errors):
      continue
    flag = arg.split("=", 1)[0]
    if flag in reserved:
      errors.append(f"{where}.server.args[{index}]: {flag} is reserved by runtime '{runtime_id}'")
    if flag in mapped:
      errors.append(f"{where}.server.args[{index}]: {flag} is set by Omarchy from the recipe's inputs")
    if KEY_PLACEHOLDER in arg:
      errors.append(f"{where}.server.args[{index}]: may not reference the key")
  return errors


def validate_best(best, recipes):
  errors = []
  classes = best.get("class", [])
  if not isinstance(classes, list) or not classes:
    return ["best.toml: needs at least one [[class]]"]
  seen = {}
  for index, entry in enumerate(classes):
    where = f"best.toml class[{index}]"
    if not isinstance(entry, dict):
      errors.append(f"{where}: must be a table")
      continue
    if entry.get("ram_class") not in RAM_CLASSES:
      errors.append(f"{where}.ram_class: must be one of {RAM_CLASSES}")
    if not entry.get("gpu") and not entry.get("platform"):
      errors.append(f"{where}: needs gpu or platform")
    selectors = (entry.get("gpu"), entry.get("platform"), entry.get("ram_class"))
    if selectors in seen:
      errors.append(f"{where}: same selectors as class[{seen[selectors]}]")
    seen[selectors] = index
    names = entry.get("recipes", [])
    if not isinstance(names, list) or not names:
      errors.append(f"{where}.recipes: must be a non-empty list")
      continue
    for name in names:
      recipe = recipes.get(name)
      if recipe is None:
        errors.append(f"{where}: unknown recipe '{name}'")
        continue
      qualified = any(
        hw.get("ram_class") == entry.get("ram_class")
        and (not entry.get("gpu") or hw.get("gpu") == entry.get("gpu"))
        and (not entry.get("platform") or hw.get("platform") in (None, entry.get("platform")))
        for hw in recipe.get("hardware", []) if isinstance(hw, dict)
      )
      if not qualified:
        errors.append(f"{where}: recipe '{name}' has no measured [[hardware]] entry for this class")
  return errors


def _load_toml_dir(root, sub):
  items = {}
  directory = os.path.join(root, sub)
  if not os.path.isdir(directory):
    return items
  for name in sorted(os.listdir(directory)):
    if name.endswith(".toml"):
      with open(os.path.join(directory, name), "rb") as handle:
        items[name[:-5]] = tomllib.load(handle)
  return items


class Catalog:
  def __init__(self, root, commit="", source=""):
    self.root = root
    self.commit = commit
    self.source = source
    with open(os.path.join(root, "catalog.toml"), "rb") as handle:
      self.meta = tomllib.load(handle)
    self.runtimes = _load_toml_dir(root, "runtimes")
    self.recipes = _load_toml_dir(root, "recipes")
    with open(os.path.join(root, "best.toml"), "rb") as handle:
      self.best = tomllib.load(handle)
    self.overrides = set()

  def apply_user_overrides(self):
    for sub, target in (("runtimes", self.runtimes), ("recipes", self.recipes)):
      for rid, item in _load_toml_dir(config_dir(), sub).items():
        target[rid] = item
        self.overrides.add(f"{sub}/{rid}")

  def errors(self):
    errors = []
    if self.meta.get("schema") != SCHEMA:
      errors.append(f"catalog.toml: schema {self.meta.get('schema')} is not {SCHEMA}")
    for rid, runtime in self.runtimes.items():
      errors += validate_runtime(rid, runtime, self.root)
    for rid, recipe in self.recipes.items():
      errors += validate_recipe(rid, recipe, self.runtimes, self.root)
    errors += validate_best(self.best, self.recipes)
    return errors


def load_catalog_dir(root):
  try:
    return Catalog(root)
  except (OSError, tomllib.TOMLDecodeError) as error:
    raise LocalError(f"Catalog at {root} can't be read: {error}")


# ---------------------------------------------------------------- catalog fetch


def catalog_settings():
  """Where the catalog comes from. Who may change it is the repository's own
  access control; a fork or a pinned commit can be set for testing."""
  settings = {"url": DEFAULT_CATALOG_URL, "ref": f"schema-{SCHEMA}"}
  path = os.path.join(config_dir(), "catalog.toml")
  if os.path.isfile(path):
    with open(path, "rb") as handle:
      user = tomllib.load(handle)
    for key in settings:
      if key in user:
        settings[key] = str(user[key])
  return settings


def git(args, repo, check=True, capture=True, input_bytes=None):
  env = {
    "PATH": os.environ.get("PATH", "/usr/bin"),
    "HOME": home(),
    "GIT_CONFIG_NOSYSTEM": "1",
    "GIT_CONFIG_GLOBAL": "/dev/null",
    "GIT_TERMINAL_PROMPT": "0",
    "GIT_ASKPASS": "/bin/false",
    "SSH_ASKPASS": "/bin/false",
  }
  command = ["git", "-c", "core.hooksPath=/dev/null", "-c", "credential.helper=", "-c", "protocol.file.allow=always", "--git-dir", repo] + args
  result = subprocess.run(command, env=env, capture_output=capture, input=input_bytes)
  if check and result.returncode != 0:
    detail = (result.stderr or b"").decode(errors="replace").strip() if capture else ""
    raise LocalError(f"git {' '.join(args[:2])} failed: {detail}")
  return result


def catalog_state():
  path = os.path.join(state_dir(), "catalog", "state.json")
  try:
    with open(path) as handle:
      return json.load(handle)
  except (OSError, ValueError):
    return {}


def save_catalog_state(state):
  write_atomic(os.path.join(state_dir(), "catalog", "state.json"), json.dumps(state, indent=2) + "\n")


def export_tree(repo, commit):
  target = os.path.join(state_dir(), "catalog", "trees", commit)
  if os.path.isfile(os.path.join(target, "catalog.toml")):
    return target
  staging = target + ".partial"
  shutil.rmtree(staging, ignore_errors=True)
  ensure_dir(staging)
  archive = git(["archive", "--format=tar", commit], repo).stdout
  with tempfile.TemporaryFile() as handle:
    handle.write(archive)
    handle.seek(0)
    with tarfile.open(fileobj=handle) as tar:
      tar.extractall(staging, filter="data")
  shutil.rmtree(target, ignore_errors=True)
  os.replace(staging, target)
  return target


def refresh_catalog(force=False, pin=None):
  """Fetch, validate and accept the catalog. Returns (Catalog, note)."""
  settings = catalog_settings()
  state = catalog_state()
  repo = os.path.join(state_dir(), "catalog", "repo.git")
  if not os.path.isdir(repo):
    ensure_dir(os.path.dirname(repo))
    subprocess.run(["git", "init", "--bare", "--quiet", repo], check=True, env={"PATH": os.environ.get("PATH", ""), "HOME": home(), "GIT_CONFIG_NOSYSTEM": "1", "GIT_CONFIG_GLOBAL": "/dev/null"})
  note = ""
  pinned = pin or (settings["ref"] if SHA_RE.match(settings["ref"]) else None)
  source_changed = state.get("url") != settings["url"]
  fresh = time.time() - state.get("fetched_at", 0) < CATALOG_MAX_AGE
  if force or source_changed or pinned or not fresh or not state.get("current"):
    ref = pinned or settings["ref"]
    fetch = git(["fetch", "--quiet", "--no-tags", settings["url"], f"+{ref}:refs/omarchy/fetched"] if not pinned else ["fetch", "--quiet", "--no-tags", settings["url"], ref], repo, check=False)
    if fetch.returncode != 0:
      if not state.get("current"):
        raise LocalError(f"Can't fetch the catalog from {settings['url']}: {(fetch.stderr or b'').decode(errors='replace').strip()}")
      note = f"catalog not refreshed (offline?); using cached {state['current'][:12]}"
    else:
      new = pinned or git(["rev-parse", "refs/omarchy/fetched"], repo).stdout.decode().strip()
      if not git(["cat-file", "-e", f"{new}^{{commit}}"], repo, check=False).returncode == 0:
        raise LocalError(f"Catalog commit {new} not found at {settings['url']}")
      current = state.get("current") if not source_changed else None
      try:
        tree = export_tree(repo, new)
        catalog = load_catalog_dir(tree)
        errors = catalog.errors()
        if errors:
          raise LocalError("Catalog failed validation:\n  " + "\n  ".join(errors))
      except LocalError as error:
        if current and not pinned:
          note = f"kept catalog {current[:12]}: {error}"
        else:
          raise
      else:
        if not pinned:
          state.update({"current": new, "url": settings["url"]})
        state["fetched_at"] = time.time()
        save_catalog_state(state)
        if pinned:
          catalog.commit, catalog.source = new, settings["url"]
          catalog.apply_user_overrides()
          return catalog, note
  commit = state["current"]
  catalog = load_catalog_dir(export_tree(repo, commit))
  catalog.commit, catalog.source = commit, state.get("url", settings["url"])
  catalog.apply_user_overrides()
  if catalog.overrides:
    errors = catalog.errors()
    if errors:
      raise LocalError("Your local recipe or runtime overrides are invalid:\n  " + "\n  ".join(errors))
  age = time.time() - state.get("fetched_at", 0)
  if not note and age > CATALOG_MAX_AGE:
    note = f"catalog is {int(age // 3600)}h old"
  return catalog, note


def cached_catalog():
  state = catalog_state()
  if not state.get("current"):
    return None
  tree = os.path.join(state_dir(), "catalog", "trees", state["current"])
  if not os.path.isdir(tree):
    return None
  catalog = load_catalog_dir(tree)
  catalog.commit, catalog.source = state["current"], state.get("url", "")
  catalog.apply_user_overrides()
  return catalog


# ---------------------------------------------------------------- compatibility and best


def runtime_supports(runtime, gpu):
  devices = runtime.get("run", {}).get("devices", [])
  if gpu["vendor"] == "amd":
    return "cdi-nvidia" not in devices
  if gpu["vendor"] == "nvidia":
    return "kfd" not in devices and "render" not in devices
  return False


def qualified(recipe, profile, gpu):
  return any(
    hw.get("gpu") == gpu["family"] and hw.get("ram_class") == profile["ram_class"] and hw.get("platform") in (None, profile["platform"])
    for hw in recipe.get("hardware", [])
  )


def fits(variant, profile, gpu):
  """Static fit of a variant on this machine: (ok, reason)."""
  if variant["peak_gpu_gib"] > gpu["memory_gib"]:
    return False, f"needs {variant['peak_gpu_gib']:g} GiB GPU-addressable memory, this GPU has {gpu['memory_gib']:.0f}"
  if variant["peak_ram_gib"] + RESERVE_GIB > profile["ram_gib"]:
    return False, f"needs {variant['peak_ram_gib']:g} GiB RAM plus {RESERVE_GIB} GiB for the desktop, this machine has {profile['ram_gib']:.0f}"
  return True, ""


def pick_variant(recipe, profile, gpu, ctx=None):
  variants = sorted(recipe.get("variant", []), key=lambda v: v["ctx"], reverse=True)
  if ctx:
    variants = [v for v in variants if v["ctx"] == ctx]
    if not variants:
      raise LocalError(f"No measured variant with ctx {ctx} (have: {', '.join(str(v['ctx']) for v in recipe.get('variant', []))})")
  reasons = []
  for variant in variants:
    ok, reason = fits(variant, profile, gpu)
    if ok:
      return variant, ""
    reasons.append(reason)
  return None, reasons[-1] if reasons else "no variants"


def compatibility(catalog, rid, profile, gpu, ctx=None):
  recipe = catalog.recipes[rid]
  runtime = catalog.runtimes.get(recipe.get("runtime"), {})
  if not runtime_supports(runtime, gpu):
    return None, f"runtime {recipe.get('runtime')} can't run on {gpu['family']}"
  if not qualified(recipe, profile, gpu):
    classes = ", ".join(f"{hw.get('gpu')} {hw.get('ram_class')} GB" for hw in recipe.get("hardware", []))
    return None, f"not measured on {gpu['family']} {profile['ram_class']} GB (measured: {classes})"
  return pick_variant(recipe, profile, gpu, ctx)


def match_class(best, profile, gpu):
  matches = []
  for entry in best.get("class", []):
    if entry.get("ram_class") != profile["ram_class"]:
      continue
    if entry.get("gpu") and entry["gpu"] != gpu["family"]:
      continue
    if entry.get("platform") and entry["platform"] != profile["platform"]:
      continue
    rank = (1 if entry.get("gpu") else 0, sum(1 for key in ("gpu", "platform") if entry.get(key)))
    matches.append((rank, entry))
  if not matches:
    return None
  matches.sort(key=lambda item: item[0], reverse=True)
  if len(matches) > 1 and matches[0][0] == matches[1][0]:
    raise LocalError("best.toml has two equally specific classes for this machine")
  return matches[0][1]


def resolve_best(catalog, profile, gpu, ctx=None):
  entry = match_class(catalog.best, profile, gpu)
  if entry is None:
    near = [rid for rid, recipe in catalog.recipes.items() if any(hw.get("gpu") == gpu["family"] for hw in recipe.get("hardware", []))]
    raise LocalError(
      f"No recommendation for this machine yet ({gpu['family']}, {profile['ram_class']} GB, {profile['platform']}).\n"
      + (f"Recipes measured on the same GPU family: {', '.join(near)}" if near else "No recipes are measured on this GPU family yet.")
    )
  skipped = []
  for rid in entry["recipes"]:
    if rid not in catalog.recipes:
      continue
    variant, reason = compatibility(catalog, rid, profile, gpu, ctx)
    if variant:
      return rid, variant, skipped
    skipped.append((rid, reason))
  details = "; ".join(f"{rid}: {reason}" for rid, reason in skipped)
  raise LocalError(f"No recommended recipe fits this machine: {details}")


def recipe_listing(catalog, profile, running=()):
  rows = []
  try:
    gpu = choose_gpu(profile)
  except LocalError as error:
    gpu, gpu_error = None, str(error)
  best_id = None
  if gpu:
    try:
      best_id = resolve_best(catalog, profile, gpu)[0]
    except LocalError:
      best_id = None
  for rid in sorted(catalog.recipes):
    recipe = catalog.recipes[rid]
    runtime = catalog.runtimes.get(recipe.get("runtime"), {})
    if gpu:
      variant, reason = compatibility(catalog, rid, profile, gpu)
    else:
      variant, reason = None, gpu_error
    review = load_review(catalog, runtime) if runtime.get("tier") == "third-party" else {}
    measured = load_measurement(catalog, recipe, profile, gpu) if variant else {}
    rows.append({
      "id": rid,
      "name": recipe.get("name", rid),
      "summary": recipe.get("summary", ""),
      "runtime": recipe.get("runtime", ""),
      "tier": runtime.get("tier", ""),
      "publisher": review.get("publisher", ""),
      "vendor": recipe.get("vendor", ""),
      "architecture": recipe.get("architecture", ""),
      "installed": recipe_installed(rid),
      "available": variant is not None,
      "reason": "" if variant else reason,
      "best": rid == best_id,
      "active": rid in running,
      "override": f"recipes/{rid}" in catalog.overrides,
      # What the card shows: the measured footprint, context and speed at a
      # long prompt on this machine class.
      "memory_gib": variant["peak_ram_gib"] if variant else None,
      "context": variant["ctx"] if variant else None,
      "decode_tok_s": measured.get("long", {}).get("decode_tok_s"),
      "prefill_tok_s": measured.get("long", {}).get("prefill_tok_s"),
    })
  return rows


RUN_NAME_RE = re.compile(r"^\d{8}T\d{6}-(.+)\.json$")


def run_recipe_id(name):
  """The recipe a run manifest's file name belongs to, matched whole: removing
  `bar` must not touch `foo-bar`'s runs."""
  match = RUN_NAME_RE.match(name)
  return match.group(1) if match else None


def recipe_installed(rid):
  """Whether a recipe has run here and its weights are still on disk, so switching to it is quick."""
  if not os.path.isdir(os.path.join(data_dir(), "models", rid)):
    return False
  runs = runs_dir()
  return os.path.isdir(runs) and any(run_recipe_id(name) == rid for name in os.listdir(runs))


def load_measurement(catalog, recipe, profile, gpu):
  """The bench numbers the catalog recorded for this recipe on this machine class."""
  for hw in recipe.get("hardware", []):
    if hw.get("gpu") == gpu["family"] and hw.get("ram_class") == profile["ram_class"] and hw.get("platform") in (None, profile["platform"]):
      try:
        with open(os.path.join(catalog.root, hw["measured"]), "rb") as handle:
          return tomllib.load(handle)
      except (OSError, KeyError, tomllib.TOMLDecodeError):
        return {}
  return {}


def load_review(catalog, runtime):
  path = runtime.get("review")
  if not path:
    return {}
  try:
    with open(os.path.join(catalog.root, path), "rb") as handle:
      return tomllib.load(handle)
  except (OSError, tomllib.TOMLDecodeError):
    return {}


def write_list_cache(rows):
  write_atomic(os.path.join(state_dir(), "list.json"), json.dumps(rows, indent=2) + "\n")


# ---------------------------------------------------------------- Hugging Face artifacts


def hf_token():
  token = os.environ.get("HF_TOKEN", "")
  if not token:
    token = _read(os.path.join(home(), ".cache", "huggingface", "token"))
  return token


def http_json(url, timeout=60):
  headers = {"User-Agent": "omarchy-agent-local"}
  token = hf_token()
  if token and url.startswith("https://huggingface.co/"):
    headers["Authorization"] = f"Bearer {token}"
  request = urllib.request.Request(url, headers=headers)
  try:
    with urllib.request.urlopen(request, timeout=timeout) as response:
      return json.load(response)
  except (urllib.error.URLError, TimeoutError, ValueError) as error:
    raise LocalError(f"Can't read {url}: {error}")


def hf_tree(repo, revision, cache):
  key = f"{repo}@{revision}"
  if key not in cache:
    cache[key] = http_json(f"https://huggingface.co/api/models/{repo}/tree/{revision}?recursive=1")
  return cache[key]


def build_artifacts(recipe, tree_cache=None):
  """Expand a recipe's artifacts against Hugging Face's file list at each pinned revision."""
  tree_cache = {} if tree_cache is None else tree_cache
  files = []
  destinations = {}
  roles = {}
  for artifact in recipe["artifacts"]:
    tree = [entry for entry in hf_tree(artifact["repo"], artifact["revision"], tree_cache) if entry.get("type") == "file"]
    for pattern in artifact["files"]:
      matched = [entry for entry in tree if fnmatch.fnmatchcase(entry["path"], pattern)]
      if not matched:
        raise LocalError(f"{artifact['repo']}@{artifact['revision'][:12]} has no file matching {pattern}")
      for entry in matched:
        path = entry["path"]
        if path.startswith("/") or ".." in path.split("/"):
          raise LocalError(f"{artifact['repo']} lists an unsafe path: {path}")
        dest = f"{artifact['dest']}/{path}" if artifact.get("dest") else path
        if dest in destinations:
          if destinations[dest]["repo"] == artifact["repo"] and destinations[dest]["path"] == path:
            continue
          raise LocalError(f"Two artifacts land at {dest}")
        lfs = entry.get("lfs") or {}
        record = {
          "repo": artifact["repo"],
          "revision": artifact["revision"],
          "path": path,
          "dest": dest,
          "size": int(lfs.get("size", entry.get("size", 0))),
          "license": artifact["license"],
        }
        if lfs.get("oid"):
          record["sha256"] = lfs["oid"]
        else:
          record["git_oid"] = entry["oid"]
        destinations[dest] = record
        files.append(record)
    for role in ("model", "draft"):
      if role in artifact:
        target = artifact[role]
        roles[role] = f"{artifact['dest']}/{target}" if artifact.get("dest") else target
  return files, roles


def blob_path(record):
  if "sha256" in record:
    return os.path.join(data_dir(), "blobs", "sha256", record["sha256"])
  return os.path.join(data_dir(), "blobs", "git", record["git_oid"])


def _hasher(record):
  if "sha256" in record:
    return hashlib.sha256(), record["sha256"]
  digest = hashlib.sha1()
  digest.update(f"blob {record['size']}\0".encode())
  return digest, record["git_oid"]


def verify_file(path, record):
  if os.path.getsize(path) != record["size"]:
    return False
  digest, expected = _hasher(record)
  with open(path, "rb") as handle:
    while chunk := handle.read(16 * 2**20):
      digest.update(chunk)
  return digest.hexdigest() == expected


class Progress:
  def __init__(self, total):
    self.total = total
    self.done = 0
    self.lock = threading.Lock()
    self.last = 0
    self.started = time.time()

  def add(self, amount):
    with self.lock:
      self.done += amount
      now = time.time()
      if now - self.last >= 5 or self.done >= self.total:
        self.last = now
        rate = self.done / max(now - self.started, 0.001)
        say(f"  {gib(self.done):6.1f} / {gib(self.total):.1f} GiB  {rate / 2**20:6.0f} MiB/s")


def download(record, progress):
  url = f"https://huggingface.co/{record['repo']}/resolve/{record['revision']}/{urllib.request.quote(record['path'])}"
  staging = ensure_dir(os.path.join(data_dir(), "staging"))
  part = os.path.join(staging, os.path.basename(blob_path(record)) + ".part")
  for attempt in range(5):
    offset = os.path.getsize(part) if os.path.exists(part) else 0
    if offset > record["size"]:
      os.unlink(part)
      offset = 0
    if offset == record["size"]:
      break
    headers = {"User-Agent": "omarchy-agent-local"}
    if offset:
      headers["Range"] = f"bytes={offset}-"
    token = hf_token()
    if token:
      headers["Authorization"] = f"Bearer {token}"
    try:
      with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=120) as response:
        if offset and response.status != 206:
          offset = 0
          mode = "wb"
        else:
          mode = "ab" if offset else "wb"
        with open(part, mode) as handle:
          while chunk := response.read(8 * 2**20):
            handle.write(chunk)
            progress.add(len(chunk))
      break
    except (urllib.error.URLError, TimeoutError, ConnectionError, OSError) as error:
      if attempt == 4:
        raise LocalError(f"Download of {record['repo']}/{record['path']} failed: {error}")
      time.sleep(3 * (attempt + 1))
  if not verify_file(part, record):
    os.unlink(part)
    raise LocalError(f"{record['repo']}/{record['path']} doesn't match its published hash; discarded")
  target = blob_path(record)
  ensure_dir(os.path.dirname(target))
  os.chmod(part, 0o644)
  os.replace(part, target)


def adopt_seed(record, seed_dir):
  if not seed_dir:
    return False
  candidate = os.path.join(seed_dir, record["dest"])
  if not os.path.isfile(candidate) or os.path.getsize(candidate) != record["size"]:
    return False
  say(f"  verifying {record['dest']} from {seed_dir}")
  if not verify_file(candidate, record):
    say(f"  {candidate} doesn't match the published hash; downloading instead")
    return False
  target = blob_path(record)
  ensure_dir(os.path.dirname(target))
  try:
    os.link(candidate, target)
  except OSError:
    shutil.copyfile(candidate, target)
  os.chmod(target, 0o644)
  return True


SHA256_RE = re.compile(r"^[0-9a-f]{64}$")
FILESET_RE = re.compile(r"^[0-9a-f]{16}$")


def validate_files(files, roles):
  """Refuse a file list that could write outside its model directory or name
  a blob by anything but its hash. A replayed manifest is user-editable."""
  errors = []
  if not isinstance(files, list) or not files:
    raise LocalError("Manifest has no files")
  dests = set()
  for index, record in enumerate(files):
    where = f"files[{index}]"
    if not isinstance(record, dict):
      raise LocalError(f"Manifest {where} is not a table")
    _safe_relpath(record.get("dest"), f"{where}.dest", errors)
    if not isinstance(record.get("size"), int) or record["size"] < 0:
      errors.append(f"{where}.size: must be a non-negative integer")
    if "sha256" in record:
      if not SHA256_RE.match(str(record["sha256"])):
        errors.append(f"{where}.sha256: must be 64 hex characters")
    elif not SHA_RE.match(str(record.get("git_oid", ""))):
      errors.append(f"{where}: needs sha256 or a 40-hex git_oid")
    dests.add(record.get("dest"))
  if len(dests) != len(files):
    errors.append("files: two records share a destination")
  for role, path in (roles or {}).items():
    if role not in ("model", "draft") or path not in dests:
      errors.append(f"roles.{role}: must name one of the files")
  if errors:
    raise LocalError("Manifest is invalid:\n  " + "\n  ".join(errors))


def fileset_id(files):
  digest = hashlib.sha256()
  for record in sorted(files, key=lambda r: r["dest"]):
    digest.update(f"{record['dest']}\0{record.get('sha256') or record.get('git_oid')}\n".encode())
  return digest.hexdigest()[:16]


def fileset_dir(rid, fileset=None):
  """Where a run's files live: one immutable directory per exact file set, so
  setting up a new one never touches the files a running or previous unit
  mounts. Manifests from before file sets mount the recipe directory itself."""
  base = os.path.join(data_dir(), "models", rid)
  return os.path.join(base, fileset) if fileset else base


def prune_filesets(rid, keep):
  """After a run commits, drop this recipe's other file sets and any files
  from the layout before file sets."""
  base = os.path.join(data_dir(), "models", rid)
  if not os.path.isdir(base) or not FILESET_RE.match(keep or ""):
    return
  for name in os.listdir(base):
    if name == keep:
      continue
    path = os.path.join(base, name)
    if os.path.isdir(path) and not os.path.islink(path):
      shutil.rmtree(path, ignore_errors=True)
    else:
      os.unlink(path)


def materialize(rid, files, roles, seed_dir=None):
  """Fetch a run's files and link them into their own file-set directory.
  Returns the file set id the unit mounts."""
  validate_files(files, roles)
  missing = [record for record in files if not os.path.isfile(blob_path(record))]
  missing = [record for record in missing if not adopt_seed(record, seed_dir)]
  need = sum(record["size"] for record in missing)
  if need:
    ensure_dir(data_dir())
    free = shutil.disk_usage(data_dir()).free
    if need + 2 * 2**30 > free:
      raise LocalError(f"Need {gib(need):.1f} GiB free for downloads, {gib(free):.1f} GiB available in {data_dir()}")
    say(f"Downloading {len(missing)} file(s), {gib(need):.1f} GiB, from Hugging Face")
    progress = Progress(need)
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
      for future in [pool.submit(download, record, progress) for record in missing]:
        future.result()
  fileset = fileset_id(files)
  target = fileset_dir(rid, fileset)
  if os.path.isdir(target):
    return fileset
  staging = target + ".partial"
  shutil.rmtree(staging, ignore_errors=True)
  ensure_dir(staging)
  # Paths are built from the resolved staging directory, so a model store
  # moved to another disk through a symlink still passes the containment check.
  root = os.path.realpath(staging)
  for record in files:
    dest = os.path.normpath(os.path.join(root, record["dest"]))
    if not dest.startswith(root + os.sep):
      raise LocalError(f"Refusing a file outside the model directory: {record['dest']}")
    ensure_dir(os.path.dirname(dest))
    if not (os.path.realpath(os.path.dirname(dest)) + os.sep).startswith(root + os.sep):
      raise LocalError(f"Refusing a file outside the model directory: {record['dest']}")
    os.link(blob_path(record), dest)
  os.replace(staging, target)
  return fileset


# ---------------------------------------------------------------- unit generation


def _systemd_escape(value):
  if CONTROL_RE.search(value):
    raise LocalError(f"Refusing a value with control characters: {value!r}")
  return value.replace("%", "%%").replace("$", "$$")


def _quote(value):
  escaped = _systemd_escape(value).replace("\\", "\\\\").replace('"', '\\"')
  return f'"{escaped}"'


def server_invocation(runtime, recipe, variant, roles, rid):
  """Returns (entrypoint, argv, env) with the key as KEY_PLACEHOLDER when it's an argument."""
  inputs = runtime["inputs"]
  values = {
    "model": f"/models/{roles['model']}",
    "draft": f"/models/{roles['draft']}" if roles.get("draft") else None,
    "ctx": str(variant["ctx"]),
    "alias": rid,
    "key": KEY_PLACEHOLDER,
  }
  for name, value in recipe.get("sampling", {}).items():
    values[name] = f"{value:g}" if isinstance(value, float) else str(value)
  argv = list(runtime.get("command", []))
  env = {}
  skipped = []
  for name in STANDARD_INPUTS:
    value = values.get(name)
    if value is None:
      continue
    mapping = inputs.get(name)
    if mapping is None:
      if name in ("temperature", "top_p", "top_k"):
        skipped.append(name)
        continue
      if name in ("draft", "ctx"):
        raise LocalError(f"Runtime has no mapping for {name}")
      continue
    if "arg" in mapping:
      argv += [mapping["arg"], value]
    elif name != "key":
      env[mapping["env"]] = value
  argv += recipe.get("server", {}).get("args", [])
  entrypoint = None
  if KEY_PLACEHOLDER in argv:
    script = f'a=(); for x in "$@"; do [[ $x == {KEY_PLACEHOLDER} ]] && x=${KEY_ENV}; a+=("$x"); done; exec "${{a[@]}}"'
    argv = ["-c", script, "omarchy-local"] + argv
    entrypoint = runtime["shell"]
  return entrypoint, argv, env, skipped


def device_lines(runtime, gpu):
  lines = []
  for device in runtime.get("run", {}).get("devices", []):
    if device == "render":
      lines.append(f"AddDevice={gpu['render_node']}")
    elif device == "kfd":
      lines.append("AddDevice=/dev/kfd")
    elif device == "cdi-nvidia":
      lines.append("AddDevice=nvidia.com/gpu=all")
  return lines


# Quadlet otherwise orders every unit after the system's network-online.target
# through podman-user-wait-network-online.service. These units have no outside
# network to wait for, and where that target never arrives every start would
# sit out the 90s timeout first.
QUADLET_SECTION = ["[Quadlet]", "DefaultDependencies=false"]


def render_network():
  return "\n".join(QUADLET_SECTION + ["", "[Network]", f"NetworkName={NETWORK_NAME}", "Internal=true"]) + "\n"


def render_container(rid, recipe, runtime, variant, roles, gpu, autostart=False, fileset=None):
  for value in (rid, recipe.get("name", "")):
    if CONTROL_RE.search(value):
      raise LocalError("Refusing a recipe name with control characters")
  if not ID_RE.match(rid) or not IMAGE_RE.match(runtime["image"]) or (fileset and not FILESET_RE.match(fileset)):
    raise LocalError("Refusing an invalid recipe id or image reference")
  entrypoint, argv, env, _ = server_invocation(runtime, recipe, variant, roles, rid)
  run = runtime.get("run", {})
  key_mapping = runtime["inputs"]["key"]
  lines = [
    "# Generated by omarchy-agent-local-use; changes are overwritten.",
    "[Unit]",
    f"Description=Omarchy local model {rid}",
    "PartOf=graphical-session.target",
    "After=graphical-session.target",
    "StartLimitIntervalSec=10m",
    "StartLimitBurst=3",
    "",
    *QUADLET_SECTION,
    "",
    "[Container]",
    f"ContainerName={unit_base(rid)}",
    f"Image={runtime['image']}",
    f"Label=org.omarchy.agent-local.recipe={rid}",
    f"Network={NETWORK_UNIT}",
    f"PublishPort=127.0.0.1:{port_for(rid)}:{runtime['port']}",
    f"Volume=%h/.local/share/omarchy/agent-local/models/{rid}{'/' + fileset if fileset else ''}:/models:ro",
    f"Secret={SECRET},type=env,target={KEY_ENV}",
  ]
  if "env" in key_mapping:
    lines.append(f"Secret={SECRET},type=env,target={key_mapping['env']}")
  lines += device_lines(runtime, gpu)
  if run.get("group_add") == "keep-groups":
    lines.append("GroupAdd=keep-groups")
  if run.get("memlock") == "unlimited":
    lines.append("Ulimit=memlock=-1:-1")
  if run.get("shm_size_gib"):
    lines.append(f"ShmSize={int(run['shm_size_gib'] * 1024)}m")
  for name, value in sorted(env.items()):
    lines.append(f"Environment={_quote(f'{name}={value}')}")
  lines += ["ReadOnly=true", "DropCapability=all", "NoNewPrivileges=true"]
  if entrypoint:
    lines.append(f"Entrypoint={_systemd_escape(entrypoint)}")
  if argv:
    lines.append("Exec=" + " ".join(_quote(arg) for arg in argv))
  probe = runtime["health"]["probe"]
  for part in probe:
    _systemd_escape(part)
  probe_json = _systemd_escape(json.dumps(probe))
  lines += [
    # While loading, probe every 2s so the unit goes active as soon as the model
    # is ready; once it passes, the regular check takes over every 30s.
    "HealthStartupCmd=" + probe_json,
    "HealthStartupInterval=2s",
    "HealthStartupRetries=300",
    "HealthStartupSuccess=1",
    "HealthCmd=" + probe_json,
    "HealthInterval=30s",
    "HealthTimeout=5s",
    "HealthRetries=3",
    "HealthStartPeriod=10m",
    "HealthOnFailure=kill",
    "Notify=healthy",
    "",
    "[Service]",
    "TimeoutStartSec=12m",
    "Restart=on-failure",
    "RestartSec=10s",
    # The agents panel watches status.json; every start, stop and crash rewrites it.
    # systemd resolves a bare name in its own search path, not PATH; env uses the
    # unit's PATH, which holds Omarchy's bin.
    # Each hook says how the transition ended: systemd still reports it as
    # activating or deactivating while its Post commands run.
    f"ExecStartPost=-/usr/bin/env omarchy-agent-local-status --write --started {rid}",
    f"ExecStopPost=-/usr/bin/env omarchy-agent-local-status --write --stopped {rid}",
  ]
  if autostart:
    lines += ["", "[Install]", "WantedBy=graphical-session.target"]
  return "\n".join(lines) + "\n"


# ---------------------------------------------------------------- systemd and podman


def systemctl(*args, check=False, timeout=None):
  return subprocess.run(["systemctl", "--user", *args], capture_output=True, text=True, check=check, timeout=timeout)


# ---------------------------------------------------------------- one unit per model
#
# Every recipe runs as its own Quadlet unit on its own loopback port, so several
# models can run side by side when memory allows. Names never collide with the
# shared network unit (omarchy-agent-local.network becomes
# omarchy-agent-local-network.service), whatever a recipe is called.


def unit_base(rid):
  return f"{UNIT_PREFIX}{rid}"


def unit_name(rid):
  return f"{unit_base(rid)}.service"


def quadlet_path(rid):
  return os.path.join(quadlet_dir(), f"{unit_base(rid)}.container")


def ports_path():
  return os.path.join(state_dir(), "ports.json")


def load_ports():
  try:
    with open(ports_path()) as handle:
      ports = json.load(handle)
    return {rid: int(port) for rid, port in ports.items() if ID_RE.match(rid)}
  except (OSError, ValueError, AttributeError):
    return {}


def port_for(rid):
  """A stable loopback port per recipe, so a model's endpoint never moves."""
  ports = load_ports()
  if rid not in ports:
    taken = set(ports.values())
    port = BASE_PORT
    while port in taken:
      port += 1
    ports[rid] = port
    write_atomic(ports_path(), json.dumps(ports, indent=2, sort_keys=True) + "\n")
  return ports[rid]


def endpoint(rid):
  return f"http://127.0.0.1:{port_for(rid)}/v1"


def unit_props(rid, *names):
  result = systemctl("show", unit_name(rid), "--timestamp=unix", *(f"--property={name}" for name in names))
  props = {}
  for line in result.stdout.splitlines():
    key, _, value = line.partition("=")
    props[key] = value
  return props


def unit_active(rid):
  return unit_props(rid, "ActiveState").get("ActiveState") in ("active", "activating", "reloading")


def journal_tail(rid, lines=15):
  result = subprocess.run(["journalctl", "--user", "-u", unit_name(rid), "-n", str(lines), "-o", "cat", "--no-pager"], capture_output=True, text=True)
  return result.stdout.strip()


def ensure_key():
  path = key_path()
  if not os.path.isfile(path):
    ensure_dir(config_dir(), 0o700)
    import secrets
    write_atomic(path, secrets.token_urlsafe(32), mode=0o600)
  os.chmod(path, 0o600)
  with open(path) as handle:
    key = handle.read().strip()
  # The secret is the bare key: a trailing newline from the file would reach the
  # server through --api-key or its key variable and never match a Bearer header.
  result = subprocess.run(["podman", "secret", "create", "--replace", SECRET, "-"], input=key, capture_output=True, text=True)
  if result.returncode != 0:
    raise LocalError(f"Can't store the API key as a Podman secret: {result.stderr.strip()}")
  return key


# Podman's per-layer bars, as it draws them on a terminal: "Copying blob
# <id> [===>---] 1.2GiB / 3.4GiB | 80 MiB/s", then "Copying blob <id> done".
PULL_BAR_RE = re.compile(r"Copying blob (\w+) .*?([\d.]+)\s*([KMG]?i?B|b) / ([\d.]+)\s*([KMG]?i?B|b)")
PULL_DONE_RE = re.compile(r"Copying blob (\w+) (?:done|skipped)")
PULL_UNITS = {"b": 1, "B": 1, "KiB": 2**10, "MiB": 2**20, "GiB": 2**30, "KB": 1e3, "MB": 1e6, "GB": 1e9}


def ensure_image(image):
  if subprocess.run(["podman", "image", "exists", image]).returncode == 0:
    return
  say(f"Pulling the runtime image {image.split('@')[0]}")
  # Podman only draws byte progress on a terminal, one redrawn bar per layer,
  # which scrolls into a wall of lines in a narrow window. It draws to a
  # pseudo-terminal here instead, and its bars become the one progress line
  # downloads use. Run from a systemd unit's environment, Podman would also
  # cap the pull at five minutes, too short for a large image.
  env = {key: value for key, value in os.environ.items() if key not in ("NOTIFY_SOCKET", "INVOCATION_ID", "JOURNAL_STREAM", "SYSTEMD_EXEC_PID")}
  master, slave = pty.openpty()
  fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 50, 400, 0, 0))
  process = subprocess.Popen(["podman", "pull", image], stdin=subprocess.DEVNULL, stdout=slave, stderr=slave, env=env)
  os.close(slave)
  layers = {}
  started = time.time()
  shown = started
  pending = ""
  lines = []
  while True:
    try:
      chunk = os.read(master, 65536)
    except OSError:
      break
    if not chunk:
      break
    pending += re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "\n", chunk.decode("utf-8", "replace"))
    *complete, pending = re.split(r"[\r\n]", pending)
    for line in (line.strip() for line in complete):
      if not line:
        continue
      bar = PULL_BAR_RE.search(line)
      done = PULL_DONE_RE.search(line)
      if bar:
        layers[bar.group(1)] = (float(bar.group(2)) * PULL_UNITS.get(bar.group(3), 1), float(bar.group(4)) * PULL_UNITS.get(bar.group(5), 1))
      elif done and done.group(1) in layers:
        total = layers[done.group(1)][1]
        layers[done.group(1)] = (total, total)
      elif "Copying blob" not in line:
        lines.append(line)
    now = time.time()
    if layers and now - shown >= 5:
      shown = now
      got = sum(value[0] for value in layers.values())
      total = sum(value[1] for value in layers.values())
      say(f"  {gib(got):6.1f} / {gib(total):.1f} GiB  {got / max(now - started, 0.001) / 2**20:6.0f} MiB/s")
  os.close(master)
  if process.wait() != 0:
    raise LocalError(f"Can't pull {image}" + ("\n" + "\n".join(lines[-5:]) if lines else ""))
  total = sum(value[1] for value in layers.values())
  say(f"  {gib(total):6.1f} / {gib(total):.1f} GiB  in {time.time() - started:.0f}s")


def preflight(runtime, gpu):
  user = os.environ.get("USER") or home().rsplit("/", 1)[-1]
  for path in ("/etc/subuid", "/etc/subgid"):
    if not any(line.split(":", 1)[0] == user for line in _read(path).splitlines()):
      raise LocalError(f"{path} has no range for {user}; rootless Podman needs one (sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 {user})")
  for line in device_lines(runtime, gpu):
    device = line.split("=", 1)[1]
    if device.startswith("/dev/") and not os.access(device, os.R_OK | os.W_OK):
      raise LocalError(f"{device} isn't accessible to {user}; add the user to its group (ls -l {device}) and log in again")


def http_status(url, key=None, timeout=10):
  headers = {"User-Agent": "omarchy-agent-local"}
  if key:
    headers["Authorization"] = f"Bearer {key}"
  try:
    with urllib.request.urlopen(urllib.request.Request(url, headers=headers), timeout=timeout) as response:
      return response.status, response.read()
  except urllib.error.HTTPError as error:
    return error.code, b""
  except (urllib.error.URLError, TimeoutError, ConnectionError) as error:
    return 0, str(error).encode()


def post_start_checks(rid, key):
  base = f"{endpoint(rid)}/models"
  status, _ = http_status(base)
  if status not in (401, 403):
    raise LocalError(f"The server answered {status or 'nothing'} without the key; refusing a model that doesn't enforce its key")
  status, body = http_status(base, key)
  if status != 200:
    raise LocalError(f"The server answered {status or 'nothing'} with the key")
  try:
    ids = [entry.get("id") for entry in json.loads(body).get("data", [])]
  except ValueError:
    ids = []
  if rid not in ids:
    raise LocalError(f"Port {port_for(rid)} is serving {', '.join(map(str, ids)) or 'an unknown model'}, not {rid}")


def free_memory(gpu):
  mem = meminfo()
  available = gib(mem.get("MemAvailable", 0))
  gpu_free = gpu["memory_gib"]
  if gpu.get("sysfs"):
    used = int(_read(os.path.join(gpu["sysfs"], "mem_info_gtt_used"), "0") or 0) + int(_read(os.path.join(gpu["sysfs"], "mem_info_vram_used"), "0") or 0)
    gpu_free = gpu["memory_gib"] - gib(used)
  return available, gpu_free


def top_memory_users(count=3):
  result = subprocess.run(["ps", "-eo", "rss=,comm=", "--sort=-rss"], capture_output=True, text=True)
  users = []
  for line in result.stdout.splitlines()[:count]:
    rss, _, name = line.strip().partition(" ")
    if rss.isdigit():
      users.append(f"{name.strip()} ({int(rss) / 2**20:.1f} GiB)")
  return ", ".join(users)


def evict_idle_weights(keep=()):
  """Drop the page cache of weights no running model needs.

  A model that just stopped leaves its weights in the page cache. The kernel
  would reclaim them on demand, but only page by page, so a runtime pinning
  tens of GiB in large contiguous blocks (halogen's KV pool) stalls on memory
  that is free in total but fragmented. POSIX_FADV_DONTNEED on files we own
  frees those pages at once, unprivileged, and the freed runs coalesce: on a
  128 GB Strix Halo, reading a 29 GiB model left 165 free 2 MiB blocks and
  evicting it brought back 5,301. Weights of `keep` recipes and of models
  still running are left alone; their runtimes may be reading them."""
  keep = set(keep) | running_models()
  wanted = set()
  for rid in keep:
    manifest = load_model(rid)
    if manifest:
      wanted.update(blob_path(record) for record in manifest["files"])
  for directory, _, names in os.walk(os.path.join(data_dir(), "blobs")):
    for name in names:
      path = os.path.join(directory, name)
      if path in wanted:
        continue
      try:
        fd = os.open(path, os.O_RDONLY)
      except OSError:
        continue
      try:
        os.posix_fadvise(fd, 0, 0, os.POSIX_FADV_DONTNEED)
      finally:
        os.close(fd)


def check_headroom(variant, gpu):
  for _ in range(15):
    available, gpu_free = free_memory(gpu)
    if available >= variant["peak_ram_gib"] + RESERVE_GIB and gpu_free >= variant["peak_gpu_gib"]:
      return available, gpu_free
    time.sleep(1)
  running = [rid for rid in known_models() if unit_active(rid)]
  names = [(load_model(rid) or {}).get("recipe", {}).get("name", rid) for rid in running]
  need = variant["peak_ram_gib"] + RESERVE_GIB
  short = f"{NOT_ENOUGH_MEMORY} (needs {need:g} GiB)"
  raise LocalError(
    f"Not enough free memory right now: the model needs {variant['peak_ram_gib']:g} GiB RAM plus {RESERVE_GIB} GiB for the desktop "
    f"and {variant['peak_gpu_gib']:g} GiB GPU-addressable; {available:.1f} GiB RAM and {gpu_free:.1f} GiB GPU are free.\n"
    + (f"Local models running: {', '.join(running)} (stop one with: omarchy agent local stop <recipe>)\n" if running else "")
    + f"Largest memory users: {top_memory_users()}",
    short=short,
  )


# ---------------------------------------------------------------- runs and manifests


def runs_dir():
  return os.path.join(state_dir(), "runs")


def models_dir():
  return os.path.join(state_dir(), "models")


def model_manifest_path(rid):
  return os.path.join(models_dir(), f"{rid}.json")


def load_model(rid):
  """The manifest a recipe currently runs from, or None if it isn't set up."""
  try:
    with open(model_manifest_path(rid)) as handle:
      return json.load(handle)
  except (OSError, ValueError):
    return None


def known_models():
  """Every recipe set up on this machine, in no particular order."""
  if not os.path.isdir(models_dir()):
    return []
  return sorted(name[:-5] for name in os.listdir(models_dir()) if name.endswith(".json") and ID_RE.match(name[:-5]))


def last_model_id():
  rid = _read(os.path.join(state_dir(), "last"))
  return rid if rid and load_model(rid) else None


def default_model(running_only=False):
  """The model a launch or bench means when none is named: the last one
  started, if it qualifies, else any running one."""
  last = last_model_id()
  if last and (not running_only or unit_active(last)):
    return load_model(last)
  for rid in known_models():
    if not running_only or unit_active(rid):
      return load_model(rid)
  return None


def resolve_model(rid=None, running_only=False):
  if rid:
    if not ID_RE.match(rid):
      raise LocalError("Not a recipe id")
    manifest = load_model(rid)
    if not manifest:
      raise LocalError(f"{rid} isn't set up. Run: omarchy agent local use {rid}")
    if running_only and not unit_active(rid):
      raise LocalError(f"{rid} isn't running. Start it with: omarchy agent local start {rid}")
    return manifest
  manifest = default_model(running_only)
  if not manifest:
    raise LocalError("No local model is running. Run: omarchy agent local use best" if running_only else "No local model set up. Run: omarchy agent local use best")
  return manifest


def save_run(manifest):
  stamp = time.strftime("%Y%m%dT%H%M%S")
  rid = manifest["recipe_id"]
  path = os.path.join(runs_dir(), f"{stamp}-{rid}.json")
  text = json.dumps(manifest, indent=2) + "\n"
  write_atomic(path, text)
  write_atomic(model_manifest_path(rid), text)
  write_atomic(os.path.join(state_dir(), "last"), rid + "\n")
  return path


def stop_seconds_path(rid):
  return os.path.join(state_dir(), "stops", rid)


def expected_stop_seconds(rid):
  try:
    return float(_read(stop_seconds_path(rid)))
  except ValueError:
    return None


def load_seconds_path(rid):
  return os.path.join(state_dir(), "loads", rid)


def expected_load_seconds(rid, manifest):
  """How long this model's last start took, which the panel's loading bar
  runs against. Every start reads weights cold (stops evict them), so the
  last start predicts the next far better than the setup run did."""
  try:
    return float(_read(load_seconds_path(rid)))
  except ValueError:
    return (manifest.get("observed") or {}).get("load_seconds")


def error_path(rid):
  return os.path.join(state_dir(), "errors", rid)


def record_error(rid, reason):
  """Keep why a model couldn't start, for the panel to show on its line."""
  write_atomic(error_path(rid), " ".join(str(reason).split()) + "\n")


def clear_error(rid):
  if os.path.exists(error_path(rid)):
    os.unlink(error_path(rid))


def autostart_flag(rid):
  return os.path.join(state_dir(), "autostart", rid)


def autostart_enabled(rid):
  return os.path.exists(autostart_flag(rid))


class Lock:
  def __enter__(self):
    ensure_dir(state_dir())
    self.handle = open(os.path.join(state_dir(), "lock"), "w")
    try:
      fcntl.flock(self.handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
      say("Another omarchy agent local command is running; waiting for it")
      fcntl.flock(self.handle, fcntl.LOCK_EX)
    return self

  def __exit__(self, *exc):
    fcntl.flock(self.handle, fcntl.LOCK_UN)
    self.handle.close()


def write_unit_files(rid, container_text):
  ensure_dir(quadlet_dir())
  write_atomic(os.path.join(quadlet_dir(), NETWORK_UNIT), render_network())
  if container_text is None:
    if os.path.exists(quadlet_path(rid)):
      os.unlink(quadlet_path(rid))
  else:
    write_atomic(quadlet_path(rid), container_text)
  systemctl("daemon-reload", check=True)


def start_unit(rid):
  say("Starting the model (waiting until it's loaded and healthy)")
  process = subprocess.Popen(["systemctl", "--user", "start", unit_name(rid)], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
  started = time.time()
  while process.poll() is None:
    time.sleep(1)
    elapsed = int(time.time() - started)
    if elapsed and elapsed % 15 == 0:
      say(f"  still loading ({elapsed}s)")
  if process.returncode != 0:
    raise LocalError(f"The model didn't start: {process.stderr.read().strip()}\n{journal_tail(rid)}")
  return time.time() - started


def activate(manifest, recipe, runtime, gpu, key):
  """Start a recipe from a resolved manifest. Other models keep running; a
  failure restores this recipe's previous unit, and restarts it if it ran."""
  rid = manifest["recipe_id"]
  previous_text = open(quadlet_path(rid)).read() if os.path.isfile(quadlet_path(rid)) else None
  was_running = unit_active(rid)
  container_text = render_container(rid, recipe, runtime, manifest["variant"], manifest["roles"], gpu, autostart_enabled(rid), manifest.get("fileset"))
  if was_running:
    say(f"Restarting {rid} with the new setup (its in-flight requests are interrupted)")
    write_status({rid: "deactivating"})
    systemctl("stop", unit_name(rid))
  clear_error(rid)
  try:
    evict_idle_weights(keep=[rid])
    before_ram, before_gpu = check_headroom(manifest["variant"], gpu)
    write_unit_files(rid, container_text)
    systemctl("reset-failed", unit_name(rid))
    write_status({rid: "activating"}, pending={rid: (recipe, manifest)})
    load_seconds = start_unit(rid)
    post_start_checks(rid, key)
  except (LocalError, subprocess.CalledProcessError) as error:
    systemctl("stop", unit_name(rid))
    write_unit_files(rid, previous_text)
    if previous_text is not None and was_running:
      say(f"Restoring the previous setup of {rid}")
      systemctl("start", unit_name(rid))
    short = getattr(error, "short", None) or str(error).splitlines()[0]
    record_error(rid, short)
    write_status()
    raise LocalError(str(error), short=short)
  after_ram, after_gpu = free_memory(gpu)
  manifest["observed"] = {
    "load_seconds": round(load_seconds, 1),
    "ram_used_gib": round(before_ram - after_ram, 1),
    "gpu_used_gib": round(before_gpu - after_gpu, 1),
  }


# ---------------------------------------------------------------- commands


def _lookup_recipe(catalog, target):
  if target not in catalog.recipes:
    known = ", ".join(sorted(catalog.recipes)) or "none"
    raise LocalError(f"No recipe '{target}' in catalog {catalog.commit[:12]} (known: {known})")
  return catalog.recipes[target]


def cmd_use(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local use")
  parser.add_argument("target", nargs="?", help="best, or a recipe id")
  parser.add_argument("--manifest", help="rerun a resolved manifest exactly")
  parser.add_argument("--ctx", type=int)
  parser.add_argument("--gpu")
  parser.add_argument("--catalog", dest="pin", help="use this catalog commit")
  parser.add_argument("--seed", help="reuse matching files from this directory before downloading")
  parser.add_argument("--unqualified", action="store_true", help="run a recipe not measured on this machine class")
  args = parser.parse_args(argv)
  if not args.target and not args.manifest:
    parser.error("give 'best', a recipe id, or --manifest <file>")
  with Lock():
    profile = machine_profile()
    write_profile_cache(profile)
    gpu = choose_gpu(profile, args.gpu)
    if args.manifest:
      with open(args.manifest) as handle:
        old = json.load(handle)
      rid, recipe, runtime, variant = old["recipe_id"], old["recipe"], old["runtime"], old["variant"]
      errors = validate_runtime(old["runtime_id"], runtime) + validate_recipe(rid, recipe, {old["runtime_id"]: runtime})
      errors = [error for error in errors if "is missing" not in error]
      if errors:
        raise LocalError("Manifest is invalid:\n  " + "\n  ".join(errors))
      catalog_info = old["catalog"]
      say(f"Rerunning {rid} from {args.manifest}")
    else:
      catalog, note = refresh_catalog(pin=args.pin)
      if note:
        say(f"Note: {note}")
      if args.target == "best":
        rid, variant, skipped = resolve_best(catalog, profile, gpu, args.ctx)
        for skipped_id, reason in skipped:
          say(f"Skipping {skipped_id}: {reason}")
        say(f"Best for this machine ({gpu['family']}, {profile['ram_class']} GB): {rid}")
      else:
        rid = args.target
        _lookup_recipe(catalog, rid)
        variant, reason = compatibility(catalog, rid, profile, gpu, args.ctx)
        if variant is None:
          if not args.unqualified:
            raise LocalError(f"{rid} isn't qualified for this machine: {reason}\nRun with --unqualified to try anyway.")
          variant, fit_reason = pick_variant(catalog.recipes[rid], profile, gpu, args.ctx)
          if variant is None:
            raise LocalError(f"{rid} doesn't fit: {fit_reason}")
          say(f"Warning: {reason}")
      recipe = catalog.recipes[rid]
      runtime = catalog.runtimes[recipe["runtime"]]
      catalog_info = {"url": catalog.source, "commit": catalog.commit, "overrides": sorted(catalog.overrides)}
      if runtime.get("tier") == "third-party":
        review = load_review(catalog, runtime)
        say(f"Runtime {recipe['runtime']} is third-party: {review.get('publisher', 'unknown publisher')}, license {review.get('license_url', 'unknown')}")
    if runtime.get("key_on_cmdline"):
      say(f"Warning: runtime {recipe['runtime']} takes its key as a command-line argument, visible in the process list to other local users")
    preflight(runtime, gpu)
    files, roles = (old["files"], old["roles"]) if args.manifest else build_artifacts(recipe)
    say(f"Recipe {rid}: {len(files)} file(s), {gib(sum(f['size'] for f in files)):.1f} GiB, context {variant['ctx']}")
    for license_name in sorted({f"{f['repo']} ({f['license']})" for f in files}):
      say(f"  weights: {license_name}")
    fileset = materialize(rid, files, roles, args.seed)
    ensure_image(runtime["image"])
    key = ensure_key()
    manifest = {
      "schema": SCHEMA,
      "recipe_id": rid,
      "runtime_id": recipe["runtime"],
      "catalog": catalog_info,
      "profile": profile,
      "gpu": gpu["family"],
      "variant": variant,
      "recipe": recipe,
      "runtime": runtime,
      "image": runtime["image"],
      "files": files,
      "roles": roles,
      "fileset": fileset,
      "created_at": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
    }
    _, argv_out, env_out, skipped = server_invocation(runtime, recipe, variant, roles, rid)
    manifest["launch"] = {"argv": argv_out, "env": env_out}
    if skipped:
      say(f"Note: runtime {recipe['runtime']} takes no {', '.join(skipped)} default; clients choose their own")
    activate(manifest, recipe, runtime, gpu, key)
    path = save_run(manifest)
    prune_filesets(rid, fileset)
    refresh_list_cache(profile)
    write_status()
    say("")
    say(f"Running {rid} at {endpoint(rid)} (model id {rid}, key in {key_path()})")
    say(f"Loaded in {manifest['observed']['load_seconds']:.0f}s, using about {manifest['observed']['ram_used_gib']:.0f} GiB")
    say(f"Manifest: {path}")
    say(f"Launch an agent against it with: omarchy agent --local-model {rid}")
  return 0


def running_models():
  return {rid for rid in known_models() if unit_active(rid)}


def refresh_list_cache(profile=None):
  catalog = cached_catalog()
  if catalog is None:
    return []
  profile = profile or machine_profile()
  rows = recipe_listing(catalog, profile, running_models())
  write_list_cache(rows)
  return rows


def cmd_list(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local list")
  parser.add_argument("--json", action="store_true")
  parser.add_argument("--offline", action="store_true", help="use the cached catalog")
  args = parser.parse_args(argv)
  profile = machine_profile()
  write_profile_cache(profile)
  if args.offline:
    catalog, note = cached_catalog(), ""
    if catalog is None:
      raise LocalError("No cached catalog yet; run without --offline")
  else:
    catalog, note = refresh_catalog()
  rows = recipe_listing(catalog, profile, running_models())
  write_list_cache(rows)
  if args.json:
    print(json.dumps(rows, indent=2))
    return 0
  if note:
    say(f"Note: {note}")
  gpu = profile["gpus"][0]["family"] if profile["gpus"] else "no GPU"
  say(f"Catalog {catalog.commit[:12]} · this machine: {gpu}, {profile['ram_class']} GB, {profile['platform']}")
  for row in rows:
    marks = [mark for mark, on in (("best", row["best"]), ("running", row["active"]), ("installed", row["installed"]), ("local override", row["override"])) if on]
    tier = f" · third-party ({row['publisher']})" if row["tier"] == "third-party" else ""
    say(f"{'●' if row['available'] else '○'} {row['id']}{' [' + ', '.join(marks) + ']' if marks else ''}")
    say(f"    {row['name']} on {row['runtime']}{tier} — {row['summary']}")
    if not row["available"]:
      say(f"    unavailable: {row['reason']}")
  return 0


def _unix_ms(value):
  value = (value or "").lstrip("@")
  return int(value) * 1000 if value.isdigit() else None


def latest_run(rid):
  runs = runs_dir()
  if not os.path.isdir(runs):
    return None
  names = sorted(name for name in os.listdir(runs) if run_recipe_id(name) == rid)
  if not names:
    return None
  try:
    with open(os.path.join(runs, names[-1])) as handle:
      return json.load(handle)
  except (OSError, ValueError):
    return None


def start_fit(manifest, profile):
  """Whether a stopped model fits in the memory free right now: (fits, reason).
  Rewritten with every start and stop, the moments free memory changes."""
  variant = manifest["variant"]
  try:
    gpu = choose_gpu(profile, manifest.get("gpu"))
  except LocalError as error:
    return False, error.short
  available, gpu_free = free_memory(gpu)
  if available >= variant["peak_ram_gib"] + RESERVE_GIB and gpu_free >= variant["peak_gpu_gib"]:
    return True, ""
  return False, "Not enough memory"


def model_record(rid, manifest, catalog=None, profile=None):
  props = unit_props(rid, "ActiveState", "SubState", "Result", "InactiveExitTimestamp", "ActiveExitTimestamp")
  unit = props.get("ActiveState", "inactive") or "inactive"
  # A removal in progress outranks the unit's own state, which passes
  # through stopping and stopped on the way.
  removing = _read(removing_path(rid))
  if removing:
    unit = "removing"
  recipe = manifest["recipe"]
  vendor = recipe.get("vendor", "")
  if not vendor and catalog:
    vendor = catalog.recipes.get(rid, {}).get("vendor", "")
  observed = manifest.get("observed") or {}
  fits, fit_reason = (True, "") if unit in ("active", "activating", "deactivating", "removing") or profile is None else start_fit(manifest, profile)
  error = _read(error_path(rid))
  # A memory refusal isn't a failure to show: play is greyed out with its
  # reason before a start is even tried.
  if error.startswith(NOT_ENOUGH_MEMORY):
    error = ""
  if not error and unit == "failed":
    error = f"Stopped unexpectedly ({props.get('Result') or 'failed'})"
  return {
    # Why the last start failed, shown where the progress bar was.
    "error": error,
    # Whether play can start it now; the panel greys play out when it can't.
    "fits": fits,
    "fit_reason": fit_reason,
    "recipe": rid,
    "name": recipe.get("name", rid),
    "vendor": vendor,
    "runtime": manifest["runtime_id"],
    "image": manifest["image"],
    "ctx": manifest["variant"]["ctx"],
    "unit": unit,
    "sub_state": props.get("SubState", ""),
    "result": props.get("Result", ""),
    "port": port_for(rid),
    "endpoint": endpoint(rid),
    "autostart": autostart_enabled(rid),
    "catalog_commit": manifest["catalog"]["commit"],
    "observed": observed or None,
    # When the current start or stop began, and how long the last load took:
    # the panel's progress bar measures the one against the other.
    "since_ms": int(os.path.getmtime(removing_path(rid)) * 1000) if removing else _unix_ms(props.get("InactiveExitTimestamp") if unit == "activating" else props.get("ActiveExitTimestamp") if unit == "deactivating" else ""),
    "expected_load_seconds": expected_load_seconds(rid, manifest),
    "expected_stop_seconds": expected_stop_seconds(rid),
    "expected_remove_seconds": float(removing) if removing else None,
  }


def status_record():
  catalog = cached_catalog()
  state = catalog_state()
  profile = machine_profile()
  models = {rid: model_record(rid, load_model(rid), catalog, profile) for rid in known_models()}
  record = {
    "models": models,
    "last": last_model_id(),
    "ram_total_gib": round(gib(meminfo().get("MemTotal", 0)), 1),
    "catalog_current": state.get("current"),
    "catalog_age_hours": round((time.time() - state.get("fetched_at", 0)) / 3600, 1) if state.get("fetched_at") else None,
    "best": None,
  }
  if catalog:
    try:
      profile = machine_profile()
      record["best"] = resolve_best(catalog, profile, choose_gpu(profile))[0]
    except LocalError:
      pass
  return record


def write_status(transitions=None, pending=None):
  """Rewrite status.json, which the agents panel watches. `transitions` reports
  a start or stop before systemd reaches it, so a click shows at once;
  `pending` describes a model being set up before its manifest is saved.

  Collecting and replacing happen under one lock, so a writer that started
  earlier can't land its older snapshot over a newer one."""
  ensure_dir(state_dir())
  with open(os.path.join(state_dir(), "status.lock"), "w") as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    record = status_record()
    now = int(time.time() * 1000)
    for rid, (recipe, manifest) in (pending or {}).items():
      run = latest_run(rid) or {}
      record["models"][rid] = model_record(rid, {**manifest, "observed": run.get("observed")})
    for rid, unit in (transitions or {}).items():
      if rid in record["models"]:
        record["models"][rid]["unit"] = unit
        record["models"][rid]["since_ms"] = now if unit in ("activating", "deactivating") else None
        if unit == "active":
          record["models"][rid]["error"] = ""
    write_atomic(os.path.join(state_dir(), "status.json"), json.dumps(record, indent=2) + "\n")
    return record


def cmd_status(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local status")
  parser.add_argument("--json", action="store_true")
  parser.add_argument("--write", action="store_true", help=argparse.SUPPRESS)
  parser.add_argument("--started", metavar="RECIPE", help=argparse.SUPPRESS)
  parser.add_argument("--stopped", metavar="RECIPE", help=argparse.SUPPRESS)
  args = parser.parse_args(argv)
  if args.write:
    # From the units' hooks, which run before systemd finishes the transition
    # they report, so the outcome is passed in rather than read back.
    transitions = {}
    if args.started and ID_RE.match(args.started):
      clear_error(args.started)
      transitions[args.started] = "active"
    if args.stopped and ID_RE.match(args.stopped):
      result = os.environ.get("SERVICE_RESULT", "success")
      if result == "success":
        transitions[args.stopped] = "inactive"
      else:
        record_error(args.stopped, f"Stopped unexpectedly ({result})")
        transitions[args.stopped] = "failed"
    write_status(transitions)
    return 0
  record = status_record()
  if args.json:
    print(json.dumps(record, indent=2))
    return 0
  if not record["models"]:
    say("No local model has been set up. Run: omarchy agent local use best")
    return 0
  for rid, model in record["models"].items():
    state = {"active": "running", "activating": "loading", "deactivating": "stopping"}.get(model["unit"], model["unit"])
    say(f"{rid} ({model['name']}) on {model['runtime']}: {state}")
    say(f"  endpoint {model['endpoint']} · model id {rid} · context {model['ctx']} · autostart {'on' if model['autostart'] else 'off'}")
    if model["unit"] == "failed":
      say(f"  last failure: {model['result']}")
      tail = journal_tail(rid, 5)
      if tail:
        say("  " + tail.replace("\n", "\n  "))
  if record["catalog_age_hours"] is not None:
    say(f"Catalog {str(record['catalog_current'])[:12]}, {record['catalog_age_hours']}h old")
  if record["best"] and record["best"] not in record["models"]:
    say(f"The recommendation for this machine is {record['best']}: omarchy agent local use best")
  return 0


def cmd_stop(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local stop")
  parser.add_argument("recipe", nargs="?", help="the model to stop (default: every running one)")
  args = parser.parse_args(argv)
  targets = [resolve_model(args.recipe)["recipe_id"]] if args.recipe else sorted(running_models())
  if not targets:
    say("No local model is running")
    return 0
  # A model takes seconds to let go of its memory; the panel says so meanwhile.
  write_status({rid: "deactivating" for rid in targets})
  for rid in targets:
    started = time.time()
    systemctl("stop", unit_name(rid))
    # How long this model takes to let go; the panel's stopping bar measures
    # the next stop against it.
    write_atomic(stop_seconds_path(rid), f"{time.time() - started:.1f}\n")
  # Give the memory back whole, not as cached weights the next model has to
  # fight the kernel for.
  evict_idle_weights()
  write_status()
  say(f"Stopped {', '.join(targets)}")
  return 0


def cmd_start(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local start")
  parser.add_argument("recipe", nargs="?", help="the model to start (default: the last one started)")
  parser.add_argument("--setup", action="store_true", help="set the recipe up first when it isn't yet")
  args = parser.parse_args(argv)
  if args.setup and args.recipe and ID_RE.match(args.recipe) and not load_model(args.recipe):
    return cmd_use([args.recipe])
  # Admission is serialized with use and remove: two starts checking the same
  # free memory at once would both pass and together overcommit it.
  with Lock():
    return _start(args)


def _start(args):
  manifest = resolve_model(args.recipe)
  rid = manifest["recipe_id"]
  if unit_active(rid):
    say(f"{rid} is already running at {endpoint(rid)}")
    return 0
  gpu = choose_gpu(machine_profile(), manifest["gpu"])
  # Shown as loading from the click on; the memory checks below take seconds.
  clear_error(rid)
  started = time.time()
  write_status({rid: "activating"})
  evict_idle_weights(keep=[rid])
  try:
    check_headroom(manifest["variant"], gpu)
  except LocalError as error:
    record_error(rid, error.short)
    write_status()
    raise
  systemctl("reset-failed", unit_name(rid))
  result = systemctl("start", unit_name(rid))
  write_atomic(os.path.join(state_dir(), "last"), rid + "\n")
  if result.returncode != 0:
    record_error(rid, "Didn't start: omarchy agent local status shows why")
  else:
    # Timed from the same moment the panel's bar starts from, the click.
    write_atomic(load_seconds_path(rid), f"{time.time() - started:.1f}\n")
  write_status()
  if result.returncode != 0:
    raise LocalError(f"{rid} didn't start: {result.stderr.strip()}\n{journal_tail(rid)}")
  say(f"Started {rid} at {endpoint(rid)}")
  return 0


def cmd_autostart(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local autostart")
  parser.add_argument("mode", choices=("on", "off"))
  parser.add_argument("recipe", nargs="?", help="the model (default: the last one started)")
  args = parser.parse_args(argv)
  with Lock():
    manifest = resolve_model(args.recipe)
    rid = manifest["recipe_id"]
    flag = autostart_flag(rid)
    if args.mode == "on":
      write_atomic(flag, "on\n")
    elif os.path.exists(flag):
      os.unlink(flag)
    gpu = choose_gpu(machine_profile(), manifest["gpu"])
    text = render_container(rid, manifest["recipe"], manifest["runtime"], manifest["variant"], manifest["roles"], gpu, args.mode == "on", manifest.get("fileset"))
    write_unit_files(rid, text)
    write_status()
  say(f"Autostart {args.mode}: {rid} {'starts' if args.mode == 'on' else 'no longer starts'} with your session")
  return 0


def cmd_remove(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local remove")
  parser.add_argument("recipe")
  args = parser.parse_args(argv)
  rid = args.recipe
  if not ID_RE.match(rid):
    raise LocalError("Not a recipe id")
  with Lock():
    manifest = load_model(rid)
    running = unit_active(rid)
    size_gib = gib(sum(record.get("size", 0) for record in (manifest or {}).get("files", [])))
    # Shown as removing until it's gone: the marker outlasts the stop below,
    # whose hook would otherwise report the model as merely stopped.
    expected = (expected_stop_seconds(rid) or 10 if running else 0) + size_gib * removal_rate()
    if manifest:
      write_atomic(removing_path(rid), f"{expected:.1f}\n")
      write_status()
    started = time.time()
    try:
      if running:
        say(f"Stopping {rid}")
        systemctl("stop", unit_name(rid))
      deleting = time.time()
      result = _remove_files(rid)
      if size_gib > 1:
        write_atomic(os.path.join(state_dir(), "removal_rate"), f"{(time.time() - deleting) / size_gib:.4f}\n")
    finally:
      for path in (model_manifest_path(rid), removing_path(rid)):
        if os.path.exists(path):
          os.unlink(path)
  refresh_list_cache()
  write_status()
  removed_runs, freed, images = result
  say(f"Removed {rid} in {time.time() - started:.0f}s: {removed_runs} run manifest(s), {gib(freed):.1f} GiB of weights no other recipe uses" + (f", {len(images)} image(s)" if images else ""))
  return 0


def removing_path(rid):
  return os.path.join(state_dir(), "removing", rid)


def removal_rate():
  """Seconds per GiB the last removal took, deleting weights and image."""
  try:
    return float(_read(os.path.join(state_dir(), "removal_rate")))
  except ValueError:
    return 0.1


def _remove_files(rid):
  write_unit_files(rid, None)
  for path in (autostart_flag(rid), error_path(rid), stop_seconds_path(rid), load_seconds_path(rid)):
    if os.path.exists(path):
      os.unlink(path)
  if _read(os.path.join(state_dir(), "last")) == rid:
    os.unlink(os.path.join(state_dir(), "last"))
  ports = load_ports()
  if ports.pop(rid, None) is not None:
    write_atomic(ports_path(), json.dumps(ports, indent=2, sort_keys=True) + "\n")
  removed_runs = 0
  removed_images = set()
  for name in os.listdir(runs_dir()) if os.path.isdir(runs_dir()) else []:
    if run_recipe_id(name) == rid:
      path = os.path.join(runs_dir(), name)
      try:
        with open(path) as handle:
          removed_images.add(json.load(handle)["image"])
      except (OSError, ValueError, KeyError):
        pass
      os.unlink(path)
      removed_runs += 1
  shutil.rmtree(os.path.join(data_dir(), "models", rid), ignore_errors=True)
  freed = 0
  for directory, _, names in os.walk(os.path.join(data_dir(), "blobs")):
    for name in names:
      path = os.path.join(directory, name)
      if os.stat(path).st_nlink == 1:
        freed += os.path.getsize(path)
        os.unlink(path)
  kept_images = set()
  for name in os.listdir(runs_dir()) if os.path.isdir(runs_dir()) else []:
    try:
      with open(os.path.join(runs_dir(), name)) as handle:
        kept_images.add(json.load(handle)["image"])
    except (OSError, ValueError, KeyError):
      pass
  images = []
  for image in sorted(removed_images - kept_images):
    if subprocess.run(["podman", "rmi", image], capture_output=True).returncode == 0:
      images.append(image)
  return removed_runs, freed, images


def cmd_profile(argv):
  argparse.ArgumentParser(prog="omarchy agent local profile").parse_args(argv)
  profile = machine_profile()
  write_profile_cache(profile)
  print(json.dumps(profile, indent=2))
  return 0


def cmd_refresh(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local refresh")
  parser.add_argument("--quiet", action="store_true")
  args = parser.parse_args(argv)
  catalog, note = refresh_catalog(force=True)
  refresh_list_cache()
  write_status()
  if not args.quiet:
    say(f"Catalog {catalog.commit[:12]} from {catalog.source}" + (f" ({note})" if note else ""))
  return 0


def cmd_validate(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local validate")
  parser.add_argument("catalog_dir")
  parser.add_argument("--online", action="store_true", help="also check every Hugging Face file and recipe license")
  args = parser.parse_args(argv)
  catalog = load_catalog_dir(args.catalog_dir)
  errors = catalog.errors()
  if args.online and not errors:
    cache = {}
    for rid, recipe in catalog.recipes.items():
      try:
        build_artifacts(recipe, cache)
      except LocalError as error:
        errors.append(f"recipes/{rid}: {error}")
      for artifact in recipe["artifacts"]:
        info = http_json(f"https://huggingface.co/api/models/{artifact['repo']}/revision/{artifact['revision']}")
        declared = (info.get("cardData") or {}).get("license")
        if declared and not artifact["license"].startswith(str(declared)):
          errors.append(f"recipes/{rid}: {artifact['repo']} declares license '{declared}', recipe says '{artifact['license']}'")
  for error in errors:
    print(error)
  if errors:
    return 1
  say(f"Catalog valid: {len(catalog.recipes)} recipe(s), {len(catalog.runtimes)} runtime(s)")
  return 0


OVERLAY_PROVIDER = "llamacpp"


def pi_overlay(rid=None):
  """A pi extension registering a running model, loaded only by local launches."""
  manifest = resolve_model(rid, running_only=True)
  rid = manifest["recipe_id"]
  provider = {
    "name": "Omarchy local model",
    "baseUrl": endpoint(rid),
    "apiKey": "!cat -- " + shlex.quote(key_path()),
    "api": "openai-completions",
    "models": [{
      "type": "chat",
      "id": rid,
      "name": manifest["recipe"].get("name", rid),
      "reasoning": True,
      "input": ["text"],
      "cost": {"input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0},
      "contextWindow": manifest["variant"]["ctx"],
      "maxTokens": 16384,
    }],
  }
  source = (
    "// Generated by omarchy-agent-local-overlay for `omarchy agent --local`; rewritten on every launch.\n"
    "export default function (pi) {\n"
    f"  pi.registerProvider({json.dumps(OVERLAY_PROVIDER)}, {json.dumps(provider, indent=2)});\n"
    "}\n"
  )
  # One file per recipe: launches of two models close together must not
  # swap each other's overlay before their agents read it.
  path = os.path.join(config_dir(), "overlays", f"pi-{rid}.ts")
  write_atomic(path, source)
  return path, OVERLAY_PROVIDER, rid


def opencode_overlay(rid=None):
  manifest = resolve_model(rid, running_only=True)
  rid = manifest["recipe_id"]
  overlay = {
    "$schema": "https://opencode.ai/config.json",
    "provider": {
      OVERLAY_PROVIDER: {
        "npm": "@ai-sdk/openai-compatible",
        "name": "Omarchy local model",
        "options": {"baseURL": endpoint(rid), "apiKey": "{file:" + key_path() + "}"},
        "models": {rid: {"name": manifest["recipe"].get("name", rid), "limit": {"context": manifest["variant"]["ctx"], "output": 16384}}},
      }
    },
  }
  path = os.path.join(config_dir(), "overlays", f"opencode-{rid}.json")
  write_atomic(path, json.dumps(overlay, indent=2) + "\n")
  return path, OVERLAY_PROVIDER, rid


def cmd_overlay(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local overlay")
  parser.add_argument("agent", choices=("opencode", "pi"))
  parser.add_argument("recipe", nargs="?", help="the running model (default: the last one started)")
  args = parser.parse_args(argv)
  for line in (pi_overlay if args.agent == "pi" else opencode_overlay)(args.recipe):
    print(line)
  return 0


BENCH_SHORT = "Write a bash function that prints the 20 largest files under a directory, human-readable sizes, handling spaces in names. Just the code."
BENCH_LONG_QUESTION = "Above are shell scripts from a Linux desktop project. Pick the one with the most fragile error handling, name it, and rewrite its worst function to be robust. Show the code."


def bench_request(prompt, model, key, max_tokens=512):
  body = {
    "model": model,
    "messages": [{"role": "user", "content": prompt}],
    "max_tokens": max_tokens,
    "temperature": 0,
    "stream": True,
    "stream_options": {"include_usage": True},
    "chat_template_kwargs": {"enable_thinking": False},
  }
  request = urllib.request.Request(
    f"{endpoint(model)}/chat/completions",
    data=json.dumps(body).encode(),
    headers={"Content-Type": "application/json", "Authorization": f"Bearer {key}"},
  )
  start = time.monotonic()
  first = None
  usage = None
  chunks = 0
  with urllib.request.urlopen(request, timeout=1800) as response:
    for raw in response:
      line = raw.decode(errors="replace").strip()
      if not line.startswith("data:") or line[5:].strip() == "[DONE]":
        continue
      event = json.loads(line[5:])
      usage = event.get("usage") or usage
      for choice in event.get("choices", []):
        delta = choice.get("delta", {})
        if delta.get("content") or delta.get("reasoning_content"):
          first = first or time.monotonic()
          chunks += 1
  end = time.monotonic()
  prompt_tokens = (usage or {}).get("prompt_tokens")
  completion = (usage or {}).get("completion_tokens", chunks)
  ttft = (first or end) - start
  decode = end - (first or end)
  return {
    "prompt_tokens": prompt_tokens,
    "completion_tokens": completion,
    "ttft_s": round(ttft, 2),
    "prefill_tok_s": round(prompt_tokens / ttft, 1) if prompt_tokens and ttft else None,
    "decode_tok_s": round((completion - 1) / decode, 1) if decode > 0 and completion > 1 else None,
    "total_s": round(end - start, 2),
  }


def cmd_bench(argv):
  parser = argparse.ArgumentParser(prog="omarchy agent local bench")
  parser.add_argument("recipe", nargs="?", help="the running model (default: the last one started)")
  parser.add_argument("--output", help="write the measurement record here (default: print it)")
  args = parser.parse_args(argv)
  active = resolve_model(args.recipe, running_only=True)
  catalog = cached_catalog()
  corpus = os.path.join(catalog.root, "bench", "context.txt") if catalog else ""
  if not os.path.isfile(corpus):
    raise LocalError("The catalog has no bench/context.txt prompt corpus")
  with open(corpus, encoding="utf-8") as handle:
    context = handle.read()
  with open(key_path()) as handle:
    key = handle.read().strip()
  rid = active["recipe_id"]
  gpu = choose_gpu(machine_profile(), active["gpu"])
  low_ram = [free_memory(gpu)[0]]
  stop = threading.Event()

  def sample():
    while not stop.is_set():
      low_ram.append(free_memory(gpu)[0])
      stop.wait(0.5)

  sampler = threading.Thread(target=sample, daemon=True)
  sampler.start()
  say(f"Benchmarking {rid}: short prompt, then a ~32K-token prompt (greedy, thinking off, 512 tokens out)")
  bench_request("Say ok.", rid, key, max_tokens=8)
  short = bench_request(BENCH_SHORT, rid, key)
  say(f"  short: decode {short['decode_tok_s']} tok/s, first token {short['ttft_s']}s")
  long = bench_request(context + "\n\n" + BENCH_LONG_QUESTION, rid, key)
  say(f"  long ({long['prompt_tokens']} tokens): first token {long['ttft_s']}s, prefill {long['prefill_tok_s']} tok/s, decode {long['decode_tok_s']} tok/s")
  stop.set()
  sampler.join()
  mem = meminfo()
  record = {
    "recipe": rid,
    "measured_at": time.strftime("%Y-%m-%d"),
    "catalog_commit": active["catalog"]["commit"],
    "image": active["image"],
    "ctx": active["variant"]["ctx"],
    "machine": {
      "platform": active["profile"]["platform"],
      "gpu": active["gpu"],
      "ram_class": active["profile"]["ram_class"],
      "kernel": os.uname().release,
      "cpu": next((line.split(":", 1)[1].strip() for line in _read("/proc/cpuinfo").splitlines() if line.startswith("model name")), ""),
    },
    "memory": {
      "observed_at_load_gib": (active.get("observed") or {}).get("ram_used_gib"),
      "min_available_during_bench_gib": round(min(low_ram), 1),
      "total_gib": round(gib(mem.get("MemTotal", 0)), 1),
    },
    "load_seconds": (active.get("observed") or {}).get("load_seconds"),
    "artifacts": [{"repo": f["repo"], "revision": f["revision"], "path": f["path"], key_name: f[key_name]} for f in active["files"] for key_name in (("sha256",) if "sha256" in f else ("git_oid",))],
    "short": short,
    "long": long,
    "method": "omarchy agent local bench: 1 warmup, then short and ~32K-token prompts from the catalog's bench/context.txt, temperature 0, enable_thinking false, 512 tokens out, streamed",
  }
  text = toml_dumps(record)
  if args.output:
    write_atomic(args.output, text)
    say(f"Wrote {args.output}")
  else:
    print(text)
  return 0


COMMANDS = {
  "use": cmd_use,
  "list": cmd_list,
  "status": cmd_status,
  "stop": cmd_stop,
  "start": cmd_start,
  "autostart": cmd_autostart,
  "remove": cmd_remove,
  "profile": cmd_profile,
  "refresh": cmd_refresh,
  "validate": cmd_validate,
  "overlay": cmd_overlay,
  "bench": cmd_bench,
}


def main(command, argv):
  try:
    return COMMANDS[command](argv)
  except LocalError as error:
    print(f"Error: {error}", file=sys.stderr)
    return 1
  except KeyboardInterrupt:
    return 130
