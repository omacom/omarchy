#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command lua

exclusion=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

o = {
  window = function(match)
    if type(match) == "table" and match.title == "^Meet - .+" then
      print((match.initial_title:gsub("^negative:", "")))
    end
  end,
}

require("default.hypr.apps.pip")
LUA
)

[[ -n $exclusion ]] || fail "Meet PiP rule excludes browser windows by initial title"

# A browser window maps as "Untitled - Chromium" and only then navigates to Meet.
for title in "Untitled - Chromium" "New Tab - Brave" "Meet - abc-defg-hij - Google Chrome"; do
  grep -Eq "$exclusion" <<<"$title" || fail "Meet PiP rule leaves a browser window alone: $title"
done
pass "Meet PiP rule leaves browser windows alone"

# Chromium titles a PiP window after its opener, without the browser suffix.
for title in "Meet - abc-defg-hij" "Meet – Standup"; do
  grep -Eq "$exclusion" <<<"$title" && fail "Meet PiP rule still matches the overlay: $title"
done
pass "Meet PiP rule still matches the overlay"
