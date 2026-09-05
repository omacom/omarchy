#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

bar="$ROOT/shell/plugins/bar/Bar.qml"

if grep -E '^[[:space:]]*required property (string omarchyPath|var barWidgetRegistry|var barConfig)' "$bar"; then
  fail "cloned bars can assign host properties after construction"
fi
grep -Fq 'root.barWidgetRegistry && root.barWidgetRegistry.widgets' "$bar" ||
  fail "cloned bars tolerate a null widget registry before host assignment"
pass "cloned bars can assign host properties after construction"
