#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-shell hands every argument to the shell whole. Its socket path sends
# fields verbatim; the qs ipc fallback it uses otherwise splits a bracketed list
# literal ("[a,b]", even "[x]") into one argument per item, which turns one
# widget setting of ["claude","codex"] into two, and a one-element list into its
# element. An empty list reaches qs ipc as CLI11's [[]] escape, and any other
# argument shaped like a list literal with a trailing space, so each stays one
# value.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/qs" <<'STUB'
#!/bin/bash

if [[ -n ${OMARCHY_TEST_IPC_ARGS:-} ]]; then
  {
    printf 'qs'
    printf ' <%s>' "$@"
    printf '\n'
  } >>"$OMARCHY_TEST_IPC_ARGS"
fi
exit 0
STUB
chmod +x "$mock_bin/qs"

args_log="$test_tmp/args.log"
run_shell() {
  OMARCHY_PATH="$ROOT" \
    XDG_RUNTIME_DIR="$test_tmp" \
    OMARCHY_TEST_IPC_ARGS="$args_log" \
    PATH="$mock_bin:$PATH" \
    "$ROOT/bin/omarchy-shell" "$@" >/dev/null
}

run_shell shell setBarWidget demo.key '{"a":1}' '["claude","codex"]'
grep -F '<shell> <setBarWidget> <demo.key> <{"a":1}> <["claude","codex"] >' "$args_log" >/dev/null ||
  fail "a bracketed argument reaches the shell as one value" "$(cat "$args_log")"
pass "a bracketed argument reaches the shell as one value"

run_shell shell setBarWidget demo.key '["only"]' '{}'
grep -F '<["only"] >' "$args_log" >/dev/null ||
  fail "a one-element list literal stays one value" "$(cat "$args_log")"
pass "a one-element list literal stays one value"

run_shell shell setBarWidget demo.key '[]' '{}'
grep -F '<[[]]>' "$args_log" >/dev/null ||
  fail "an empty list literal goes as CLI11's [[]] escape" "$(cat "$args_log")"
pass "an empty list literal goes as CLI11's [[]] escape"

grep -F '<{"a":1}>' "$args_log" >/dev/null ||
  fail "an argument that is not a list literal is untouched" "$(cat "$args_log")"
pass "an argument that is not a list literal is untouched"
