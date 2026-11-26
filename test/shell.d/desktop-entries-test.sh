#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home" XDG_DATA_DIRS="$scratch/system:$scratch/ven[dor]*" LC_ALL=C

entry() {
  local path=$1
  mkdir -p "${path%/*}"
  printf '[Desktop Entry]\n%s\n' "$2" > "$path"
}

entry "$HOME/.local/share/applications/override.desktop" 'Name=Visible override'
entry "$HOME/.local/share/applications/kde-foo.desktop" 'Name=Visible nested override'
entry "$scratch/system/applications/kde/foo.desktop" 'Hidden=true'
entry "$scratch/system/applications/override.desktop" 'Hidden=true'
entry "$HOME/.local/share/applications/user-hidden.desktop" 'Hidden=true'
entry "$scratch/system/applications/user-hidden.desktop" 'Name=Visible system entry'
entry "$scratch/system/applications/nested/space name.desktop" 'NoDisplay=true'
entry "$scratch/system/applications/nested/deeper/app.desktop" 'OnlyShowIn=GNOME;'
entry "$scratch/system/applications/visible.desktop" 'OnlyShowIn=Hyprland;GNOME;'
entry "$scratch/system/applications/not-hyprland.desktop" 'NotShowIn=Hyprland;'
entry "$scratch/system/applications/other-section.desktop" $'Name=Visible\n[Desktop Action Hidden]\nHidden=true'
entry "$scratch/system/applications/quote\" app.desktop" 'NoDisplay=true'
entry "$scratch/ven[dor]*/applications/vendor.desktop" 'Hidden=true'
entry "$HOME/.nix-profile/share/applications/nix.desktop" 'NoDisplay=true'
entry "$HOME/.local/share/applications/agent.desktop" 'X-Omarchy-Dock-Click=new'
entry "$scratch/system/applications/agent.desktop" 'X-Omarchy-Dock-Click=workspace'
entry "$scratch/system/applications/files.desktop" $'NoDisplay=true\nX-Omarchy-Dock-Click=workspace'

actual=$(bash "$ROOT/shell/services/desktop-entries.sh" 'Hyprland:Omarchy')
hidden=$(awk -F'\t' '$1 == "hidden" { print $2 }' <<<"$actual")
expected=$'user-hidden\nfiles\nnested-deeper-app\nnested-space name\nnot-hyprland\nquote" app\nvendor\nnix'
[[ $hidden == "$expected" ]] || fail "hidden entries changed IDs, directory precedence, or desktop visibility: $hidden"
pass "hidden entries preserve nested IDs, unusual filenames, overrides, and desktop filters"

clicks=$(awk -F'\t' '$1 == "dock-click" { print $2 " " $3 }' <<<"$actual")
[[ $clicks == $'new agent\nworkspace files' ]] || fail "dock click modes ignore X-Omarchy-Dock-Click or its overrides: $clicks"
pass "dock click modes come from X-Omarchy-Dock-Click, with the user's entry winning"
