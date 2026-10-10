"""Fcitx defaults for offline finalization and updates."""

import argparse
from contextlib import contextmanager
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import sys
import time


ROOT = Path(os.environ["OMARCHY_PATH"])
PRESETS = json.loads((ROOT / "default/input-methods/presets.json").read_text())
NON_LATIN = set("af am ara bd bg by et ge gr il in iq ir kg kh kz la lk mk mm mn mv np rs ru sy th tj ua".split())
CONTROLLER = ["busctl", "--user", "call", "org.fcitx.Fcitx5", "/controller", "org.fcitx.Fcitx.Controller1"]


def run(args, **kwargs):
  return subprocess.run(args, check=True, text=True, capture_output=True, **kwargs).stdout.strip()


def read(path):
  return path.read_text() if path.exists() else ""


def values(text):
  result = {}
  for line in text.splitlines():
    match = re.match(r"^\s*([\w ]+)\s*=\s*(.*?)\s*(?:\s+#.*)?$", line)
    if match:
      result[match[1].strip()] = match[2].strip("\"'")
  return result


def sections(text):
  result = {}
  current = ""
  for line in text.splitlines():
    match = re.match(r"^\s*\[([^]]+)\]\s*$", line)
    if match:
      current = match[1]
      result.setdefault(current, {})
    elif current:
      result[current].update(values(line))
  return result


def atomic_write(path, text):
  # Follow a user's config symlink rather than replacing the link itself.
  path = path.resolve()
  if read(path) == text:
    return False
  path.parent.mkdir(parents=True, exist_ok=True)
  mode = path.stat().st_mode & 0o777 if path.exists() else 0o644
  fd, temporary = tempfile.mkstemp(prefix=".omarchy-input-", dir=path.parent)
  try:
    with os.fdopen(fd, "w") as file:
      file.write(text)
    os.chmod(temporary, mode)
    os.replace(temporary, path)
  finally:
    if os.path.exists(temporary):
      os.unlink(temporary)
  return True


def key_list(entries):
  # Fcitx canonicalizes modifiers (e.g. Shift+Super instead of Super+Shift).
  return {frozenset(value.split("+")) for value in entries.values()}


def without_ctrl_space(text):
  # Ctrl+Space belongs to tmux and Herdr, and the terminal binding returns to
  # direct input on it; a Fcitx toggle on the same key would undo that. Without
  # a TriggerKeys list Fcitx falls back to its default, which has Ctrl+Space.
  section = re.search(r"(?ms)^\[Hotkey/TriggerKeys\][ \t]*\n(.*?)(?=^\[|\Z)", text)
  if not section:
    return text.rstrip() + ("\n\n" if text.strip() else "") + "[Hotkey/TriggerKeys]\n0=Zenkaku_Hankaku\n1=Hangul\n"
  keys = values(section[1])
  kept = [keys[key] for key in sorted(keys, key=lambda key: int(key) if key.isdigit() else 0) if keys[key] != "Control+space"]
  if len(kept) == len(keys):
    return text
  body = "".join(f"{index}={key}\n" for index, key in enumerate(kept)) + ("\n" if section[1].endswith("\n\n") else "")
  return text[:section.start(1)] + body + text[section.end(1):]


def defaults(config_home, fresh=False):
  changed = False
  files = ["config", "conf/quickphrase.conf", "conf/wayland.conf", "conf/xcb.conf", "conf/pinyin.conf"]
  for name in files:
    target = config_home / "fcitx5" / name
    original = read(target)
    shipped = read(ROOT / "config/fcitx5" / name)
    if name == "config" or name == "conf/quickphrase.conf":
      if name == "config":
        original = without_ctrl_space(original)
      existing = sections(original)
      additions = []
      for section, entries in sections(shipped).items():
        # Missing hotkey sections also represent a choice: Fcitx's defaults.
        if not fresh and section.startswith("Hotkey/"):
          continue
        # Existing lists (including explicitly empty lists) are user choices.
        # A fresh profile has no working IME shortcut to preserve.
        stock_lists = {
          "Hotkey/ActivateKeys": {"0": "Hangul_Hanja"},
          "Hotkey/DeactivateKeys": {"0": "Hangul_Romaja"},
          "Hotkey/AltTriggerKeys": {"0": "Shift_L"},
          "Hotkey/EnumerateGroupForwardKeys": {"0": "Super+space"},
          "Hotkey/EnumerateGroupBackwardKeys": {"0": "Super+Shift+space"},
          "TriggerKey": {"0": "Super+grave", "1": "Super+semicolon"},
        }
        if fresh and section in existing and section in stock_lists and (key_list(existing[section]) == key_list(stock_lists[section]) or (not existing[section] and section in {"Hotkey/ActivateKeys", "Hotkey/DeactivateKeys"})):
          original = re.sub(r"(?ms)^\[" + re.escape(section) + r"\]\s*\n.*?(?=^\[|\Z)", "", original)
          existing.pop(section)
        if section not in existing:
          additions.append(f"[{section}]\n" + "".join(f"{key}={value}\n" for key, value in entries.items()))
      if additions:
        original = original.rstrip() + ("\n\n" if original.strip() else "") + "\n".join(additions)
      changed |= atomic_write(target, original)
    elif name == "conf/pinyin.conf":
      # Suppress the first-use cloud prompt while preserving any explicit
      # cloud-prediction preference and all other existing engine settings.
      if not original:
        updated = shipped
      elif "FirstRun" in values(original):
        updated = re.sub(r"(?m)^\s*FirstRun\s*=.*$", "FirstRun=False", original)
      else:
        updated = "FirstRun=False\n" + original
      changed |= atomic_write(target, updated)
    elif not target.exists() and not target.is_symlink():
      changed |= atomic_write(target, shipped)
  return changed


def activation_default():
  data_home = Path(os.environ.get("XDG_DATA_HOME") or str(Path.home() / ".local/share"))
  path = data_home / "dbus-1/services/org.fcitx.Fcitx5.service"
  original = read(path)
  # Repair the package's plain activation entry, but retain custom launchers.
  packaged = values(original).get("Exec") in ("/usr/bin/fcitx5", "/usr/bin/fcitx5 -d")
  if not original or (packaged and "SystemdService" not in values(original)):
    return atomic_write(path, read(ROOT / "default/input-methods/org.fcitx.Fcitx5.service"))
  return False


@contextmanager
def transaction(config_home):
  data_home = Path(os.environ.get("XDG_DATA_HOME") or str(Path.home() / ".local/share"))
  paths = [config_home / "fcitx5" / name for name in ["profile", "config", "conf/quickphrase.conf", "conf/wayland.conf", "conf/xcb.conf", "conf/pinyin.conf"]]
  paths += [config_home / "fontconfig/conf.d/50-omarchy-input-method.conf", data_home / "dbus-1/services/org.fcitx.Fcitx5.service"]
  before = {path.resolve(): path.read_text() if path.exists() else None for path in paths}
  try:
    yield
  except BaseException:
    for path, original in before.items():
      if original is None:
        path.unlink(missing_ok=True)
      else:
        atomic_write(path, original)
    raise


def selection():
  vconsole = values(read(Path(os.environ.get("OMARCHY_VCONSOLE", "/etc/vconsole.conf"))))
  preference = values(read(Path(os.environ.get("OMARCHY_INPUT_SELECTION", "/etc/omarchy/input-method"))))
  layout = vconsole.get("XKBLAYOUT", "us").split(",")[0] or "us"
  variant = vconsole.get("XKBVARIANT", "").split(",")[0]
  if preference.get("XKB_LAYOUT") in ("kr", "la") and vconsole.get("XKBLAYOUT", "us") == "us" and not variant:
    layout, variant = preference["XKB_LAYOUT"], ""
  method = preference.get("INPUT_METHOD", "mozc" if layout == "jp" else "none")
  if method not in PRESETS:
    raise ValueError(f"Unknown installed input method: {method}")
  if layout in NON_LATIN:
    layout, variant = "us", ""
  group_layout = layout + (f"-{variant}" if variant else "")
  if not re.fullmatch(r"[A-Za-z0-9_-]+", group_layout):
    raise ValueError("Invalid installed keyboard layout")
  return method, group_layout


def stock_profile(text):
  if not text.strip():
    return True
  groups = sections(text)
  items = [data.get("Name", "") for key, data in groups.items() if re.fullmatch(r"Groups/\d+/Items/\d+", key)]
  group = groups.get("Groups/0", {})
  return (items == ["keyboard-us"]
    and list(key for key in groups if re.fullmatch(r"Groups/\d+", key)) == ["Groups/0"]
    and group.get("Name", "Default") == "Default"
    and group.get("Default Layout", "us") == "us"
    and not groups.get("Groups/0/Items/0", {}).get("Layout"))


def profile_text(layout, method):
  default_im = method if method != "none" else f"keyboard-{layout}"
  text = f"[Groups/0]\nName=Default\nDefault Layout={layout}\nDefaultIM={default_im}\n\n[Groups/0/Items/0]\nName=keyboard-{layout}\nLayout=\n"
  if method != "none":
    text += f"\n[Groups/0/Items/1]\nName={method}\nLayout=\n"
  return text + "\n[GroupOrder]\n0=Default\n"


def font_default(config_home, method):
  variant = PRESETS[method]["font"]
  path = config_home / "fontconfig/conf.d/50-omarchy-input-method.conf"
  if not variant or path.exists() or path.is_symlink():
    return
  # Only CJK fallback changes; retain the interface and terminal's Latin font.
  rules = []
  for families, face in [("sans-serif|Liberation Sans", "Sans"), ("serif|Liberation Serif", "Serif"), ("monospace|JetBrainsMono Nerd Font", "Sans Mono")]:
    for family in families.split("|"):
      rules.append(f'<alias><family>{family}</family><accept><family>Noto {face} CJK {variant}</family></accept></alias>')
  atomic_write(path, '<?xml version="1.0"?>\n<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">\n<fontconfig>\n' + "\n".join(rules) + "\n</fontconfig>\n")


def live_group():
  group = run(["fcitx5-remote", "-q"])
  info = json.loads(run(CONTROLLER[:1] + ["--json=short"] + CONTROLLER[1:] + ["InputMethodGroupInfo", "s", group]))["data"]
  layout, items = info[:2]
  return group, layout, items


def live_set(group, layout, items):
  args = [group, layout, str(len(items))]
  for name, item_layout in items:
    args.extend([name, item_layout])
  run(CONTROLLER + ["SetInputMethodGroupInfo", "ssa(ss)"] + args)
  run(CONTROLLER + ["Save"])


def reload_bus():
  # Offline finalization and updates over SSH may have no session bus.
  try:
    run(["busctl", "--user", "call", "org.freedesktop.DBus", "/org/freedesktop/DBus", "org.freedesktop.DBus", "ReloadConfig"])
  except (OSError, subprocess.CalledProcessError, RuntimeError) as error:
    print(f"Input activation reload deferred until login: {error}", file=sys.stderr)


def available_methods():
  return json.loads(run(CONTROLLER[:1] + ["--json=short"] + CONTROLLER[1:] + ["AvailableInputMethods"]))["data"][0]


def wait_ready(method):
  for attempt in range(100):
    try:
      available = available_methods()
      if any(item[0] == method for item in available) and live_group()[2]:
        return
    except (OSError, ValueError, KeyError, IndexError, subprocess.CalledProcessError):
      pass
    time.sleep(0.1)
  raise RuntimeError(f"Fcitx did not load the {method} engine after restart")


def configure(args):
  config_home = Path(os.environ.get("XDG_CONFIG_HOME") or str(Path.home() / ".config"))
  running = subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", "fcitx5"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL).returncode == 0
  # Finalization can be retried after login. A live daemon owns its profile.
  if args.seed and running:
    return
  with transaction(config_home):
    configure_inner(args, config_home, running)


def configure_inner(args, config_home, running):
  method, layout = selection()
  profile = config_home / "fcitx5/profile"
  original = read(profile)
  if args.seed:
    if not stock_profile(original):
      return
    atomic_write(profile, profile_text(layout, method))
    defaults(config_home, fresh=True)
    activation_default()
    font_default(config_home, method)
    return

  fresh = stock_profile(original)
  changed = defaults(config_home, fresh=fresh)
  if activation_default():
    reload_bus()
  # Upgrades can run through sudo/SSH without access to the live user's bus.
  # Never overwrite its profile or restart input in that context.
  if fresh:
    if running:
      try:
        group, old_layout, items = live_group()
        if old_layout == "us" and items == [["keyboard-us", ""]]:
          new_items = [[f"keyboard-{layout}", ""]]
          if method != "none":
            if any(item[0] == method for item in available_methods()):
              new_items.append([method, ""])
            else:
              print(f"Finish input setup after login: omarchy setup input {method}", file=sys.stderr)
          live_set(group, layout, new_items)
          if live_group()[1:] != (layout, new_items):
            live_set(group, old_layout, items)
            raise RuntimeError("Fcitx did not retain the installed keyboard settings")
      except (OSError, ValueError, KeyError, IndexError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"Input profile alignment deferred until login: {error}", file=sys.stderr)
    else:
      atomic_write(profile, profile_text(layout, method))
  if running and changed:
    try:
      run(CONTROLLER + ["ReloadConfig"])
    except (OSError, subprocess.CalledProcessError) as error:
      print(f"Input defaults reload deferred until login: {error}", file=sys.stderr)


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  commands = parser.add_subparsers(dest="command", required=True)
  commands.add_parser("status")
  configure_parser = commands.add_parser("configure")
  mode = configure_parser.add_mutually_exclusive_group(required=True)
  mode.add_argument("--seed", action="store_true")
  mode.add_argument("--defaults", action="store_true")
  args = parser.parse_args()
  if args.command == "status":
    method, layout = selection()
    print(json.dumps({"installed_method": method, "layout": layout}))
  else:
    configure(args)


if __name__ == "__main__":
  try:
    main()
  except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
    raise SystemExit(f"Input method setup failed: {error}")
