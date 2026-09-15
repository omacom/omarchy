"""Validated live keyboard configuration with owned-file and runtime rollback.

No input-event capture, locale changes, or edits to user-authored Lua.
"""
from contextlib import contextmanager
from pathlib import Path
import base64
import copy
import fcntl
import hashlib
import json
import os
import re
import secrets
import selectors
import stat
import subprocess
import tempfile
import time

from .catalog import Catalog, SettingsError
from .deferred import (LOADER, PROMOTER,
           parse as parse_deferred, render as render_deferred,
           saved_session)
from .deferred_runtime import MAX_DATA_BYTES, UnsafeState, read_path
from .devices import metadata, resolve, pick, active_index
from .keymap import validate

FIELDS = ("rules", "model", "layout", "variant", "options")
OWNED = ("layout", "variant", "options")
SINGLE_LAYOUT_COMPATIBILITY = "duplicated-single-layout"
MAX_PROFILE_BYTES = 256 * 1024
MAX_ACTIVITY_BYTES = 64 * 1024
MAX_TRANSACTION_BYTES = 1024 * 1024
MAX_RUNTIME_STDOUT = 256 * 1024
MAX_RUNTIME_STDERR = 64 * 1024


def encoded(data):
  return json.dumps(data, sort_keys=True, ensure_ascii=False, separators=(",", ":")).encode()


def digest(data):
  return hashlib.sha256(encoded(data)).hexdigest()


def lua_string(value):
  # Fixed-width decimal escapes cannot terminate the string or absorb digits.
  return '"' + ''.join(chr(b) if 32 <= b < 127 and b not in (34, 92)
            else "\\%03d" % b for b in value.encode("utf-8")) + '"'


def config_of(device):
  return {key: device.get(key, "") for key in FIELDS}


def layout_pairs(config):
  layouts = config.get("layout", "").split(",")
  raw = config.get("variant", "")
  variants = raw.split(",") if raw else [""] * len(layouts)
  if len(variants) == 1 and len(layouts) > 1:
    variants *= len(layouts)
  if len(variants) != len(layouts):
    return None
  return list(zip(layouts, variants))


def equivalent(a, b):
  # Hyprland normalizes an all-empty variant list to an empty string.
  return (layout_pairs(a) == layout_pairs(b)
      and a.get("options", "") == b.get("options", ""))


def atomic(path, content):
  path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
  fd, temp = tempfile.mkstemp(prefix=".keyboard-", dir=path.parent)
  try:
    with os.fdopen(fd, "wb") as stream:
      stream.write(content)
      stream.flush()
      os.fsync(stream.fileno())
    os.replace(temp, path)
    directory = os.open(path.parent, os.O_DIRECTORY)
    try:
      os.fsync(directory)
    finally:
      os.close(directory)
  finally:
    if os.path.exists(temp):
      os.unlink(temp)


def path_present(path):
  """Treat dangling links as occupied paths, never as an absent owned file."""
  path = Path(path)
  return path.exists() or path.is_symlink()


class Paths:
  def __init__(self, config=None, state=None, cache=None, lock_timeout=5, omarchy=None):
    home = Path.home()
    self.config = Path(config or os.environ.get("XDG_CONFIG_HOME") or home / ".config")
    self.state = Path(state or os.environ.get("XDG_STATE_HOME") or home / ".local/state")
    if cache is None and state is not None:
      cache = Path(state).parent / "cache"
    self.cache = Path(cache or os.environ.get("XDG_CACHE_HOME") or home / ".cache")
    self.lock_timeout = lock_timeout
    self.root = self.state / "omarchy/keyboard-layouts"
    self.profile = self.root / "settings.json"
    self.activity = self.root / "activity.json"
    self.transaction = self.root / "transaction.json"
    self.omarchy = Path(omarchy or os.environ["OMARCHY_PATH"])
    self.override = self.omarchy / "default/hypr/keyboard-layouts.lua"
    self.legacy_loader = self.state / "omarchy/toggles/hypr/madmatt-keyboard-settings.lua"
    self.active = self.root / "active-v1.conf"
    self.pending = self.root / "pending-v1.conf"
    self.promoter = self.omarchy / "shell/plugins/bar/widgets/keyboard/backend/deferred_runtime.py"
    self.lock_file = self.root / "lock"
    self.main = self.config / "hypr/hyprland.lua"

  def limit(self, path):
    limits = {
      self.profile: MAX_PROFILE_BYTES,
      self.activity: MAX_ACTIVITY_BYTES,
      self.transaction: MAX_TRANSACTION_BYTES,
      self.active: MAX_DATA_BYTES,
      self.pending: MAX_DATA_BYTES,
      self.override: len(LOADER),
      self.promoter: len(PROMOTER),
    }
    return limits.get(Path(path), MAX_TRANSACTION_BYTES)

  def owned_blob(self, path, missing_ok=True):
    try:
      limit = self.limit(path)
      if Path(path) in (self.override, self.promoter):
        try:
          fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK | os.O_CLOEXEC)
        except FileNotFoundError:
          if missing_ok:
            return None
          raise
        with os.fdopen(fd, "rb") as stream:
          if not stat.S_ISREG(os.fstat(stream.fileno()).st_mode):
            raise UnsafeState("packaged keyboard source is not a regular file")
          data = stream.read(limit + 1)
        if len(data) > limit:
          raise UnsafeState("packaged keyboard source exceeds its bound")
      else:
        data = read_path(path, limit, missing_ok=missing_ok)
      exact_lengths = {
        self.override: {len(LOADER)},
        self.promoter: {len(PROMOTER)},
      }
      allowed = exact_lengths.get(Path(path))
      if (data is not None and allowed is not None
          and len(data) not in allowed):
        raise UnsafeState("fixed runtime source has an unexpected length")
      return data
    except (OSError, UnsafeState, ValueError) as exc:
      raise SettingsError(f"Cannot read {Path(path).name}. Recover the saved settings before editing.") from exc

  @contextmanager
  def lock(self):
    self.root.mkdir(parents=True, exist_ok=True, mode=0o700)
    info = self.root.lstat()
    if (not stat.S_ISDIR(info.st_mode) or info.st_uid != os.geteuid()
        or self.root.is_symlink()):
      raise SettingsError("The keyboard settings directory needs manual review.")
    if stat.S_IMODE(info.st_mode) & 0o077:
      self.root.chmod(0o700)
    try:
      fd = os.open(self.lock_file, os.O_RDWR | os.O_CREAT | os.O_CLOEXEC
            | os.O_NOFOLLOW | os.O_NONBLOCK, 0o600)
    except OSError as exc:
      raise SettingsError("The keyboard settings lock needs manual review.") from exc
    try:
      lock_info = os.fstat(fd)
      if (not stat.S_ISREG(lock_info.st_mode) or lock_info.st_uid != os.geteuid()
          or lock_info.st_nlink != 1):
        raise SettingsError("The keyboard settings lock needs manual review.")
      os.fchmod(fd, 0o600)
      deadline = time.monotonic() + self.lock_timeout
      while True:
        try:
          fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
          break
        except BlockingIOError:
          if time.monotonic() >= deadline:
            raise SettingsError("Another keyboard settings action is still running. Try again.")
          time.sleep(0.02)
      yield
    finally:
      os.close(fd)

  def sources(self):
    files = list((self.config / "hypr").rglob("*.lua"))
    files += list((self.state / "omarchy/toggles/hypr").glob("*.lua"))
    files += [self.omarchy / "default/hypr/toggles.lua"]
    return {str(p): hashlib.sha256(p.read_bytes()).hexdigest()
        for p in sorted(set(files)) if p != self.override and p.is_file()}

  def read(self, path, fallback):
    data = self.owned_blob(path)
    if data is None:
      return copy.deepcopy(fallback)
    try:
      return json.loads(data)
    except (ValueError, UnicodeError) as exc:
      raise SettingsError(f"Cannot read {path.name}. Recover the saved settings before editing.") from exc

  def check_loader(self):
    try:
      text = self.main.read_text()
    except OSError as exc:
      raise SettingsError("The Omarchy Lua configuration could not be found.") from exc
    lines = "\n".join(line for line in text.splitlines() if not line.lstrip().startswith("--"))
    if not re.search(r'require\s*\(\s*[\'\"]default\.hypr\.toggles[\'\"]\s*\)', lines):
      raise SettingsError("This configuration does not load Omarchy’s saved toggles. No files were changed.")
    for filename in self.sources():
      content = Path(filename).read_text()
      if any("kb_file" in line for line in content.splitlines() if not line.lstrip().startswith("--")):
        raise SettingsError("A custom keymap file needs manual review. The picker will not replace it.")
    if path_present(self.legacy_loader):
      raise SettingsError("Remove the community Keyboard Layouts plugin using its cleanup command before editing built-in keyboard settings.")
    override = self.owned_blob(self.override) or b""
    if override != LOADER or self.owned_blob(self.promoter) != PROMOTER:
      raise SettingsError("The installed keyboard settings runtime is incomplete. Update Omarchy before saving.")
    toggles = self.omarchy / "default/hypr/toggles.lua"
    lines = "\n".join(line for line in toggles.read_text().splitlines()
                      if not line.lstrip().startswith("--"))
    if not re.search(r'require\s*\(\s*[\'\"]default\.hypr\.keyboard-layouts[\'\"]\s*\)', lines):
      raise SettingsError("Omarchy does not load saved keyboard layouts. Update Omarchy before saving.")
    for path in (self.active, self.pending):
      try:
        data = self.owned_blob(path)
        if data is not None:
          parse_deferred(data)
      except (OSError, ValueError, SettingsError) as exc:
        raise SettingsError(f"Cannot read {path.name}. Recover the saved settings before editing.") from exc



class Hyprland:
  @staticmethod
  def _bounded(command, timeout=8):
    try:
      process = subprocess.Popen(command, stdin=subprocess.DEVNULL,
                   stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                   close_fds=True)
    except OSError as exc:
      raise SettingsError("The desktop did not respond. Your saved settings were not changed.") from exc
    selector = selectors.DefaultSelector()
    output = {process.stdout: bytearray(), process.stderr: bytearray()}
    limits = {process.stdout: MAX_RUNTIME_STDOUT, process.stderr: MAX_RUNTIME_STDERR}
    deadline = time.monotonic() + timeout
    try:
      for stream in output:
        os.set_blocking(stream.fileno(), False)
        selector.register(stream, selectors.EVENT_READ)
      while selector.get_map():
        remaining = deadline - time.monotonic()
        if remaining <= 0:
          raise TimeoutError
        events = selector.select(remaining)
        if not events:
          raise TimeoutError
        for key, _ in events:
          chunk = os.read(key.fileobj.fileno(), 65536)
          if not chunk:
            selector.unregister(key.fileobj)
            continue
          output[key.fileobj].extend(chunk)
          if len(output[key.fileobj]) > limits[key.fileobj]:
            raise OverflowError
      remaining = deadline - time.monotonic()
      if remaining <= 0:
        raise TimeoutError
      returncode = process.wait(timeout=remaining)
    except (TimeoutError, OverflowError, subprocess.TimeoutExpired) as exc:
      try:
        process.terminate()
      except ProcessLookupError:
        pass
      try:
        process.wait(timeout=1)
      except subprocess.TimeoutExpired:
        process.kill()
        process.wait()
      raise SettingsError("The desktop did not respond. Your saved settings were not changed.") from exc
    finally:
      selector.close()
      process.stdout.close()
      process.stderr.close()
    return subprocess.CompletedProcess(command, returncode, bytes(output[process.stdout]),
                     bytes(output[process.stderr]))

  def call(self, *args, json_output=False):
    result = self._bounded(["/usr/bin/hyprctl", *(["-j"] if json_output else []), *args])
    if result.returncode:
      raise SettingsError("The desktop rejected the keyboard request.")
    try:
      stdout = result.stdout.decode("utf-8")
    except UnicodeError as exc:
      raise SettingsError("The desktop returned an unreadable keyboard response.") from exc
    if json_output:
      try:
        return json.loads(stdout)
      except ValueError as exc:
        raise SettingsError("The desktop returned an unreadable keyboard response.") from exc
    text = stdout.strip()
    if args and args[0] in ("switchxkblayout", "reload") and text.lower() not in ("ok", "ok.", ""):
      raise SettingsError("The desktop could not apply the keyboard request.")
    return text

  def devices(self):
    return self.call("devices", json_output=True)

  def check(self):
    if self.call("configerrors"):
      raise SettingsError("Resolve the existing desktop configuration error before changing keyboards.")
    value = self.call("getoption", "input.kb_file", json_output=True).get("str", "")
    if value not in ("", "[[EMPTY]]"):
      raise SettingsError("This desktop uses a custom keymap file. It will not be overwritten.")

  def switch(self, name, index):
    self.call("switchxkblayout", name, str(index))

  def reload(self):
    self.call("reload")
    if self.call("configerrors"):
      raise SettingsError("The desktop reported a configuration error. Restoring the previous setup.")

  def animations(self):
    return self.call("getoption", "animations.enabled", json_output=True).get("int", 1) != 0


class Session:
  def __init__(self, paths=None, hypr=None, records=None):
    self.paths = paths or Paths()
    self.hypr = hypr or Hyprland()
    self.records = records
    self.catalog = Catalog(cache=self.paths.cache / "omarchy/keyboard-layouts/catalog-v1.json")

  def single_layout_compatibility(self, group, saved):
    """Recognize only the complete managed logical-one/physical-two state."""
    try:
      loader = self.paths.owned_blob(self.paths.override)
      promoter = self.paths.owned_blob(self.paths.promoter)
    except SettingsError:
      return False
    if not group or loader != LOADER or promoter != PROMOTER:
      return False
    session = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
    if not session:
      return False
    profiles = saved.get("profiles", {})
    if not isinstance(profiles, dict):
      return False
    targets = profiles.get(group["id"], [])
    names = [member["name"] for member in group["members"]]
    if (not isinstance(targets, list) or len(targets) != len(names)
        or any(not isinstance(target, dict) for target in targets)
        or {target.get("name") for target in targets} != set(names)):
      return False
    try:
      active_data = self.paths.owned_blob(self.paths.active, missing_ok=False)
      pending_data = self.paths.owned_blob(self.paths.pending, missing_ok=False)
      if saved_session(active_data) != session or saved_session(pending_data) != session:
        return False
      active = parse_deferred(active_data)
      pending = parse_deferred(pending_data)
    except (OSError, ValueError, SettingsError):
      return False
    active_by_name = {target.get("name"): target for target in active}
    pending_by_name = {target.get("name"): target for target in pending}
    saved_by_name = {target["name"]: target for target in targets}
    if (len(active_by_name) != len(active) or len(pending_by_name) != len(pending)
        or any(name not in active_by_name or name not in pending_by_name for name in names)):
      return False
    for member in group["members"]:
      target = saved_by_name[member["name"]]
      logical = layout_pairs(target)
      physical = layout_pairs(member)
      if (not logical or len(logical) != 1 or physical != logical * 2
          or not equivalent(member, active_by_name[member["name"]])
          or not equivalent(target, pending_by_name[member["name"]])):
        return False
    return True

  def snapshot(self, event_device=""):
    devices = self.hypr.devices()
    records = self.records if self.records is not None else metadata()
    groups, _ = resolve(devices, records)
    saved = self.paths.read(self.paths.profile, {"profiles": {}})
    if not isinstance(saved, dict):
      raise SettingsError("Cannot read settings.json. Recover the saved settings before editing.")
    group = pick(groups, saved.get("preferred"))
    revision = digest({"groups": groups_without_active(groups), "sources": self.paths.sources(),
             "saved": saved, "loader": self.file_blob(self.paths.override),
             "promoter": self.file_blob(self.paths.promoter),
             "active": self.file_blob(self.paths.active),
             "pending": self.file_blob(self.paths.pending)})
    consistent = bool(group) and all(config_of(m) == config_of(group["members"][0]) for m in group["members"])
    physical_rows = self.catalog.current_rows(group["members"][0]) if group else []
    compatibility = consistent and self.single_layout_compatibility(group, saved)
    rows = physical_rows[:1] if compatibility else physical_rows
    activity = self.layout_activity(group, event_device) if consistent else {}
    active = active_index(group, activity.get("source", "")) if consistent else -1
    physical_indices = {member.get("active_layout_index", -1) for member in group["members"]} if group else set()
    if compatibility:
      active = (0 if physical_indices
           and all(0 <= index < len(physical_rows) for index in physical_indices)
           else -1)
    if not 0 <= active < len(rows):
      active = -1
    problem = "" if consistent else ("Choose the keyboard you type on." if not group else
                    "This keyboard’s interfaces have different settings. They need manual review.")
    if consistent and active < 0:
      problem = "The typing interfaces report different or unknown layouts. Select a layout above to synchronize them."
    if rows and any(r.get("custom") for r in rows):
      problem = "This keyboard uses a custom layout. It can be switched, but will not be overwritten."
    return {"groups": groups, "group": group, "saved": saved, "revision": revision,
        "rows": rows, "active": active, "consistent": consistent, "problem": problem,
        "activity": activity, "physicalRows": physical_rows,
        "compatibilityMode": SINGLE_LAYOUT_COMPATIBILITY if compatibility else ""}

  def layout_activity(self, group, event_device):
    # Cache the verified interface, never a layout index. Read its current
    # layout from Hyprland every time. Session, addresses, membership and
    # keymap configuration must still match before old evidence is reused.
    session = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
    scope = digest({"session": session, "group": groups_without_active([group])})
    try:
      raw = self.paths.owned_blob(self.paths.activity)
      previous = json.loads(raw) if raw is not None else {}
    except (SettingsError, ValueError, UnicodeError):
      previous = {}
    if not isinstance(previous, dict) or not session or previous.get("scope") != scope:
      previous = {}
    indices = {d["name"]: d.get("active_layout_index", -1) for d in group["members"]}
    source = previous.get("source", "")
    if event_device in indices:
      source = event_device
    elif isinstance(previous.get("indices"), dict):
      # Recover a switch missed during a shell reload. If several
      # interfaces changed, their ordering is unknown: do not guess.
      changed = [name for name, index in indices.items() if previous["indices"].get(name) != index]
      if changed:
        source = changed[0] if len(changed) == 1 else ""
    if not isinstance(source, str) or source not in indices:
      source = ""
    return {"scope": scope, "source": source, "indices": indices}

  def configured(self, snap):
    group = snap["group"]
    if not group:
      return snap["rows"], "custom", False
    current_shortcut = self.catalog.shortcut(group["members"][0].get("options", ""))
    targets = snap["saved"].get("profiles", {}).get(group["id"], [])
    by_name = {target.get("name"): target for target in targets if isinstance(target, dict)}
    if not all(member["name"] in by_name for member in group["members"]):
      return snap["rows"], current_shortcut, False
    first = by_name[group["members"][0]["name"]]
    candidate = {**config_of(group["members"][0]), **{key: first.get(key, "") for key in OWNED}}
    rows = self.catalog.current_rows(candidate)
    pending = False if snap["compatibilityMode"] else any(
      not equivalent(member, {**config_of(member), **{
        key: by_name[member["name"]].get(key, "") for key in OWNED}})
      for member in group["members"])
    return rows, self.catalog.shortcut(candidate.get("options", "")), pending

  def status(self, event_device=""):
    with self.paths.lock():
      snap = self.snapshot(event_device)
      activity = encoded(snap["activity"])
      if self.paths.owned_blob(self.paths.activity) != activity:
        atomic(self.paths.activity, activity)
    group = snap["group"]
    configured, configured_shortcut, pending = self.configured(snap)
    active_indices = {d.get("active_layout_index", -1) for d in group["members"]} if snap["consistent"] else set()
    if snap["compatibilityMode"]:
      active_indices = {0} if snap["active"] == 0 else set()
    return {"revision": snap["revision"], "devices": [{k: g[k] for k in ("id", "label", "certain")} for g in snap["groups"]],
        "device": group["id"] if group else "", "deviceLabel": group["label"] if group else "",
        "deviceNames": group["names"] if group else [],
        "layouts": snap["rows"], "active": snap["active"], "problem": snap["problem"],
        "activeLayouts": [row for i, row in enumerate(snap["rows"]) if i in active_indices],
        "shortcut": self.catalog.shortcut(group["members"][0].get("options", "")) if group else "custom",
        "configuredLayouts": configured, "configuredShortcut": configured_shortcut,
        "pendingRestart": pending, "physicalLayouts": snap["physicalRows"],
        "compatibilityMode": snap["compatibilityMode"]}

  def require_current(self, revision, writable=True, event_device=""):
    snap = self.snapshot(event_device)
    if snap["revision"] != revision:
      raise SettingsError("The keyboard setup changed. Review the refreshed list and try again.")
    if not snap["group"] or not snap["consistent"] or (writable and snap["problem"]):
      raise SettingsError(snap["problem"] or "Choose a typing keyboard first.")
    return snap

  def choose(self, identity, revision):
    with self.paths.lock():
      snap = self.snapshot()
      if snap["revision"] != revision:
        raise SettingsError("The connected keyboards changed. Choose again.")
      if not any(g["id"] == identity and g["certain"] for g in snap["groups"]):
        raise SettingsError("This interface cannot be identified safely as a physical typing keyboard.")
      saved = snap["saved"]
      saved["preferred"] = identity
      atomic(self.paths.profile, encoded(saved))

  def switch(self, index, revision):
    with self.paths.lock():
      snap = self.require_current(revision, writable=False)
      if type(index) is not int or not 0 <= index < len(snap["rows"]):
        raise SettingsError("That layout is no longer available.")
      self._switch_members(snap["group"]["members"], index)

  def _switch_members(self, members, index):
    changed = []
    try:
      for device in members:
        changed.append(device)
        self.hypr.switch(device["name"], index)
      current = self.hypr.devices().get("keyboards", [])
      for device in changed:
        actual = next((d for d in current if d.get("address") == device.get("address")
               and d.get("name") == device["name"]), None)
        if not actual or actual.get("active_layout_index") != index:
          raise SettingsError("The typing keyboard did not confirm the layout change.")
    except Exception:
      current = self.hypr.devices().get("keyboards", [])
      for device in changed:
        if any(d.get("name") == device["name"] and d.get("address") == device.get("address")
           for d in current):
          self.hypr.switch(device["name"], device.get("active_layout_index", 0))
      raise

  def _runtime_matches(self, expected):
    if not isinstance(expected, list):
      return False
    current = self.hypr.devices().get("keyboards", [])
    for wanted in expected:
      if not isinstance(wanted, dict):
        return False
      actual = next((device for device in current
             if device.get("name") == wanted.get("name")
             and device.get("address") == wanted.get("address")), None)
      if (not actual or not equivalent(actual, wanted)
          or actual.get("active_layout_index") != wanted.get("active_layout_index")):
        return False
    return True

  def _restore_runtime(self, expected):
    current = self.hypr.devices().get("keyboards", [])
    for wanted in expected:
      if any(device.get("name") == wanted.get("name")
         and device.get("address") == wanted.get("address") for device in current):
        self.hypr.switch(wanted["name"], wanted["active_layout_index"])
    if not self._runtime_matches(expected):
      raise SettingsError("The previous keyboard setup could not be confirmed.")

  def save(self, pairs, shortcut, revision, event_device="", expected_active_id=None):
    """Apply a validated layout set now, with durable file and runtime rollback."""
    with self.paths.lock():
      if path_present(self.paths.transaction):
        raise SettingsError("A previous file update needs recovery before editing again.")
      snap = self.require_current(revision, event_device=event_device)
      if expected_active_id is not None:
        active_id = snap["rows"][snap["active"]]["id"]
        if not isinstance(expected_active_id, str) or active_id != expected_active_id:
          raise SettingsError("The active layout changed. Review the refreshed list and try again.")
      rows = self.catalog.resolve(pairs)
      self.paths.check_loader()
      self.hypr.check()
      session = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
      use_compatibility = len(rows) == 1 and len(snap["physicalRows"]) > 1
      if use_compatibility and not session:
        raise SettingsError("The desktop session could not be identified. No keyboard settings were changed.")
      targets = []
      live_targets = []
      for device in snap["group"]["members"]:
        proposal = config_of(device)
        proposal.update(layout=",".join(row["layout"] for row in rows),
                variant=",".join(row["variant"] for row in rows),
                options=self.catalog.options(device.get("options", ""), shortcut))
        validate(proposal, self.catalog)
        targets.append({"name": device["name"], **{key: proposal[key] for key in OWNED}})
        if use_compatibility:
          proposal.update(layout=proposal["layout"] + "," + proposal["layout"],
                  variant=proposal["variant"] + "," + proposal["variant"])
          validate(proposal, self.catalog)
        live_targets.append({"name": device["name"], **{key: proposal[key] for key in OWNED}})

      saved = copy.deepcopy(snap["saved"])
      saved["preferred"] = snap["group"]["id"]
      saved.setdefault("profiles", {})[snap["group"]["id"]] = targets
      written_profile = encoded(saved)
      active_saved = copy.deepcopy(saved)
      active_saved["profiles"][snap["group"]["id"]] = live_targets
      written_active = render_deferred(active_saved, session)
      written_pending = render_deferred(saved, session)

      current_ids = [row["id"] for row in snap["rows"]]
      requested_ids = [row["id"] for row in rows]
      active_id = current_ids[snap["active"]]
      if active_id in requested_ids:
        selected_id = active_id
      else:
        selected_id = next((identity for identity in requested_ids if identity in current_ids), "")
        if not selected_id:
          raise SettingsError("Add a new layout before removing every layout available in this session.")
      before_index = current_ids.index(selected_id)
      after_index = requested_ids.index(selected_id)

      previous_runtime = [{"name": device["name"], "address": device.get("address"),
                "active_layout_index": device.get("active_layout_index", 0),
                **{key: device.get(key, "") for key in OWNED}}
                for device in snap["group"]["members"]]
      applied_runtime = [{"name": device["name"], "address": device.get("address"),
                "active_layout_index": after_index,
                **{key: target[key] for key in OWNED}}
               for device, target in zip(snap["group"]["members"], live_targets)]
      transaction = {
        "kind": "live-save", "token": secrets.token_hex(16),
        "profile": self.file_blob(self.paths.profile),
        "active": self.file_blob(self.paths.active),
        "pending": self.file_blob(self.paths.pending),
        "writtenProfile": base64.b64encode(written_profile).decode(),
        "writtenActive": base64.b64encode(written_active).decode(),
        "writtenPending": base64.b64encode(written_pending).decode(),
        "previousRuntime": previous_runtime,
        "appliedRuntime": applied_runtime,
      }
      backup = self.paths.root / "backups" / transaction["token"]
      atomic(backup / "recovery.json", encoded(transaction))
      atomic(self.paths.transaction, encoded(transaction))
      try:
        # Synchronize every interface on a layout that survives before
        # removing the active layout or replacing any live keymap. The
        # UI performs active removal as a separate switch/readback/save
        # sequence; do not emit a duplicate switch immediately before
        # reload when that first operation is already confirmed.
        if any(device.get("active_layout_index") != before_index
           for device in snap["group"]["members"]):
          self._switch_members(snap["group"]["members"], before_index)
        atomic(self.paths.active, written_active)
        atomic(self.paths.pending, written_pending)
        atomic(self.paths.profile, written_profile)
        if (self.paths.owned_blob(self.paths.active, missing_ok=False) != written_active
            or self.paths.owned_blob(self.paths.pending, missing_ok=False) != written_pending
            or self.paths.owned_blob(self.paths.profile, missing_ok=False) != written_profile):
          raise OSError("saved keyboard files failed readback")
        self.hypr.reload()
        self._switch_members(snap["group"]["members"], after_index)
        if not self._runtime_matches(applied_runtime):
          raise SettingsError("The typing keyboard did not confirm the new layout setup.")
        self.paths.transaction.unlink()
      except Exception as exc:
        try:
          self._rollback_live(transaction)
        except Exception as recovery:
          raise SettingsError("The layout edit failed and automatic recovery could not be confirmed. The recovery record was retained.") from recovery
        raise SettingsError("The layout edit could not be applied. The previous setup was restored.") from exc
      return {"restartRequired": False}

  @staticmethod
  def _transaction_files(transaction):
    return (("Profile", "profile"), ("Active", "active"), ("Pending", "pending"))

  def _restore_transaction_files(self, transaction):
    conflicts = []
    for label, attribute in self._transaction_files(transaction):
      path = getattr(self.paths, attribute)
      current = self.file_blob(path)
      written = transaction.get("written" + label)
      previous = transaction.get(attribute)
      if current == written:
        self.restore_blob(path, previous)
      elif current != previous:
        conflicts.append(path.name)
    if conflicts:
      raise SettingsError("Saved keyboard files changed during recovery; they were preserved for manual review.")

  def _rollback_live(self, transaction):
    previous = transaction.get("previousRuntime")
    if not isinstance(previous, list):
      raise SettingsError("The live keyboard recovery record is incomplete.")
    self._restore_transaction_files(transaction)
    self.hypr.reload()
    self._restore_runtime(previous)
    self.paths.transaction.unlink(missing_ok=True)

  def recover_pending(self):
    if not path_present(self.paths.transaction):
      return
    with self.paths.lock():
      if path_present(self.paths.legacy_loader):
        raise SettingsError("Remove the community Keyboard Layouts plugin using its cleanup command before recovering built-in keyboard settings.")
      transaction = self.paths.read(self.paths.transaction, None)
      if not transaction or transaction.get("kind") != "live-save":
        raise SettingsError("The saved keyboard transaction needs manual review.")
      if (all(self.file_blob(getattr(self.paths, attribute)) == transaction.get("written" + label)
          for label, attribute in self._transaction_files(transaction))
          and self._runtime_matches(transaction.get("appliedRuntime"))):
        self.paths.transaction.unlink()
      else:
        self._rollback_live(transaction)

  def file_blob(self, path):
    data = self.paths.owned_blob(path)
    return base64.b64encode(data).decode() if data is not None else None

  @staticmethod
  def restore_blob(path, blob):
    if blob is None:
      path.unlink(missing_ok=True)
    else:
      atomic(path, base64.b64decode(blob))

def groups_without_active(groups):
  return [{"id": g["id"], "certain": g["certain"], "members": [
    {k: d.get(k) for k in ("name", "address", *FIELDS)} for d in g["members"]]} for g in groups]
