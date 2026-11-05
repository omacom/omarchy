#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "layer-surface launch feedback test"
qml_fixture_scratch
cat >"$QML_FIXTURE_TMP/bin/omarchy-shell" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-shell"
run_qml_fixture app-launch-layer "launch feedback follows matching layer surfaces and ordinary windows" services Commons
