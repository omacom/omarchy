#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export OMARCHY_PATH=$ROOT XDG_CONFIG_HOME=$work/config NOTIFY_LOG=$work/notify.log
mkdir -p "$work/stubs"
printf '#!/bin/bash\n' >"$work/stubs/omarchy-restart-shell"
printf '#!/bin/bash\necho "$@" >>"$NOTIFY_LOG"\n' >"$work/stubs/omarchy-notification-send"
chmod +x "$work/stubs/"*
export PATH="$work/stubs:$ROOT/bin:$PATH"
preference=$XDG_CONFIG_HOME/fontconfig/conf.d/50-omarchy-input-method.conf

[[ $(omarchy-font-cjk) == "default" ]] || fail "with no preference the CJK forms are the default" "$(omarchy-font-cjk)"
pass "with no preference the CJK forms are the default"

omarchy-font-cjk tc
grep -q 'Noto Sans CJK TC' "$preference" || fail "setting tc writes the preference"
[[ $(omarchy-font-cjk) == "tc" ]] || fail "the current forms read back as set" "$(omarchy-font-cjk)"
grep -q "$(omarchy-i18n font.cjkChanged)" "$NOTIFY_LOG" || fail "a change is announced" "$(cat "$NOTIFY_LOG")"
pass "setting the CJK forms writes, reads back and announces the choice"

# A preference the first input method seeded reads back and can be changed.
rm "$preference"
python3 "$ROOT/default/input-methods/configure.py" font --seed kr
[[ $(omarchy-font-cjk) == "kr" ]] || fail "a seeded preference reads back" "$(omarchy-font-cjk)"
omarchy-font-cjk hk
[[ $(omarchy-font-cjk) == "hk" ]] || fail "a seeded preference can be changed" "$(omarchy-font-cjk)"
pass "the preference an input method seeded is the one the command changes"

omarchy-font-cjk default
[[ $(omarchy-font-cjk) == "default" ]] || fail "default reads back" "$(omarchy-font-cjk)"
! grep -q 'CJK' "$preference" || fail "default names no CJK forms" "$(cat "$preference")"
python3 "$ROOT/default/input-methods/configure.py" font --seed kr
[[ $(omarchy-font-cjk) == "default" ]] || fail "a later language or input method keeps an explicit default" "$(omarchy-font-cjk)"
pass "default returns to the system's choice, and later seeding keeps it"

if omarchy-font-cjk cn 2>/dev/null; then
  fail "an unknown variant is refused"
fi
pass "an unknown variant is refused"

