#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Exercise the collapsible widget group: a `type: "group"` layout entry that
# wraps children behind a chevron and reveals them like the tray drawer. The
# regression this guards is that older code dropped id-less group entries during
# layout normalization, so the grouped widgets vanished. The bar must keep
# rendering with a group configured, and the group must actually hide its
# children when collapsed and reveal them when open.
#
# The acceptance harness syncs this checkout into ~/.local/share/omarchy but
# leaves the live shell running the stock system path, so first repoint the
# session at the synced checkout and restart, or the shell under test would be
# the stock one without the group code.

abs_omarchy="$HOME/.local/share/omarchy"

# Track whether OMARCHY_PATH is present in the session env by its line (not a
# non-empty value), so restore() puts it back exactly — including an empty value
# — and only unsets it when it was truly absent.
env_dump=$(systemctl --user show-environment 2>/dev/null)
had_omarchy_path=0
grep -q '^OMARCHY_PATH=' <<<"$env_dump" && had_omarchy_path=1
original_path=$(sed -n 's/^OMARCHY_PATH=//p' <<<"$env_dump" | tail -1)

config_dir="$HOME/.config/omarchy"
config="$config_dir/shell.json"
backup="$(mktemp)"
had_config=0

mkdir -p "$config_dir"
if [[ -f $config ]]; then
  cp "$config" "$backup"
  had_config=1
fi

restore() {
  if (( had_config )); then
    cp "$backup" "$config"
  else
    rm -f "$config"
  fi
  rm -f "$backup"
  if (( had_omarchy_path )); then
    systemctl --user set-environment OMARCHY_PATH="$original_path" >/dev/null 2>&1 || true
  else
    systemctl --user unset-environment OMARCHY_PATH >/dev/null 2>&1 || true
  fi
  omarchy-restart-shell >/dev/null 2>&1 || true
}
trap restore EXIT

# The group's children are custom `command` modules echoing fixed text rather
# than first-party widgets, because every hardware-backed widget hides itself
# when its backing state is missing: system-update has no pending update,
# bluetooth no adapter, network no connection, tray no apps, power no battery.
# A clean CI image has none of them, so a group built from those measures 0px in
# *both* states, the two captures come out byte-identical, and the test passes
# while proving nothing. Fixed command output renders on any machine, and it is
# what the assertions below read back off the screen.
child_a="GROUPALPHA"
child_b="GROUPBETA"

write_group_config() {
  local collapsed="$1"

  cat >"$config" <<JSON
{
  "version": 1,
  "bar": {
    "position": "top",
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left": [ { "id": "omarchy.menu" }, { "id": "omarchy.workspaces" } ],
      "center": [ { "id": "omarchy.clock", "format": "dddd HH:mm" } ],
      "right": [
        {
          "type": "group",
          "collapsed": $collapsed,
          "items": [
            { "id": "grouptest.alpha", "type": "command", "exec": "echo $child_a" },
            { "id": "grouptest.beta", "type": "command", "exec": "echo $child_b" }
          ]
        },
        { "id": "omarchy.audio" }
      ]
    }
  }
}
JSON
}

# Load the synced checkout so the code under test is what actually renders.
write_group_config true
systemctl --user set-environment OMARCHY_PATH="$abs_omarchy"
omarchy-restart-shell >/dev/null 2>&1 || true
wait_until "shell restarts on the synced checkout with a collapsed group" 40 layer_on_screen "omarchy-bar"
sleep 3
# On its own this would still pass with the group dropped altogether — which is
# the very regression being guarded — so it is the expanded case below that
# proves the children exist at all.
wait_until "collapsed group hides its children" 20 screen_lacks "$child_a"
screenshot "success-bar-group-collapsed"

# Expanded (collapsed:false starts the drawer open) so a screenshot captures the
# revealed widgets — the state a hover produces. Restart rather than reload: a
# config reload is not guaranteed to rebuild the section for this change, and a
# run that silently keeps rendering the previous state is how a bar group test
# ends up asserting nothing.
write_group_config false
omarchy-restart-shell >/dev/null 2>&1 || true
wait_until "bar renders with an expanded group" 40 layer_on_screen "omarchy-bar"
sleep 3
wait_until "expanded group reveals its first child" 30 screen_contains "$child_a"
wait_until "expanded group reveals its second child" 20 screen_contains "$child_b"
screenshot "success-bar-group-expanded"
