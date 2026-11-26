#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "menu label marquee runtime test"

run_qml_fixture menu-marquee "a cut-off menu label scrolls to its end under the cursor and rests when the cursor leaves" Ui Commons
