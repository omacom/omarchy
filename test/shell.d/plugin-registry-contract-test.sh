#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "plugin registry contract test"

run_qml_fixture plugin-registry "plugin registry contract checks pass" services Commons
