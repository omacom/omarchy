#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command c++
temp=$(mktemp -d)
trap 'rm -rf "$temp"' EXIT
c++ -std=c++23 -Wall -Wextra -Werror "$ROOT/test/fixtures/float-snap/geometry-test.cpp" -o "$temp/geometry-test"
"$temp/geometry-test"
echo 'PASS: Float Snap edge, corner, move, bounds, offset and continuous-drag geometry'
