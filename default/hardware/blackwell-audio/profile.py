"""A version-bounded workaround bundle, not a diagnosis of NVIDIA stalls.

Only user configuration is changed. No audio/browser restart, PCI config access,
driver options, clocks, firmware, display layout, or boot changes belong here.
"""

import argparse
import fcntl
import json
import os
from pathlib import Path
import platform
import re
import shlex
import stat
import subprocess
import tempfile


PACKAGES = {
  "nvidia-utils": "615.71.09",
  "nvidia-open-dkms": "615.71.09",
  "linux": "7.2.3.arch1",
  "pipewire": "1.6.8",
  "wireplumber": "0.5.17",
  "chromium": "152.0.7977.82",
}
KERNEL = "7.2.3-arch1-3"
FILES = (
  "pipewire/pipewire.conf.d/90-omarchy-blackwell-audio.conf",
  "wireplumber/wireplumber.conf.d/90-omarchy-blackwell-audio.conf",
  "chromium-flags.conf",
)
FLAGS = {
  "ozone-platform": "wayland",
  "ozone-platform-hint": "wayland",
  "use-gl": "angle",
  "use-angle": "gl",
  "disable-accelerated-video-decode": None,
}
FEATURES = {
  "enable-features": ("WaylandLinuxDrmSyncobj",),
  "disable-features": (
    "AcceleratedVideoDecodeLinuxZeroCopyGL",
    "AcceleratedVideoDecodeLinuxGL",
    "VaapiVideoDecoder",
  ),
}


class Conflict(Exception):
  pass


def read_id(path):
  try:
    return path.read_text().strip()
  except OSError:
    return ""


def hardware_matches(sysfs=Path("/sys"), cpuinfo=Path("/proc/cpuinfo")):
  dmi = sysfs / "class/dmi/id"
  if (read_id(dmi / "board_vendor") != "Gigabyte Technology Co., Ltd."
      or read_id(dmi / "board_name") != "B650I AORUS ULTRA"
      or read_id(dmi / "bios_version") != "F42"):
    return False
  if "AMD Ryzen 9 7950X3D 16-Core Processor" not in read_id(cpuinfo):
    return False
  gpu = any(
    read_id(device / "vendor") == "0x10de"
    and read_id(device / "device") == "0x2c34"
    and read_id(device / "class").startswith("0x03")
    for device in (sysfs / "bus/pci/devices").glob("*")
  )
  headset = any(
    read_id(device / "idVendor") == "1038"
    and read_id(device / "idProduct") == "12e0"
    for device in (sysfs / "bus/usb/devices").glob("*")
  )
  return gpu and headset


def package_versions():
  result = subprocess.run(
    ["pacman", "-Q", *PACKAGES], capture_output=True, text=True, check=False
  )
  if result.returncode:
    return {}
  return {
    name: version.split(":")[-1].rsplit("-", 1)[0]
    for name, version in (line.split() for line in result.stdout.splitlines())
  }


def check_path(path):
  # Do not replace dotfile-manager symlinks or follow a linked parent into some
  # other configuration tree. This command never runs as root.
  for part in (path, *path.parents):
    if part.is_symlink():
      raise Conflict(f"Preserving symlink: {part}")
  if path.exists() and not path.is_file():
    raise Conflict(f"Preserving non-file: {path}")


def snapshot(path):
  check_path(path)
  if not path.exists():
    return None
  return {"text": path.read_bytes().decode("utf-8"), "mode": stat.S_IMODE(path.stat().st_mode)}


def atomic_write(path, text, mode=0o600):
  check_path(path)
  path.parent.mkdir(parents=True, exist_ok=True)
  fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
  try:
    with os.fdopen(fd, "w") as stream:
      os.fchmod(stream.fileno(), mode)
      stream.write(text)
      stream.flush()
      os.fsync(stream.fileno())
    os.replace(temporary, path)
    directory = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY)
    try:
      os.fsync(directory)
    finally:
      os.close(directory)
  finally:
    Path(temporary).unlink(missing_ok=True)


def chromium_flags(text):
  lines = text.splitlines(keepends=True)
  found = {}
  for index, line in enumerate(lines):
    try:
      tokens = shlex.split(line, comments=True)
    except ValueError as error:
      raise Conflict("Preserving Chromium flags that cannot be parsed safely") from error
    for token in tokens:
      name = token.removeprefix("--").split("=", 1)[0]
      if name in ("disable-gpu", "disable-gpu-compositing", "enable-accelerated-video-decode"):
        raise Conflict(f"Preserving conflicting Chromium flag: --{name}")
      if name not in FLAGS and name not in FEATURES:
        continue
      if not token.startswith("--") or len(tokens) != 1 or "#" in line:
        raise Conflict("Preserving nonstandard Chromium flag formatting")
      if name in found:
        raise Conflict(f"Preserving duplicate Chromium flag: --{name}")
      found[name] = (index, token.partition("=")[2] if "=" in token else None)

  for name, value in FLAGS.items():
    if name in found:
      if found[name][1] != value:
        raise Conflict(f"Preserving conflicting Chromium flag: --{name}")
    else:
      lines.append(f"--{name}" + (f"={value}" if value is not None else "") + "\n")

  for name, required in FEATURES.items():
    opposite = "disable-features" if name == "enable-features" else "enable-features"
    opposite_values = (found.get(opposite, (0, ""))[1] or "").split(",")
    if any(re.split(r"[<:]", feature)[0] in required for feature in opposite_values):
      raise Conflict(f"Preserving conflicting Chromium --{opposite}")
    index, value = found.get(name, (len(lines), ""))
    if value and any(character.isspace() or character in "\\\"'" for character in value):
      raise Conflict(f"Preserving custom Chromium feature quoting: --{name}")
    values = value.split(",") if value else []
    for feature in required:
      if feature not in values:
        if any(re.split(r"[<:]", existing)[0] == feature for existing in values):
          raise Conflict(f"Preserving custom Chromium feature parameters: {feature}")
        values.append(feature)
    replacement = f"--{name}={','.join(values)}\n"
    if name in found:
      lines[index] = replacement
    else:
      lines.append(replacement)

  # Preserve a pre-existing final line without a newline when appending flags.
  return "".join(line if line.endswith("\n") else line + "\n" for line in lines)


class Profile:
  def __init__(self, config, state, sources, system_config=Path("/etc")):
    self.config = config
    self.state = state
    self.sources = sources
    self.system_config = system_config

  def load(self):
    saved = snapshot(self.state)
    if saved is None:
      return None
    data = json.loads(saved["text"])
    if data.get("schema") != 1 or data.get("config") != str(self.config):
      raise Conflict("Compatibility state does not match this configuration directory")
    if data.get("status") not in ("applying", "on", "removing", "off"):
      raise Conflict("Compatibility state contains an unknown operation")
    names = set(data.get("files", {}))
    if names != set(FILES) and not (not names and data["status"] == "off"):
      raise Conflict("Compatibility state contains incomplete or unknown file paths")
    return data

  def save(self, data):
    atomic_write(self.state, json.dumps(data, indent=2) + "\n")

  def plan(self):
    # Never silently win over existing custom audio tuning, including files
    # whose names sort after ours. Preserve the whole bundle on any conflict.
    for base, pattern in (
      ("pipewire", r"(?:default\.clock\.|(?:clock|node)\.force-(?:quantum|rate))"),
      ("wireplumber", r"api\.alsa\.(?:disable-tsched|period-size|headroom)\s*="),
    ):
      candidates = []
      for config_root in (self.system_config, self.config):
        candidates.append(config_root / base / f"{base}.conf")
        candidates += sorted((config_root / base / f"{base}.conf.d").glob("*.conf"))
      for path in candidates:
        if path.exists() or path.is_symlink():
          current = snapshot(path)
          code = re.sub(r"#[^\n]*", "", current["text"])
          if re.search(pattern, code):
            raise Conflict(f"Preserving existing audio tuning: {path}")

    files = {}
    for relative, source in zip(FILES[:2], ("pipewire.conf", "wireplumber.conf")):
      if snapshot(self.config / relative) is not None:
        raise Conflict(f"Preserving existing file: {relative}")
      files[relative] = {
        "before": None,
        "after": {"text": (self.sources / source).read_text(), "mode": 0o644},
      }
    before = snapshot(self.config / FILES[2])
    files[FILES[2]] = {
      "before": before,
      "after": {
        "text": chromium_flags(before["text"] if before else ""),
        "mode": before["mode"] if before else 0o644,
      },
    }
    return {"schema": 1, "config": str(self.config), "status": "applying", "files": files}

  def verify(self, data):
    for relative, record in data["files"].items():
      current = snapshot(self.config / relative)
      interrupted = data["status"] in ("applying", "removing")
      if current != record["after"] and not (interrupted and current == record["before"]):
        raise Conflict(f"Preserving subsequent edits: {relative}; backup retained at {self.state}")

  def apply(self, automatic=False):
    data = self.load()
    if data and data["status"] == "removing":
      raise Conflict("Finish interrupted rollback with: omarchy setup blackwell-audio off")
    if data and data["status"] == "off":
      if automatic:
        print("Blackwell/audio compatibility: opted out; leaving configuration unchanged.")
        return
      data = None
    if data is None:
      data = self.plan()
      self.save(data)  # Durable rollback record before the first config write.
    self.verify(data)
    for relative, record in data["files"].items():
      destination = self.config / relative
      if snapshot(destination) != record["after"]:
        atomic_write(destination, **record["after"])
    data["status"] = "on"
    self.save(data)
    print("Blackwell/audio compatibility installed. Audio latency is increased; Chromium video decoding uses the CPU.")
    print("No running service was restarted. Log out/in and fully restart Chromium when convenient.")
    print("Rollback: omarchy setup blackwell-audio off")

  def off(self):
    data = self.load()
    if data is None:
      data = {"schema": 1, "config": str(self.config), "status": "off", "files": {}}
    if data.get("status") != "off":
      self.verify(data)
      data["status"] = "removing"
      self.save(data)
      for relative, record in data["files"].items():
        destination = self.config / relative
        if snapshot(destination) == record["before"]:
          continue
        if record["before"] is None:
          destination.unlink()
        else:
          atomic_write(destination, **record["before"])
    data["status"] = "off"
    self.save(data)
    print("Compatibility-owned changes rolled back; automatic reapplication disabled. No services restarted.")


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("action", choices=("status", "on", "off", "auto"), nargs="?", default="status")
  args = parser.parse_args()
  config = Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))).absolute()
  state = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state"))).absolute()
  profile = Profile(config, state / "omarchy/blackwell-audio/state.json", Path(__file__).parent)
  try:
    if args.action == "status":
      data = profile.load()
      print(f"Saved profile: {data['status'] if data else 'not installed'}")
      print(f"Hardware matches: {hardware_matches()}")
      print(f"Tested package versions match: {package_versions() == PACKAGES}")
      print(f"Tested running kernel matches: {platform.release() == KERNEL}")
      if data and data["status"] != "off":
        profile.verify(data)
      return 0
    if os.geteuid() == 0:
      raise Conflict("Run as the target desktop user, not root")
    if args.action != "off" and (
      not hardware_matches() or package_versions() != PACKAGES or platform.release() != KERNEL
    ):
      print("Blackwell/audio compatibility: hardware or tested versions do not match; no changes.")
      return 0 if args.action == "auto" else 1
    check_path(profile.state)
    profile.state.parent.mkdir(parents=True, exist_ok=True)
    lock = profile.state.with_suffix(".lock")
    check_path(lock)
    with lock.open("a") as stream:
      fcntl.flock(stream, fcntl.LOCK_EX)
      if args.action == "off":
        profile.off()
      else:
        profile.apply(automatic=args.action == "auto")
    return 0
  except (Conflict, OSError, ValueError) as error:
    print(f"Blackwell/audio compatibility: {error}")
    # A customization is a deliberate skip, not a reason to abort an install.
    # I/O failures still fail the migration, retaining its rollback state.
    return 0 if args.action == "auto" and isinstance(error, Conflict) else 1


if __name__ == "__main__":
  raise SystemExit(main())
