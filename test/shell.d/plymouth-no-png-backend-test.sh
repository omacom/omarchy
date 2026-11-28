#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

[[ ! -e $ROOT/bin/omarchy-plymouth-effect-render ]] ||
  fail "obsolete PNG renderer remains in the product tree"

if grep -R -E 'parity-dump|animation/frame-[^[:space:]]*\.png|logo\.frames|logo_animation_frame|logo_animation_tick' \
  "$ROOT/bin" "$ROOT/default/plymouth" "$ROOT/migrations" \
  --exclude='*.pyc' >/dev/null; then
  fail "installed product path still renders or loads PNG frame sequences"
fi

[[ -f $ROOT/default/plymouth/omarchy.script ]] || fail "static recovery script is missing"
grep -Fq 'logo.image = Image("logo.png")' "$ROOT/default/plymouth/omarchy.script" ||
  fail "static recovery script no longer renders the recovery logo"

grep -Fq "s/^ModuleName=.*/ModuleName=script/" "$ROOT/bin/omarchy-plymouth-ttfx-build" ||
  fail "static recovery staging no longer selects the script plugin"

pass "product path contains native TTFX plus static recovery, with no PNG animation backend"
