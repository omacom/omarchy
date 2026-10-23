#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
launch_log="$test_tmp/launch"
mkdir -p "$mock_bin" "$test_home"

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$TEST_LAUNCH_LOG"
SH

# The launcher asks the focused terminal for its cwd, which needs a compositor.
cat >"$mock_bin/omarchy-cmd-terminal-cwd" <<'SH'
#!/bin/bash
printf '%s\n' "$TEST_CWD"
SH

chmod +x "$mock_bin"/*

export HOME="$test_home"
export OMARCHY_PATH="$ROOT"
export TEST_LAUNCH_LOG="$launch_log"
export PATH="$mock_bin:$ROOT/bin:$PATH"

# Compare the whole argument vector, one element at a time: a substring or $*
# match would miss an argument that was split, merged or dropped.
assert_launch_argv() {
  local label=$1 cwd=$2
  local -a expected argv
  local i

  : >"$launch_log"
  TEST_CWD=$cwd "$ROOT/bin/omarchy-launch-terminal-herdr"
  mapfile -d '' -t argv <"$launch_log"

  expected=(uwsm-app -- xdg-terminal-exec "--dir=$cwd" --app-id=org.omarchy.herdr herdr)

  (( ${#argv[@]} == ${#expected[@]} )) ||
    fail "herdr launch in $label passes exactly ${#expected[@]} arguments" \
      "expected: $(printf '%q ' "${expected[@]}")"$'\n'"actual:   $(printf '%q ' "${argv[@]}")"

  for i in "${!expected[@]}"; do
    [[ ${argv[i]} == "${expected[i]}" ]] ||
      fail "herdr launch in $label passes ${expected[i]} as argument $((i + 1))" \
        "expected: $(printf '%q ' "${expected[@]}")"$'\n'"actual:   $(printf '%q ' "${argv[@]}")"
  done

  pass "herdr launches as the exact argv in $label"
}

assert_launch_argv "a cwd with spaces and shell metacharacters" "$test_tmp/work dir; touch pwned"
assert_launch_argv "a HOME cwd" "$HOME"
