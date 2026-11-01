#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint service test"

run_qml_fixture lock-fingerprint-service "fingerprint service handles enrollment, failures and recovery" Ui Commons
