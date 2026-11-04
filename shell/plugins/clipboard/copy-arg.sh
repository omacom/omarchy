#!/bin/bash
# Copy one argument to the Wayland clipboard as plain text. Used for values
# this plugin composes (OCR, QR, colour formats, edited text) so no shell ever
# re-parses them.

set -euo pipefail
printf '%s' "${1-}" | wl-copy --type text/plain
