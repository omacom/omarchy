#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Exercise the actual MMIO save/restore logic on a regular file standing in
# for resource0. No root, real PCI device, or sleep transition is touched.
python3 - "$ROOT/default/apple/macbook81-lpss.py" <<'PY'
import importlib.util
import pathlib
import struct
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True

spec = importlib.util.spec_from_file_location("macbook81_lpss", sys.argv[1])
lpss = importlib.util.module_from_spec(spec)
spec.loader.exec_module(lpss)


class LPSSRecovery(unittest.TestCase):
    def test_reject_other_pci_function(self):
        with tempfile.TemporaryDirectory() as work:
            with self.assertRaisesRegex(ValueError, "unrecognized LPSS controller"):
                lpss.process("save", "0000:00:15.5", pathlib.Path(work) / "snap")

    def test_reject_malformed_snapshot_before_opening_pci(self):
        with tempfile.TemporaryDirectory() as work:
            snapshot = pathlib.Path(work) / "snap"
            snapshot.write_text("12345678 00000003\n")
            with self.assertRaisesRegex(ValueError, "invalid LPSS register snapshot"):
                lpss.process("restore", lpss.SPI_PCI, snapshot)

    def test_reject_inactive_controller(self):
        with tempfile.TemporaryDirectory() as work:
            resource = pathlib.Path(work) / lpss.SPI_PCI / "resource0"
            resource.parent.mkdir(parents=True)
            resource.write_bytes(bytes(4096))
            with self.assertRaisesRegex(ValueError, "controller not active"):
                lpss.process("save", lpss.SPI_PCI, pathlib.Path(work) / "snap", work)

    def test_full_save_and_restore(self):
        with tempfile.TemporaryDirectory() as work:
            resource = pathlib.Path(work) / lpss.SPI_PCI / "resource0"
            resource.parent.mkdir(parents=True)
            raw = bytearray(4096)
            values = [0x80190005, 3, 0, 0, 0x800, 0x800, 3, 0, 0]
            for offset, value in zip(lpss.OFFSETS, values):
                struct.pack_into("<I", raw, offset, value)
            resource.write_bytes(raw)
            snapshot = pathlib.Path(work) / "snap"
            self.assertEqual(lpss.process("save", lpss.SPI_PCI, snapshot, work), values)
            self.assertEqual(lpss.read_snapshot(snapshot), values)
            resource.write_bytes(bytes(4096))
            self.assertEqual(lpss.process("restore", lpss.SPI_PCI, snapshot, work), values)
            restored = resource.read_bytes()
            self.assertEqual([struct.unpack_from("<I", restored, o)[0] for o in lpss.OFFSETS], values)


if __name__ == "__main__":
    unittest.main(argv=[sys.argv[0]])
PY

pass "MacBook8,1 LPSS MMIO validation, save, and restore"
