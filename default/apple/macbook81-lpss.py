#!/usr/bin/python3
"""MacBook8,1 SPI LPSS private register snapshot and restore for deep/S3.

Only GSPI 0000:00:15.4 is permitted. The caller must gate the host DMI model,
sleep mode and PIO kernel workaround before invoking this MMIO operation.

Implementation adapted from the independently written MacBook8,1 Omarchy PoC.
Hardware behavior was validated using that PoC, not this extracted package.
See https://github.com/tvpittner/macbook8-1-fedora for prior register analysis.
"""

import mmap
import os
import pathlib
import struct
import sys

SPI_PCI = "0000:00:15.4"
OFFSETS = tuple(range(0x800, 0x824, 4))


def read_snapshot(blob):
    if not blob.exists():
        raise ValueError(f"missing register snapshot: {blob}")
    try:
        values = [int(v, 16) for v in blob.read_text().strip().split()]
    except ValueError as exc:
        raise ValueError("non-hexadecimal LPSS register snapshot") from exc
    if len(values) != len(OFFSETS) or any(not 0 <= v <= 0xFFFFFFFF for v in values):
        raise ValueError("invalid LPSS register snapshot")
    if values[1] != 0x3:
        raise ValueError("snapshot does not contain an active controller")
    return values


def process(mode, pci, file, resource_root="/sys/bus/pci/devices"):
    if pci != SPI_PCI:
        raise ValueError(f"unrecognized LPSS controller: {pci}")
    if mode not in ("save", "restore"):
        raise ValueError(f"unrecognized command: {mode}")

    target = pathlib.Path(file)
    if mode == "restore":
        values = read_snapshot(target)

    fd = os.open(f"{resource_root}/{pci}/resource0", os.O_RDWR | os.O_SYNC)
    try:
        with mmap.mmap(fd, 4096, flags=mmap.MAP_SHARED, prot=mmap.PROT_READ | mmap.PROT_WRITE) as mm:
            def get(offset):
                return struct.unpack_from("<I", mm, offset)[0]

            def put(offset, value):
                struct.pack_into("<I", mm, offset, value)

            if mode == "save":
                values = [get(off) for off in OFFSETS]
                if values[1] != 0x3 or not values[0] & 1:
                    raise ValueError(f"controller not active: reset={values[1]:08x} clock={values[0]:08x}")
                target.parent.mkdir(parents=True, exist_ok=True)
                tmp = target.with_suffix(".new")
                tmp.write_text(" ".join(f"{v:08x}" for v in values) + "\n")
                tmp.replace(target)
            else:
                # Restore reset, private registers and finally the clock.
                put(0x804, 0)
                put(0x804, 3)
                for off, value in zip(OFFSETS, values):
                    if off not in (0x800, 0x804):
                        put(off, value)
                put(0x800, values[0])
    finally:
        os.close(fd)
    return values


def main(argv):
    if len(argv) != 4:
        print("usage: macbook81-lpss.py save|restore PCI-BDF SNAPSHOT", file=sys.stderr)
        return 2
    try:
        values = process(*argv[1:])
    except (OSError, ValueError) as exc:
        print(f"LPSS {argv[1]} {argv[2]} FAILED: {exc}", file=sys.stderr)
        return 1
    print(f"LPSS {argv[1]} {argv[2]}: " + " ".join(f"{value:08x}" for value in values))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
