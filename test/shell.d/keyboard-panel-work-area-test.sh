#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

panel="$ROOT/shell/Ui/KeyboardPanel.qml"

# Bar panels follow the bar. The bar is laid out inside the work area (its
# exclusive zone plus the monitor's reserved area), so the panel surface has
# to be as well: an Ignore surface spans the whole output and leaves the card
# in the screen corner when something has pushed the bar away from it.
if ! rg -q '^\s*exclusionMode: ExclusionMode\.Normal' "$panel"; then
  fail "keyboard panel surface is laid out inside the work area"
fi
pass "keyboard panel surface is laid out inside the work area"

# The surface already starts at the bar's edge, so the card offset is just the
# gap. Only a hidden bar, which reserves nothing and parks under the surface,
# adds its own size back.
if rg -q 'barH \+ gap|barW \+ gap|- barH -|- barW -' "$panel"; then
  fail "keyboard panel card offsets by the bar size only when the bar reserves no space"
fi
if ! rg -q 'readonly property bool barReservesSpace: anchorWindow \? anchorWindow\.exclusionMode !== ExclusionMode\.Ignore' "$panel"; then
  fail "keyboard panel reads whether the bar reserves space from its exclusion mode"
fi
pass "keyboard panel card offsets by the bar size only when the bar reserves no space"

# Card placement and clamping measure the surface, not the screen, since the
# two differ by whatever the work area excludes.
if rg -q 'Math\.min\([xy], screen[WH] -' "$panel"; then
  fail "keyboard panel clamps the card to the surface rather than the screen"
fi
pass "keyboard panel clamps the card to the surface rather than the screen"
