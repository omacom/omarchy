#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "ConfirmDialog button layout test"

# English, and the languages whose words for Uninstall run longest.
for language in en de id ru; do
  qml_fixture_scratch
  # Each run links Ui and Commons afresh; a link left from the last one would
  # make ln write into the linked directory instead.
  rm -rf "$QML_FIXTURE_TMP/confirm-dialog"
  printf '%s\n' "$language" >"$QML_FIXTURE_TMP/language"
  OMARCHY_LANGUAGE_FILE="$QML_FIXTURE_TMP/language" CONFIRM_DIALOG_LANGUAGE="$language" \
    run_qml_fixture confirm-dialog "ConfirmDialog labels stay inside their buttons and the card ($language)" Ui Commons
  jq -r '.measurements[] | "# \(.host)px \(.name): " + ([.buttons[] | "\(.text) \(.width)/\(.natural)\(if .truncated then " cut" else "" end)"] | join(", "))' \
    "$QML_FIXTURE_TMP/result.json"
done
