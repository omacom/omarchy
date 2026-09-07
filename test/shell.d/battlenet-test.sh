#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

install_script="$ROOT/bin/omarchy-install-gaming-battlenet"

[[ ! -f $ROOT/applications/battlenet.desktop ]] || fail "Battle.net launcher is not part of default application refresh"
[[ -f $ROOT/default/applications/battlenet.desktop ]] || fail "Battle.net launcher template is available to the installer"
grep -F '$OMARCHY_PATH/default/applications/battlenet.desktop' "$install_script" >/dev/null ||
  fail "Battle.net installer installs the launcher from the installer-only template"

pass "Battle.net launcher is only installed by the Battle.net installer"

# The window rules must match the class the standalone install actually produces.
# battlenet.lua used to key on steam_app_battlenet, a class only a Steam-hosted
# install would have, so none of its rules ever applied to Omarchy's own installer.
rules="$ROOT/default/hypr/apps/battlenet.lua"
desktop="$ROOT/default/applications/battlenet.desktop"

wm_class=$(sed -n 's/^StartupWMClass=//p' "$desktop")
[[ -n $wm_class ]] || fail "battlenet.desktop declares StartupWMClass"

grep -F "$wm_class" "$rules" >/dev/null ||
  fail "battlenet.lua matches the class battlenet.desktop declares ($wm_class)"
! grep -F 'steam_app_battlenet' "$rules" >/dev/null ||
  fail "battlenet.lua no longer matches the Steam-hosted class"

pass "Battle.net window rules match the class the installer produces"
