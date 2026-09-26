#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! python -c 'import PySide6.QtQuick' >/dev/null 2>&1; then
  skip "offscreen shadow rendering requires optional Python PySide6"
  exit 0
fi

# No live desktop or shell process: render a small Qt Quick scene offscreen.
# grabWindow() and Loader teardown are driven synchronously by the fixture;
# use the basic render loop rather than waiting on an offscreen render thread.
QT_QPA_PLATFORM=offscreen QSG_RHI_BACKEND=opengl QT_QUICK_BACKEND=rhi QSG_RENDER_LOOP=basic \
  python "$ROOT/test/shell.d/fixtures/surface-shadow-render.py"
