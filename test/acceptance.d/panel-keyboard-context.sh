#!/bin/bash

# Sourced by panel acceptance tests. Unexpected layer surfaces invalidate the
# isolated keyboard context; their presence alone does not prove who has focus.
assert_panel_keyboard_context() {
  local allowed unexpected context=${0##*/}
  context=${context%.sh}
  local snapshot="$ARTIFACTS/$context-keyboard-layers"
  if ! hyprctl -j layers > "$snapshot.json" 2> "$snapshot.stderr"; then
    fail "panel keyboard context can be inspected ($context)" "Compositor query failed; see $snapshot.json and .stderr"
  fi

  allowed=$(jq -cn --args '["omarchy-background", "omarchy-bar", "omarchy-dock", "omarchy-notifications", "omarchy-keyboard-panel", "omarchy-keyboard-panel-dismiss"] + $ARGS.positional' "$@")
  if ! unexpected=$(jq -c --argjson allowed "$allowed" '
    if type != "object" or length == 0 then error("missing monitor layer data") else
      [to_entries[] | .value
        | if (.levels | type) != "object" then error("missing layer levels") else .levels | to_entries[] end
        | .key as $level | .value
        | if type != "array" then error("invalid layer list") else .[] end
        | if type != "object" or (.namespace | type) != "string" then error("missing layer namespace") else .namespace end
        # OWE is the wallpaper renderer, outside Quickshell. Its ordinary
        # background surface is expected; the same name on an overlay is not.
        | select(. != "owe-background" or $level != "0")
        | select(. as $ns | $allowed | index($ns) | not)] | unique
    end
  ' "$snapshot.json" 2>> "$snapshot.stderr"); then
    fail "panel keyboard context can be inspected ($context)" "Invalid layer data; see $snapshot.json and .stderr"
  fi
  if [[ $unexpected != "[]" ]]; then
    fail "panel keyboard context has no unexpected layer surfaces ($context)" "Unexpected surfaces: $unexpected. Keyboard step aborted; inspect $snapshot.json."
  fi
}
