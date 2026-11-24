#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

# Every curated package needs a polkit action naming it, or installing it asks
# for a password with polkit's generic prompt; and every action needs its
# package on the list, or the helper refuses what polkit allowed.
script="$ROOT/bin/omarchy-pkg-add-curated"
policy="$ROOT/default/polkit/org.omarchy.pkg-add-curated.policy"

listed=$(sed -n '/^curated() {/,/^}/p' "$script" | grep -oE '[a-z0-9][a-z0-9-]+' | grep -vxE 'curated|case|in|return|esac' | sort)
actions=$(grep -oE 'exec\.argv1">[^<]+' "$policy" | cut -d'>' -f2 | sort)
[[ -n $listed && $listed == "$actions" ]] ||
  fail "the curated list and its polkit actions name the same packages" "$(diff <(echo "$listed") <(echo "$actions"))"
grep -c '<allow_active>yes</allow_active>' "$policy" | grep -qx "$(wc -l <<<"$actions")" ||
  fail "every curated action installs without a password at the machine"
! grep -q '<allow_any>yes\|<allow_inactive>yes' "$policy" ||
  fail "a curated action asks for a password away from the machine"
pass "the curated list and its polkit actions agree"
