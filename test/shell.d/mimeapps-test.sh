#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

mimeapps="$ROOT/default/applications/mimeapps.list"

[[ -f $mimeapps ]] || fail "default mimeapps.list exists"

image_handlers=$(grep -E '^image/[^=]+=' "$mimeapps" | cut -d= -f2 | sort -u)
[[ -n $image_handlers ]] || fail "default mimeapps.list registers image handlers"

# imv.desktop opens only the file it is given, so arrow-key navigation has no
# list to move through. imv-dir.desktop opens the containing folder starting
# on the clicked photo instead.
[[ $image_handlers == "imv-dir.desktop" ]] ||
  fail "image defaults open through imv-dir for folder navigation" "$image_handlers"
pass "image defaults open through imv-dir for folder navigation"

if grep -Eq '^image/[^=]+=imv\.desktop$' "$mimeapps"; then
  fail "no image default points at single-file imv.desktop"
fi
pass "no image default points at single-file imv.desktop"
