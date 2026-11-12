#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "bar style test"

run_qml_fixture bar-style "shell.toml [bar] style selects strip or islands" Commons
