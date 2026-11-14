#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "wheel scroll test"

# Style reads Hyprland options at startup; the fixture sets them itself.
qml_fixture_scratch
printf '#!/bin/bash\necho "{}"\n' >"$QML_FIXTURE_TMP/bin/hyprctl"
chmod +x "$QML_FIXTURE_TMP/bin/hyprctl"

run_qml_fixture wheel-scroll "touchpad scrolling follows the fingers, coasts after a flick and stops at the ends" Ui Commons
