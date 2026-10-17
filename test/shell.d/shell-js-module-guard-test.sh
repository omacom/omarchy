#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

# shell/**/*.js files are QML JS modules, not CommonJS. A trailing
# `if (typeof module !== "undefined") { module.exports = ... }` block looks
# harmless, but QML evaluates a non-.pragma module again for every delegate
# that imports it, and the `module` lookup walks the delegate's context into
# Qt's list accessor. When a Repeater's array model holds a destroyed object,
# that lookup crashes Quickshell (#11727). Tests reach these files through
# test/shell.d/js-model-loader.js instead.

offenders=$(grep -rnE --include='*.js' \
  'typeof +(module|exports|require)\b|\bmodule\.exports\b|^\s*exports\.|\brequire\(' \
  "$ROOT/shell" | sed "s|^$ROOT/||" || true)

[[ -z $offenders ]] ||
  fail "shell JS modules carry no CommonJS module, exports or require code" "$offenders"
pass "shell JS modules carry no CommonJS module, exports or require code"
