#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d) || fail "create debug CLI test directory"
trap 'rm -rf -- "${test_tmp:?}"' EXIT

check_debug_metadata() {
  local cli="$1"
  local listing
  local help

  listing=$("$cli" commands --all --json)
  jq -e '.commands[] | select(.route == "omarchy debug" and .binary == "omarchy-debug" and .summary == "Print debugging information" and .args == "[--no-sudo] [--print]" and .requires_sudo == true and .examples == ["omarchy debug --print --no-sudo"])' <<<"$listing" >/dev/null || fail "debug CLI metadata is complete"
  help=$("$cli" debug --help)
  [[ $help == *"omarchy debug [--no-sudo] [--print]"* ]] || fail "debug CLI help shows the public route"
}

# The source tree scans the collector's header; the installed launcher is a
# native binary and uses the sidecar metadata in share/omarchy instead.
check_debug_metadata "$ROOT/bin/omarchy"
pass "source CLI reads the canonical debug command metadata"

mkdir -p "$test_tmp/bin" "$test_tmp/share/omarchy/command-metadata"
cp "$ROOT/bin/omarchy" "$test_tmp/bin/omarchy"
printf 'native launcher placeholder\n' >"$test_tmp/bin/omarchy-debug"
chmod +x "$test_tmp/bin/omarchy-debug"
cp "$ROOT/default/omarchy/command-metadata/omarchy-debug" "$test_tmp/share/omarchy/command-metadata/omarchy-debug"
check_debug_metadata "$test_tmp/bin/omarchy"
pass "installed CLI reads debug metadata beside the native launcher"

# The Bash payload is only usable through the packaged native launcher.
# A positional -p must not be mistaken for a protected Bash startup.
mkdir -p "$test_tmp/home" "$test_tmp/runtime" "$test_tmp/state"
for startup in direct decoy; do
  if [[ $startup == "direct" ]]; then
    command=("$ROOT/bin/omarchy-debug" --print)
  else
    command=(/usr/bin/bash "$ROOT/bin/omarchy-debug" -p --print)
  fi

  status=0
  output=$(/usr/bin/env -i PATH=/usr/bin:/bin HOME="$test_tmp/home" \
    XDG_RUNTIME_DIR="$test_tmp/runtime" XDG_STATE_HOME="$test_tmp/state" \
    "${command[@]}" 2>&1) || status=$?
  (( status == 126 )) || fail "debug payload refuses $startup startup"
  [[ $output == *"Run the packaged omarchy-debug command directly"* ]] || fail "debug payload explains $startup refusal"
  [[ ! -e $test_tmp/runtime/omarchy-debug.log &&
    ! -e $test_tmp/state/omarchy/omarchy-debug.log &&
    ! -e $test_tmp/home/.local/state/omarchy/omarchy-debug.log ]] || fail "refused debug payload creates no log"
  pass "debug payload refuses $startup startup without creating a log"
done
