#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! python -c 'import PySide6.QtQuick' >/dev/null 2>&1; then
  skip "offscreen shadow rendering requires optional Python PySide6"
  exit 0
fi

# The offscreen plugin can be present without a usable OpenGL context. Probe
# in a separate process so a driver/plugin failure cannot abort the test run.
if ! QT_QPA_PLATFORM=offscreen QSG_RHI_BACKEND=opengl python - >/dev/null 2>&1 <<'PY'
from PySide6.QtGui import QGuiApplication, QOffscreenSurface, QOpenGLContext
app = QGuiApplication([])
surface = QOffscreenSurface()
surface.create()
context = QOpenGLContext()
raise SystemExit(0 if surface.isValid() and context.create() and context.makeCurrent(surface) else 1)
PY
then
  skip "offscreen shadow rendering requires a usable OpenGL context"
  exit 0
fi

# No live desktop or shell process: render a small Qt Quick scene offscreen.
# grabWindow() and Loader teardown are driven synchronously by the fixture;
# use the basic render loop rather than waiting on an offscreen render thread.
QT_QPA_PLATFORM=offscreen QSG_RHI_BACKEND=opengl QT_QUICK_BACKEND=rhi QSG_RENDER_LOOP=basic \
  python "$ROOT/test/shell.d/fixtures/surface-shadow-render.py"
