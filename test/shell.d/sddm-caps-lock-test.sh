#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "SDDM caps lock test"

# The theme imports SddmComponents without using it, and CI has no SDDM, so run
# a copy without that import; the fixture stands in for the greeter's context.
qml_fixture_scratch
sed '/^import SddmComponents/d' "$ROOT/default/sddm/omarchy/Main.qml" >"$QML_FIXTURE_TMP/Main.qml"
# The images give the password field its real size.
cp "$ROOT"/default/sddm/omarchy/*.png "$QML_FIXTURE_TMP/"

OMARCHY_SDDM_THEME_QML="$QML_FIXTURE_TMP/Main.qml" \
  run_qml_fixture sddm-caps-lock "login screen caps lock icon shows Caps Lock as read from typed keys and stays clear of the password dots"
