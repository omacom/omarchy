#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
runner=/usr/lib/qt6/bin/qmltestrunner
if [[ ! -x $runner ]]; then
  skip 'display canvas mouse regression requires Qt6 qmltestrunner'
  exit 0
fi
sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT
cp -R "$ROOT/test/shell.d/fixtures/display-layout/"* "$sandbox/"
cp "$ROOT/shell/plugins/panels/display-settings/"{LayoutCanvas.qml,LayoutModel.js,WorkspaceAssignments.qml} "$sandbox/"
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software "$runner" -input "$sandbox" -import "$sandbox"
