#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
fake_bin="$test_tmp/fake"
mkdir -p "$mock_bin" "$fake_bin" "$test_tmp/home"

# A real curated-add would touch the package manager. It is where an install
# ends, so logging its call proves what the gate let through; exit 1 stops the
# real installer there, which is all the gate cases need.
cat >"$mock_bin/omarchy-pkg-add-curated" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CURATED_LOG"
exit 1
SH

# The package being present is the real installer's installed branch's check;
# answer "missing" so the branch is deterministic. The dispatcher is what that
# branch runs next; a no-op keeps the installed case hermetic.
cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/omarchy-agent-account-dispatch" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

export HOME="$test_tmp/home"
# installed() runs type -P, and a claude/codex on this machine would take the
# already-installed branch before the gate ever runs. The hermetic PATH goes
# only on the installer calls below, so the test's own commands keep the host
# PATH.
restricted_path="$mock_bin:$fake_bin:$ROOT/bin"
export CURATED_LOG="$test_tmp/curated"

cli="$ROOT/bin/omarchy-install-ai-cli"
no_avx2="sse sse2 sse3 sse4_1 sse4_2 ssse3 cx16 popcnt lahf_lm pni fma avx f16c bmi1 abm xsave"
with_avx2="$no_avx2 avx2 bmi2 lzcnt movbe"

: >"$CURATED_LOG"
if PATH="$restricted_path" OMARCHY_CPU_FLAGS="$no_avx2" "$cli" claude >"$test_tmp/out" 2>"$test_tmp/err"; then
  fail "a Bun-agent install is rejected on a CPU without AVX2"
fi
grep -F "needs AVX2" "$test_tmp/err" >/dev/null ||
  fail "the AVX2 rejection names the reason"
[[ ! -s $CURATED_LOG ]] || fail "a rejected install never reaches the package manager"
pass "a Bun-agent install is rejected on a CPU without AVX2"

: >"$CURATED_LOG"
PATH="$restricted_path" OMARCHY_CPU_FLAGS="$no_avx2" "$cli" codex >/dev/null 2>&1 || true
grep -qx "openai-codex" "$CURATED_LOG" ||
  fail "the AVX2 gate does not block other agents"
pass "the AVX2 gate does not block other agents"

: >"$CURATED_LOG"
PATH="$restricted_path" OMARCHY_CPU_FLAGS="$with_avx2" "$cli" claude >/dev/null 2>&1 || true
grep -qx "claude-code" "$CURATED_LOG" ||
  fail "an AVX2 CPU can install a Bun agent"
pass "an AVX2 CPU can install a Bun agent"

# --check and --package only answer, with no gate warning even on a CPU the
# install gate would refuse.
if PATH="$restricted_path" OMARCHY_CPU_FLAGS="$no_avx2" "$cli" --check claude >"$test_tmp/out" 2>"$test_tmp/err"; then
  fail "--check exits 1 for a missing agent"
fi
[[ ! -s $test_tmp/out && ! -s $test_tmp/err ]] || fail "--check stays silent"
out=$(PATH="$restricted_path" OMARCHY_CPU_FLAGS="$no_avx2" "$cli" --package claude)
[[ $out == "claude-code" ]] || fail "--package names the package"
pass "--check and --package stay side-effect free"

# An existing CLI, for example a baseline build the user placed themselves,
# takes the installed branch before the gate and keeps working.
printf '#!/bin/bash\nexit 0\n' >"$fake_bin/claude"
chmod +x "$fake_bin/claude"
if ! PATH="$fake_bin:$mock_bin:$ROOT/bin" OMARCHY_CPU_FLAGS="$no_avx2" "$cli" claude >"$test_tmp/out" 2>"$test_tmp/err"; then
  fail "an installed agent is not blocked by the gate"
fi
[[ ! -s $test_tmp/err ]] || fail "an installed agent reinstall says nothing"
pass "an installed agent is not blocked by the gate"
