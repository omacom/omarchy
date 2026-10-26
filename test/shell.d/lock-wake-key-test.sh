#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock wake key test"

run_qml_fixture lock-wake-key "a key pressed at a dark lock screen wakes it without typing" Ui Commons
