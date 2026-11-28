#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const weather = requireFromRoot('shell/plugins/panels/weather/Model.js')

assert(weather.shouldAcceptProvisionalIcon(true, ''), 'weather accepts wttr provisional icon for empty label with pinned coordinates')
assert(!weather.shouldAcceptProvisionalIcon(true, 'night'), 'weather ignores wttr provisional icon when coordinates are pinned and icon is resolved')
assert(weather.shouldAcceptProvisionalIcon(false, 'night'), 'weather evaluates wttr provisional icon when coordinates are not configured')
JS
