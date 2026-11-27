#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "bar label centering test"

run_qml_fixture bar-label-centering "bar labels center on the ink their figures paint" Ui Commons
