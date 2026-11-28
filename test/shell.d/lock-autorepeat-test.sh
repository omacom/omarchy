#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock autorepeat test"

run_qml_fixture lock-autorepeat "lock password field drops auto-repeat except Backspace/Delete" Ui Commons
