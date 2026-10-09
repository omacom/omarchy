#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command dbus-run-session
require_command quickshell

ulimit -c 0

dbus-run-session --config-file "$ROOT/test/shell.d/fixtures/session-lock-bridge/bus.conf" -- \
  python3 "$ROOT/test/shell.d/fixtures/session-lock-bridge.py"
