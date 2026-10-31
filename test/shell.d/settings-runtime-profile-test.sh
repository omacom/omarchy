#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The omarchy-settings recipe ships the same files on every architecture when
# the source has default/settings-runtime-profile, which lists the files that
# decide at runtime whether they apply. Every file it lists must exist.
profile="$ROOT/default/settings-runtime-profile"
[[ -f $profile ]] || fail "the source marks itself for the omarchy-settings recipe"

listed=$(grep -oE '(^|[[:space:]])(etc|default)/[^ ,]*' "$profile" | sed 's/^[[:space:]]*//' | sort -u)
[[ -n $listed ]] || fail "the runtime profile lists its files"
while IFS= read -r path; do
  [[ -e $ROOT/${path%/} ]] || fail "the runtime profile lists an existing file: $path"
done <<<"$listed"
pass "every file the runtime profile lists exists in the source"
