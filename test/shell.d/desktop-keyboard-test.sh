#!/bin/bash

set -euo pipefail

# shellcheck source=base-test.sh
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 "$ROOT/test/helpers/desktop-keyboard-process.py"
