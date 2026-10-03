#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Run only through the disposable-VM acceptance workflow.
python3 "$ROOT/test/acceptance.d/fixtures/bar-reservation.py" "$ARTIFACTS"
