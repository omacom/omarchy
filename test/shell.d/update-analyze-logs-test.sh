#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

script="$ROOT/bin/omarchy-update-analyze-logs"
missing_log="$test_tmp/omarchy-update.log"

# The script hardcodes /tmp/omarchy-update.log, so run a copy pointed at a
# temporary path to keep the host's own update log out of every case.

wrapper="$test_tmp/analyze"
sed "s|/tmp/omarchy-update.log|$missing_log|" "$script" >"$wrapper"
chmod +x "$wrapper"

out=$("$wrapper")
[[ $out == "No update log found; nothing to analyze." ]] ||
  fail "analyze logs reports a clean miss when the update log is absent" "$out"
pass "analyze logs reports a clean miss when the update log is absent"

printf '%s\n' "Updating linux initcpios" >"$missing_log"
out=$("$wrapper")
[[ $out == *$'\e[31mError: Initramfs generation may have failed. Review logs before restart.\e[0m'* ]] ||
  fail "analyze logs still flags a failed initramfs when the log exists" "$out"
pass "analyze logs still flags a failed initramfs when the log exists"

printf '%s\n' "Updating linux initcpios" "Initcpio image generation successful" >"$missing_log"
out=$("$wrapper")
[[ -z $out ]] || fail "analyze logs stays quiet on a successful initramfs" "$out"
pass "analyze logs stays quiet on a successful initramfs"
