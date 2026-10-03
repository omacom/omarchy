#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

qml="$ROOT/shell/plugins/plugin-marketplace/PluginMarketplace.qml"

grep -Fq 'if (opened && doneFile) finishRequest(doneFile)' "$qml" ||
  fail "marketplace completes an outstanding request before opening another"
grep -Fq 'Keys.priority: Keys.AfterItem' "$qml" ||
  fail "marketplace lets focused controls handle keyboard events first"
grep -Fq 'Flow {' "$qml" || fail "marketplace wraps filters on narrow cards"
grep -Fq 'width: parent.width' "$qml" || fail "marketplace filter flow follows the card width"
grep -Fq 'property var primaryAction: root.selectedPlugin ? MarketplaceModel.primaryAction(root.selectedPlugin)' "$qml" ||
  fail "marketplace derives the primary action label and operation together"

pass "plugin marketplace protects concurrent requests and focused controls"
pass "plugin marketplace adapts filters and primary actions"
