#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

system_rules="$ROOT/default/hypr/apps/system.lua"
screensaver_launch="$ROOT/bin/omarchy-launch-screensaver"

rg -q 'File Operation\(s\| Progress\)' "$system_rules" ||
  fail "Nautilus file-operations windows are matched by title"
grep -Fq 'org\\.gnome\\.Nautilus' "$system_rules" ||
  fail "Nautilus file-operations windows are matched by class"
rg -q 'pin = true' "$system_rules" ||
  fail "Nautilus file-operations windows stay pinned while open"
rg -q 'org.omarchy.screensaver' "$system_rules" ||
  fail "screensaver window rules are present"
rg -q 'stay_focused = true' "$system_rules" ||
  fail "screensaver keeps focus against lingering grabs"
pass "Nautilus file-operations grab is contained by window rules"

rg -q 'wtype -k Escape' "$screensaver_launch" ||
  fail "screensaver launch releases exclusive seat grabs before mapping"
pass "screensaver launch releases exclusive seat grabs before mapping"
