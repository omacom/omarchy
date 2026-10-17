#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
prefix="$test_tmp/Games/battlenet"
launcher="$prefix/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
mkdir -p "$(dirname "$launcher")" "$mock_bin"
: >"$launcher"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ ${1:-} == clients ]]; then
  printf '%s\n' "${OMARCHY_TEST_CLIENTS_JSON:-[]}"
  exit 0
fi
if [[ ${1:-} == dispatch ]]; then
  printf 'focus:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
  exit 0
fi
exit 0
SH

# Real jq is used (require_command jq). pgrep stub returns canned process lines.
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ $* == "-af umu-run" ]] || exit 2
if [[ -n ${OMARCHY_TEST_PGREP_LINES:-} ]]; then
  printf '%s\n' "$OMARCHY_TEST_PGREP_LINES"
  exit 0
fi
exit 1
SH

cat >"$mock_bin/umu-run" <<'SH'
#!/bin/bash
printf 'launch:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH

chmod +x "$mock_bin"/*

launch_log="$test_tmp/launch-log"
run_launch() {
  : >"$launch_log"
  HOME="$test_tmp" PATH="$mock_bin:$PATH" OMARCHY_TEST_LOG="$launch_log" \
    bash "$ROOT/bin/omarchy-launch-battlenet" "$@"
}

export OMARCHY_TEST_CLIENTS_JSON='[]'
unset OMARCHY_TEST_PGREP_LINES
run_launch
grep -Fq 'launch:' "$launch_log" || fail "launcher starts umu-run when no Battle.net tree exists"
pass "launcher starts umu-run when no Battle.net tree exists"

export OMARCHY_TEST_CLIENTS_JSON='[{"class":"battle.net.exe","title":"Battle.net","address":"0xabc"}]'
unset OMARCHY_TEST_PGREP_LINES
run_launch
grep -Fq 'focus:' "$launch_log" || fail "launcher focuses an existing Battle.net window"
grep -Fq 'address:0xabc' "$launch_log" || fail "launcher focuses the Battle.net window address"
grep -Fq 'launch:' "$launch_log" && fail "launcher must not stack umu-run when a window exists"
pass "launcher focuses an existing Battle.net window"

# Title-only match must NOT steal focus (browser tab / Ghostty cwd).
export OMARCHY_TEST_CLIENTS_JSON='[{"class":"chromium","title":"Battle.net - Chromium","address":"0xbad"}]'
unset OMARCHY_TEST_PGREP_LINES
run_launch
grep -Fq 'focus:' "$launch_log" && fail "launcher must not focus title-only Battle.net matches"
grep -Fq 'launch:' "$launch_log" || fail "launcher starts when only a title match exists"
pass "launcher ignores title-only Battle.net window matches"

export OMARCHY_TEST_CLIENTS_JSON='[]'
export OMARCHY_TEST_PGREP_LINES="12345 python3 /usr/bin/umu-run $prefix/drive_c/Program Files (x86)/Battle.net/Battle.net Launcher.exe"
run_launch
grep -Fq 'launch:' "$launch_log" && fail "launcher must not stack umu-run when a headless tree exists"
grep -Fq 'notify:' "$launch_log" || fail "launcher notifies when refusing a headless relaunch"
pass "launcher refuses to stack a headless Battle.net tree"

# Sibling prefix must not count as running.
export OMARCHY_TEST_CLIENTS_JSON='[]'
export OMARCHY_TEST_PGREP_LINES="99999 python3 /usr/bin/umu-run ${prefix}-old/drive_c/x"
run_launch
grep -Fq 'launch:' "$launch_log" || fail "launcher starts when only a battlenet-old sibling tree exists"
pass "launcher ignores battlenet-old sibling umu-run trees"
