#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "bar drag test"

# The bar syncs the compositor's blur to its background as it starts.
qml_fixture_scratch
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-bar"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-bar"

run_qml_fixture bar-drag "dragged widgets land where dropped, as the instances dragged" Ui Commons
