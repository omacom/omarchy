#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command script

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
mkdir -p "$stub_bin"

cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "-Qtdq" ]]; then
  printf 'asar\nvulkan-headers\n'
  exit 0
fi
printf 'pacman %s\n' "$*" >>"$CALL_LOG"
STUB

cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
printf 'gum %s\n' "$*" >>"$CALL_LOG"
exit 1
STUB

cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
exit 1
STUB

chmod +x "$stub_bin/"*
printf -v command '%q' "$ROOT/bin/omarchy-update-orphan-pkgs"

: >"$call_log"
output=$(OMARCHY_UPDATE_UNATTENDED=1 CALL_LOG="$call_log" PATH="$stub_bin:/usr/bin:/bin" \
  script -qefc "$command" /dev/null | tr -d '\r') ||
  fail "unattended orphan review exits successfully" "$output"

[[ ! -s $call_log ]] ||
  fail "unattended orphan review does not prompt or remove packages" "$(cat "$call_log")"
grep -Fq '2 orphaned package(s) found. Re-run omarchy-update-orphan-pkgs in a terminal to review/remove them.' <<<"$output" ||
  fail "unattended orphan review reports what it skipped" "$output"
pass "unattended orphan review skips the prompt even on a PTY"

: >"$call_log"
output=$(CALL_LOG="$call_log" PATH="$stub_bin:/usr/bin:/bin" \
  script -qefc "$command" /dev/null | tr -d '\r') ||
  fail "interactive orphan review exits successfully when removal is declined" "$output"

grep -Fq 'gum confirm --default=false Remove 2 orphaned package(s)?' "$call_log" ||
  fail "interactive orphan review still prompts" "$(cat "$call_log")"
if grep -q '^sudo ' "$call_log"; then
  fail "declining interactive orphan removal still removes packages" "$(cat "$call_log")"
fi
pass "interactive orphan review still prompts"
