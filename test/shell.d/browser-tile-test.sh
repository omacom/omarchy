#!/bin/bash

# Microsoft Edge segfaults on native Wayland when the chromium tile rule forces
# its class to tile (omacom/omarchy#5097). Other chromium browsers keep that
# rule for the --app bug. Firefox already tiles without it.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua
require_command python3

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

rules=$tmpdir/rules
HOME="$tmpdir" OMARCHY_PATH="$ROOT" lua >"$rules" <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local function field(value)
  if value == true then
    return "1"
  end
  if value == false then
    return "0"
  end
  if value == nil then
    return ""
  end
  return tostring(value)
end

hl = {
  window_rule = function(rule)
    local match = rule.match or {}
    print(table.concat({
      field(match.class),
      field(match.title),
      field(match.tag),
      field(rule.tag),
      field(rule.tile),
    }, "\t"))
  end,
}

require("default.hypr.helpers")
require("default.hypr.apps.browser")
LUA

python_status=0
python3 - "$rules" >"$tmpdir/python.out" 2>"$tmpdir/python.err" <<'PY' || python_status=$?
import re
import sys

rules = []
with open(sys.argv[1], encoding="utf-8") as handle:
    for line in handle:
        class_pattern, title_pattern, tag_pattern, effect_tag, tile = line.rstrip("\n").split("\t")
        rules.append({
            "class": class_pattern,
            "title": title_pattern,
            "tag": tag_pattern,
            "effect_tag": effect_tag,
            "tile": tile,
        })

def fullmatch(pattern, value):
    negative = pattern.startswith("negative:")
    if negative:
        pattern = pattern[len("negative:"):]
    return (re.fullmatch(pattern, value) is not None) != negative

def apply(class_name, title=""):
    tags = set()
    tile = None
    for rule in rules:
        if rule["class"] and not fullmatch(rule["class"], class_name):
            continue
        if rule["title"] and not fullmatch(rule["title"], title):
            continue
        if rule["tag"]:
            spec = rule["tag"]
            negative = spec.startswith("negative:")
            name = spec[len("negative:"):] if negative else spec
            if (name in tags) == negative:
                continue
        if rule["effect_tag"].startswith("+"):
            tags.add(rule["effect_tag"][1:])
        elif rule["effect_tag"].startswith("-"):
            tags.discard(rule["effect_tag"][1:])
        if rule["tile"] == "1":
            tile = True
        elif rule["tile"] == "0":
            tile = False
    return tags, tile

def fail(message):
    print(message, file=sys.stderr)
    sys.exit(1)

chromium_classes = [
    "chromium",
    "Chromium",
    "chrome",
    "Chrome",
    "google-chrome",
    "google-Chrome",
    "brave-browser",
    "Brave-browser",
    "Vivaldi-stable",
    "helium",
]
for class_name in chromium_classes:
    tags, tile = apply(class_name, "Example")
    if "chromium-based-browser" not in tags or tile is not True:
        fail(f"{class_name} should stay tagged and tiled, got tags={sorted(tags)} tile={tile}")

for class_name in ("microsoft-edge", "Microsoft-edge"):
    for title in ("", "Omarchy — theme", "New Tab"):
        tags, tile = apply(class_name, title)
        if "chromium-based-browser" not in tags:
            fail(f"{class_name!r} lost the chromium tag")
        if tile is not None:
            fail(f"{class_name!r} title {title!r} is forced tile={tile}")

firefox_classes = ["firefox", "Firefox", "zen", "librewolf"]
for class_name in firefox_classes:
    tags, tile = apply(class_name, "Example")
    if "firefox-based-browser" not in tags or "chromium-based-browser" in tags or tile is not None:
        fail(f"{class_name} should keep its own tag and its own tiling, got tags={sorted(tags)} tile={tile}")

# A hover overlay with no class is not an Edge window, and it is not pulled in
# by the browser tile rule.
tags, tile = apply("", "")
if tile is not None or tags:
    fail(f"anonymous window picked up a browser rule, tags={sorted(tags)} tile={tile}")

print("ok")
PY

if (( python_status != 0 )); then
  fail "browser tile rules match the intended windows" "$(cat "$tmpdir/python.err" "$tmpdir/python.out")"
fi
grep -qx 'ok' "$tmpdir/python.out" ||
  fail "browser tile rules match the intended windows" "$(cat "$tmpdir/python.out")"

pass "Edge is left out of the chromium tile rule, and Chromium and Firefox keep theirs"
