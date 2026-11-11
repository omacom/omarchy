#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

PYTHONDONTWRITEBYTECODE=1 /usr/bin/python3 "$ROOT/test/shell.d/fixtures/apple-display-profile-test.py" -v
