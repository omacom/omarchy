#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command lua
export XDG_RUNTIME_DIR
XDG_RUNTIME_DIR=$(mktemp -d)
trap 'rm -rf "$XDG_RUNTIME_DIR"' EXIT
lua "$ROOT/test/shell.d/fixtures/startup-cursor/monitorless.lua"
pass "completed startup stays completed across a monitorless reload"
