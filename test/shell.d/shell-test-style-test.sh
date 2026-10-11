#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# lua with no script argument runs stdin but ignores its error and exits 0, so
# assertions in a bare heredoc cannot fail their test. lua - treats it as a script.
stdin_lua=$(rg -l -P '\blua[[:space:]]*<<' "$SHELL_TEST_DIR" || true)
[[ -z $stdin_lua ]] || fail "shell tests run Lua heredocs as scripts" "$stdin_lua"
pass "shell tests run Lua heredocs as scripts"
