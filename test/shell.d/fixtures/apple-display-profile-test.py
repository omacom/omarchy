"""Validate the actual ICC data, color transforms, and installer recovery."""

import contextlib
import ctypes as C
import importlib.util
import io
from pathlib import Path
import struct
import tempfile
import unittest
import plistlib
import zipfile
from unittest.mock import patch


spec = importlib.util.spec_from_file_location(
  "profile_installer",
  Path(__file__).resolve().parents[3] / "default/color/apple-display-profile.py",
)
app = importlib.util.module_from_spec(spec)
spec.loader.exec_module(app)


class DisplayProfileTests(unittest.TestCase):
  @classmethod
  def setUpClass(cls):
    cls.directory = tempfile.TemporaryDirectory()
    cls.addClassCleanup(cls.directory.cleanup)
    root = Path(cls.directory.name)
    cls.archive = root / "overrides.zip"
    cls.drm = root / "drm"
    connector = cls.drm / "card0-LVDS-1"
    connector.mkdir(parents=True)
    (connector / "status").write_text("connected\n")
    edid = bytearray(128)
    edid[:8] = b"\x00\xff\xff\xff\xff\xff\xff\x00"
    edid[8:10] = bytes.fromhex("0610")
    edid[10:12] = bytes.fromhex("a39c")
    edid[-1] = -sum(edid) % 256
    (connector / "edid").write_bytes(edid)
    # Synthetic sRGB primaries and curves; no Apple characterization data.
    data = dict(
      DisplayVendorID=0x0610,
      DisplayProductID=0x9CA3,
      DisplayGammaChannels=3,
      DisplayGammaEntryCount=256,
      DisplayGammaEntrySize=2,
      DisplayGammaTable=struct.pack(
        ">768H", *([round((i / 255) ** 2.2 * 65535) for i in range(256)] * 3)
      ),
    )
    for channel, (x, y) in {
      "Red": (0.64, 0.33),
      "Green": (0.30, 0.60),
      "Blue": (0.15, 0.06),
      "White": (0.3127, 0.3290),
    }.items():
      data[f"Display{channel}PointX"] = x
      data[f"Display{channel}PointY"] = y
    with zipfile.ZipFile(cls.archive, "w") as z:
      z.writestr("local/display/DisplayProductID-9ca3", plistlib.dumps(data))
    cls.drm_patch = patch.object(app, "DRM_ROOT", cls.drm)
    cls.drm_patch.start()
    cls.addClassCleanup(cls.drm_patch.stop)
    cls.panel = app.matching_panel(cls.archive)
    cls.icc = app.build_icc(cls.panel[3], cls.panel[2])

  def test_matching_panel_and_reject_wrong_connector(self):
    self.assertEqual(self.panel[1:3], (0x0610, 0x9CA3))
    with self.assertRaises(app.ProfileError):
      app.matching_panel(self.archive, "HDMI-A-999")

  def test_generate_only_needs_no_hyprland_config(self):
    with (
      tempfile.TemporaryDirectory() as directory,
      patch.object(app.os, "geteuid", return_value=1000),
      patch.object(app, "hypr", side_effect=AssertionError("No session needed")),
      patch.dict(
        app.os.environ, {"XDG_CONFIG_HOME": str(Path(directory) / "no-config")}
      ),
      contextlib.redirect_stdout(io.StringIO()),
    ):
      target = Path(directory) / "profile.icc"
      app.main(["--archive", str(self.archive), "--generate-only", str(target)])
      self.assertEqual(target.read_bytes(), self.icc)

  def test_rejects_unloaded_config_before_writing(self):
    with (
      tempfile.TemporaryDirectory() as directory,
      patch.object(app.os, "geteuid", return_value=1000),
      patch.object(app, "hypr", side_effect=AssertionError("No reload expected")),
      patch.dict(app.os.environ, {"XDG_CONFIG_HOME": str(Path(directory) / "custom")}),
      contextlib.redirect_stdout(io.StringIO()),
    ):
      for mode in ([], ["--dry-run"], ["--remove"]):
        with (
          self.subTest(mode=mode),
          self.assertRaisesRegex(app.ProfileError, "XDG_CONFIG_HOME"),
        ):
          app.main(["--archive", str(self.archive), *mode])
      self.assertEqual(list(Path(directory).iterdir()), [])

  def test_rejects_root_before_generating(self):
    with (
      tempfile.TemporaryDirectory() as directory,
      patch.object(app.os, "geteuid", return_value=0),
    ):
      target = Path(directory) / "profile.icc"
      with self.assertRaisesRegex(app.ProfileError, "desktop user"):
        app.main(["--archive", str(self.archive), "--generate-only", str(target)])
      self.assertFalse(target.exists())

  def test_exact_tables_and_valid_header(self):
    icc = self.icc
    self.assertEqual(struct.unpack_from(">I", icc)[0], len(icc))
    self.assertEqual(icc[12:24], b"mntrRGB XYZ ")
    self.assertEqual(icc[36:40], b"acsp")
    tags = {}
    for i in range(struct.unpack_from(">I", icc, 128)[0]):
      sig, offset, size = struct.unpack_from(">4sII", icc, 132 + i * 12)
      self.assertLessEqual(offset + size, len(icc))
      tags[sig] = icc[offset : offset + size]
    raw = self.panel[3]["DisplayGammaTable"]
    for i, name in enumerate([b"rTRC", b"gTRC", b"bTRC"]):
      self.assertEqual(tags[name][:4], b"curv")
      self.assertEqual(struct.unpack_from(">I", tags[name], 8)[0], 256)
      self.assertEqual(tags[name][12:], raw[i * 512 : (i + 1) * 512])
    self.assertNotIn(b"vcgt", tags)

  def test_color_transform_and_d50_white(self):
    lib = app.littlecms()
    signatures = {
      "cmsOpenProfileFromMem": ([C.c_void_p, C.c_uint32], C.c_void_p),
      "cmsCreateXYZProfile": ([], C.c_void_p),
      "cmsCreate_sRGBProfile": ([], C.c_void_p),
      "cmsCreateTransform": (
        [C.c_void_p, C.c_uint32, C.c_void_p, C.c_uint32, C.c_uint32, C.c_uint32],
        C.c_void_p,
      ),
      "cmsDoTransform": ([C.c_void_p, C.c_void_p, C.c_void_p, C.c_uint32], None),
      "cmsDeleteTransform": ([C.c_void_p], None),
    }
    for name, (args, result) in signatures.items():
      getattr(lib, name).argtypes, getattr(lib, name).restype = args, result
    rgb_double = (1 << 22) | (4 << 16) | (3 << 3)
    xyz_double = (1 << 22) | (9 << 16) | (3 << 3)
    buf = C.create_string_buffer(self.icc)
    display = lib.cmsOpenProfileFromMem(buf, len(self.icc))
    xyz, srgb = lib.cmsCreateXYZProfile(), lib.cmsCreate_sRGBProfile()
    self.assertTrue(display)
    transforms = []
    try:
      device_xyz = lib.cmsCreateTransform(display, rgb_double, xyz, xyz_double, 1, 0)
      srgb_device = lib.cmsCreateTransform(srgb, rgb_double, display, rgb_double, 1, 0)
      srgb_xyz = lib.cmsCreateTransform(srgb, rgb_double, xyz, xyz_double, 1, 0)
      transforms = [device_xyz, srgb_device, srgb_xyz]
      self.assertTrue(all(transforms))

      def transform(handle, values):
        result = (C.c_double * 3)()
        lib.cmsDoTransform(handle, (C.c_double * 3)(*values), result, 1)
        return tuple(result)

      for actual, expected in zip(
        transform(device_xyz, (1, 1, 1)), (0.9642, 1.0, 0.8249)
      ):
        self.assertAlmostEqual(actual, expected, delta=0.0002)
      self.assertTrue(all(abs(v) < 0.00001 for v in transform(device_xyz, (0, 0, 0))))
      for rgb in [(0.25, 0.25, 0.25), (0.5, 0.5, 0.5), (0.75, 0.4, 0.3)]:
        device = transform(srgb_device, rgb)
        actual, expected = transform(device_xyz, device), transform(srgb_xyz, rgb)
        for a, e in zip(actual, expected):
          self.assertAlmostEqual(a, e, delta=0.001)
    finally:
      for handle in transforms:
        if handle:
          lib.cmsDeleteTransform(handle)
      for handle in (display, xyz, srgb):
        if handle:
          lib.cmsCloseProfile(handle)

  def test_generation_is_deterministic_and_rejects_bad_curve(self):
    self.assertEqual(self.icc, app.build_icc(self.panel[3], self.panel[2]))
    invalid = dict(self.panel[3], DisplayGammaTable=b"broken")
    with self.assertRaises(app.ProfileError):
      app.build_icc(invalid, self.panel[2])

  def test_managed_block_replacement_and_removal(self):
    original = '-- Custom layout\nhl.env("GDK_SCALE", "2")\n\n'
    block = f"{app.BEGIN}\nhl.monitor({{}})\n{app.END}\n"
    installed = app.managed_config(original, block)
    self.assertEqual(app.managed_config(installed, block), installed)
    self.assertEqual(app.managed_config(installed, ""), original)
    with self.assertRaises(app.ProfileError):
      app.managed_config(app.BEGIN, block)

  def test_failed_reload_restores_config_and_profile(self):
    with tempfile.TemporaryDirectory() as directory:
      config, profile = Path(directory) / "monitors.lua", Path(directory) / "panel.icc"
      config.write_bytes(b"original config\n")
      profile.write_bytes(b"original ICC")
      with (
        patch.object(app, "hypr", side_effect=["ok", "deliberate config error", "ok"]),
        patch.object(app.time, "sleep"),
        contextlib.redirect_stdout(io.StringIO()),
      ):
        with self.assertRaises(app.ProfileError):
          app.install(config, "changed config\n", profile, b"changed ICC")
      self.assertEqual(config.read_bytes(), b"original config\n")
      self.assertEqual(profile.read_bytes(), b"original ICC")
      self.assertEqual(len(list(Path(directory).glob("*.bak.*"))), 2)

  def test_repeat_install_does_not_rewrite_files(self):
    with tempfile.TemporaryDirectory() as directory:
      config, profile = Path(directory) / "monitors.lua", Path(directory) / "panel.icc"
      config.write_bytes(b"config\n")
      profile.write_bytes(self.icc)
      timestamps = (config.stat().st_mtime_ns, profile.stat().st_mtime_ns)
      with (
        patch.object(app, "hypr", side_effect=["ok", ""]),
        patch.object(app.time, "sleep"),
      ):
        app.install(config, "config\n", profile, self.icc)
      self.assertEqual(
        timestamps, (config.stat().st_mtime_ns, profile.stat().st_mtime_ns)
      )
      self.assertFalse(list(Path(directory).glob("*.bak.*")))


if __name__ == "__main__":
  unittest.main()
