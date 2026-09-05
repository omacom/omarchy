#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

shell="$ROOT/shell/shell.qml"
handler=$(awk '/id: pluginBarLoader/,/^  }/' "$shell")

grep -q 'shell.failedBarId = failedId' <<<"$handler" ||
  fail "a failed custom bar still records failedBarId"
if grep -q 'errorString && errorString()' <<<"$handler"; then
  fail "bar load errors must not call an unbound errorString identifier"
fi

failed_line=$(grep -n 'shell.failedBarId = failedId' <<<"$handler" | head -n 1 | cut -d: -f1)
error_line=$(grep -n 'sourceComponent.errorString()' <<<"$handler" | head -n 1 | cut -d: -f1)
[[ -n $failed_line && -n $error_line ]] ||
  fail "bar load errors record failedBarId and read Component.errorString"
(( failed_line < error_line )) ||
  fail "failedBarId is recorded before errorString is read"
pass "a failed custom bar still records failedBarId"
