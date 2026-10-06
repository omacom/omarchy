#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "overlay output recovery runtime test"

for tool in Hyprland quickshell hyprctl wtype python; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    skip "$tool not installed; skipping overlay output recovery runtime test"
    exit 0
  fi
done

python "$SHELL_TEST_DIR/fixtures/overlay-output-recovery/run.py" "$ROOT"
python "$SHELL_TEST_DIR/fixtures/overlay-output-recovery/run.py" "$ROOT" --zero-output-open
