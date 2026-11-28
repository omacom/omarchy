#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "emoji picker scroll and pointer gate test"

run_qml_fixture emojis-scroll "emoji picker wheel scrolls by rows and gates hover under a stationary pointer" Ui Commons
