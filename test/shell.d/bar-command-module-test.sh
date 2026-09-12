#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

bar="$ROOT/shell/plugins/bar/Bar.qml"

if grep -q 'outputText = data.text ||' "$bar"; then
  fail "command modules do not treat empty JSON text as missing"
fi
grep -Fq 'data.text !== undefined && data.text !== null' "$bar" ||
  fail "command modules treat an explicit JSON text field as provided"
grep -Fq 'jsonProvidedText = true' "$bar" ||
  fail "command modules remember when JSON supplied a text field"
grep -Fq 'text: jsonProvidedText ? outputText : (outputText || String(setting("text", "")))' "$bar" ||
  fail "command modules keep empty JSON text empty instead of falling back to setting text"
pass "command modules keep empty JSON text empty"
