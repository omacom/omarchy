#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
stub_bin="$test_dir/bin"
tool_dir="$test_dir/tool with spaces"
mkdir -p "$test_home" "$stub_bin" "$tool_dir"
export OMARCHY_MISE_RESOLUTION_LOG="$test_dir/mise.log"
export OMARCHY_MISE_ARGUMENTS="$test_dir/arguments"
export OMARCHY_MISE_RESOLVED_BIN="$tool_dir/tool"

cat >"$stub_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >>"$OMARCHY_MISE_RESOLUTION_LOG"
case $1 in
  use) exit "${OMARCHY_MISE_USE_STATUS:-0}" ;;
  which)
    [[ $2 == "--tool" && $3 == "npm:example" && $4 == "tool" ]] || exit 91
    printf '%s\n' "$OMARCHY_MISE_RESOLVED_BIN"
    exit "${OMARCHY_MISE_WHICH_STATUS:-0}"
    ;;
  x)
    [[ $2 == "npm:example" && $3 == "--" ]] || exit 92
    shift 3
    # Model mise preserving the earlier wrapper entry in PATH. Bound any
    # recursion so this regression fails safely against the original template.
    export OMARCHY_MISE_EXEC_DEPTH=$(( ${OMARCHY_MISE_EXEC_DEPTH:-0} + 1 ))
    (( OMARCHY_MISE_EXEC_DEPTH < 3 )) || exit 93
    export OMARCHY_MISE_RUNTIME="runtime from mise"
    exec "$@"
    ;;
esac
exit 94
SH
cat >"$OMARCHY_MISE_RESOLVED_BIN" <<'SH'
#!/bin/bash
printf '%s\0' "$OMARCHY_MISE_RUNTIME" "$@" >"$OMARCHY_MISE_ARGUMENTS"
printf '{"loggedIn":false}\n'
SH
chmod +x "$stub_bin/mise" "$OMARCHY_MISE_RESOLVED_BIN"
HOME="$test_home" "$ROOT/bin/omarchy-mise-install" npm:example tool >/dev/null
wrapper="$test_home/.local/bin/tool"

run_wrapper() {
  HOME="$test_home" PATH="$test_home/.local/bin:$stub_bin:/usr/bin" "$wrapper" "$@"
}

output=$(run_wrapper auth status --json "two words" "" '*')
[[ $output == '{"loggedIn":false}' ]] || fail "wrapper preserves protocol stdout"
mapfile -d '' -t args <"$OMARCHY_MISE_ARGUMENTS"
[[ ${#args[@]} == 7 && ${args[0]} == "runtime from mise" && ${args[1]} == "auth" && ${args[4]} == "two words" && ${args[5]} == "" && ${args[6]} == '*' ]] ||
  fail "wrapper retains mise runtime variables and argument boundaries"
[[ $(cat "$OMARCHY_MISE_RESOLUTION_LOG") == $'use\nwhich\nx' ]] ||
  fail "wrapper resolves the installed executable after activation without re-entry"
pass "wrapper-first PATH executes the actual tool once with runtime and arguments intact"

refuse_resolution() {
  local label=$1 resolved=$2
  : >"$OMARCHY_MISE_RESOLUTION_LOG"
  if OMARCHY_MISE_RESOLVED_BIN="$resolved" run_wrapper >/dev/null 2>"$test_dir/error"; then
    fail "wrapper refuses $label"
  fi
  ! grep -qx x "$OMARCHY_MISE_RESOLUTION_LOG" || fail "$label never reaches mise x"
  grep -q 'did not resolve a usable executable' "$test_dir/error" || fail "$label reports the resolution error"
  pass "wrapper refuses $label before execution"
}

refuse_resolution "its own path" "$wrapper"
ln -s "$wrapper" "$test_dir/self-symlink"
refuse_resolution "a symlink to itself" "$test_dir/self-symlink"
ln "$wrapper" "$test_dir/self-hardlink"
refuse_resolution "a hard link to itself" "$test_dir/self-hardlink"
refuse_resolution "a relative path" tool
refuse_resolution "an empty result" ""
refuse_resolution "a missing executable" "$test_dir/missing"
printf 'not executable\n' >"$test_dir/non-executable"
refuse_resolution "a non-executable file" "$test_dir/non-executable"
chmod +x "$tool_dir"
refuse_resolution "an executable directory" "$tool_dir"

for failure in USE WHICH; do
  : >"$OMARCHY_MISE_RESOLUTION_LOG"
  if env "OMARCHY_MISE_${failure}_STATUS=37" HOME="$test_home" PATH="$test_home/.local/bin:$stub_bin:/usr/bin" "$wrapper" >/dev/null 2>&1; then
    fail "a failed $failure stops the wrapper"
  fi
  ! grep -qx x "$OMARCHY_MISE_RESOLUTION_LOG" || fail "a failed $failure never falls back to PATH"
  pass "a failed $failure stops before execution"
done
