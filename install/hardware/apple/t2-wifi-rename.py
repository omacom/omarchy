# Extracted from the t2linux firmware tool so a wiped T2 Mac can rename
# Apple's firmware tree into the names brcmfmac requests. The blobs themselves
# are not shipped here.
#
# Copyright (C) 2024 Aditya Garg <gargaditya08@live.com>
# Copyright (C) 2024 Orlando Chamberlain <redecorating@protonmail.com>
# Copyright (C) 2024 Sharpened Blade <sharpenedblade@proton.me>
# The python script is based upon the original work by The Asahi Linux Contributors.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# SPDX-License-Identifier: MIT
import logging, os, os.path, re, sys, pprint, statistics, tarfile, io
from collections import namedtuple, defaultdict
from hashlib import sha256
from pathlib import Path

log = logging.getLogger("asahi_firmware.bluetooth")

BluetoothChip = namedtuple(
  "BluetoothChip", ("chip", "stepping", "board_type", "vendor")
)


class BluetoothFWCollection(object):
  VENDORMAP = {
    "MUR": "m",
    "USI": "u",
    "GEN": None,
  }
  STRIP_SUFFIXES = [
    "ES2"
  ]

  def __init__(self, source_path):
    self.fwfiles = defaultdict(lambda: [None, None])
    self.load(source_path)

  def load(self, source_path):
    for fname in os.listdir(source_path):
      root, ext = os.path.splitext(fname)

      # index for bin and ptb inside self.fwfiles
      if ext == ".bin":
        idx = 0
      elif ext == ".ptb":
        idx = 1
      else:
        # skip firmware for older (UART) chips
        continue

      # skip T2 _DEV firmware
      if "_DEV" in root:
        continue

      chip = self.parse_fname(root)
      if chip is None:
        continue

      if self.fwfiles[chip][idx] is not None:
        log.warning(f"duplicate entry for {chip}: {self.fwfiles[chip][idx].name} and now {fname + ext}")
        continue

      path = os.path.join(source_path, fname)
      with open(path, "rb") as f:
        data = f.read()

      self.fwfiles[chip][idx] = FWFile(fname, data)

  def parse_fname(self, fname):
    fname = fname.split("_")

    match = re.fullmatch("bcm(43[0-9]{2})([a-z][0-9])", fname[0].lower())
    if not match:
      log.warning(f"Unexpected firmware file: {fname}")
      return None
    chip, stepping = match.groups()

    # board type is either preceded by PCIE_macOS or by PCIE
    try:
      pcie_offset = fname.index("PCIE")
    except:
      log.warning(f"Can't find board type in {fname}")
      return None

    if fname[pcie_offset + 1] == "macOS":
      board_type = fname[pcie_offset + 2]
    else:
      board_type = fname[pcie_offset + 1]
    for i in self.STRIP_SUFFIXES:
      board_type = board_type.rstrip(i)
    board_type = "apple," + board_type.lower()

    # make sure we can identify exactly one vendor
    otp_values = set()
    for vendor, otp_value in self.VENDORMAP.items():
      if vendor in fname:
        otp_values.add(otp_value)
    if len(otp_values) != 1:
      log.warning(f"Unable to determine vendor ({otp_values}) in {fname}")
      return None
    vendor = otp_values.pop()

    return BluetoothChip(
      chip=chip, stepping=stepping, board_type=board_type, vendor=vendor
    )

  def files(self):
    for chip, (bin, ptb) in self.fwfiles.items():
      fname_base = f"brcmbt{chip.chip}{chip.stepping}-{chip.board_type}"
      if chip.vendor is not None:
        fname_base += f"-{chip.vendor}"

      if bin is None:
        log.warning(f"no bin for {chip}")
        continue
      else:
        yield fname_base + ".bin", bin

      if ptb is None:
        log.warning(f"no ptb for {chip}")
        continue
      else:
        yield fname_base + ".ptb", ptb

log = logging.getLogger("asahi_firmware.wifi")

class FWNode(object):
  def __init__(self, this=None, leaves=None):
    if leaves is None:
      leaves = {}
    self.this = this
    self.leaves = leaves

  def __eq__(self, other):
    return self.this == other.this and self.leaves == other.leaves

  def __hash__(self):
    return hash((self.this, tuple(self.leaves.items())))

  def __repr__(self):
    return f"FWNode({self.this!r}, {self.leaves!r})"

  def print(self, depth=0, tag=""):
    print(f"{'  ' * depth} * {tag}: {self.this or ''} ({hash(self)})")
    for k, v in self.leaves.items():
      v.print(depth + 1, k)

class WiFiFWCollection(object):
  EXTMAP = {
    "trx": "bin",
    "txt": "txt",
    "clmb": "clm_blob",
    "txcb": "txcap_blob",
  }
  DIMS = ["C", "s", "P", "M", "V", "m", "A"]
  def __init__(self, source_path):
    self.root = FWNode()
    self.load(source_path)
    self.prune()

  def load(self, source_path):
    included_folders = ["C-4355__s-C1", "C-4364__s-B2", "C-4364__s-B3", "C-4377__s-B3"]
    for dirpath, dirnames, filenames in os.walk(source_path):
      dirnames[:] = [d for d in dirnames if d in included_folders]
      if "perf" in dirnames:
        dirnames.remove("perf")
      if "assert" in dirnames:
        dirnames.remove("assert")
      subpath = os.path.relpath(dirpath, source_path)
      for name in sorted(filenames):
        if not any(name.endswith("." + i) for i in self.EXTMAP):
          continue
        path = os.path.join(dirpath, name)
        relpath = os.path.join(subpath, name)
        if not name.endswith(".txt"):
          name = "P-" + name
        idpath, ext = os.path.join(subpath, name).rsplit(".", 1)
        props = {}
        for i in idpath.replace("/", "_").split("_"):
          if not i:
            continue
          k, v = i.split("-", 1)
          if k == "P" and "-" in v:
            plat, ant = v.split("-", 1)
            props["P"] = plat
            props["A"] = ant
          else:
            props[k] = v
        ident = [ext]
        for dim in self.DIMS:
          if dim in props:
            ident.append(props.pop(dim))

        if props:
          log.error(f"Unhandled properties found: {props} in file {relpath}")

        assert not props

        node = self.root
        for k in ident:
          node = node.leaves.setdefault(k, FWNode())
        with open(path, "rb") as fd:
          data = fd.read()

        if name.endswith(".txt"):
          data = self.process_nvram(data)

        node.this = FWFile(relpath, data)

  def prune(self, node=None, depth=0):
    if node is None:
      node = self.root

    for i in node.leaves.values():
      self.prune(i, depth + 1)

    if node.this is None and node.leaves and depth > 3:
      first = next(iter(node.leaves.values()))
      if all(i == first for i in node.leaves.values()):
        node.this = first.this

    for i in node.leaves.values():
      if not i.this or not node.this:
        break
      if i.this != node.this:
        break
    else:
      node.leaves = {}

  def _walk_files(self, node, ident):
    if node.this is not None:
      yield ident, node.this
    for k, subnode in node.leaves.items():
      yield from self._walk_files(subnode, ident + [k])

  def files(self):
    for ident, fwfile in self._walk_files(self.root, []):
      (ext, chip, rev), rest = ident[:3], ident[3:]
      rev = rev.lower()
      ext = self.EXTMAP[ext]

      if rest:
        rest = "," + "-".join(rest)
      else:
        rest = ""
      filename = f"brcmfmac{chip}{rev}-pcie.apple{rest}.{ext}"

      yield filename, fwfile

  def process_nvram(self, data):
    data = data.decode("ascii")
    keys = {}
    lines = []
    for line in data.split("\n"):
      if not line:
        continue
      key, value = line.split("=", 1)
      keys[key] = value
      # Clean up spurious whitespace that Linux does not like
      lines.append(f"{key.strip()}={value}\n")

    return "".join(lines).encode("ascii")

  def print(self):
    self.root.print()

class FWFile(object):
  def __init__(self, name, data):
    self.name = name
    self.data = data
    self.sha = sha256(data).hexdigest()

  def __repr__(self):
    return f"FWFile({self.name!r}, <{self.sha[:16]}>)"

  def __eq__(self, other):
    if other is None:
      return False
    return self.sha == other.sha

  def __hash__(self):
    return hash(self.sha)

class FWPackage(object):
  def __init__(self, target):
    self.path = target
    self.tarfile = tarfile.open(target, mode="w")
    self.hashes = {}
    self.manifest = []

  def close(self):
    self.tarfile.close()

  def add_file(self, name, data):
    ti = tarfile.TarInfo(name)
    fd = None
    if data.sha in self.hashes:
      ti.type = tarfile.LNKTYPE
      ti.linkname = self.hashes[data.sha]
      self.manifest.append(f"LINK {name} {ti.linkname}")
    else:
      ti.type = tarfile.REGTYPE
      ti.size = len(data.data)
      fd = io.BytesIO(data.data)
      self.hashes[data.sha] = name
      self.manifest.append(f"FILE {name} SHA256 {data.sha}")

    logging.info(f"+ {self.manifest[-1]}")
    self.tarfile.addfile(ti, fd)

  def add_files(self, it):
    for name, data in it:
      self.add_file(name, data)

  def save_manifest(self, filename):
    with open(filename, "w") as fd:
      for i in self.manifest:
        fd.write(i + "\n")

  def __del__(self):
    self.tarfile.close()

logging.getLogger().setLevel(logging.WARNING if (len(sys.argv) >= 4 and sys.argv[3] == "-v") else logging.ERROR)

pkg = FWPackage(sys.argv[2])
wifi_col = WiFiFWCollection(sys.argv[1]+"/wifi")
pkg.add_files(sorted(wifi_col.files()))
if not Path(sys.argv[1] + "/bluetooth").exists():
  log.warning("\nBluetooth firmware missing.\n\nThe source of the firmware is likely macOS Big Sur or earlier. Therefore, only Wi-Fi firmware shall be extracted.\nBluetooth firmware is needed only for MacBookPro15,4, MacBookPro16,3 and MacBookAir9,1. So, you can ignore this message if you do not have these Macs.\n")
else:
  bt_col = BluetoothFWCollection(sys.argv[1]+"/bluetooth")
  pkg.add_files(sorted(bt_col.files()))
pkg.close()