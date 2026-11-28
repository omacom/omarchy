#!/bin/bash
# Builds Omarchy.Ttfx with its smoke test and runs it on Qt Quick's software
# backend, offscreen, as the boot splash draws (no GPU). Build output stays
# under ${TMPDIR:-/var/tmp}; nothing is removed afterwards.

set -euo pipefail

here=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
build=${TTFX_QML_BUILD:-${TMPDIR:-/var/tmp}/omarchy-ttfx-qml-build}

cmake -S "$here/.." -B "$build" -DCMAKE_BUILD_TYPE=Release -DTTFX_QML_TESTS=ON >/dev/null
cmake --build "$build" -j"$(nproc)"

QT_QPA_PLATFORM=offscreen "$build/ttfx-qml-smoke" "$build/qml" "$here/smoke.qml" "${1:-}"
echo "ttfx-qml smoke test: PASS"
