#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
require_command jq
if ! "$ROOT/bin/omarchy-cmd-present" magick; then
  skip "animated picture conversions need ImageMagick"
  exit 0
fi

python3 "$ROOT/test/shell.d/fixtures/transcode-animated-image.py"
