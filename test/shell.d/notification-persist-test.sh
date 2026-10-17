#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

PERSIST="$ROOT/bin/omarchy-notification-persist"

[[ -x $PERSIST ]] || fail "notification persist helper is executable"

tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
state="$tmp/notifications"
images="$state/images"
history="$state/history"

# Linux rejects a single argv string at MAX_ARG_STRLEN (131072 bytes). That is
# the failure the old implementation walked into: the serialized notification
# was one argument to `bash -c`, so a large body failed to spawn and wedged the
# serialized persistence queue behind it.
oversized_arg=$(head -c 140000 /dev/zero | tr '\0' 'x')
if bash -c 'printf "%s" "$1" >/dev/null' -- "$oversized_arg" 2>/dev/null; then
  fail "Linux rejects an oversized single argv"
fi
pass "Linux rejects an oversized single argv"

# A normal notification persists through the helper, body intact.
normal_json='{"id":1,"originalId":1,"summary":"normal","body":"hello","timestamp":100}'
printf '%s\n' "$normal_json" | "$PERSIST" "$state" "$images" "100-1.json" ||
  fail "normal notification persists"
[[ -f $state/100-1.json ]] || fail "normal notification file exists"
grep -q '"body":"hello"' "$state/100-1.json" || fail "normal notification body round-trips"
pass "normal notification persists"

# Image copies run before the JSON and are bounded: a small image lands intact,
# an oversized one is dropped rather than filling the state dir.
printf 'PNGDATA' > "$tmp/small.png"
printf '%s\n' "$normal_json" | "$PERSIST" "$state" "$images" "100-1.json" \
  "$tmp/small.png" "$images/100-1-image" ||
  fail "small image copy lands"
[[ -f $images/100-1-image ]] || fail "small image copy file exists"
grep -q 'PNGDATA' "$images/100-1-image" || fail "small image copy is intact"
pass "small image copy lands"

head -c 5242881 /dev/zero > "$tmp/big.png"
printf '%s\n' "$normal_json" | "$PERSIST" "$state" "$images" "100-1.json" \
  "$tmp/big.png" "$images/100-1-big" ||
  fail "oversized image is skipped without failing the job"
[[ ! -e $images/100-1-big ]] || fail "oversized image copy is dropped"
pass "oversized image copy is dropped"

# A notification whose serialized JSON crosses MAX_ARG_STRLEN persists with its
# body intact. The marker at the end catches a fix that silently truncates.
huge_body="$(head -c 140000 /dev/zero | tr '\0' 'x')TAILMARKER"
huge_json="{\"id\":2,\"originalId\":2,\"summary\":\"huge\",\"body\":\"$huge_body\",\"timestamp\":200}"
(( ${#huge_json} > 131072 )) || fail "oversized notification JSON crosses MAX_ARG_STRLEN"

printf '%s\n' "$huge_json" | "$PERSIST" "$state" "$images" "200-2.json" ||
  fail "oversized notification persists"
[[ -f $state/200-2.json ]] || fail "oversized notification file exists"
grep -q 'TAILMARKER' "$state/200-2.json" || fail "oversized notification body is not truncated"
pass "oversized notification persists with its body intact"

# A second notification can still be persisted after an oversized one. These
# are two sequential helper invocations, not Service.qml's serial queue; the
# real queue is covered by test/acceptance.d/notifications-persistence-test.sh.
later_json='{"id":3,"originalId":3,"summary":"later","body":"after","timestamp":300}'
printf '%s\n' "$later_json" | "$PERSIST" "$state" "$images" "300-3.json" ||
  fail "a second notification can be persisted after an oversized notification"
[[ -f $state/300-3.json ]] || fail "second notification file exists"
pass "a second notification can be persisted after an oversized notification"

# The history path shares the transport, so it accepts an oversized body too and
# still trims the directory to the newest entries afterwards.
for i in 1 2 3; do
  printf '%s\n' "{\"id\":$i,\"originalId\":$i,\"timestamp\":$((400 + i))}" |
    "$PERSIST" --history 2 "$history" "$images" "$((400 + i))-$i.json" ||
    fail "history entry $i persists"
done
printf '%s\n' "$huge_json" | "$PERSIST" --history 2 "$history" "$images" "500-9.json" ||
  fail "oversized history entry persists"
grep -q 'TAILMARKER' "$history/500-9.json" || fail "oversized history body is not truncated"
(( $(find "$history" -name '*.json' | wc -l) == 2 )) || fail "history trims to the newest entries"
pass "history persists oversized bodies and trims to the newest entries"
