#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
touch "$scratch/input.png"
export CONVERT_LOG="$scratch/convert" NUMERIC_SENTINEL="$scratch/evaluated"
cat >"$scratch/bin/magick" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CONVERT_LOG"
if [[ " $* " == *" -format "* ]]; then printf '0 1\n'; else printf 'P1\n2 2\n1 0 0 1\n'; fi
SH
chmod +x "$scratch/bin/magick"
export PATH="$scratch/bin:$PATH"
for option in width height threshold; do
  for value in 'a[$(touch "$NUMERIC_SENTINEL")]' 99999999999999999999999999 -1; do
    : >"$CONVERT_LOG"
    if bash "$ROOT/bin/omarchy-transcode-ascii" "$scratch/input.png" "$scratch/out" "--$option" "$value" >"$scratch/log" 2>&1; then
      fail "an invalid $option is refused"
    fi
    [[ ! -s $CONVERT_LOG && ! -e $NUMERIC_SENTINEL ]] || fail "invalid numeric data is neither evaluated nor sent to the converter"
  done
done
pass "dimensions and threshold reject expressions, oversized integers and negative values before conversion"
for pair in width:0 width:1001 height:0 height:1001 threshold:101 threshold:100.000001; do
  : >"$CONVERT_LOG"
  if bash "$ROOT/bin/omarchy-transcode-ascii" "$scratch/input.png" "$scratch/out" "--${pair%%:*}" "${pair#*:}" >"$scratch/log" 2>&1; then
    fail "out-of-range ${pair%%:*} is refused"
  fi
  [[ ! -s $CONVERT_LOG ]] || fail "out-of-range data never reaches the converter"
done
pass "valid numeric syntax still has to satisfy the dimensions and percentage bounds"
bash "$ROOT/bin/omarchy-transcode-ascii" "$scratch/input.png" "$scratch/out" --width 011 --height 009 --threshold 50.5 >"$scratch/log" 2>&1 || fail "decimal dimensions with leading zeros and fractional thresholds work" "$(cat "$scratch/log")"
grep -q -- '-resize 22x36' "$CONVERT_LOG" || fail "dimensions are decimal, including digits above seven"
[[ -s $scratch/out ]] || fail "valid dimensions still produce art"
pass "valid dimensions with leading zeros are decimal and still produce art"
