#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Pango sets lang as a string, and a string contains test is a substring match,
# so a bare <string>ar</string> also catches es-ar and pulls Latin digits into Naskh.
string_lang_tests=$(rg -U -n '<test name="lang"[^>]*>\s*<string>' "$ROOT/default/fontconfig" || true)
[[ -z $string_lang_tests ]] || fail "fontconfig lang tests compare against a langset" "$string_lang_tests"
pass "fontconfig lang tests compare against a langset"
