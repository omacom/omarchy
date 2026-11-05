#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "apps overlay test"
run_qml_fixture apps "app grid searches and launches with the dock disabled, enabled or cloned" Ui Commons services
