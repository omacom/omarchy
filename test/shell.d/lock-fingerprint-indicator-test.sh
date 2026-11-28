#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint indicator test"

run_qml_fixture lock-fingerprint-indicator "fingerprint indicator tracks the configured sensor and password dots fit beside it" Ui Commons
