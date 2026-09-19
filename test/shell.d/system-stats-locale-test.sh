#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-system-stats"

grep -q 'LC_ALL=C LC_NUMERIC=C top -bn1' "$script" || fail "system stats forces C locale for top"
grep -q 'sub(/,$/, "", label)' "$script" || fail "system stats strips trailing commas from top labels"
grep -q 'gsub(/,/, ".", idle)' "$script" || fail "system stats treats comma as decimal separator"

parse_cpu() {
  awk '/^%?Cpu/ {
    for (i = 1; i <= NF; i++) {
      label = $(i + 1)
      sub(/,$/, "", label)
      if (label == "id") {
        idle = $i
        gsub(/,/, ".", idle)
        printf "%.0f%%", 100 - idle
        exit
      }
    }
  }'
}

c_locale=$(printf '%s\n' '%Cpu(s):  5.6 us,  3.4 sy,  0.0 ni, 84.3 id,  4.5 wa,  1.1 hi,  1.1 si,  0.0 st' | parse_cpu)
[[ $c_locale == "16%" ]] || fail "cpu percentage from C-locale top idle is 16%" "$c_locale"
pass "cpu percentage from C-locale top idle is 16%"

comma_locale=$(printf '%s\n' '%Cpu(s):  5,6 us,  3,4 sy,  0,0 ni,  84,3 id,  4,5 wa,  1,1 hi,  1,1 si,  0,0 st' | parse_cpu)
[[ $comma_locale == "16%" ]] || fail "cpu percentage from comma-decimal top idle is 16%" "$comma_locale"
pass "cpu percentage from comma-decimal top idle is 16%"
