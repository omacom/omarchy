#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

# Chromium tab tear-out creates a new toplevel and asks Hyprland to move it with
# the pointer. An explicit tile=true rule forces that window tiled, so the move
# cannot start and Chromium freezes (issue #10596). Keep opacity/tag styling,
# and leave Firefox and the youtube/zoom tag strip alone.

dump_browser_rules() {
  OMARCHY_PATH="$ROOT" lua - "$1" <<'LUA'
local module = arg[1]
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

local rules = {}

hl = {
  window_rule = function(rule)
    rules[#rules + 1] = rule
  end,
}

require("default.hypr.helpers")
require(module)

local function enc(value)
  local value_type = type(value)
  if value_type == "nil" then
    return "null"
  elseif value_type == "boolean" or value_type == "number" then
    return tostring(value)
  elseif value_type == "string" then
    return string.format("%q", value)
  elseif value_type == "table" then
    local parts = {}
    if #value > 0 then
      for index, entry in ipairs(value) do
        parts[index] = enc(entry)
      end
      return "[" .. table.concat(parts, ",") .. "]"
    end

    for key, entry in pairs(value) do
      parts[#parts + 1] = string.format("%q:%s", key, enc(entry))
    end
    table.sort(parts)
    return "{" .. table.concat(parts, ",") .. "}"
  end

  return string.format("%q", tostring(value))
end

for _, rule in ipairs(rules) do
  print(enc(rule))
end
LUA
}

browser_rules=$(dump_browser_rules "default.hypr.apps.browser") ||
  fail "browser window rules load under a stub compositor"

[[ -n $browser_rules ]] || fail "browser window rules emit at least one rule"

chromium_tag_rule=$(grep -F '"tag":"+chromium-based-browser"' <<<"$browser_rules" || true)
[[ -n $chromium_tag_rule ]] || fail "chromium class match still adds chromium-based-browser tag" "$browser_rules"
pass "chromium class match adds chromium-based-browser tag"

firefox_tag_rule=$(grep -F '"tag":"+firefox-based-browser"' <<<"$browser_rules" || true)
[[ -n $firefox_tag_rule ]] || fail "firefox class match still adds firefox-based-browser tag" "$browser_rules"
pass "firefox class match adds firefox-based-browser tag"

chromium_style_rule=$(grep -F '"match":{"tag":"chromium-based-browser"}' <<<"$browser_rules" || true)
[[ -n $chromium_style_rule ]] || fail "chromium tag still has a style rule" "$browser_rules"

if grep -Eq '"tile"[[:space:]]*:[[:space:]]*true' <<<"$chromium_style_rule"; then
  fail "chromium style rule must not force tile=true (blocks tab tear-out move)" "$chromium_style_rule"
fi
if grep -Eq '"tile"[[:space:]]*:' <<<"$chromium_style_rule"; then
  fail "chromium style rule must not set any tile effect" "$chromium_style_rule"
fi

# Source-level guard: ignore comments, flag real rule tables that still force tile.
if awk '
  /^[[:space:]]*--/ { next }
  /tile[[:space:]]*=[[:space:]]*true/ { found=1; print NR ":" $0 }
  END { exit found ? 0 : 1 }
' "$ROOT/default/hypr/apps/browser.lua"; then
  fail "browser.lua must not assign tile = true outside comments"
fi
pass "chromium style rule does not force tile=true"

grep -Fq '"tag":"-default-opacity"' <<<"$chromium_style_rule" ||
  fail "chromium style rule still opts out of default-opacity" "$chromium_style_rule"
grep -Fq '"opacity":"1.0 0.985"' <<<"$chromium_style_rule" ||
  fail "chromium style rule keeps near-opaque opacity" "$chromium_style_rule"
pass "chromium style rule keeps -default-opacity and opacity"

firefox_style_rule=$(grep -F '"match":{"tag":"firefox-based-browser"}' <<<"$browser_rules" || true)
[[ -n $firefox_style_rule ]] || fail "firefox tag still has a style rule" "$browser_rules"
grep -Fq '"tag":"-default-opacity"' <<<"$firefox_style_rule" ||
  fail "firefox style rule still opts out of default-opacity" "$firefox_style_rule"
grep -Fq '"opacity":"1.0 0.985"' <<<"$firefox_style_rule" ||
  fail "firefox style rule keeps near-opaque opacity" "$firefox_style_rule"
if grep -Eq '"tile"[[:space:]]*:' <<<"$firefox_style_rule"; then
  fail "firefox style rule stays free of an explicit tile effect" "$firefox_style_rule"
fi
pass "firefox style rule unchanged (opacity/tag, no tile)"

youtube_strip=$(grep -F '"tag":"-chromium-based-browser"' <<<"$browser_rules" || true)
[[ -n $youtube_strip ]] || fail "youtube/zoom class match still strips chromium-based-browser" "$browser_rules"
grep -Eq 'youtube(\\.|\\\\\.)com' <<<"$youtube_strip" ||
  fail "youtube class pattern remains on the chromium tag strip rule" "$youtube_strip"
grep -Eq 'zoom(\\.|\\\\\.)us' <<<"$youtube_strip" ||
  fail "zoom class pattern remains on the chromium tag strip rule" "$youtube_strip"
pass "youtube/zoom still strip chromium-based-browser tag"

youtube_opacity_strip=$(grep -E 'youtube(\\.|\\\\\.)com' <<<"$browser_rules" | grep -F '"tag":"-default-opacity"' || true)
[[ -n $youtube_opacity_strip ]] ||
  fail "youtube/zoom still strip default-opacity" "$browser_rules"
pass "youtube/zoom still strip default-opacity"

sharing_rule=$(grep -F '"title":".*is sharing.*"' <<<"$browser_rules" || true)
[[ -n $sharing_rule ]] || fail "screen-sharing notification still moves to special silent" "$browser_rules"
grep -Fq '"workspace":"special silent"' <<<"$sharing_rule" ||
  fail "screen-sharing notification workspace is special silent" "$sharing_rule"
pass "screen-sharing notification rule remains"

# pip.lua depends on the chromium tag for Meet overlays; ensure that path still
# loads and still floats Meet without relying on the removed tile force.
pip_rules=$(dump_browser_rules "default.hypr.apps.pip") ||
  fail "pip window rules load under a stub compositor"

meet_rule=$(grep -F '"title":"^Meet - .+"' <<<"$pip_rules" || true)
[[ -n $meet_rule ]] || fail "Meet PiP rule still matches chromium-based-browser + Meet title" "$pip_rules"
grep -Fq '"tag":"chromium-based-browser"' <<<"$meet_rule" ||
  fail "Meet PiP rule still requires chromium-based-browser tag" "$meet_rule"
grep -Fq '"float":true' <<<"$meet_rule" ||
  fail "Meet PiP rule still floats" "$meet_rule"
pass "Meet PiP still floats via chromium-based-browser tag"

# No other default hypr rule should reintroduce a blanket chromium tile.
chromium_tile_hits=$(
  rg -n 'tile\s*=\s*true' "$ROOT/default/hypr" -g '*.lua' |
    grep -Ei 'chrom|browser' |
    awk -F: '
      {
        line=$0
        sub(/^[^:]+:[0-9]+:/, "", line)
        if (line ~ /^[[:space:]]*--/) next
        print
      }
    ' || true
)
[[ -z $chromium_tile_hits ]] ||
  fail "no chromium/browser app rule reintroduces tile=true" "$chromium_tile_hits"

tag_tile_hits=$(
  rg -n 'tile\s*=\s*true' "$ROOT/default/hypr" -g '*.lua' |
    grep -F 'chromium-based-browser' |
    awk -F: '
      {
        line=$0
        sub(/^[^:]+:[0-9]+:/, "", line)
        if (line ~ /^[[:space:]]*--/) next
        print
      }
    ' || true
)
[[ -z $tag_tile_hits ]] ||
  fail "no hypr rule tiles chromium-based-browser" "$tag_tile_hits"
pass "no remaining hypr rule force-tiles chromium-based-browser"
