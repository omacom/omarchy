#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The fixtures feed OMARCHY_CPU_FLAGS, which the helper applies before its
# non-x86 pass path, so the level cases hold on any architecture.

helper="$ROOT/bin/omarchy-cpu-isa"
# The helper calls its siblings (omarchy-hw-x86, omarchy-cmd-present) by name,
# so they come from this checkout, not whatever is installed on the host.
export PATH="$ROOT/bin:$PATH"

live=$("$helper" --json)
[[ $live == *'"level":'* && $live == *'"avx2":'* ]] ||
  fail "live detection emits a valid record" "$live"
pass "live detection emits a valid record"

check_level() {
  local case_name="$1" flags="$2" expect_level="$3" expect_avx2="$4"
  local json
  json=$(OMARCHY_CPU_FLAGS="$flags" "$helper" --json)
  [[ $json == "{\"level\":\"$expect_level\",\"avx2\":$expect_avx2}" ]] ||
    fail "$case_name classifies" "expected: $expect_level/$expect_avx2
actual:   $json"
  if [[ $expect_avx2 == "true" ]]; then
    OMARCHY_CPU_FLAGS="$flags" "$helper" --avx2 || fail "$case_name --avx2 passes"
  else
    if OMARCHY_CPU_FLAGS="$flags" "$helper" --avx2; then
      fail "$case_name --avx2 rejects non-AVX2"
    fi
  fi
  pass "$case_name classifies and --avx2 agrees"
}

base="sse sse2"
v2="sse sse2 sse3 sse4_1 sse4_2 ssse3 cx16 popcnt lahf_lm pni fma avx f16c bmi1 abm xsave"
v3="$v2 avx2 bmi2 lzcnt movbe"
v4="$v3 avx512f avx512dq avx512cd avx512bw avx512vl"

check_level "v1" "$base" v1 false
check_level "v2" "$v2" v2 false
check_level "v3" "$v3" v3 true
check_level "v4" "$v4" v4 true

# Levels are cumulative: a CPU with only some v3/v4 flags is not that level, so
# --atleast cannot let an unsupported build through. A VM that exposes the
# AVX-512 flags while masking movbe is v2, not v4.
missing_movbe="$v2 avx2 bmi2 lzcnt avx512f avx512dq avx512cd avx512bw avx512vl"
check_level "v4 flags without v3" "$missing_movbe" v2 true
OMARCHY_CPU_FLAGS="$missing_movbe" "$helper" --atleast v3 &&
  fail "a v2 CPU with stray AVX-512 flags must not pass --atleast v3"
missing_lahf="$v2"; missing_lahf=${missing_lahf// lahf_lm/}
check_level "v2 without lahf_lm" "$missing_lahf" v1 false
OMARCHY_CPU_FLAGS="$missing_lahf" "$helper" --atleast v2 &&
  fail "a CPU without lahf_lm must not pass --atleast v2"
pass "levels are cumulative, so partial flag sets cannot pass a higher level"

OMARCHY_CPU_FLAGS="$v2" "$helper" --atleast v2 || fail "v2 --atleast v2"
if OMARCHY_CPU_FLAGS="$v2" "$helper" --atleast v3; then fail "v2 --atleast v3 must fail"; fi
OMARCHY_CPU_FLAGS="$v3" "$helper" --atleast v3 || fail "v3 --atleast v3"
if OMARCHY_CPU_FLAGS="$v3" "$helper" --atleast v4; then fail "v3 --atleast v4 must fail"; fi
pass "--atleast reflects the detected level"

# Non-x86 hosts get every check for free, but a bad level is still a usage
# error: --atleast validates its argument before the pass path, as on x86.
mockdir=$(mktemp -d)
trap 'rm -rf "$mockdir"' EXIT
printf '#!/bin/bash\nexit 1\n' >"$mockdir/omarchy-hw-x86"
chmod +x "$mockdir/omarchy-hw-x86"
export PATH="$mockdir:$ROOT/bin:$PATH"
"$helper" --atleast v3 || fail "non-x86 --atleast v3 passes"
"$helper" --avx2 || fail "non-x86 --avx2 passes"
if "$helper" --atleast bogus 2>/dev/null; then fail "non-x86 --atleast bogus is rejected"; fi
pass "non-x86 checks pass but reject an invalid level"
