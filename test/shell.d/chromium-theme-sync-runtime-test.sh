#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command node
require_command jq
require_command flock

node --test "$ROOT/test/shell.d/fixtures/chromium-theme-sync/"*.test.mjs
pass "theme sync worker, page API, and native host regressions"
