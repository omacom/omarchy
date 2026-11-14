#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua
require_command python3

# Inspect the emitted rules, so commented-out or inactive rules cannot pass.
emitted_rules() {
  OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

hl = {
  window_rule = function(rule)
    print(table.concat({
      rule.match.class or "", rule.match.title or "", rule.match.tag or "", rule.tag or "",
      tostring(rule.float), tostring(rule.center),
      rule.size and rule.size[1] or "", rule.size and rule.size[2] or "",
    }, "\t"))
  end,
}

require("default.hypr.helpers")
require("default.hypr.apps.system")
LUA
}

rules=$(emitted_rules) || fail "system.lua loads" "$rules"

EMITTED_RULES="$rules" python3 <<'PY'
import os
import re
import sys

rules = [line.split("\t") for line in os.environ["EMITTED_RULES"].splitlines()]


def check(condition, description):
  if not condition:
    print(f"not ok - {description}", file=sys.stderr)
    sys.exit(1)


def matches(rule, window_class, title, tag=""):
  # These patterns use the common RE2/Python subset. Hyprland matches the whole string.
  return all(not pattern or re.fullmatch(pattern, value) is not None
             for pattern, value in zip(rule[:3], (window_class, title, tag)))


def tagged(window_class, title):
  return any(rule[3] == "+floating-window" and matches(rule, window_class, title)
             for rule in rules)


for window_class in ("soffice", "soffice.bin"):
  for title in ("Open", "Open Files", "Open Folder", "Save", "Save As", "Save File",
                "All Files", "Choose a File", "Choose a Folder", "choose a directory"):
    check(tagged(window_class, title), f"{window_class}: {title} receives the floating-window tag")

  for title in ("Text Import - [test.csv]", "Enter Password", "Import Options",
                "ASCII Filter Options", "Filter Options"):
    matching = [rule for rule in rules if matches(rule, window_class, title)]
    check(any(rule[4] == "true" for rule in matching), f"{window_class}: {title} floats")
    check(any(rule[5] == "true" for rule in matching), f"{window_class}: {title} is centered")
    check(not tagged(window_class, title) and not any(rule[6] or rule[7] for rule in matching),
          f"{window_class}: {title} keeps its requested size")

# Standard file pickers still inherit the shared float, center and size treatment.
floating = [rule for rule in rules if matches(rule, "soffice", "Open", "floating-window")]
check(any(rule[4] == "true" for rule in floating), "floating-window tag floats file pickers")
check(any(rule[5] == "true" for rule in floating), "floating-window tag centers file pickers")
check(any(rule[6:] == ["875", "600"] for rule in floating), "file pickers use the standard size")

for window_class in ("sublime_text", "DesktopEditors", "org.gnome.Nautilus"):
  for title in ("Open Files", "Save", "Choose a File", "choose a directory"):
    check(tagged(window_class, title), f"existing {window_class}: {title} coverage is retained")

check(tagged("xdg-desktop-portal-gtk", "Open"), "portal dialogs remain floating")

# Guard the Open folder collision, document titles, and a wildcard dot in soffice.bin.
for window_class, title in (
  ("org.gnome.Nautilus", "Open"),
  ("libreoffice-writer", "Choose a venue.txt - LibreOffice Writer"),
  ("libreoffice-calc", "Save - LibreOffice Calc"),
  ("soffice", "Text Import.csv - LibreOffice Calc"),
  ("soffice", "Open - LibreOffice Writer"),
  ("soffice", "Untitled 1 - LibreOffice Writer"),
  ("sofficexbin", "Open"),
  ("sofficexbin", "Save"),
  ("sofficexbin", "Text Import - [test.csv]"),
  ("unrelated-app", "Text Import - [test.csv]"),
):
  matching = [rule for rule in rules if matches(rule, window_class, title)]
  check(not tagged(window_class, title) and not any(rule[4] == "true" for rule in matching),
        f"{window_class}: {title} is not floated")
PY

pass "LibreOffice native file dialogs use the standard floating dialog treatment"
