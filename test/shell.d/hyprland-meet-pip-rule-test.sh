#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

rule=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

o = {
  window = function(match)
    if type(match) == "table" and match.title and match.title:find("^%^Meet ") then
      print(match.title)
      print(match.initial_title)
    end
  end,
}

require("default.hypr.apps.pip")
LUA
)

{ read -r title; read -r exclusion; } <<<"$rule"

# The PiP takes its dash from the meeting page.
for pip in "Meet - abc-defg-hij" "Meet – Team standup" "Meet — Team standup"; do
  grep -Eq "$title" <<<"$pip" || fail "Meet PiP rule matches the overlay: $pip"
done
pass "Meet PiP rule matches every dash"

[[ $exclusion == "negative:"* ]] || fail "Meet PiP rule excludes browser windows by initial title" "$exclusion"
exclusion=${exclusion#negative:}

# A browser window maps as "Untitled - Chromium" and only then navigates to Meet.
for title in "Untitled - Chromium" "New Tab - Brave" "Meet - abc-defg-hij - Google Chrome"; do
  grep -Eq "$exclusion" <<<"$title" || fail "Meet PiP rule leaves a browser window alone: $title"
done
pass "Meet PiP rule leaves browser windows alone"

# Chromium titles a PiP window after its opener, without the browser suffix.
grep -Eq "$exclusion" <<<"Meet - abc-defg-hij" && fail "Meet PiP rule still matches the overlay"
pass "Meet PiP rule still matches the overlay"
