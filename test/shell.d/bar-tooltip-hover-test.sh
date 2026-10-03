#!/bin/bash

# Bar.showTooltip() shows nothing unless its target reports
# tooltipHovered === true, the live hover state it checks before and after
# the deferred show. A widget that calls showTooltip() without declaring that
# property never gets a tooltip, and nothing reports it: the request is just
# dropped. The active window title and the media widget both lost theirs that
# way when the guard arrived.
#
# So require every QML file that calls showTooltip() to declare
# tooltipHovered. The scan is per file, which is coarse but enough to catch a
# widget that never heard of the property.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

function scan {
  local root=$1 file

  while IFS= read -r file; do
    if ! grep -Eq 'property[[:space:]]+bool[[:space:]]+tooltipHovered\b' "$file"; then
      printf '%s\n' "${file#"$root"/}"
    fi
  done < <(grep -rlE --include='*.qml' '\bbar\.showTooltip\(' "$root/shell")
}

violations=$(scan "$ROOT")

if [[ -n $violations ]]; then
  fail "every widget that calls showTooltip declares tooltipHovered" \
    "$violations

These files call bar.showTooltip() but never declare tooltipHovered, so the
bar drops their tooltips. Add, for example:
  readonly property bool tooltipHovered: visible && mouseArea.containsMouse"
fi

pass "every widget that calls showTooltip declares tooltipHovered"

# The scan's own tests: one fixture it must report and one it must leave alone,
# so a scan that matches nothing (or everything) cannot pass.
fixture_root=$(mktemp -d)
trap 'rm -rf "$fixture_root"' EXIT

function scan_fixture {
  local name=$1
  local dir="$fixture_root/$name"
  mkdir -p "$dir/shell/plugins"
  cat > "$dir/shell/plugins/Fixture.qml"
  scan "$dir"
}

output=$(scan_fixture missing <<'QML'
import QtQuick
Item {
  id: root
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: if (root.bar) root.bar.showTooltip(root, "title")
  }
}
QML
)
if [[ -z $output ]]; then
  fail "the scan reports a widget that calls showTooltip without tooltipHovered" "the scan reported nothing"
fi
pass "the scan reports a widget that calls showTooltip without tooltipHovered"

output=$(scan_fixture declared <<'QML'
import QtQuick
Item {
  id: root
  readonly property bool tooltipHovered: visible && mouseArea.containsMouse
  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    onEntered: if (root.bar) root.bar.showTooltip(root, "title")
  }
}
QML
)
if [[ -n $output ]]; then
  fail "the scan leaves a widget that declares tooltipHovered alone" "the scan reported: $output"
fi
pass "the scan leaves a widget that declares tooltipHovered alone"
