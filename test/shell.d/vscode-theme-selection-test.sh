#!/bin/bash

set -euo pipefail

# The generated VSCode theme must keep selection surfaces opaque and their
# text readable. Hex-alpha suffixes (80, 60, 30) read like percentages but
# render at roughly half that opacity, so a regression here turns every
# primary selection back into a faint wash.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
next="$home/.local/state/omarchy/current/next-theme"
mkdir -p "$next"

# A dark, a light, and the theme whose accent is closest to its background,
# which is where a wrong selected-text color shows up first.
for theme in tokyo-night catppuccin-latte rose-pine; do
  cp "$ROOT/themes/$theme/colors.toml" "$next/colors.toml"
  rm -f "$next/vscode-theme.json"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" \
    bash "$ROOT/bin/omarchy-theme-set-templates" ||
    fail "vscode template renders for $theme"
  cp "$next/vscode-theme.json" "$test_tmp/$theme.json"
done

python3 - "$test_tmp" <<'EOF' || fail "vscode selections stay opaque and readable"
import json
import re
import sys

run = sys.argv[1]

OPAQUE = re.compile(r"^#[0-9a-fA-F]{6}$")

# Every selection surface that is opaque in the stock themes.
OPAQUE_KEYS = [
    "selection.background",
    "list.activeSelectionBackground",
    "list.inactiveSelectionBackground",
    "list.focusOutline",
    "minimap.selectionHighlight",
    "editor.selectionBackground",
    "editor.inactiveSelectionBackground",
    "editorSuggestWidget.selectedBackground",
    "menu.selectionBackground",
    "quickInputList.focusBackground",
    "terminal.selectionBackground",
    "terminal.inactiveSelectionBackground",
]

# (background, foreground) pairs carrying text, which must hold normal-text
# contrast on every rendered theme.
TEXT_PAIRS = [
    ("editor.selectionBackground", "editor.selectionForeground"),
    ("terminal.selectionBackground", "terminal.selectionForeground"),
    ("list.activeSelectionBackground", "list.activeSelectionForeground"),
    ("list.inactiveSelectionBackground", "list.inactiveSelectionForeground"),
    ("menu.selectionBackground", "menu.selectionForeground"),
    ("quickInputList.focusBackground", "quickInputList.focusForeground"),
    ("editorSuggestWidget.selectedBackground",
     "editorSuggestWidget.selectedForeground"),
]


def luminance(value):
    channels = [int(value[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    channels = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4
                for c in channels]
    return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2]


def contrast(first, second):
    light, dark = sorted([luminance(first), luminance(second)], reverse=True)
    return (light + 0.05) / (dark + 0.05)


for theme in ("tokyo-night", "catppuccin-latte", "rose-pine"):
    with open(f"{run}/{theme}.json") as handle:
        colors = json.load(handle)["colors"]
    for key in OPAQUE_KEYS:
        value = colors.get(key)
        assert isinstance(value, str) and OPAQUE.match(value), \
            f"{theme}: {key} is not an opaque color: {value!r}"
        print(f"ok - {theme}: {key} renders opaque ({value})")
    for background, foreground in TEXT_PAIRS:
        ratio = contrast(colors[background], colors[foreground])
        assert ratio >= 4.5, \
            f"{theme}: {foreground} on {background} is {ratio:.2f}:1"
        print(f"ok - {theme}: {foreground} on {background} "
              f"reads at {ratio:.2f}:1")
EOF
