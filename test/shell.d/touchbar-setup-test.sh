#!/bin/bash
# Prebuilt package/user orchestration, isolated from the active desktop.
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
python3 "$ROOT/test/shell.d/touchbar-setup-fixture.py" "$ROOT"
