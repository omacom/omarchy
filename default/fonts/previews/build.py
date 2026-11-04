"""Regenerate menu specimens: uv run --with fonttools==4.60.1 python build.py."""

import hashlib
import io
import json
from pathlib import Path
import tarfile
from urllib.parse import quote
from urllib.request import urlopen

from fontTools import subset
from fontTools.ttLib import TTFont

VERSION = "v3.4.0"
BASE = f"https://raw.githubusercontent.com/ryanoasis/nerd-fonts/{VERSION}/patched-fonts/"
SOURCES = {
  "cascadia": ("CascadiaMono.tar.xz", "CaskaydiaMonoNerdFont-Regular.ttf", "LICENSE"),
  "meslo": ("Meslo/L/Regular/", "MesloLGLNerdFont-Regular.ttf", "LICENSE.txt"),
  "fira": ("FiraCode/Regular/", "FiraCodeNerdFont-Regular.ttf", "LICENSE"),
  "victor": ("VictorMono/Regular/", "VictorMonoNerdFont-Regular.ttf", "LICENSE.txt"),
  "bitstream": ("BitstreamVeraSansMono/Regular/", "BitstromWeraNerdFont-Regular.ttf", "Bitstream Vera License.txt"),
  "iosevka": ("Iosevka/", "IosevkaNerdFontMono-Regular.ttf", "LICENSE.md"),
}


def download(url):
  with urlopen(url, timeout=60) as response:
    return response.read()


def build():
  destination = Path(__file__).resolve().parent
  manifest = {}
  for number, (key, (directory, filename, license_name)) in enumerate(SOURCES.items(), 1):
    if directory.endswith(".tar.xz"):
      url = f"https://github.com/ryanoasis/nerd-fonts/releases/download/{VERSION}/{directory}"
      with tarfile.open(fileobj=io.BytesIO(download(url)), mode="r:xz") as archive:
        # Read named members only; never extract archive paths to disk.
        data = archive.extractfile(filename).read()
        license_data = archive.extractfile(license_name).read()
    else:
      url = BASE + quote(directory + filename)
      data = download(url)
      license_data = download(BASE + quote(directory + license_name))

    font = TTFont(io.BytesIO(data), recalcTimestamp=False)
    original_family = font["name"].getDebugName(16) or font["name"].getDebugName(1)
    options = subset.Options()
    options.name_IDs = ["*"]
    options.name_legacy = True
    options.name_languages = ["*"]
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=range(32, 127))
    subsetter.subset(font)
    # Modified fonts need distinct names, both for license compliance and to
    # prevent these ASCII-only specimens shadowing installed, complete fonts.
    family = "Omarchy Preview " + str(number)
    names = {1: family, 2: "Regular", 3: family + " Regular", 4: family + " Regular",
             6: "OmarchyPreview" + str(number) + "-Regular", 16: family, 17: "Regular"}
    for record in font["name"].names:
      if record.nameID in names:
        record.string = names[record.nameID].encode(record.getEncoding())
    font.save(destination / f"{key}.ttf")
    (destination / f"{key}.LICENSE").write_bytes(license_data)
    manifest[key] = {"url": url, "sourceSha256": hashlib.sha256(data).hexdigest(),
                     "sourceFamily": original_family, "previewFamily": family}
    print(key, (destination / f"{key}.ttf").stat().st_size)
  (destination / "sources.json").write_text(json.dumps(manifest, indent=2) + "\n")
  (destination / "APACHE-2.0.txt").write_bytes(download("https://www.apache.org/licenses/LICENSE-2.0.txt"))


if __name__ == "__main__":
  build()
