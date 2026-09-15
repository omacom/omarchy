#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

refresh_function=$(sed -n '/^refresh_running_browser() {/,/^}/p' "$ROOT/bin/omarchy-theme-set-browser")
[[ -n $refresh_function ]] || fail "omarchy-theme-set-browser defines refresh_running_browser"
eval "$refresh_function"

omarchy-cmd-present() { return 0; }
pgrep() { return 0; }

timeout_args=()
timeout() {
  timeout_args=("$@")
  return 124
}

refresh_running_browser chromium chromium ||
  fail "a timed-out browser policy refresh does not fail theme application"

expected=(10 chromium --refresh-platform-policy --no-startup-window)
[[ ${timeout_args[*]} == "${expected[*]}" ]] ||
  fail "browser policy refresh is bounded to 10 seconds" "got: ${timeout_args[*]}"
pass "browser policy refresh is bounded to 10 seconds"
pass "browser policy refresh timeout is best-effort"
