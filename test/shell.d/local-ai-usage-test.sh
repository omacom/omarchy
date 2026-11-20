#!/bin/bash
# The usage summary: appends, a half-written line, a completed line and a truncated log are all counted right, and a
# log that has not changed is not read again
set -u
source "$(dirname "$0")/base-test.sh"
export OMARCHY_PATH=$ROOT
B=${BACKEND:-$ROOT/bin/omarchy-local-ai}
FNS=$(mktemp); sed '/^paths "\$HOME"$/,$d' "$B" >"$FNS"
T=$(mktemp -d); D=$T/usage/m; mkdir -p "$D"
line() { printf '{"t":%d,"prompt":%d,"completion":10,"ms":500,"ttft_ms":50}\n' "$EPOCHSECONDS" "$1"; }
req() { bash -c "set -euo pipefail; shopt -s nullglob; source $FNS >/dev/null 2>&1; summary '$D'" | jq -r '"\(.requests) \(.total)"'; }
check() { local got; got=$(req); [[ $got == "$1" ]] && echo "ok - $2 ($got)" || { echo "not ok - $2: want $1, got $got"; exit 1; }; }
line 100 >"$D/usage.jsonl"; line 200 >>"$D/usage.jsonl"; line 300 >>"$D/usage.jsonl"
check "3 630" "three lines"
check "3 630" "unchanged: read from the summary"
line 400 >>"$D/usage.jsonl"; line 500 >>"$D/usage.jsonl"
check "5 1550" "two appended lines"
printf '{"t":%d,"prompt":600,' "$EPOCHSECONDS" >>"$D/usage.jsonl"
check "5 1550" "a half-written line waits"
printf '"completion":10,"ms":500,"ttft_ms":50}\n' >>"$D/usage.jsonl"
check "6 2160" "the line, once written, is counted"
line 700 >"$D/usage.jsonl"
check "1 710" "a truncated log is summed again"
sleep 1.1; line 800 >>"$D/usage.jsonl"
check "2 1520" "a line a second later"
week=$(bash -c "source '$FNS'; STATE='$T'; session m '$EPOCHSECONDS'" | jq -r .week)
[[ $week == 1520 ]] || { echo "not ok - model weekly tokens: $week"; exit 1; }
echo 'ok - weekly tokens belong to this model'
rm -f "$D/summary.json"
line 1 | awk '{for(i=0;i<200005;i++)print}' >"$D/usage.jsonl"
check "200005 2200055" "large logs cross the 100000-line boundary without SIGPIPE"
# UTC-hour buckets overlap local midnight in half-hour and quarter-hour zones.
# Only requests after local midnight belong in the weekly total, even within the same UTC hour.
for zone in Asia/Kolkata Asia/Kathmandu; do
  export TZ=$zone
  boundary=$(date -d '6 days ago 00:05' +%s)
  printf '{"t":%d,"prompt":77,"completion":3,"ms":500,"ttft_ms":50}\n' "$boundary" >"$D/usage.jsonl"
  printf '{"t":%d,"prompt":997,"completion":3,"ms":500,"ttft_ms":50}\n' "$((boundary - 600))" >>"$D/usage.jsonl"
  rm -f "$D/summary.json"
  week=$(bash -c "source '$FNS'; STATE='$T'; session m '$EPOCHSECONDS'" | jq -r .week)
  total=$(bash -c "source '$FNS'; STATE='$T'; tokens" | jq -r .week)
  [[ $week == 80 && $total == 80 ]] || { echo "not ok - midnight bucket $zone: model=$week total=$total"; exit 1; }
done
echo 'ok - weekly boundary excludes requests before half-hour and quarter-hour midnight'
# Changing timezones rebuilds the cached local-day counts.
export TZ=UTC
week=$(bash -c "source '$FNS'; STATE='$T'; session m '$EPOCHSECONDS'" | jq -r .week)
[[ $week == 0 ]] || { echo "not ok - timezone change: $week"; exit 1; }
echo 'ok - timezone change rebuilds local-day counts'
rm -rf "$T" "$FNS"
