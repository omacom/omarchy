#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Registry and inline-loader checks need a QML engine, not a compositor.
if [[ ${QT_QPA_PLATFORM:-} == "offscreen" ]]; then
  require_command quickshell
  require_command jq
else
  require_quickshell "plugin registry contract test"
fi

run_qml_fixture plugin-registry "plugin registry contract checks pass" services Commons Ui
