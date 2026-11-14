"""Build private ASCII menu specimens; see --help and the adjacent README."""

import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import tarfile
from urllib.request import urlopen

from fontTools import subset
from fontTools.ttLib import TTFont

DESTINATION = Path(__file__).resolve().parent


def download(url):
  with urlopen(url, timeout=60) as response:
    return response.read()


def source_data(source):
  data = download(source["url"])
  if "archiveMember" in source:
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:*") as archive:
      # Read named members only; never extract archive paths to disk.
      return (archive.extractfile(source["archiveMember"]).read(),
              archive.extractfile(source["licenseMember"]).read())
  return data, download(source["licenseUrl"])


def build_preview(data, family):
  font = TTFont(io.BytesIO(data), recalcTimestamp=False)
  if font.sfntVersion != "\x00\x01\x00\x00" or "fvar" in font:
    raise ValueError("Use a static TrueType regular-weight font")
  original_family = font["name"].getDebugName(16) or font["name"].getDebugName(1)
  if not set(range(32, 127)).issubset(font.getBestCmap()):
    raise ValueError("Source font must cover printable ASCII")
  options = subset.Options()
  options.name_IDs = ["*"]
  options.name_legacy = True
  options.name_languages = ["*"]
  subsetter = subset.Subsetter(options=options)
  subsetter.populate(unicodes=range(32, 127))
  subsetter.subset(font)
  # Private names avoid shadowing complete fonts and respect reserved names.
  names = {1: family, 2: "Regular", 3: family + " Regular", 4: family + " Regular",
           6: family.replace(" ", "") + "-Regular", 16: family, 17: "Regular"}
  for record in font["name"].names:
    if record.nameID in names:
      record.string = names[record.nameID].encode(record.getEncoding())
  output = io.BytesIO()
  font.save(output)
  if len(output.getvalue()) >= 100000:
    raise ValueError("Preview exceeds the menu's 100 KB budget")
  return output.getvalue(), original_family


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  commands = parser.add_subparsers(dest="command")
  add = commands.add_parser("add", help="Add one font from pinned direct font/license URLs")
  add.add_argument("key", help="Menu option suffix, e.g. example-mono")
  add.add_argument("--font-url", required=True)
  add.add_argument("--license-url", required=True)
  add.add_argument("--font", type=Path, help="Use a local full font instead of downloading it")
  add.add_argument("--license", type=Path, help="Use a local license instead of downloading it")
  rebuild = commands.add_parser("rebuild", help="Rebuild all specimens or selected keys")
  rebuild.add_argument("keys", nargs="*")
  args = parser.parse_args()
  manifest_path = DESTINATION / "sources.json"
  manifest = json.loads(manifest_path.read_text())
  if args.command == "add":
    if not re.fullmatch(r"[a-z][a-z0-9-]*", args.key):
      parser.error("key must contain lowercase letters, digits and hyphens")
    if args.key in manifest:
      parser.error("key already exists; use rebuild or edit its source record")
    if not all(url.startswith("https://") for url in (args.font_url, args.license_url)):
      parser.error("provenance URLs must use HTTPS")
    family = "Omarchy Preview " + args.key
    source = {"url": args.font_url, "licenseUrl": args.license_url, "previewFamily": family}
    data = args.font.read_bytes() if args.font else download(args.font_url)
    license_data = args.license.read_bytes() if args.license else download(args.license_url)
    inputs = [(args.key, source, data, license_data)]
  else:
    keys = args.keys if args.command == "rebuild" and args.keys else list(manifest)
    if any(key not in manifest for key in keys):
      parser.error("unknown specimen key")
    inputs = [(key, manifest[key], *source_data(manifest[key])) for key in keys]
  for key, source, data, license_data in inputs:
    digest = hashlib.sha256(data).hexdigest()
    if source.get("sourceSha256", digest) != digest:
      raise ValueError(f"{key}: source hash changed; review upstream before updating sourceSha256")
    if not license_data.strip():
      raise ValueError(f"{key}: empty license")
    preview, original_family = build_preview(data, source["previewFamily"])
    (DESTINATION / f"{key}.ttf").write_bytes(preview)
    (DESTINATION / f"{key}.LICENSE").write_bytes(license_data)
    source.update(sourceSha256=digest, sourceFamily=original_family)
    manifest[key] = source
    print(f'{key}: {len(preview)} bytes')
    print(json.dumps({"previewFont": original_family,
                      "previewFontFile": f"default/fonts/previews/{key}.ttf"}))
  manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
  main()
