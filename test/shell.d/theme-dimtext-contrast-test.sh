#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Readable text tokens derived as mix(foreground, background, N%) must clear
# WCAG AA 4.5:1 against background on every first-party theme (issue #10533).
# A fixed high blend toward the background used to leave 19/22 themes below AA.

require_command python3

python3 - "$ROOT" <<'PY' || fail "themed readable-text mixes stay at or above WCAG AA 4.5:1"
import re, sys
from pathlib import Path

root = Path(sys.argv[1])

def lum(h: str) -> float:
    h = h.lstrip("#")[:6]
    channels = [int(h[i : i + 2], 16) / 255 for i in (0, 2, 4)]
    channels = [
        c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in channels
    ]
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def ratio(a: str, b: str) -> float:
    la, lb = lum(a), lum(b)
    return (max(la, lb) + 0.05) / (min(la, lb) + 0.05)


def mix(a: str, b: str, amount: float) -> str:
    a, b = a.lstrip("#"), b.lstrip("#")
    return "#" + "".join(
        f"{int(int(a[i : i + 2], 16) * (1 - amount) + int(b[i : i + 2], 16) * amount + 0.5):02x}"
        for i in (0, 2, 4)
    )


# Keep in lockstep with the readable-text mixes in default/themed/*.tpl.
tokens = {
    "pi.json.tpl dimText": 0.16,
    "pi.json.tpl mutedText": 0.10,
    "claude.json.tpl inactive": 0.16,
    "claude.json.tpl inactiveShimmer": 0.10,
    "shell.toml.tpl placeholder": 0.10,
}

# Templates must still encode those percentages so a drift cannot pass this test.
template_checks = {
    root / "default/themed/pi.json.tpl": (
        ('"mutedText": "{{ mix foreground background 10% }}"', "mutedText 10%"),
        ('"dimText": "{{ mix foreground background 16% }}"', "dimText 16%"),
    ),
    root / "default/themed/claude.json.tpl": (
        ('"inactive": "{{ mix foreground background 16% }}"', "inactive 16%"),
        ('"inactiveShimmer": "{{ mix foreground background 10% }}"', "inactiveShimmer 10%"),
    ),
    root / "default/themed/shell.toml.tpl": (
        ('placeholder      = "{{ mix foreground background 10% }}"', "placeholder 10%"),
    ),
}

for path, needles in template_checks.items():
    text = path.read_text()
    for needle, label in needles:
        if needle not in text:
            print(f"missing {label} in {path.relative_to(root)}", file=sys.stderr)
            sys.exit(1)

themes = []
for colors in sorted((root / "themes").glob("*/colors.toml")):
    body = colors.read_text()
    fg = re.search(r'^foreground\s*=\s*"(#\w{6})"', body, re.M)
    bg = re.search(r'^background\s*=\s*"(#\w{6})"', body, re.M)
    if not (fg and bg):
        continue
    themes.append((colors.parent.name, fg.group(1), bg.group(1)))

if len(themes) < 20:
    print(f"expected first-party colors.toml themes, found {len(themes)}", file=sys.stderr)
    sys.exit(1)

failures = []
for label, amount in tokens.items():
    for name, fg, bg in themes:
        value = mix(fg, bg, amount)
        contrast = ratio(value, bg)
        if contrast < 4.5:
            failures.append(f"{name} {label} {value} = {contrast:.2f}:1")

if failures:
    print("\n".join(failures), file=sys.stderr)
    sys.exit(1)

print(f"checked {len(themes)} themes x {len(tokens)} readable-text mixes")
PY

pass "themed readable-text mixes stay at or above WCAG AA 4.5:1"
