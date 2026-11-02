#!/usr/bin/env python3
"""Regenerate the N0B shader palette. Requires Pillow (python-pillow)."""

import argparse
import hashlib
from pathlib import Path
from urllib.request import urlopen
import xml.etree.ElementTree as ET

from PIL import Image, PngImagePlugin


REVISION = "99b2b6e452bb08471cd1cf7a5f60d61668997976"
SOURCE = f"https://raw.githubusercontent.com/akrherz/iem/{REVISION}/scripts/ridge/ReflectivityColorCurveManager.xml"
SOURCE_SHA256 = "85b019d623188d96fe67846acf043ee03a374830495167e808493e8b4d976af1"
OUTPUT = Path(__file__).resolve().parents[1] / "shell/plugins/panels/weather/n0b-palette.png"


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("--output", type=Path, default=OUTPUT)
  args = parser.parse_args()
  with urlopen(SOURCE, timeout=30) as response:
    source = response.read()
  if hashlib.sha256(source).hexdigest() != SOURCE_SHA256:
    raise ValueError("The pinned IEM color curve checksum does not match")

  levels = []
  for level in ET.fromstring(source):
    rgb = tuple(int(level.findtext(channel)) for channel in ("red", "green", "blue"))
    lower = float(level.attrib.get("lowerValue", level.attrib.get("upperValue")))
    upper = float(level.attrib.get("upperValue", lower))
    levels.append((lower, upper, rgb))

  unique = {}
  for lower, upper, rgb in sorted(levels, key=lambda level: level[0]):
    unique.setdefault(rgb, (lower + upper) / 2)
  image = Image.new("RGB", (len(unique), 2))
  for index, (rgb, dbz) in enumerate(unique.items()):
    image.putpixel((index, 0), rgb)
    encoded = dbz + 32
    whole = int(encoded)
    image.putpixel((index, 1), (whole, round((encoded - whole) * 255), 0))

  metadata = PngImagePlugin.PngInfo()
  # Preserve the original metadata so regeneration keeps the committed bytes.
  metadata.add_text("Source", "https://github.com/akrherz/iem/blob/main/scripts/ridge/ReflectivityColorCurveManager.xml")
  metadata.add_text("Encoding", "Top row: unique N0B RGB; bottom row: dBZ = R + G/255 - 32. Duplicate white uses the 60 dBZ interval.")
  image.save(args.output, pnginfo=metadata)


if __name__ == "__main__":
  main()
