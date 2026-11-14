#!/bin/bash
# omarchy:exclusive - opens a fullscreen menu that takes the keyboard.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "menu select confirm test"

# Nothing the menu runs may reach the desktop's own shell.
qml_fixture_scratch
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-shell"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-shell"

run_qml_fixture menu-select-confirm "menu select confirms a pick in place, and the Apps menu's uninstall prompt still closes on an outside click" Ui Commons
