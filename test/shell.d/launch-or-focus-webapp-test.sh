#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# No window matches, so omarchy-launch-or-focus takes its launch path.
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
[[ ${1:-} == clients ]] && echo "[]"
exit 0
SH

# The arguments setsid receives are the ones omarchy-launch-webapp would start with.
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$OMARCHY_TEST_ARGV"
SH
chmod +x "$mock_bin"/*

export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_ARGV="$test_tmp/argv"

executed="$test_tmp/executed"
launched=()

# Runs the real wrapper and the real omarchy-launch-or-focus, so the eval that
# re-parses the launch command is the one under test.
launch() {
  : >"$OMARCHY_TEST_ARGV"
  bash "$ROOT/bin/omarchy-launch-or-focus-webapp" "$@" >/dev/null 2>&1 || return 1
  mapfile -d '' -t launched <"$OMARCHY_TEST_ARGV"
}

# Every argument after the window pattern must reach omarchy-launch-webapp as it
# was given: same words, same boundaries, nothing added.
assert_forwarded() {
  local description="$1"
  shift

  launch "$@" || fail "$description" "the wrapper exited non-zero"

  local expected actual
  expected=$(printf '[%s]' omarchy-launch-webapp "${@:2}")
  actual=$(printf '[%s]' "${launched[@]}")

  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected
actual:   $actual"
  pass "$description"
}

# Unquoted, the & ends the command and backgrounds it, and the ; ends it.
assert_forwarded "a URL with an ampersand reaches the launcher intact" Pattern 'https://example.com/?a=1&b=2'
assert_forwarded "a URL with a semicolon reaches the launcher intact" Pattern 'https://example.com/?a=1;b=2'
assert_forwarded "spaces stay inside one argument" Pattern 'https://example.com/a b'
assert_forwarded "a fragment is not read as a comment" Pattern 'https://example.com/#section'
assert_forwarded "a single quote survives" Pattern "https://example.com/it's"
assert_forwarded "a double quote survives" Pattern 'https://example.com/a"b'
assert_forwarded "glob characters are not expanded" Pattern 'https://example.com/*?[a]'
assert_forwarded "browser flags stay separate arguments" Pattern 'https://example.com' --new-window --class=Foo

# The property the quoting exists for: nothing in a URL gets to run.
assert_forwarded "command substitution stays data" Pattern "https://example.com/\$(touch $executed)"
assert_forwarded "backticks stay data" Pattern "https://example.com/\`touch $executed\`"
assert_forwarded "a separator does not start a second command" Pattern "https://example.com/;touch $executed"

[[ ! -e $executed ]] || fail "no URL runs a command"
pass "no URL runs a command"

# With only a window pattern there is nothing to forward. An unconditional
# printf '%q ' "$@" would turn that into one empty argument.
assert_forwarded "no URL means no argument rather than an empty one" Pattern
