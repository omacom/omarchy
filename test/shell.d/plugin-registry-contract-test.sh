#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Registry and inline-loader checks need a QML engine, not a compositor.
if [[ ${QT_QPA_PLATFORM:-} == "offscreen" ]]; then
  require_command quickshell
  require_command jq
else
  require_quickshell "plugin registry contract test"
fi

run_qml_fixture plugin-registry "plugin registry contract checks pass" services Commons Ui

# Check the rendered output, not just the layout height: a collapsed root can
# still have painted children with positive heights.
sample_y=$(jq -r '.paintSampleY' "$QML_FIXTURE_TMP/result.json")
collapsed_red=$(magick "$QML_FIXTURE_TMP/result.json.collapsed.png" -format "%[fx:p{10,$sample_y}.r]" info:)
zero_red=$(magick "$QML_FIXTURE_TMP/result.json.zero.png" -format "%[fx:p{10,$sample_y}.r]" info:)
expanded_red=$(magick "$QML_FIXTURE_TMP/result.json.expanded.png" -format "%[fx:p{10,$sample_y}.r]" info:)
[[ $collapsed_red == "0" ]] || fail "collapsed extension does not paint over neighbouring content" "red channel: $collapsed_red"
[[ $zero_red == "0" ]] || fail "zero-height extension does not paint over neighbouring content" "red channel: $zero_red"
[[ $expanded_red == "1" ]] || fail "expanded extension still paints its controls" "red channel: $expanded_red"
pass "collapsed extension stays within its bounds and paints again when expanded"
