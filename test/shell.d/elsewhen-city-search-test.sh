#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "elsewhen city search test"

run_qml_fixture elsewhen-city-search "elsewhen city search picks on a Return that beat the geocoder" Ui Commons
