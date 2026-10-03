#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

THEME_ORDER_TEST=$(mktemp -d)
trap 'rm -rf "$THEME_ORDER_TEST"' EXIT

# Source only the function under test so this file does not execute a real theme
# change while verifying the sequencing contract.
source <(awk '
  /^apply_running_theme\(\) \{/ { copying=1 }
  copying { print }
  copying && /^}$/ { exit }
' "$ROOT/bin/omarchy-theme-set")

log="$THEME_ORDER_TEST/order.log"
stub_bin="$THEME_ORDER_TEST/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-theme-set-herdr" <<'EOF'
#!/bin/bash
echo herdr >>"$THEME_ORDER_LOG"
EOF
chmod +x "$stub_bin/omarchy-theme-set-herdr"

run_parallel() {
  printf 'parallel:%s\n' "$*" >>"$THEME_ORDER_LOG"
}

THEME_ORDER_LOG="$log" PATH="$stub_bin:$PATH" apply_running_theme

mapfile -t phases <"$log"

[[ ${#phases[@]} -eq 2 ]] ||
  fail "theme refresh runs Herdr barrier before parallel application refresh" "$(cat "$log")"

[[ ${phases[0]} == "herdr" ]] ||
  fail "Herdr theme hook runs synchronously before application refreshes" "$(cat "$log")"

[[ ${phases[1]} == *"omarchy-restart-opencode"* ]] ||
  fail "OpenCode refreshes after the Herdr palette barrier" "$(cat "$log")"

[[ ${phases[1]} == *"omarchy-theme-set-foot"* && ${phases[1]} == *"omarchy-theme-set-tmux"* ]] ||
  fail "existing terminal and tmux refresh hooks stay in the parallel batch" "$(cat "$log")"

pass "theme refresh retints Herdr before terminal-adaptive applications"
