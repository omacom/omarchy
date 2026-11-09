#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "context menu popup"
run_qml_fixture context-menu "context menu opens, navigates, activates, and closes on escape" Ui Commons
