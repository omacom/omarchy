#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python <<'PY'
import os
from pathlib import Path
import runpy
import subprocess
import tempfile

import cairo

root = Path(os.environ["ROOT"])
module = runpy.run_path(str(root / "default/image-print/print.py"))
GdkPixbuf = module["GdkPixbuf"]

# Portrait and landscape images fit the page, with white margins and no distortion.
for image_width, image_height in [(800, 400), (400, 800)]:
  pixbuf = GdkPixbuf.Pixbuf.new(GdkPixbuf.Colorspace.RGB, False, 8, image_width, image_height)
  pixbuf.fill(0x4287f5ff)
  surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, 600, 800)
  context = cairo.Context(surface)
  context.set_source_rgb(1, 1, 1)
  context.paint()
  module["draw_image"](context, pixbuf, 600, 800)
  surface.flush()
  pixels = surface.get_data()
  def pixel(x, y):
    offset = y * surface.get_stride() + x * 4
    return bytes(pixels[offset:offset + 4])
  assert pixel(300, 400) != b"\xff\xff\xff\xff"
  assert pixel(0, 0) == b"\xff\xff\xff\xff"
  if image_width > image_height:
    assert pixel(300, 249) == b"\xff\xff\xff\xff"
    assert pixel(300, 251) != b"\xff\xff\xff\xff"
  else:
    assert pixel(99, 400) == b"\xff\xff\xff\xff"
    assert pixel(101, 400) != b"\xff\xff\xff\xff"

with tempfile.TemporaryDirectory() as directory:
  scratch = Path(directory)
  fake_bin = scratch / "bin"
  fake_bin.mkdir()
  helper = fake_bin / "omarchy-pkg-add"
  helper.write_text("#!/bin/bash\nexit 0\n")
  helper.chmod(0o755)
  migration = root / "migrations/1788662350.sh"
  shipped = '<Ctrl+p> = exec lp "$imv_current_file"'
  replacement = next(line for line in (root / "config/imv/config").read_text().splitlines() if line.startswith("<Ctrl+p>"))
  for binding in [shipped, '<Ctrl+p> = exec my-custom-printer "$imv_current_file"']:
    home = scratch / ("stock" if binding == shipped else "custom")
    config = home / ".config/imv/config"
    config.parent.mkdir(parents=True)
    config.write_text("[binds]\n" + binding + "\nx = close\n")
    env = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(root), PATH=str(fake_bin) + ":" + os.environ["PATH"])
    for _ in range(2):
      subprocess.run(["bash", "-euo", "pipefail", str(migration)], env=env, check=True, stdout=subprocess.DEVNULL)
    assert config.read_text() == "[binds]\n" + (replacement if binding == shipped else binding) + "\nx = close\n"
    assert (home / ".local/share/nautilus-python/extensions/print_picture.py").is_file()
    assert len(list(config.parent.glob("config.bak.*"))) == (1 if binding == shipped else 0)

  # The shell must return immediately, including when its output is captured.
  launcher = fake_bin / "omarchy-launch-image-print"
  launcher.write_text('#!/bin/bash\nsleep 2\n')
  launcher.chmod(0o755)
  command = replacement.split(" = exec ", 1)[1]
  subprocess.run(command, shell=True, env=dict(os.environ, PATH=str(fake_bin) + ":" + os.environ["PATH"], imv_current_file="/tmp/a picture.png"), capture_output=True, timeout=1, check=True)
PY

# Nautilus uses GTK 4; test its provider in a separate process from GTK 3 printing.
python <<'PY'
import os
from pathlib import Path
import runpy
module = runpy.run_path(str(Path(os.environ["ROOT"]) / "default/nautilus-python/extensions/print_picture.py"), run_name="print_picture")
Gio = module["Gio"]
class File:
  def __init__(self, mime, uri="file:///tmp/a%20picture.png", directory=False):
    self.mime, self.uri, self.directory = mime, uri, directory
  def get_location(self): return Gio.File.new_for_uri(self.uri)
  def get_mime_type(self): return self.mime
  def is_directory(self): return self.directory
provider = module["PrintPictureExtension"]()
assert provider.get_file_items([File("image/png")])[0].props.label == "Print…"
for files in [[], [File("text/plain")], [File("image/png", directory=True)], [File("image/png", "sftp://example.com/a.png")], [File("image/png"), File("image/jpeg")]]:
  assert not provider.get_file_items(files)
PY

pass "picture printing fits images, preserves custom bindings, detaches from imv, and filters the Files action"
