#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT

# A checkout (or ISO live environment) can live under a path with spaces. The
# loader must quote $OMARCHY_PATH while leaving the glob unquoted, or the path
# word-splits and every function fails to source.
omarchy_path="$test_dir/omarchy path"
mkdir -p "$omarchy_path/default/bash/fns"
cat >"$omarchy_path/default/bash/fns/sample" <<'FN'
sample_omarchy_function() { printf 'loaded\n'; }
FN

OMARCHY_PATH="$omarchy_path" source "$ROOT/default/bash/functions"

[[ $(type -t sample_omarchy_function) == "function" ]] || fail "functions load from an OMARCHY_PATH containing spaces"
pass "functions load from an OMARCHY_PATH containing spaces"

[[ $(sample_omarchy_function) == "loaded" ]] || fail "a loaded function is callable"
pass "a loaded function is callable"
