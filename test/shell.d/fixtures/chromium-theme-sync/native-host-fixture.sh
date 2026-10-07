#!/bin/bash
set -uo pipefail

# Refuse to source the host unless every path it touches is the test sandbox.
[[ -n ${TEST_ROOT:-} && $HOME == "$TEST_ROOT/home" && $XDG_RUNTIME_DIR == "$TEST_ROOT/runtime" ]] || exit 90

source "${BASH_SOURCE[0]%/*}/../../../../bin/omarchy-browser-theme-host"

emit_palette
read_requests
