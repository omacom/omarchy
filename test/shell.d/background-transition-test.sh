#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# OpenGL-backed Qt Quick rendering in a private X server: no desktop surfaces,
# compositor, or user state. The software Qt Quick backend cannot render masks.
for dependency in python quickshell magick vipsheader xvfb-run Xvfb xauth; do
  if ! command -v "$dependency" >/dev/null; then
    skip "$dependency unavailable; skipping rendered background transition fixture"
    exit 0
  fi
done

# Set OMARCHY_BACKGROUND_TEST_DIR to retain screenshots after a successful run.
render_dir=${OMARCHY_BACKGROUND_TEST_DIR:-$(mktemp -d /tmp/omarchy-background-render.XXXXXX)}
trap 'if (( $? == 0 )) && [[ -z ${OMARCHY_BACKGROUND_TEST_DIR:-} ]]; then rm -rf "$render_dir"; fi' EXIT
ulimit -c 0 2>/dev/null || true

if ! env -u WAYLAND_DISPLAY -u QT_QUICK_BACKEND -u QSG_RHI_BACKEND \
  QT_QPA_PLATFORM=xcb QT_QPA_PLATFORMTHEME=basic LIBGL_ALWAYS_SOFTWARE=1 \
  xvfb-run -a python "$SHELL_TEST_DIR/fixtures/background-transition/render-test.py" "$ROOT" "$render_dir"; then
  fail "rendered background transitions preserve per-output frames" "Artifacts: $render_dir"
fi
pass "rendered transitions hold per-output variants until presented and instant reloads replace same-path pixels"
