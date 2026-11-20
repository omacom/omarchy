#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Portal file choosers must map floating AND pinned. Among floating windows
# Hyprland stacks pinned > unpinned regardless of focus, so an unpinned
# chooser maps invisible behind a popped (pinned) floating parent even while
# it holds keyboard focus. See omacom/omarchy#19601.
#
# Focus is deliberately not asserted: it depends on what happens to hold
# focus at spawn time in the harness session. The pinned stratum is the
# deterministic regression this test guards.

# The portal spawns the chooser on demand, so closing it is killing the
# backend process; the next request starts it fresh. Clear any stale chooser
# before spawning, and again on exit.
cleanup() {
  pkill -f "folio chooser" >/dev/null 2>&1 || true
}

cleanup
trap cleanup EXIT

# Spawn the chooser the way any app does: through the portal, without a parent.
gdbus call --session --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.FileChooser.OpenFile "" "acceptance" "{}" >/dev/null

wait_until "portal chooser window maps" 20 window_present "folio-chooser"
screenshot "success-portal-chooser-01-mapped"

chooser_is_floating_and_pinned() {
  hyprctl -j clients | jq -e '[.[] | select(.class == "folio-chooser")][0] | .floating == true and .pinned == true'
}

wait_until "portal chooser is floating and pinned" 10 chooser_is_floating_and_pinned
screenshot "success-portal-chooser-02-floating-pinned"
