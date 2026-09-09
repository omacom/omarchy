#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hw_nightlight="$ROOT/bin/omarchy-hw-nightlight"
toggle="$ROOT/bin/omarchy-toggle-nightlight"
menu="$ROOT/default/omarchy/omarchy-menu.jsonc"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# A /sys/class/drm shaped tree: one directory per card bound to the named
# driver, plus the connector directories the real thing interleaves with them.
make_drm_tree() {
  local tree="$test_tmp/drm-$RANDOM"
  local index=0
  local driver

  mkdir -p "$tree/drivers"

  for driver in "$@"; do
    mkdir -p "$tree/card$index/device" "$tree/drivers/$driver"
    ln -s "../../drivers/$driver" "$tree/card$index/device/driver"
    # Connectors hang off the same directory and must not be counted as cards.
    mkdir -p "$tree/card$index-LVDS-1" "$tree/card$index-DVI-I-1"
    (( ++index ))
  done

  echo "$tree"
}

supports_nightlight() {
  OMARCHY_DRM_PATH="$1" "$BASH" "$hw_nightlight"
}

# Pre-GCN AMD: aquamarine's legacy DRM path never submits a CTM, so hyprsunset
# is a silent no-op here.
! supports_nightlight "$(make_drm_tree radeon)" ||
  fail "a radeon-only machine reports no nightlight support"
pass "radeon-only hardware reports no nightlight support"

# Everything atomic must keep the feature.
supports_nightlight "$(make_drm_tree amdgpu)" ||
  fail "an amdgpu machine still supports nightlight"
supports_nightlight "$(make_drm_tree i915)" ||
  fail "an Intel machine still supports nightlight"
pass "atomic drivers keep nightlight"

# Conservative on mixed hardware: the display may be driven by the other GPU,
# and hiding a working feature is worse than leaving a broken one visible.
supports_nightlight "$(make_drm_tree radeon i915)" ||
  fail "a machine with both radeon and an atomic GPU keeps nightlight"
pass "mixed radeon plus atomic hardware keeps nightlight"

# Nothing to go on is not evidence of breakage.
supports_nightlight "$(make_drm_tree)" ||
  fail "a tree with no DRM cards does not claim nightlight is broken"
pass "an empty DRM tree keeps nightlight"

# The guard has to be wired up in both places, or the silent no-op comes back.
grep -Fq '"when":"omarchy-hw-nightlight"' "$menu" ||
  fail "the menu hides the Nightlight row on hardware that cannot do it"
grep -Fq 'if ! omarchy-hw-nightlight; then' "$toggle" ||
  fail "omarchy-toggle-nightlight refuses instead of reporting a false success"
pass "the nightlight guard is wired into the menu and the toggle"
