#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command lua
lua "$SHELL_TEST_DIR/fixtures/workspace-order/test.lua" "$ROOT/default/hypr/workspace-order.lua"
