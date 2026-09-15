#!/bin/bash

# Chromium --app web apps must receive +chromium-based-browser under Hyprland's
# RE2 FullMatch class matching. Bare browser ids alone never full-match the
# product-prefixed <id>-<host>__<path>-<Profile> form from omarchy-launch-webapp
# (chrome-/brave-/msedge-/vivaldi-/opera-/helium-, not the bare window class).
#
# Regression guard for omacom/omarchy#9784. Uses Python re.fullmatch so the
# test matches Hyprland semantics (bash [[ =~ ]] is unanchored and would hide
# the bug).

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

browser_lua="$ROOT/default/hypr/apps/browser.lua"

chromium_pattern=$(
  grep -F 'tag = "+chromium-based-browser"' "$browser_lua" | head -n1 |
    sed -n 's/^o\.window("\([^"]*\)".*$/\1/p'
)
[[ -n $chromium_pattern ]] || fail "browser.lua declares a chromium-based-browser class rule"

# Decode Lua string escapes in the extracted pattern so Python sees the same
# bytes Hyprland's RE2 engine does after the Lua string is parsed.
chromium_pattern=$(
  PATTERN=$chromium_pattern python3 - <<'PY'
import codecs, os
print(codecs.decode(os.environ["PATTERN"], "unicode_escape"), end="")
PY
)

fullmatch() {
  local value=$1 pattern=$2
  PATTERN=$pattern VALUE=$value python3 - <<'PY'
import os, re, sys
sys.exit(0 if re.fullmatch(os.environ["PATTERN"], os.environ["VALUE"]) else 1)
PY
}

# Bare Chromium-family browser windows still match.
for appid in \
  chromium chrome Chrome google-chrome \
  brave-browser Brave-browser brave-origin \
  microsoft-edge Microsoft-edge Vivaldi-stable helium \
  opera Opera; do
  fullmatch "$appid" "$chromium_pattern" ||
    fail "chromium rule full-matches bare browser class $appid"
done
pass "chromium rule full-matches bare Chromium-family browser classes"

# Web apps launched via --app= use product id + host/path + profile suffix.
# omarchy-launch-webapp never passes --profile-directory, so Chromium puts the
# last-used profile basename in the class (Default, Profile_1, ...). The host
# path always contains __; that is what separates web apps from extension ids.
for appid in \
  "chrome-example.com__-Default" \
  "chrome-example.com__path-Default" \
  "chrome-example.test__-Profile_1" \
  "chrome-example.com__-Profile_1" \
  "chrome-youtube.com__-Default" \
  "brave-outlook.office.com__mail_-Default" \
  "brave-example.com__-Default" \
  "brave-example.com__-Profile_1" \
  "msedge-example.com__-Default" \
  "msedge-example.com__-Profile_1" \
  "vivaldi-example.com__-Default" \
  "opera-example.com__-Default" \
  "helium-example.com__-Default"; do
  fullmatch "$appid" "$chromium_pattern" ||
    fail "chromium rule full-matches webapp class $appid"
done
pass "chromium rule full-matches Chromium --app webapp classes"

# Non-Chromium classes, incomplete suffixes, and extension popouts stay untagged.
# Bitwarden popout is chrome-<extension-id>-Default with no host/__ (bitwarden.lua).
for appid in \
  firefox zen librewolf \
  "firefox-example.com__-Default" \
  chrome-evil \
  brave-something \
  not-a-browser \
  "chrome-nngceckbapebfimnlniiiahkandclblb-Default" \
  "chrome-abcdefghijklmnopqrstuvwxyzabcdef-Default"; do
  fullmatch "$appid" "$chromium_pattern" &&
    fail "chromium rule leaves non-matching class $appid untagged"
done
pass "chromium rule leaves non-Chromium, incomplete, and extension classes untagged"

# Tag removals for YouTube/Zoom must precede the rules that consume the tag.
# Hyprland does not undo a rule that already matched on a later-removed tag.
mapfile -t order_lines < <(
  grep -nE 'tag = "-chromium-based-browser"|tag = "chromium-based-browser"' "$browser_lua" |
    awk -F: '{print $1, $2}'
)
remove_line=
consume_line=
for entry in "${order_lines[@]}"; do
  line=${entry%% *}
  text=${entry#* }
  if [[ $text == *'tag = "-chromium-based-browser"'* ]]; then
    remove_line=${remove_line:-$line}
  elif [[ $text == *'tag = "chromium-based-browser"'* ]]; then
    consume_line=${consume_line:-$line}
  fi
done
[[ -n $remove_line && -n $consume_line ]] ||
  fail "browser.lua declares both chromium tag removal and tag consumer rules"
(( remove_line < consume_line )) ||
  fail "YouTube/Zoom chromium tag removal precedes the tile/opacity consumer" \
    "remove=$remove_line consume=$consume_line"
pass "chromium video-app tag removals precede the rules that consume the tag"
