#!/usr/bin/python3
# Copyright (c) 2026 MarkPronkin <109197080+MarkPronkin@users.noreply.github.com>
"""Build and apply a Hyprland ICC profile from the matching Apple panel override."""

import argparse
import ctypes as C
import ctypes.util
import datetime
import hashlib
import json
import os
from pathlib import Path
import plistlib
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import time
import zipfile


DRM_ROOT = Path("/sys/class/drm")
BEGIN = "-- BEGIN macbookpro-display-profile (managed)"
END = "-- END macbookpro-display-profile (managed)"


class ProfileError(Exception):
  pass


def hypr(*args):
  try:
    result = subprocess.run(
      ["hyprctl", *args], capture_output=True, text=True, timeout=20
    )
  except (OSError, subprocess.TimeoutExpired) as exc:
    raise ProfileError(f"Cannot contact Hyprland: {exc}") from exc
  if result.returncode:
    raise ProfileError(f"hyprctl {' '.join(args)}: {result.stdout}{result.stderr}")
  return result.stdout.strip()


def config_clean():
  errors = hypr("configerrors")
  if errors:
    raise ProfileError(f"Hyprland configuration errors:\n{errors}")


def monitor_config():
  # Omarchy's Lua bootstrap loads hypr.monitors from ~/.config regardless
  # of XDG_CONFIG_HOME. Reject a different directory before touching files.
  root = Path.home() / ".config"
  configured = Path(os.environ.get("XDG_CONFIG_HOME") or root)
  if configured.resolve() != root.resolve():
    raise ProfileError(
      "Omarchy loads monitor rules from ~/.config; a different XDG_CONFIG_HOME "
      "is not supported for applying or removing a profile. "
      "Use --generate-only to create a standalone ICC profile."
    )
  return (root / "hypr/monitors.lua").resolve()


def matching_panel(archive, output=None):
  """Match the connected internal panel by EDID, never by laptop model alone."""
  matches = []
  with zipfile.ZipFile(archive) as z:
    for connector in sorted(DRM_ROOT.glob("card*-*")):
      name = re.sub(r"^card\d+-", "", connector.name)
      if output and output != name:
        continue
      if not name.startswith(("LVDS-", "eDP-", "DSI-")):
        continue
      if not (connector / "status").is_file():
        continue
      if (connector / "status").read_text().strip() != "connected":
        continue
      edid = (connector / "edid").read_bytes()
      if len(edid) < 128 or edid[:8] != b"\x00\xff\xff\xff\xff\xff\xff\x00":
        raise ProfileError(f"Invalid EDID on {name}")
      if sum(edid[:128]) % 256:
        raise ProfileError(f"EDID checksum mismatch on {name}")
      vendor = int.from_bytes(edid[8:10], "big")
      product = int.from_bytes(edid[10:12], "little")
      if vendor != 0x0610:
        continue
      candidates = [
        n
        for n in z.namelist()
        if n.endswith(f"/display/DisplayProductID-{product:04x}")
      ]
      if len(candidates) != 1:
        continue
      raw = z.read(candidates[0])
      data = plistlib.loads(raw)
      if (
        data.get("DisplayVendorID") != vendor or data.get("DisplayProductID") != product
      ):
        raise ProfileError("Apple override identifiers do not match the EDID")
      matches.append((name, vendor, product, data, raw, edid))
  if len(matches) != 1:
    raise ProfileError(
      "Expected one connected internal Apple panel with an exact archive match; "
      f"found {len(matches)}. Use --output LVDS-1 if necessary."
    )
  return matches[0]


class xyY(C.Structure):
  _fields_ = [("x", C.c_double), ("y", C.c_double), ("Y", C.c_double)]


class Primaries(C.Structure):
  _fields_ = [("Red", xyY), ("Green", xyY), ("Blue", xyY)]


def littlecms():
  name = ctypes.util.find_library("lcms2")
  if not name:
    raise ProfileError("LittleCMS is required (Arch package: lcms2).")
  lib = C.CDLL(name)
  signatures = {
    "cmsBuildTabulatedToneCurve16": (
      [C.c_void_p, C.c_uint32, C.POINTER(C.c_uint16)],
      C.c_void_p,
    ),
    "cmsCreateRGBProfile": (
      [C.POINTER(xyY), C.POINTER(Primaries), C.POINTER(C.c_void_p)],
      C.c_void_p,
    ),
    "cmsSetProfileVersion": ([C.c_void_p, C.c_double], None),
    "cmsMLUalloc": ([C.c_void_p, C.c_uint32], C.c_void_p),
    "cmsMLUsetASCII": ([C.c_void_p, C.c_char_p, C.c_char_p, C.c_char_p], C.c_int),
    "cmsWriteTag": ([C.c_void_p, C.c_uint32, C.c_void_p], C.c_int),
    "cmsMLUfree": ([C.c_void_p], None),
    "cmsSaveProfileToMem": ([C.c_void_p, C.c_void_p, C.POINTER(C.c_uint32)], C.c_int),
    "cmsCloseProfile": ([C.c_void_p], C.c_int),
    "cmsFreeToneCurve": ([C.c_void_p], None),
  }
  for name, (args, result) in signatures.items():
    fn = getattr(lib, name)
    fn.argtypes, fn.restype = args, result
  return lib


def build_icc(data, product):
  """Use Apple's channel response tables as ICC TRCs, not GPU calibration ramps."""
  channels = data["DisplayGammaChannels"]
  count = data["DisplayGammaEntryCount"]
  entry_size = data["DisplayGammaEntrySize"]
  raw = data["DisplayGammaTable"]
  if channels != 3 or entry_size != 2 or not 2 <= count <= 65536:
    raise ProfileError("Unsupported Apple gamma table format")
  if len(raw) != channels * count * entry_size:
    raise ProfileError("Incorrect Apple gamma table length")
  values = struct.unpack(f">{channels * count}H", raw)
  curves = [values[c * count : (c + 1) * count] for c in range(3)]
  for curve in curves:
    if (
      curve[0] != 0
      or curve[-1] != 65535
      or any(a > b for a, b in zip(curve, curve[1:]))
    ):
      raise ProfileError("Gamma table must increase monotonically from black to white")

  def point(channel):
    x, y = (float(data[f"Display{channel}Point{axis}"]) for axis in "XY")
    if not (0 < x < 1 and 0 < y < 1 and x + y <= 1):
      raise ProfileError(f"Invalid {channel} chromaticity")
    return xyY(x, y, 1.0)

  lib = littlecms()
  pointers, profile = [], None
  try:
    for curve in curves:
      pointer = lib.cmsBuildTabulatedToneCurve16(
        None, count, (C.c_uint16 * count)(*curve)
      )
      if not pointer:
        raise ProfileError("LittleCMS could not build a response curve")
      pointers.append(pointer)
    white = point("White")
    primaries = Primaries(*(point(c) for c in ("Red", "Green", "Blue")))
    # LittleCMS adapts the native white and RGB colorants to the ICC D50 PCS.
    profile = lib.cmsCreateRGBProfile(
      C.byref(white), C.byref(primaries), (C.c_void_p * 3)(*pointers)
    )
    if not profile:
      raise ProfileError("LittleCMS could not create the RGB display profile")
    lib.cmsSetProfileVersion(profile, 2.4)
    for signature, text in {
      b"desc": f"Color LCD 0610-{product:04x} (derived from Apple panel override)",
      b"cprt": "Derived profile; panel characterization data from Apple display override.",
    }.items():
      mlu = lib.cmsMLUalloc(None, 1)
      if not mlu:
        raise ProfileError("LittleCMS could not allocate profile metadata")
      try:
        if not lib.cmsMLUsetASCII(mlu, b"en", b"US", text.encode("ascii")):
          raise ProfileError("LittleCMS could not encode profile metadata")
        if not lib.cmsWriteTag(profile, int.from_bytes(signature, "big"), mlu):
          raise ProfileError("LittleCMS could not write profile metadata")
      finally:
        lib.cmsMLUfree(mlu)
    size = C.c_uint32()
    if not lib.cmsSaveProfileToMem(profile, None, C.byref(size)):
      raise ProfileError("LittleCMS could not size the profile")
    buf = C.create_string_buffer(size.value)
    if not lib.cmsSaveProfileToMem(profile, buf, C.byref(size)):
      raise ProfileError("LittleCMS could not serialize the profile")
    result = bytearray(buf.raw[: size.value])
    # A fixed creation date makes identical source data produce identical files.
    result[24:36] = struct.pack(">6H", 2026, 11, 5, 0, 0, 0)
    return bytes(result)
  finally:
    if profile:
      lib.cmsCloseProfile(profile)
    for pointer in pointers:
      lib.cmsFreeToneCurve(pointer)


def atomic_write(path, content):
  path.parent.mkdir(parents=True, exist_ok=True)
  mode = (path.stat().st_mode & 0o777) if path.exists() else 0o644
  fd, temporary = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent)
  try:
    with os.fdopen(fd, "wb") as f:
      f.write(content)
      f.flush()
      os.fsync(f.fileno())
    os.chmod(temporary, mode)
    os.replace(temporary, path)
  finally:
    if os.path.exists(temporary):
      os.unlink(temporary)


def backup(path):
  if path.exists():
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    target = path.with_name(f"{path.name}.bak.{stamp}")
    shutil.copy2(path, target)
    print(f"Backup: {target}")


def managed_config(original, block):
  if BEGIN in original or END in original:
    if original.count(BEGIN) != 1 or original.count(END) != 1:
      raise ProfileError(
        "Malformed managed profile block; refusing to edit configuration"
      )
    pattern = re.compile(re.escape(BEGIN) + r"\n.*?" + re.escape(END) + r"\n?", re.S)
    updated, count = pattern.subn(lambda _: block, original)
    if count != 1:
      raise ProfileError("Malformed managed profile block")
    return updated
  return (
    original + ("\n" if original and not original.endswith("\n\n") else "") + block
    if block
    else original
  )


def monitor_block(monitor, profile, edid):
  # A new hl.monitor call replaces a matching rule. Carry over the current
  # mode, layout, scale and relevant SDR options instead of resetting them.
  fields = {
    "output": monitor["name"],
    "mode": f"{monitor['width']}x{monitor['height']}@{monitor['refreshRate']:.5f}",
    "position": f"{monitor['x']}x{monitor['y']}",
    "scale": monitor["scale"],
    "transform": monitor["transform"],
    "vrr": 1 if monitor.get("vrr") else 0,
    "icc": str(profile),
  }
  for source, target in [
    ("sdrBrightness", "sdrbrightness"),
    ("sdrSaturation", "sdrsaturation"),
    ("sdrMinLuminance", "sdr_min_luminance"),
    ("sdrMaxLuminance", "sdr_max_luminance"),
  ]:
    if source in monitor:
      fields[target] = monitor[source]
  if "2101010" in monitor.get("currentFormat", ""):
    fields["bitdepth"] = 10
  if monitor.get("mirrorOf", "none") != "none":
    fields["mirror"] = monitor["mirrorOf"]
  rows = [
    BEGIN,
    f"-- EDID SHA256: {hashlib.sha256(edid).hexdigest()}",
    "-- Derived from Apple's panel response data; generated by omarchy setup apple-display-profile.",
    "hl.monitor({",
  ]
  rows.extend(
    f"  {key} = {json.dumps(value, ensure_ascii=False)},"
    for key, value in fields.items()
  )
  rows.extend(["})", END, ""])
  return "\n".join(rows)


def install(config, updated, profile=None, content=None):
  changes = []
  for path, new in [(profile, content), (config, updated.encode())]:
    if path is not None:
      old = path.read_bytes() if path.exists() else None
      if new != old:
        changes.append((path, old, new))
  try:
    for path, old, new in changes:
      backup(path)
      atomic_write(path, new)
    response = hypr("reload")
    if response != "ok":
      raise ProfileError(f"Hyprland rejected reload: {response}")
    time.sleep(1)
    config_clean()
  except Exception:
    for path, old, new in reversed(changes):
      if path.exists() and path.read_bytes() != new:
        print(f"Concurrent edit detected; leaving {path} untouched.", file=sys.stderr)
        continue
      if old is None:
        path.unlink(missing_ok=True)
      else:
        atomic_write(path, old)
    try:
      hypr("reload")
    except ProfileError as exc:
      print(f"Rollback reload failed: {exc}", file=sys.stderr)
    raise


def main(argv=None):
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument(
    "--archive", type=Path, help="Local archive containing Apple panel overrides"
  )
  parser.add_argument(
    "--output", help="Internal connector to match (normally detected automatically)"
  )
  mode = parser.add_mutually_exclusive_group()
  mode.add_argument(
    "--dry-run", action="store_true", help="Validate and preview without writing files"
  )
  mode.add_argument(
    "--generate-only", type=Path, metavar="ICC", help="Write just the derived ICC file"
  )
  mode.add_argument(
    "--remove", action="store_true", help="Remove the managed monitor rule and reload"
  )
  args = parser.parse_args(argv)
  if os.geteuid() == 0:
    raise ProfileError("Run as your desktop user, without sudo.")
  config = None if args.generate_only else monitor_config()
  if args.remove:
    original = config.read_text() if config.exists() else ""
    config_clean()
    updated = managed_config(original, "")
    if updated == original:
      print("No managed display profile is installed.")
      return
    install(config, updated)
    print("Removed the managed display profile; Hyprland configuration is clean.")
    return

  if args.archive is None:
    parser.error("--archive is required unless --remove is used")
  name, vendor, product, data, raw, edid = matching_panel(args.archive, args.output)
  print(f"Matched {name}: Apple {vendor:04x}:{product:04x}")
  print(f"Apple override SHA256: {hashlib.sha256(raw).hexdigest()}")
  content = build_icc(data, product)
  print(
    f"Derived ICC: {len(content)} bytes; SHA256 {hashlib.sha256(content).hexdigest()}"
  )
  if args.generate_only:
    path = args.generate_only.expanduser().resolve()
    if not path.exists() or path.read_bytes() != content:
      backup(path)
      atomic_write(path, content)
    print(f"Generated {path}")
    return

  original = config.read_text() if config.exists() else ""
  config_clean()
  if "bool: true" not in hypr("getoption", "render:cm_enabled"):
    raise ProfileError(
      "Hyprland color management is disabled; enable render.cm_enabled first."
    )
  monitors = json.loads(hypr("-j", "monitors"))
  monitor = next(
    (m for m in monitors if m["name"] == name and not m.get("disabled")), None
  )
  if monitor is None:
    raise ProfileError(f"Matched panel {name} is not active in this Hyprland session")
  data_root = Path(os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share")))
  profile = (
    data_root / "color/icc" / f"Apple-{vendor:04x}-{product:04x}.icc"
  ).resolve()
  block = monitor_block(monitor, profile, edid)
  updated = managed_config(original, block)
  if args.dry_run:
    print(f"Would install {profile}\nWould update {config}\n\n{block}")
    return
  install(config, updated, profile, content)
  print(f"Applied {profile} to {name}; Hyprland configuration is clean.")
  print("The monitor rule persists across logins. Use --remove to undo it.")


if __name__ == "__main__":
  try:
    main()
  except (ProfileError, OSError, ValueError, KeyError, zipfile.BadZipFile) as exc:
    print(f"Error: {exc}", file=sys.stderr)
    sys.exit(1)
