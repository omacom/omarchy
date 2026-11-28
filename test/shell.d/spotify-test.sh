#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command lua

spotify_rules="$ROOT/default/hypr/apps/spotify.lua"

[[ -f $spotify_rules ]] ||
  fail "Spotify ships Hyprland window rules"

# Load the rule file and print what it registers, so a rule that is commented
# out or reshaped fails here rather than passing on its text.
rules=$(OMARCHY_PATH="$ROOT" lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path

hl = {
  window_rule = function(rule)
    print(string.format("%s\t%s\t%s", rule.match.class, tostring(rule.match.fullscreen_state_internal), tostring(rule.idle_inhibit)))
  end,
}

require("default.hypr.helpers")
require("default.hypr.apps.spotify")
LUA
)

# Spotify runs under XWayland, so it cannot bind zwp_idle_inhibit_manager_v1 and
# never inhibits idle on its own. Without a compositor-side rule the screensaver
# covers fullscreen video podcasts mid-playback.
[[ $(cut -f3 <<<"$rules") == "fullscreen" ]] ||
  fail "Spotify inhibits idle while fullscreen" "$rules"
pass "Spotify inhibits idle while fullscreen"

# Match both the XWayland class (Spotify) and the app id Spotify uses when run
# with the Wayland ozone backend (spotify).
[[ $(cut -f1 <<<"$rules") == "^[sS]potify\$" ]] ||
  fail "Spotify rule matches both its XWayland class and its Wayland app id" "$rules"
pass "Spotify rule matches both its XWayland class and its Wayland app id"

# Hyprland's fullscreen inhibit also fires for a maximized window, so a paused
# Spotify left at full width would hold the machine awake without this.
[[ $(cut -f2 <<<"$rules") == "2" ]] ||
  fail "Spotify does not inhibit idle while maximized" "$rules"
pass "Spotify does not inhibit idle while maximized"
