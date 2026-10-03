"""Conservative physical-device grouping using metadata, never raw key events."""
import hashlib
import re
from pathlib import Path

NON_TYPING = re.compile(r"^(hl-virtual-keyboard|virtual-|power-button|sleep-button|lid-switch|video-bus)")
ALPHA_KEYS = [16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 30, 31, 32, 33, 34, 35, 36, 37, 38, 44, 45, 46, 47, 48, 49, 50]


def normalized(name):
  return re.sub(r"[^a-z0-9_-]", "-", name.lower())


def bits(text):
  # sysfs prints most significant machine-word first with unpadded words.
  word_bits = 64
  value = 0
  for word in text.split():
    value = (value << word_bits) | int(word, 16)
  return value


def metadata(directory=Path("/sys/class/input")):
  records = []
  for event in sorted(directory.glob("event*"), key=lambda p: int(p.name[5:])):
    base = event / "device"
    try:
      # Spaces belong to the device name; Hyprland turns them into '-'.
      # Only strip sysfs's terminating newline, including for media devices.
      name = (base / "name").read_text().rstrip("\n")
      physical = (base / "phys").read_text().strip()
      keys = bits((base / "capabilities/key").read_text())
      rel = bits((base / "capabilities/rel").read_text()) if (base / "capabilities/rel").exists() else 0
      typing = all(keys & (1 << k) for k in ALPHA_KEYS + [28, 57])
      pointer = bool(keys & (1 << 272)) and bool(rel & 3)
      group = re.sub(r"/input\d+$", "", physical) if physical else ""
      records.append({"name": normalized(name), "label": name, "physical": physical,
              "group": group, "typing": typing, "pointer": pointer,
              "primary": physical.endswith("/input0")})
    except (OSError, ValueError):
      continue
  return records


def resolve(devices, records):
  keyboards = devices.get("keyboards", [])
  pointer_groups = {r["group"] for r in records if r["pointer"] and r["group"]}
  primary_groups = {r["group"] for r in records if r["typing"] and r["primary"] and r["group"]}
  groups = {}
  excluded = []
  for keyboard in keyboards:
    name = keyboard.get("name", "")
    if not name or NON_TYPING.match(name):
      excluded.append(name)
      continue
    matches = [r for r in records if name == r["name"] or re.fullmatch(re.escape(r["name"]) + r"-\d+", name)]
    # Exact matches take precedence over a synthetic duplicate suffix.
    exact = [r for r in matches if name == r["name"]]
    matches = exact or matches
    typing = [r for r in matches if r["typing"] and r["group"]]
    if matches and not typing:
      excluded.append(name)
      continue
    if typing and all(r["group"] in pointer_groups and r["group"] not in primary_groups for r in typing):
      excluded.append(name)
      continue
    physical = {r["group"] for r in typing}
    known = len(physical) == 1
    key = next(iter(physical)) if known else "unresolved:" + name
    identity = hashlib.sha256(key.encode()).hexdigest()[:24]
    if identity not in groups:
      groups[identity] = {"id": identity, "label": typing[0]["label"] if known else name,
                "certain": known, "members": [], "names": []}
    groups[identity]["members"].append(keyboard)
    groups[identity]["names"].append(name)
  return list(groups.values()), excluded


def pick(groups, preferred=None):
  if preferred:
    return next((g for g in groups if g["id"] == preferred), None)
  if len(groups) == 1 and groups[0]["certain"]:
    return groups[0]
  return None


def active_index(group, event_device=""):
  if event_device in group["names"]:
    return next(d.get("active_layout_index", -1) for d in group["members"] if d["name"] == event_device)
  indices = {d.get("active_layout_index", -1) for d in group["members"]}
  return indices.pop() if len(indices) == 1 else -1
