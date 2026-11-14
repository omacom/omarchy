#!/usr/bin/python3
"""Subdivide the canonical logo and generate its C byte array."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

SOURCE_WIDTH = 81
SOURCE_HEIGHT = 10
OUTPUT_WIDTH = 162
OUTPUT_HEIGHT = 20
GLYPH_BITS = {
    " ": (False, False),
    "▀": (True, False),
    "▄": (False, True),
    "█": (True, True),
}
BITS_GLYPH = {bits: glyph for glyph, bits in GLYPH_BITS.items()}


def subdivide(source: str) -> str:
    lines = source.splitlines()
    if len(lines) != SOURCE_HEIGHT or max(map(len, lines), default=0) != SOURCE_WIDTH:
        raise ValueError("canonical logo must be exactly 81x10 at maximum width")
    if any(set(line) - GLYPH_BITS.keys() for line in lines):
        raise ValueError("canonical logo contains an unsupported glyph")

    half_rows: list[list[bool]] = []
    for line in lines:
        padded = line.ljust(SOURCE_WIDTH)
        upper: list[bool] = []
        lower: list[bool] = []
        for glyph in padded:
            top, bottom = GLYPH_BITS[glyph]
            upper.append(top)
            lower.append(bottom)
        half_rows.extend((upper, lower))

    subdivided_half_rows: list[list[bool]] = []
    for half_row in half_rows:
        doubled = [bit for bit in half_row for _ in range(2)]
        subdivided_half_rows.extend((doubled.copy(), doubled.copy()))

    output_lines = []
    for row in range(0, len(subdivided_half_rows), 2):
        output_lines.append(
            "".join(
                BITS_GLYPH[(subdivided_half_rows[row][column], subdivided_half_rows[row + 1][column])]
                for column in range(OUTPUT_WIDTH)
            )
        )
    if len(output_lines) != OUTPUT_HEIGHT or any(len(line) != OUTPUT_WIDTH for line in output_lines):
        raise AssertionError("subdivision dimensions drifted")
    if output_lines[0].strip():
        raise AssertionError("canonical empty first half-row was not preserved")
    return "\n".join(output_lines) + "\n"


def render_header(data: bytes) -> str:
    lines = [
        "#ifndef TTFX_EMBEDDED_LOGO_H",
        "#define TTFX_EMBEDDED_LOGO_H",
        "",
        "#include <stddef.h>",
        "#include <stdint.h>",
        "",
        "/* Generated from embedded-logo-v2.txt; do not edit by hand. */",
        "static const uint8_t ttfx_embedded_logo[] = {",
    ]
    for offset in range(0, len(data), 12):
        values = ", ".join(f"0x{byte:02x}" for byte in data[offset : offset + 12])
        lines.append(f"        {values},")
    lines.extend(
        [
            "};",
            "static const size_t ttfx_embedded_logo_len = sizeof(ttfx_embedded_logo);",
            "",
            "#endif",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="fail if generated files are stale")
    args = parser.parse_args()

    root = Path(__file__).resolve().parent
    source = root.parent.parent / "logo.txt"
    asset = root / "embedded-logo-v2.txt"
    header = root / "embedded-logo.h"
    generated_asset = subdivide(source.read_text(encoding="utf-8"))
    generated_header = render_header(generated_asset.encode("utf-8"))

    if args.check:
        stale = []
        if not asset.exists() or asset.read_text(encoding="utf-8") != generated_asset:
            stale.append(asset)
        if not header.exists() or header.read_text(encoding="utf-8") != generated_header:
            stale.append(header)
        if stale:
            print("stale generated files: " + ", ".join(map(str, stale)), file=sys.stderr)
            return 1
        return 0

    asset.write_text(generated_asset, encoding="utf-8")
    header.write_text(generated_header, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
