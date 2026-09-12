#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# python-gobject and NetworkManager are both in Omarchy's base package set.
# Use the system interpreter, just as the privileged importer does.
/usr/bin/python3 "$ROOT/test/shell.d/fixtures/iwd-network-import.py" "$ROOT"
pass "iwd profiles survive the NetworkManager transition"
