#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
require_command jq

python3 "$ROOT/test/shell.d/fixtures/transcode-batch.py"

# Real images catch frame splitting that the encoder doubles cannot exercise.
if "$ROOT/bin/omarchy-cmd-present" magick; then
  python3 "$ROOT/test/shell.d/fixtures/transcode-animated-image.py"
else
  skip "animated picture conversions need ImageMagick"
fi
