"""Local workspace snapshots. No background process; invoked by the bar on demand."""
from __future__ import annotations

import contextlib
import fcntl
import json
import html
import math
import os
from pathlib import Path
import re
import shlex
import shutil
import socket
import subprocess
import struct
import sys
import tempfile
import time
import uuid

HOME = Path.home()
STATE = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state")) / "omarchy/saved-workspaces"
CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", HOME / ".config")) / "omarchy/shell.json"
WIDGET = "omarchy.saved-workspaces"
MODES = {"dwindle", "floating", "scrolling"}
MAX_WINDOWS = 100


class WorkspaceError(Exception):
  pass


def atomic_json(path, value):
  path.parent.mkdir(parents=True, exist_ok=True)
  fd, temporary = tempfile.mkstemp(prefix=".saved-workspaces-", dir=path.parent)
  try:
    with os.fdopen(fd, "w") as stream:
      os.fchmod(stream.fileno(), 0o600)
      json.dump(value, stream, ensure_ascii=False, indent=2, allow_nan=False)
      stream.write("\n")
      stream.flush()
      os.fsync(stream.fileno())
    os.replace(temporary, path)
  finally:
    if os.path.exists(temporary):
      os.unlink(temporary)


def database():
  path = STATE / "workspaces.json"
  if not path.exists():
    return {"version": 1, "items": [], "active": {}}
  if path.stat().st_size > 8 * 1024 * 1024:
    raise WorkspaceError("The scenes file is too large.")
  value = json.loads(path.read_text())
  if value.get("version") != 1 or not isinstance(value.get("items"), list):
    raise WorkspaceError("The scenes file could not be read.")
  return value


def name_value(name):
  name = str(name).strip()
  if not name or len(name) > 80 or any(ord(c) < 32 for c in name):
    raise WorkspaceError("Use a name between 1 and 80 characters.")
  return name


def find_profile(data, identifier):
  result = next((p for p in data["items"] if p["id"] == identifier), None)
  if result is None:
    raise WorkspaceError("That scene no longer exists.")
  return result


def record_opened(data, identifier, workspace, addresses):
  data.setdefault("opened", {})[str(workspace)] = {
    "id": identifier, "session": os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", ""),
    "windows": list(addresses),
  }
  data["active"] = {"id": identifier, "workspace": workspace}


def put_profile(data, snapshot, name=None, identifier=None):
  """Update by immutable id, never silently overwrite a duplicate name."""
  previous = find_profile(data, identifier) if identifier else None
  name = name_value(name if name is not None else previous["name"])
  if any(p["name"].casefold() == name.casefold() and p is not previous for p in data["items"]):
    raise WorkspaceError("That name is already saved. Use Update to replace it.")
  if not previous and len(data["items"]) >= 100:
    raise WorkspaceError("You can save up to 100 scenes.")
  now = int(time.time())
  profile = {**snapshot, "id": previous["id"] if previous else uuid.uuid4().hex,
       "name": name, "created": previous["created"] if previous else now, "updated": now}
  if previous:
    data["items"][data["items"].index(previous)] = profile
  else:
    data["items"].append(profile)
  record_opened(data, profile["id"], profile["workspace"], [w["address"] for w in profile["windows"]])
  return profile


def rename_profile(data, identifier, name):
  profile = find_profile(data, identifier)
  name = name_value(name)
  if any(p["id"] != identifier and p["name"].casefold() == name.casefold() for p in data["items"]):
    raise WorkspaceError("That name is already saved.")
  profile["name"] = name
  profile["updated"] = int(time.time())
  return profile


def run(*argv, timeout=12):
  result = subprocess.run(argv, capture_output=True, text=True, timeout=timeout)
  if result.returncode:
    raise WorkspaceError((result.stderr or result.stdout or "The desktop did not respond.").strip()[:300])
  return result.stdout.strip()


def query(request):
  return json.loads(run("hyprctl", request, "-j"))


def lua_string(value):
  return '"' + "".join('\\' + c if c in '\\"' else ('\\%03d' % ord(c) if ord(c) < 32 else c) for c in str(value)) + '"'


def lua(value):
  if value is None:
    return "nil"
  if isinstance(value, bool):
    return "true" if value else "false"
  if isinstance(value, (int, float)):
    if not math.isfinite(value):
      raise WorkspaceError("Invalid window coordinates.")
    return str(value)
  if isinstance(value, str):
    return lua_string(value)
  if isinstance(value, list):
    return "{" + ",".join(lua(v) for v in value) + "}"
  return "{" + ",".join("[" + lua_string(k) + "]=" + lua(v) for k, v in value.items()) + "}"


def execute(code):
  result = run("hyprctl", "eval", code)
  if result != "ok":
    raise WorkspaceError(result[:300])


def dispatch(kind, values):
  execute("hl.dispatch(hl.dsp." + kind + "(" + lua(values) + "))")


JSON_ENCODER = r'''
local function encode(v)
  local kind = type(v)
  if kind == "nil" then return "null" end
  if kind == "boolean" or kind == "number" then return tostring(v) end
  if kind == "string" then
    return '"' .. v:gsub('[%z\1-\31\\"]', function(c) return string.format('\\u%04x', c:byte()) end) .. '"'
  end
  local out = {}
  if #v > 0 then
    for _, value in ipairs(v) do table.insert(out, encode(value)) end
    return '[' .. table.concat(out, ',') .. ']'
  end
  for k,value in pairs(v) do table.insert(out, encode(tostring(k)) .. ':' .. encode(value)) end
  return '{' .. table.concat(out, ',') .. '}'
end
'''


def layout_metadata():
  code = JSON_ENCODER + '''
local result = {}
for _, w in ipairs(hl.get_windows({})) do
  local item = {stable_id = w.stable_id}
  local l = w.layout
  if l then
    item.name = l.name
    if l.column then
      item.column = l.column.index
      item.width = l.column.width
      item.row = l.index_in_column
    end
  end
  result[w.address] = item
end
return encode(result)
'''
  return json.loads(run("hyprctl", "repl", code))


def recover_argv(raw, executable):
  argv = [os.fsdecode(v) for v in raw.split(b"\0") if v]
  # setproctitle can replace the whole NUL-separated vector with one command line.
  if len(argv) == 1 and argv[0].startswith(executable + " "):
    with contextlib.suppress(ValueError):
      argv = shlex.split(argv[0])
  if argv and not (Path(argv[0]).is_file() or shutil.which(argv[0])):
    argv[0] = executable
  return argv


def process_info(pid):
  root = Path("/proc") / str(pid)
  try:
    executable = str((root / "exe").resolve(strict=True))
    argv = recover_argv((root / "cmdline").read_bytes(), executable)
    cwd = str((root / "cwd").resolve(strict=True))
    birth = (root / "stat").read_text().rsplit(")", 1)[1].split()[19]
    # A terminal's shell tracks the current directory, unlike its GUI process.
    if argv and Path(argv[0]).name.lower() in {"alacritty", "kitty", "foot", "ghostty"}:
      children = (root / "task" / str(pid) / "children").read_text().split()
      if children:
        with contextlib.suppress(OSError):
          cwd = str((Path("/proc") / children[0] / "cwd").resolve(strict=True))
    return {"argv": argv[:256], "cwd": cwd, "birth": birth}
  except (OSError, IndexError):
    return {"argv": [], "cwd": str(HOME), "birth": ""}


def workarea(monitor):
  scale = monitor.get("scale", 1)
  width, height = monitor["width"] / scale, monitor["height"] / scale
  if monitor.get("transform", 0) % 2:
    width, height = height, width
  left, top, right, bottom = monitor.get("reserved", [0, 0, 0, 0])
  return [monitor["x"] + left, monitor["y"] + top, width - left - right, height - top - bottom]


def split_tree(windows, bounds):
  """Recover a BSP partition from its leaf rectangles, including unequal splits."""
  if not windows:
    return None
  if len(windows) == 1:
    return {"leaf": windows[0]["key"]}
  candidates = []
  for axis in [0, 1]:
    ordered = sorted(windows, key=lambda w: w["at"][axis])
    for index in range(1, len(ordered)):
      before, after = ordered[:index], ordered[index:]
      edge = max(w["at"][axis] + w["size"][axis] for w in before)
      start = min(w["at"][axis] for w in after)
      if start >= edge - 2:
        cut = (edge + start) / 2
        ratio = (cut - bounds[axis]) / bounds[axis + 2]
        if .04 < ratio < .96:
          candidates.append((abs(.5 - ratio), axis, cut, before, after))
  if not candidates:
    raise WorkspaceError("This tiled arrangement could not be saved. Ungroup overlapping tiled windows first.")
  _, axis, cut, before, after = min(candidates, key=lambda c: c[:2])
  first, second = list(bounds), list(bounds)
  first[axis + 2] = cut - bounds[axis]
  second[axis] = cut
  second[axis + 2] = bounds[axis] + bounds[axis + 2] - cut
  return {"axis": axis, "ratio": 2 * first[axis + 2] / bounds[axis + 2],
      "first": split_tree(before, first), "second": split_tree(after, second)}


def command_for(window, info):
  argv = info["argv"]
  if not argv:
    raise WorkspaceError("A window's launch command is unavailable. Try saving again after the app starts.")
  app = Path(argv[0]).name.lower()
  if app in {"chromium", "google-chrome", "chrome", "brave", "brave-browser"}:
    argv = [a for a in argv if a not in {"--new-window", "--restore-last-session"}]
    argv += ["--new-window"]
    if not any(a.startswith(("http:", "https:", "file:", "about:", "--app=")) for a in argv[1:]):
      argv.append("about:blank")
  elif app in {"firefox", "firefox-bin"}:
    argv += ["--new-window", "about:blank"]
  return argv


# Chromium's SNSS command records and navigation Pickles are defined in
# components/sessions/core/{session_service_commands,serialized_navigation_entry}.cc.
def chromium_sessions(raw):
  if raw[:4] != b"SNSS" or len(raw) < 8 or struct.unpack_from("<I", raw, 4)[0] not in {1, 3}:
    return []
  windows, tabs = {}, {}
  offset = 8
  while offset + 2 <= len(raw):
    size = struct.unpack_from("<H", raw, offset)[0]
    offset += 2
    if size < 1 or offset + size > len(raw):
      break  # Chromium may be appending the final record while we read.
    kind, payload = raw[offset], raw[offset + 1:offset + size]
    offset += size
    try:
      if kind == 0:
        wid, tid = struct.unpack_from("<ii", payload)
        tabs.setdefault(tid, {}).update(window=wid)
        windows.setdefault(wid, {})
      elif kind in {2, 7}:
        tid, index = struct.unpack_from("<ii", payload)
        tabs.setdefault(tid, {})["order" if kind == 2 else "selected"] = index
      elif kind == 8:
        wid, index = struct.unpack_from("<ii", payload)
        windows.setdefault(wid, {})["selected"] = index
      elif kind == 31:
        _, wid, length = struct.unpack_from("<iii", payload)
        if 0 <= length <= 32768 and 12 + length <= len(payload):
          windows.setdefault(wid, {})["userTitle"] = payload[12:12 + length].decode("utf-8")
      elif kind == 6:
        # Pickle header, tab id, navigation index, URL, UTF-16 title.
        _, tid, index, length = struct.unpack_from("<iiii", payload)
        if length < 0 or length > 32768 or 16 + length > len(payload):
          continue
        url = payload[16:16 + length].decode("utf-8")
        cursor = 16 + ((length + 3) // 4) * 4
        title_length = struct.unpack_from("<i", payload, cursor)[0]
        if title_length < 0 or title_length > 32768:
          continue
        title = payload[cursor + 4:cursor + 4 + title_length * 2].decode("utf-16-le")
        tabs.setdefault(tid, {}).setdefault("navigations", {})[index] = {"url": url, "title": title}
      elif kind == 16:
        tabs.pop(struct.unpack_from("<i", payload)[0], None)
      elif kind == 17:
        windows.pop(struct.unpack_from("<i", payload)[0], None)
    except (struct.error, UnicodeError):
      continue
  result = []
  for wid, window in windows.items():
    entries = []
    for tid, tab in sorted(tabs.items(), key=lambda pair: pair[1].get("order", 0)):
      if tab.get("window") != wid:
        continue
      navigations = tab.get("navigations", {})
      navigation = navigations.get(tab.get("selected"))
      if not navigation and navigations:
        navigation = navigations[max(navigations)]
      if navigation and re.match(r"^(https?://|file://|about:|chrome://|chrome-extension://)", navigation["url"]):
        entries.append({**navigation, "order": tab.get("order", 0)})
    if entries:
      active = next((tab for tab in entries if tab["order"] == window.get("selected", 0)), entries[0])
      result.append({"urls": [tab["url"] for tab in entries], "title": window.get("userTitle") or active["title"], "activeUrl": active["url"], "titles": [tab["title"] for tab in entries]})
  return result


def argument_value(argv, flag, default=None):
  for index, value in enumerate(argv):
    if value.startswith(flag + "="):
      return value.split("=", 1)[1]
    if value == flag and index + 1 < len(argv):
      return argv[index + 1]
  return default


def capture_app_state(window, info, cache):
  argv = info["argv"]
  app = Path(argv[0]).name.lower() if argv else ""
  if app in {"chromium", "google-chrome", "chrome", "brave", "brave-browser"} and not any(a.startswith(("--app=", "--app-id=")) for a in argv):
    defaults = {"chromium": "chromium", "chrome": "google-chrome", "google-chrome": "google-chrome", "brave": "BraveSoftware/Brave-Browser", "brave-browser": "BraveSoftware/Brave-Browser"}
    directory = Path(argument_value(argv, "--user-data-dir", str(HOME / ".config" / defaults[app])))
    profile = argument_value(argv, "--profile-directory", "Default")
    location = directory / profile / "Sessions"
    if str(location) not in cache:
      cache[str(location)] = []
      for path in sorted(location.glob("Session_*"), key=lambda p: p.stat().st_mtime, reverse=True)[:2]:
        if path.stat().st_size > 32 * 1024 * 1024:
          continue
        records = chromium_sessions(path.read_bytes())
        if records:
          cache[str(location)] = records
          break
    records = cache[str(location)]
    # Named windows may themselves end in a browser suffix: exact titles win.
    title = window["title"]
    matches = [record for record in records if record["title"] == title or record.get("activeUrl") == title]
    if not matches:
      title = re.sub(r" - (Chromium|Google Chrome|Brave)$", "", title)
      matches = [record for record in records if record["title"] == title or record.get("activeUrl") == title]
    if not matches and len(records) == 1 and not any(a in {"--incognito", "--guest"} for a in argv) and not re.search(r"incognito|private", window["title"], re.I):
      live = [w for w in query("clients") if w["pid"] == window["pid"] and w.get("mapped", True)]
      if len(live) == 1:
        matches = records
    if len(matches) != 1:
      raise WorkspaceError("This browser window's tabs aren't available yet. Try saving again after a moment. Private windows aren't supported.")
    return {"kind": "browser", "urls": matches[0]["urls"][:200]}
  if app == "spotify" or window["class"].lower() == "spotify":
    paths = (HOME / ".cache/spotify/Users").glob("*/list_player_play_request")
    for path in sorted(paths, key=lambda p: p.stat().st_mtime, reverse=True):
      if path.stat().st_size <= 1024 * 1024:
        match = re.search(rb"spotify:(?:playlist|album|artist|track):[A-Za-z0-9]{22}(?![A-Za-z0-9])", path.read_bytes())
        if match:
          return {"kind": "spotify", "uri": match[0].decode("ascii")}
  return None


def state_command(window, argv):
  state = window.get("appState") or {}
  if state.get("kind") == "browser":
    urls = state.get("urls", [])
    if not urls or len(urls) > 200 or not all(isinstance(u, str) and re.match(r"^(https?://|file://|about:|chrome://|chrome-extension://)", u) and "\0" not in u for u in urls):
      raise WorkspaceError("The saved browser tabs are invalid.")
    argv = [a for a in argv if not re.match(r"^(https?://|file://|about:|chrome://|chrome-extension://)", a)]
    return argv + urls
  if state.get("kind") == "spotify":
    uri = state.get("uri", "")
    if not re.fullmatch(r"spotify:(?:playlist|album|artist|track):[A-Za-z0-9]{22}", uri):
      raise WorkspaceError("The saved Spotify link is invalid.")
    return [a for a in argv if not a.startswith("spotify:")] + [uri]
  return argv


def capture():
  workspace = query("activeworkspace")
  if workspace["id"] < 1:
    raise WorkspaceError("Switch to a regular workspace before saving.")
  monitors = query("monitors")
  monitor = next((m for m in monitors if m["id"] == workspace["monitorID"]), None)
  if not monitor:
    raise WorkspaceError("The workspace's screen is unavailable.")
  mode = run("omarchy-hyprland-workspace-layout-current", str(workspace["id"]))
  if mode not in MODES:
    raise WorkspaceError("Scenes supports tiling, floating and scrolling layouts.")
  origin_tag = "omarchy-minimized-from-" + str(workspace["id"])
  clients = [w for w in query("clients") if w.get("mapped", True) and
       (w["workspace"]["id"] == workspace["id"] or
        (w["workspace"].get("name", "").startswith("special:minimized") and origin_tag in w.get("tags", [])))]
  if len(clients) > MAX_WINDOWS:
    raise WorkspaceError("You can save up to 100 windows in one workspace.")
  metadata = layout_metadata()
  windows = []
  state_cache = {}
  for w in clients:
    info = process_info(w["pid"])
    windows.append({"key": uuid.uuid4().hex, "address": w["address"], "pid": w["pid"], "birth": info["birth"],
            "stable_id": metadata.get(w["address"], {}).get("stable_id"), "class": w["class"], "title": w["title"], "initialTitle": w.get("initialTitle", ""),
            "appState": capture_app_state(w, info, state_cache), "argv": command_for(w, info), "cwd": info["cwd"], "at": w["at"], "size": w["size"],
            "floating": w["floating"], "minimized": w["workspace"]["id"] != workspace["id"], "fullscreen": w.get("fullscreen", 0),
            "layout": metadata.get(w["address"], {})})
  area = workarea(monitor)
  tiled = [w for w in windows if not w["floating"] and not w.get("minimized")]
  direction = json.loads(run("hyprctl", "getoption", "scrolling:direction", "-j")).get("str", "right")
  if mode == "scrolling":
    cols = {}
    for w in tiled:
      cols.setdefault(w["layout"].get("column", 0), w)
    ordered = [w for _, w in sorted(cols.items())]
    if len(ordered) > 1:
      first, last = ordered[0], ordered[-1]
      axis = max([0, 1], key=lambda a: abs(last["at"][a] - first["at"][a]) / area[a + 2])
      direction = ("right" if last["at"][0] > first["at"][0] else "left") if axis == 0 else ("down" if last["at"][1] > first["at"][1] else "up")
  return {"workspace": workspace["id"], "mode": mode, "direction": direction, "monitor": monitor["name"], "area": area,
      "session": os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", ""), "windows": windows,
      "tree": split_tree(tiled, area) if mode == "dwindle" else None,
      "focused": next((w["key"] for w in windows if w["address"] == workspace.get("lastwindow")), None)}


def launch_window(saved, known, workspace):
  argv = saved.get("argv")
  if not isinstance(argv, list) or not argv or not all(isinstance(a, str) and "\0" not in a for a in argv):
    raise WorkspaceError("A saved app's launch command is invalid.")
  argv = state_command(saved, argv)
  before = query("clients")
  if Path(argv[0]).name.lower() == "spotify" and any(w["class"].lower() == "spotify" for w in before):
    raise WorkspaceError("Spotify shares one window. Close its existing window before opening this saved arrangement.")
  cwd = saved.get("cwd", str(HOME))
  if not Path(cwd).is_dir():
    cwd = str(HOME)
  token = "omarchy-scene-" + uuid.uuid4().hex
  browser_name = None
  launch_page = None
  app = Path(argv[0]).name.lower()
  chromium = app in {"chromium", "google-chrome", "chrome", "brave", "brave-browser"} and not any(a.startswith(("--app=", "--app-id=")) for a in argv)
  firefox = app in {"firefox", "firefox-bin"}
  if chromium or firefox:
    # Browser requests may be forwarded to an existing process, so give the
    # requested window its own meaningful identity instead of using its PID/class.
    base = str(saved.get("sceneName") or saved.get("title") or "Scene")
    titles = {w.get("title", "") for w in before}
    if firefox:
      titles.update(re.sub(r" [—-] (?:Mozilla )?Firefox(?: ESR)?$", "", title) for title in list(titles))
    browser_name = base
    copy = 2
    while browser_name in titles:
      browser_name = base + " (" + str(copy) + ")"
      copy += 1
  if chromium:
    cleaned = []
    skip = False
    for arg in argv:
      if skip:
        skip = False
      elif arg == "--window-name":
        skip = True
      elif not arg.startswith("--window-name="):
        cleaned.append(arg)
    argv = cleaned + ["--window-name=" + browser_name]
  elif firefox:
    # Firefox has no --window-name for forwarded requests. A short-lived blank
    # page supplies the identity, then replaces itself with the normal blank tab.
    # No keyboard input, extensions, remote debugging or background service.
    page = '<meta name="color-scheme" content="dark light"><title>' + html.escape(browser_name) + '</title><script>setTimeout(()=>location.replace("about:blank"),2000)</script>'
    argv = [a for a in argv if a != "--new-window" and not re.match(r"^(https?://|file:|about:|data:)", a)]
    fd, path = tempfile.mkstemp(prefix="omarchy-scene-", suffix=".html")
    launch_page = Path(path)
    with os.fdopen(fd, "w") as stream:
      stream.write(page)
    argv += ["--new-window", launch_page.as_uri()]
  command = shlex.join(["env", "OMARCHY_SAVED_WORKSPACE_LAUNCH=" + token, *argv])
  launch_command = "hl.exec_cmd(" + lua_string("cd " + shlex.quote(cwd) + " && exec " + command) + ", " + lua({"workspace": str(workspace), "tag": "+" + token}) + ")"
  deadline = time.monotonic() + 18
  signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE", "")
  runtime = Path(os.environ.get("XDG_RUNTIME_DIR", "/run/user/" + str(os.getuid())))
  event = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
  with contextlib.suppress(OSError):
    event.connect(str(runtime / "hypr" / signature / ".socket2.sock"))
  event.settimeout(.25)
  try:
    execute(launch_command)
    while time.monotonic() < deadline:
      clients = query("clients")
      candidates = [w for w in clients if w["address"] not in known and w["class"].casefold() == saved["class"].casefold()
                    and ((w.get("title") == browser_name or (firefox and w.get("title") in {browser_name + " — Mozilla Firefox", browser_name + " - Mozilla Firefox", browser_name + " — Firefox", browser_name + " — Mozilla Firefox ESR"})) if browser_name else token in [t.rstrip("*") for t in w.get("tags", [])])]
      if len(candidates) == 1:
        if token in [t.rstrip("*") for t in candidates[0].get("tags", [])]:
          dispatch("window.tag", {"window": "address:" + candidates[0]["address"], "tag": "-" + token})
        return candidates[0]
      try:
        event.recv(8192)
      except (socket.timeout, OSError):
        time.sleep(.1)
  finally:
    event.close()
    if launch_page:
      launch_page.unlink(missing_ok=True)
  raise WorkspaceError("The app did not open an identifiable new window: " + saved["class"])


def float_window(address, enabled):
  dispatch("window.float", {"window": "address:" + address, "action": "on" if enabled else "off"})


def focus(address):
  dispatch("focus", {"window": "address:" + address})


def layout_message(message):
  dispatch("layout", message)


def boolean_option(option):
  value = json.loads(run("hyprctl", "getoption", option, "-j"))
  return bool(value.get("bool", value.get("int", False)))


def set_mode(workspace, mode, direction=None):
  if mode not in MODES or not isinstance(workspace, int) or not 1 <= workspace < 2147483647:
    raise WorkspaceError("Invalid workspace layout.")
  source = "o.workspace_mode({ workspace = " + lua_string(str(workspace)) + ", mode = " + lua_string(mode) + " })"
  if mode == "scrolling" and direction in {"left", "right", "up", "down"}:
    source += "; hl.workspace_rule({workspace=" + lua_string(str(workspace)) + ",layout=\"scrolling\",layout_opts={direction=" + lua_string(direction) + "}})"
  execute(source)
  directory = STATE.parent / "workspace-layouts"
  directory.mkdir(parents=True, exist_ok=True)
  path = directory / (str(workspace) + ".lua")
  fd, temporary = tempfile.mkstemp(dir=directory, prefix=".saved-")
  with os.fdopen(fd, "w") as f:
    f.write(source + "\n")
  os.replace(temporary, path)
  for target in ["omarchy.workspaces", "omarchy.dock"]:
    subprocess.run(["omarchy-shell", "-q", target, "refresh"], capture_output=True)


def first_leaf(tree):
  return tree["leaf"] if "leaf" in tree else first_leaf(tree["first"])


def restore_tree(tree, addresses):
  if "leaf" in tree:
    return
  first = addresses[first_leaf(tree["first"])]
  second = addresses[first_leaf(tree["second"])]
  focus(first)
  layout_message("preselect " + ("r" if tree["axis"] == 0 else "d"))
  float_window(second, False)
  focus(second)
  layout_message("splitratio " + str(tree["ratio"]) + " exact")
  restore_tree(tree["first"], addresses)
  restore_tree(tree["second"], addresses)


def restore_scrolling(profile, addresses, area):
  tiled = [w for w in profile["windows"] if not w["floating"] and not w.get("minimized")]
  columns = {}
  for w in tiled:
    columns.setdefault(w["layout"].get("column", 0), []).append(w)
  last = None
  for _, column in sorted(columns.items()):
    column.sort(key=lambda w: w["layout"].get("row", 0))
    for index, saved in enumerate(column):
      if last:
        focus(last)
      address = addresses[saved["key"]]
      float_window(address, False)
      focus(address)
      if index:
        layout_message("consume_or_expel prev")
      last = address
    if last:
      focus(last)
      layout_message("colresize " + str(column[0]["layout"].get("width", .5)))
    # Restore shared row boundaries bottom-up, so later resizes do not undo earlier ones.
    cross = 0 if profile.get("direction", "right") in {"up", "down"} else 1
    for saved in reversed(column[1:]):
      now = next(w for w in query("clients") if w["address"] == addresses[saved["key"]])
      desired = area[cross] + (saved["at"][cross] - profile["area"][cross]) * area[cross + 2] / profile["area"][cross + 2]
      delta = round(now["at"][cross] - desired)
      dispatch("window.resize", {"window": "address:" + now["address"], "x": delta if cross == 0 else 0,
                   "y": delta if cross == 1 else 0, "relative": True})


def restore_destination(current, clients, block=None):
  occupied = set()
  for window in clients:
    if not window.get("mapped", True):
      continue
    occupied.add(int(window["workspace"]["id"]))
    for tag in window.get("tags", []):
      match = re.fullmatch(r"omarchy-minimized-from-(\d+)", tag)
      if match:
        occupied.add(int(match[1]))
  # Monitor workspaces are blocks of ten, including when the last slot is active.
  base = (current - 1) // 10 * 10 if block is None else block * 10
  if current not in occupied and base < current <= base + 10:
    return current
  start = current - base if base < current <= base + 10 else 0
  for offset in range(10):
    target = base + (start + offset) % 10 + 1
    if target not in occupied:
      return target
  raise WorkspaceError("All workspaces on this monitor are occupied.")


def monitor_block(monitor, current):
  path = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state")) / "omarchy/monitors/workspaces"
  with contextlib.suppress(OSError, ValueError):
    for line in path.read_text().splitlines():
      block, connector, _ = line.split("\t", 2)
      if connector == monitor["name"]:
        return int(block)
  return (current - 1) // 10


def restore(profile, data):
  if profile.get("mode") not in MODES or not isinstance(profile.get("windows"), list) or len(profile["windows"]) > MAX_WINDOWS:
    raise WorkspaceError("The saved scene is invalid.")
  current = query("activeworkspace")
  target = int(current["id"])
  if target < 1:
    raise WorkspaceError("Open a regular workspace first.")
  monitors = query("monitors")
  monitor = next(m for m in monitors if m["id"] == current["monitorID"])
  clients = query("clients")
  target = restore_destination(target, clients, monitor_block(monitor, target))
  used, addresses = set(), {}
  # Select the empty destination before applying its layout or opening apps.
  dispatch("focus", {"workspace": str(target)})
  dispatch("workspace.move", {"workspace": str(target), "monitor": monitor["name"]})
  # Apps should appear in the saved layout from their first frame.
  set_mode(target, profile["mode"], profile.get("direction"))
  # A save is a reusable arrangement: every opening creates independent windows.
  for saved in profile["windows"]:
    existing = launch_window({**saved, "sceneName": profile.get("name", "Scene")}, {w["address"] for w in query("clients")}, target)
    used.add(existing["address"])
    addresses[saved["key"]] = existing["address"]
  spare = None
  dispatch("focus", {"workspace": str(target)})
  dispatch("workspace.move", {"workspace": str(target), "monitor": monitor["name"]})
  # Detach all saved windows from their old layout, then reconstruct it deterministically.
  for saved in profile["windows"]:
    address = addresses[saved["key"]]
    dispatch("window.fullscreen_state", {"window": "address:" + address, "internal": 0, "client": 0})
    float_window(address, True)
    dispatch("window.move", {"window": "address:" + address, "workspace": str(target), "follow": False})
  # Moving the last window can recreate an empty workspace with its default layout.
  # Apply the saved mode again after all windows have arrived.
  set_mode(target, profile["mode"], profile.get("direction"))
  area = workarea(monitor)
  if profile["mode"] == "dwindle" and profile.get("tree"):
    old_options = {k: boolean_option(k) for k in ["dwindle:preserve_split", "dwindle:use_active_for_splits"]}
    execute("hl.config({dwindle={preserve_split=true,use_active_for_splits=true}})")
    try:
      float_window(addresses[first_leaf(profile["tree"])], False)
      restore_tree(profile["tree"], addresses)
    finally:
      execute("hl.config({dwindle={preserve_split=" + lua(bool(old_options["dwindle:preserve_split"])) + ",use_active_for_splits=" + lua(bool(old_options["dwindle:use_active_for_splits"])) + "}})")
  elif profile["mode"] == "scrolling":
    restore_scrolling(profile, addresses, area)
  for saved in profile["windows"]:
    address = addresses[saved["key"]]
    if saved["floating"] or profile["mode"] == "floating":
      x = area[0] + (saved["at"][0] - profile["area"][0]) * area[2] / profile["area"][2]
      y = area[1] + (saved["at"][1] - profile["area"][1]) * area[3] / profile["area"][3]
      width = saved["size"][0] * area[2] / profile["area"][2]
      height = saved["size"][1] * area[3] / profile["area"][3]
      dispatch("window.resize", {"window": "address:" + address, "x": round(width), "y": round(height), "relative": False})
      dispatch("window.move", {"window": "address:" + address, "x": round(x), "y": round(y), "relative": False})
  selected = addresses.get(profile.get("focused"))
  if selected:
    focus(selected)
  for saved in profile["windows"]:
    if saved["fullscreen"]:
      dispatch("window.fullscreen_state", {"window": "address:" + addresses[saved["key"]], "internal": saved["fullscreen"], "client": saved["fullscreen"]})
  if profile["mode"] == "scrolling":
    tiled = [w for w in profile["windows"] if not w["floating"] and not w.get("minimized")]
    if tiled:
      saved = tiled[0]
      now = next(w for w in query("clients") if w["address"] == addresses[saved["key"]])
      direction = profile.get("direction", "right")
      axis = 1 if direction in {"up", "down"} else 0
      desired = area[axis] + (saved["at"][axis] - profile["area"][axis]) * area[axis + 2] / profile["area"][axis + 2]
      sign = -1 if direction in {"left", "up"} else 1
      layout_message("move " + str(round(sign * (desired - now["at"][axis]))))
  for saved in profile["windows"]:
    if saved.get("minimized"):
      address = addresses[saved["key"]]
      dispatch("window.tag", {"window": "address:" + address, "tag": "+omarchy-minimized-from-" + str(target)})
      dispatch("window.move", {"window": "address:" + address, "workspace": "special:minimized", "follow": False})
  if selected and profile["mode"] != "scrolling":
    focus(selected)
  record_opened(data, profile["id"], target, addresses.values())
  return {"ok": True, "otherWorkspace": spare}


def effective_config():
  # A running shell is authoritative; its API includes default-only setups.
  result = subprocess.run(["omarchy-shell", "-q", "shell", "listShellConfig"], capture_output=True, text=True)
  if result.returncode == 0 and isinstance(result.stdout, str):
    with contextlib.suppress(ValueError):
      config = json.loads(result.stdout)
      if isinstance(config, dict) and config.get("version") == 1:
        return config, True
  source = CONFIG if CONFIG.exists() else Path(os.environ["OMARCHY_PATH"]) / "config/omarchy/shell.json"
  try:
    config = json.loads(source.read_text())
    if not isinstance(config, dict):
      raise ValueError()
    return config, False
  except (OSError, ValueError):
    raise WorkspaceError("The shell configuration could not be read; it was left unchanged.")


def enabled():
  config, _ = effective_config()
  if WIDGET in config.get("disabledPlugins", []):
    return False
  return any(isinstance(entries, list) and any(
    (entry == WIDGET if isinstance(entry, str) else isinstance(entry, dict) and entry.get("id") == WIDGET)
    for entry in entries) for entries in config.get("bar", {}).get("layout", {}).values())


def configure(value):
  config, running = effective_config()
  if running:
    args = ["putBarWidget", WIDGET, json.dumps({"section": "centerBegin"})] if value else ["setPluginEnabled", WIDGET, "false"]
    result = subprocess.run(["omarchy-shell", "-q", "shell", *args], capture_output=True, text=True)
    if result.returncode != 0 or result.stdout.strip() != "ok":
      raise WorkspaceError("The shell could not update Scenes: " + str(result.stderr or result.stdout).strip()[:200])
  else:
    layout = config.setdefault("bar", {}).setdefault("layout", {})
    placed = enabled()
    if not value:
      for key, entries in layout.items():
        if isinstance(entries, list):
          layout[key] = [entry for entry in entries if entry != WIDGET and not (isinstance(entry, dict) and entry.get("id") == WIDGET)]
    elif not placed:
      layout.setdefault("centerBegin", []).append({"id": WIDGET})
    if value and isinstance(config.get("disabledPlugins"), list):
      config["disabledPlugins"] = [entry for entry in config["disabledPlugins"] if entry != WIDGET]
    config.pop("savedWorkspaces", None)
    config["version"] = 1
    atomic_json(CONFIG, config)
  if not (STATE / "workspaces.json").exists():
    atomic_json(STATE / "workspaces.json", database())


def main(argv):
  command = argv[0] if argv else "list"
  if command == "status":
    print("on" if enabled() else "off")
    return
  STATE.mkdir(parents=True, exist_ok=True)
  with (STATE / ".lock").open("a") as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    data = database()
    result = {"ok": True}
    if command in {"enable", "disable", "toggle"}:
      configure(command == "enable" or (command == "toggle" and not enabled()))
    elif command in {"save", "update"}:
      if len(argv) != 2:
        raise WorkspaceError("Enter a name for this scene.")
      profile = put_profile(data, capture(), name=argv[1] if command == "save" else None,
                 identifier=argv[1] if command == "update" else None)
      atomic_json(STATE / "workspaces.json", data)
    elif command == "rename":
      if len(argv) != 3:
        raise WorkspaceError("Enter a new scene name.")
      rename_profile(data, argv[1], argv[2])
      atomic_json(STATE / "workspaces.json", data)
    elif command == "restore":
      result = restore(find_profile(data, argv[1]), data)
      atomic_json(STATE / "workspaces.json", data)
    elif command == "delete":
      profile = find_profile(data, argv[1])
      data["items"].remove(profile)
      data["opened"] = {key: value for key, value in data.get("opened", {}).items() if value.get("id") != profile["id"]}
      if data.get("active", {}).get("id") == profile["id"]:
        data["active"] = {}
      atomic_json(STATE / "workspaces.json", data)
    elif command != "list":
      raise WorkspaceError("Unknown workspace action.")
    print(json.dumps(result))


if __name__ == "__main__":
  try:
    main(sys.argv[1:])
  except (WorkspaceError, OSError, ValueError, IndexError, subprocess.SubprocessError) as error:
    print(json.dumps({"ok": False, "error": str(error)}))
    sys.exit(1)
