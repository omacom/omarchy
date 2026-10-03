#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tray="$ROOT/shell/plugins/bar/widgets/Tray.qml"

grep -Fq 'readonly property int revealPx: Math.round(root.revealExtent)' "$tray" ||
  fail "tray sizes the drawer from a single rounded reveal extent"

# Collapsed width must follow revealExtent (0), not the full drawerExtent.
if grep -Eq 'drawerBlockWidth: root\.allItems\.length > 0 \? expandIcon\.implicitWidth \+ root\.drawerExtent' "$tray"; then
  fail "horizontal tray still reserves the fully expanded drawer width while collapsed"
fi
if grep -Eq 'drawerBlockHeight: root\.allItems\.length > 0 \? expandIcon\.implicitHeight \+ root\.drawerExtent' "$tray"; then
  fail "vertical tray still reserves the fully expanded drawer height while collapsed"
fi

grep -Fq 'expandIcon.implicitWidth + revealPx' "$tray" ||
  fail "horizontal drawer block width uses revealPx"
grep -Fq 'expandIcon.implicitHeight + revealPx' "$tray" ||
  fail "vertical drawer block height uses revealPx"
grep -Fq 'x: horizontalTrayRoot.drawerBlockWidth - width' "$tray" ||
  fail "horizontal chevron pins to the block's trailing edge"
grep -Fq 'y: verticalTrayRoot.drawerBlockHeight - height' "$tray" ||
  fail "vertical chevron pins to the block's trailing edge"
grep -Fq 'width: horizontalTrayRoot.revealPx' "$tray" ||
  fail "horizontal icon clip tracks revealPx"
grep -Fq 'height: verticalTrayRoot.revealPx' "$tray" ||
  fail "vertical icon clip tracks revealPx"

pass "tray drawer width follows reveal extent while collapsed"
